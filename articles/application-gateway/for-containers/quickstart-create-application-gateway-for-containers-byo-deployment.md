---
layout: Conceptual
title: 'Quickstart: Create Application Gateway for Containers - bring your own deployment | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/quickstart-create-application-gateway-for-containers-byo-deployment
breadcrumb_path: /azure/bread/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/148/azure-application-gateway/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/8ae9bf04-8326-ec11-b6e6-000d3a4f0789?c=8d429912-8326-ec11-b6e6-000d3a4f0789
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
learn_banner_products:
- azure
manager: kumud
ms.reviewer: mbender
description: In this quickstart, you learn how to provision and manage the Application Gateway for Containers Azure resources independent from Kubernetes configuration.
services: application-gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.custom: devx-track-azurecli
ms.topic: quickstart
ms.date: 2024-08-12T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: 5cf9d3f1-b453-ba12-67b1-a930640b7e07
document_version_independent_id: ce7d1853-cd8b-fbbb-e99d-756801188819
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/quickstart-create-application-gateway-for-containers-byo-deployment.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/quickstart-create-application-gateway-for-containers-byo-deployment
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/quickstart-create-application-gateway-for-containers-byo-deployment.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: 5376a8e9-c00f-41ec-f54a-d4114ddd37b2
---

# Quickstart: Create Application Gateway for Containers - bring your own deployment | Microsoft Learn

This guide assumes you're following the **bring your own**[deployment strategy](overview#deployment-strategies), where ALB Controller references the Application Gateway for Containers resources precreated in Azure. It's assumed that resource lifecycles are managed in Azure, independent from what is defined within Kubernetes.

## Prerequisites

Ensure you have first deployed ALB Controller into your Kubernetes cluster. You may follow the ALB Controller quickstart guide for [Add-on](quickstart-deploy-application-gateway-for-containers-alb-controller-addon) or [Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm) if you haven't already deployed the ALB Controller.

## Create the Application Gateway for Containers resource

Execute the following command to create the Application Gateway for Containers resource.

```azurecli
RESOURCE_GROUP='<your resource group name>'
AGFC_NAME='alb-test' # Name of the Application Gateway for Containers resource to be created
az network alb create -g $RESOURCE_GROUP -n $AGFC_NAME
```

## Create a frontend resource

Execute the following command to create the Application Gateway for Containers frontend resource.

```azurecli
FRONTEND_NAME='test-frontend'
az network alb frontend create -g $RESOURCE_GROUP -n $FRONTEND_NAME --alb-name $AGFC_NAME
```

## Create an association resource

### Delegate a subnet to association resource

To create an association resource, you first need to reference a subnet for Application Gateway for Containers to establish connectivity to. Ensure the subnet for an Application Gateway for Containers association is at least a class C or larger (/24 or smaller CIDR prefix). For this step, you may either reuse an existing subnet and enable subnet delegation on it or create a new VNET, subnet, and enable subnet delegation.

# [Reference existing VNet and Subnet](#tab/existing-vnet-subnet)
To reference an existing subnet, execute the following command to set the variables for reference to the subnet in later steps.

```azurecli
VNET_NAME='<name of the virtual network to use>'
VNET_RESOURCE_GROUP='<the resource group of your VNET>'
ALB_SUBNET_NAME='subnet-alb' # subnet name can be any non-reserved subnet name (i.e. GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet would all be invalid)
```

# [New VNet and Subnet](#tab/new-vnet-subnet)
If you would like to use a new virtual network for the Application Gateway for Containers association resource, you can create a new vnet with the following commands.

Warning

Upon creation of the virtual network, ensure you establish connectivity between this virtual network/subnet and the AKS node pool to enable communication between Application Gateway for Containers and the pods running in AKS. This may be achieved by establishing [virtual network peering](../../virtual-network/virtual-network-peering-overview) between both virtual networks.

```azurecli
VNET_NAME='<name of the virtual network to use>'
VNET_RESOURCE_GROUP='<the resource group of your VNET>'
VNET_ADDRESS_PREFIX='<address space of the vnet that will contain various subnets. The vnet must be able to handle at least 250 available addresses (/24 or smaller cidr prefix for the subnet)>'
SUBNET_ADDRESS_PREFIX='<an address space under the vnet that has at least 250 available addresses (/24 or smaller cidr prefix for the subnet)>'
ALB_SUBNET_NAME='subnet-alb' # subnet name can be any non-reserved subnet name (i.e. GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet would all be invalid)
az network vnet create \
    --name $VNET_NAME \
    --resource-group $VNET_RESOURCE_GROUP \
    --address-prefix $VNET_ADDRESS_PREFIX \
    --subnet-name $ALB_SUBNET_NAME \
    --subnet-prefixes $SUBNET_ADDRESS_PREFIX
```

---

Enable subnet delegation for the Application Gateway for Containers service. The delegation for Application Gateway for Containers is identified by the *Microsoft.ServiceNetworking/trafficControllers* resource type.

```azurecli
az network vnet subnet update \
    --resource-group $VNET_RESOURCE_GROUP  \
    --name $ALB_SUBNET_NAME \
    --vnet-name $VNET_NAME \
    --delegations 'Microsoft.ServiceNetworking/trafficControllers'
ALB_SUBNET_ID=$(az network vnet subnet list --resource-group $VNET_RESOURCE_GROUP --vnet-name $VNET_NAME --query "[?name=='$ALB_SUBNET_NAME'].id" --output tsv)
echo $ALB_SUBNET_ID
```

### Delegate permissions to managed identity

ALB Controller needs the ability to provision new Application Gateway for Containers resources and join the subnet intended for the Application Gateway for Containers association resource.

In this example, we delegate the *AppGW for Containers Configuration Manager* role to the resource group and delegate the *Network Contributor* role to the subnet used by the Application Gateway for Containers association subnet, which contains the *Microsoft.Network/virtualNetworks/subnets/join/action* permission.

If desired, you can [create and assign a custom role](../../role-based-access-control/custom-roles-portal) with the *Microsoft.Network/virtualNetworks/subnets/join/action* permission to eliminate other permissions contained in the *Network Contributor* role. Learn more about [managing subnet permissions](../../virtual-network/virtual-network-manage-subnet#permissions).

```azurecli
IDENTITY_RESOURCE_NAME='azure-alb-identity'

resourceGroupId=$(az group show --name $RESOURCE_GROUP --query id -otsv)
principalId=$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query principalId -otsv)

# Delegate AppGw for Containers Configuration Manager role to RG containing Application Gateway for Containers resource
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $resourceGroupId --role "fbc52c3f-28ad-4303-a892-8a056630b8f1" 

# Delegate Network Contributor permission for join to association subnet
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $ALB_SUBNET_ID --role "4d97b98b-1d4f-4787-a291-c67834d212e7" 
```

### Create an association resource

Execute the following command to create the association resource and connect it to the referenced subnet. It can take 5-6 minutes for the Application Gateway for Containers association to be created.

```azurecli
ASSOCIATION_NAME='association-test'
az network alb association create -g $RESOURCE_GROUP -n $ASSOCIATION_NAME --alb-name $AGFC_NAME --subnet $ALB_SUBNET_ID
```