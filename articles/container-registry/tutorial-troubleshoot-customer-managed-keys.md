---
layout: Conceptual
title: Troubleshoot Customer-Managed Keys in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/tutorial-troubleshoot-customer-managed-keys
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
description: Learn how to troubleshoot the most common problems for a registry that's enabled with a customer-managed key.
ms.topic: tutorial
ms.date: 2026-10-09T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 03257e11-5a28-8fd8-f638-a765923bfcc7
document_version_independent_id: 5b3d2243-3cb3-8b7a-8fa8-9daa7d18391a
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/tutorial-troubleshoot-customer-managed-keys.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: container-registry/tutorial-troubleshoot-customer-managed-keys
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/tutorial-troubleshoot-customer-managed-keys.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
platformId: 8a34eb66-f96a-c12d-2a21-b4956c181b23
---

# Troubleshoot Customer-Managed Keys in Azure Container Registry - Azure Container Registry | Microsoft Learn

This article is part four in a four-part tutorial series. [Part one](tutorial-customer-managed-keys) provides an overview of customer-managed keys, their features, and considerations before you enable one on your registry. In [part two](tutorial-enable-customer-managed-keys), you learn how to enable a customer-managed key by using the Azure CLI, the Azure portal, or an Azure Resource Manager template. In [part three](tutorial-rotate-revoke-customer-managed-keys), you learn how to rotate, update, and revoke a customer-managed key. This article helps you troubleshoot and resolve common problems with customer-managed keys.

## Error when you're removing a managed identity

If you try to remove a user-assigned or system-assigned managed identity that you used to configure encryption for your registry, you might see an error:

```
Azure resource '/subscriptions/xxxx/resourcegroups/myGroup/providers/Microsoft.ContainerRegistry/registries/myRegistry' does not have access to identity 'xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx' Try forcibly adding the identity to the registry <registry name>. For more information on bring your own key, please visit 'https://aka.ms/acr/cmk'.
```

You're unable to change (rotate) the encryption key. The resolution steps depend on the type of identity that you used for encryption.

### Removing a user-assigned identity

If you get the error when you try to remove a user-assigned identity, follow these steps:

1. Reassign the user-assigned identity by using the [az acr identity assign](/en-us/cli/azure/acr/identity/#az-acr-identity-assign) command.
2. Pass the user-assigned identity's resource ID, or use the identity's name when it's in the same resource group as the registry.

    For example:

    ```azurecli
    az acr identity assign -n myRegistry \
        --identities "/subscriptions/mysubscription/resourcegroups/myresourcegroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myidentity"
    ```
3. Change the key and assign a different identity.
4. Now, you can remove the original user-assigned identity.

### Removing a system-assigned identity

If you get the error when you try to remove a system-assigned identity, [create an Azure support ticket](https://azure.microsoft.com/support/create-ticket/) for assistance in restoring the identity.

## Error after you enable a key store firewall

If you enable a Key Vault or Managed HSM firewall, virtual network, or private endpoint after creating an encrypted registry, you might see HTTP 403 or other errors with image import or automated key rotation. Ensure that the key store's network configuration allows Azure Container Registry to reach the key. For Managed HSM networking options, see [Network security for Managed HSM](/en-us/azure/key-vault/managed-hsm/network-security).

If Azure Container Registry can access the Managed HSM but the portal key picker can't list keys, ensure that your client is inside the configured network boundary or use **Enter key URI**. Trusted-services bypass doesn't grant portal clients access through the Managed HSM firewall.

After you correct the network configuration, reconfigure the managed identity and key that you initially used for encryption. See the steps in [Rotate a customer-managed key](tutorial-rotate-revoke-customer-managed-keys#rotate-a-customer-managed-key).

If the problem persists, contact Azure Support.

## Error when you use a Managed HSM key

Check the following requirements if registry creation, key rotation, or image operations fail when the encryption key is stored in Managed HSM:

- The Managed HSM is provisioned and activated. Data-plane operations, including key creation and role assignment, are unavailable until activation is complete.
- The key is an RSA-HSM key that supports the `wrapKey` and `unwrapKey` operations.
- The registry's managed identity has the **Managed HSM Crypto Service Encryption User** local RBAC role. For the least privilege, assign the role at `/keys/<key-name>`.
- The key URI uses HTTPS and has the format `https://<managed-hsm-name>.<managed-hsm-dns-suffix>/keys/<key-name>` or `https://<managed-hsm-name>.<managed-hsm-dns-suffix>/keys/<key-name>/<version>`.
- The URI identifies a key. URIs for secrets, certificates, or other Managed HSM object paths aren't supported.

To verify the role assignment for a specific key, run:

```azurecli
az keyvault role assignment list \
  --hsm-name <managed-hsm-name> \
  --assignee-object-id <identity-principal-id> \
  --role "Managed HSM Crypto Service Encryption User" \
  --scope /keys/<key-name>
```

Managed HSM local RBAC changes can take several minutes to propagate. If the role assignment is correct but validation still fails, wait for propagation and retry the registry operation.

## Identity expiry error

The identity attached to a registry is set for autorenewal to avoid expiry. If you disassociate an identity from a registry, an error message occurs explaining to you can't remove the identity in use for CMK. Attempting to remove the identity jeopardizes the autorenewal of identity. The artifact pull/push operations work until the identity expires (Usually three months). After the identity expiration, you'll see the HTTP 403 with an error message "The identity associated with the registry is inactive. This could be due to attempted removal of the identity. Reassign the identity manually".

You have to reassign the identity back to registry explicitly.

1. Run the [az acr identity assign](/en-us/cli/azure/acr/identity/#az-acr-identity-assign) command to reassign the identity manually.

    - For example,

    ```azurecli
    az acr identity assign -n myRegistry \
    --identities "/subscriptions/mysubscription/resourcegroups/myresourcegroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myidentity"
    ```

## Accidental deletion of a key store or key

Deletion of the Key Vault or Managed HSM resource, or the key that you use to encrypt a registry, makes the registry's content inaccessible. If you enable [soft delete](/en-us/azure/key-vault/general/soft-delete-overview) in a key vault, you can recover the deleted vault or key vault object and resume registry operations. Managed HSM also supports soft-delete recovery, but it continues to incur charges while it's in a soft-deleted state.

## Azure Policy remediation fails on a customer-managed key registry

An Azure Policy assignment with a **Modify** effect (for example, the built-in policy [**`Configure container registries to disable ARM audience token authentication.`**](container-registry-disable-authentication-as-arm)) can fail to automatically remediate a registry that's encrypted with a customer-managed key. The remediation task fails, and the registry stays noncompliant. The remediation deployment reports a `BadRequest` error similar to the following:

```output
Invalid encryption key vault property specified for registry <registry-name>. Property Identity and KeyIdentifier must be set when encryption is enabled. For more information on customer-managed keys, please visit 'https://aka.ms/acr/cmk'.
```

This error is a known limitation: automatic **Modify** remediation isn't currently supported on registries that are encrypted with a customer-managed key. The remediation can't preserve the protected key vault settings when it resubmits the registry configuration, so the registry rejects the update with the preceding error and stays noncompliant.

To bring the registry into compliance, set the property that the policy targets directly instead of relying on automatic remediation. Setting the property directly changes only that one setting and leaves the encryption configuration untouched, so the registry accepts the update. Use the command that corresponds to the policy you're remediating.

For the **`Configure container registries to disable ARM audience token authentication.`** policy, run:

```azurecli
az acr config authentication-as-arm update \
    -r myregistry \
    --resource-group myResourceGroup \
    --status disabled
```

After you run the command, trigger a policy compliance scan or wait for the next evaluation. The registry then reports as compliant. The automatic remediation task might still show a *Failed* status for registries that are encrypted with a customer-managed key. That status doesn't affect the registry's compliance after you set the property directly.