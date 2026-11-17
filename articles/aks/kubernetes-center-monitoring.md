---
layout: Conceptual
title: Monitor AKS clusters in Kubernetes Center using the Azure portal - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kubernetes-center-monitoring
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
description: Learn how to compare AKS cluster health and resource usage, investigate nodes and pods, and review Kubernetes events in Kubernetes Center.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.subservice: aks-monitoring
ms.date: 2026-11-06T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 67bf146e-3be5-3e64-1f24-5d52a4640366
document_version_independent_id: 5e9a9c49-f059-6a4f-762a-1705774b1e8b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kubernetes-center-monitoring.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/kubernetes-center-monitoring
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kubernetes-center-monitoring.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 3b686fb3-523b-b75f-2db8-6dad6bd6f7f3
---

# Monitor AKS clusters in Kubernetes Center using the Azure portal - Azure Kubernetes Service | Microsoft Learn

Use **Monitoring** in Kubernetes Center (preview) to compare health and resource usage across Azure Kubernetes Service (AKS) clusters, then narrow an investigation to a node, pod, network signal, or Kubernetes event.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- An Azure subscription with AKS clusters and access to the resources you want to investigate.
- For the metrics views, Azure Monitor managed service for Prometheus enabled on the relevant clusters, with data sent to an Azure Monitor workspace.
- For Kubernetes events in **Logs**, Container insights enabled on the relevant clusters, with data sent to a Log Analytics workspace.
- Permissions to view the monitoring data. You need the **Monitoring Reader** or **Monitoring Contributor** role to view data after monitoring is enabled. Your access must cover the relevant resources and workspace data.

Azure Monitor workspaces and Log Analytics workspaces serve different purposes in this experience. Enabling metrics collection doesn't, by itself, enable event or container-log collection.

For setup and permission details, see [Enable monitoring for AKS clusters](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable).

## Open Monitoring

1. Sign in to the [Azure portal](https://portal.azure.com/).
2. Search for and select **Kubernetes center**.
3. In the **Kubernetes center** menu, expand **Operations**, and select **Monitoring**.
4. Start on **Overview**.

[![Screenshot of the Kubernetes center menu showing Monitoring under Operations.](media/kubernetes-center-monitoring/monitoring-menu.png)](media/kubernetes-center-monitoring/monitoring-menu.png#lightbox)

The experience provides **Overview**, **Nodes**, **Pods**, **Networking**, **Logs**, and **Dashboards** tabs. Use the tabs as parts of the same investigation, but check the scope and time range each time you switch views.

## Select a workspace, clusters, and time range

1. On **Overview**, select **Monitor workspace**.
2. Choose the Azure Monitor workspace that receives metrics from the clusters you want to inspect, and select **Apply**.
3. Select **Clusters**, choose the relevant clusters, and apply the selection.
4. Select **Time range**, choose the period to investigate, and select **Apply**. Available choices include recent intervals and **Custom**.
5. Select **Refresh** when you need to reload the view, and check **Last updated**.

[![Screenshot of the Monitor workspace, Clusters, and Time range filters.](media/kubernetes-center-monitoring/workspace-cluster-time-filters.png)](media/kubernetes-center-monitoring/workspace-cluster-time-filters.png#lightbox)

The workspace selection determines which connected clusters you can investigate in the metrics views. If clusters send metrics to different workspaces, examine each workspace in turn.

Note

**Logs** uses a separate **Log Analytics workspace** selector. Don't assume that its cluster selection matches the selection in the Prometheus-based metrics tabs.

Changing these view filters doesn't change cluster configuration.

## Identify an issue on Overview

Review the overview cards for the selected scope:

| Card | How to use it |
| --- | --- |
| **Node health and capacity** | Identify nodes with high P95 CPU utilization, computed against capacity. Select **View nodes** to investigate further. |
| **Node readiness** | Compare ready and not-ready nodes, then use **View nodes** to inspect the node list. |
| **Pod readiness** | Compare ready and not-ready pods, then use **View pods** to inspect the pod list. |

[![Screenshot of the Node health and capacity card ranking nodes by P95 CPU utilization.](media/kubernetes-center-monitoring/node-health-capacity.png)](media/kubernetes-center-monitoring/node-health-capacity.png#lightbox)

Use a high-utilization result as a starting point for investigation, not as proof of the cause of an application issue. Compare the same cluster and time range in the detailed views.

Important

No data isn't the same as zero utilization or a healthy cluster. Check workspace selection, collection, permissions, and time range before interpreting an empty card.

## Compare node utilization

1. Select **Nodes**, or use **View nodes** from **Overview**.
2. Verify **Monitor workspace**, **Clusters**, and **Time range**.
3. In **Metric**, choose the CPU or memory measure you need. The view offers capacity-based and allocatable-based choices.
4. Review **Status**, the utilization statistics, **Containers**, and **Uptime**. The percentile columns include **50th %**, **90th %**, and **95th %**.
5. Select a column heading, such as **95th %**, to sort the results. Use **Filter for any field** to narrow the table.
6. If helpful, use **Group by none** to select **Group by Node** or **Group by Status**.
7. Select a linked node to continue investigating that resource. Use **Export to CSV** if you need a copy of the displayed results.

[![Screenshot of the Nodes view with workspace filters, the Metric selector, readiness status, and utilization percentile columns.](media/kubernetes-center-monitoring/nodes.png)](media/kubernetes-center-monitoring/nodes.png#lightbox)

Keep the denominator consistent when comparing utilization. A percentage computed against node capacity isn't the same comparison as a percentage computed against allocatable resources.

If a value is shown as a dash, don't treat it as zero. Check the collection and selected interval, particularly for newly created nodes.

## Investigate pod readiness and resource usage

1. Select **Pods**, and confirm the workspace, cluster selection, and time range.
2. Choose a **Metric**, such as **CPU usage / requests**, **CPU usage / limits**, or a memory measure relative to requests or limits.
3. Review **Cluster**, **Namespace**, **Pod**, and **Status** to locate the affected workload.
4. Compare the utilization statistics with **Containers** and **Restarts**.
5. Use **Filter for any field** to narrow the results, or sort a relevant column.
6. Select the linked pod or namespace to continue into its resource view.

[![Screenshot of the Pods view showing readiness, CPU usage relative to requests, percentile values, and restart counts.](media/kubernetes-center-monitoring/pods.png)](media/kubernetes-center-monitoring/pods.png#lightbox)

For a usage-to-request metric, a value above 100% means usage exceeded the configured request. It doesn't mean the node exceeded its physical capacity. Check the selected metric before comparing values across views.

For example, to investigate an unhealthy workload, identify its cluster and namespace here, then review events for the same cluster and interval in **Logs**.

## Examine network signals

1. Select **Networking**.
2. Verify **Monitor workspace**, **Clusters**, and **Time range**.
3. Review the charts for **Container receive packet success**, **Container transmit packet success**, **Node receive packets dropped**, **Node transmit packets dropped**, and **API server errors (5xx)**.
4. Compare changes in these signals with the period when the node, pod, or application issue occurred.

[![Screenshot of the Container receive packet success chart with a drop during the selected interval.](media/kubernetes-center-monitoring/network-packet-success.png)](media/kubernetes-center-monitoring/network-packet-success.png#lightbox)

A chart with no data doesn't establish that there were no failures. Check whether the required metrics are collected for the selected clusters and interval.

## Review Kubernetes events and open a scoped log query

The **Logs** tab displays Kubernetes events. It isn't a live container-output stream.

1. Select **Logs**.
2. Select **Log Analytics workspace**, choose the workspace receiving the relevant clusters' Container insights data, and select **Apply**.
3. Set **Clusters** and **Time range** for the investigation.
4. Use **Filter for any field** to narrow the event list.
5. Review **Source component**, **Namespace**, **Node**, **Message**, and **Count**. Sort by **Count** to focus on frequently occurring events.
6. For an event you want to investigate, select **View in logs**.
7. In the opened Azure Monitor Logs experience, review the resource scope and generated query before running or editing it.

[![Screenshot of Kubernetes events showing source components, namespaces, nodes, messages, occurrence counts, and View in logs actions.](media/kubernetes-center-monitoring/kubernetes-events.png)](media/kubernetes-center-monitoring/kubernetes-events.png#lightbox)

**View in logs** opens a query against `KubeEvents` scoped to the selected cluster and event details, using the selected lookback interval. Review that context before broadening a query.

Kubernetes events and container stdout/stderr logs are different data. For container-log queries and collection requirements, see [Query container logs in Azure Monitor](/en-us/azure/azure-monitor/containers/container-insights-log-query). Event availability also depends on collection settings. Not every Kubernetes event type is necessarily collected.

## Open dashboards

1. Select **Dashboards** to open the dashboard gallery.
2. Browse the available dashboards, or use the gallery's filters.
3. Open a relevant dashboard, and verify its data source and scope.

Dashboard availability and access can differ from the monitoring tables. Don't assume that opening the gallery creates or configures a dashboard.

## Address a monitoring-configuration warning

If the page displays **Action required** for clusters missing **Managed Prometheus** or **Container insights**:

1. Read which collection features are missing.
2. Decide whether you need metrics, events and logs, or both for the investigation.
3. If you're authorized to configure collection, select **Enable now** to open the onboarding experience.
4. Review the resources, workspaces, permissions, and cost implications before enabling collection.
5. After onboarding and data collection begin, return to **Monitoring**, select the appropriate workspace and clusters, and select **Refresh**.

Enabling monitoring is a resource-configuration change and can incur Azure Monitor charges. Viewing this page doesn't enable collection. Use the [monitoring setup guidance](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable) for the onboarding procedure.