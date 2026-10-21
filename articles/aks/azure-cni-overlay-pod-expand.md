---
layout: Conceptual
title: Expand Pod CIDR Space in Azure CNI Overlay Azure Kubernetes Service (AKS) Clusters - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay-pod-expand
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
description: Learn how to expand pod CIDR space in Azure CNI Overlay AKS clusters with Linux nodes and validate the new pod CIDR block.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2024-08-16T00:00:00.0000000Z
locale: en-us
document_id: 9ec323bc-caa3-fc20-3b3d-83bb9d3988e3
document_version_independent_id: a3045fee-32e8-cc23-7050-548e0b66f5a0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-cni-overlay-pod-expand.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,bash
toc_rel: toc.json
asset_id: aks/azure-cni-overlay-pod-expand
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-cni-overlay-pod-expand.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 59ca0ac4-9ef2-cbee-fe9c-706d38143536
---

# Expand Pod CIDR Space in Azure CNI Overlay Azure Kubernetes Service (AKS) Clusters - Azure Kubernetes Service | Microsoft Learn

You can expand your pod Classless Inter-Domain Routing (CIDR) space on Azure CNI Overlay clusters in Azure Kubernetes Service with Linux nodes only. The operation uses the [`az aks update`](/en-us/cli/azure/aks#az_aks_update) command and allows expansions without the need to re-create your AKS cluster.

## Requirements and parameters

| Requirement or parameter | Supported versions or values | Description |
| --- | --- | --- |
| Azure CLI version | 2.48.0 or later | The Azure CLI version must be 2.48.0 or later to support the pod CIDR expansion feature. |
| Node operating system | Linux | Pod CIDR expansion is supported only on Azure CNI Overlay AKS clusters with Linux nodes. |
| Networking mode | Azure CNI Overlay | Pod CIDR expansion is supported only on AKS clusters that use Azure CNI Overlay networking. |
| Example original pod CIDR | `10.244.0.0/18` | This is an example of a starting pod CIDR block. |
| Example expanded pod CIDR | `10.244.0.0/16` | This is an example of a target expanded pod CIDR block. |

## Limitations

- Windows nodes and hybrid node scenarios aren't supported.
- Shrinking or changing the pod CIDR isn't supported.
- Adding a discontinuous pod CIDR isn't supported. The new pod CIDR must be a larger superset that contains the complete original range.
- IPv6 pod CIDR expansion isn't supported.
- Changing multiple pod CIDR blocks via `--pod-cidrs` isn't supported.
- If an [Azure availability zone](availability-zones) is down during the expansion operation, new nodes might appear as `unready`. You can expect these nodes to reconcile after the availability zone is up.

## Prerequisites

- You need an Azure subscription. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Ensure that you meet the requirements listed in the Requirements and parameters section.

## Update an Azure CNI Overlay AKS cluster to expand the pod CIDR space

1. Starting from a pod CIDR block of `10.244.0.0/18`, you can expand the pod CIDR space by using the [`az aks update`](/en-us/cli/azure/aks#az_aks_update) command. For example:

    ```azurecli
    az aks update \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --pod-cidr 10.244.0.0/16
    ```

    Note

    Although the update operation might successfully finish and show the new pod CIDR in the network profile, be sure to validate the new cluster state through `NodeNetworkConfig` (`nnc`).
2. Verify the state of the upgrade operation by checking `NodeNetworkConfig` (`nnc`) via the `kubectl get nnc` command. In the output, all node pools should match your new pod CIDR block (for example, `10.244.0.0/16`).

    ```bash
    kubectl get nnc -A -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.networkContainers[0].subnetAddressSpace}{"\n"}{end}'
    ```