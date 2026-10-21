---
layout: Conceptual
title: Kubernetes on Azure tutorial - Create an Azure Container Registry and build images - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-acr
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
description: In this Azure Kubernetes Service (AKS) tutorial, you create an Azure Container Registry instance and upload sample application container images.
ms.topic: tutorial
ms.date: 2026-04-07T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: mvc, devx-track-azurecli, devx-track-azurepowershell, aks-getting-started
locale: en-us
document_id: 9410c775-540c-0451-4041-43f5f4f9abbf
document_version_independent_id: e0ace6aa-4b2e-d840-a6fe-cc521faba04d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/tutorial-kubernetes-prepare-acr.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/tutorial-kubernetes-prepare-acr
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/tutorial-kubernetes-prepare-acr.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 6c50f6b6-8c85-1bec-6cac-ef624bb645f8
---

# Kubernetes on Azure tutorial - Create an Azure Container Registry and build images - Azure Kubernetes Service | Microsoft Learn

Azure Container Registry (ACR) is a private registry for container images. A private container registry allows you to securely build and deploy your applications and custom code.

In this tutorial, you deploy an ACR instance and push a container image to it. You learn how to:

- Create an ACR instance.
- Use [ACR Tasks](/en-us/azure/container-registry/container-registry-tasks-overview) to build and push container images to ACR.
- View images in your registry.

## Before you begin

In the [previous tutorial](tutorial-kubernetes-prepare-app), you cloned the application code repository and used Docker to create a container image for a simple Azure Store Front application. If you didn't create the Azure Store Front app image, return to [Tutorial 1 - Prepare an application for AKS](tutorial-kubernetes-prepare-app).

This tutorial creates billable Azure resources, including a resource group and an Azure Container Registry. To complete these steps, you need permissions to create resource groups and Azure Container Registry resources in your subscription, such as **Contributor** or **Owner**.

# [Azure CLI](#tab/azure-cli)
This tutorial requires Azure CLI version 2.0.53 or later. To find the version, run the `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

# [Azure PowerShell](#tab/azure-powershell)
This tutorial requires Azure PowerShell version 5.9.0 or later. To find the version, run the `Get-InstalledModule -Name Az` command. If you need to install or upgrade, see [Install Azure PowerShell](/en-us/powershell/azure/install-az-ps).

---

## Create an Azure Container Registry

Before creating an ACR instance, you need a resource group. An Azure resource group is a logical container into which you deploy and manage Azure resources.

# [Azure CLI](#tab/azure-cli)
1. Create variables for the resource group name, location, and registry name. You can use these values or create your own. The registry name variable's value stored in `ACRNAME` must be unique within Azure and contain 5-50 lowercase alphanumeric characters.

    ```azurecli
    export RESOURCE_GROUP=myResourceGroup
    export LOCATION=westus2
    export RANDOM_STRING=$(printf '%05d%05d' "$RANDOM" "$RANDOM")
    export ACRNAME="myregistry${RANDOM_STRING}"
    ```

    The registry name variable's value stored in `ACRNAME` must be unique within Azure and contain 5-50 lowercase alphanumeric characters. The `ACRNAME` value is concatenated with the `RANDOM_STRING` variable that stores a random 10-digit string to ensure the registry name is unique. The variable `RESOURCE_GROUP` with the value *myResourceGroup* for the resource group and `LOCATION` with the value *westus2*. You can use these values or create your own.
2. Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```
3. Create an ACR instance by using the [`New-AzContainerRegistry`](/en-us/powershell/module/az.containerregistry/new-azcontainerregistry) cmdlet and provide your own unique registry name. The *Basic* SKU is a cost-optimized entry point for development purposes that provides a balance of storage and throughput.

    ```azurecli
    az group show --name $RESOURCE_GROUP --query name --output tsv
    ```
4. Create an ACR instance using the [`az acr create`](/en-us/cli/azure/acr#az-acr-create) command and provide your own unique registry name. The *Basic* SKU is a cost-optimized entry point for development purposes that provides a balance of storage and throughput.

    ```azurecli
    az acr create \
      --resource-group $RESOURCE_GROUP \
      --location $LOCATION \
      --name $ACRNAME \
      --sku Basic
    ```

    Verify that the registry provisioning state is `Succeeded` before continuing:

    ```azurecli
    az acr show --name $ACRNAME --resource-group $RESOURCE_GROUP --query provisioningState --output tsv
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. Create variables for the resource group name, location, and registry name. You can use these values or create your own. The registry name variable's value stored in `ACRNAME` must be unique within Azure and contain 5-50 lowercase alphanumeric characters.

    ```azurepowershell
    $RESOURCE_GROUP="myResourceGroup"
    $LOCATION="westus2"
    $randobj=New-Object System.Random
    $RAND=$randobj.Next()
    $ACRNAME="myregistry$RAND"
    ```

    The registry name variable's value stored in `ACRNAME` must be unique within Azure and contain 5-50 lowercase alphanumeric characters. The `ACRNAME` value is concatenated with the `RAND` variable that stores a random 10-digit string to ensure the registry name is unique. The variable `RESOURCE_GROUP` with the value *myResourceGroup* for the resource group and `LOCATION` with the value *westus2*. You can use these values or create your own.
2. Create a resource group using the [`New-AzResourceGroup`](/en-us/powershell/module/az.resources/new-azresourcegroup) cmdlet.

    ```azurepowershell
    New-AzResourceGroup -Name $RESOURCE_GROUP -Location $LOCATION
    ```

    Verify that the resource group was created before continuing:

    ```azurepowershell
    Get-AzResourceGroup -Name $RESOURCE_GROUP | Select-Object -ExpandProperty ResourceGroupName
    ```
3. Create an ACR instance using the [`New-AzContainerRegistry`](/en-us/powershell/module/az.containerregistry/new-azcontainerregistry) cmdlet and provide your own unique registry name. The *Basic* SKU is a cost-optimized entry point for development purposes that provides a balance of storage and throughput.

    ```azurepowershell
    New-AzContainerRegistry -ResourceGroupName $RESOURCE_GROUP -Name $ACRNAME -Location $LOCATION -Sku Basic
    ```

    Verify that the registry provisioning state is `Succeeded` before continuing:

    ```azurepowershell
    Get-AzContainerRegistry -ResourceGroupName $RESOURCE_GROUP -Name $ACRNAME | Select-Object -ExpandProperty ProvisioningState
    ```

---

## Build and push container images to registry

Build and push the images to your ACR using the Azure CLI [`az acr build`](/en-us/cli/azure/acr#az-acr-build) command. The `az acr build` commands use images in the repository you cloned in the previous article [prepare an app for AKS](tutorial-kubernetes-prepare-app). Make sure you switch to that directory or the `build` commands fail. For example, if you created directory *demorepo* and cloned the repository, the repository's root directory is *aks-store-demo*, so switch to the *demorepo/aks-store-demo* directory.

Before running the build commands, verify that your current directory contains the expected service folders:

```azurecli
ls ./src/order-service ./src/store-front
```

There isn't an equivalent Azure PowerShell cmdlet that builds or pushes container images to the registry. You need to use the steps for Azure CLI, but with the `ACRNAME` variable set to the value you created in PowerShell. In PowerShell you can get the value with the command `$ACRNAME`.

In the following example, we don't build the `product-service` image. This image can take a long time to build, and there's a container image already available in the GitHub Container Registry (GHCR). You can use the [`az acr import`](/en-us/cli/azure/acr#az-acr-import) command to import the image from the GHCR to your ACR instance. We also don't build the `rabbitmq` image. This image is available from the Docker Hub public repository and doesn't need to be built or pushed to your ACR instance.

```azurecli
az acr import \
  --name $ACRNAME \
  --source ghcr.io/azure-samples/aks-store-demo/product-service:latest \
  --image aks-store-demo/product-service:1.0

az acr build \
  --registry $ACRNAME \
  --image aks-store-demo/order-service:1.0 ./src/order-service/

az acr build \
  --registry $ACRNAME \
  --image aks-store-demo/store-front:1.0 ./src/store-front/
```

If you get an authorization error, run `az login`, confirm the active subscription with `az account show`, and then rerun the failed command.

## List images in registry

# [Azure CLI](#tab/azure-cli)
View the images in your ACR instance using the [`az acr repository list`](/en-us/cli/azure/acr/repository#az-acr-repository-list) command.

```azurecli
az acr repository list --name $ACRNAME --output table
```

The following example output lists the available images in your registry:

```output
Result
----------------
aks-store-demo/product-service
aks-store-demo/order-service
aks-store-demo/store-front
```

# [Azure PowerShell](#tab/azure-powershell)
View the images in your ACR instance using the [`Get-AzContainerRegistryRepository`](/en-us/powershell/module/az.containerregistry/get-azcontainerregistryrepository) cmdlet.

```azurepowershell
Get-AzContainerRegistryRepository -RegistryName $ACRNAME
```

The following example output lists the available images in your registry:

```output
aks-store-demo/productservice
aks-store-demo/orderservice
aks-store-demo/storefront
```

---