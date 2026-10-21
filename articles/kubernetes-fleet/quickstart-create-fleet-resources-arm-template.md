---
layout: Conceptual
title: 'Quickstart: Create an Azure Kubernetes Fleet Manager and join member clusters using ARM Templates | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/quickstart-create-fleet-resources-arm-template
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
description: In this quickstart, you learn how to create an Azure Kubernetes Fleet Manager and join member clusters using ARM Templates.
ms.date: 2025-12-16T00:00:00.0000000Z
author: MuhammadAli
ms.author: alimuhammad
ms.service: azure-kubernetes-fleet-manager
ms.custom: template-quickstart, mode-other
ms.devlang: azurecli
ms.topic: quickstart
locale: en-us
document_id: 1d3b2995-251e-9d6f-77be-1d3bb3f9ca53
document_version_independent_id: b677ea75-87e8-c0ff-ebc6-5c7230e1a8bd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/quickstart-create-fleet-resources-arm-template.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/quickstart-create-fleet-resources-arm-template
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/quickstart-create-fleet-resources-arm-template.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
platformId: 112217d7-5730-ac0c-2436-d11f948b9bfa
---

# Quickstart: Create an Azure Kubernetes Fleet Manager and join member clusters using ARM Templates | Microsoft Learn

**Applies to:** ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Learn how to create an Azure Kubernetes Fleet Manager using ARM templates.

## Before you begin

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Read the [conceptual overview of Fleet Manager](concepts-fleet), which provides an explanation of fleets and member clusters referenced in this document.
- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Install or upgrade Azure CLI](/en-us/cli/azure/install-azure-cli) to version `2.71.0` or later.

    - Ensure **fleet** extension is updated to version `1.5.2` or higher.

## Create a Fleet Manager

You can create a Fleet Manager and later add your AKS and Arc-enabled clusters as member clusters. If the Fleet Manager has a hub cluster, more features are enabled, such as [Kubernetes object propagation](concepts-resource-placement) and [Managed Fleet Namespaces](concepts-fleet-managed-namespace). For more information, see the [conceptual overview of Fleet Manager types](concepts-choosing-fleet), which provides a comparison of different Fleet Manager configurations.

Note

Once a Fleet Manager is created, it's possible to upgrade a Fleet Manager resource without a hub cluster to one with a hub cluster. For Fleet Manager resources with a hub cluster, once private or public is selected it can't be changed.

# [Fleet Manager without hub cluster](#tab/without-hub-cluster)
If you only want to use Fleet Manager for update orchestration, you can create a hubless Fleet Manager with the following ARM template:

##### Review the template

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "fleetName": {
            "type": "string",
            "defaultValue": "my-hubless-fleet"
        }
    },
    "resources": [
        {
            "type": "Microsoft.ContainerService/fleets",
            "apiVersion": "2025-03-01",
            "name": "[parameters('fleetName')]",
            "location": "[resourceGroup().location]",
            "properties": {}
        }
    ]
}
```

##### Deploy the template

1. Select **Deploy to Azure** to sign in and open a template.

    [![Button to deploy the Resource Manager template to Azure.](../reusable-content/ce-skilling/azure/media/template-deployments/deploy-to-azure-button.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Ffleet-hubless%2Fazuredeploy.json)
2. On the **Basics** page, configure the following template parameters

    - **Subscription**: Select an Azure subscription.
    - **Resource group**: Select **Create new**. Enter a unique name for the resource group, such as *myResourceGroup*, then select **OK**.
    - **Location**: Select a location, such as **East US**.
    - **Fleet Name**: Enter a unique name for the Fleet, such as *myFleet*.
3. Select **Review + Create** &gt; **Create**.

# [Fleet Manager with hub cluster](#tab/with-hub-cluster)
If you want to use Fleet Manager for Kubernetes object propagation in addition to update orchestration, then you need to create the Fleet Manager resource with the hub cluster.

Fleet Manager with a hub cluster supports both public and private modes for network access. For more information, see [Choose an Azure Kubernetes Fleet Manager option](concepts-choosing-fleet#network-access-modes-for-hub-cluster).

#### Public hub cluster

To create a Fleet Manager with a public hub cluster, use the following ARM template.

##### Review the template

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "fleetName": {
            "type": "string",
            "defaultValue": "my-hubful-fleet"
        }
    },
    "resources": [
        {
            "type": "Microsoft.ContainerService/fleets",
            "apiVersion": "2025-03-01",
            "name": "[parameters('fleetName')]",
            "location": "[resourceGroup().location]",
            "properties": {
                "hubProfile": {
                    "dnsPrefix": "[parameters('fleetName')]"
                }
            }
        }
    ]
}
```

##### Deploy the template

1. Select **Deploy to Azure** to sign in and open a template.

    [![Button to deploy the Resource Manager template to Azure.](../reusable-content/ce-skilling/azure/media/template-deployments/deploy-to-azure-button.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Ffleet-hubful%2Fazuredeploy.json)
2. On the **Basics** page, configure the following template parameters

    - **Subscription**: Select an Azure subscription.
    - **Resource group**: Select **Create new**. Enter a unique name for the resource group, such as *myResourceGroup*, then select **OK**.
    - **Location**: Select a location, such as **East US**.
    - **Fleet Name**: Enter a unique name for the Fleet, such as *myFleet*.
3. Select **Review + Create** &gt; **Create**.

#### Private hub cluster

When you create a Fleet Manager with a private hub cluster, take these additional considerations into account:

- Fleet Manager requires you to provide the subnet on which the Fleet Manager hub cluster's node Virtual Machine (VM) is placed. This can be done by setting `subnetId` in the `agentProfile` within the Fleet Manager's `hubProfile`.
- The address prefix of the vnet **vnetName** must not overlap with the Azure Kubernetes Service's (AKS) default service range of `10.0.0.0/16`.
- Private access mode doesn't allow configuring domain names.
- Private access mode requires a `Network Contributor` role assignment on the agent subnet for Fleet Manager's first party service principal (Fleet Manager's first party service principal ID varies across different Entra tenants). This role assignment is **NOT** needed when creating private Fleet Manager using the `az fleet create` command because the CLI automatically creates the role assignment.

1. Fetch Fleet Manager's service principal object ID:

```azurecli
az ad sp list --display-name "Azure Kubernetes Service - Fleet RP" --query "[].{id:id}" --output tsv
```

```output
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

1. Review the template

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vnetName": {
            "type": "String",
            "defaultValue": "myVnet"
        },
        "fleetName": {
            "type": "String",
            "defaultValue": "my-private-fleet"
        },
        "fleetSpObjectId": {
            "type": "String"
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Network/virtualNetworks",
            "apiVersion": "2024-05-01",
            "name": "[parameters('vnetName')]",
            "location": "[resourceGroup().location]",
            "properties": {
                "addressSpace": {
                    "addressPrefixes": [
                        "192.168.0.0/16"
                    ]
                }
            }
        },
        {
            "type": "Microsoft.ContainerService/fleets",
            "apiVersion": "2025-03-01",
            "name": "[parameters('fleetName')]",
            "location": "[resourceGroup().location]",
            "dependsOn": [
                "[guid(resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('vnetName'), 'subnet'), parameters('fleetSpObjectId'))]"
            ],
            "properties": {
                "hubProfile": {
                    "agentProfile": {
                        "subnetId": "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('vnetName'), 'subnet')]"
                    },
                    "apiServerAccessProfile": {
                        "enablePrivateCluster": true,
                        "enableVnetIntegration": false
                    }
                }
            }
        },
        {
            "type": "Microsoft.Network/virtualNetworks/subnets",
            "apiVersion": "2024-05-01",
            "name": "[concat(parameters('vnetName'), '/subnet')]",
            "dependsOn": [
                "[resourceId('Microsoft.Network/virtualNetworks', parameters('vnetName'))]"
            ],
            "properties": {
                "addressPrefix": "192.168.0.0/24"
            }
        },
        {
            "type": "Microsoft.Authorization/roleAssignments",
            "apiVersion": "2022-04-01",
            "name": "[guid(resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('vnetName'), 'subnet'), parameters('fleetSpObjectId'))]",
            "scope": "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('vnetName'), 'subnet')]",
            "properties": {
                "roleDefinitionId": "[subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')]",
                "principalType": "ServicePrincipal",
                "principalId": "[parameters('fleetSpObjectId')]"
            },
            "dependsOn": [
                "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('vnetName'), 'subnet')]"
            ]
        }
    ]
}
```

1. Deploy the ARM template with service principal object ID from first step

    - Select **Deploy to Azure** to sign in and open a template.

    [![Button to deploy the Resource Manager template to Azure.](../reusable-content/ce-skilling/azure/media/template-deployments/deploy-to-azure-button.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Ffleet-hubful-private%2Fazuredeploy.json)

    - On the **Basics** page, configure the following template parameters:

        - **Subscription**: Select an Azure subscription.
        - **Resource group**: Select **Create new**. Enter a unique name for the resource group, such as *myResourceGroup*, then select **OK**.
        - **Location**: Select a location, such as **East US**.
        - **Fleet Name**: Enter a unique name for the Fleet, such as *myFleet*.
        - **Vnet Name**: Enter a unique name for the virtual network, such as *myVnet*
        - **Fleet SP Object ID**: Enter the service principal object ID from **Step 1** output.
    - Select **Review + Create** &gt; **Create**.

---