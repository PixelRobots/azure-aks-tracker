---
layout: Conceptual
title: AKS service permissions reference - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-service-permissions
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
description: Reference for the Azure permissions required by the identity creating an AKS cluster, the cluster identity at runtime, and AKS node access.
ms.topic: reference
ms.subservice: aks-security
ms.date: 2026-04-19T00:00:00.0000000Z
author: shashankbarsin
ms.author: shasb
ai-usage: ai-assisted
locale: en-us
document_id: 58dae33f-8406-90e9-d9a9-7c12c9ddd4ea
document_version_independent_id: 3031bf4b-6726-a0f5-25b9-fc57cc550a60
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-service-permissions.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-service-permissions
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-service-permissions.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
platformId: 59b93a2c-45d9-4808-3d58-d7f70e249088
---

# AKS service permissions reference - Azure Kubernetes Service | Microsoft Learn

When creating a cluster, AKS generates or modifies resources it needs (like VMs and NICs) to create and run the cluster on behalf of the user. This identity is distinct from the cluster's identity permission, which is created during cluster creation.

For the built-in roles used to grant these permissions, see [Azure built-in roles for Containers](/en-us/azure/role-based-access-control/built-in-roles#containers). For a worked example of granting a service principal the permissions needed for a custom virtual network, see [Use a service principal with AKS](kubernetes-service-principal). For an orientation across the four AKS identity scenarios, see [Access and identity options for AKS](concepts-identity).

## Identity creating and operating the cluster permissions

The following permissions are needed by the identity creating and operating the cluster.

| Permission | Reason |
| --- | --- |
| `Microsoft.Compute/diskEncryptionSets/read` | Required to read disk encryption set ID. |
| `Microsoft.Compute/proximityPlacementGroups/write` | Required for updating proximity placement groups. |
| `Microsoft.Network/applicationGateways/read``Microsoft.Network/applicationGateways/write``Microsoft.Network/virtualNetworks/subnets/join/action` | Required to configure application gateways and join the subnet. |
| `Microsoft.Network/virtualNetworks/subnets/join/action` | Required to configure the Network Security Group for the subnet when using a custom VNET. |
| `Microsoft.Network/publicIPAddresses/join/action``Microsoft.Network/publicIPPrefixes/join/action` | Required to configure the outbound public IPs on the Standard Load Balancer. |
| `Microsoft.OperationalInsights/workspaces/sharedkeys/read``Microsoft.OperationalInsights/workspaces/read``Microsoft.OperationsManagement/solutions/write``Microsoft.OperationsManagement/solutions/read``Microsoft.ManagedIdentity/userAssignedIdentities/assign/action` | Required to create and update Log Analytics workspaces and Azure monitoring for containers. |
| `Microsoft.Network/virtualNetworks/joinLoadBalancer/action` | Required to configure the IP-based Load Balancer Backend Pools. |

## AKS cluster identity permissions

The following permissions are used by the AKS cluster identity, which is created and associated with the AKS cluster. Each permission is used for the reasons below:

| Permission | Reason |
| --- | --- |
| `Microsoft.ContainerService/managedClusters/*` | Required for creating users and operating the cluster |
| `Microsoft.Network/loadBalancers/delete``Microsoft.Network/loadBalancers/read``Microsoft.Network/loadBalancers/write` | Required to configure the load balancer for a LoadBalancer service. |
| `Microsoft.Network/publicIPAddresses/delete``Microsoft.Network/publicIPAddresses/read``Microsoft.Network/publicIPAddresses/write` | Required to find and configure public IPs for a LoadBalancer service. |
| `Microsoft.Network/publicIPAddresses/join/action` | Required for configuring public IPs for a LoadBalancer service. |
| `Microsoft.Network/networkSecurityGroups/read``Microsoft.Network/networkSecurityGroups/write` | Required to create or delete security rules for a LoadBalancer service. |
| `Microsoft.Compute/disks/delete``Microsoft.Compute/disks/read``Microsoft.Compute/disks/write``Microsoft.Compute/locations/DiskOperations/read` | Required to configure AzureDisks. |
| `Microsoft.Storage/storageAccounts/delete``Microsoft.Storage/storageAccounts/listKeys/action``Microsoft.Storage/storageAccounts/read``Microsoft.Storage/storageAccounts/write``Microsoft.Storage/operations/read` | Required to configure storage accounts for AzureFile or AzureDisk. |
| `Microsoft.Network/routeTables/read``Microsoft.Network/routeTables/routes/delete``Microsoft.Network/routeTables/routes/read``Microsoft.Network/routeTables/routes/write``Microsoft.Network/routeTables/write` | Required to configure route tables and routes for nodes. |
| `Microsoft.Compute/virtualMachines/read` | Required to find information for virtual machines in a VMAS, such as zones, fault domain, size, and data disks. |
| `Microsoft.Compute/virtualMachines/write` | Required to attach AzureDisks to a virtual machine in a VMAS. |
| `Microsoft.Compute/virtualMachineScaleSets/read``Microsoft.Compute/virtualMachineScaleSets/virtualMachines/read``Microsoft.Compute/virtualMachineScaleSets/virtualmachines/instanceView/read` | Required to find information for virtual machines in a virtual machine scale set, such as zones, fault domain, size, and data disks. |
| `Microsoft.Network/networkInterfaces/write` | Required to add a virtual machine in a VMAS to a load balancer backend address pool. |
| `Microsoft.Compute/virtualMachineScaleSets/write` | Required to add a virtual machine scale set to a load balancer backend address pools and scale out nodes in a virtual machine scale set. |
| `Microsoft.Compute/virtualMachineScaleSets/delete` | Required to delete a virtual machine scale set to a load balancer backend address pools and scale down nodes in a virtual machine scale set. |
| `Microsoft.Compute/virtualMachineScaleSets/virtualmachines/write` | Required to attach AzureDisks and add a virtual machine from a virtual machine scale set to the load balancer. |
| `Microsoft.Network/networkInterfaces/read` | Required to search internal IPs and load balancer backend address pools for virtual machines in a VMAS. |
| `Microsoft.Compute/virtualMachineScaleSets/virtualMachines/networkInterfaces/read` | Required to search internal IPs and load balancer backend address pools for a virtual machine in a virtual machine scale set. |
| `Microsoft.Compute/virtualMachineScaleSets/virtualMachines/networkInterfaces/ipconfigurations/publicipaddresses/read` | Required to find public IPs for a virtual machine in a virtual machine scale set. |
| `Microsoft.Network/virtualNetworks/read``Microsoft.Network/virtualNetworks/subnets/read` | Required to verify if a subnet exists for the internal load balancer in another resource group. |
| `Microsoft.Compute/snapshots/delete``Microsoft.Compute/snapshots/read``Microsoft.Compute/snapshots/write` | Required to configure snapshots for AzureDisk. |
| `Microsoft.Compute/locations/vmSizes/read``Microsoft.Compute/locations/operations/read` | Required to find virtual machine sizes for finding AzureDisk volume limits. |

## Additional AKS cluster identity permissions

When creating a cluster with specific attributes, you will need the following additional permissions for the cluster identity. Since these permissions are not automatically assigned, you must add them to the cluster identity after it's created.

| Permission | Reason |
| --- | --- |
| `Microsoft.Network/networkSecurityGroups/write``Microsoft.Network/networkSecurityGroups/read` | Required if using a network security group in another resource group. Required to configure security rules for a LoadBalancer service. |
| `Microsoft.Network/virtualNetworks/subnets/read``Microsoft.Network/virtualNetworks/subnets/join/action` | Required if using a subnet in another resource group such as a custom VNET. |
| `Microsoft.Network/routeTables/routes/read``Microsoft.Network/routeTables/routes/write` | Required if using a subnet associated with a route table in another resource group such as a custom VNET with a custom route table. Required to verify if a subnet already exists for the subnet in the other resource group. |
| `Microsoft.Network/virtualNetworks/subnets/read` | Required if using an internal load balancer in another resource group. Required to verify if a subnet already exists for the internal load balancer in the resource group. |
| `Microsoft.Network/privatednszones/*` | Required if using a private DNS zone in another resource group such as a custom privateDNSZone. |

## AKS node mapped identity

The kubelet managed identity assigned to AKS nodes is used to pull images from Azure Container Registry. The required data actions depend on the registry's [role assignment permissions mode](/en-us/azure/container-registry/container-registry-rbac-built-in-roles-overview).

### Registries configured with "RBAC Registry Permissions"

| Permission | Reason |
| --- | --- |
| `Microsoft.ContainerRegistry/registries/pull/read` | Required to pull container images from Azure Container Registry. Granted by the [`AcrPull`](/en-us/azure/role-based-access-control/built-in-roles/containers#acrpull) built-in role. |

### Registries configured with "RBAC Registry + ABAC Repository Permissions"

ABAC-enabled mode is becoming the default for new Azure Container Registries. In this mode, the legacy `AcrPull` role isn't honored and you must grant the equivalent ABAC-enabled role permissions to the kubelet identity. For more information, see [Azure ABAC repository permissions in Azure Container Registry](/en-us/azure/container-registry/container-registry-rbac-abac-repository-permissions).

| Permission | Reason |
| --- | --- |
| `Microsoft.ContainerRegistry/registries/repositories/content/read``Microsoft.ContainerRegistry/registries/repositories/metadata/read` | Required to pull container images and read image tags and metadata from repositories. Granted by the [`Container Registry Repository Reader`](/en-us/azure/container-registry/container-registry-rbac-built-in-roles-directory-reference#container-registry-repository-reader) built-in role, which can be optionally scoped to specific repositories using ABAC conditions. |
| `Microsoft.ContainerRegistry/registries/catalog/repositories/read` | Required only if the kubelet identity needs to list all repositories in the registry. Granted by the [`Container Registry Repository Catalog Lister`](/en-us/azure/container-registry/container-registry-rbac-built-in-roles-directory-reference#container-registry-repository-catalog-lister) built-in role. This role doesn't support ABAC conditions. |