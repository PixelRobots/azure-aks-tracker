---
layout: Conceptual
title: Quickstart - Create Registry - Bicep - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-bicep
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
description: Learn how to create an Azure container registry by using a Bicep file.
services: azure-resource-manager
ms.date: 2023-10-31T00:00:00.0000000Z
ms.topic: quickstart
tags: azure-resource-manager, bicep
ms.custom: mode-api, devx-track-bicep
locale: en-us
document_id: 627fc377-6f07-8949-eb66-1603c8e34417
document_version_independent_id: 54a1376f-e7f3-4268-ab66-e2dda76ceb3e
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-get-started-bicep.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-get-started-bicep
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-get-started-bicep.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: b98cf4db-e79b-67d2-601e-88a97340a8ad
---

# Quickstart - Create Registry - Bicep - Azure Container Registry | Microsoft Learn

This quickstart shows how to create an Azure Container Registry instance by using a Bicep file.

[Bicep](/en-us/azure/azure-resource-manager/bicep/overview) is a domain-specific language (DSL) that uses declarative syntax to deploy Azure resources. It provides concise syntax, reliable type safety, and support for code reuse. Bicep offers the best authoring experience for your infrastructure-as-code solutions in Azure.

## Prerequisites

If you don't have an Azure subscription, create a [free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) account before you begin.

## Review the Bicep file

Use Visual Studio Code or your favorite editor to create a file with the following content and name it **main.bicep**:

```bicep
@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer

```

The following resource is defined in the Bicep file:

- **[Microsoft.ContainerRegistry/registries](/en-us/azure/templates/microsoft.containerregistry/registries)**: create an Azure container registry

More Azure Container Registry template samples can be found in the [quickstart template gallery](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Containerregistry&amp;pageNumber=1&amp;sort=Popular).

## Deploy the Bicep file

To deploy the file you've created, open PowerShell or Azure CLI. If you want to use the integrated Visual Studio Code terminal, select the `ctrl` + ``` key combination. Change the current directory to where the Bicep file is located.

# [CLI](#tab/CLI)
```azurecli
az group create --name myContainerRegRG --location centralus

az deployment group create --resource-group myContainerRegRG --template-file main.bicep --parameters acrName={your-unique-name}
```

# [PowerShell](#tab/PowerShell)
```azurepowershell
New-AzResourceGroup -Name myContainerRegRG -Location centralus

New-AzResourceGroupDeployment -ResourceGroupName myContainerRegRG -TemplateFile ./main.bicep -acrName "{your-unique-name}"
```

---

Note

Replace **{your-unique-name}**, including the curly braces, with a unique container registry name.

When the deployment finishes, you should see a message indicating the deployment succeeded.

## Review deployed resources

Use the Azure portal or a tool such as the Azure CLI to review the properties of the container registry.

1. In the portal, search for **Container Registries**, and select the container registry you created.
2. On the **Overview** page, note the **Login server** of the registry. Use this URI when you use Docker to tag and push images to your registry. For information, see [Push your first image using the Docker CLI](container-registry-get-started-docker-cli).

    ![Registry overview](media/container-registry-get-started-bicep/registry-overview.png)

## Clean up resources

When you no longer need the resource, delete the resource group, and the registry. To do so, go to the Azure portal, select the resource group that contains the registry, and then select **Delete resource group**.