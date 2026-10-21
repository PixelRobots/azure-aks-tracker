---
layout: Conceptual
title: Schedule Upgrades for Azure Kubernetes Application Network Members using Planned Maintenance (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-network/planned-maintenance
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
learn_banner_products:
- azure
description: Learn how to use planned maintenance to schedule component upgrades for Azure Kubernetes Application Network members, including in-cluster data plane components and control plane components.
author: Kochhars
ms.author: kochhars
ms.service: azure-kubernetes-app-net
ms.topic: how-to
ms.date: 2026-03-13T00:00:00.0000000Z
locale: en-us
document_id: 19a25753-694e-0376-c0f6-486999f90182
document_version_independent_id: 1bd17cda-6ddb-b859-d299-eb2b4395e494
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/application-network/planned-maintenance.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: application-network/planned-maintenance
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-network/planned-maintenance.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: b78d39fb-911d-1ac7-cf7c-d4c289cc8463
---

# Schedule Upgrades for Azure Kubernetes Application Network Members using Planned Maintenance (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article shows you how to use planned maintenance to schedule component upgrades for Azure Kubernetes Application Network members.

## Overview of planned maintenance for Application Network

Maintenance operations refer to the upgrade of in-cluster [data plane components](architecture#data-plane) and Application Network [control plane components](architecture#control-plane) that run outside the cluster, such as Istiod.

Two of the key in-cluster components are the **ztunnel node proxies** and **Istio CNI node agents**. These resources are per-node DaemonSets, so their upgrades affect an entire node at a time and might cause disruptions of long-lived TCP connections. To isolate node-level disruptions to a common window, Application Network uses the same `aksManagedNodeOSUpgradeSchedule` maintenance schedule as [Azure Kubernetes Service (AKS) node operating system (OS) automatic upgrades](/en-us/azure/aks/auto-upgrade-node-os-image), if configured.

Note that while the maintenance *window* is the same, Application Network member upgrades and node OS upgrades are independent events within the window that occur for one or both components, depending on availability of upgrades. Neither upgrade impacts the timing or process of the other. If both components upgrade within the same window, there might be separate connection disruptions for each upgrade within that window.

Note

It's not required to opt in to node OS automatic upgrades to use planned maintenance for Application Network. Creating an `aksManagedNodeOSUpgradeSchedule` doesn't enable or disable node OS automatic upgrades.

## Prerequisites

- An existing AKS cluster onboarded as a member of an Application Network resource. If you don't have an Application Network resource or haven't onboarded your cluster yet, see [Get started with Azure Kubernetes Application Network](get-started).
- Azure CLI version is 2.84.0 or later. Check your version using the `az --version` command. To install or update, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- We recommend reviewing the [Maintenance window documentation](/en-us/azure/aks/planned-maintenance#create-a-maintenance-window) to understand the configuration fields and how maintenance windows work in AKS.

## Considerations

Keep the following considerations in mind when using planned maintenance to schedule Application Network upgrades:

- Application Network reserves the right to break planned maintenance windows for unplanned, reactive maintenance operations that are urgent or critical. These maintenance operations might even run during the `notAllowedTime` or `notAllowedDates` periods defined in your configuration.
- Maintenance operations are considered *best effort only* and aren't guaranteed to occur within a specified window.
- If an attempted upgrade isn't completed when the window closes, it continues to attempt reconciliation until it completes.

## Mode-specific behavior

You can use planned maintenance to schedule the timing of fully-managed upgrades and self-managed upgrades, but enabling or disabling planned maintenance doesn't impact your upgrade mode itself. Maintenance windows gate different types of upgrades depending on the upgrade mode of your cluster.

- [**Fully-managed mode**](upgrades#fully-managed-mode): Maintenance windows gate both minor and patch upgrades. However, if you initiate a release channel change, the associated version change takes effect immediately.
- [**Self-managed mode**](upgrades#self-managed-mode): Maintenance windows apply only to patch upgrades. If you initiate a minor version change, it takes effect immediately.

## Add a maintenance window

- Add a `aksManagedNodeOSUpgradeSchedule` maintenance window configuration to an AKS cluster using the [`az aks maintenanceconfiguration add`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-add) command. The following example adds a new `aksManagedNodeOSUpgradeSchedule` configuration that schedules maintenance to run every third Friday between 12:00 AM and 8:00 AM in the `UTC+5:30` time zone:

    ```azurecli
    az aks maintenanceconfiguration add --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name aksManagedNodeOSUpgradeSchedule --schedule-type Weekly --day-of-week Friday --interval-weeks 3 --duration 8 --utc-offset +05:30 --start-time 00:00
    ```

## Update an existing maintenance window

- Update an existing maintenance configuration using the [`az aks maintenanceconfiguration update`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-update) command. The following example updates the `aksManagedNodeOSUpgradeSchedule` configuration to schedule maintenance to run every Friday from 2:00 AM to 6:00 AM:

    ```azurecli
    az aks maintenanceconfiguration update --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name aksManagedNodeOSUpgradeSchedule --schedule-type Weekly --day-of-week Friday --interval-weeks 1 --duration 4 --utc-offset +00:00 --start-time 02:00
    ```

## Show the maintenance configuration for a cluster

- View a specific maintenance configuration window in your AKS cluster using the [`az aks maintenanceconfiguration show`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-show) command with the `--name` parameter.

    ```azurecli
    az aks maintenanceconfiguration show --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name aksManagedNodeOSUpgradeSchedule
    ```

    The following example output shows the maintenance window for `aksManagedNodeOSUpgradeSchedule`:

    ```output
    {
      "id": "/subscriptions/<subscription>/resourceGroups/myResourceGroup/providers/Microsoft.ContainerService/managedClusters/myAKSCluster/maintenanceConfigurations/aksManagedNodeOSUpgradeSchedule",
      "maintenanceWindow": {
        "durationHours": 4,
        "notAllowedDates": [
          {
            "end": "2024-01-05",
            "start": "2023-12-23"
          }
        ],
        "schedule": {
          "absoluteMonthly": {
            "dayOfMonth": 1,
            "intervalMonths": 3
          },
          "daily": null,
          "relativeMonthly": null,
          "weekly": null
        },
        "startDate": "2023-01-20",
        "startTime": "09:00",
        "utcOffset": "-08:00"
      },
      "name": "aksManagedNodeOSUpgradeSchedule",
      "notAllowedTime": null,
      "resourceGroup": "myResourceGroup",
      "systemData": null,
      "timeInWeek": null,
      "type": null
    }
    ```

## Delete a maintenance configuration for a cluster

- Delete a maintenance configuration window in your AKS cluster using the [`az aks maintenanceconfiguration delete`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-delete) command.

    ```azurecli
    az aks maintenanceconfiguration delete --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name aksManagedNodeOSUpgradeSchedule
    ```