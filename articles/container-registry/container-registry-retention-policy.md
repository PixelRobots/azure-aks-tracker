---
layout: Conceptual
title: Set a Retention Policy to Retain Untagged Manifests - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-retention-policy
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
description: Learn how to enable a retention policy in your Premium Azure container registry, for automatic deletion of untagged manifests after a defined period.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2025-12-18T00:00:00.0000000Z
locale: en-us
document_id: 8aa2c495-4dd0-1040-cb44-2d569514de2f
document_version_independent_id: 7adea665-ebd8-8e85-7c7d-6fd070378073
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-retention-policy.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-retention-policy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-retention-policy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 36b4499a-cb55-e6cb-e225-30c0ae143d24
---

# Set a Retention Policy to Retain Untagged Manifests - Azure Container Registry | Microsoft Learn

Azure Container Registry gives you the option to set a *retention policy* for stored image manifests that don't have any associated tags. When you enable a retention policy, the registry automatically deletes untagged manifests after the number of days you set. This feature prevents the registry from filling up with unneeded artifacts and helps you save on storage costs.

To set a retention policy for untagged manifests, use the Azure portal or the Azure CLI. For the Azure CLI, run commands in either Azure Cloud Shell or a local installation with the latest version of the Azure CLI. To install or upgrade, see [How to install the Azure CLI](/en-us/cli/azure/install-azure-cli).

A retention policy for untagged manifests is currently a preview feature of container registries with the **Premium** pricing plan. For information about registry pricing plans (SKUs), see [Azure Container Registry SKU features and limits](container-registry-skus).

Warning

Set a retention policy with care; deleted image data is **unrecoverable**. If you have systems that pull images by manifest digest (as opposed to image name), don't set a retention policy for untagged manifests. Deleting untagged images prevents those systems from pulling the images from your registry. Instead of pulling by manifest, consider adopting a *unique tag* scheme, a [recommended best practice](container-registry-image-tag-version#unique-tags).

## How the retention policy works

Azure Container Registry does reference counting for manifests in the registry. When you untag a manifest, the registry checks to see if there's a retention policy. If a retention policy is enabled, and the `delete-enabled` attribute of the manifest is set to `true`, the registry schedules a manifest delete operation for a specific date and time, according to the number of days set in the retention policy.

As an example, suppose you untagged two manifests, one hour apart, in a registry with a retention policy of 30 days. The registry schedules delete operations for each of the manifests. Then, 30 days later, approximately one hour apart, both manifests are deleted, unless the retention policy is disabled before the scheduled deletion date.

You can exclude untagged manifests from being deleted by a retention policy by setting its `delete-enabled` attribute to `false`. For more information, see [Lock a container image in an Azure container registry](container-registry-image-lock).

Important

The retention policy applies only to untagged manifests with timestamps *after* the policy is enabled. Untagged manifests in the registry with earlier timestamps aren't subject to the policy. For other options to delete image data, see examples in [Delete container images in Azure Container Registry](container-registry-delete).

Untagged manifests that use OCI media types like `application/vnd.oci.image.manifest.v1+json` or `application/vnd.oci.image.index.v1+json` aren't supported by the retention policy. Only docker manifests are supported, including `application/vnd.docker.distribution.manifest.v2+json` and `application/vnd.docker.distribution.manifest.list.v2+json`. To clean up untagged OCI manifests, use the [acr purge command](container-registry-auto-purge).

## Set a retention policy

By default, container registries don't have a retention policy for untagged manifests. To set or update a retention policy, use either the Azure CLI or the Azure portal.

The default retention period for a retention policy is seven days, but you can specify any number of days between 0 and 365. After the retention period, the registry automatically deletes untagged manifests. Setting the value to 0 removes untagged manifests as soon as they become untagged.

# [Azure CLI](#tab/azure-cli)
### Set or update a retention policy

To set or update a retention policy, run the [az acr config retention update](/en-us/cli/azure/acr/config/retention#az-acr-config-retention-update) command.

The following example sets a retention policy of 30 days for untagged manifests in the registry *myregistry*:

```azurecli
az acr config retention update --registry myregistry --status enabled --days 30 --type UntaggedManifests
```

### Verify the retention policy

If you enable a retention policy with a retention period of 0 days, you can quickly verify that untagged manifests are deleted:

1. Push a test image `hello-world:latest` image to your registry, or substitute another test image of your choice.
2. Untag the `hello-world:latest` image by using the [az acr repository untag](/en-us/cli/azure/acr/repository#az-acr-repository-untag) command. This command doesn't delete the untagged manifest from the registry.

    ```azurecli
    az acr repository untag \
      --name myregistry --image hello-world:latest
    ```
3. Within a few seconds, because of your retention policy, the untagged manifest is deleted. Use the [az acr manifest list-metadata](/en-us/cli/azure/acr/manifest#az-acr-manifest-list-metadata) command to list all manifests in the repository, and confirm that your test image is no longer listed. If the test image was the only one in the repository, the repository itself is also deleted.

### Show the retention policy

To show the retention policy set in a registry, run the [az acr config retention show](/en-us/cli/azure/acr/config/retention#az-acr-config-retention-show) command:

```azurecli
az acr config retention show --registry myregistry
```

# [Azure portal](#tab/azure-portal)
You can enable a registry's retention policy in the [Azure portal](https://portal.azure.com).

1. Go to your Azure container registry.
2. In the service menu, under **Policies**, select **Retention (Preview)**.
3. In **Status**, select **Enabled**.
4. Specify a number of days between 0 and 365 to retain the untagged manifests.
5. Select **Save**.

![Screenshot showing the option to set a retention policy for untagged manifests for a container repository.](media/container-registry-retention-policy/set-retention-policy-untagged-manifests.png)

---

## Disable a retention policy

# [Azure CLI](#tab/azure-cli)
To disable a retention policy in a registry, run the [az acr config retention update](/en-us/cli/azure/acr/config/retention#az-acr-config-retention-update) command and set `--status disabled`:

```azurecli
az acr config retention update \
  --registry myregistry --status disabled \
  --type UntaggedManifests
```

# [Azure portal](#tab/azure-portal)
### Disable a retention policy

1. Go to your Azure container registry.
2. In the service menu, under **Policies**, select **Retention (Preview)**.
3. In **Status**, select **Disabled**.
4. Select **Save**.

---