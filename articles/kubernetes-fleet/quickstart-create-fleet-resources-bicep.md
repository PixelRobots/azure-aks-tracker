---
layout: Conceptual
title: 'Quickstart: Create an Azure Kubernetes Fleet Manager and join member clusters using Bicep | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/quickstart-create-fleet-resources-bicep
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
learn_banner_products:
- azure
description: In this quickstart, you learn how to create an Azure Kubernetes Fleet Manager and join member clusters using Bicep.
ms.date: 2025-12-16T00:00:00.0000000Z
author: MuhammadAli
ms.author: alimuhammad
ms.service: azure-kubernetes-fleet-manager
ms.custom: template-quickstart, mode-other
ms.devlang: azurecli
ms.topic: quickstart
locale: en-us
document_id: 3fd414c4-0ec4-8314-90f2-19e843761981
document_version_independent_id: 9770f0c0-1761-e2c1-4673-b933199cb67d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/quickstart-create-fleet-resources-bicep.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/quickstart-create-fleet-resources-bicep
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/quickstart-create-fleet-resources-bicep.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/f7db5823-dfbf-4e94-9016-c24311b90d7e
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/a5ab72d9-1367-4994-84a6-d9964cd9936d
platformId: c442df46-d844-384a-e131-288e397b422b
---

# Quickstart: Create an Azure Kubernetes Fleet Manager and join member clusters using Bicep | Microsoft Learn

**Applies to:** ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Learn how to create an Azure Kubernetes Fleet Manager using Bicep.

## Before you begin

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Read the [conceptual overview of Fleet Manager](concepts-fleet), which provides an explanation of fleets and member clusters referenced in this document.
- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Install or upgrade Azure CLI](/en-us/cli/azure/install-azure-cli) to version `2.71.0` or later.

    - Ensure **fleet** extension is updated to version `1.5.2` or higher.

## Create a Fleet Manager

You can create a Fleet Manager and later add your AKS and Arc-enabled clusters as member clusters. If the Fleet Manager has a hub cluster, more features are enabled, such as [Kubernetes object propagation](concepts-resource-placement) and [Managed Fleet Namespaces](concepts-fleet-managed-namespace). For more information, see the [conceptual overview of Fleet Manager types](concepts-choosing-fleet), which provides a comparison of different Fleet Manager configurations.

Important

Once a Fleet Manager is created, it's possible to upgrade a Fleet Manager resource without a hub cluster to one with a hub cluster. For Fleet Manager resources with a hub cluster, once private or public is selected it can't be changed.

# [Fleet Manager without hub cluster](#tab/without-hub-cluster)
If you only want to use Fleet Manager for update orchestration, you can create a hubless Fleet Manager with the following Bicep:

##### Review Bicep

```bicep
@description('The name of the Fleet resource.')
param fleetName string = 'my-hubless-fleet'

@description('The location of the Fleet resource.')
param location string = resourceGroup().location

resource hubless_fleet 'Microsoft.ContainerService/fleets@2025-03-01' = {
  name: fleetName
  location: location
}
```

##### Deploy the Bicep file using either Azure CLI or Azure PowerShell.

1. Save the Bicep file as **main.bicep** to your local computer.
2. Deploy the Bicep file using either Azure CLI or Azure PowerShell.

# [Azure CLI](#tab/azure-cli)
```azurecli
    az group create --name myResourceGroup --location eastus
    az deployment group create --resource-group myResourceGroup --template-file main.bicep'
    ```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
    New-AzResourceGroup -Name myResourceGroup -Location eastus
    New-AzResourceGroupDeployment -ResourceGroupName myResourceGroup -TemplateFile ./main.bicep"
    ```

---

# [Fleet Manager with hub cluster](#tab/with-hub-cluster)
If you want to use Fleet Manager for Kubernetes object propagation in addition to update orchestration, then you need to create the Fleet Manager resource with the hub cluster.

Fleet Manager with a hub cluster supports both public and private modes for network access. For more information, see [Choose an Azure Kubernetes Fleet Manager option](concepts-choosing-fleet#network-access-modes-for-hub-cluster).

#### Public hub cluster

To create a public Fleet Manager resource with a hub cluster, use the following Bicep

##### Review Bicep

```bicep
@description('The name of the Fleet resource.')
param fleetName string = 'my-hubful-fleet'

@description('The location of the Fleet resource.')
param location string = resourceGroup().location

resource hubful_fleet 'Microsoft.ContainerService/fleets@2025-03-01' = {
  name: fleetName
  location: location

  properties: {
    hubProfile: {
      dnsPrefix: fleetName
    }
  }
}
```

##### Deploy the Bicep file using either Azure CLI or Azure PowerShell.

1. Save the Bicep file as **main.bicep** to your local computer.
2. Deploy the Bicep file using either Azure CLI or Azure PowerShell.

# [Azure CLI](#tab/azure-cli)
```azurecli
    az group create --name myResourceGroup --location eastus
    az deployment group create --resource-group myResourceGroup --template-file main.bicep'
    ```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
    New-AzResourceGroup -Name myResourceGroup -Location eastus
    New-AzResourceGroupDeployment -ResourceGroupName myResourceGroup -TemplateFile ./main.bicep"
    ```

---

#### Private hub cluster

When you create a Fleet Manager with a private hub cluster, take these additional considerations into account:

- Fleet Manager requires you to provide the subnet on which the Fleet Manager hub cluster's node Virtual Machine (VM) is placed. This can be done by setting `subnetId` in the `agentProfile` within the Fleet Manager's `hubProfile`.
- The address prefix of the vnet **vnetName** must not overlap with the Azure Kubernetes Service's (AKS) default service range of `10.0.0.0/16`.
- Private access mode doesn't allow configuring domain names.
- Private access mode requires a `Network Contributor` role assignment on the agent subnet for Fleet Manager's first party service principal (Fleet Manager's first party service principal ID varies across different Entra tenants). This role assignment is **NOT** needed when creating private Fleet Manager using the `az fleet create` command because the CLI automatically creates the role assignment.

1. Fetch Fleet Manager's service principal object ID:

```azurecli
az ad sp list \
    --display-name "Azure Kubernetes Service - Fleet RP" \
    --query "[].{id:id}" \
    --output tsv
```

```output
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

1. Review Bicep

```bicep
@description('The name of the vnet.')
param vnetName string = 'myVnet'

@description('The name of the Fleet resource.')
param fleetName string = 'my-private-fleet'

@description('The object id of Fleets Service Principal in your tenant.')
param fleetSpObjectId string = '00000000-0000-0000-0000-000000000000' // Replace with the actual object ID of the Fleets Service Principal

@description('The location of the Fleet resource.')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
  }
}

resource hubful_private_fleet 'Microsoft.ContainerService/fleets@2025-03-01' = {
  name: fleetName
  location: location
  properties: {
    hubProfile: {
      agentProfile: {
        subnetId: vnet_subnet.id
      }
      apiServerAccessProfile: {
        enablePrivateCluster: true
        enableVnetIntegration: false
      }
    }
  }
  dependsOn: [
    roleassignment
  ]
}

resource vnet_subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  name: 'subnet'
  properties: {
    addressPrefix: '192.168.0.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  parent: vnet
}

resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: vnet_subnet
  name: guid(vnet_subnet.id, fleetSpObjectId)
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '4d97b98b-1d4f-4787-a291-c67834d212e7'
    )
    principalId: fleetSpObjectId
    principalType: 'ServicePrincipal'
  }
}
```

1. Deploy the Bicep file using either Azure CLI or Azure PowerShell. Deploy the Bicep file with service principal object ID from first step:

- Save the Bicep file as **main.bicep** to your local computer.
- Deploy the Bicep file using either Azure CLI or Azure PowerShell.

# [Azure CLI](#tab/azure-cli)
```azurecli
    az group create --name myResourceGroup --location eastus
    az deployment group create --resource-group myResourceGroup --template-file main.bicep --parameters fleets_sp_object_id=<fleet-sp-object-id>
    ```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
    New-AzResourceGroup -Name myResourceGroup -Location eastus
    New-AzResourceGroupDeployment -ResourceGroupName myResourceGroup -TemplateFile ./main.bicep -fleets_sp_object_id=<fleet-sp-object-id>"
    ```

---

# [Azure CLI](#tab/azure-cli)
```azurecli
    az group create --name myResourceGroup --location eastus
    az deployment group create --resource-group myResourceGroup --template-file main.bicep'
    ```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
    New-AzResourceGroup -Name myResourceGroup -Location eastus
    New-AzResourceGroupDeployment -ResourceGroupName myResourceGroup -TemplateFile ./main.bicep"
    ```

# [Azure CLI](#tab/azure-cli)
```azurecli
    az group create --name myResourceGroup --location eastus
    az deployment group create --resource-group myResourceGroup --template-file main.bicep'
    ```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
    New-AzResourceGroup -Name myResourceGroup -Location eastus
    New-AzResourceGroupDeployment -ResourceGroupName myResourceGroup -TemplateFile ./main.bicep"
    ```

# [Azure CLI](#tab/azure-cli)
```azurecli
    az group create --name myResourceGroup --location eastus
    az deployment group create --resource-group myResourceGroup --template-file main.bicep'
    ```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
    New-AzResourceGroup -Name myResourceGroup -Location eastus
    New-AzResourceGroupDeployment -ResourceGroupName myResourceGroup -TemplateFile ./main.bicep"
    ```

---