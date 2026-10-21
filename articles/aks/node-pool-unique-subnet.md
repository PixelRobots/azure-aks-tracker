---
layout: Conceptual
title: Create Node Pools with Unique Subnets in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-pool-unique-subnet
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
description: Learn how to create node pools with unique subnets in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2025-09-26T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-nodes
locale: en-us
document_id: 2211de24-ee18-a982-5b47-5cefcaa75d57
document_version_independent_id: bb323b3c-196a-a444-be8c-82a8befa0ffa
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-pool-unique-subnet.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/node-pool-unique-subnet
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-pool-unique-subnet.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: b3f766f5-3013-9f7f-a7ee-3628e916dbb6
---

# Create Node Pools with Unique Subnets in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Certain workloads might require splitting cluster nodes into separate pools for logical isolation. Separate subnets dedicated to each node pool in the cluster can help support this isolation, which can address requirements such as having noncontiguous virtual network address space to split across node pools.

In this article, you learn how to create node pools with unique subnets in Azure Kubernetes Service (AKS).

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli) version 2.35.0 or later. Run `az version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- An existing AKS cluster with a system node pool. If you need to create one, see [Create an AKS cluster with a single node pool](create-node-pools#create-an-aks-cluster-with-a-single-node-pool-using-the-azure-cli).

## Limitations

- All subnets assigned to node pools must belong to the same virtual network (VNet).
- System pods must have access to all nodes and pods in the cluster to provide critical functionality, such as DNS resolution and tunneling kubectl logs/exec/port-forward proxy.
- If you expand your VNet after creating the cluster, you must update your cluster before adding a subnet outside the original CIDR block. While AKS errors out on the agent pool add, the `aks-preview` Azure CLI extension (version 0.5.66 and higher) now supports running `az aks update` command with only the required `--resource-group $RESOURCE_GROUP --name $CLUSTER_NAME` arguments. This command performs an update operation without making any changes, which can recover a cluster stuck in a failed state.
- In clusters with Kubernetes version less than 1.23.3, kube-proxy SNATs traffic from new subnets, which can cause Azure Network Policy to drop the packets.
- Windows nodes SNAT traffic to the new subnets until the node pool is reimaged.
- Internal load balancers default to one of the node pool subnets.

## Add a node pool with a unique subnet

- Add a node pool with a unique subnet into your existing AKS cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks#az-aks-nodepool-add) command and the `--vnet-subnet-id` parameter specified.

    ```azurecli
    az aks nodepool add \
        --resource-group $RESOURCE_GROUP_NAME \
        --cluster-name $CLUSTER_NAME \
        --name $NODE_POOL_NAME \
        --node-count 3 \
        --vnet-subnet-id $SUBNET_RESOURCE_ID
    ```