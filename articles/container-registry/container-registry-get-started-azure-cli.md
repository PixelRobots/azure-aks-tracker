---
layout: Conceptual
title: Quickstart - Create Registry - Azure CLI - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-azure-cli
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
description: Learn how to create a private Docker container registry using the Azure CLI, push a container image, and pull and run the image from the registry.
ms.topic: quickstart
ms.date: 2023-10-31T00:00:00.0000000Z
ms.custom: H1Hack27Feb2017, mvc, devx-track-azurecli, mode-api
locale: en-us
document_id: 2a23fc33-0447-06f6-c6f0-dd0b4696cc6d
document_version_independent_id: 1a1af0e2-5b46-9261-1406-6636ae845c52
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-get-started-azure-cli.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-get-started-azure-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-get-started-azure-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 50a450f1-a050-cd0d-5702-d45221525555
---

# Quickstart - Create Registry - Azure CLI - Azure Container Registry | Microsoft Learn

Azure Container Registry is a private registry service for building, storing, and managing container images and related artifacts. In this quickstart, you create an Azure container registry instance with the Azure CLI. Then, use Docker commands to push a container image into the registry, and finally pull and run the image from your registry.

This quickstart requires that you are running the Azure CLI (version 2.0.55 or later recommended). Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

You must also have Docker installed locally. Docker provides packages that easily configure Docker on any [macOS](https://docs.docker.com/desktop/setup/install/mac-install/), [Windows](https://docs.docker.com/desktop/setup/install/windows-install/), or [Linux](https://docs.docker.com/engine/install) system.

Because the Azure Cloud Shell doesn't include all required Docker components (the `dockerd` daemon), you can't use the Cloud Shell for this quickstart.

## Create a resource group

Create a resource group with the [az group create](/en-us/cli/azure/group#az-group-create) command. An Azure resource group is a logical container into which Azure resources are deployed and managed.

The following example creates a resource group named *myResourceGroup* in the *eastus* location.

```azurecli
az group create --name myResourceGroup --location eastus
```

## Configure parameters for a container registry

In this quickstart you create a *Standard* registry, which is sufficient for most Azure Container Registry workflows. For details on available service tiers, see [Container registry service tiers](container-registry-skus).

Create an ACR instance using the [az acr create](/en-us/cli/azure/acr#az-acr-create) command. The registry name must be unique within Azure, and contain 5-50 lowercase alphanumeric characters. In the following example, *mycontainerregistry* is used. Update this to a unique value.

### Configure Domain Name Label (DNL) option

The Domain Name Label (DNL) feature strengthens security by preventing subdomain takeover attacks of registry DNS names. These attacks occur when a registry is deleted, and another entity reuses the same registry name, potentially causing downstream references to pull from the registry re-created by the other entity.

DNL addresses this by appending a unique hash to the registry's DNS name. This ensures that even if the same registry name is reused by another entity, the DNS names will differ due to the unique hash. This safeguards your downstream references from inadvertently pointing to the registry re-created by the other entity.

When creating a registry from the [az acr create](/en-us/cli/azure/acr#az-acr-create) command, you can specify the optional flag `--dnl-scope` and choose from the available options:

- **`Unsecure`**: Creates the DNS name as-is, based on the registry name (e.g., `contosoacrregistry.azurecr.io`). This option does not include DNL protection.
- **`TenantReuse`**: Appends a unique hash based on the tenant and registry name, ensuring the DNS name is unique within the tenant.
- **`SubscriptionReuse`**: Appends a unique hash based on the subscription, tenant, and registry name, ensuring the DNS name is unique within the subscription.
- **`ResourceGroupReuse`**: Appends a unique hash based on the resource group, subscription, tenant, and registry name, ensuring the DNS name is unique within the resource group.
- **`NoReuse`**: Generates a unique DNS name with a unique hash every time the registry is created, regardless of other factors, ensuring the DNS name is always unique.

Note

**Immutable Configuration**: The DNL scope selected during registry creation is permanent and cannot be modified later. This ensures consistent DNS behavior and prevents disruptions to downstream references.

### DNS Name Implications of DNL options

**DNS Name Format**: For all DNL-enabled options except **`Unsecure`**, the DNS name follows the format `registryname-hash.azurecr.io`, where the dash (`-`) serves as the hash delineator. To avoid conflicts, dash (`-`) is not permitted in the registry name. For instance, a registry named `contosoacrregistry` with the `TenantReuse` DNL scope will have a DNS name like `contosoacrregistry-e7ggejfuhzhgedc8.azurecr.io`.

**Downstream References**: The DNS name may differ from the registry name, necessitating updates in downstream files such as Dockerfiles, Kubernetes YAML, and Helm charts to reflect the full DNS name with the DNL hash. For example, if you want your downstream Dockerfile to reference a registry named `contosoacrregistry` with the `TenantReuse` DNL scope, you would need to update the reference to `contosoacrregistry-e7ggejfuhzhgedc8.azurecr.io` in your downstream Dockerfile.

### Configure role assignment permissions mode

You can optionally use the `--role-assignment-mode` parameter to specify the role assignment mode of the registry. This option determines how Microsoft Entra role-based access control (RBAC) and role assignments are managed for the registry, including the use of Microsoft Entra attribute-based access control (ABAC) for Microsoft Entra repository permissions.

Specify `rbac-abac` for this parameter to retain standard Microsoft Entra RBAC role assignments, while optionally applying Microsoft Entra ABAC conditions for fine‑grained, repository‑level access control.

For more information on this option, see [Microsoft Entra attribute-based access control (ABAC) for repository permissions](container-registry-rbac-abac-repository-permissions).

## Create a container registry

```azurecli
az acr create --resource-group myResourceGroup \
  --name mycontainerregistry --sku Standard \
  --role-assignment-mode 'rbac-abac' \
  --dnl-scope TenantReuse
```

When the registry is created, the output is similar to the following:

```json
{
  "adminUserEnabled": false,
  "creationDate": "2023-01-08T22:32:13.175925+00:00",
  "id": "/subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/myResourceGroup/providers/Microsoft.ContainerRegistry/registries/mycontainerregistry",
  "location": "eastus",
  "loginServer": "mycontainerregistry-e7ggejfuhzhgedc8.azurecr.io",
  "name": "mycontainerregistry",
  "provisioningState": "Succeeded",
  "resourceGroup": "myResourceGroup",
  "sku": {
    "name": "Standard",
    "tier": "Standard"
  },
  "status": null,
  "storageAccount": null,
  "tags": {},
  "type": "Microsoft.ContainerRegistry/registries",
  "roleAssignmentMode": "AbacRepositoryPermissions",
  "autoGeneratedDomainNameLabelScope": "TenantReuse"
}
```

Take note of `loginServer` in the output, which is the fully qualified registry name (all lowercase). Throughout the rest of this quickstart `<registry-name>` is a placeholder for the container registry name, and `<login-server>` is a placeholder for the registry's login server name.

Tip

In this quickstart, you create a *Standard* registry, which is sufficient for most Azure Container Registry workflows. For increased storage and image throughput, and capabilities such as connection using a [private endpoint](container-registry-private-endpoints), the **Premium** pricing plan option (SKU) is available. For details on service tiers (SKUs), see [Azure Container Registry SKU features and limits](container-registry-skus).

## Log in to registry

Before pushing and pulling container images, you must log in to the registry. To do so, use the [az acr login](/en-us/cli/azure/acr#az-acr-login) command. Specify only the registry resource name when logging in with the Azure CLI. Don't use the fully qualified login server name.

```azurecli
az acr login --name <registry-name>
```

Example:

```azurecli
az acr login --name mycontainerregistry
```

The command returns a `Login Succeeded` message once completed.

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

The following example lists the repositories in your registry:

```azurecli
az acr repository list --name <registry-name> --output table
```

Output:

```
Result
----------------
hello-world
```

The following example lists the tags on the **hello-world** repository.

```azurecli
az acr repository show-tags --name <registry-name> --repository hello-world --output table
```

Output:

```
Result
--------
v1
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

When no longer needed, you can use the [az group delete](/en-us/cli/azure/group#az-group-delete) command to remove the resource group, the container registry, and the container images stored there.

```azurecli
az group delete --name myResourceGroup
```