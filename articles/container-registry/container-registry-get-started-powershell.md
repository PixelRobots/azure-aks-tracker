---
layout: Conceptual
title: Quickstart - Create Registry - PowerShell - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-powershell
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
description: Quickly learn to create a private Docker registry in Azure Container Registry with PowerShell
ms.date: 2025-02-07T00:00:00.0000000Z
ms.topic: quickstart
ms.custom: devx-track-azurepowershell, mvc, mode-api
locale: en-us
document_id: a14aeed3-ac3d-10b7-6810-9480d13b3169
document_version_independent_id: c7868ac5-369f-8e8b-1339-af040cd9e5c7
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-get-started-powershell.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-get-started-powershell
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-get-started-powershell.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: dfaffa34-a194-f8ac-afd8-6b38151831b0
---

# Quickstart - Create Registry - PowerShell - Azure Container Registry | Microsoft Learn

Azure Container Registry is a private registry service for building, storing, and managing container images and related artifacts. In this quickstart, you will create an Azure Container Registry instance by using the Azure PowerShell locally. Then, using the Docker CLI you will pull a hello-world container image, tag the hello-world container image to create a new container image, push the new container image into the container registry, delete the local container image, and finally pull and run the image from your registry.

## Prerequisites

Note

We recommend that you use the Azure Az PowerShell module to interact with Azure. To get started, see [Install Azure PowerShell](/en-us/powershell/azure/install-azure-powershell). To learn how to migrate to the Az PowerShell module, see [Migrate Azure PowerShell from AzureRM to Az](/en-us/powershell/azure/migrate-from-azurerm-to-az).

This quickstart requires Azure PowerShell module. Run `Get-Module -ListAvailable Az` to determine your installed version. If you need to install or upgrade, see [Install Azure PowerShell module](/en-us/powershell/azure/install-azure-powershell).

You must also have Docker installed locally. Docker provides packages for [macOS](https://docs.docker.com/desktop/setup/install/mac-install/), [Windows](https://docs.docker.com/desktop/setup/install/windows-install/), and [Linux](https://docs.docker.com/engine/install) systems.

Because the Azure Cloud Shell doesn't include all required Docker components (the `dockerd` daemon), you can't use the Cloud Shell for this quickstart.

## Sign in to Azure

Sign in to your Azure subscription with the [Connect-AzAccount](/en-us/powershell/module/az.accounts/connect-azaccount) command, and follow the on-screen directions.

```powershell
Connect-AzAccount
```

## Create resource group

Once you're authenticated with Azure, create a resource group with [New-AzResourceGroup](/en-us/powershell/module/az.resources/new-azresourcegroup). A resource group is a logical container in which you deploy and manage your Azure resources.

```powershell
New-AzResourceGroup -Name myResourceGroup -Location EastUS
```

## Create container registry

Next, create a container registry in your new resource group with the [New-AzContainerRegistry](/en-us/powershell/module/az.containerregistry/New-AzContainerRegistry) command.

The registry name must be unique within Azure, and contain 5-50 alphanumeric characters. The following example creates a registry named "mycontainerregistry." Replace *mycontainerregistry* in the following command, then run it to create the registry:

```powershell
$registry = New-AzContainerRegistry -ResourceGroupName "myResourceGroup" -Name "mycontainerregistry" -EnableAdminUser -Sku Standard -Location EastUS
```

Tip

In this quickstart, you create a *Standard* registry, which is sufficient for most Azure Container Registry workflows. For increased storage and image throughput, and capabilities such as connection using a [private endpoint](container-registry-private-endpoints), the **Premium** pricing plan option (SKU) is available. For details on service tiers (SKUs), see [Azure Container Registry SKU features and limits](container-registry-skus).

## Log in to registry

Before pushing and pulling container images, you must log in to your registry with the [Connect-AzContainerRegistry](/en-us/powershell/module/az.containerregistry/connect-azcontainerregistry) cmdlet. The following example uses the same credentials you logged in with when authenticating to Azure with the `Connect-AzAccount` cmdlet.

Note

In the following example, the value of `$registry.Name` is the resource name, not the fully qualified registry name.

```powershell
Connect-AzContainerRegistry -Name $registry.Name
```

The command returns `Login Succeeded` once completed.

## Push image to registry

To push an image to an Azure Container registry, you must first have an image. If you don't yet have any local container images, run the following [docker pull](https://docs.docker.com/engine/reference/commandline/pull/) command to pull an existing public image. For this example, pull the `hello-world` image from Microsoft Container Registry.

```
docker pull mcr.microsoft.com/hello-world
```

Before you can push an image to your registry, you must tag it by using the [docker tag](https://docs.docker.com/engine/reference/commandline/tag/) with the fully qualified name of your registry login server.

- The login server name format for [Domain Name Label (DNL) protected registries](container-registry-get-started-portal#configure-domain-name-label-dnl-option) with a unique DNS name hash included is `mycontainerregistry-abc123.azurecr.io`.
- The login server name format for registries created with the `Unsecure` DNL option is `mycontainerregistry.azurecr.io`.

For example, if you create a registry with the `Tenant Reuse` DNL scope, the login server might look like `mycontainerregistry-abc123.azurecr.io` with a hash in the DNS name. If you create a registry with the `Unsecure` DNL option, the login server looks like `mycontainerregistry.azurecr.io`, without the hash.

Tag the image by using the [docker tag](https://docs.docker.com/engine/reference/commandline/tag/) command with your registry's login server. For this quickstart, tag the `hello-world` image with `v1`.

Example command to tag an image for a DNL-protected registry:

```
docker tag mcr.microsoft.com/hello-world mycontainerregistry-abc123.azurecr.io/hello-world:v1
```

Example command to tag an image for a non-DNL registry:

```
docker tag mcr.microsoft.com/hello-world mycontainerregistry.azurecr.io/hello-world:v1
```

Finally, use [docker push](https://docs.docker.com/engine/reference/commandline/push/) to push the image to the registry instance. Replace `<login-server>` with the login server name of your registry instance. This example creates the **hello-world** repository, containing the `hello-world:v1` image.

```
docker push <login-server>/hello-world:v1
```

After pushing the image to your container registry, remove the `hello-world:v1` image from your local Docker environment by using the [docker rmi](https://docs.docker.com/engine/reference/commandline/rmi/) command. This command doesn't remove the image from the **hello-world** repository in your Azure container registry.

```
docker rmi <login-server>/hello-world:v1
```

## Run image from registry

Now, you can pull and run the `hello-world:v1` container image from your container registry by using [docker run](https://docs.docker.com/engine/reference/commandline/run/):

```
docker run <login-server>/hello-world:v1  
```

Example output:

```
Unable to find image 'mycontainerregistry.azurecr.io/hello-world:v1' locally
v1: Pulling from hello-world
Digest: sha256:662dd8e65ef7ccf13f417962c2f77567d3b132f12c95909de6c85ac3c326a345
Status: Downloaded newer image for mycontainerregistry.azurecr.io/hello-world:v1

Hello from Docker!
This message shows that your installation appears to be working correctly.

[...]
```

## Clean up resources

Once you're done working with the resources you created in this quickstart, use the [Remove-AzResourceGroup](/en-us/powershell/module/az.resources/remove-azresourcegroup) command to remove the resource group, the container registry, and the container images stored there:

```powershell
Remove-AzResourceGroup -Name myResourceGroup
```