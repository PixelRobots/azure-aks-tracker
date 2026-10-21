---
layout: Conceptual
title: Migrate to Key Management Service (KMS) infrastructure encryption with platform-managed or customer-managed keys in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/migrate-key-management-service-platform-managed-key-customer-managed-key
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
description: Learn how to migrate from KMS v2 to KMS with infrastructure encryption platform-managed keys (PMK) or customer-managed keys (CMK) for enhanced performance and security.
ms.date: 2026-01-12T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: how-to
author: zhechengli
ms.author: zhechengli
locale: en-us
document_id: f0091cfc-f33b-f24f-4d27-5c9b4f52b047
document_version_independent_id: 99021f35-db9b-fff0-e35d-7dcd42a07a67
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/migrate-key-management-service-platform-managed-key-customer-managed-key.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/migrate-key-management-service-platform-managed-key-customer-managed-key
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/migrate-key-management-service-platform-managed-key-customer-managed-key.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 014a16fb-6cca-127a-6dae-14ba21070276
---

# Migrate to Key Management Service (KMS) infrastructure encryption with platform-managed or customer-managed keys in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Important

This article applies to clusters running Kubernetes version 1.33 or later that need to migrate from KMS v2 to the new KMS encryption experience. This experience offers platform-managed keys (PMK), customer-managed keys (CMK) with automatic key rotation, and a simplified configuration experience.

Migration from KMS v1 to platform-managed or customer-managed keys isn't supported. Upgrade to KMS v2 first.

[AKS apiserver virtual network integration](api-server-vnet-integration) is required for KMS v2 with private key vault, while it isn't required in CMK.

Any policy to block updating secrets should be disabled first because the migration process will update secrets.

In this article, you learn how to migrate from KMS v2 for clusters with version 1.33 or later. The new KMS experience provides enhanced performance and security features, including the option to use platform-managed keys that eliminate the need to manage your own Azure Key Vault.

## Prerequisites

Before starting the migration, ensure you have:

- An AKS cluster running Kubernetes version 1.33.0 or later. [To upgrade AKS](upgrade-aks-control-plane).
- Azure CLI version 2.73.0 or later. To install Azure CLI, go to [How to install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- The `aks-preview`[az extension](/en-us/cli/azure/extension) version 19.0.0b13 or later.
- For CMK migrations: User-assigned managed identity with Key Vault permissions "Key Vault Crypto User" and "Key Vault Reader".

## Migration scenarios

The new KMS experience supports two key management options:

- **Platform-managed key (PMK)**: Azure manages the encryption key automatically. No Key Vault configuration required.
- **Customer-managed key (CMK)**: You provide your own Key Vault with either public or private network access.

## Migrate from KMS v2 with public or private Key Vault to PMK

This migration path is ideal if you want to simplify your encryption setup by letting AKS manage the encryption keys. After migration, customer managed key vault and key are not used by KMS.

Enable PMK on your existing KMS v2 cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

```azurecli
az aks update \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --kms-infrastructure-encryption "Enabled" \
    --disable-azure-keyvault-kms
```

## Migrate from KMS v2 with public Key Vault to CMK

This migration path allows you to continue using your existing Key Vault while gaining the benefits of the new KMS experience, including automatic key rotation support.

1. Ensure your Key Vault has the following configuration:

    - Public network access enabled.
    - User-assigned managed identity has "Key Vault Crypto User" and "Key Vault Reader" roles.
2. Enable CMK on your existing KMS v2 cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

    ```azurecli
    az aks update \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --kms-infrastructure-encryption "Enabled"
    ```

## Migrate from KMS v2 with private Key Vault to CMK

1. Ensure your Key Vault has the following configuration:

    - Private network access enabled.
    - *Allow trusted Microsoft services to bypass this firewall* enabled.
    - User-assigned managed identity has "Key Vault Crypto User" and "Key Vault Reader" roles.
2. Enable CMK on your existing KMS v2 cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command for private Key Vault support.

    ```azurecli
    az aks update \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --kms-infrastructure-encryption "Enabled"
    ```

## Important considerations

- **No downgrade**: Once the new KMS encryption is enabled, you cannot disable it or downgrade to KMS v2.
- **Minimum version**: The new KMS experience requires Kubernetes version 1.33.0 or later.