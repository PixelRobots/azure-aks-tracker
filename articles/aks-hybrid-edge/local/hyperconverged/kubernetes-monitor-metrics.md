---
layout: Conceptual
title: Metrics and monitoring logs in AKS | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-metrics
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
ms.service: azure-kubernetes-service-hybrid
description: Learn about metrics and logs used to monitor Kubernetes clusters in AKS.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2024-03-28T00:00:00.0000000Z
ms.reviewer: haojiehang
ms.custom: hyperconverged
locale: en-us
document_id: 08013f21-e314-bf4d-a7e5-bad77843df5d
document_version_independent_id: a631c3f3-e09b-1f4b-6643-d9ba29cd9fa2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-metrics.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-metrics
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-metrics.md
platformId: 94f33dfd-6273-5b05-15a3-c9889b3a943a
---

# Metrics and monitoring logs in AKS | Microsoft Learn

This article provides an overview of the metrics and logs used to monitor Kubernetes clusters in AKS.

## Metrics

### Platform Metrics

The following table lists the platform metrics supported for AKS. To view these basic platform metrics, you can install the observability extension on your Kubernetes cluster and wait a few minutes to start the automatic metrics ingestion. Follow each link for a detailed list of the metrics for each particular type:

| Metric type | Resource provider/type namespace |
| --- | --- |
| Provisioned clusters | [Microsoft.HybridContainerService/provisionedClusters](/en-us/azure/azure-monitor/reference/supported-metrics/microsoft-hybridcontainerservice-provisionedclusters-metrics) |
| Connected clusters | [Microsoft.Kubernetes/connectedClusters](/en-us/azure/azure-monitor/reference/supported-metrics/microsoft-kubernetes-connectedclusters-metrics) |

### Prometheus Metrics

To view more granular metrics, it's recommended that you enable the Managed Prometheus extension in your Kubernetes, and then query Prometheus metrics in Metrics Explorer or Managed Grafana. For the extension onboarding instructions, [see this article](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=cli#enable-prometheus-and-grafana).

## Azure Monitor Logs

AKS supports two types of logs: Control Plane logs implemented as resource logs, and container insights logs. For more information about exporting control plane logs such as audit logs using diagnostic settings, see [Monitor Kubernetes audit events](/en-us/azure/aks/hybrid/kubernetes-monitor-audit-events). For more information about enabling container insights, see [Enable Container Insights](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=cli).

### Control Plane Logs

The following table lists the log categories available for AKS. You can also see this table in the [Azure Monitor resource log reference](/en-us/azure/azure-monitor/reference/supported-logs/microsoft-kubernetes-connectedclusters-logs):

| Category | Description | Table (resource-specific mode) |
| --- | --- | --- |
| kube-apiserver | Logs from the API server. | ArcK8SControlPlane |
| kube-audit | Audit log data for every audit event including get, list, create, update, delete, patch, and post. | ArcK8SAudit |
| kube-audit-admin | Subset of the kube-audit log category. Significantly reduces the number of logs by excluding the get and list audit events from the log. | ArcK8SAuditAdmin |
| kube-controller-manager | Gain deeper visibility into issues that can arise between Kubernetes and the Azure control plane. A typical example is when the AKS cluster has insufficient permissions to interact with Azure. | ArcK8SControlPlane |
| kube-scheduler | Logs from the scheduler. | ArcK8SControlPlane |
| cluster-autoscaler | Understand why the AKS cluster is scaled up or down, which might not be expected. This information is also useful to correlate time intervals during which something interesting might have happened in the cluster. | ArcK8SControlPlane |
| cloud-controller-manager | Logs from the cloud-node-manager component of the Kubernetes cloud controller manager. | ArcK8SControlPlane |
| guard | Managed Microsoft Entra ID and Azure RBAC audits. For managed Microsoft Entra ID, this category includes token in and user info out. For Azure RBAC, it includes access reviews in and out. | ArcK8SControlPlane |
| csi-aksarcdisk-controller | Logs from the AKS CSI storage driver. | ArcK8SControlPlane |
| csi-aksarcsmb-controller | Logs from the AKS SMB CSI storage driver. | ArcK8SControlPlane |
| csi-aksarcnfs-controller | Logs from the AKS NFS CSI storage driver. | ArcK8SControlPlane |

For more information, see the list of [all resource log category types supported in Azure Monitor](/en-us/azure/azure-monitor/essentials/resource-logs-schema).

### Azure Monitor log tables

You can analyze both the control plane logs and the container insights in Log Analytics Workspace. See the Log Analytics tables in the [Azure Monitor Reference](/en-us/azure/azure-monitor/reference/tables-index#azure-arc-enabled-kubernetes).

## Activity log

The following table lists a few example operations related to AKS that might be created in the activity log. Use the activity log to track information such as when a cluster is created, or had its configuration change. You can view this information in the portal or by using other methods. You can also use it to create an activity log alert to be proactively notified when an event occurs:

| Resource Type | Notes |
| --- | --- |
| [ProvisionedClusterInstances](/en-us/rest/api/hybridcontainer/provisioned-cluster-instances) | Follow this link for a list and descriptions of operations used in AKS. |