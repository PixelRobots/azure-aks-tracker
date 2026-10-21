---
layout: Conceptual
title: Migrate to Key Management Service (KMS) v2 in Azure Kubernetes Service (AKS) (legacy) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-kms-v2
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
description: Learn how to migrate to KMS v2 for clusters with versions older than 1.27.
ms.date: 2025-12-22T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: how-to
author: shashankbarsin
ms.author: shasb
locale: en-us
document_id: 128f98fb-e04f-5681-23e2-118b422a11c0
document_version_independent_id: 48e9b07a-92b2-2758-fff3-35cea3b97fdf
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-kms-v2.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-kms-v2
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-kms-v2.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 4f09dc07-2b3a-72dd-f71d-4f25db86f2fe
---

# Migrate to Key Management Service (KMS) v2 in Azure Kubernetes Service (AKS) (legacy) - Azure Kubernetes Service | Microsoft Learn

Important

This article applies to clusters using the legacy KMS experience that need to migrate from KMS v1 to KMS v2. For clusters running Kubernetes version 1.33 or later, we recommend using the new [KMS data encryption](kms-data-encryption) experience, which offers platform-managed keys, customer-managed keys with automatic key rotation, and a simplified configuration experience.

In this article, you learn how to migrate to KMS v2 for clusters with versions older than 1.27. Beginning in AKS version 1.27, turning on the KMS feature configures KMS v2. With KMS v2, you aren't limited to the 2,000 secrets that earlier versions support. For more information, see [KMS v2 improvements](https://kubernetes.io/blog/2023/05/16/kms-v2-moves-to-beta/).

Important

If your cluster version is older than 1.27 and you already turned on KMS, the upgrade to cluster version 1.27 or later is blocked.

## Turn off KMS

1. Disable KMS on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-azure-keyvault-kms` parameter.

    ```azurecli
    az aks update --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --disable-azure-keyvault-kms
    ```
2. Update all secrets using the `kubectl get secrets` command to ensure the secrets created earlier are no longer encrypted. For larger clusters, you might want to subdivide the secrets by namespace or create an update script. If the previous command to update KMS fails, still run the following command to avoid unexpected state for KMS plugin.

    ```bash
    kubectl get secrets --all-namespaces -o json | kubectl replace -f -
    ```

    When you run the command, the following error is safe to ignore:

    ```output
    The object has been modified; please apply your changes to the latest version and try again.
    ```

## Upgrade your AKS cluster and turn on KMS

1. Upgrade your AKS cluster to version 1.27 or later using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command with the `--kubernetes-version` parameter set to your desired version. The following example upgrades to version `1.27.1`:

    ```azurecli
    az aks upgrade --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --kubernetes-version 1.27.1
    ```
2. Once the upgrade completes, you can turn on KMS for a public or private key vault using one of the following resources:

    - [Enable a public key vault and KMS on an existing AKS cluster](use-kms-etcd-encryption#enable-a-public-key-vault-and-kms-on-an-existing-aks-cluster)
    - [Update an existing AKS cluster to turn on KMS etcd encryption for a private key vault](use-kms-etcd-encryption#update-an-existing-aks-cluster-to-turn-on-kms-etcd-encryption-for-a-private-key-vault)
3. Update all secrets using the `kubectl get secrets` command to ensure the secrets created earlier are no longer encrypted. For larger clusters, you might want to subdivide the secrets by namespace or create an update script. If the previous command to update KMS fails, still run the following command to avoid unexpected state for KMS plugin.

    ```bash
    kubectl get secrets --all-namespaces -o json | kubectl replace -f -
    ```

    When you run the command, the following error is safe to ignore:

    ```output
    The object has been modified; please apply your changes to the latest version and try again.
    ```