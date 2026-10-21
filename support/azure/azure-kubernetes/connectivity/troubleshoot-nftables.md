---
layout: Conceptual
title: Troubleshoot nftables in AKS clusters - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-nftables
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: sufuf3
ms.author: shanjungfu
ms.topic: troubleshooting
description: Troubleshoot nftables configuration in AKS by validating kube-proxy settings, rules, and compatibility issues to quickly restore service connectivity—start now.
ms.date: 2026-05-05T00:00:00.0000000Z
ms.reviewer: jarrettr
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Connectivity
locale: en-us
document_id: 411abfd7-da50-77c2-bc3c-be2579b01d09
document_version_independent_id: 411abfd7-da50-77c2-bc3c-be2579b01d09
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/troubleshoot-nftables.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/troubleshoot-nftables
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/troubleshoot-nftables.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f2cb5f27-c1cf-5a4f-6c58-5779f4e0c050
---

# Troubleshoot nftables in AKS clusters - Azure | Microsoft Learn

## Summary

This article provides guidance for troubleshooting issues with nftables when used as the kube-proxy backend in Azure Kubernetes Service (AKS). It covers steps to verify that the cluster is configured to use nftables, that kube-proxy pods are running correctly, that the kube-proxy command-line arguments are set appropriately for nftables mode, and how to inspect the nftables ruleset on nodes or within kube-proxy pods.

nftables is the third kube-proxy backend mode supported in AKS, alongside iptables (default) and IPVS. It leverages the Linux nftables subsystem - the successor to iptables - to implement Layer 3/Layer 4 service load balancing within the cluster. Compared to iptables and IPVS, nftables provides improved performance and scalability, and is recommended as the long-term replacement for IPVS. Additionally, unlike IPVS mode, nftables is fully compatible with Azure Network Policy, making it a more suitable choice for environments requiring network policy enforcement.

## Troubleshooting checklist

### Step 1: Confirm the cluster is configured for nftables mode

Check networkProfile.kubeProxyConfig in the cluster properties and ensure the Kubernetes version is &gt;= 1.33.0.

```bash
$ az aks show --resource-group <ResourceGroupName> -n <ClusterName> --query networkProfile.kubeProxyConfig
"networkProfile": {
    "kubeProxyConfig": {
        "enabled": true,
        "mode": "NFTABLES"
    }
}
```

### Step 2: Verify kube-proxy pods are running

Check that all kube-proxy pods are in the `Running` state with zero restarts.

```sh
$ kubectl get pods -n kube-system -owide | grep kube-proxy
```

### Step 3: Verify kube-proxy command-line arguments

Describe a kube-proxy pod and confirm `--proxy-mode=nftables` is present:

```bash
$ kubectl describe pod -n kube-system <kube-proxy-pod>
```

Expected arguments for nftables mode:

```yaml
Containers:
  kube-proxy:
    Command:
      kube-proxy
      --conntrack-max-per-core=0
      --metrics-bind-address=0.0.0.0:10249
      --kubeconfig=/var/lib/kubelet/kubeconfig
      --cluster-cidr=10.244.0.0/16
      --detect-local-mode=ClusterCIDR
      --v=3
      --proxy-mode=nftables
```

> 
> **Note:** The command line shouldn't include any IPVS-specific arguments, such as `--ipvs-scheduler` or `--ipvs-tcp-timeout`. If `--proxy-mode=nftables` is missing, confirm the Kubernetes version is 1.33.0 or later and that the goal state has the correct mode.

### Step 4: Verify nftables rules on a node or kube-proxy pod

You can inspect the nftables ruleset either by SSH or JIT-ing to a node, or by using `kubectl exec` to enter the kube-proxy pod (which shares the host network namespace):

```bash
# From a node
$ nft list ruleset

# Or from inside the kube-proxy pod
$ kubectl -n kube-system exec -it <kube-proxy-pod> -- nft list ruleset
```

When kube-proxy runs in nftables mode, you see a table named `ip kube-proxy` containing chains for service routing, such as `services`, `service-endpoints`, `filter-prerouting`, and `filter-output`.

Example output (abbreviated):

```text
table ip kube-proxy {
    chain services {
        type nat hook prerouting priority dstnat; policy accept;
        ip daddr . meta l4proto . th dport vmap @service-ips
    }

    chain service-endpoints {
        ...
    }

    chain filter-prerouting {
        type filter hook prerouting priority -110; policy accept;
        ct state new jump firewall-check
    }

    chain masquerading {
        type nat hook postrouting priority srcnat; policy accept;
        ...
    }
}
```

If `nft list ruleset` shows no `kube-proxy` table:

- Kube-proxy might not start in nftables mode - check Step 3.
- The `nft` binary might not be installed - install it by running `apt install nftables`.
- Check kube-proxy logs for errors by running `kubectl logs -n kube-system <kube-proxy-pod>`.

**Tip**: To check rules for a specific service, look for the service's ClusterIP in the nftables maps:

```bash
$ nft list map ip kube-proxy service-ips
```

### Step 5: Verify Calico linuxDataplane (if applicable)

For clusters using Calico network policy (kubenet or Azure CNI with Calico), verify the Calico Installation CR is configured for nftables:

```bash
$ kubectl get installation default -o yaml | grep linuxDataplane
```

Expected output:

```yaml
    linuxDataplane: Nftables
```

If this field is missing or shows a different value, Calico's Felix component might use the iptables backend, which can cause rule conflicts with kube-proxy in nftables mode. Check:

1. Kubernetes version is &gt;= 1.33.0 (Calico nftables also gates on this).
2. The Calico synth or Helm template rendered the correct value.
3. Calico operator logs: `kubectl logs -n calico-system deployment/tigera-operator`.

### Step 6: Check kube-proxy logs

If service connectivity problems persist, check kube-proxy logs for errors:

```bash
# Current container logs
$ kubectl logs -n kube-system <kube-proxy-pod>

# Previous container logs (useful after a crash)
$ kubectl logs -n kube-system --previous <kube-proxy-pod>
```

Common log messages to look for:

- `"Using nftables Proxier"` — confirms nftables mode is active.
- `"Failed to execute nft"` — indicates an issue running nft commands on the node.
- `"Error syncing proxy rules"` — nftables rule programming failed.

## Issue 1: nftables mode silently not applied (k8s &lt; 1.33.0)

### Symptom

Cluster API shows `mode: NFTABLES` but kube-proxy runs with `--proxy-mode=iptables` (or no `--proxy-mode` flag).

### Cause

The API validator doesn't enforce a minimum Kubernetes version for nftables mode. The Helm template only renders `--proxy-mode=nftables` when Kubernetes is version 1.33.0 or higher. On older versions, the flag is silently omitted.

### Resolution

Upgrade the cluster to Kubernetes version 1.33.0 or higher.

## Issue 2: Feature flag not registered (error 1132)

### Symptom

API call to create or update the cluster returns error code 1132 (`KubeProxyConfigFeatureNotRegistered`).

### Cause

The AFEC feature flag `Microsoft.ContainerService/KubeProxyConfigurationPreview` isn't registered on the subscription.

### Resolution

Register the feature flag:

```sh
az feature register --namespace "Microsoft.ContainerService" --name "KubeProxyConfigurationPreview"
# Wait for status to show "Registered", then:
az provider register --namespace Microsoft.ContainerService
```

## Issue 3: IPVS config fields rejected (error 1133)

### Symptom

API returns error code 1133 (`KubeProxyConfigFieldUnsupported`) when creating or updating with nftables mode.

### Cause

You included IPVS-specific fields (for example, `scheduler`, `TCPTimeoutSeconds`, `TCPFINTimeoutSeconds`, `UDPTimeoutSeconds`) in the `kubeProxyConfig` while setting mode to `NFTABLES`.

### Resolution

Remove all `ipvsConfig` fields from the configuration. nftables mode doesn't accept IPVS-specific settings. Example valid config:

```json
{
  "enabled": true,
  "mode": "NFTABLES"
}
```

## Issue 4: Cilium dataplane conflict

### Symptom

API returns error with SubCode `CiliumDataplaneRequiresKubeProxyConfigDisabled`.

### Cause

Cilium replaces kube-proxy entirely. Any `kubeProxyConfig` with `enabled: true` is rejected on Cilium dataplane clusters.

### Resolution

You can't use nftables mode with Cilium dataplane. If you want nftables proxy behavior, you need to use a non-Cilium network configuration.

## Issue 5: Service connectivity issues after mode transition

### Symptom

Some services are unreachable briefly after switching from iptables/IPVS to nftables.

### Cause

During the transition, nodes might have stale iptables or IPVS rules until the kube-proxy daemonset rollout finishes on all nodes.

### Resolution

Wait for the kube-proxy daemonset rollout to finish:

```sh
$ kubectl rollout status daemonset/kube-proxy -n kube-system
```

kube-proxy cleans up old rules from the previous mode on restart. If connectivity problems persist after the rollout finishes, cordon and drain affected nodes to force a fresh start.

## Issue 6: Calico/Felix errors after enabling nftables

### Symptom

Calico Felix pods log errors about nftables or iptables rule conflicts. Network policy enforcement might be inconsistent.

### Cause

Calico's Felix wasn't switched to nftables backend when kube-proxy mode changed. This problem can happen if the cluster Kubernetes version is below the 1.33.0 gate or the Calico Installation CR wasn't updated.

### Resolution

Verify `linuxDataplane: Nftables` in the Calico Installation CR (see Step 5). If missing, you might need to redeploy the Calico chart or synth. Escalate to the networking SIG if you can't set the field.

## CNI compatibility

| Network Plugin | nftables Support | Notes |
| --- | --- | --- |
| Azure CNI | Supported | Works directly. |
| Kubenet | Supported | Works with Calico network policy. |
| BYO CNI (`none`) | Supported | If kube-proxy is enabled. |
| Cilium Dataplane | **Not supported** | Cilium replaces kube-proxy. `kubeProxyConfig.enabled` must be `false`. |

Azure Network Policy is **supported** with nftables mode (unlike IPVS, which doesn't support Azure Network Policy).