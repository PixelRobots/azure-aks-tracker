---
layout: Conceptual
title: Proactive monitoring best practices for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/best-practices-monitoring-proactive
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
description: Learn the best practices for proactively monitoring your Azure Kubernetes Service (AKS) cluster and workloads.
ms.topic: best-practice
ms.date: 2024-11-01T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-monitoring
locale: en-us
document_id: aa3a2d78-2dd7-cee4-0df1-0f046cc5f8d1
document_version_independent_id: 0df176bf-b4d0-02e4-2c81-ba783f73a42c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/best-practices-monitoring-proactive.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/best-practices-monitoring-proactive
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/best-practices-monitoring-proactive.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 00fcc410-fde7-8601-cdce-7b0315f94412
---

# Proactive monitoring best practices for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article covers the best practices for proactive monitoring on Azure Kubernetes Service (AKS) and provides a comprehensive list of the key signals AKS recommends for you to monitor.

Proactively monitoring your AKS clusters is crucial for reducing downtime and saving business interruptions for your applications. This process involves identifying and monitoring key indicators of abnormal behavior in your cluster that might lead to major issues or downtime.

## Monitoring and alerting overview

Monitoring on AKS involves using metrics, logs, and events to ensure the health and performance of your cluster. Common scenarios to monitor include node performance, pod status, and overall resource utilization in your cluster. Logs provide insights into system events and cluster operations and activity. For more information about the methods and signals AKS provides for monitoring, see [Monitor Azure Kubernetes Service (AKS)](monitor-aks).

The best way to proactively monitor your cluster is to configure [Azure Monitor alerts](/en-us/azure/azure-monitor/alerts/alerts-overview). Alerts act as proactive measures to notify you of potential issues or anomalies before they escalate into critical problems. By defining thresholds for key metrics and logs, you receive immediate alerts when these signals exceed predefined limits, indicating potential issues like resource exhaustion or application failures. We highly recommend defining [service-level objectives (SLOs)](/en-us/azure/well-architected/reliability/metrics) for your application to measure the performance and reliability of your service. Configuring alerts on the key signals for your SLOs allows you to quickly detect any degradation of your application's quality of service that your customers receive. Overall, setting timely alerts enables you to quickly investigate and remediate problems, minimizing downtime and ensuring high availability of applications running on your AKS cluster.

## How to configure alerts on specific metric types

| Metric type | Where to find these metrics | How to configure alerts |
| --- | --- | --- |
| AKS Platform Metric | View [platform metrics](monitor-aks#azure-monitor-platform-metrics) through the Metrics blade in the Azure portal. | You can create, update, and delete metric alerts through the Azure portal. For more information, see [Create a metric alert for an Azure resource](/en-us/azure/azure-monitor/alerts/tutorial-metric-alert). |
| Azure Managed Prometheus Metric | To access Prometheus metrics, you need to enable Managed Prometheus. For details on how to enable and view Prometheus metrics, see [Azure Monitor and Prometheus](/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview). | For guidance on configuring Prometheus alerts, see [Azure Monitor managed service for Prometheus rule groups](/en-us/azure/azure-monitor/essentials/prometheus-rule-groups). |
| Azure Activity Logs | View activity logs through the Azure portal. For more information, see [Azure activity logs for AKS](monitor-aks#azure-activity-log). | Configure alerts on activity logs through the Azure portal. For more information, see [Activity log alerts](/en-us/azure/azure-monitor/alerts/alerts-types#activity-log-alerts). |
| Azure Virtual Machine Scale Set Metric | View the Virtual Machine Scale Set metrics through the Azure portal. | 1. To find the Virtual Machine Scale Set instance associated with your node pool, navigate to the **Settings &gt; Properties** blade for your AKS cluster in the Azure portal.  2. Select your **infrastructure resource group** to view the infrastructure resources associated with your cluster.  3. Select the **Virtual Machine Scale Set instance** that matches the name of your node pool you're creating alerts for.  4. Navigate to the **Alerts** blade to create your metric alert. |
| Load Balancer Metric | View load balancer metrics through the Load Balancer page in Azure portal. | 1. To find the load balancer instance associated with your node pool, navigate to the **Settings &gt; Properties** blade for your AKS cluster in the Azure portal.  2. Select your **infrastructure resource group** to view the infrastructure resources associated with your cluster.  3. Select the **load balancer instance** to bring up the Azure portal page for load balancer.  4. Navigate to the **Alerts** page to create your load balancer metric alert. |
| Logs and Events | To alert on logs and events, you need to enable Container Insights. For more information, see [Azure Monitor resource logs](monitor-aks#azure-monitor-resource-logs). | For guidance on creating alerts on logs and events, see [Create log search alerts from Container insights](/en-us/azure/azure-monitor/containers/container-insights-log-alerts). |

## Critical signals for configuring alerts

To get holistic coverage of your AKS environment, you need to configure alerts on the three main components of your cluster:

- **Cluster infrastructure**: Alerts targeting the underlying infrastructure of your cluster such as nodes, disks, and networking.
- **Application health**: Alerts for monitoring the health of your pods and applications. Some common indicators of unhealthy applications include out-of-memory kills (OOMKills) of your pods, pods in not ready state, etc.
- **Kubernetes control plane**: Alerts on AKS control plane to monitor the health and performance of the API server, etcd, and other components.

The following sections contain the key signals which we recommend all AKS customers monitor closely. The AKS team is working to add all critical signals to the existing [Recommended Alerts](/en-us/azure/azure-monitor/containers/kubernetes-metric-alerts) feature, which allows you to easily enable alerts for all signals with a one-click experience. The Prometheus metrics alerts are available in Public Preview today, and the remaining alerts are estimated to be available in early 2025. For now, you can manually configure alerts on the critical signals.

### Cluster infrastructure alerts

| Alert scenario | Source | Signal | Recommended threshold |
| --- | --- | --- | --- |
| Cluster is in a failed state | Azure Activity Logs | Create or update managed cluster | Status of the log is Failed, indicating that the cluster upgrade or creation action failed. |
| Node pool is in a failed state | Azure Activity Logs | Create or update agent pool | Status of the log is Failed, indicating that the node pool is in a Failed state due to a failed Create, Read, Upgrade, or Delete (CRUD) operation. |
| High Node OS Disk Bandwidth Usage | Virtual Machine Scale Set Metric | OS Disk Bandwidth Consumed Percentage | Node OS disk bandwidth utilization is above 95%. |
| High Node OS Disk IOPS Usage | Virtual Machine Scale Set Metric | OS Disk IOPS Consumed Percentage | Node OS disk IOPS utilization is above 95%. |
| High Node OS Disk Space Usage | AKS Platform Metric | Disk Used Percentage | Node OS disk space percentage utilization is above 90%. |
| High Node CPU Usage | AKS Platform Metric | CPU Usage Percentage | Node CPU Usage is greater than 90%. |
| High Node Memory Usage | AKS Platform Metric | Memory Working Set Percentage | Node Memory Usage is greater than 90%. |
| Node is in NotReady state | AKS Platform Metric | Status for various node conditions | Node is in NotReady state for &gt;20 minutes. |
| SNAT port exhaustion | Load Balancer (LB) Metric | SNAT Connection Count | Filter for Connection State = "Failed" |

### Application health alerts

| Alert scenario | Source | Signal | Recommended threshold |
| --- | --- | --- | --- |
| High number of unhealthy pods | Azure Managed Prometheus Metric | Alert name: KubePodReadyStateLow | Available as an AKS recommended alert. To enable this alert, see [Recommended alert rules for Kubernetes clusters](/en-us/azure/azure-monitor/containers/kubernetes-metric-alerts?tabs=portal). |
| One or more pods are restarting | Azure Managed Prometheus Metric | Alert name: KubePodContainerRestart | Available as an AKS recommended alert. To enable this alert, see [Recommended alert rules for Kubernetes clusters](/en-us/azure/azure-monitor/containers/kubernetes-metric-alerts?tabs=portal). |
| One or more pods are in CrashLoop status | Azure Managed Prometheus Metric | Alert name: KubePodCrashLooping | Available as an AKS recommended alert. To enable this alert, see [Recommended alert rules for Kubernetes clusters](/en-us/azure/azure-monitor/containers/kubernetes-metric-alerts?tabs=portal). |

### Kubernetes control plane alerts

| Alert scenario | Source | Signal | Recommended threshold |
| --- | --- | --- | --- |
| ETCD is Filled Up | Azure Managed Prometheus Metric | etcd\_mvcc\_db\_total\_size\_in\_use\_in\_bytes | ETCD utilization is greater than 2 GB |
| API Server Too Many Requests Errors | Azure Managed Prometheus Metric | apiserver\_request\_total | Filter for error code 429 |
| API Server Webhook and Tunnel Errors | Azure Managed Prometheus Metric | apiserver\_request\_total | Filter for error codes 500 and 503 |