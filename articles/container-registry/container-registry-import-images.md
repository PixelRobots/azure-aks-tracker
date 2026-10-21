---
layout: Conceptual
title: Import Container Images to ACR using Azure APIs - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-import-images
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
description: Import container images to an Azure container registry by using Azure APIs, without needing to run Docker commands.
ms.topic: how-to
ms.date: 2026-08-26T00:00:00.0000000Z
ms.custom: devx-track-azurepowershell, devx-track-azurecli
locale: en-us
document_id: 0a9eeb5e-cbe9-8343-3db0-13fb148ebb1a
document_version_independent_id: 684bb876-38ee-4ad6-2653-40ee84383cd5
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-import-images.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-import-images
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-import-images.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: c3f5b40a-dea8-2039-3bac-7fe3285b00c2
---

# Import Container Images to ACR using Azure APIs - Azure Container Registry | Microsoft Learn

You can easily import (copy) container images to an Azure container registry without using Docker commands. For example, you can import images from a development registry to a production registry, or copy base images from a public registry.

Azure Container Registry handles many common scenarios to copy images and other artifacts from an existing registry:

- Import images from a public registry.
- Import images or OCI artifacts, including Helm 3 charts, from another Azure container registry in the same Azure subscription, Azure tenant, or across subscriptions and tenants.
- Import images from a non-Azure private container registry.

Importing images into an Azure container registry has the following benefits compared to using Docker CLI commands:

- If your client environment doesn't need a local Docker installation, you can import any container image, regardless of the supported OS type.
- If you import multi-architecture images (such as official Docker images), images for all architectures and platforms specified in the manifest list get copied.
- If you have access to the target registry, you don't require the registry's public endpoint.

Important

Importing images requires external registry support [RFC 7233](https://www.rfc-editor.org/rfc/rfc7233#section-2.3). To avoid failures, use a registry that supports RFC 7233 ranges while using the `az acr import` command with the registry URI.

## Limitations

- The maximum number of manifests for an imported image is 50.
- Azure Container Registry supports importing images from a variety of source registries across cloud providers. If the import source is an ACR, you can import only from the source ACR's home region. The source ACR's regional endpoints aren't supported as import sources. Specify the source ACR's global endpoint when importing from a source ACR. Additionally, an import always writes content to the downstream ACR's home region. See [Azure Container Registry endpoint reference](container-registry-endpoint-reference).

# [Azure CLI](#tab/azure-cli)
To import container images, run the Azure CLI in Azure Cloud Shell or locally.

# [Azure PowerShell](#tab/azure-powershell)
To import container images, run Azure PowerShell in Azure Cloud Shell or locally.

---

Note

If you need to distribute identical container images across multiple Azure regions, Azure Container Registry also supports [geo-replication](/en-us/azure/container-registry/container-registry-geo-replication). By geo-replicating a registry (Premium service tier required), you can serve multiple regions with identical image and tag names from a single registry.

Important

To import to or from a network-restricted Azure container registry, the restricted registry must [**allow access by trusted services**](allow-access-trusted-services) to bypass the network. By default, the setting is enabled, so import works. If you create a registry with a private endpoint or with registry firewall rules and don't enable the setting, import fails.

## Prerequisites

# [Azure CLI](#tab/azure-cli)
If you don't already have an Azure container registry, create a registry. For steps, see [Quickstart: Create a private container registry using the Azure CLI](container-registry-get-started-azure-cli).

# [Azure PowerShell](#tab/azure-powershell)
If you don't already have an Azure container registry, create a registry. For steps, see [Quickstart: Create a private container registry using Azure PowerShell](container-registry-get-started-powershell).

---

To import an image to an Azure Container Registry, your identity must have permissions to trigger imports on the target registry (`Container Registry Data Importer and Data Reader` role). See [Azure Container Registry Entra permissions and roles overview](container-registry-rbac-built-in-roles-overview).

## Import container images from a public registry

Important

To import from a public registry to a network-restricted Azure container registry, the restricted registry must [**allow access by trusted services**](allow-access-trusted-services) to bypass the network. By default, this setting is enabled, so import works. If you disable this setting in a newly created registry with a private endpoint or with registry firewall rules, import fails.

### Import container images from Docker Hub

# [Azure CLI](#tab/azure-cli)
For example, use the [az acr import](/en-us/cli/azure/acr#az-acr-import) command to import the multi-architecture `hello-world:latest` image from Docker Hub to a registry named *myregistry*. Because `hello-world` is an official image from Docker Hub, this image is in the default `library` repository. Include the repository name and optionally a tag in the value of the `--source` image parameter. (You can optionally identify an image by its manifest digest instead of by tag, which guarantees a particular version of an image.)

```azurecli
az acr import \
  --name myregistry \
  --source docker.io/library/hello-world:latest \
  --image hello-world:latest
```

You can verify that multiple manifests are associated with this image by running the [az acr manifest list-metadata](/en-us/cli/azure/acr/manifest#az-acr-manifest-list-metadata) command:

```azurecli
az acr manifest list-metadata \
  --name hello-world \
  --registry myregistry
```

To import an artifact by digest without adding a tag:

```azurecli
az acr import \
   --name myregistry \
   --source docker.io/library/hello-world@sha256:abc123 \
   --repository hello-world
```

If you have a [Docker Hub account](https://www.docker.com/pricing), use the credentials when importing an image from Docker Hub. Pass the Docker Hub user name and the password or a [personal access token](https://docs.docker.com/docker-hub/access-tokens/) as parameters to `az acr import`. The following example imports a public image from the `tensorflow` repository in Docker Hub, using Docker Hub credentials:

```azurecli
az acr import \
  --name myregistry \
  --source docker.io/tensorflow/tensorflow:latest-gpu \
  --image tensorflow:latest-gpu \
  --username <Docker Hub user name> \
  --password <Docker Hub token>
```

# [Azure PowerShell](#tab/azure-powershell)
For example, use the [Import-AzContainerRegistryImage](/en-us/powershell/module/az.containerregistry/import-azcontainerregistryimage) command to import the multi-architecture `hello-world:latest` image from Docker Hub to a registry named *myregistry*. Because `hello-world` is an official image from Docker Hub, this image is in the default `library` repository. Include the repository name and optionally a tag in the value of the `-SourceImage` parameter. (You can optionally identify an image by its manifest digest instead of by tag, which guarantees a particular version of an image.)

```azurepowershell
Import-AzContainerRegistryImage -RegistryName myregistry -ResourceGroupName myResourceGroup -SourceRegistryUri docker.io -SourceImage library/hello-world:latest
```

You can verify that multiple manifests are associated with this image by running the `Get-AzContainerRegistryManifest` cmdlet:

```azurepowershell
Get-AzContainerRegistryManifest -RepositoryName library/hello-world -RegistryName myregistry
```

If you have a [Docker Hub account](https://www.docker.com/pricing), use the credentials when importing an image from Docker Hub. Pass the Docker Hub user name and the password or a [personal access token](https://docs.docker.com/docker-hub/access-tokens/) as parameters to `Import-AzContainerRegistryImage`. The following example imports a public image from the `tensorflow` repository in Docker Hub, using Docker Hub credentials:

```azurepowershell
Import-AzContainerRegistryImage -RegistryName myregistry -ResourceGroupName myResourceGroup -SourceRegistryUri docker.io -SourceImage tensorflow/tensorflow:latest-gpu -Username <Docker Hub user name> -Password <Docker Hub token>
```

---

### Import container images from Microsoft Container Registry

For example, import the `ltsc2022` Windows Server Core image from the `windows` repository in Microsoft Container Registry.

# [Azure CLI](#tab/azure-cli)
```azurecli
az acr import \
--name myregistry \
--source mcr.microsoft.com/windows/servercore:ltsc2022\
--image servercore:ltsc2022
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
Import-AzContainerRegistryImage -RegistryName myregistry -ResourceGroupName myResourceGroup -SourceRegistryUri mcr.microsoft.com -SourceImage windows/servercore:ltsc2022
```

---

## Import container images from an Azure container registry in the same Microsoft Entra tenant

You can import an image from an Azure container registry in the same Microsoft Entra tenant by using integrated Microsoft Entra permissions.

- Your identity must have permissions to view and pull images, tags, and OCI referrers from the source registry (`Container Registry Data Importer and Data Reader` role assigned on the source registry).
- Your identity must also have permissions to both read images and trigger imports on the target registry (`Container Registry Data Importer and Data Reader` role assigned on the target registry).
- The registry can be in the same or a different Azure subscription in the same Microsoft Entra tenant.
- [Public access](container-registry-access-selected-networks#disable-public-network-access) to the source registry is disabled. If public access is disabled, specify the source registry by resource ID instead of by registry login server name.
- The source registry and/or the target registry with a private endpoint or registry firewall rules must ensure the restricted registry [allows trusted services](allow-access-trusted-services) to access the network.

### Import container images from a registry in the same subscription

For example, import the `aci-helloworld:latest` image from a source registry *mysourceregistry* to *myregistry* in the same Azure subscription.

# [Azure CLI](#tab/azure-cli)
The following example imports the `aci-helloworld:latest` image to *myregistry* from a source registry *mysourceregistry* in which access to the registry's public endpoint is disabled. Supply the resource ID of the source registry with the `--registry` parameter. Notice that the `--source` parameter specifies only the source repository and tag, not the registry login server name.

To use Microsoft Entra identity authentication to the source registry, include the `--registry <source-registry-resource-id>` flag.

```azurecli
az acr import \
  --name myregistry \
  --source aci-helloworld:latest \
  --image aci-helloworld:latest \
  --registry /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/sourceResourceGroup/providers/Microsoft.ContainerRegistry/registries/mysourceregistry
```

# [Azure PowerShell](#tab/azure-powershell)
The following example imports the `aci-helloworld:latest` image to *myregistry* from a source registry *mysourceregistry* in which access to the registry's public endpoint is disabled. Supply the resource ID of the source registry with the `-SourceRegistryResourceId` parameter. Notice that the `-SourceImage` parameter specifies only the source repository and tag, not the registry login server name.

To use Entra identity authentication to the source registry, include the `-SourceRegistryResourceId <source-registry-resource-id>` flag.

```azurepowershell
Import-AzContainerRegistryImage -RegistryName myregistry -ResourceGroupName myResourceGroup -SourceRegistryResourceId '/subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/sourceResourceGroup/providers/Microsoft.ContainerRegistry/registries/mysourceregistry' -SourceImage aci-helloworld:latest
```

---

### Import container images from a registry in a different subscription

Note

To import an image from one registry to another, the source and target registries must ensure that both regions are registered for Azure Container Registry (ACR) under the subscription’s resource providers.

# [Azure CLI](#tab/azure-cli)
In the following example, *mysourceregistry* is in a different subscription from *myregistry* in the same tenant. Supply the resource ID of the source registry by using the `--registry` parameter. The `--source` parameter specifies only the source repository and tag, not the registry login server name.

```azurecli
az acr import \
  --name myregistry \
  --source aci-helloworld:latest \
  --image aci-hello-world:latest \
  --registry /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/sourceResourceGroup/providers/Microsoft.ContainerRegistry/registries/mysourceregistry
```

# [Azure PowerShell](#tab/azure-powershell)
In the following example, *mysourceregistry* is in a different subscription from *myregistry* in the same tenant. Supply the resource ID of the source registry by using the `-SourceRegistryResourceId` parameter. The `-SourceImage` parameter specifies only the source repository and tag, not the registry login server name.

```azurepowershell
Import-AzContainerRegistryImage -RegistryName myregistry -ResourceGroupName myResourceGroup -SourceRegistryResourceId '/subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/sourceResourceGroup/providers/Microsoft.ContainerRegistry/registries/mysourceregistry' -SourceImage aci-helloworld:latest
```

---

### Import container images from a registry by using service principal credentials

To import from a registry that you can't access by using integrated Active Directory permissions, use service principal credentials (if available) for the source registry. Enter the appID and password of a Microsoft Entra [service principal](container-registry-auth-service-principal) that has the correct role assignment access to the source registry.

- For Microsoft Entra service principals, ensure either `Container Registry Repository Reader` (for [ABAC-enabled registries](container-registry-rbac-abac-repository-permissions)) or `AcrPull` (for non-ABAC registries) is assigned.

Using a service principal is useful for build systems and other unattended systems that need to import images to your registry.

# [Azure CLI](#tab/azure-cli)
```azurecli
az acr import \
  --name myregistry \
  --source sourceregistry.azurecr.io/sourcerepo:tag \
  --image targetimage:tag \
  --username <SP_App_ID> \
  --password <SP_Passwd>
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
Import-AzContainerRegistryImage -RegistryName myregistry -ResourceGroupName myResourceGroup -SourceRegistryUri sourceregistry.azurecr.io -SourceImage sourcerepo:tag -Username <SP_App_ID> -Password <SP_Passwd>
```

---

## Import container images from an Azure container registry in a different tenant

To import images from an Azure container registry in a different Microsoft Entra tenant, specify the source registry by login server name, and provide credentials that enable pull access to the registry.

Cross-tenant import isn't supported over public access disabled registry.

### Cross-tenant import with username and password

For example, use a [non-Microsoft Entra repository-scoped token](container-registry-token-based-repository-permissions) and password, or the appID and password of a Microsoft Entra [service principal](container-registry-auth-service-principal) that has correct role assignments to the source registry.

- For Microsoft Entra service principals, ensure either `Container Registry Repository Reader` (for [ABAC-enabled registries](container-registry-rbac-abac-repository-permissions)) or `AcrPull` (for non-ABAC registries) is assigned on the source registry.

# [Azure CLI](#tab/azure-cli)
```azurecli
az acr import \
  --name myregistry \
  --source sourceregistry.azurecr.io/sourcerepo:tag \
  --image targetimage:tag \
  --username <SP_App_ID> \
  --password <SP_Passwd>
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
Import-AzContainerRegistryImage -RegistryName myregistry -ResourceGroupName myResourceGroup -SourceRegistryUri sourceregistry.azurecr.io -SourceImage sourcerepo:tag -Username <SP_App_ID> -Password <SP_Passwd>
```

---

### Cross-tenant import with access token

To access the source registry by using an identity in the source tenant that has registry permissions, get an access token:

# [Azure CLI](#tab/azure-cli)
```azurecli
# Login to Azure CLI with the identity, for example a user-assigned managed identity
az login --identity --username <identity_ID>

# Get access token returned by `az account get-access-token`
az account get-access-token
```

In the target tenant, pass the access token as a password to the `az acr import` command. The source registry specifies the login server name. No username is needed in this command:

```azurecli
az acr import \
  --name myregistry \
  --source sourceregistry.azurecr.io/sourcerepo:tag \
  --image targetimage:tag \
  --password ($token|ConvertFrom-Json).accessToken
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
# Login to Azure PowerShell with the identity, for example a user-assigned managed identity
Connect-AzAccount -Identity -AccountId <identity_ID>

# Get access token returned by `Get-AzAccessToken`
Get-AzAccessToken
```

In the target tenant, pass the access token as a password to the `Import-AzContainerRegistryImage` cmdlet. The source registry specifies the login server name. No username is needed in this command:

```azurepowershell
Import-AzContainerRegistryImage -RegistryName myregistry -ResourceGroupName myResourceGroup -SourceRegistryUri sourceregistry.azurecr.io -SourceImage sourcerepo:tag -Password <access-token>
```

---

## Import container images from a non-Azure private container registry

Import an image from a non-Azure private registry by specifying credentials that enable pull access to the registry. For example, pull an image from a private Docker registry:

# [Azure CLI](#tab/azure-cli)
```azurecli
az acr import \
  --name myregistry \
  --source docker.io/sourcerepo/sourceimage:tag \
  --image sourceimage:tag \
  --username <username> \
  --password <password>
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
Import-AzContainerRegistryImage -RegistryName myregistry -ResourceGroupName myResourceGroup -SourceRegistryUri docker.io/sourcerepo -SourceImage sourcerepo:tag -Username <username> -Password <password>
```

Note

If you're importing from a non-Azure private registry with IP rules, [follow these steps.](container-registry-access-selected-networks)

---

## Troubleshoot problems with container image imports

If you see an error when importing an image, review the following table for more information.

| Error message | Explanation |
| --- | --- |
| `The remote server may not be RFC 7233 compliant` | The [distribution-spec](https://github.com/opencontainers/distribution-spec/blob/main/spec.md) allows range header form of `Range: bytes=<start>-<end>`. However, the remote server might not be RFC 7233 compliant. |
| `Unexpected response status code` | An unexpected response status code was retrieved from the source repository when doing range query. |
| `Unexpected length of body in response` | The received content length doesn't match the expected size. The expected size is decided by blob size and range header. |