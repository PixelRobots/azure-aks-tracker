---
layout: Conceptual
title: Use Arm64 Virtual Machines in Azure Kubernetes Service (AKS) for cost effectiveness - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-arm64-vms
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
description: Learn how to create node pools using Arm64 Virtual Machines with Azure Kubernetes Service (AKS) for cost effectiveness.
ms.topic: how-to
ms.date: 2025-02-25T00:00:00.0000000Z
author: allyford
ms.author: allyford
locale: en-us
document_id: 5f883d45-b5c6-2051-0af2-052aa13850a3
document_version_independent_id: 989b9ae6-590f-db61-c14b-e387808786b3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-arm64-vms.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-arm64-vms
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-arm64-vms.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
platformId: 1db1a961-b473-ad62-3ad1-9ea3491a78dd
---

# Use Arm64 Virtual Machines in Azure Kubernetes Service (AKS) for cost effectiveness - Azure Kubernetes Service | Microsoft Learn

[Arm-based processors (Arm64)](/en-us/azure/virtual-machines/sizes/cobalt-overview) are power-efficient and cost-effective, but don't compromise on performance. These Arm64 VMs are engineered to efficiently run dynamic, scalable workloads and can deliver up to 50% better price-performance than comparable x86-based VMs for scale-out workloads.

Because of their ability to scale workloads efficiently, Arm64 VMs are well-suited for web or application servers, open-source databases, cloud-native applications, gaming servers, and other high traffic applications.

Note

While a combination of CPU, memory, and networking capacity configurations heavily influences the cost effectiveness of a SKU, Arm64 VM types are recommended for cost optimization.

In this article, you'll learn how to add a Arm64 VM to an existing node pool.

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Prerequisites

Before you begin, make sure you have:

- An existing AKS cluster.
- The [Dpsv5](/en-us/azure/virtual-machines/dpsv5-dpdsv5-series), [Dplsv5](/en-us/azure/virtual-machines/dplsv5-dpldsv5-series), or [Epsv5](/en-us/azure/virtual-machines/epsv5-epdsv5-series) series SKUs available for your subscription.

## Limitations

- Arm64 VMs aren't supported for Windows node pools.
- Existing node pools can't be updated to use an Arm64 VM.
- Federal Information Processing Standards (FIPS)-enabled node pools are only supported with Arm64 SKUs when using Azure Linux 3.0+.
- Arm64 node pools aren't supported on Defender-enabled clusters with Kubernetes version 1.29.0 or lower.

## Create node pools with Arm64 VMs

The Arm64 processor provides low power compute for your Kubernetes workloads. Arm64 virtual machines can be added to existing clusters even mixing Intel and Arm architecture node pools within a cluster. To create an Arm64 node pool, you need to choose a [Dpsv5](/en-us/azure/virtual-machines/dpsv5-dpdsv5-series), [Dplsv5](/en-us/azure/virtual-machines/dplsv5-dpldsv5-series), or [Epsv5](/en-us/azure/virtual-machines/epsv5-epdsv5-series) series virtual machine.

### Add a node pool with an Arm64 VM

Use [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) to add a node pool with an Arm64 VM to an existing cluster. Alternatively, if you're using [Azure Linux 3.0+](/en-us/azure/azure-linux/how-to-enable-azure-linux-3), you can add a node pool with an Arm64 VM and [FIPS](enable-fips-nodes) enabled.

- Add a node pool with an Arm64 VM

    ```azurecli
        az aks nodepool add \
            --resource-group $RESOURCE_GROUP_NAME \
            --cluster-name $CLUSTER_NAME \
            --name $ARM_NODE_POOL_NAME \
            --node-count 3 \
            --node-vm-size Standard_D2pds_v5
    ```
- Add a FIPS-enabled node pool with an Arm64 VM

    Limitations:

    - Node pools with Arm64 VMs and [FIPS](enable-fips-nodes) enabled aren't supported with Ubuntu OS.
    - Node pools with Arm64 VMs and [FIPS](enable-fips-nodes) require kubernetes version 1.31+.

    Use the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) with `--enable-fips-image` and `--os-sku` parameters.

    ```azurecli
        az aks nodepool add \
           --resource-group $RESOURCE_GROUP_NAME \
           --cluster-name $CLUSTER_NAME \
           --name $ARM_NODE_POOL_NAME \
           --os-sku AzureLinux
           --enable-fips-image
           --kubernetes-version 1.31
           --node-count 3 \
           --node-vm-size Standard_D2pds_v5
    ```

    For more information on verifying FIPS enablement and disabling FIPS, see [Enable FIPS node pools](enable-fips-nodes).
- Update a node pool with an Arm64 VM to enable FIPS

    Limitations:

    - Node pools with Arm64 VMs and [FIPS](enable-fips-nodes) enabled aren't supported with Ubuntu OS.
    - Node pools with Arm64 VMs and [FIPS](enable-fips-nodes) require kubernetes version 1.31+.

    Use [`az aks nodepool update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-fips-image` parameter to enable FIPS on an existing node pool.

    ```azurecli
        az aks nodepool update \
           --resource-group myResourceGroup \
           --cluster-name myAKSCluster \
           --name np \
           --enable-fips-image
    ```

    This command triggers a reimage of the node pool immediately to deploy the FIPS compliant Operating System. This reimage occurs during the node pool update. No extra steps are required.

For more information on verifying FIPS enablement and disabling FIPS, see [Enable FIPS node pools](enable-fips-nodes).

## Verify the node pool uses Arm64

Verify a node pool uses Arm64 using the [`az aks nodepool show`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-show) command and verify the `vmSize` is a [Dpsv5](/en-us/azure/virtual-machines/dpsv5-dpdsv5-series), [Dplsv5](/en-us/azure/virtual-machines/dplsv5-dpldsv5-series), or [Epsv5](/en-us/azure/virtual-machines/epsv5-epdsv5-series) series.

```azurecli
    az aks nodepool show \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name mynodepool \
        --query vmSize
```

The following example output shows the node pool uses Arm64:

```output
 "Standard_D2pds_v5"
```