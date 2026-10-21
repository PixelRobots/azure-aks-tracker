---
layout: Conceptual
title: Delete an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/delete-cluster
breadcrumb_path: /azure/breadcrumb/azure-aks/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/200/azure-kubernetes-service/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn about deleting a cluster in Azure Kubernetes Service (AKS).
ms.topic: overview
ms.author: schaffererin
author: schaffererin
ms.date: 2024-04-16T00:00:00.0000000Z
ms.custom: 
locale: en-us
document_id: 87d5120e-186a-d2ab-0a1e-34863d54734c
document_version_independent_id: 64d2b763-6bf4-0911-53cc-518d47de17c2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/delete-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/delete-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/delete-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c528f80a-360d-9129-a733-99ad8e8b3eb9
---

# Delete an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

This article outlines cluster deletion in Azure Kubernetes Service (AKS), including what happens when you delete a cluster, alternatives to deleting a cluster, and how to delete a cluster.

## What happens when you delete a cluster?

When you delete a cluster, the following resources are deleted:

- The [node resource group](concepts-clusters-workloads#node-resource-group)and its resources, including:
    - The virtual machine scale sets and virtual machines (VMs) for each node in the cluster
    - The virtual network and its subnets for the cluster
    - The storage for the cluster
- The control plane and its resources
- Any node instances in the cluster along with any pods running on those nodes

## Alternatives to deleting a cluster

Before you delete a cluster, consider **stopping the cluster**. Stopping an AKS cluster stops the control plane and agent nodes, allowing you to save on compute costs while maintaining all objects except standalone pods. When you stop a cluster, its state is saved and you can restart the cluster at any time. For more information, see [Stop an AKS cluster](start-stop-cluster).

If you want to delete a cluster to change its configuration, you can instead use the [AKS cluster upgrade](upgrade-cluster) feature to upgrade the cluster to a different Kubernetes version or change the node pool configuration. For more information, see [Upgrade an AKS cluster](upgrade-cluster).

## Delete a cluster

Important

**You can't recover a cluster after it's deleted**. If you need to recover a cluster, you need to create a new cluster and redeploy your applications.

# [Azure CLI](#tab/azure-cli)
Delete a cluster using the [`az aks delete`](/en-us/cli/azure/aks#az-aks-delete) command. The following example deletes the `myAKSCluster` cluster in the `myResourceGroup` resource group.

Declare environment variables with generic names and a random suffix to ensure uniqueness. This avoids conflicts and enables the commands to be re-used in different sessions or by different users.

```azurecli
export RANDOM_SUFFIX=$(openssl rand -hex 3)
export AKS_CLUSTER_NAME="myAKSCluster$RANDOM_SUFFIX"
export RESOURCE_GROUP_NAME="myResourceGroup$RANDOM_SUFFIX"
az aks delete --name $AKS_CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME --yes --no-wait
```

# [Azure PowerShell](#tab/azure-powershell)
Delete a cluster using the [`Remove-AzAks`](/en-us/powershell/module/az.aks/remove-azakscluster) command. The following example deletes the `myAKSCluster` cluster in the `myResourceGroup` resource group:

```azurepowershell
Remove-AzAksCluster -Name myAKSCluster -ResourceGroupName myResourceGroup
```

# [Azure portal](#tab/azure-portal)
You can delete a cluster using the Azure portal. To delete a cluster, navigate to the **Overview** page for the cluster and select **Delete**. You can also delete a cluster from the **Resource group** page by selecting the cluster and then selecting **Delete**.

---