---
layout: Conceptual
title: Manage local accounts with Microsoft Entra integration - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/local-accounts
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
description: Learn how to managed local accounts when integrating Microsoft Entra ID in your Azure Kubernetes Service (AKS) clusters.
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2023-04-20T00:00:00.0000000Z
author: shashankbarsin
ms.author: shasb
ms.custom: devx-track-azurecli
locale: en-us
document_id: 2e6ad799-4955-03b7-61c2-59a480148759
document_version_independent_id: 5c43d91e-62b1-1bc9-651d-b6c1738e0398
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/local-accounts.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/local-accounts
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/local-accounts.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
platformId: 7de6525d-caad-1e24-a320-4f716bee8bdc
---

# Manage local accounts with Microsoft Entra integration - Azure Kubernetes Service | Microsoft Learn

When you deploy an AKS cluster, local accounts are enabled by default. Even when you enable RBAC or Microsoft Entra integration, `--admin` access still exists as a non-auditable backdoor option. This article shows you how to disable local accounts on an existing cluster, create a new cluster with local accounts disabled, and re-enable local accounts on existing clusters.

## Before you begin

- See [Microsoft Entra integration](managed-azure-ad) for an overview and setup instructions.

## Disable local accounts

You can disable local accounts using the parameter `disable-local-accounts`. The `properties.disableLocalAccounts` field has been added to the managed cluster API to indicate whether the feature is enabled or not on the cluster.

Note

- On clusters with Microsoft Entra integration enabled, users assigned to a Microsoft Entra administrators group specified by `aad-admin-group-object-ids` can still gain access using non-administrator credentials. On clusters without Microsoft Entra integration enabled and `properties.disableLocalAccounts` set to `true`, any attempt to authenticate with user or admin credentials will fail.
- After disabling local user accounts on an existing AKS cluster where users might have authenticated with local accounts, the administrator must [rotate the cluster certificates](certificate-rotation) to revoke certificates they might have had access to. If this is a new cluster, no action is required.

### Create a new cluster without local accounts

1. Create a new AKS cluster without any local accounts using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `disable-local-accounts` flag.

    ```azurecli
    az aks create \
        --resource-group <resource-group> \
        --name <cluster-name> \
        --enable-aad \
        --aad-admin-group-object-ids <aad-group-id> \
        --disable-local-accounts \
        --generate-ssh-keys
    ```
2. In the output, confirm local accounts are disabled by checking that the field `properties.disableLocalAccounts` is set to `true`.

    ```output
    "properties": {
        ...
        "disableLocalAccounts": true,
        ...
    }
    ```
3. Run the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command to ensure the cluster is set to disable local accounts.

    ```azurecli
    az aks get-credentials --resource-group <resource-group> --name <cluster-name> --admin
    ```

    Your output should show the following error message indicating the feature is preventing access:

    ```output
    Operation failed with status: 'Bad Request'. Details: Getting static credential isn't allowed because this cluster is set to disable local accounts.
    ```

### Disable local accounts on an existing cluster

1. Disable local accounts on an existing Microsoft Entra integration enabled AKS cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `disable-local-accounts` parameter.

    ```azurecli
    az aks update --resource-group <resource-group> --name <cluster-name> --disable-local-accounts
    ```
2. In the output, confirm local accounts are disabled by checking that the field `properties.disableLocalAccounts` is set to `true`.

    ```output
    "properties": {
        ...
        "disableLocalAccounts": true,
        ...
    }
    ```
3. Run the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command to ensure the cluster is set to disable local accounts.

    ```azurecli
    az aks get-credentials --resource-group <resource-group> --name <cluster-name> --admin
    ```

    Your output should show the following error message indicating the feature is preventing access:

    ```output
    Operation failed with status: 'Bad Request'. Details: Getting static credential isn't allowed because this cluster is set to disable local accounts.
    ```

### Re-enable local accounts on an existing cluster

1. Re-enable a disabled local account on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `enable-local-accounts` parameter.

    ```azurecli
    az aks update --resource-group <resource-group> --name <cluster-name> --enable-local-accounts
    ```
2. In the output, confirm local accounts are re-enabled by checking that the field `properties.disableLocalAccounts` is set to `false`.

    ```output
    "properties": {
        ...
        "disableLocalAccounts": false,
        ...
    }
    ```
3. Run the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command to ensure the cluster is set to enable local accounts.

    ```azurecli
    az aks get-credentials --resource-group <resource-group> --name <cluster-name> --admin
    ```

    Your output should show the following message indicating you have successfully enabled local accounts on the cluster:

    ```output
    Merged "<cluster-name>-admin" as current context in C:\Users\<username>\.kube\config
    ```