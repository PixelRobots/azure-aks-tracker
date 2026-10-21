---
layout: Conceptual
title: Send an email when an Azure Kubernetes Fleet Manager update run reaches a gate | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-send-email-pending-gate
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
description: Learn how to use Azure Monitor to send email when an Azure Kubernetes Fleet Manager update run reaches an approval or scheduled start gate.
ms.topic: how-to
ms.date: 2026-09-29T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ai-usage: ai-assisted
locale: en-us
document_id: 4ee5ea79-334b-fb3b-3d00-c25bf2c84119
document_version_independent_id: d3548e68-ab96-a87b-1205-6369dd3b5079
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-send-email-pending-gate.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-send-email-pending-gate
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-send-email-pending-gate.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/d3928677-9b71-43a6-875f-004dc4f98b65
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/6bbc70ca-58b2-4c69-8249-28ec92c08029
platformId: a446f142-0bac-e134-e3b8-b8dcb03d1269
---

# Send an email when an Azure Kubernetes Fleet Manager update run reaches a gate | Microsoft Learn

**Applies to:** ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Azure Kubernetes Fleet Manager update runs can pause at [approval gates](update-strategies-gates-approvals) and [scheduled start gates](update-strategies-gates-scheduled-start). Use Azure Monitor to email recipients when an update run reaches either gate type and the gate enters the `Pending` state.

In this article, you set up an Azure Monitor alert rule that uses a log search to evaluate gate data in Azure Resource Graph. An action group connected to the rule sends an email notification to a set of recipients.

## Before you begin

- You need a Fleet Manager with an update strategy that contains at least one approval or scheduled start gate.
- You need permission to create Azure Monitor alert rules and action groups in the subscription.
- Start an update run that reaches a gate so that you can validate the query and select the query result fields when you configure the alert rule.

## Query pending gates

Fleet Manager gate resources are available in the `aksresources` table in [Azure Resource Graph](/en-us/azure/governance/resource-graph/overview). A gate enters the `Pending` state when an update run reaches it. Approval gates remain pending until they're approved. Scheduled start gates remain pending until their scheduled time arrives or they're approved manually.

1. Open [Azure Resource Graph Explorer](https://portal.azure.com/#view/HubsExtension/ArgQueryBlade) in the Azure portal.
2. Replace `<fleet-name>` in the following query with the name of your Fleet Manager resource, and then run the query:

    ```kusto
    aksresources
    | where type =~ "microsoft.containerservice/fleets/gates"
    | where id contains "/fleets/<fleet-name>/gates/"
    | extend gateProperties = parse_json(properties)
    | extend gateType = tostring(gateProperties.gateType),
             gateState = tostring(gateProperties.state)
    | where gateState =~ "Pending"
    | where gateType in~ ("Approval", "ScheduledStart")
    | project gateId = id,
              gateName = name,
              gateDisplayName = tostring(gateProperties.displayName),
              gateType,
              gateState,
              fleetName = extract(@"/fleets/([^/]+)", 1, tostring(gateProperties.target.id)),
              updateRunName = tostring(gateProperties.target.updateRunProperties.name),
              updateRunId = tostring(gateProperties.target.id),
              stage = tostring(gateProperties.target.updateRunProperties.stage),
              group = tostring(gateProperties.target.updateRunProperties.group),
              timing = tostring(gateProperties.target.updateRunProperties.timing),
              scheduledStartTime = todatetime(gateProperties.scheduledStartProperties.absoluteStartTime)
    ```
3. Confirm that the results contain the pending gates for your fleet. The query returns both `Approval` and `ScheduledStart` gate types. To receive email for only one type, remove the other value from the `in~` clause.

Note

Azure Resource Graph Explorer queries start with `aksresources`. Azure Monitor log search queries must start with `arg("").aksresources` to access the same Azure Resource Graph data.

## Create an email action group

Create an action group that defines the email recipients for the notification.

1. In the Azure portal, open **Monitor**.
2. Select **Alerts** &gt; **Action groups** &gt; **Create**.
3. On the **Basics** tab, select the subscription and resource group where you want to store the action group. Enter an action group name and display name.
4. On the **Notifications** tab, select **Email/SMS message/Push/Voice** for the notification type.
5. Select **Email**, enter the recipient's email address, select **OK**, and enter a name for the notification.
6. Add more email notifications as needed, and then select **Review + create** &gt; **Create**.
7. Verify that each recipient receives the action group confirmation email from Azure Monitor.

For more information about email receivers and delivery limits, see [Create and manage action groups in the Azure portal](/en-us/azure/azure-monitor/alerts/action-groups).

## Create the alert rule that sends email

Create a log search alert rule that runs the pending gate query and invokes the email action group when the query returns a gate.

1. In the Azure portal, open **Monitor**.
2. Select **Alerts** &gt; **+ Create** &gt; **Alert rule**.
3. On the **Scope** tab, select the Subscription containing your Azure Kubernetes Fleet Manager. Don't scope to the Fleet Manager as the log query won't be executed.
4. On the **Condition** tab, select **Custom log search** as the signal name.
5. For **Query type** select **Aggregated logs**.
6. In the **Logs** pane, enter the following query. Replace `<fleet-name>` with your Fleet Manager resource name. You can modify the query to target specific update runs, groups, stages, or particular gates as required.

    ```kusto
    arg("").aksresources
    | where type =~ "microsoft.containerservice/fleets/gates"
    | where id contains "/fleets/<fleet-name>/gates/"
    | extend gateProperties = parse_json(properties)
    | extend gateType = tostring(gateProperties.gateType),
             gateState = tostring(gateProperties.state)
    | where gateState =~ "Pending"
    | where gateType in~ ("Approval", "ScheduledStart")
    | project gateId = id,
              gateName = name,
              displayName = tostring(gateProperties.displayName),
              gateType,
              fleetName = extract(@"/fleets/([^/]+)", 1, tostring(gateProperties.target.id)),
              updateRunName = tostring(gateProperties.target.updateRunProperties.name),
              updateRunId = tostring(gateProperties.target.id),
              stage = tostring(gateProperties.target.updateRunProperties.stage),
              group = tostring(gateProperties.target.updateRunProperties.group),
              timing = tostring(gateProperties.target.updateRunProperties.timing),
              scheduledStartTime = todatetime(gateProperties.scheduledStartProperties.absoluteStartTime)
    ```
7. Select **Continue Editing Alert**.
8. In **Measurement**, configure the alert rule to count table rows, set to granularity of 5 minutes.
9. Under **Split by dimensions**, for **Resource ID column** leave as **Don't split**, then select `gateId` as the dimension and select all current and future values. Splitting by gate ID allows Azure Monitor to evaluate each gate separately when more than one gate is pending.
10. For **Alert logic** Set **Threshold type** to **Static**, **Operator** to **Greater than** and **Threshold value** to `0`. Set **Frequency of evaluation** to **5 minutes**.
11. On the **Actions** tab, select **Select action groups**, and then select the email action group that you created.
12. On the **Details** tab, select the subscription and resource group where you want to store the rule. Enter a severity, alert rule name, and description.
13. Depending on your environment, choose the appropriate **Identity** to use to create an run the new alert rule.
14. Expand **Advanced options** and set either **Automatically resolve alerts** to fire the alert only once when the gate is reached, or configure a time period for **Mute actions** so that you don't receive alerts more frequently than you wish.
15. Select **Review + create** &gt; **Create**.

When an approval or scheduled start gate enters the `Pending` state, the query returns the gate and Azure Monitor invokes the action group. The email body has the alert context including the `gateId`, Subscription, alert details, and rule.

Important

The identity assigned to the log search alert rule must be assigned the `Reader` RBAC role for the Azure subscription where the Fleet Manager resides. Failing to assign this role means the alert won't fire as the Kusto query can't be executed.

A sample alert email is shown below.

[![A screenshot of the body of an email received as a result of configuring an alert rule.](media/send-email-gates/howto-send-email-gates-sample.png)](media/send-email-gates/howto-send-email-gates-sample.png#lightbox)

To create customized email alerts, see [Automate approval gates with Event Grid events](howto-configure-events-for-gates), which shows how you can use an event-driven trigger custom code to send email via service APIs.