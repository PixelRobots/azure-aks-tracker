---
layout: Conceptual
title: AKS cluster upgrade fails because of NSG rules - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/upgrade-fails-because-of-nsg-rules
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Learn how to troubleshoot an Azure Kubernetes Service (AKS) cluster or node pool upgrade that fails because network security group (NSG) rules block required outbound traffic.
ms.date: 2026-10-16T00:00:00.0000000Z
ms.reviewer: chiragpa, v-leedennis, andbar
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-generated
locale: en-us
document_id: a0a969bc-3893-8995-f042-2023fb6e36cb
document_version_independent_id: a0a969bc-3893-8995-f042-2023fb6e36cb
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/upgrade-fails-because-of-nsg-rules.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/upgrade-fails-because-of-nsg-rules
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/upgrade-fails-because-of-nsg-rules.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: b3cf4a1c-44c8-4b5c-de59-c142f2aeeffa
---

# AKS cluster upgrade fails because of NSG rules - Azure | Microsoft Learn

## Summary

This article explains how to fix an Azure Kubernetes Service (AKS) cluster or node pool upgrade that fails because network security group (NSG) rules block required outbound traffic.

Unless you use a [network isolated cluster](/en-us/azure/aks/concepts-network-isolated), AKS nodes need [outbound connectivity](/en-us/azure/aks/outbound-rules-control-egress) to a set of [required endpoints and FQDNs](/en-us/azure/aks/outbound-rules-control-egress#required-outbound-network-rules-and-fqdns-for-aks-clusters). Nodes use this connectivity during provisioning, upgrades, and scaling. For example, a node must be able to:

- Reach the Kubernetes API server.
- Resolve domain name system (DNS) names.
- Pull container images from Microsoft Container Registry (MCR).
- Download required binaries and packages.

Almost all AKS outbound dependencies are defined as FQDNs, and the IP addresses behind them aren't static. Because of this, you can't use NSGs to restrict outbound traffic from an AKS cluster. By default, AKS clusters have unrestricted outbound internet access. If you have to restrict egress traffic, use a solution that supports fully qualified domain name (FQDN) filtering, such as [Azure Firewall](/en-us/azure/aks/limit-egress-traffic), and keep the required ports and addresses reachable. Don't use NSG rules that deny all outbound internet traffic. For more information, see [Outbound network and FQDN rules for AKS clusters - Background](/en-us/azure/aks/outbound-rules-control-egress#background).

NSGs aren't the recommended way to restrict AKS egress, but an NSG rule can still block traffic that the cluster needs. When that happens, the upgrade fails.

## Prerequisites

The following prerequisites are required to troubleshoot NSG-related upgrade failures:

- [Azure CLI](/en-us/cli/azure/install-azure-cli). Use the latest version. To check your version, run `az --version`.
- Access to a node in the cluster to run connectivity tests. For more information, see [Connect to AKS cluster nodes](/en-us/azure/aks/node-access).
- The `curl` and `nslookup` command-line tools on the node.

For more information about the upgrade process, see [Upgrade an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/upgrade-cluster#upgrade-an-aks-cluster).

## Symptoms

The AKS cluster or node pool upgrade fails. The following table lists the most common error messages, but you might see others.

| Exit code | Error | Meaning |
| --- | --- | --- |
| 50 | [OutboundConnFailVMExtensionError](/en-us/troubleshoot/azure/azure-kubernetes/error-code-outboundconnfailvmextensionerror) | The node can't connect to a required outbound endpoint, such as `mcr.microsoft.com`. |
| 51 | [K8SAPIServerConnFailVMExtensionError](/en-us/troubleshoot/azure/azure-kubernetes/error-code-k8sapiserverconnfailvmextensionerror) | The node can't connect to the cluster's API server. |
| 52 | [K8SAPIServerDNSLookupFailVMExtensionError](/en-us/troubleshoot/azure/azure-kubernetes/error-code-k8sapiserverdnslookupfailvmextensionerror) | The node can't resolve the API server FQDN. |

Important

These errors mean that something blocks node connectivity or DNS resolution. They don't prove that an NSG is the cause. Other components can block the same traffic, for example:

- A firewall or network virtual appliance (NVA)
- A proxy server
- A user-defined route (UDR)
- A custom DNS server
- [API server authorized IP ranges](/en-us/azure/aks/api-server-authorized-ip-ranges)

Use the Troubleshooting section to find which component blocks the traffic.

## Cause

During an upgrade, AKS creates new (surge) nodes or reimages existing nodes with the new node image. Each node runs a bootstrap process through the Custom Script Extension (CSE). The process must be able to:

- Resolve DNS names through the DNS server that's configured on the virtual network.
- Reach required outbound endpoints, such as MCR, over TCP port 443.
- Reach the cluster's API server so that the node can register with the cluster.

If an NSG rule blocks any of this traffic, the CSE fails with an exit code, the node doesn't join the cluster, and the upgrade fails. An NSG can block this traffic in several ways:

- An outbound rule denies traffic to the `Internet` service tag, or uses a broad deny-all rule whose priority is higher than the allow rules.
- An outbound rule denies traffic to the IP addresses or ports of a required endpoint, such as the API server IP address (public, or the private endpoint IP of a private cluster) on TCP port 443.
- An outbound rule blocks DNS traffic (UDP/TCP port 53) to a custom DNS server that's configured on the virtual network.

You can apply NSG rules at two levels, and both levels are evaluated:

- **Subnet level** - An NSG that you associate with the node subnet, typically when you use your own virtual network.
- **Network interface level** - The AKS-managed NSG in the node resource group (by default named `MC_<resource-group>_<cluster-name>_<location>`).

Note

An upgrade often fails after you add or change an NSG rule since the last successful cluster operation. Existing nodes keep working because their connections are already established. New nodes that are created during the upgrade can't bootstrap.

## Troubleshooting

The following options can help you troubleshoot NSG-related upgrade failures.

### Option 1: Use Connectivity analysis

**Connectivity analysis** in the [Azure portal](https://portal.azure.com) uses the same engine as [Azure Virtual Network Verifier](/en-us/azure/virtual-network-manager/concept-virtual-network-verifier). It quickly shows whether Azure network resources block outbound traffic from your AKS nodes to an endpoint. It checks:

- Azure Load Balancer
- Azure Firewall
- NAT gateway
- Network security groups (NSGs)
- Network policies
- User-defined routes (route tables)
- Virtual network peering

To run the analysis:

1. In the [Azure portal](https://portal.azure.com), go to your AKS cluster.
2. Under **Settings**, select **Node pools**.
3. On the toolbar, select **Connectivity analysis**. If you don't see it, select the ellipsis (**...**).
4. Select the source node pool, enter the destination endpoint (for example, `mcr.microsoft.com` or the API server FQDN), and then select **Run analysis**.

[![Screenshot of Connectivity analysis (preview).](media/upgrade-fails-because-of-nsg-rules/connectivity-analysis-preview.png)](media/upgrade-fails-because-of-nsg-rules/connectivity-analysis-preview.png#lightbox)

The result shows whether traffic is blocked, which resource and rule block it, and a diagram of the Azure network resources in the path.

For more information, see [Check if Azure network resources are blocking traffic to the endpoint](../connectivity/basic-troubleshooting-outbound-connections#check-if-azure-network-resources-are-blocking-traffic-to-the-endpoint).

Note

Connectivity analysis can't inspect resources outside Azure networking, such as non-Microsoft firewalls, NVA configurations, proxy servers, or custom DNS servers. If the analysis finds no blocker, check those components manually.

### Option 2: Manual checks

[Connect to a node in the affected cluster](/en-us/azure/aks/node-access), and then run the test that matches your exit code.

Tip

If outbound traffic to MCR is blocked, `kubectl debug` might not be able to pull the debug image. In that case, run the commands through [`az vmss run-command invoke`](/en-us/cli/azure/vmss/run-command#az-vmss-run-command-invoke) instead.

To get the API server FQDN, run the following command. For a private cluster, query `privateFqdn` instead of `fqdn`.

```azurecli
az aks show --resource-group <resource-group> --name <cluster-name> --query fqdn --output tsv
```

#### Exit code 50: OutboundConnFailVMExtensionError

Test connectivity to a [required FQDN](/en-us/azure/aks/outbound-rules-control-egress#required-outbound-network-rules-and-fqdns-for-aks-clusters). Run the following command.

```bash
curl -v --insecure --proxy-insecure https://<required-fqdn>
```

The following is an example of testing connectivity to MCR.

```bash
curl -v --insecure --proxy-insecure https://mcr.microsoft.com/v2/
```

#### Exit code 51: K8SAPIServerConnFailVMExtensionError

Test connectivity to the API server on TCP port 443. Run the following command.

```bash
curl -v --insecure --proxy-insecure https://<API-server-FQDN>:443
```

The following is an example of testing connectivity to the API server.

```bash
curl -v --insecure --proxy-insecure https://mycluster-dns-a1b2c3d4.hcp.eastus.azmk8s.io:443
```

#### Exit code 52: K8SAPIServerDNSLookupFailVMExtensionError

Test DNS resolution of the API server FQDN. Run the following command.

```bash
nslookup <API-server-FQDN>
```

The following is an example of testing DNS resolution of the API server FQDN.

```bash
nslookup mycluster-dns-a1b2c3d4.hcp.eastus.azmk8s.io
```

#### Interpret the results

If the connection or DNS lookup fails, first make sure that the other components in the traffic path are configured correctly, such as the firewall, NVA, proxy, UDRs, and DNS server. If they are, an NSG rule might be one of the following:

- **Blocking the IP address of a required endpoint.** Run `nslookup <fqdn>` from a node in the affected cluster to find the IP address that the FQDN resolves to. Run the command from the same cluster because an FQDN can resolve to different IP addresses in different regions and networks. Check whether an NSG rule denies that IP address or its port.
- **Blocking traffic to the DNS server.** Find the DNS servers configured on the cluster virtual network (**Virtual network** &gt; **Settings** &gt; **DNS servers**), and check whether an NSG rule denies UDP/TCP port 53 to those IP addresses. Azure-provided DNS (`168.63.129.16`) isn't subject to NSG rules by default, so this case usually involves a custom DNS server.

## Solution

### Step 1: Identify the NSGs that apply to the nodes

1. Get the node resource group, and list the AKS-managed NSG. Run the following command.

    ```azurecli
    NODE_RG=$(az aks show --resource-group <resource-group> --name <cluster-name> --query nodeResourceGroup --output tsv)
    az network nsg list --resource-group $NODE_RG --output table
    ```
2. If the cluster uses your own virtual network, get the NSG that's associated with the node pool subnet. Run the following command.

    ```azurecli
    SUBNET_ID=$(az aks nodepool show --resource-group <resource-group> --cluster-name <cluster-name> --name <nodepool-name> --query vnetSubnetId --output tsv)
    az network vnet subnet show --ids $SUBNET_ID --query networkSecurityGroup.id --output tsv
    ```

    If the command returns an empty value and the node pool doesn't use a custom subnet, the subnet has no NSG.

### Step 2: Review the NSG rules

1. List the rules of each NSG, including the default rules. Run the following command.

    ```azurecli
    az network nsg rule list --resource-group <nsg-resource-group> --nsg-name <nsg-name> --include-default --output table
    ```
2. Review the **outbound** rules. Rules with lower priority numbers are evaluated first. Look for `Deny` rules that match any of the following items:

    - The `Internet` service tag, or `*` destinations, on TCP port 443.
    - The IP addresses that the required FQDNs resolve to, as found in Interpret the results.
    - The API server IP address on TCP port 443. For a private cluster, this is the IP address of the private endpoint.
    - The DNS server IP addresses on UDP/TCP port 53.
    - Other [required outbound network rules](/en-us/azure/aks/outbound-rules-control-egress#azure-global-required-network-rules), such as UDP port 123 (NTP).
3. To see the combined result of the subnet-level and NIC-level NSGs for a node, check the effective security rules. In the Azure portal, go to the node pool's virtual machine scale set in the node resource group, and then select **Instances** &gt; *instance* &gt; **Networking** &gt; **Network settings** &gt; **Effective security rules**. You can also use [Network Watcher IP flow verify](/en-us/azure/network-watcher/ip-flow-verify-overview) to test a specific destination IP address and port.

### Step 3: Fix the blocking rules

- Remove or change the rules that block required traffic, or add a higher-priority `Allow` rule for the required destinations and ports. Where possible, use [service tags](/en-us/azure/virtual-network/service-tags-overview) (for example, `AzureCloud.<region>`) instead of individual IP addresses, because the IP addresses behind AKS FQDNs can change.
- Don't change or delete the rules that AKS creates in the AKS-managed NSG. Add custom rules to the NSG on your own subnet instead.
- If you need FQDN-based egress filtering, use [Azure Firewall](/en-us/azure/aks/limit-egress-traffic) or another FQDN-aware appliance instead of NSG rules.

Note

An NSG is only one possible cause. If the NSG rules are correct and connectivity still fails, check the firewall, NVA, proxy, UDRs, and DNS configuration. For more guidance, see [Troubleshoot AKS outbound connections](../connectivity/basic-troubleshooting-outbound-connections).

### Step 4: Retry the operation by reconciling the cluster

After you fix the blocking rules, run the connectivity tests from Option 2: Manual checks again to confirm that connectivity works. Then reconcile the cluster or node pool to retry the failed operation.

To reconcile the AKS cluster, run the following command.

```azurecli
az aks update --resource-group <resource-group> --name <cluster-name>
```

To reconcile an AKS node pool, run the following command.

```azurecli
az aks nodepool update --resource-group <resource-group> --cluster-name <cluster-name> --name <nodepool-name>
```

Check that the cluster and its node pools are in the `Succeeded` provisioning state and on the expected Kubernetes version. Run the following command.

```azurecli
az aks show --resource-group <resource-group> --name <cluster-name> --query "{state:provisioningState, version:currentKubernetesVersion}" --output table
az aks nodepool list --resource-group <resource-group> --cluster-name <cluster-name> --query "[].{name:name, state:provisioningState, version:currentOrchestratorVersion}" --output table
```

If the cluster isn't on the target version after the reconciliation succeeds, run the upgrade again. Run the following command.

```azurecli
az aks upgrade --resource-group <resource-group> --name <cluster-name> --kubernetes-version <kubernetes-version>
```

## References

- [Outbound network and FQDN rules for AKS clusters](/en-us/azure/aks/outbound-rules-control-egress)
- [Limit egress traffic by using Azure Firewall in AKS](/en-us/azure/aks/limit-egress-traffic)
- [Network isolated AKS clusters](/en-us/azure/aks/concepts-network-isolated)
- [Troubleshoot AKS outbound connections](../connectivity/basic-troubleshooting-outbound-connections)
- [Network security groups overview](/en-us/azure/virtual-network/network-security-groups-overview)
- [Azure Virtual Network Verifier](/en-us/azure/virtual-network-manager/concept-virtual-network-verifier)