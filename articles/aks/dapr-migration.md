---
layout: Conceptual
title: Migrate from Dapr OSS to the Dapr Extension for AKS - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/dapr-migration
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
description: Learn how to migrate your managed clusters from Dapr OSS to the Dapr extension for Azure Kubernetes Service (AKS).
author: shivamkm07
ms.author: shivamkumar
ms.reviewer: ramithar
ms.topic: how-to
ms.date: 2026-02-06T00:00:00.0000000Z
ms.subservice: dapr-aks
ms.custom: devx-track-azurecli
locale: en-us
document_id: 6c4c36bb-e31b-8472-4177-33e4871873a2
document_version_independent_id: 796c81e8-08b2-94bd-2b86-38d1b139bb57
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/dapr-migration.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/dapr-migration
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/dapr-migration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 9b2bc133-9823-fa1a-6e92-6ab175988b4e
---

# Migrate from Dapr OSS to the Dapr Extension for AKS - Azure Kubernetes Service | Microsoft Learn

This article shows you how to migrate from Dapr OSS to the Dapr extension for AKS.

You can configure the Dapr extension to use and manage the Kubernetes resources created by Dapr OSS by either:

- Checking for an existing Dapr installation by using the Azure CLI (*default method*)
- Configuring the existing Dapr installation by using `--configuration-settings`

For more information, see [an overview of the Dapr extension for AKS](dapr-overview).

## Check for an existing Dapr installation

When you [install the Dapr extension](dapr), the extension checks for an existing Dapr installation on your cluster. If Dapr exists, the extension uses and manages the Kubernetes resources created by Dapr OSS.

1. List the details of your current Dapr installation using the `helm list -A` command and save the Dapr release name and namespace from the output.

    ```azurecli
    helm list -A
    ```
2. Enter the Helm release name and namespace (from `helm list -A`) when prompted with the following questions:

    ```azurecli
    Enter the Helm release name for Dapr, or press Enter to use the default name [dapr]:
    Enter the namespace where Dapr is installed, or press Enter to use the default namespace [dapr-system]:
    ```

## Configure the existing Dapr installation using `--configuration-settings`

When you [create the Dapr extension](dapr), you can configure the extension to use and manage the Kubernetes resources created by Dapr OSS using the `--configuration-settings` flag.

1. List the details of your current Dapr installation using the `helm list -A` command and save the Dapr release name and namespace from the output.

    ```azurecli
    helm list -A
    ```
2. Create the Dapr extension by using [`az k8s-extension create`](/en-us/cli/azure/k8s-extension#az-k8s-extension-create) and use the `--configuration-settings` flags to set the Dapr release name and namespace.

    ```azurecli
    az k8s-extension create --cluster-type managedClusters \
    --cluster-name <your-AKS-cluster> \
    --resource-group <your-resource-group> \
    --name dapr \
    --extension-type Microsoft.Dapr \
    --configuration-settings "existingDaprReleaseName=dapr" \
    --configuration-settings "existingDaprReleaseNamespace=dapr-system"
    ```

## Update high availability (HA) mode or placement service settings

When installing the Dapr extension on top of an existing Dapr installation, you receive the following message:

```output
The extension will be installed on your existing Dapr installation. Note, if you have updated the default values for global.ha.* or dapr_placement.* in your existing Dapr installation, you must provide them in the configuration settings. Failing to do so will result in an error, since Helm upgrade will try to modify the StatefulSet. See <link> for more information.
```

Kubernetes only allows patching for limited fields in StatefulSets. If any of the HA mode or placement service settings are configured, the upgrade fails. To update the HA mode or placement service settings, you must delete the stateful set and then update the HA mode.

1. Delete the stateful set using the `kubectl delete` command.

    ```azurecli
    kubectl delete statefulset.apps/dapr-placement-server -n dapr-system
    ```
2. Update the HA mode using the [`az k8s-extension update`](/en-us/cli/azure/k8s-extension#az-k8s-extension-update) command.

    ```azurecli
    az k8s-extension update --cluster-type managedClusters \
    --cluster-name <your-AKS-cluster> \
    --resource-group <your-resource-group> \
    --name dapr \
    --extension-type Microsoft.Dapr \
    --auto-upgrade-minor-version true \  
    --configuration-settings "global.ha.enabled=true" \    
    ```

For more information, see the [Dapr production guidelines](https://docs.dapr.io/operations/hosting/kubernetes/kubernetes-production/#enabling-high-availability-in-an-existing-dapr-deployment).