---
layout: Conceptual
title: Quickstart - Create Geo-Replicated Registry - ARM Template - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-geo-replication-template
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Learn how to create a geo-replicated Azure container registry by using an Azure Resource Manager template.
services: azure-resource-manager
ms.date: 2023-10-31T00:00:00.0000000Z
ms.topic: quickstart
tags: azure-resource-manager
ms.custom: subject-armqs, mode-arm, devx-track-arm-template
locale: en-us
document_id: 6c879fac-7a37-d8cd-679d-88457aa20f16
document_version_independent_id: 645bd9dd-6a42-9d9d-fa0c-2975826e7591
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-get-started-geo-replication-template.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-get-started-geo-replication-template
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-get-started-geo-replication-template.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: bdd75afe-4d18-ca73-0336-0ed924e4d1bb
---

# Quickstart - Create Geo-Replicated Registry - ARM Template - Azure Container Registry | Microsoft Learn

This quickstart shows how to create an Azure Container Registry instance by using an Azure Resource Manager template (ARM template). The template sets up a [geo-replicated](container-registry-geo-replication) registry, which automatically synchronizes registry content across more than one Azure region. Geo-replication enables network-close access to images from regional deployments, while providing a single management experience. It's a feature of the [Premium](container-registry-skus) registry service tier.

An [Azure Resource Manager template](/en-us/azure/azure-resource-manager/templates/overview) is a JavaScript Object Notation (JSON) file that defines the infrastructure and configuration for your project. The template uses declarative syntax. You describe your intended deployment without writing the sequence of programming commands to create the deployment.

The registry with replications does not support the ARM/Bicep template Complete mode deployments.

If your environment meets the prerequisites and you're familiar with using ARM templates, select the **Deploy to Azure** button. The template will open in the Azure portal.

[![Button to deploy the Resource Manager template to Azure.](../reusable-content/ce-skilling/azure/media/template-deployments/deploy-to-azure-button.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerregistry%2Fcontainer-registry-geo-replication%2Fazuredeploy.json)

## Prerequisites

If you don't have an Azure subscription, create a [free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) account before you begin.

## Review the template

The template used in this quickstart is from [Azure Quickstart Templates](https://azure.microsoft.com/resources/templates/container-registry-geo-replication/). The template sets up a registry and an additional regional replica.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.5.6.12127",
      "templateHash": "12610175857982700190"
    }
  },
  "parameters": {
    "acrName": {
      "type": "string",
      "defaultValue": "[format('acr{0}', uniqueString(resourceGroup().id))]",
      "maxLength": 50,
      "minLength": 5,
      "metadata": {
        "description": "Globally unique name of your Azure Container Registry"
      }
    },
    "acrAdminUserEnabled": {
      "type": "bool",
      "defaultValue": false,
      "metadata": {
        "description": "Enable admin user that has push / pull permission to the registry."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for registry home replica."
      }
    },
    "acrSku": {
      "type": "string",
      "defaultValue": "Premium",
      "allowedValues": [
        "Premium"
      ],
      "metadata": {
        "description": "Tier of your Azure Container Registry. Geo-replication requires Premium SKU."
      }
    },
    "acrReplicaLocation": {
      "type": "string",
      "metadata": {
        "description": "Short name for registry replica location."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ContainerRegistry/registries",
      "apiVersion": "2019-12-01-preview",
      "name": "[parameters('acrName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "[parameters('acrSku')]"
      },
      "tags": {
        "displayName": "Container Registry",
        "container.registry": "[parameters('acrName')]"
      },
      "properties": {
        "adminUserEnabled": "[parameters('acrAdminUserEnabled')]"
      }
    },
    {
      "type": "Microsoft.ContainerRegistry/registries/replications",
      "apiVersion": "2019-12-01-preview",
      "name": "[format('{0}/{1}', parameters('acrName'), parameters('acrReplicaLocation'))]",
      "location": "[parameters('acrReplicaLocation')]",
      "properties": {},
      "dependsOn": [
        "[resourceId('Microsoft.ContainerRegistry/registries', parameters('acrName'))]"
      ]
    }
  ],
  "outputs": {
    "acrLoginServer": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.ContainerRegistry/registries', parameters('acrName'))).loginServer]"
    }
  }
}
```

The following resources are defined in the template:

- **[Microsoft.ContainerRegistry/registries](/en-us/azure/templates/microsoft.containerregistry/registries)**: create an Azure container registry
- **[Microsoft.ContainerRegistry/registries/replications](/en-us/azure/templates/microsoft.containerregistry/registries/replications)**: create a container registry replica

More Azure Container Registry template samples can be found in the [quickstart template gallery](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Containerregistry&amp;pageNumber=1&amp;sort=Popular).

## Deploy the template

1. Select the following image to sign in to Azure and open a template.

    [![Button to deploy the Resource Manager template to Azure.](../reusable-content/ce-skilling/azure/media/template-deployments/deploy-to-azure-button.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerregistry%2Fcontainer-registry-geo-replication%2Fazuredeploy.json)
2. Select or enter the following values.

    - **Subscription**: select an Azure subscription.
    - **Resource group**: select **Create new**, enter a unique name for the resource group, and then select **OK**.
    - **Region**: select a location for the resource group. Example: **Central US**.
    - **Acr Name**: accept the generated name for the registry, or enter a name. It must be globally unique.
    - **Acr Admin User Enabled**: accept the default value.
    - **Location**: accept the generated location for the registry's home replica, or enter a location such as **Central US**.
    - **Acr Sku**: accept the default value.
    - **Acr Replica Location**: enter a location for the registry replica, using the region's short name. It must be different from the home registry location. Example: **westeurope**.

        ![Template properties](media/container-registry-get-started-geo-replication-template/template-properties.png)
3. Select **Review + Create**, then review the terms and conditions. If you agree, select **Create**.
4. After the registry has been created successfully, you get a notification:

    ![Portal notification](media/container-registry-get-started-geo-replication-template/deployment-notification.png)

The Azure portal is used to deploy the template. In addition to the Azure portal, you can use the Azure PowerShell, Azure CLI, and REST API. To learn other deployment methods, see [Deploy templates](/en-us/azure/azure-resource-manager/templates/deploy-cli).

## Review deployed resources

Use the Azure portal or a tool such as the Azure CLI to review the properties of the container registry.

1. In the portal, search for Container Registries, and select the container registry you created.
2. On the **Overview** page, note the **Login server** of the registry. Use this URI when you use Docker to tag and push images to your registry. For information, see [Push your first image using the Docker CLI](container-registry-get-started-docker-cli).

    ![Registry overview](media/container-registry-get-started-geo-replication-template/registry-overview.png)
3. On the **Replications** page, confirm the locations of the home replica and the replica added through the template. If desired, add more replicas on this page.

    ![Registry replications](media/container-registry-get-started-geo-replication-template/registry-replications.png)

## Clean up resources

When you no longer need them, delete the resource group, the registry, and the registry replica. To do so, go to the Azure portal, select the resource group that contains the registry, and then select **Delete resource group**.

![Delete resource group](media/container-registry-get-started-geo-replication-template/delete-resource-group.png)