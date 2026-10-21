---
layout: Conceptual
title: Rotate and Revoke a Key for Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/tutorial-rotate-revoke-customer-managed-keys
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
description: Learn how to rotate, update, and revoke a customer-managed key on Azure Container Registry to ensure secure and continuous access to your registry data.
ms.topic: tutorial
ms.date: 2026-10-09T00:00:00.0000000Z
ai-usage: ai-assisted
ms.custom: subject-rbac-steps, devx-track-azurecli
locale: en-us
document_id: 73a249d9-e679-d0d2-1c48-88d40d917285
document_version_independent_id: d20cb3a0-b80c-c9bb-5551-5eec324f03d2
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/tutorial-rotate-revoke-customer-managed-keys.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/tutorial-rotate-revoke-customer-managed-keys
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/tutorial-rotate-revoke-customer-managed-keys.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: d20c12a3-7704-b13a-0af5-b5b1b53ce8f1
---

# Rotate and Revoke a Key for Azure Container Registry - Azure Container Registry | Microsoft Learn

This article is part three in a four-part tutorial series. [Part one](tutorial-customer-managed-keys) provides an overview of customer-managed keys, their features, and considerations before you enable one on your registry. In [part two](tutorial-enable-customer-managed-keys), you learn how to enable a customer-managed key by using the Azure CLI, the Azure portal, or an Azure Resource Manager template. This article walks you through rotating, updating, and revoking a customer-managed key.

## Rotate a customer-managed key

To rotate a key, you can either update the key version in Azure Key Vault or Azure Key Vault Managed HSM, or create a new key. While rotating the key, you can specify the same identity that you used to create the registry.

Optionally, you can:

- Configure a new user-assigned identity to access the key.
- Enable and specify the registry's system-assigned identity.

Note

To enable the registry's system-assigned identity in the portal, select **Settings** &gt; **Identity** and set the system-assigned identity's status to **On**.

Ensure that the identity has the required access to the key store. For a key vault, see [Enable managed identities to access the key vault](tutorial-enable-customer-managed-keys#enable-managed-identities-to-access-the-key-vault). For Managed HSM, assign the **Managed HSM Crypto Service Encryption User** local RBAC role at the key scope.

### Create or update the key version by using the Azure CLI

To create a new key version in a key vault, run the [az keyvault key create](/en-us/cli/azure/keyvault/key#az-keyvault-key-create) command:

```azurecli
# Create new version of existing key
az keyvault key create \
  --name <key-name> \
  --vault-name <key-vault-name>
```

To create a new key version in Managed HSM, use the `--hsm-name` parameter:

```azurecli
az keyvault key create \
  --name <key-name> \
  --hsm-name <managed-hsm-name> \
  --kty RSA-HSM \
  --ops wrapKey unwrapKey
```

If you configure the registry to detect key version updates, the customer-managed key is automatically updated within one hour, whether the key is stored in Key Vault or Managed HSM.

If you configure the registry for manual updating for a new key version, run the [az-acr-encryption-rotate-key](/en-us/cli/azure/acr/#az-acr-encryption-rotate-key) command. Pass the new key ID and the identity that you want to configure.

Tip

When you run `az-acr-encryption-rotate-key`, you can pass either a versioned key ID or an unversioned key ID. If you use an unversioned key ID, the registry is then configured to automatically detect later key version updates.

To update a customer-managed key version manually, you have three options:

- Rotate the key and use a client ID of a managed identity.

If you're using a key from a different key vault, verify that the identity has the `get`, `wrap`, and `unwrap` permissions. For Managed HSM, verify that the identity has the **Managed HSM Crypto Service Encryption User** role at the key scope.

```azurecli
az acr encryption rotate-key \
  --name <registry-name> \
  --key-encryption-key <new-key-id> \
  --identity <client ID of a managed identity>
```

- Rotate the key and use a user-assigned identity.

Before you use the user-assigned identity, verify that the required Key Vault permissions or Managed HSM local RBAC role is assigned to it.

```azurecli
az acr encryption rotate-key \
  --name <registry-name> \
  --key-encryption-key <new-key-id> \
  --identity <id of user assigned identity>
```

- Rotate the key and use a system-assigned identity.

Before you use the system-assigned identity, verify that the required Key Vault permissions or Managed HSM local RBAC role is assigned to it.

```azurecli
az acr encryption rotate-key \
  --name <registry-name> \
  --key-encryption-key <new-key-id> \
  --identity [system]
```

### Create or update the key version by using the Azure portal

Use the registry's **Encryption** settings to update the Key Vault or Managed HSM key and identity settings for a customer-managed key.

For example, to configure a new key:

1. In the portal, go to your registry.
2. Under **Settings**, select **Encryption** &gt; **Change key**.

    ![Screenshot of encryption key options in the Azure portal.](media/container-registry-customer-managed-keys/rotate-key.png)
3. In **Encryption**, choose one of the following options:

    - Choose **Select from Key Vault**, and then select an existing key vault or Managed HSM and a key. Select **Create new** to create a key vault and key. The key that you select is unversioned and enables automatic key rotation.
    - Select **Enter key URI**, and provide a Key Vault or Managed HSM key identifier directly. You can provide either a versioned key URI (for a key that you must rotate manually) or an unversioned key URI (which enables automatic key rotation).
4. Complete the key selection, and then select **Save**.

## Revoke a customer-managed key

You can revoke a customer-managed encryption key by removing the registry identity's access to the key or by deleting the key.

### Revoke access to a key in a key vault

To change the access policy of the managed identity that your registry uses, run the [az-keyvault-delete-policy](/en-us/cli/azure/keyvault#az-keyvault-delete-policy) command:

```azurecli
az keyvault delete-policy \
  --resource-group <resource-group-name> \
  --name <key-vault-name> \
  --object-id <identity-principal-id>
```

If the key vault uses Azure RBAC instead of access policies, remove the applicable Key Vault role assignment.

### Revoke access to a key in Managed HSM

Managed HSM doesn't support Key Vault access policies. Remove the local RBAC assignment for the registry identity. Use the same scope where you created the assignment. The following example removes a key-scoped assignment:

```azurecli
az keyvault role assignment delete \
  --hsm-name <managed-hsm-name> \
  --role "Managed HSM Crypto Service Encryption User" \
  --assignee-object-id <identity-principal-id> \
  --scope /keys/<key-name>
```

An assignment created at `/keys` or `/` isn't removed by a command that specifies `/keys/<key-name>`.

### Delete the encryption key

To delete a key from a key vault, run the [az-keyvault-key-delete](/en-us/cli/azure/keyvault/key#az-keyvault-key-delete) command. This operation requires the *keys/delete* permission.

```azurecli
az keyvault key delete \
  --vault-name <key-vault-name> \
  --name <key-name>
```

To delete a key from Managed HSM, use the `--hsm-name` parameter:

```azurecli
az keyvault key delete \
  --hsm-name <managed-hsm-name> \
  --name <key-name>
```

Note

Revoking a customer-managed key will block access to all registry data. If you enable access to the key or restore a deleted key, the registry will pick the key, and you can regain control of access to the encrypted registry data.