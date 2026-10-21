---
layout: Conceptual
title: Create Windows Server Node Pools with containerd in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/windows-containerd
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
description: Learn how to create Windows Server node pools with containerd in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2025-09-26T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-nodes
locale: en-us
document_id: 6353f7b7-e14c-c23a-84d9-ba252c114d2b
document_version_independent_id: 55e57031-e5f0-4ae0-e798-5f292261a51f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/windows-containerd.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/windows-containerd
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/windows-containerd.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: 7f4fb9e7-2bb2-b729-a31f-891317236ef0
---

# Create Windows Server Node Pools with containerd in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

For Kubernetes version 1.20 and higher, you can specify [`containerd`](https://containerd.io/) as the container runtime for Windows Server 2019 node pools. Starting with Kubernetes 1.23, `containerd` is the default and only container runtime for Windows.

In this article, you learn how to create Windows Server node pools with `containerd` in Azure Kubernetes Service (AKS).

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli) installed and configured. Find the version using the `az version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- An existing AKS cluster with a system node pool. If you need to create one, see [Create an AKS cluster with a single node pool](create-node-pools#create-an-aks-cluster-with-a-single-node-pool-using-the-azure-cli).

## Limitations and considerations

When using Windows Server node pools with `containerd`, keep the following limitations and considerations in mind:

- Both the control plane and Windows Server 2019 node pools must use Kubernetes version 1.20 or greater.
- When you create or update a node pool to run Windows Server containers, the default value for `--node-vm-size` is `Standard_D2s_v3`, which was the minimum recommended size for Windows Server 2019 node pools up to Kubernetes version 1.20. The minimum recommended size for Windows Server 2019 node pools using `containerd` is `Standard_D4s_v3`. When setting the `--node-vm-size` parameter, check the [list of restricted virtual machine (VM) sizes](/en-us/azure/virtual-machines/sizes/overview).
- We recommend using [taints or labels](manage-node-pools#set-node-pool-taints) with your Windows Server 2019 node pools running `containerd` and tolerations or node selectors with your deployments to guarantee your workloads are scheduled correctly.

## Add a Windows Server node pool with `containerd`

- Add a Windows Server node pool with `containerd` into your existing cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add).

    Note

    If you don't specify the `WindowsContainerRuntime=containerd` custom header, the node pool still uses `containerd` as the container runtime by default.

    ```azurecli
    az aks nodepool add \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --os-type Windows \
        --name $CONTAINER_D_NODE_POOL_NAME \
        --node-vm-size Standard_D4s_v3 \
        --kubernetes-version 1.20.5 \
        --aks-custom-headers WindowsContainerRuntime=containerd \
        --node-count 1
    ```

## Upgrade an existing Windows Server node pool to `containerd`

- Upgrade a specific node pool from Docker to `containerd` using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command.

    ```azurecli
    export CONTAINER_D_NODE_POOL_NAME="mywindowsnodepool"
    
    az aks nodepool upgrade \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --name $CONTAINER_D_NODE_POOL_NAME \
        --kubernetes-version 1.20.7 \
        --aks-custom-headers WindowsContainerRuntime=containerd
    ```

## Upgrade all existing Windows Server node pools to `containerd`

- Upgrade all node pools from Docker to `containerd` using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command.

    ```azurecli
    az aks nodepool upgrade \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --kubernetes-version 1.20.7 \
        --aks-custom-headers WindowsContainerRuntime=containerd
    ```