---
layout: Conceptual
title: Enable Unauthenticated Anonymous Pull Access in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/anonymous-pull-access
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
description: Optionally enable unauthenticated anonymous pull access to make content in your Azure container registry publicly available
ms.topic: how-to
ms.date: 2025-02-28T00:00:00.0000000Z
locale: en-us
document_id: 9a1893dc-d7c5-a631-4f54-340789d53531
document_version_independent_id: d7fcabe2-4608-8c01-8257-f4583e5454c0
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/anonymous-pull-access.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: container-registry/anonymous-pull-access
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/anonymous-pull-access.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 94bf684d-9ff0-0d43-0ad6-6f9707d1f41a
---

# Enable Unauthenticated Anonymous Pull Access in Azure Container Registry - Azure Container Registry | Microsoft Learn

By default, access to pull or push content from an Azure container registry is only available to [authenticated](container-registry-authentication) users. Enabling anonymous (unauthenticated) pull access makes all registry content publicly available for read (pull) actions. Use anonymous pull access in scenarios that don't require user authentication, such as distributing public container images.

Anonymous pull access is available in the Standard and Premium [service tiers](container-registry-skus). To configure anonymous pull access, update a registry using the Azure CLI (version 2.21.0 or later). For information about installing or upgrading, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

- Enable anonymous pull access by updating the properties of an existing registry.
- After enabling anonymous pull access, you can disable that access at any time.
- Only data-plane operations are available to unauthenticated clients.
- The registry might throttle a high rate of unauthenticated requests.
- If you previously authenticated to the registry, make sure you clear the credentials before attempting an anonymous pull operation.

Warning

Anonymous pull access currently applies to all repositories in the registry. If you manage repository access using [non-Microsoft Entra token-based repository permissions](container-registry-token-based-repository-permissions) or [Microsoft Entra-based repository permissions](container-registry-rbac-abac-repository-permissions), all users can still pull from those repositories in a registry enabled for unauthenticated anonymous pull. Please be aware of this when enabling unauthenticated anonymous pull access.

## Configure anonymous pull access

Users can enable, disable, and query the status of anonymous pull access using the Azure CLI. The following examples demonstrate how to enable, disable, and query the status of anonymous pull access.

### Enable anonymous pull access

Update a registry using the [az acr update](/en-us/cli/azure/acr#az-acr-update) command and pass the `--anonymous-pull-enabled` parameter. By default, anonymous pull is disabled in the registry.

```azurecli
az acr update --name myregistry --anonymous-pull-enabled
```

Important

If you previously authenticated to the registry with Docker credentials, run `docker logout` to ensure that you clear the existing credentials before attempting anonymous pull operations. Otherwise, you might see an error message similar to "pull access denied". Remember to always specify the fully qualified registry name (all lowercase) when using `docker login` and tagging images for pushing to your registry. In the examples provided, the fully qualified name is `myregistry.azurecr.io`.

If you previously authenticated to the registry with Docker credentials, run the following command to clear existing credentials or any previous authentication.

```azurecli
   docker logout myregistry.azurecr.io
```

This step helps you attempt an anonymous pull operation. If you encounter any issues, you might see an error message similar to "pull access denied."

### Disable anonymous pull access

Disable anonymous pull access by setting `--anonymous-pull-enabled` to `false`.

```azurecli
az acr update --name myregistry --anonymous-pull-enabled false
```

### Query the status of anonymous pull access

You can query the status of "anonymous-pull" using the [az acr show command](/en-us/cli/azure/acr#az-acr-show) with the `--query` parameter. Here's an example:

```azurecli
az acr show -n <registry_name> --query anonymousPullEnabled
```

The command returns a boolean value indicating whether "Anonymous Pull" is enabled (`true`) or disabled (`false`). This command streamlines the process of verifying the status of features within ACR.