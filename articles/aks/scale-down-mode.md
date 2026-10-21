---
layout: Conceptual
title: Use Scale-down Mode for your Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/scale-down-mode
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
description: Learn how to use Scale-down Mode in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2023-08-21T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ms.subservice: aks-nodes
locale: en-us
document_id: 803f1295-bdc8-8350-ac89-6a29839cbb13
document_version_independent_id: 8619dbd0-8925-1c87-1f2d-98553361b776
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/scale-down-mode.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/scale-down-mode
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/scale-down-mode.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: f69d5b88-c027-fba8-0e67-4ea0a9fa6e90
---

# Use Scale-down Mode for your Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

By default, scale-up operations performed manually or by the cluster autoscaler require the allocation and provisioning of new nodes, and scale-down operations delete nodes. Scale-down Mode allows you to decide whether you would like to delete or deallocate the nodes in your Azure Kubernetes Service (AKS) cluster upon scaling down.

When an Azure VM is in the `Stopped` (deallocated) state, you will not be charged for the VM compute resources. However, you'll still need to pay for any OS and data storage disks attached to the VM. This also means that the container images will be preserved on those nodes. For more information, see [States and billing of Azure Virtual Machines](/en-us/azure/virtual-machines/states-billing). This behavior allows for faster operation speeds, as your deployment uses cached images. Scale-down Mode removes the need to pre-provision nodes and pre-pull container images, saving you compute cost.

## Before you begin

Warning

In order to preserve any deallocated VMs, you must set Scale-down Mode to Deallocate. That includes VMs that have been deallocated using IaaS APIs (Virtual Machine Scale Set APIs). Setting Scale-down Mode to Delete will remove any deallocate VMs. Once applied the deallocated mode and scale down operation occurred, those nodes keep registered in APIserver and appear as NotReady state.

This article assumes that you have an existing AKS cluster. If you don't have an AKS cluster, for guidance on a designing an enterprise-scale implementation of AKS, see [Plan your AKS design](/en-us/azure/architecture/reference-architectures/containers/aks-start-here?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json).

### Limitations

- [Ephemeral OS](concepts-storage#ephemeral-os-disks-in-aks) disks aren't supported. Be sure to specify managed OS disks by including the argument `--node-osdisk-type Managed` when creating a cluster or node pool.

Note

Previously, while Scale-down Mode was in preview, [spot node pools](spot-node-pool) were unsupported. Now that Scale-down Mode is Generally Available, this limitation no longer applies.

## Using Scale-down Mode to deallocate nodes on scale-down

By setting `--scale-down-mode Deallocate`, nodes will be deallocated during a scale-down of your cluster/node pool. All deallocated nodes are stopped. When your cluster/node pool needs to scale up, the deallocated nodes are started first before any new nodes are provisioned.

In this example, we create a new node pool with 20 nodes and specify that upon scale-down, nodes are to be deallocated using the argument `--scale-down-mode Deallocate`.

```azurecli
az aks nodepool add --node-count 20 --scale-down-mode Deallocate --node-osdisk-type Managed --max-pods 10 --name nodepool2 --cluster-name myAKSCluster --resource-group myResourceGroup
```

By scaling the node pool and changing the node count to 5, we'll deallocate 15 nodes.

```azurecli
az aks nodepool scale --node-count 5 --name nodepool2 --cluster-name myAKSCluster --resource-group myResourceGroup
```

To deallocate Windows nodes during scale-down, run the following command. The default behavior is consistent with Linux nodes, where nodes are deleted during scale-down.

```azurecli
az aks nodepool add --node-count 20 --scale-down-mode Deallocate --os-type Windows --node-osdisk-type Managed --max-pods 10 --name npwin2 --cluster-name myAKSCluster --resource-group myResourceGroup
```

### Deleting previously deallocated nodes

To delete your deallocated nodes, you can change your Scale-down Mode to `Delete` by setting `--scale-down-mode Delete`. The 15 deallocated nodes will now be deleted.

```azurecli
az aks nodepool update --scale-down-mode Delete --name nodepool2 --cluster-name myAKSCluster --resource-group myResourceGroup
```

Note

Changing your scale-down mode from `Deallocate` to `Delete` then back to `Deallocate` will delete all deallocated nodes while keeping your node pool in `Deallocate` scale-down mode.

## Using Scale-down Mode to delete nodes on scale-down

The default behavior of AKS without using Scale-down Mode is to delete your nodes when you scale-down your cluster. With Scale-down Mode, this behavior can be explicitly achieved by setting `--scale-down-mode Delete`.

In this example, we create a new node pool and specify that our nodes will be deleted upon scale-down using the argument `--scale-down-mode Delete`. Scaling operations will be handled using the cluster autoscaler.

```azurecli
az aks nodepool add --enable-cluster-autoscaler --min-count 1 --max-count 10 --max-pods 10 --node-osdisk-type Managed --scale-down-mode Delete --name nodepool3 --cluster-name myAKSCluster --resource-group myResourceGroup
```