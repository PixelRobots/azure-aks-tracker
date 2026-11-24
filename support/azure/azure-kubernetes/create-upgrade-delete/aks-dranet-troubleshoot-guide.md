---
layout: Conceptual
title: Troubleshoot managed support for DRANET in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/aks-dranet-troubleshoot-guide
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
description: Troubleshoot managed support for DRANET in AKS. Diagnose enablement failures, missing labels, unhealthy pods, and RDMA claim issues, then follow the steps to fix them.
ms.reviewer: sachidesai
ms.date: 2026-11-20T00:00:00.0000000Z
ms.service: azure-kubernetes-service
ai-usage: ai-assisted
locale: en-us
document_id: 93829a9a-6dfa-4213-5d3a-04b5a2ae9010
document_version_independent_id: 93829a9a-6dfa-4213-5d3a-04b5a2ae9010
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/aks-dranet-troubleshoot-guide.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/aks-dranet-troubleshoot-guide
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/aks-dranet-troubleshoot-guide.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 87d58f14-9173-da1f-9923-56b96ac47831
---

# Troubleshoot managed support for DRANET in AKS - Azure | Microsoft Learn

## Summary

This article provides guidance on diagnosing and resolving common issues with managed support for DRANET in Azure Kubernetes Service (AKS).

[Managed support for DRANET](/en-us/azure/aks/managed-support-for-dranet) lets AKS manage the networking drivers that make Remote Direct Memory Access (RDMA) network interface cards (NICs) available to workloads. Kubernetes Dynamic Resource Allocation (DRA) assigns these devices through resource claims. High performance computing (HPC), GPU, and non-GPU workloads can use this feature.

Use this article to troubleshoot common configuration and workload issues.

## Prerequisites

Ensure the following environment variables are set.

```bash
RESOURCE_GROUP="<resource-group>"
CLUSTER_NAME="<aks-cluster-name>"
POOL_NAME="<rdma-node-pool-name>"
```

## Troubleshoot DRANET issues in AKS

The following steps help you diagnose and resolve common issues with managed support for DRANET in AKS.

### 1. Managed DRANET enablement fails

**Symptom** - A node pool create or update request with `--enable-managed-dranet` fails, or the pool can't provision RDMA-capable nodes.

**Check** - Read the full Azure CLI validation message, then inspect the AKS cluster and node pool. Run the following command.

```azurecli
az aks show --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" \
  --query "{version:kubernetesVersion,network:networkProfile}" --output json
az aks nodepool show --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" --name "$POOL_NAME" \
  --query "{state:provisioningState,version:orchestratorVersion,os:osSku,vmSize:vmSize,dranet:networkProfile.dranet}" \
  --output json
```

If creation failed before the node pool existed, check the submitted settings instead.

**Resolve**

Follow these steps to resolve the issue:

- Use AKS version `1.35` or later, Ubuntu, or Azure Linux nodes, and cluster with Azure CNI option.
- Choose a supported RDMA-capable Azure virtual machine (VM) size.
- For quota or allocation errors, check regional and VM-family vCPU quota and VM availability in the cluster's region. Request more quota or select another supported, available size as appropriate.

After correcting the prerequisite, retry the failed request. Successful enablement should report `networkProfile.dranet.mode` as `Managed`.

### 2. Nodes don't have the `network-dra` label

**Symptom** - Enablement succeeds, but nodes lack the `network-dra` label, including after scaling or a Kubernetes upgrade.

**Check** - Confirm the node pool's network profile DRANET mode and compare all nodes with labeled nodes with the following commands.

```azurecli
az aks nodepool show --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" --name "$POOL_NAME" \
  --query "networkProfile.dranet.mode" --output tsv
```

```bash
kubectl get nodes -l "agentpool=$POOL_NAME" -L network-dra
kubectl get nodes -l "agentpool=$POOL_NAME,network-dra"
```

**Resolve** - Verify that you're inspecting the correct AKS cluster and node pool. Wait a few minutes for labels after enablement. Newly added nodes must become `Ready`. Investigate a non-`Ready` node with `kubectl describe node "<node-name>"`.

If the mode isn't `Managed` and you intend to enable management of the networking drivers, update the existing pool. Run the following command.

```azurecli
az aks nodepool update --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" --name "$POOL_NAME" \
  --enable-managed-dranet
```

Recheck the mode and labels. Enabling management on an existing supported pool shouldn't require node recreation. If the mode is already `Managed` but `Ready` nodes remain unlabeled, continue with 3. DRANET pods are missing or unhealthy. Don't manually add the label. It doesn't install or repair the DRANET driver.

### 3. DRANET pods are missing or unhealthy

**Symptom** - The managed component is absent, `Pending`, or repeatedly restarting, or devices aren't prepared for a workload.

**Check** - Find the managed DaemonSet and pods, including their node assignments with the following command.

```bash
kubectl get daemonsets -n kube-system -l app.kubernetes.io/name=dranet
kubectl get pods -n kube-system -l app.kubernetes.io/name=dranet -o wide
kubectl describe pod "<dranet-pod-name>" -n kube-system
kubectl logs "<dranet-pod-name>" -n kube-system --all-containers=true --tail=100
```

**Resolve** - Use pod events to distinguish scheduling or image-pull failures from driver failures. Address reported node readiness, resource, or network-access problems. For a restarting container, also collect its previous logs using `kubectl logs` with `--container "<container-name>" --previous`.

Check whether a self-managed NVIDIA Network Operator or RDMA shared device plugin still targets the affected nodes. Coordinate its supported removal or retargeting before using managed DRANET on those nodes. Don't install a second driver, edit the managed DaemonSet, or delete cluster-wide custom resource definitions or webhooks as a repair step. Other node pools might depend on them.

After correction, confirm the relevant DRANET pod is healthy on each affected node. If the managed component remains absent or preparation errors persist, collect the following evidence for Azure Support.

### 4. A workload stays Pending or its RDMA claim isn't allocated

**Symptom** - A workload can't get RDMA devices, especially after migration from a traditional device plugin.

**Check** - Look at pod events, its generated claim, and the available DRA APIs and inventory with the following command.

```bash
kubectl describe pod "<workload-pod>" -n "<namespace>"
kubectl get resourceclaims -n "<namespace>"
kubectl describe resourceclaim "<claim-name>" -n "<namespace>"
kubectl api-resources --api-group=resource.k8s.io
kubectl get deviceclasses
kubectl get resourceslices
```

**Resolve**

Follow these steps to resolve the issue:

- Make sure the claim template exists in the workload's namespace. The pod's `spec.resourceClaims` must reference it, and the consuming container's `resources.claims` must reference the pod's claim name.
- Match the template's device class and selectors to the installed class and advertised devices. Use API versions served by your cluster. DRA uses `DeviceClass`; an older example that refers to `ResourceClass` isn't a reliable health check.
- Ensure the pod's node selector, affinity, and tolerations allow a `Ready`, DRANET-enabled node with enough matching devices. Reduce the requested device count only if validated application requirements permit it, or add supported capacity to the appropriate node pool.
- After migration, replace legacy RDMA extended-resource requests, such as `nvidia.com/rdma_shared_device_a`, with DRA claims. Keep any independently required GPU requests. Old RDMA resource counts under node `Allocatable` aren't proof of DRA availability. Inspect `ResourceSlices` and claim allocation instead.

If the claim is allocated but the container can't access devices, check the DRANET pod on the workload's assigned node by using issue 3. Look for resource-preparation or Container Device Interface (CDI) errors. Allocation alone doesn't prove successful device preparation or application-level RDMA communication.

### 5. Unexpected resources remain after disabling or re-enabling DRANET

**Symptom** - Labels or managed components remain after disabling, or DRANET doesn't recover after re-enabling.

**Check** - Look at the node pool mode, node labels, and DRANET pods by using 2. Nodes don't have the `network-dra` label and 3. DRANET pods are missing or unhealthy. Check other node pools before treating a remaining cluster component as orphaned. Run the following command.

```azurecli
az aks nodepool list --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --query "[].{pool:name,mode:networkProfile.dranet.mode}" --output table
```

**Resolve** - Before disabling, stop or migrate workloads that depend on the DRANET driver. Verify that `networkProfile.dranet.mode` no longer reports `Managed` and that the nodes' `network-dra` labels disappear. The cluster extension is removed only when the last managed DRANET node pool is disabled or removed.

To restore management, update the node pool with `--enable-managed-dranet`, allow labels and components to reconcile, and repeat the pod and claim checks before resuming workloads. Don't delete shared components or repeatedly toggle the feature to work around a persistent failure.