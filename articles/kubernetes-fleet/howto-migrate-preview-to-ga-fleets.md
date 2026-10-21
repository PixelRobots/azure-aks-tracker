---
layout: Conceptual
title: Migrate Azure Kubernetes Fleet Manager preview instances to a supported state | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-migrate-preview-to-ga-fleets
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
learn_banner_products:
- azure
description: Quickly identify if an instance of Kubernetes Fleet Manager was created using preview custom resource APIs.
ms.date: 2025-04-09T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: how-to
locale: en-us
document_id: 52cb7814-f5f8-887d-5ee8-a48ba9c70aa8
document_version_independent_id: 42082d20-7920-0c03-7851-138489b9ab72
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-migrate-preview-to-ga-fleets.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-migrate-preview-to-ga-fleets
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-migrate-preview-to-ga-fleets.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 19f9c3a0-f108-7ecd-5475-3947af273777
---

# Migrate Azure Kubernetes Fleet Manager preview instances to a supported state | Microsoft Learn

During the preview stage of Azure Kubernetes Fleet Manager (Kubernetes Fleet), an internal custom resource definition (CRD) API change was made that impacts a small number Kubernetes Fleet instances created during the service public preview.

Microsoft notified affected Kubernetes Fleet users who can use this article to help identify Kubernetes Fleet instances affected by the change.

The Kubernetes Fleet Custom Resource Definitions (CRDs) API change is shown in the table.

| Old API definition (unsupported) | New API definition (supported) |
| --- | --- |
| memberclusters.fleet.azure.com/v1alpha1 | memberclusters.cluster.kubernetes-fleet.io/v1 |
| internalmemberclusters.fleet.azure.com/v1alpha1 | internalmemberclusters.cluster.kubernetes-fleet.io/v1 |

As of March 2025, the old API definitions no longer receive support or updates and will be removed from platform deployments.

Administrators with affected Kubernetes Fleet instances need to create a new Kubernetes Fleet instance and manually transfer member clusters. This is a one-time activity.

## Prerequisites

- The user undertaking this activity must be assigned the `Azure Kubernetes Fleet Manager RBAC Cluster Admin` Entra ID role.
- You need Azure CLI version 2.70.0 or later installed. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need the `fleet` Azure CLI extension version 1.5.0 or later, which you can install by running the following command:

    ```azurecli
    az extension add --name fleet
    ```

    Run the following command to update to the latest version of the extension released:

    ```azurecli
    az extension update --name fleet
    ```

## Identify affected instances

1. Set the correct Azure subscription. If you received a notification from Microsoft, that notification contains one or more subscription IDs you should use.

    ```azurecli
    az account set \
        --subscription <subscription-id>
    ```
2. Find all the Kubernetes Fleet instances you have in the subscription.

    ```azurecli
    az resource list \
        --resource-type 'Microsoft.ContainerService/fleets'
    ```

    If you have multiple Kubernetes Fleet instances deployed, you can filter to instances created in 2022 or 2023 which may be affected. Instances from 2024 aren't affected.

    ```azurecli
    az resource list \
        --resource-type 'Microsoft.ContainerService/fleets' \
        --query "[?contains(createdTime, '2023') || contains(createdTime, '2022')]"
    ```

    If the above query returns any matching instances, determine if the instances are using the retired Kubernetes CRD API as described in the next steps.
3. Download Kubernetes credentials for the Kubernetes Fleet hub cluster.

    ```azurecli
    az fleet get-credentials \
        --resource-group <resource-group> \
        --name <fleet-name>
    ```
4. Query the Kubernetes Fleet hub cluster Kubernetes API to determine if the old CRD versions are deployed.

    ```azurecli
    kubectl get crd memberclusters.fleet.azure.com
    kubectl get crd internalmemberclusters.fleet.azure.com
    ```

    If both queries return `Error from server (NotFound) customresourcedefinitions.apiextensions.k8s.io`, then the selected Kubernetes Fleet instance isn't affected and no further action is required.

    If any instances are affected see the next section for remediation steps.

## Remediating affected instances

If you identify any affected Kubernetes Fleet instances, you'll need to undertake the following steps.

1. Document any update runs and cluster resource placement rules defined on the affected Kubernetes Fleet instance.
2. Remove all member clusters from the affected Kubernetes Fleet instance.
3. Create a new Kubernetes Fleet Manager instance and associate member clusters as required.
4. Reapply and validate any configurations you noted from the old Kubernetes Fleet instance.
5. Delete the old Kubernetes Fleet instance.