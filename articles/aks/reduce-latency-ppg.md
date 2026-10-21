---
layout: Conceptual
title: Use proximity placement groups to reduce latency for Azure Kubernetes Service (AKS) clusters - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/reduce-latency-ppg
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
description: Learn how to use proximity placement groups to reduce latency for your Azure Kubernetes Service (AKS) cluster workloads.
ms.topic: how-to
ms.subservice: aks-networking
ms.date: 2023-06-19T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 3fa56053-694f-2c0b-abf3-6af51ae5cee3
document_version_independent_id: 2d1cea9f-1838-e580-8a91-f85654bb9a04
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/reduce-latency-ppg.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/reduce-latency-ppg
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/reduce-latency-ppg.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 1eb194bf-727a-f8a3-33a8-0d32d5696287
---

# Use proximity placement groups to reduce latency for Azure Kubernetes Service (AKS) clusters - Azure Kubernetes Service | Microsoft Learn

Note

When using proximity placement groups on AKS, colocation only applies to the agent nodes. Node to node and the corresponding hosted pod to pod latency is improved. The colocation doesn't affect the placement of a cluster's control plane.

When deploying your application in Azure, you can create network latency by spreading virtual machine (VM) instances across regions or availability zones, which may impact the overall performance of your application. A proximity placement group is a logical grouping used to make sure Azure compute resources are physically located close to one another. Some applications, such as gaming, engineering simulations, and high-frequency trading (HFT) require low latency and tasks that can complete quickly. For similar high-performance computing (HPC) scenarios, consider using [proximity placement groups (PPG)](/en-us/azure/virtual-machines/co-location#proximity-placement-groups) for your cluster's node pools.

## Before you begin

This article requires Azure CLI version 2.14 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

### Limitations

- A proximity placement group can map to only *one* availability zone.
- A node pool must use Virtual Machine Scale Sets to associate a proximity placement group.
- A node pool can associate a proximity placement group at node pool create time only.

## Node pools and proximity placement groups

The first resource you deploy with a proximity placement group attaches to a specific data center. Any extra resources you deploy with the same proximity placement group are colocated in the same data center. Once all resources using the proximity placement group are stopped (deallocated) or deleted, it's no longer attached.

- You can associate multiple node pools with a single proximity placement group.
- You can only associate a node pool with a single proximity placement group.

### Configure proximity placement groups with availability zones

Note

While proximity placement groups require a node pool to use only *one* availability zone, the [baseline Azure VM SLA of 99.9%](https://azure.microsoft.com/support/legal/sla/virtual-machines/v1_9/) is still in effect for VMs in a single zone.

Proximity placement groups are a node pool concept and associated with each individual node pool. Using a PPG resource has no impact on AKS control plane availability, which can impact how you should design your cluster with zones. To ensure a cluster is spread across multiple zones, we recommend using the following design:

- Provision a cluster with the first system pool using *three* zones and no proximity placement group associated to ensure the system pods land in a dedicated node pool, which spreads across multiple zones.
- Add extra user node pools with a unique zone and proximity placement group associated to each pool. An example is *nodepool1* in zone one and PPG1, *nodepool2* in zone two and PPG2, and *nodepool3* in zone 3 with PPG3. This configuration ensures that, at a cluster level, nodes are spread across multiple zones and each individual node pool is colocated in the designated zone with a dedicated PPG resource.

## Create a new AKS cluster with a proximity placement group

Accelerated networking greatly improves networking performance of virtual machines. Ideally, use proximity placement groups with accelerated networking. By default, AKS uses accelerated networking on [supported virtual machine instances](/en-us/azure/virtual-network/accelerated-networking-overview?toc=/azure/virtual-machines/linux/toc.json#limitations-and-constraints), which include most Azure virtual machine with two or more vCPUs.

1. Create an Azure resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name myResourceGroup --location centralus
    ```
2. Create a proximity placement group using the [`az ppg create`](/en-us/cli/azure/ppg#az-ppg-create) command. Make sure to note the ID value in the output.

    ```azurecli
    az ppg create --name myPPG --resource-group myResourceGroup --location centralus --type standard
    ```

    The command produces an output similar to the following example output, which includes the *ID* value you need for upcoming CLI commands.

    ```output
    {
      "availabilitySets": null,
      "colocationStatus": null,
      "id": "/subscriptions/yourSubscriptionID/resourceGroups/myResourceGroup/providers/Microsoft.Compute/proximityPlacementGroups/myPPG",
      "location": "centralus",
      "name": "myPPG",
      "proximityPlacementGroupType": "Standard",
      "resourceGroup": "myResourceGroup",
      "tags": {},
      "type": "Microsoft.Compute/proximityPlacementGroups",
      "virtualMachineScaleSets": null,
      "virtualMachines": null
    }
    ```
3. Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command and replace the *myPPGResourceID* value with your proximity placement group resource ID from the previous step.

    ```azurecli
    az aks create \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --ppg myPPGResourceID
        --generate-ssh-keys
    ```

## Add a proximity placement group to an existing cluster

You can add a proximity placement group to an existing cluster by creating a new node pool. You can then optionally migrate existing workloads to the new node pool and delete the original node pool.

Use the same proximity placement group that you created earlier to ensure agent nodes in both node pools in your AKS cluster are physically located in the same data center.

- Create a new node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command and replace the *myPPGResourceID* value with your proximity placement group resource ID.

    ```azurecli
    az aks nodepool add \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name mynodepool \
        --node-count 1 \
        --ppg myPPGResourceID
    ```

## Clean up

- Delete the Azure resource group along with its resources using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command.

    ```azurecli
    az group delete --name myResourceGroup --yes --no-wait
    ```