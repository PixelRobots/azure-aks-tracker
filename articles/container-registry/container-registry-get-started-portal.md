---
layout: Conceptual
title: Quickstart - Create Registry in Portal - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal
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
description: Quickly learn to create a private Azure container registry using the Azure portal, push a container image, and pull and run the image from the registry.
ms.date: 2025-12-09T00:00:00.0000000Z
ms.topic: quickstart
ms.custom:
- mvc
- mode-ui
- sfi-image-nochange
locale: en-us
document_id: ba491964-1f3c-6833-fc0b-ad57606ebced
document_version_independent_id: d507f1aa-0e8e-9abc-2dd8-1b152ee530f9
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-get-started-portal.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-get-started-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-get-started-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: fd74c5d8-d213-bb4a-94fd-e6951b23c80b
---

# Quickstart - Create Registry in Portal - Azure Container Registry | Microsoft Learn

[Azure Container Registry](container-registry-intro) is a private registry service for building, storing, and managing container images and related artifacts. In this quickstart, you create an Azure container registry instance with the Azure portal. Next, you use Docker commands to push a container image into the registry. Finally, you pull and run the image from your registry.

## Prerequisites

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

# [Azure CLI](#tab/azure-cli)
To sign in to the registry to work with container images, this quickstart requires that you run the Azure CLI, preferably the most recent version. If you need to install or upgrade, see [How to install the Azure CLI](/en-us/cli/azure/install-azure-cli).

# [Azure PowerShell](#tab/azure-powershell)
To sign in to the registry to work with container images, this quickstart requires that you run Azure PowerShell (version 7.5.0 or later recommended). Run `Get-Module Az -ListAvailable` to find the version. If you need to install or upgrade, see [How to install Azure PowerShell](/en-us/powershell/azure/install-az-ps).

---

You must also have Docker installed locally with the daemon running. Docker provides packages that easily configure Docker on any [Mac](https://docs.docker.com/desktop/setup/install/mac-install/), [Windows](https://docs.docker.com/desktop/setup/install/windows-install/), or [Linux](https://docs.docker.com/engine/install) system.

## Create a container registry

1. Sign in to the [Azure portal](https://portal.azure.com).
2. Select **Create a resource** &gt; **Infrastructure services** &gt; **Container Registry** &gt; **Create**.

    ![Screenshot of the option to create a new container registry resource in the Azure portal.](media/container-registry-get-started-portal/create-resource-container-registry.png)
3. In the **Basics** tab, select the subscription where you want to create the container registry.
4. Select **Create new** to create a new resource group, and enter `myResourceGroup` for the resource group name.
5. Enter a **Registry name**. The registry name must be unique within Azure, and contain 5-50 alphanumeric characters, excluding dash characters (`-`). This name is part of the fully qualified DNS name of the registry.
6. Select **West US 2** for **Location**, and for [**Pricing plan**](container-registry-skus), select `Standard`.
7. For **Domain name label scope**, select **Tenant Reuse**, or choose another option as described in the Configure Domain Name Label (DNL) option section.
8. For **Role assignment permissions mode**, select **RBAC Registry + ABAC Repository Permissions** to retain standard Microsoft Entra role-based access control (RBAC) role assignments, while optionally applying [Microsoft Entra attribute-based access control (ABAC) conditions](container-registry-rbac-abac-repository-permissions) for fine‑grained, repository‑level access control.

    ![Screenshot showing the container registry creation settings in the portal](media/container-registry-get-started-portal/configure-container-registry-options.png)
9. Leave the other options set to their default values, and select **Review + create**. After reviewing the settings, select **Create**.

Tip

In this quickstart, you create a *Standard* registry, which is sufficient for most Azure Container Registry workflows. For increased storage and image throughput, and capabilities such as connection using a [private endpoint](container-registry-private-endpoints), the **Premium** pricing plan option (SKU) is available. For details on service tiers (SKUs), see [Azure Container Registry SKU features and limits](container-registry-skus).

When the **Deployment succeeded** message appears, select **Go to resource** to view your new container registry.

![Screenshot of the overview page of a container registry in the Azure portal.](media/container-registry-get-started-portal/container-registry-overview.png)

Take note of the registry name and the value of the **Login server**, which is a fully qualified name ending with `azurecr.io` in the Azure cloud.

Use the login server in the following steps when you push and pull images with Docker, as well as in downstream references such as Dockerfiles, Kubernetes YAML, and Helm charts.

## Sign in to registry

# [Azure CLI](#tab/azure-cli)
Before pushing and pulling container images, you must sign in to the registry instance. [Sign in to the Azure CLI](/en-us/cli/azure/get-started-with-azure-cli) on your local machine, then run the [az acr login](/en-us/cli/azure/acr#az-acr-login) command.

Specify only the registry resource name when signing in with the Azure CLI, such as `az acr login -n registryname`. Don't use the fully qualified login server name, such as `registryname.azurecr.io` or `registryname-hash.azurecr.io` (for DNL-enabled registries).

```azurecli
az acr login --name <registry-name>
```

Example:

```azurecli
az acr login --name contosoacrregistry
```

The command returns `Login Succeeded` when it completes.

# [Azure PowerShell](#tab/azure-powershell)
Before pushing and pulling container images, you must sign in to the registry instance. [Sign in to Azure PowerShell](/en-us/powershell/azure/get-started-azureps) on your local machine, then run the [Connect-AzContainerRegistry](/en-us/powershell/module/az.containerregistry/connect-azcontainerregistry) cmdlet.

Specify only the registry resource name when signing in with Azure PowerShell. Don't use the fully qualified login server name, such as `registryname.azurecr.io` or `registryname-hash.azurecr.io` (for DNL-enabled registries).

```azurepowershell
Connect-AzContainerRegistry -Name <registry-name>
```

Example:

```azurepowershell
Connect-AzContainerRegistry -Name contosoacrregistry
```

The command returns `Login Succeeded` when it completes.

---

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

## List container images

To list the images in your registry, go to your registry in the portal. Under **Services**, select **Repositories**, then select the **hello-world** repository you created with `docker push`.

![Screenshot showing the container images for a container registry in the Azure portal.](media/container-registry-get-started-portal/list-container-images.png)

When you select the **hello-world** repository, you see the `v1`-tagged image under **Tags**.

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

To remove the resources you created, go to the **myResourceGroup** resource group in the Azure portal. Select **Delete resource group** to remove the resource group, the container registry, and the container images.

## Configure Domain Name Label (DNL) option

The Domain Name Label (DNL) feature strengthens security by preventing subdomain takeover attacks of registry DNS names. These attacks occur when a registry is deleted, and another entity reuses the same registry name, potentially causing downstream references to pull from the registry re-created by the other entity.

DNL addresses this issue by appending a unique hash to the registry's DNS name. This approach ensures that even if another entity reuses the same registry name, the DNS names differ because of the unique hash. This safeguard prevents your downstream references from inadvertently pointing to the registry re-created by the other entity.

When you create a registry from the Azure portal, select the **Domain Name Label Scope** from the available options:

- **Unsecure**: Creates the DNS name as-is, based on the registry name (for example, `contosoacrregistry.azurecr.io`). This option doesn't include DNL protection.
- **Tenant Reuse**: Appends a unique hash based on the tenant and registry name, ensuring the DNS name is unique within the tenant.
- **Subscription Reuse**: Appends a unique hash based on the subscription, tenant, and registry name, ensuring the DNS name is unique within the subscription.
- **Resource Group Reuse**: Appends a unique hash based on the resource group, subscription, tenant, and registry name, ensuring the DNS name is unique within the resource group.
- **No Reuse**: Generates a unique DNS name with a unique hash every time you create the registry, regardless of other factors, ensuring the DNS name is always unique.

Important

The DNL scope you select during registry creation is permanent and can't be modified later. This choice ensures consistent DNS behavior and prevents disruptions to downstream references.

For all DNL-enabled options except **Unsecure**, the DNS name follows the format `registryname-hash.azurecr.io`, where the dash (`-`) serves as the hash delineator. For instance, a registry named `contosoacrregistry` with the `Tenant Reuse` DNL scope has a DNS name like `contosoacrregistry-abc123.azurecr.io`. To avoid conflicts, the dash character (`-`) isn't permitted in the registry name.

If the DNS name differs from the registry name, you need to update downstream files such as Dockerfiles, Kubernetes YAML, and Helm charts to reflect the full DNS name with the DNL hash. For example, if you want your downstream Dockerfile to reference a registry named `contosoacrregistry` with the `Tenant Reuse` DNL scope, you need to update the reference to the full value such as `contosoacrregistry-abc123.azurecr.io` in your downstream Dockerfile.