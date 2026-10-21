---
layout: Conceptual
title: ACR Transfer with Azure CLI - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-transfer-cli
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
description: Learn how to use ACR Transfer with Azure CLI to efficiently manage and transfer container images in Azure Container Registry.
ms.topic: how-to
ms.date: 2026-02-11T00:00:00.0000000Z
ms.custom: devx-track-azurecli
locale: en-us
document_id: 91edd46d-8327-688f-e13a-29f35e2844dc
document_version_independent_id: 06ed6272-3e8d-a9ab-20cd-12c2e3165c07
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-transfer-cli.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-transfer-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-transfer-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: d7181331-0eb5-1f6f-1d6c-edde8f81962c
---

# ACR Transfer with Azure CLI - Azure Container Registry | Microsoft Learn

ACR Transfer enables you to transfer container images and OCI artifacts between Azure container registries using an intermediary storage account, making it ideal for air-gapped and cross-cloud scenarios. For an overview of the feature, see [Transfer artifacts to another registry](container-registry-transfer-prerequisites).

This article shows how to use the ACR Transfer feature with the acrtransfer Az CLI extension.

## Complete prerequisites

Please complete the prerequisites outlined in [ACR Transfer prerequisites](container-registry-transfer-prerequisites) prior to attempting the actions in this article. This means that:

- You have an existing Premium SKU Registry in both clouds.
- You have an existing Storage Account Container in both clouds.
- If using **SAS Token** storage access mode, ensure you have an existing Key Vault with a secret containing a valid SAS token with the necessary permissions in both clouds.
- If using **Managed Identity** storage access mode, ensure the pipeline's managed identity has the appropriate RBAC role (such as `Storage Blob Data Contributor`) on the storage account.
- You have a recent version of Az CLI installed in both clouds.

ACR Transfer supports two storage access modes: **SAS Token** and **Managed Identity**. You must specify which mode to use via the `--storage-access-mode` parameter when creating pipelines. For a detailed comparison, see [Storage access modes](container-registry-transfer-prerequisites#storage-access-modes).

Note

The `--storage-access-mode` parameter requires Azure CLI extension `acrtransfer` version 2.0.0 or later. If you're using an older version, upgrade with `az extension update --name acrtransfer`.

Important

ACR Transfer supports artifacts with layer sizes up to 8 GB due to technical limitations.

## Install the Az CLI extension

In AzureCloud, you can install the extension with the following command:

```azurecli
az extension add --name acrtransfer
```

## Create ExportPipeline with the acrtransfer Az CLI extension

Create an ExportPipeline resource for your AzureCloud container registry using the acrtransfer Az CLI extension.

### SAS Token mode

Create an export pipeline with SAS Token storage access mode, no options, and a system-assigned identity:

```azurecli
az acr export-pipeline create \
--resource-group $MyRG \
--registry $MyReg \
--name $MyPipeline \
--secret-uri https://$MyKV.vault.azure.net/secrets/$MySecret \
--storage-container-uri https://$MyStorage.blob.core.windows.net/$MyContainer \
--storage-access-mode SasToken
```

Create an export pipeline with SAS Token mode, all possible options, and a user-assigned identity:

```azurecli
az acr export-pipeline create \
--resource-group $MyRG \
--registry $MyReg \
--name $MyPipeline \
--secret-uri https://$MyKV.vault.azure.net/secrets/$MySecret \
--storage-container-uri https://$MyStorage.blob.core.windows.net/$MyContainer \
--storage-access-mode SasToken \
--options OverwriteBlobs ContinueOnErrors \
--assign-identity /subscriptions/$MySubID/resourceGroups/$MyRG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$MyIdentity
```

### Managed Identity mode

When using **Managed Identity** storage access mode, the pipeline authenticates directly to the storage account using the pipeline's Entra managed identity. No Key Vault or SAS token is required for storage access.

Create an export pipeline with Managed Identity mode and a system-assigned identity:

```azurecli
az acr export-pipeline create \
--resource-group $MyRG \
--registry $MyReg \
--name $MyPipeline \
--storage-container-uri https://$MyStorage.blob.core.windows.net/$MyContainer \
--storage-access-mode ManagedIdentity
```

Create an export pipeline with Managed Identity mode, all possible options, and a user-assigned identity:

```azurecli
az acr export-pipeline create \
--resource-group $MyRG \
--registry $MyReg \
--name $MyPipeline \
--storage-container-uri https://$MyStorage.blob.core.windows.net/$MyContainer \
--storage-access-mode ManagedIdentity \
--options OverwriteBlobs ContinueOnErrors \
--assign-identity /subscriptions/$MySubID/resourceGroups/$MyRG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$MyIdentity
```

Important

When using Managed Identity mode, do **not** provide the `--secret-uri` parameter. The `--secret-uri` parameter is only used with SAS Token mode.

### Export options

The `options` property for the export pipelines supports optional boolean values. The following values are recommended:

| Parameter | Value |
| --- | --- |
| options | OverwriteBlobs - Overwrite existing target blobsContinueOnErrors - Continue export of remaining artifacts in the source registry if one artifact export fails. |

### Give the ExportPipeline identity keyvault policy access

Note

This section only applies when using **SAS Token** storage access mode. If you are using **Managed Identity** storage access mode, skip this section and instead ensure your pipeline's managed identity has the appropriate RBAC role (such as `Storage Blob Data Contributor`) on the storage account.

If you created your pipeline with a user-assigned identity, simply give this user-assigned identity `secret get` access policy permissions on the keyvault.

If you created your pipeline with a system-assigned identity, you'll first need to retrieve the principalId that the system has assigned to your pipeline resource.

Run the following command to retrieve your pipeline resource:

```azurecli
az acr export-pipeline show --resource-group $MyRG --registry $MyReg --name $MyPipeline
```

From this output, you'll want to copy the value in the `principalId` field.

Then, you'll run the following command to give this principal the appropriate `secret get` access policy permissions on your keyvault.

```azurecli
az keyvault set-policy --name $MyKeyvault --secret-permissions get --object-id $MyPrincipalID
```

## Create ImportPipeline with the acrtransfer Az CLI extension

Create an ImportPipeline resource in your target container registry using the acrtransfer Az CLI extension. By default, the pipeline is enabled to create an Import PipelineRun automatically when the attached storage account container receives a new artifact blob.

### SAS Token mode

Create an import pipeline with SAS Token storage access mode, no options, and a system-assigned identity:

```azurecli
az acr import-pipeline create \
--resource-group $MyRG \
--registry $MyReg \
--name $MyPipeline \
--secret-uri https://$MyKV.vault.azure.net/secrets/$MySecret \
--storage-container-uri https://$MyStorage.blob.core.windows.net/$MyContainer \
--storage-access-mode SasToken
```

Create an import pipeline with SAS Token mode, all possible options, source-trigger disabled, and a user-assigned identity:

```azurecli
az acr import-pipeline create \
--resource-group $MyRG \
--registry $MyReg \
--name $MyPipeline \
--secret-uri https://$MyKV.vault.azure.net/secrets/$MySecret \
--storage-container-uri https://$MyStorage.blob.core.windows.net/$MyContainer \
--storage-access-mode SasToken \
--options DeleteSourceBlobOnSuccess OverwriteTags ContinueOnErrors \
--assign-identity /subscriptions/$MySubID/resourceGroups/$MyRG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$MyIdentity \
--source-trigger-enabled False
```

### Managed Identity mode

When using **Managed Identity** storage access mode, the pipeline authenticates directly to the storage account using the pipeline's Entra managed identity. No Key Vault or SAS token is required for storage access.

Create an import pipeline with Managed Identity mode and a system-assigned identity:

```azurecli
az acr import-pipeline create \
--resource-group $MyRG \
--registry $MyReg \
--name $MyPipeline \
--storage-container-uri https://$MyStorage.blob.core.windows.net/$MyContainer \
--storage-access-mode ManagedIdentity
```

Create an import pipeline with Managed Identity mode, all possible options, source-trigger disabled, and a user-assigned identity:

```azurecli
az acr import-pipeline create \
--resource-group $MyRG \
--registry $MyReg \
--name $MyPipeline \
--storage-container-uri https://$MyStorage.blob.core.windows.net/$MyContainer \
--storage-access-mode ManagedIdentity \
--options DeleteSourceBlobOnSuccess OverwriteTags ContinueOnErrors \
--assign-identity /subscriptions/$MySubID/resourceGroups/$MyRG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$MyIdentity \
--source-trigger-enabled False
```

Important

When using Managed Identity mode, do **not** provide the `--secret-uri` parameter. The `--secret-uri` parameter is only used with SAS Token mode.

### Import options

The `options` property for the import pipeline supports optional boolean values. The following values are recommended:

| Parameter | Value |
| --- | --- |
| options | OverwriteTags - Overwrite existing target tagsDeleteSourceBlobOnSuccess - Delete the source storage blob after successful import to the target registryContinueOnErrors - Continue import of remaining artifacts in the target registry if one artifact import fails. |

### Give the ImportPipeline identity keyvault policy access

Note

This section only applies when using **SAS Token** storage access mode. If you are using **Managed Identity** storage access mode, skip this section and instead ensure your pipeline's managed identity has the appropriate RBAC role (such as `Storage Blob Data Contributor`) on the storage account.

If you created your pipeline with a user-assigned identity, simply give this user-assigned identity `secret get` access policy permissions on the keyvault.

If you created your pipeline with a system-assigned identity, you'll first need to retrieve the principalId that the system has assigned to your pipeline resource.

Run the following command to retrieve your pipeline resource:

```azurecli
az acr import-pipeline show --resource-group $MyRG --registry $MyReg --name $MyPipeline
```

From this output, you'll want to copy the value in the `principalId` field.

Then, you'll run the following command to give this principal the appropriate `secret get` access policy on your keyvault.

```azurecli
az keyvault set-policy --name $MyKeyvault --secret-permissions get --object-id $MyPrincipalID
```

## Create PipelineRun for export with the acrtransfer Az CLI extension

Create a PipelineRun resource for your container registry using the acrtransfer Az CLI extension. This resource runs the ExportPipeline resource you created previously and exports specified artifacts from your container registry as a blob to your storage account container.

Create an export pipeline-run:

```azurecli
az acr pipeline-run create \
--resource-group $MyRG \
--registry $MyReg \
--pipeline $MyPipeline \
--name $MyPipelineRun \
--pipeline-type export \
--storage-blob $MyBlob \
--artifacts hello-world:latest hello-world@sha256:90659bf80b44ce6be8234e6ff90a1ac34acbeb826903b02cfa0da11c82cbc042 \
--force-redeploy
```

If redeploying a PipelineRun resource with identical properties, you must use the --force-redeploy flag.

### Pipeline run authentication logging

When a pipeline run executes, the CLI displays a log message indicating which authentication method is being used to access the storage account. This helps confirm whether the pipeline is using Managed Identity or SAS Token authentication:

```
Authenticating to Storage Account using Entra Managed Identity.
```

or

```
Authenticating to Storage Account using Storage SAS Token.
```

It can take several minutes for artifacts to export. When deployment completes successfully, verify artifact export by listing the exported blob in the container of the source storage account. For example, run the [az storage blob list](/en-us/cli/azure/storage/blob#az-storage-blob-list) command:

```azurecli
az storage blob list --account-name $MyStorageAccount --container-name $MyContainer --output table
```

## Transfer blob across domain

In most use-cases, you'll now use a Cross Domain Solution or other method to transfer your blob from the storage account in your source domain (the storage account associated with your export pipeline) to the storage account in your target domain (the storage account associated with your import pipeline). At this point, we'll assume that the blob has arrived in the target domain storage account associated with your import pipeline.

## Trigger ImportPipeline resource

If you didn't use the `--source-trigger-enabled False` parameter when creating your import pipeline, the pipeline will be triggered within 15 minutes after the blob arrives in the storage account container. It can take several minutes for artifacts to import. When the import completes successfully, verify artifact import by listing the tags on the repository you're importing in the target container registry. For example, run [az acr repository show-tags](/en-us/cli/azure/acr/repository#az-acr-repository-show-tags):

```azurecli
az acr repository show-tags --name $MyRegistry --repository $MyRepository
```

Note

Source Trigger will only import blobs that have a Last Modified time within the last 60 days. If you intend to use Source Trigger to import blobs older than that, please refresh the Last Modified time of the blobs by adding blob metadata to them or else import them with manually created pipeline runs.

If you did use the `--source-trigger-enabled False` parameter when creating your ImportPipeline, you'll need to create a PipelineRun manually, as shown in the following section.

## Create PipelineRun for import with the acrtransfer Az CLI extension

Create a PipelineRun resource for your container registry using the acrtransfer Az CLI extension. This resource runs the ImportPipeline resource you created previously and imports specified blobs from your storage account into your container registry.

Create an import pipeline-run:

```azurecli
az acr pipeline-run create \
--resource-group $MyRG \
--registry $MyReg \
--pipeline $MyPipeline \
--name $MyPipelineRun \
--pipeline-type import \
--storage-blob $MyBlob \
--force-redeploy
```

If redeploying a PipelineRun resource with identical properties, you must use the --force-redeploy flag.

It can take several minutes for artifacts to import. When the import completes successfully, verify artifact import by listing the repositories in the target container registry. For example, run [az acr repository show-tags](/en-us/cli/azure/acr/repository#az-acr-repository-show-tags):

```azurecli
az acr repository show-tags --name $MyRegistry --repository $MyRepository
```

## Delete ACR Transfer resources

Delete an ExportPipeline:

```azurecli
az acr export-pipeline delete --resource-group $MyRG --registry $MyReg --name $MyPipeline
```

Delete an ImportPipeline:

```azurecli
az acr import-pipeline delete --resource-group $MyRG --registry $MyReg --name $MyPipeline
```

Delete a PipelineRun resource. Note that this doesn't reverse the action taken by the PipelineRun. This is more like deleting the log of the PipelineRun.

```azurecli
az acr pipeline-run delete --resource-group $MyRG --registry $MyReg --name $MyPipelineRun
```

## ACR Transfer troubleshooting

View [ACR Transfer Troubleshooting](container-registry-transfer-troubleshooting) for troubleshooting guidance.