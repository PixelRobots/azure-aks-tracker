---
layout: Conceptual
title: Data encryption at rest concepts for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kms-data-encryption-concepts
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
description: Learn about encryption at rest for Kubernetes secrets in Azure Kubernetes Service (AKS) using Azure Key Vault and the KMS provider.
ms.date: 2025-12-19T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: concept-article
author: shashankbarsin
ms.author: shasb
locale: en-us
document_id: f187940b-513e-6eee-8b54-e6d235ed8f53
document_version_independent_id: 1f9aee0b-e0f4-e8d8-66ba-3494c249d1f5
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kms-data-encryption-concepts.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/kms-data-encryption-concepts
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kms-data-encryption-concepts.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 38def3d7-764b-304f-7ee0-9ee39f821e42
---

# Data encryption at rest concepts for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) stores sensitive data such as Kubernetes secrets in etcd, the distributed key-value store used by Kubernetes. For enhanced security and compliance requirements, AKS supports encryption of Kubernetes secrets at rest using the Kubernetes Key Management Service (KMS) provider integrated with Azure Key Vault.

This article explains the key concepts, encryption models, and key management options available for protecting Kubernetes secrets at rest in AKS.

## Understanding data encryption at rest

Data encryption at rest protects your data when it's stored on disk. Without encryption at rest, an attacker who gains access to the underlying storage could potentially read sensitive data like Kubernetes secrets.

AKS provides encryption for Kubernetes secrets stored in etcd:

| Layer | Description |
| --- | --- |
| **Azure platform encryption** | Azure Storage automatically encrypts all data at rest using 256-bit AES encryption. This encryption is always enabled and transparent to users. |
| **KMS provider encryption** | An optional layer that encrypts Kubernetes secrets before they're written to etcd using keys stored in Azure Key Vault. |

For more information about Azure's encryption at rest capabilities, see [Azure data encryption at rest](/en-us/azure/security/fundamentals/encryption-atrest) and [Azure encryption models](/en-us/azure/security/fundamentals/encryption-models).

## KMS provider for data encryption

The [Kubernetes KMS provider](https://kubernetes.io/docs/tasks/administer-cluster/kms-provider/) is a mechanism that enables encryption of Kubernetes secrets at rest using an external key management system. AKS integrates with Azure Key Vault to provide this capability, giving you control over encryption keys while maintaining the security benefits of a managed Kubernetes service.

### How KMS encryption works

When you enable KMS for an AKS cluster:

1. **Secret creation**: When a secret is created, the Kubernetes API server sends the secret data to the KMS provider plugin.
2. **Encryption**: The KMS plugin encrypts the secret data using a Data Encryption Key (DEK), which is itself encrypted using a Key Encryption Key (KEK) stored in Azure Key Vault.
3. **Storage**: The encrypted secret is stored in etcd.
4. **Secret retrieval**: When a secret is read, the KMS plugin decrypts the DEK using the KEK from Azure Key Vault, then uses the DEK to decrypt the secret data.

This envelope encryption approach provides both security and performance benefits. The DEK handles frequent encryption operations locally while the KEK in Azure Key Vault provides the security of a hardware-backed key management system.

## Key management options

AKS offers two key management options for KMS encryption:

### Platform-managed keys (PMK)

With platform-managed keys, AKS automatically manages the encryption keys for you:

- AKS creates and manages the encryption keys.
- Key rotation is handled automatically by the platform.
- No additional configuration or key vault setup is required.

**When to use platform-managed keys:**

- You want the simplest setup with minimal configuration.
- You don't have specific regulatory requirements that mandate customer-managed keys.
- You want automatic key rotation without manual intervention.

### Customer-managed keys (CMK)

With customer-managed keys, you have full control over the encryption keys:

- You create and manage your own Azure Key Vault and encryption keys.
- You control key rotation schedules and policies.

**When to use customer-managed keys:**

- You have regulatory or compliance requirements that mandate customer-managed keys.
- You need to control the key lifecycle, including rotation schedules and key versions.
- You require audit logs for all key operations.

### Key vault network access options

When using customer-managed keys, you can configure the network access for your Azure Key Vault:

| Network access | Description | Use case |
| --- | --- | --- |
| **Public** | Key vault is accessible over the public internet with authentication. | Development environments, simpler setup |
| **Private** | Key vault has public network access disabled. AKS accesses the key vault through the [trusted services firewall exception](/en-us/azure/key-vault/general/network-security#key-vault-firewall-enabled-trusted-services-only). | Production environments, enhanced security |

## Comparing encryption key options

| Feature | Platform-managed keys | Customer-managed keys (Public) | Customer-managed keys (Private) |
| --- | --- | --- | --- |
| **Key ownership** | Microsoft manages | Customer manages | Customer manages |
| **Key rotation** | Automatic | [User configurable](/en-us/azure/key-vault/keys/how-to-configure-key-rotation) | [User configurable](/en-us/azure/key-vault/keys/how-to-configure-key-rotation) |
| **Key vault creation** | Automatic | Customer creates | Customer creates |
| **Network isolation** | N/A | No | Yes |

## Requirements

- The new [KMS encryption with platform-managed keys or customer-managed keys with automatic key rotation](kms-data-encryption) experience requires **Kubernetes version 1.33 or later**.
- The new [KMS encryption with platform-managed keys or customer-managed keys with automatic key rotation](kms-data-encryption) experience is only supported on AKS clusters where [managed identity is used for the cluster's identity](use-managed-identity).

## Limitations

- **No downgrade**: After enabling the new KMS encryption experience, you can't disable the feature.
- **Key deletion**: Deleting the encryption key or key vault makes your secrets unrecoverable.
- **Private endpoint access**: Key vault access using [private link/endpoint](/en-us/azure/key-vault/general/private-link-service) isn't yet supported. For private key vaults, use the [trusted services firewall exception](/en-us/azure/key-vault/general/network-security#key-vault-firewall-enabled-trusted-services-only).