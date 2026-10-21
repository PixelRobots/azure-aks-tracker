---
layout: Conceptual
title: Update the Key Vault Mode for an Azure Kubernetes Service (AKS) Cluster with KMS Etcd Encryption (legacy) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/update-kms-key-vault
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
description: Learn how to update the key vault mode from public to private or private to public for an AKS cluster with Key Management Service (KMS) etcd encryption.
ms.date: 2026-05-01T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: how-to
author: shashankbarsin
ms.author: shasb
locale: en-us
document_id: 96d34eee-5b84-000b-7d52-af97b3fbe7af
document_version_independent_id: 2c47749f-c666-004c-4a95-8728019cdee2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/update-kms-key-vault.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/update-kms-key-vault
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/update-kms-key-vault.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 9538e775-10f1-e3a4-d0f0-b95d4bd95c1d
---

# Update the Key Vault Mode for an Azure Kubernetes Service (AKS) Cluster with KMS Etcd Encryption (legacy) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to update the key vault mode from public to private or private to public for an Azure Kubernetes Service (AKS) cluster with Key Management Service (KMS) etcd encryption.

## Prerequisites

- An AKS cluster with KMS etcd encryption enabled. For more information, see [Add Key Management Service (KMS) etcd encryption to an Azure Kubernetes Service (AKS) cluster](use-kms-etcd-encryption).
- Azure CLI version 2.39.0 or later. Find your version using the `az --version` command. If you need to install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).

## Update a key vault mode

Note

To change a different key vault with a different mode (whether public or private), you can run [`az aks update`](/en-us/cli/azure/aks#az-aks-update) directly. To change the mode of an attached key vault, you must first turn off KMS, then turn it on again using the new key vault IDs.

# [Update from a public to a private key vault](#tab/public-to-private)
1. Turn off KMS on the existing cluster and release the key vault using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-azure-keyvault-kms` parameter.

    ```azurecli
    az aks update --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --disable-azure-keyvault-kms
    ```

    Warning

    After you turn off KMS, the encryption key vault key is still needed. You can't delete or expire it.
2. Update all secrets using the `kubectl get secrets` command to ensure the secrets created earlier are no longer encrypted. For larger clusters, you might want to subdivide the secrets by namespace or create an update script. If the previous command to update KMS fails, still run the following command to avoid unexpected state for KMS plugin.

    ```bash
    kubectl get secrets --all-namespaces -o json | kubectl replace -f -
    ```

    When you run the command, the following error is safe to ignore:

    ```output
    The object has been modified; please apply your changes to the latest version and try again.
    ```
3. Turn on KMS with the updated private key vault using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--azure-keyvault-kms-key-vault-network-access` parameter set to `Private`.

    ```azurecli
    az aks update \
         --name $CLUSTER_NAME \
         --resource-group $RESOURCE_GROUP  \
         --enable-azure-keyvault-kms \
         --azure-keyvault-kms-key-id $KEY_ID \
         --azure-keyvault-kms-key-vault-network-access "Private" \
         --azure-keyvault-kms-key-vault-resource-id $KEY_VAULT_RESOURCE_ID
    ```
4. Update the key vault from public to private using the [`az keyvault update`](/en-us/cli/azure/keyvault#az-keyvault-update) command with the `--public-network-access` parameter set to `Disabled`.

    ```azurecli
    az keyvault update --name $KEY_VAULT --resource-group $RESOURCE_GROUP --public-network-access Disabled
    ```

# [Update from a private to a public key vault](#tab/private-to-public)
1. Turn off KMS on the existing cluster to release the key vault using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

    ```azurecli
    az aks update --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --disable-azure-keyvault-kms
    ```

    Warning

    After you turn off KMS, the encryption key vault key is still needed. You can't delete or expire it.
2. Update all secrets using the `kubectl get secrets` command to ensure the secrets created earlier are no longer encrypted. For larger clusters, you might want to subdivide the secrets by namespace or create an update script. If the previous command to update KMS fails, still run the following command to avoid unexpected state for KMS plugin.

    ```bash
    kubectl get secrets --all-namespaces -o json | kubectl replace -f -
    ```

    When you run the command, the following error is safe to ignore:

    ```output
    The object has been modified; please apply your changes to the latest version and try again.
    ```
3. Update the key vault from public to private using the [`az keyvault update`](/en-us/cli/azure/keyvault#az-keyvault-update) command with the `--public-network-access` parameter set to `Enabled`.

    ```azurecli
    az keyvault update --name $KEY_VAULT --resource-group $RESOURCE_GROUP --public-network-access Enabled
    ```
4. Turn on KMS with the updated private key vault using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--azure-keyvault-kms-key-vault-network-access` parameter set to `Public`.

    ```azurecli
    az aks update \
         --name $CLUSTER_NAME \
         --resource-group $RESOURCE_GROUP  \
         --enable-azure-keyvault-kms \
         --azure-keyvault-kms-key-id $KEY_ID \
         --azure-keyvault-kms-key-vault-network-access "Public" \
         --azure-keyvault-kms-key-vault-resource-id $KEY_VAULT_RESOURCE_ID
    ```

---