---
layout: Conceptual
title: Node Image Updates for Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-auto-provisioning-upgrade-image
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
description: Learn about node image updates for NAP in AKS, including how it works, recommended maintenance windows, and examples to get started.
ms.topic: overview
ms.custom: devx-track-azurecli
ms.date: 2025-09-29T00:00:00.0000000Z
ms.author: wilsondarko
author: wdarko1
locale: en-us
document_id: 7157bd62-1f5b-dab3-f9bb-e7c6d61f4195
document_version_independent_id: 78b595f3-7ab9-be86-100d-38366feaae55
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-auto-provisioning-upgrade-image.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/node-auto-provisioning-upgrade-image
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-auto-provisioning-upgrade-image.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 3c505b77-f641-ce33-2845-35c068b52740
---

# Node Image Updates for Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article provides an overview of node image updates for node auto-provisioning (NAP) in Azure Kubernetes Service (AKS), including how it works, recommended maintenance windows, and examples to get started.

## How do node image updates work for node auto-provisioning nodes?

By default, NAP node pool virtual machines (VMs) are automatically updated when a new image version is available. You can configure an AKS-managed node operating system (OS) upgrade schedule maintenance window to control when new images are picked up and applied to your NAP nodes, or use Karpenter Node Disruption Budgets and Pod Disruption Budgets to control how and when disruption occurs during upgrades.

## Node OS upgrade maintenance windows for NAP

You can use the [AKS planned maintenance feature](planned-maintenance) with a [node OS auto-upgrade channel](auto-upgrade-node-os-image) to configure a `aksManagedNodeOSUpgradeSchedule` maintenance window that controls when to perform node OS security patching scheduled by your designated node OS auto-upgrade channel.

### Node OS upgrade maintenance window behavior and considerations

Keep the following information in mind when configuring a node OS upgrade maintenance window for NAP:

- The `aksManagedNodeOSUpgradeSchedule` maintenance configuration determines the window during which NAP picks up a new image. This configuration doesn't necessarily determine when existing nodes are disrupted.
- The upgrade mechanism and decision criteria are specific to NAP/Karpenter and are evaluated by NAP's drift logic. NAP respects Karpenter Node Disruption Budgets and Pod Disruption Budgets. For more information about drift, see the [Karpenter drift documentation](https://karpenter.sh/docs/concepts/disruption/#drift).
- These NAP upgrade decisions are separate from the cluster `NodeImage` and `SecurityPatch` channels. However, the `aksManagedNodeOSUpgradeSchedule` maintenance configuration applies them as well.
- We recommend using a maintenance window of four hours or more for reliable operation.
- If no maintenance configuration exists, AKS might use a fallback schedule to pick up new images, which can cause images to be picked up at unexpected times. You can avoid unexpected timing of new images and upgrades by defining an explicit `aksManagedNodeOSUpgradeSchedule`.
- Allow at least 30 minutes between creating or updating a maintenance configuration and the scheduled start time to ensure AKS has time to reconcile the new configuration.

### Recommended schedule pattern for NAP-managed nodes

We recommend the following schedule pattern for NAP-managed nodes:

- **Weekly cadence**: Recommended for routine node image roll outs (for example: *Every week on Sunday*).

## Create a node OS maintenance schedule example

The following sections show you how to create a weekly maintenance window for NAP-managed nodes using the Azure CLI and a JSON configuration file and how to update, view, list, and delete the maintenance configuration.

### Create a maintenance configuration

1. Create a JSON file named `nodeosMaintenance.json` with a weekly maintenance window (for example: *Sunday at 01:00 UTC for 4 hours*).

    ```json
    {
      "properties": {
        "maintenanceWindow": {
          "durationHours": 4,
          "schedule": {
            "weekly": {
              "intervalWeeks": 1,
              "dayOfWeek": "Sunday"
            }
          },
          "startDate": "2025-01-01",
          "startTime": "01:00",
          "utcOffset": "+00:00"
        }
      }
    }
    ```
2. Add the maintenance configuration to your cluster using the [`az aks maintenanceconfiguration add`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-add) command.

    ```azurecli
    az aks maintenanceconfiguration add \
      --resource-group $RESOURCE_GROUP \
      --cluster-name $CLUSTER_NAME \
      --name aksManagedNodeOSUpgradeSchedule \
      --config-file ./nodeosMaintenance.json
    ```

### Update, view, list, or delete a maintenance configuration

You can use the following commands to update, view, list, or delete a maintenance configuration for NAP-managed nodes:

- Update a maintenance configuration by modifying the JSON file and then running the [`az aks maintenanceconfiguration update`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-update) command.

    ```azurecli
    az aks maintenanceconfiguration update \
      --resource-group $RESOURCE_GROUP \
      --cluster-name $CLUSTER_NAME \
      --name aksManagedNodeOSUpgradeSchedule \
      --config-file ./nodeosMaintenance.json
    ```
- View the details of a maintenance configuration using the [`az aks maintenanceconfiguration show`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-show) command.

    ```azurecli
    az aks maintenanceconfiguration show \
      --resource-group $RESOURCE_GROUP \
      --cluster-name $CLUSTER_NAME \
      --name aksManagedNodeOSUpgradeSchedule
    ```
- List all maintenance configurations for your cluster using the [`az aks maintenanceconfiguration list`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-list) command.

    ```azurecli
    az aks maintenanceconfiguration list \
      --resource-group $RESOURCE_GROUP \
      --cluster-name $CLUSTER_NAME
    ```
- Delete a maintenance configuration using the [`az aks maintenanceconfiguration delete`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-delete) command.

    ```azurecli
    az aks maintenanceconfiguration delete \
      --resource-group $RESOURCE_GROUP \
      --cluster-name $CLUSTER_NAME \
      --name aksManagedNodeOSUpgradeSchedule
    ```

For complete details, examples, and advanced scenarios, see [Use Planned Maintenance to schedule maintenance windows for your AKS cluster](planned-maintenance).

## Karpenter Node Disruption Budgets and Pod Disruption Budgets for NAP

For more information on configuring Karpenter Node Disruption Budgets and Pod Disruption Budgets for NAP, see the following resources from the official Karpenter documentation:

- [Node pool disruption budgets](https://karpenter.sh/docs/concepts/disruption/#nodepool-disruption-budgets)
- [Pod-level controls for disruption](https://karpenter.sh/docs/concepts/disruption/#pod-level-controls)