---
layout: Conceptual
title: Customer-Managed Keys for Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/tutorial-customer-managed-keys
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
description: Learn how to encrypt your Premium container registry by using a customer-managed key stored in Azure Key Vault or Azure Key Vault Managed HSM.
ms.topic: tutorial
ms.date: 2026-10-09T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 8dd5568a-cd4e-476e-239c-a1b75bd8250a
document_version_independent_id: 06243a2a-d1a9-83ee-804c-ec0e27fac191
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/tutorial-customer-managed-keys.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/tutorial-customer-managed-keys
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/tutorial-customer-managed-keys.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: ce9ad0a6-3511-8fe7-0ff9-6b98e3984bee
---

# Customer-Managed Keys for Azure Container Registry - Azure Container Registry | Microsoft Learn

Azure Container Registry automatically encrypts images and other artifacts that you store. By default, Azure automatically encrypts the registry content at rest by using [service-managed keys](/en-us/azure/security/fundamentals/encryption-models). By using a customer-managed key, you can supplement default encryption with an additional encryption layer.

This article is part one in a four-part tutorial series. The tutorial covers:

- Overview of customer-managed keys
- Enable a customer-managed key
- Rotate and revoke a customer-managed key
- Troubleshoot a customer-managed key

## About customer-managed keys

When you use a customer-managed key, you bring your own key in [Azure Key Vault](/en-us/azure/key-vault/general/overview) or [Azure Key Vault Managed HSM](/en-us/azure/key-vault/managed-hsm/overview). When you enable a customer-managed key, you can manage its rotations, control the access and permissions to use it, and audit its use.

Key features include:

- **Regulatory compliance**: Azure automatically encrypts registry content at rest with [service-managed keys](/en-us/azure/security/fundamentals/encryption-models), but customer-managed key encryption helps you meet guidelines for regulatory compliance.
- **Integration with Azure Key Vault**: Customer-managed keys support server-side encryption through integration with [Azure Key Vault](/en-us/azure/key-vault/general/overview) and [Azure Key Vault Managed HSM](/en-us/azure/key-vault/managed-hsm/overview). You can create or import encryption keys in either key store.
- **Key lifecycle management**: Integrating customer-managed keys with Key Vault or Managed HSM gives you full control and responsibility for the key lifecycle, including rotation and management.

## Before you enable a customer-managed key

Before you configure Azure Container Registry with a customer-managed key, consider the following information:

- This feature is available in the Premium service tier for a container registry. For more information, see [Azure Container Registry service tiers](container-registry-skus).
- You can currently enable a customer-managed key only while creating a registry.
- You can't disable the encryption after you enable a customer-managed key on a registry.
- You have to configure a *user-assigned* managed identity to access the key store. Later, if required, you can enable the registry's *system-assigned* managed identity for key access.
- Azure Container Registry supports only RSA or RSA-HSM keys. Elliptic-curve keys aren't currently supported.
- A Managed HSM must be provisioned and activated before you configure it for registry encryption. For more information, see [Provision and activate a Managed HSM](/en-us/azure/key-vault/managed-hsm/quick-create-cli).
- Managed HSM uses local role-based access control (RBAC), not Key Vault access policies. Assign the registry identity the **Managed HSM Crypto Service Encryption User** role, preferably at the scope of the encryption key.
- Managed HSM availability varies by Azure cloud and region. Verify that Managed HSM is available in the location and cloud where you plan to use it.
- In a registry that's encrypted with a customer-managed key, you can retain logs for [Azure Container Registry tasks](container-registry-tasks-overview) for only 24 hours. To retain logs for a longer period, see [View and manage task run logs](container-registry-tasks-logs#alternative-log-storage).
- [Content trust](container-registry-content-trust) is currently not supported in a registry that's encrypted with a customer-managed key.

## Update the customer-managed key version

Azure Container Registry supports both automatic and manual rotation of registry encryption keys when a new key version is available in Key Vault or Managed HSM.

Important

It's an important security consideration for a registry with customer-managed key encryption to frequently update (rotate) the key versions. Follow your organization's compliance policies to regularly update key versions in the key store.

- **Automatically update the key version**: When a registry is encrypted with a non-versioned key, Azure Container Registry regularly checks the key store for a new key version and updates the customer-managed key within one hour. Omit the key version when you enable registry encryption with a customer-managed key. Azure Container Registry will then automatically use and update the latest key version.
- **Manually update the key version**: When a registry is encrypted with a specific key version, Azure Container Registry uses that version for encryption until you manually rotate the customer-managed key. We suggest that you specify the key version when you enable registry encryption with a customer-managed key. Azure Container Registry will then use a specific version of a key for registry encryption.

For details, see [Key rotation](tutorial-enable-customer-managed-keys#key-rotation) and [Update key version](tutorial-rotate-revoke-customer-managed-keys#create-or-update-the-key-version-by-using-the-azure-cli).