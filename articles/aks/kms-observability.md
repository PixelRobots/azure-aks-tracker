---
layout: Conceptual
title: Observability for Azure Kubernetes Service (AKS) Clusters with Key Management Service (KMS) Etcd Encryption (legacy) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kms-observability
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
description: Learn how to view observability metrics and improve observability for AKS clusters with KMS etcd encryption.
ms.date: 2025-12-22T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: how-to
author: shashankbarsin
ms.author: shasb
locale: en-us
document_id: 002cec0a-4a4b-5343-12e0-1115d23bab47
document_version_independent_id: 094472e6-5cca-4fce-3940-41b0ad3c1375
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kms-observability.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/kms-observability
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kms-observability.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 3799c16f-f2a2-e846-9964-9c9557c2a7f1
---

# Observability for Azure Kubernetes Service (AKS) Clusters with Key Management Service (KMS) Etcd Encryption (legacy) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to view observability metrics and improve observability for AKS clusters with KMS etcd encryption.

## Prerequisites

- An AKS cluster with KMS etcd encryption enabled. For more information, see [Add Key Management Service (KMS) etcd encryption to an Azure Kubernetes Service (AKS) cluster](use-kms-etcd-encryption).
- You must enable [diagnostic settings for the key vault to check the encryption logs](/en-us/azure/key-vault/general/howto-logging).

## Check the KMS config

# [Azure CLI](#tab/azure-cli)
- Get the KMS config using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --query "securityProfile.azureKeyVaultKms"
    ```

    The output looks similar to the following example output:

    ```output
    ...
    "securityProfile": {
      "azureKeyVaultKms": {
        "enabled": true,
        "keyId": "https://<key-vault-name>.vault.azure.net/keys/<key-name>/<key-id>",
        "keyVaultNetworkAccess": "Public",
        "keyVaultResourceId": <key-vault-resource-id>
    ...
    ```

# [Azure portal](#tab/azure-portal)
1. In the Azure portal, navigate to your AKS cluster resource.
2. From the service menu, select **Diagnose and solve problems**.
3. In the search bar, search for **KMS** and select **Azure KeyVault KMS Integration Issues**.

    In the **Cluster is configured to use Azure KeyVault KMS Integration** section, you can see if KMS is enabled and the key ID, as shown in the following screenshot:

    ![Screenshot of the KMS config information in the Azure portal.](media/kms-observability/portal-kms-config.png)

    For more information about your key vault, you can navigate to the key vault resource.

---

## Diagnose and solve problems

Because the KMS plugin is a sidecar of `kube-apiserver` pod, you can't access it directly. To improve the observability of KMS, you can check the KMS status using the Azure portal.

1. In the Azure portal, navigate to your AKS cluster.
2. From the service menu, select **Diagnose and solve problems**.
3. In the search bar, search for **KMS** and select **Azure KeyVault KMS Integration Issues**.

### Example problem

Let's say you see the following issue: `KeyExpired: Operation encrypt isn't allowed on an expired key`.

Because the AKS KMS plugin currently only allows bring your own (BYO) key vault and key, it's your responsibility to manage the key lifecycle. If the key is expired, the KMS plugin fails to decrypt the existing secrets. To resolve this issue, you need to *extend the key expiration date* to make KMS work and *rotate the key version*.