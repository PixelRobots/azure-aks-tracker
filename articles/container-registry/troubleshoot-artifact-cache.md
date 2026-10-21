---
layout: Conceptual
title: Troubleshoot artifact cache issues in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/troubleshoot-artifact-cache
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
description: Learn how to troubleshoot the most common problems for a registry that uses the Artifact cache feature.
ms.topic: troubleshooting
ms.date: 2025-04-23T00:00:00.0000000Z
locale: en-us
document_id: c7e30d4d-c2f9-8838-6845-f6548b79c9b9
document_version_independent_id: 107346b1-7c78-b75d-b7a1-12d915896b4a
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/troubleshoot-artifact-cache.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: container-registry/troubleshoot-artifact-cache
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/troubleshoot-artifact-cache.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 1e2ef46b-6055-b8b4-d889-09381ee7e19b
---

# Troubleshoot artifact cache issues in Azure Container Registry - Azure Container Registry | Microsoft Learn

Learn how to solve the most common problems for a registry enabled with the artifact cache feature by identifying symptoms, causes, and potential solutions.

## Unhealthy credentials

Credentials are a set of Azure Key Vault secrets that operate as a username and password for private repositories. Unhealthy credentials can occur when these secrets are no longer valid. In the Azure portal, you can select the credentials to edit and apply changes.

Verify that secrets in Azure Key Vault are valid, and that access to the Azure Key Vault is assigned.

To assign access to Azure Key Vault, run the following command:

```azurecli
az keyvault set-policy --name myKeyVaultName --object-id myObjID --secret-permissions get
```

For more information, see [Key Vaults](/en-us/azure/key-vault/secrets/quick-create-portal) and [Assigning access to Azure Key Vault](/en-us/azure/key-vault/general/assign-access-policy#assign-an-access-policy).

### Unable to create a cache rule

If you're unable to create a cache rule, you may have hit the cache rule limit, or your rule might have a conflict with an existing rule.

## Cache rule limit issues

You may face issues while creating a cache rule if you exceed the limit of 1,000 cache rules.

If you hit this limit, delete any cache rules that are no longer needed.

## Unable to create cache rule using a wildcard

If a cache rule you're trying to create conflicts with an existing rule, you see an error message explaining there's already a cache rule with a wildcard for the specified target repository.

To resolve this issue, follow these steps:

1. Identify which existing cache rule is causing the conflict. Look for an existing rule that uses a wildcard (\*) for the target repository.
2. Delete the conflicting cache rule that overlaps with the source repository and wildcard.
3. Create a new cache rule with the desired wildcard and target repository.
4. Double-check your cache configuration to ensure that the new rule is correctly applied and there are no other conflicting rules.

For more information about wildcards and potential conflicts, see [Wildcard support for artifact cache in Azure Container Registry](wildcards-artifact-cache).

## Supported upstream repositories

Be sure your upstream repository is supported. For more information, see [Upstream support](artifact-cache-overview#upstream-support).