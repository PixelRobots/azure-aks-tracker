---
layout: Conceptual
title: Cluster autoscaler fails to scale with cannot scale cluster autoscaler enabled node pool error - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/cannot-scale-cluster-autoscaler-enabled-node-pool
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
description: Learn how to troubleshoot the cannot scale cluster autoscaler enabled node pool error when your autoscaler isn't scaling up or down.
ms.date: 2026-07-08T00:00:00.0000000Z
ms.reviewer: aritraghosh, chiragpa
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool), innovation-engine
locale: en-us
document_id: ac270989-3249-eb40-9f07-b7a963bee8c7
document_version_independent_id: ac270989-3249-eb40-9f07-b7a963bee8c7
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/cannot-scale-cluster-autoscaler-enabled-node-pool.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/cannot-scale-cluster-autoscaler-enabled-node-pool
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/cannot-scale-cluster-autoscaler-enabled-node-pool.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/96f6b0a2-2fd7-4de1-936d-89ad6e0eb7cc
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/ef8b0a5a-ba0a-4ec0-8636-48246ccd954f
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 4b7b02c7-3f6c-5468-60c9-9d6a6eb3bd9e
---

# Cluster autoscaler fails to scale with cannot scale cluster autoscaler enabled node pool error - Azure | Microsoft Learn

## Summary

This article provides solutions for the "cannot scale cluster autoscaler enabled node pool" error encountered when scaling an Azure Kubernetes Service (AKS) cluster with an autoscaler-enabled node pool. Resolving this error allows users to successfully scale their AKS clusters, ensuring efficient resource management and operational continuity.

## Symptoms

You see an error message that looks like the following message:

> 
> `kubectl get nodes` outputs "No resources found" All pods state is `Pending` Scale operations fail with "Cannot scale cluster autoscaler enabled node pool" error

## Troubleshooting checklist

Azure Kubernetes Service (AKS) uses virtual machine scale sets-based agent pools, which contain cluster nodes and [cluster autoscaling capabilities](/en-us/azure/aks/cluster-autoscaler) if enabled.

### Check that the cluster virtual machine scale set exists

1. Sign in to [Azure portal](https://portal.azure.com).
2. Find the node resource group by searching the following names:

    - The default name `MC_{AksResourceGroupName}_{YourAksClusterName}_{AksResourceLocation}`.
    - The custom name (if you provided one at creation).

    Note

    When you create a new cluster, AKS automatically creates a second resource group to store the AKS resources. For more information, see [Why are two resource groups created with AKS?](/en-us/azure/aks/faq#why-are-two-resource-groups-created-with-aks)
3. Check the list of resources and make sure that there's a virtual machine scale set.

## Cause 1: The cluster virtual machine scale set was deleted

Deleting the virtual machine scale set attached to the cluster causes the cluster autoscaler to fail. It also causes problems when provisioning resources such as nodes and pods.

Note

Modifying any resource under the node resource group in the AKS cluster is an unsupported action and causes cluster operation failures. To prevent changes to the node resource group, [block users from modifying resources](/en-us/azure/aks/cluster-configuration#fully-managed-resource-group-preview) managed by the AKS cluster.

### Reconcile node pool

If you accidentally delete the cluster virtual machine scale set, reconcile the node pool by using `az aks nodepool update`:

```shell
# Update Node Pool Configuration
az aks nodepool update --resource-group <resource-group-name> --cluster-name <cluster-name> --name <nodepool-name> --tags <tags> --node-taints <taints> --labels <labels>

# Verify the Update
az aks nodepool show --resource-group <resource-group-name> --cluster-name <cluster-name> --name <nodepool-name>
```

Monitor the node pool to make sure that it's functioning as expected and that all nodes are operational.

## Cause 2: Tags or other properties were modified in the node resource group

You receive scaling errors if you modify or delete Azure-created tags and other resource properties in the node resource group. For more information, see [Can I modify tags and other properties of the AKS resources in the node resource group?](/en-us/azure/aks/faq#can-i-modify-tags-and-other-properties-of-the-aks-resources-in-the-node-resource-group)

### Reconcile node resource group tags

Use the Azure CLI to make sure that the node resource group has the correct tags for AKS name and the AKS group name:

```shell
# Add or update tags for AKS name and AKS group name
az group update --name <node-resource-group-name> --set tags.AKS-Managed-Cluster-Name=<aks-managed-cluster-name> tags.AKS-Managed-Cluster-RG=<aks-managed-cluster-rg>

# Verify the tags
az group show --name <node-resource-group-name> --query "tags"
```

Monitor the resource group to make sure that the tags are correctly applied and that the resource group is functioning as expected.

## Cause 3: The cluster node resource group was deleted

Deleting the cluster node resource group causes problems when provisioning the infrastructure resources required by the cluster. This problem causes the cluster autoscaler to fail.

### Solution: Update the cluster to the goal state without changing the configuration

To resolve this problem, run the following command to recover the deleted virtual machine scale set or any tags (missing or modified):

Note

It might take a few minutes until the operation completes.

Set your environment variables for the AKS cluster resource group and cluster name before running the command. A random suffix is included to prevent name collisions during repeatable executions, but you must ensure the resource group and cluster exist.

```azurecli
export RANDOM_SUFFIX=$(head -c 3 /dev/urandom | xxd -p)
export AKS_RG_NAME="MyAksResourceGroup$RANDOM_SUFFIX"
export AKS_CLUSTER_NAME="MyAksCluster$RANDOM_SUFFIX"
az aks update --resource-group $AKS_RG_NAME --name $AKS_CLUSTER_NAME --no-wait
```

## Cause 4: Unsupported virtual machine scale set (VMSS) configuration

The VMSS autoscaling configuration was changed from **Manual scale** to **Custom autoscale**. AKS inherently manages the VMSS instance count so the setting should remain on **Manual scale**. Multiple autoscalers operating on the same node pool can lead to failures and unexpected behavior. The VMSS autoscaler is **not supported** for use with AKS cluster node pools.

### Resolution

1. In the Azure portal, find the affected VMSS under the node resource group of the AKS cluster.
2. Select **Scaling** from the left navigation pane.
3. Set **Scaling** to **Manual scale**.
4. Select **Save**.
5. Try the scaling operations again by using AKS (autoscaling, upgrade, and so on).