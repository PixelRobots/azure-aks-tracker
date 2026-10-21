---
layout: Conceptual
title: Recover deleted artifacts with the soft delete policy in Azure Container Registry (preview) - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-soft-delete-policy
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
description: Learn how to enable the soft delete policy in Azure Container Registry to manage and recover accidentally deleted artifacts with a set retention period.
ms.topic: how-to
ms.date: 2026-03-25T00:00:00.0000000Z
ms.custom:
- devx-track-azurecli
- sfi-image-nochange
locale: en-us
document_id: e132d9d9-cf0c-ae3f-16bf-fc2618b340dc
document_version_independent_id: 3d04aff0-50f6-b802-cf6c-864f5884dd66
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-soft-delete-policy.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: container-registry/container-registry-soft-delete-policy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-soft-delete-policy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 0b99245b-1b93-5509-f199-cfb867750123
---

# Recover deleted artifacts with the soft delete policy in Azure Container Registry (preview) - Azure Container Registry | Microsoft Learn

Azure Container Registry (ACR) allows you to enable the *soft delete policy* that lets you recover accidentally deleted artifacts for a set retention period.

Important

The soft delete policy is currently in PREVIEW. See the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/) for legal terms that apply to Azure features that are in beta, preview, or otherwise not yet released into general availability.

You can enable or disable the soft delete policy at any time in the Azure portal or by using Azure CLI. When you enable the soft delete policy in ACR, the registry treats any deleted artifacts as soft-deleted artifacts with a set retention period. Within the retention period, you can list, filter, and restore all deleted artifacts. After the retention period expires, the soft-deleted artifacts are permanently deleted and can't be restored.

![Diagram of soft delete artifact lifecycle.](media/container-registry-soft-delete/02-soft-delete.png)

The default retention period for soft-deleted artifacts is seven days, but you can select any value between 1 and 90 days. You can set, update, and change the retention policy value. The soft-deleted artifacts expire once the retention period is complete.

The autopurge runs every 24 hours and always considers the current value of retention days before permanently deleting artifacts. For example, if you deleted an artifact five days ago, then change the retention value from 7 days to 14 days, the artifact expires after 14 days from the date it was deleted.

This preview feature is available in all [service tiers](container-registry-skus) (also known as SKUs).

Note

Soft-deleted artifacts are billed as per active SKU pricing for storage.

Keep in mind the following current limitations:

- Azure Container Registry doesn't support manually purging soft-deleted artifacts.
- The soft delete policy doesn't support registries configured for geo-replication or artifact cache.
- Azure Container Registry doesn't allow enabling both the [retention policy](container-registry-retention-policy) and the soft delete policy.

## Prerequisites

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- To perform soft delete operations, a user requires the following permissions at the container registry level:

    - `Microsoft.ContainerRegistry/registries/deleted/read`: List soft-deleted artifacts
    - `Microsoft.ContainerRegistry/registries/deleted/restore/action`: Restore soft-deleted artifacts
- For Azure CLI, you can use the Azure Cloud Shell or a local installation to run the commands listed in this article. We recommend using the most recent version of the Azure CLI. If you need to install or upgrade, see [How to install the Azure CLI](/en-us/cli/azure/install-azure-cli).

## Enable soft delete policy

You can enable the soft delete policy for your Azure Container Registry in the Azure portal or by using Azure CLI.

# [Azure portal](#tab/azure-portal)
1. Go to your Azure Container Registry in the Azure portal.
2. In **Overview**, check the status of **Soft delete (Preview)**.
3. If the **Status** is **Disabled**, select **Disabled** to open the **Properties** pane.
4. Select the **Soft delete** checkbox.
5. Enter a number of days between 1 and 90 to retain deleted artifacts.
6. Select **Save**.

![Screenshot showing the option to enable soft delete in the Azure portal.](media/container-registry-soft-delete/enable-soft-delete-policy.png)

When soft delete is enabled, and you perform actions such as untagging a manifest or deleting an artifact, you can view these tags and artifacts by selecting **Managed deleted artifacts** before the retention period expires, as described in the next section.

# [Azure CLI](#tab/azure-cli)
### Enable soft delete policy for registry

1. Update the soft delete policy for a given `MyRegistry` ACR with a retention period set between 1 to 90 days.

    ```azurecli
    az acr config soft-delete update -r MyRegistry --days 7 --status <enabled/disabled>
    ```
2. Show the configured soft delete policy for a given `MyRegistry` ACR.

    ```azurecli
    az acr config soft-delete show -r MyRegistry 
    ```

---

## View and restore soft-deleted artifacts

You can view and restore soft-deleted artifacts during the current retention period set for a repository. Keep in mind the following considerations:

- You can't import a soft-deleted image at both source and target resources.
- Pushing an image to a soft-deleted repository restores that repository.
- Pushing an image that shares the same manifest digest with the soft-deleted image isn't allowed. Instead, restore the soft-deleted image.

# [Azure portal](#tab/azure-portal)
### Restore soft-deleted artifacts

1. Go to your Azure Container Registry in the Azure portal.
2. In the service menu, under **Services**, select **Repositories**.
3. In **Repositories**, select a repository.
4. Select **Manage deleted artifacts**.

    [![Screenshot showing how to access the Manage deleted artifacts option in the Azure portal.](media/container-registry-soft-delete/soft-delete-manage-deleted-artifacts.png)](media/container-registry-soft-delete/soft-delete-manage-deleted-artifacts.png#lightbox)
5. In the row for the deleted artifact that you want to restore, select **Restore**.
6. In the **Restore Artifact** pane, select the tag to restore. You can only select one tag with which to restore your artifact. To recover additional tags, you must restore them separately.
7. Select **Restore**.

### Restore soft-deleted repositories

1. Go to your Azure Container Registry in the Azure portal.
2. In the service menu, under **Services**, select **Repositories**.
3. In **Repositories**, select a repository.
4. Select **Manage Deleted Repositories**.
5. In the row for the deleted repository that you want to restore, select **Restore**.
6. In the **Restore Artifact** pane, select the tag to restore. You can only select one tag with which to restore your repository. To recover additional tags, you must restore them separately.
7. Select **Restore**

# [Azure CLI](#tab/azure-cli)
### List soft-deleted artifacts

The [`az acr repository list-deleted`](/en-us/cli/azure/acr/repository#az-acr-repository-list-deleted) command enables fetching and listing of soft-deleted repositories. Use one or more of the following options to list soft-deleted artifacts.

List the soft-deleted repositories in the `MyRegistry` repository:

```azurecli
az acr repository list-deleted -n MyRegistry
```

List the soft-deleted manifests of the `hello-world` repository in the `MyRegistry` repository:

```azurecli
az acr manifest list-deleted -r MyRegistry -n hello-world
```

List the soft-deleted tags of the `hello-world` repository in the `MyRegistry` repository:

```azurecli
az acr manifest list-deleted-tags -r MyRegistry -n hello-world
```

Filter the soft-deleted tags of the `hello-world` repository to match tag `latest` in the `MyRegistry` repository:

```azurecli
az acr manifest list-deleted-tags -r MyRegistry -n hello-world:latest
```

### Restore soft-deleted artifacts

The [`az acr manifest restore`](/en-us/cli/azure/acr/manifest#az-acr-manifest-restore) command restores a single deleted image by tag and digest. Use one or more of the following options to restore soft-deleted artifacts.

Restore the `hello-world` repository image by tag `latest` and digest `sha256:abc123` in the `MyRegistry` repository:

```azurecli
az acr manifest restore -r MyRegistry -n hello-world:latest -d sha256:abc123
```

Restore the most recently deleted manifest of the `hello-world` repository by tag `latest` in the `MyRegistry` repository:

```azurecli
az acr manifest restore -r MyRegistry -n hello-world:latest
```

*Force restore* overwrites the existing tag with the same name in the repository. To use force restore, add the specific argument `--force, -f`. If the soft delete policy is enabled when the force restore command is used, then the overwritten tag is soft-deleted according to the retention period.

Force restore the `hello-world` repository image by tag `latest` and digest `sha256:abc123` in the `MyRegistry` repository:

```azurecli
az acr manifest restore -r MyRegistry -n hello-world:latest -d sha256:abc123 -f
```

Important

Restoring a [manifest list](push-multi-architecture-images#manifest-list) doesn't recursively restore any underlying soft-deleted manifests.

If you restore soft-deleted [ORAS artifacts](container-registry-manage-artifact), then restoring a subject doesn't recursively restore the referrer chain. Also, the subject has to be restored before you can restore a referrer manifest.

---