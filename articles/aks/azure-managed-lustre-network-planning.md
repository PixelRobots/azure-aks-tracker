---
layout: Conceptual
title: Plan network architecture for AKS with Azure Managed Lustre CSI Driver - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-managed-lustre-network-planning
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
description: Learn how to plan the network architecture for connecting Azure Kubernetes Service (AKS) to an Azure Managed Lustre file system using the CSI driver.
ms.topic: concept-article
ms.subservice: aks-storage
ms.date: 2026-10-30T00:00:00.0000000Z
author: pauljewellmsft
ms.author: akashdubey
ms.reviewer: brianl
ms.custom: sfi-image-nochange
locale: en-us
document_id: 5dc85b48-3445-de1e-be4b-0e05ba047fc7
document_version_independent_id: bc9d13dd-3893-ae79-e5b9-efc426084b36
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-managed-lustre-network-planning.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/azure-managed-lustre-network-planning
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-managed-lustre-network-planning.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ae365aa9-5e19-49e1-95cb-6d0af6f19080
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/06cefb7d-f6d5-4371-a867-a6339677d3ad
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 2e509347-8f22-3017-dbc2-521d3ef85ebf
---

# Plan network architecture for AKS with Azure Managed Lustre CSI Driver - Azure Kubernetes Service | Microsoft Learn

Before deploying the Azure Lustre CSI Driver for Kubernetes, you need to plan the network configuration between your Azure Kubernetes Service (AKS) cluster and your Azure Managed Lustre file system. This article covers the supported network types and architecture options for connecting AKS to Azure Managed Lustre.

This network plan applies to Helm and script installations and to the alternative AKS CLI option in preview. The driver doesn't replace the network connectivity requirements or create the virtual network and subnet used for a dynamically provisioned file system. After preparing the network, follow [Install the Azure Managed Lustre CSI driver](azure-managed-lustre-install).

## Determine the network type to use with AKS

AKS supports multiple networking models, each with different capabilities and use cases. All networking models work with the Azure Lustre CSI Driver for Kubernetes, but they have different requirements for virtual networking and cluster setup.

For comprehensive information about choosing the right networking model for your specific requirements, see [Azure Kubernetes Service Container Network Interface (CNI) networking overview](/en-us/azure/aks/concepts-network-cni-overview).

When creating an AKS cluster in the Azure portal, you'll see the networking options described in the following sections.

### Recommended options

**Azure CNI Overlay (Recommended)**

- Conserves VNet IP address space by using logically separate CIDR ranges for pods
- Supports maximum cluster scale (5000 nodes and 250 pods per node)
- Simple IP address management
- Best choice for most scenarios

**Azure CNI Pod Subnet**

- Pods get full VNet connectivity and can be directly reached via their private IP address
- Requires larger, non-fragmented VNet IP address space
- Choose this if you need direct external access to pod IPs

### Legacy options (not recommended for new deployments)

**Azure CNI Node Subnet (Legacy)**

- Limited scale and inefficient use of VNet IPs
- Only recommended if you specifically need a managed VNet for your cluster. See [AKS Legacy Container Networking Interfaces (CNI)](/en-us/azure/aks/concepts-network-legacy-cni)

**Kubenet (Retiring)**

- Retiring March 31, 2028. For more information, see [AKS use Kubenet](/en-us/azure/aks/configure-kubenet).
- Limited scale and requires manual route management
- Plan to migrate to Azure CNI Overlay before the retirement date

For detailed information on networking models, see [Azure Kubernetes Service CNI networking overview](/en-us/azure/aks/concepts-network-cni-overview).

## Determine the network architecture for interconnectivity of AKS and Azure Managed Lustre

Azure Managed Lustre operates within a private virtual network. Your AKS instance must have network connectivity to the Azure Managed Lustre virtual network. There are two common ways to configure the networking between Azure Managed Lustre and AKS:

- Install AKS in its own virtual network and create a virtual network peering with the Azure Managed Lustre virtual network.
- Use the **Bring your own Azure virtual network** option in AKS to install AKS in a new subnet on the Azure Managed Lustre virtual network.

Note

Don't install AKS in the same subnet as Azure Managed Lustre.

### Peering AKS and Azure Managed Lustre virtual networks

Virtual network peering lets you separate network management into different privileged roles. It also provides flexibility because you can peer networks across Azure subscriptions or regions. Coordinate the two networks to avoid overlapping IP address spaces.

![Diagram that shows two virtual networks, one for Azure Managed Lustre and one for AKS, with a peering arrow connecting them.](media/azure-managed-lustre/subnet-access-option-2.png)

### Installing AKS in a subnet on the Azure Managed Lustre virtual network

The option to install the AKS cluster in the Azure Managed Lustre virtual network with the **Bring your own Azure virtual network** feature in AKS can be advantageous in scenarios where one team manages networking for both services. You need to create an extra subnet, sized to meet your AKS networking requirements, in the Azure Managed Lustre virtual network.

The AKS control-plane identity needs permissions on the AKS subnet. See [AKS identity role assignments](managed-identity-overview#control-plane-managed-identity-role-assignments) when using your own virtual network.

![Diagram that shows an Azure Managed Lustre virtual network with two subnets, one for the Lustre file system and one for AKS.](media/azure-managed-lustre/subnet-access-option-1.png)