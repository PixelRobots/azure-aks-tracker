---
layout: Conceptual
title: AKS Communication Manager - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-communication-manager
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
description: Learn how to set up and receive notices in Azure Resource Notifications for Azure Kubernetes Service maintenance events.
ms.date: 2025-08-28T00:00:00.0000000Z
ms.custom: aks communication manager
ms.topic: how-to
author: kaarthis
ms.author: kaarthis
ms.subservice: aks-upgrade
locale: en-us
document_id: ea41ea0b-246b-d6af-f7ce-20b6808c8fcc
document_version_independent_id: 2e08ccd6-844a-2c6c-7e3c-c2ed7227fa39
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-communication-manager.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-communication-manager
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-communication-manager.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: cfd3d756-6b18-1864-9069-890d1dc8a30a
---

# AKS Communication Manager - Azure Kubernetes Service | Microsoft Learn

The Azure Kubernetes Service (AKS) communication manager streamlines notifications for all your AKS maintenance tasks by using Azure Resource Notifications and Azure Resource Graph frameworks. The communication manager gives you timely alerts on event triggers and outcomes, so that you can closely monitor your upgrades.

If maintenance fails, the communication manager notifies you with the reasons for the failure. This information reduces operational hassles related to observability and follow-ups.

By following the steps in this article, you can set up alerts for upgrade events on an AKS cluster. The queries filter scheduled events by cluster resource ID; they don't monitor Fleet Manager update runs. If you configure upgrades through a Fleet Manager auto-upgrade profile and strategy, see [Monitor update runs in Fleet Manager](../kubernetes-fleet/howto-monitor-update-runs).

- **Auto-upgrades that you configure** on the cluster, which follow its [planned maintenance](planned-maintenance) window.
- **[Platform-initiated upgrades](platform-initiated-upgrades)**, which AKS runs on clusters that stay on an unsupported Kubernetes version after the platform support grace period. These upgrades can occur outside your maintenance window.

## Prerequisites

- Configure your cluster for either the [automatic upgrade channel](auto-upgrade-cluster) or the [automatic upgrade channel for nodes](auto-upgrade-node-os-image).
- Create a [planned maintenance window](planned-maintenance) for your configuration of automatic upgrades.

## Set up the communication manager

1. In the Azure portal, go to the resource.
2. Select **Monitoring** &gt; **Alerts** &gt; **Alert Rules**, and then select **Create**.
3. On the **Condition** tab, for **Signal name**, select **Custom log search**.

    ![Screenshot that shows the selection of a custom log search on the pane for creating an alert rule.](media/auto-upgrade-cluster/custom-log-search.jpg)
4. In the **Search query** box, paste one of the following custom queries. Be sure to update the `where id contains` path to reference your resources for subscription ID, resource group name, and cluster name.

    The following query is for notifications of automatic upgrades for clusters:

    ```console
    arg("").containerserviceeventresources
    | where type == "microsoft.containerservice/managedclusters/scheduledevents"
    | where id contains "/subscriptions/<subid>/resourcegroups/<rgname>/providers/Microsoft.ContainerService/managedClusters/<clustername>"
    | where properties has "eventStatus"
    | extend status = substring(properties, indexof(properties, "eventStatus") + strlen("eventStatus") + 3, 50)
    | extend status = substring(status, 0, indexof(status, ",") - 1)
    | where status != ""
    | where properties has "eventDetails"
    | extend upgradeType = case(
                               properties has "K8sVersionUpgrade",
                               "K8sVersionUpgrade",
                               properties has "NodeOSUpgrade",
                               "NodeOSUpgrade",
                               ""
                           )
    | extend details = parse_json(tostring(properties.eventDetails))
    | where properties has "lastUpdateTime"
    | extend eventTime = substring(properties, indexof(properties, "lastUpdateTime") + strlen("lastUpdateTime") + 3, 50)
    | extend eventTime = substring(eventTime, 0, indexof(eventTime, ",") - 1)
    | extend eventTime = todatetime(tostring(eventTime))
    | where eventTime >= ago(30m) // Ensure this matches aggregation granularity & frequency
    | where upgradeType == "K8sVersionUpgrade"
    | project
        eventTime,
        upgradeType,
        status,
        properties,
        name,
        details
    | order by eventTime asc
    ```

    The following query is for notifications of automatic upgrades for NodeOS:

    ```console
    arg("").containerserviceeventresources
    | where type == "microsoft.containerservice/managedclusters/scheduledevents"
    | where id contains "/subscriptions/<subid>/resourcegroups/<rgname>/providers/Microsoft.ContainerService/managedClusters/<clustername>"
    | where properties has "eventStatus"
    | extend status = substring(properties, indexof(properties, "eventStatus") + strlen("eventStatus") + 3, 50)
    | extend status = substring(status, 0, indexof(status, ",") - 1)
    | where status != ""
    | where properties has "eventDetails"
    | extend upgradeType = case(
                               properties has "K8sVersionUpgrade",
                               "K8sVersionUpgrade",
                               properties has "NodeOSUpgrade",
                               "NodeOSUpgrade",
                               ""
                           )
    | extend details = parse_json(tostring(properties.eventDetails))
    | where properties has "lastUpdateTime"
    | extend eventTime = substring(properties, indexof(properties, "lastUpdateTime") + strlen("lastUpdateTime") + 3, 50)
    | extend eventTime = substring(eventTime, 0, indexof(eventTime, ",") - 1)
    | extend eventTime = todatetime(tostring(eventTime))
    | where eventTime >= ago(30m) // Ensure this matches aggregation granularity & frequency
    | where upgradeType == "NodeOSUpgrade"
    | project
        eventTime,
        upgradeType,
        status,
        properties,
        name,
        details
    | order by eventTime asc
    ```
5. Go to the **Condition** tab. Configure the alert conditions with the following settings:

    - **Measure**: Select **Table rows**.
    - **Aggregation type**: Select **Count**.
    - **Aggregation granularity**: Select **30 minutes**.
    - **Threshold value**: Keep at **0**.
    - **Split by dimensions**: For **Dimension name**, select **status**. Then select the **Include all future values** checkbox.

    ![Screenshot of the configuration options for alert conditions.](media/auto-upgrade-cluster/edit-alert-rule.jpg)
6. In the **Split by dimensions** area, for **Dimension values**, select a value. Because you selected **status** for the dimension name, the available values are **Scheduled**, **Started**, **Completed**, **Canceled**, and **Failed**.

    Note

    These status values appear only if your cluster previously executed automatic upgrade operations. For new clusters or for clusters that haven't undergone automatic upgrades yet, the dropdown list might appear empty or show no available dimensions. After your cluster performs its first automatic upgrade, these status values become available for selection.

    ![Screenshot of the dropdown list boxes in the area for splitting by dimensions.](media/auto-upgrade-cluster/by-dimension.jpg)
7. Go to the **Actions** tab. Make sure that an action group with the correct email address exists, so that you can receive the notifications:

    1. Select **Use action groups** &gt; **Create an action group**.
    2. For **Notification type**, select **Email/SMS\_message/Push/Voice**.
    3. Select the **Email** checkbox, and then enter the email address in the **Email** box.

        ![Screenshot of the pane for entering email information for an action group.](media/auto-upgrade-cluster/action-group.png)
8. Go to the **Details** tab. Assign a managed identity so that you can grant access to the necessary resources. In the **Identity** area, select **System assigned managed identity**.

    ![Screenshot that shows selections for assigning a system-assigned managed identity.](media/auto-upgrade-cluster/system-assigned-identity.jpg)
9. Go to the **Review + create** tab, and then select **Create**.
10. Now that you've created the alert rule, you can assign the appropriate roles for the managed identity:

    1. In the alert rule, go to **Settings** &gt; **Identity** &gt; **System assigned managed identity** &gt; **Azure role assignments**.
    2. Select **Add role assignment**, select the **Reader** role, and assign it to the resource group.
    3. Select **Add role assignment** again, select the **Reader** role, and assign it to the subscription.

    Tip

    If you don't see the **Identity** option, make sure that you created your alert rule and that you have the necessary permissions.

After you set up the communication manager, it sends advance notices one week before maintenance starts and one day before maintenance starts. It also sends you timely alerts during the maintenance operation.

## Verify the configuration

To upgrade the cluster, wait for the automatic upgrader to start. Then verify that you promptly receive notices on the email address that you configured to receive notices.

Check the Azure Resource Graph database for the scheduled notification record. Each scheduled event notification should be listed as one record in the `ContainerServiceEventResources` table.

![Screenshot that shows a notification record in Azure Resource Graph.](media/auto-upgrade-cluster/azure-resource-graph.jpeg)