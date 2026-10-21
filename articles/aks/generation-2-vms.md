---
layout: Conceptual
title: Use Generation 2 (Gen 2) Virtual Machines (VMs) on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/generation-2-vms
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
description: Learn how to check available Gen 2 VM sizes, create AKS node pools with Gen 2 VMs, migrate from Gen 1 to Gen 2 VMs on AKS, and verify VM generation.
ms.topic: how-to
ms.subservice: aks-nodes
ms.date: 2025-08-05T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: e184d868-a93b-f990-5e8e-02268d78e502
document_version_independent_id: 9527a071-534e-799f-d70a-9b8976a79cbc
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/generation-2-vms.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/generation-2-vms
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/generation-2-vms.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: d445ea21-37f5-837b-7fe3-6f299f727c88
---

# Use Generation 2 (Gen 2) Virtual Machines (VMs) on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to use Generation 2 (Gen 2) virtual machines (VMs) on Azure Kubernetes Service (AKS), including how to check available Gen 2 VM sizes, create AKS node pools with Gen 2 VMs, migrate from Gen 1 to Gen 2 VMs on AKS, and verify the VM generation of your AKS nodes.

## Before you begin

- Review the [Virtual machine (VM) sizes, generations, and features for Azure Kubernetes Service (AKS)](aks-virtual-machine-sizes) article to understand VM generations and features supported on AKS.

## Check available Gen 2 VM sizes

Check available Gen 2 VM sizes using the [`az vm list-skus`](/en-us/cli/azure/vm#az-vm-list-skus) command.

```azurecli
# Set environment variables
export LOCATION=<your-region>
export VM_SIZE=<vm-size-to-check>

# Check if the VM size is available in the specified location
az vm list-skus --location $LOCATION --size $VM_SIZE --output table
```

For a breakdown of what VM sizes support Gen 2, see [Support for Gen 2 VMs on Azure](/en-us/azure/virtual-machines/generation-2).

## Create a node pool with a Gen 2 VM

# [Linux node pool](#tab/linux-node-pool)
By default, Linux uses the Gen 2 node image unless the VM size doesn't support Gen 2.

Create a Linux node pool with a Gen 2 VM using the default [node pool creation](create-node-pools) process.

# [Windows node pool](#tab/windows-node-pool)
By default, Windows Server 2022 uses the Gen 1 node image. If you want to use a Gen 2 node image, create a Windows node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--aks-custom-headers UseWindowsGen2VM=true` custom header `--aks-custom-headers UseWindowsGen2VM=true`:

```azurecli
# Set environment variables
export RESOURCE_GROUP=<resource-group-name>
export CLUSTER_NAME=<cluster-name>
export NODE_POOL_NAME=<node-pool-name>
export VM_SIZE=<supported-generation-2-vm-size>

# Create a Windows node pool with a Gen 2 VM
az aks nodepool add --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name $NODE_POOL_NAME --node-vm-size $VM_SIZE --os-type Windows --os-sku Windows2022 --aks-custom-headers UseWindowsGen2VM=true
```

Windows Server 2025+ uses the Gen 2 node image by default, so you don't need to specify the custom header.

---

## Migrate an existing node pool to Gen 2

# [Linux node pool](#tab/linux-node-pool)
If you're using a VM size that only supports Gen 1, you can update your node pool to a VM size that supports Gen 2 using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command. This update changes your node image from Gen 1 to Gen 2.

```azurecli
# Set environment variables
export RESOURCE_GROUP=<resource-group-name>
export CLUSTER_NAME=<cluster-name>
export NODE_POOL_NAME=<node-pool-name>
export VM_SIZE=<supported-generation-2-vm-size>

# Update a Linux node pool to use a Gen 2 VM
az aks nodepool update --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name $NODE_POOL_NAME --node-vm-size $VM_SIZE --os-type Linux
```

# [Windows node pool](#tab/windows-node-pool)
If you're Windows Server 2022 with the Gen 1 image, you can update your node pool to use Gen 2 by selecting a VM size that supports Gen 2 using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with the `--aks-custom-headers UseWindowsGen2VM=true` custom header:

```azurecli
# Set environment variables
export RESOURCE_GROUP=<resource-group-name>
export CLUSTER_NAME=<cluster-name>
export NODE_POOL_NAME=<node-pool-name>
export VM_SIZE=<supported-generation-2-vm-size>

# Update a Windows node pool to use a Gen 2 VM
az aks nodepool update --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name $NODE_POOL_NAME --node-vm-size $VM_SIZE --os-type Windows --os-sku Windows2022 --aks-custom-headers UseWindowsGen2VM=true
```

---

## Check if you're using a Gen 2 node image

Verify a successful node pool creation using the [`az aks nodepool show`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-show) command and check that the `nodeImageVersion` contains `gen2` in the output.

```azurecli
# Set environment variables
export RESOURCE_GROUP=<resource-group-name>
export CLUSTER_NAME=<cluster-name>
export NODE_POOL_NAME=<node-pool-name>

# Show node pool details
az aks nodepool show --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name $NODE_POOL_NAME --output table
```