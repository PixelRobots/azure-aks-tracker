---
layout: Conceptual
title: Monitoring data reference for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/monitor-aks-reference
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
description: This article contains important reference material you need when you monitor Azure Kubernetes Service (AKS) by using Azure Monitor.
ms.date: 2024-09-06T00:00:00.0000000Z
ms.custom: horz-monitor
ms.topic: reference
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-monitoring
ai-usage: ai-assisted
locale: en-us
document_id: 58ce77de-7ec0-eae5-5cf4-617af230630c
document_version_independent_id: 73b5fefa-452d-44b1-3631-9aa9ed8ed720
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/monitor-aks-reference.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/monitor-aks-reference
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/monitor-aks-reference.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/1ae5c491-970a-4062-8301-6336e69f9026
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/12ed19f9-ebdf-4c8a-8bcd-7a681836774d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/f2c3e52e-3667-4e8a-bf11-20b9eaccdc8c
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/3a764584-4f97-452b-8f1d-36f19b12f6ae
platformId: d9d15e90-a585-245a-2aa4-dc96190c4eb6
---

# Monitoring data reference for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn

This article contains all the monitoring reference information for this service.

See [Monitor Azure Kubernetes Service (AKS)](monitor-aks) for details on the data you can collect for AKS and how to use it.

## Metrics

This section lists all the automatically collected platform metrics for this service. These metrics are also part of the global list of [all platform metrics supported in Azure Monitor](/en-us/azure/azure-monitor/reference/supported-metrics/metrics-index#supported-metrics-per-resource-type).

For information on metric retention, see [Azure Monitor Metrics overview](/en-us/azure/azure-monitor/essentials/data-platform-metrics#retention-of-metrics).

### Supported metrics for Microsoft.ContainerService/managedClusters

The following table lists the metrics available for the Microsoft.ContainerService/managedClusters resource type.

- All columns might not be present in every table.
- Some columns might be beyond the viewing area of the page. Select **Expand table** to view all available columns.

**Table headings**

- **Category** - The metrics group or classification.
- **Metric** - The metric display name as it appears in the Azure portal.
- **Name in REST API** - The metric name as referred to in the [REST API](/en-us/azure/azure-monitor/essentials/rest-api-walkthrough).
- **Unit** - Unit of measure.
- **Aggregation** - The default [aggregation](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained) type. Valid values: Average (Avg), Minimum (Min), Maximum (Max), Total (Sum), Count.
- **Dimensions** - [Dimensions](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#dimensions-splitting-and-filtering) available for the metric.
- **Time Grains** - [Intervals](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#granularity) at which the metric is sampled. For example, `PT1M` indicates that the metric is sampled every minute, `PT30M` every 30 minutes, `PT1H` every hour, and so on.
- **DS Export**- Whether the metric is exportable to Azure Monitor Logs via diagnostic settings. For information on exporting metrics, see [Create diagnostic settings in Azure Monitor](/en-us/azure/azure-monitor/essentials/create-diagnostic-settings?tabs=portal).

Important

The `pod` dimension for the AKS platform metrics `kube_pod_status_ready` and `kube_pod_status_phase` will be retired on September 30, 2027. To continue using the `pod` dimension in these metrics after the retirement date, use [Azure Monitor managed service for Prometheus](/en-us/azure/azure-monitor/metrics/prometheus-metrics-overview).

### Category: API Server

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **API Server CPU Usage Percentage**Maximum CPU percentage (based off current limit) used by API server pod across instances | `apiserver_cpu_usage_percentage` | No | Percent | Maximum, Average | &lt;none&gt; | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **API Server Memory Usage Percentage**Maximum memory percentage (based off current limit) used by API server pod across instances | `apiserver_memory_usage_percentage` | No | Percent | Maximum, Average | &lt;none&gt; | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |

### Category: API Server (PREVIEW)

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Inflight Requests**Maximum number of currently used inflight requests on the apiserver per request kind in the last second | `apiserver_current_inflight_requests` | No | Count | Total (Sum), Average | `requestKind` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |
| **API Request Concurrency**Current number of API Priority and Fairness execution seats being used by the API server. | `apiserver_flowcontrol_executing_seats` | No | Count | Total (Sum), Average | `priority_level` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |

### Category: Cluster Autoscaler (PREVIEW)

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Cluster Health**Determines whether or not cluster autoscaler will take action on the cluster | `cluster_autoscaler_cluster_safe_to_autoscale` | No | Count | Total (Sum), Average | &lt;none&gt; | PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |
| **Scale Down Cooldown**Determines if the scale down is in cooldown - No nodes will be removed during this timeframe | `cluster_autoscaler_scale_down_in_cooldown` | No | Count | Total (Sum), Average | &lt;none&gt; | PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |
| **Unneeded Nodes**Cluster auotscaler marks those nodes as candidates for deletion and are eventually deleted | `cluster_autoscaler_unneeded_nodes_count` | No | Count | Total (Sum), Average | &lt;none&gt; | PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |
| **Unschedulable Pods**Number of pods that are currently unschedulable in the cluster | `cluster_autoscaler_unschedulable_pods_count` | No | Count | Total (Sum), Average | &lt;none&gt; | PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |

### Category: ETCD

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **ETCD CPU Usage Percentage**Maximum CPU percentage (based off current limit) used by ETCD pod across instances | `etcd_cpu_usage_percentage` | No | Percent | Maximum, Average | `partition` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **ETCD Database Usage Percentage**Maximum utilization of the ETCD database across instances | `etcd_database_usage_percentage` | No | Percent | Maximum, Average | `partition` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **ETCD Memory Usage Percentage**Maximum memory percentage (based off current limit) used by ETCD pod across instances | `etcd_memory_usage_percentage` | No | Percent | Maximum, Average | `partition` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |

### Category: Nodes

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Total number of available cpu cores in a managed cluster**Total number of available cpu cores in a managed cluster | `kube_node_status_allocatable_cpu_cores` | No | Count | Total (Sum), Average | &lt;none&gt; | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |
| **Total amount of available memory in a managed cluster**Total amount of available memory in a managed cluster | `kube_node_status_allocatable_memory_bytes` | No | Bytes | Total (Sum), Average | &lt;none&gt; | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |
| **Statuses for various node conditions**Statuses for various node conditions | `kube_node_status_condition` | No | Count | Total (Sum), Average | `condition`, `status`, `status2`, `node` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |

### Category: Nodes (PREVIEW)

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **CPU Usage Millicores**Aggregated measurement of CPU utilization in millicores across the cluster | `node_cpu_usage_millicores` | No | MilliCores | Maximum, Average | `node`, `nodepool` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **CPU Usage Percentage**Aggregated average CPU utilization measured in percentage across the cluster | `node_cpu_usage_percentage` | No | Percent | Maximum, Average | `node`, `nodepool` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **Disk Used Bytes**Disk space used in bytes by device | `node_disk_usage_bytes` | No | Bytes | Maximum, Average | `node`, `nodepool`, `device` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **Disk Used Percentage**Disk space used in percent by device | `node_disk_usage_percentage` | No | Percent | Maximum, Average | `node`, `nodepool`, `device` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **Memory RSS Bytes**Container RSS memory used in bytes | `node_memory_rss_bytes` | No | Bytes | Maximum, Average | `node`, `nodepool` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **Memory RSS Percentage**Container RSS memory used in percent | `node_memory_rss_percentage` | No | Percent | Maximum, Average | `node`, `nodepool` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **Memory Working Set Bytes**Container working set memory used in bytes | `node_memory_working_set_bytes` | No | Bytes | Maximum, Average | `node`, `nodepool` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **Memory Working Set Percentage**Container working set memory used in percent | `node_memory_working_set_percentage` | No | Percent | Maximum, Average | `node`, `nodepool` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **Network In Bytes**Network received bytes | `node_network_in_bytes` | No | Bytes | Maximum, Average | `node`, `nodepool` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **Network Out Bytes**Network transmitted bytes | `node_network_out_bytes` | No | Bytes | Maximum, Average | `node`, `nodepool` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |

### Category: Pods

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Number of pods by phase**Number of pods by phase | `kube_pod_status_phase` | No | Count | Total (Sum), Average | `phase`, `namespace`, `pod` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |
| **Number of pods in Ready state**Number of pods in Ready state | `kube_pod_status_ready` | No | Count | Total (Sum), Average | `namespace`, `pod`, `condition` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |

### Category: Scheduler (PREVIEW)

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Pod Scheduling Rate**Number of scheduler attempts over time, including outcome breakdowns such as scheduled and unschedulable. | `scheduler_schedule_attempts_rate` | No | CountPerSecond | Average | `result` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | No |

### Supported metrics for microsoft.kubernetes/connectedClusters

The following table lists the metrics available for the microsoft.kubernetes/connectedClusters resource type.

- All columns might not be present in every table.
- Some columns might be beyond the viewing area of the page. Select **Expand table** to view all available columns.

**Table headings**

- **Category** - The metrics group or classification.
- **Metric** - The metric display name as it appears in the Azure portal.
- **Name in REST API** - The metric name as referred to in the [REST API](/en-us/azure/azure-monitor/essentials/rest-api-walkthrough).
- **Unit** - Unit of measure.
- **Aggregation** - The default [aggregation](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained) type. Valid values: Average (Avg), Minimum (Min), Maximum (Max), Total (Sum), Count.
- **Dimensions** - [Dimensions](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#dimensions-splitting-and-filtering) available for the metric.
- **Time Grains** - [Intervals](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#granularity) at which the metric is sampled. For example, `PT1M` indicates that the metric is sampled every minute, `PT30M` every 30 minutes, `PT1H` every hour, and so on.
- **DS Export**- Whether the metric is exportable to Azure Monitor Logs via diagnostic settings. For information on exporting metrics, see [Create diagnostic settings in Azure Monitor](/en-us/azure/azure-monitor/essentials/create-diagnostic-settings?tabs=portal).

### Category: Availability

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Total number of cpu cores in a connected cluster**Total number of cpu cores in a connected cluster | `capacity_cpu_cores` | No | Count | Total (Sum), Average | &lt;none&gt; | PT1M | Yes |
| **Cluster Connectivity Status**Indicates whether the Azure Arc-enabled Kubernetes cluster is connected. A value of 1 is reported while the cluster is connected and syncing metadata; no data is reported while the cluster is not connected. | `ConnectivityStatus` | No | Count | Maximum, Average, Total (Sum) | &lt;none&gt; | PT1M | Yes |

### Category: Nodes (PREVIEW)

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **CPU Usage Percentage**Aggregated average CPU utilization measured in percentage across the cluster | `node_cpu_usage_percentage` | No | Percent | Maximum, Average | `node`, `nodepool` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **Disk Used Percentage**Disk space used in percent by device | `node_disk_usage_percentage` | No | Percent | Maximum, Average | `node`, `nodepool`, `device` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **Memory RSS Percentage**Container RSS memory used in percent | `node_memory_rss_percentage` | No | Percent | Maximum, Average | `node`, `nodepool` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |
| **Memory Working Set Percentage**Container working set memory used in percent | `node_memory_working_set_percentage` | No | Percent | Maximum, Average | `node`, `nodepool` | PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H | Yes |

### Supported metrics for microsoft.kubernetesconfiguration/extensions

The following table lists the metrics available for the microsoft.kubernetesconfiguration/extensions resource type.

- All columns might not be present in every table.
- Some columns might be beyond the viewing area of the page. Select **Expand table** to view all available columns.

**Table headings**

- **Category** - The metrics group or classification.
- **Metric** - The metric display name as it appears in the Azure portal.
- **Name in REST API** - The metric name as referred to in the [REST API](/en-us/azure/azure-monitor/essentials/rest-api-walkthrough).
- **Unit** - Unit of measure.
- **Aggregation** - The default [aggregation](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained) type. Valid values: Average (Avg), Minimum (Min), Maximum (Max), Total (Sum), Count.
- **Dimensions** - [Dimensions](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#dimensions-splitting-and-filtering) available for the metric.
- **Time Grains** - [Intervals](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#granularity) at which the metric is sampled. For example, `PT1M` indicates that the metric is sampled every minute, `PT30M` every 30 minutes, `PT1H` every hour, and so on.
- **DS Export**- Whether the metric is exportable to Azure Monitor Logs via diagnostic settings. For information on exporting metrics, see [Create diagnostic settings in Azure Monitor](/en-us/azure/azure-monitor/essentials/create-diagnostic-settings?tabs=portal).

### Category: Errors

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **File Sync Errors**Number of file sync errors | `FileSyncErrors` | No | Count | Total (Sum), Average, Count | `volume_name`, `subvolume_name`, `transfer_mode`, `status` | PT1M | No |

### Category: Latency

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Agent API Duration**Latency of agent application operations in milliseconds | `AgentApiDuration` | No | Milliseconds | Average | `AppId`, `Operation`, `ResultType`, `Result`, `AgentId`, `ToolName` | PT1M | No |
| **Api Request Duration in Seconds**Histogram of request durations | `ApiRequestDurationSeconds` | No | Seconds | Average | `AppName`, `GpuEnabled`, `Method`, `Route` | PT1M | No |
| **Ingestion Time**Total ingestion time in minutes | `IngestionTimeMinutes` | No | Seconds | Average | `AppName`, `GpuEnabled` | PT1M | No |
| **Input Preprocessing Time (Milliseconds)**Input preprocessing time in milliseconds | `InputPreprocessingTimeMilliseconds` | No | Milliseconds | Average | `GpuEnabled` | PT1M | No |
| **Knowledge API Duration**Latency of RAG backend operations in milliseconds | `KnowledgeApiDuration` | No | Milliseconds | Average | `AppId`, `Operation`, `ResultType`, `Result`, `CollectionName` | PT1M | No |
| **Knowledge Embedding Duration**Embedding generation latency in milliseconds | `KnowledgeEmbeddingDuration` | No | Milliseconds | Average | `AppId`, `Operation`, `ResultType`, `Result` | PT1M | No |
| **Knowledge File Transfer Duration**File transfer and download latency in milliseconds | `KnowledgeFileDuration` | No | Milliseconds | Average | `AppId`, `Operation`, `FileType`, `ResultType`, `Result`, `CollectionName` | PT1M | No |
| **Knowledge Insert Duration**Bulk vector insertion latency in milliseconds | `KnowledgeInsertDuration` | No | Milliseconds | Average | `AppId`, `Operation`, `ResultType`, `Result`, `CollectionName`, `EntityType`, `EmbeddingModel` | PT1M | No |
| **Knowledge Search Duration**Vector, text, and image search latency in milliseconds | `KnowledgeSearchDuration` | No | Milliseconds | Average | `AppId`, `Operation`, `SearchType`, `ResultType`, `Result`, `CollectionName`, `TopK` | PT1M | No |
| **Call LLM Total Time in Seconds**Total call\_llm time in seconds | `TotalCallLLMTimeSeconds` | No | Seconds | Average | `AppName`, `GpuEnabled`, `LLMProvider`, `OutputLength` | PT1M | No |
| **Embedding Generation Total Time in Seconds**Total time taken to generate embeddings from local model | `TotalGenerateEmbeddingsTimeSeconds` | No | Seconds | Average | `AppName`, `GpuEnabled`, `InputLength`, `OutputLength` | PT1M | No |
| **Hybrid Search Embedding Generation Total Time in Seconds**Total time taken to generate Hybrid Search embeddings from local model | `TotalGenerateHybridSearchEmbeddingsTimeSeconds` | No | Seconds | Average | `AppName`, `GpuEnabled`, `InputLength`, `OutputLength` | PT1M | No |
| **Reranking Generation Total Time in Seconds**Total time taken to generate Reranking | `TotalGenerateRerankingTimeSeconds` | No | Seconds | Average | `AppName`, `GpuEnabled`, `InputLength`, `OutputLength` | PT1M | No |
| **Get Chat History Summary Total Time in Milliseconds**Total get\_chat\_history\_summary time in milliseconds | `TotalGetChatHistorySummaryTimeMilliseconds` | No | Milliseconds | Average | `AppName`, `GpuEnabled`, `InputHistoryPairs`, `LLMProvider`, `MaxTokens`, `OutputLength`, `Temperature`, `TopP` | PT1M | No |
| **Get LLM Payload Total Time in Milliseconds**Total get\_llm\_payload time in milliseconds | `TotalGetLLMPayloadTimeMilliseconds` | No | Milliseconds | Average | `AppName`, `DiversityPenalty`, `GpuEnabled`, `LengthPenalty`, `LLMProvider`, `MaxTokens`, `RepetitionPenalty`, `Temperature`, `TopP` | PT1M | No |
| **Get Hybrid Search Total Time in Milliseconds**Total hybrid search time in milliseconds | `TotalHybridSearchTimeMilliseconds` | No | Milliseconds | Average | `AppName`, `ChunkMinScore`, `GpuEnabled`, `IndexType`, `InputLength`, `MetricType`, `TopK` | PT1M | No |
| **Inference Total Time in Seconds**Total inference time in seconds | `TotalInferenceTimeSeconds` | No | Seconds | Average | `AppName`, `DiversityPenalty`, `GpuEnabled`, `InputLength`, `LLMProvider`, `MaxTokens`, `OutputLength`, `RepetitionPenalty`, `Temperature`, `TopK` | PT1M | No |
| **Chunks Search Total Time in Milliseconds**Total search chunks time in milliseconds | `TotalSearchChunksTimeMilliseconds` | No | Milliseconds | Average | `AppName`, `EmbeddingIndexName`, `GpuEnabled`, `InputLength`, `OutputChunks`, `TopK` | PT1M | No |
| **Search Total Time in Milliseconds**Total time taken to search | `TotalSearchTimeMilliseconds` | No | Milliseconds | Average | `AppName`, `ChunkMinScore`, `GpuEnabled`, `InputLength`, `QueryType`, `TopK` | PT1M | No |
| **Similarity Search Total Time in Milliseconds**Total time taken to search for similar documents | `TotalSimilaritySearchTimeMilliseconds` | No | Milliseconds | Average | `AppName`, `GpuEnabled`, `InputLength`, `ChunkMinScore`, `IndexType`, `MetricType`, `TopK` | PT1M | No |

### Category: Saturation

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Edgevolume Percentage Space Available**Percentage of available space on Edgevolume | `EdgevolumePercentageSpaceAvailable` | No | Percent | Average, Minimum, Maximum | `edgevolume_name` | PT1M | No |
| **Edgevolume Space Available**Bytes of available space on Edgevolume | `EdgevolumeSpaceAvailable` | No | Bytes | Total (Sum), Average, Minimum, Maximum | `edgevolume_name` | PT1M | No |
| **Edgevolume Space Total**Bytes of total space on Edgevolume | `EdgevolumeSpaceTotal` | No | Bytes | Total (Sum), Average, Minimum, Maximum | `edgevolume_name` | PT1M | No |

### Category: Traffic

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Active PDU Sessions**Number of Active PDU Sessions | `ActiveSessionCount` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | No |
| **Agent Concurrent Runs**Number of currently active agent runs | `AgentConcurrentRuns` | No | Count | Average | `AppId`, `AgentId` | PT1M | No |
| **Agent LLM Token Consumption**Total LLM tokens consumed by agent operations | `AgentLlmTokens` | No | Count | Total (Sum) | `ResultType`, `Result`, `AgentId` | PT1M | No |
| **Agent Tool Invocations**Number of tool invocations per agent | `AgentToolsInvocationCount` | No | Count | Count | `AppId`, `Operation`, `AgentId`, `ToolName`, `ResultType`, `Result` | PT1M | No |
| **API Failure Count**Count of failed API requests | `ApiFailureCount` | No | Count | Count | `EndpointName`, `GpuEnabled`, `StatusCode` | PT1M | No |
| **API Request Count**Total number of API requests | `ApiRequestCount` | No | Count | Count | `AppName`, `GpuEnabled`, `Method`, `Route` | PT1M | No |
| **API Success Count**Count of successful API requests | `ApiSuccessCount` | No | Count | Count | `EndpointName`, `GpuEnabled`, `StatusCode` | PT1M | No |
| **Authentication Attempts**Authentication attempts rate (per minute) | `AuthAttempt` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Authentication Failures**Authentication failure rate (per minute) | `AuthFailure` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId`, `Result` | PT1M | Yes |
| **Authentication Successes**Authentication success rate (per minute) | `AuthSuccess` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Connected NodeBs**Number of connected gNodeBs or eNodeBs | `ConnectedNodebs` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **DeRegistration Attempts**UE deregistration attempts rate (per minute) | `DeRegistrationAttempt` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **DeRegistration Successes**UE deregistration success rate (per minute) | `DeRegistrationSuccess` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Evaluation API Request Count**Total number of Evaluation API requests | `EvaluationApiRequestCount` | No | Count | Count | `AppName`, `Method`, `Route` | PT1M | No |
| **Failed Skipped Count**Count of failed or skipped files | `FailedSkippedCount` | No | Count | Count | `Category`, `GpuEnabled` | PT1M | No |
| **File Ingestion Rate**Total files ingested per Job | `FileIngestionRate` | No | Count | Total (Sum) | `AppName`, `GpuEnabled`, `FileType`, `JobID` | PT1M | No |
| **File Sync Count**Number of files successfully synchronized | `FileSyncCount` | No | Count | Total (Sum), Average, Count | `volume_name`, `subvolume_name`, `transfer_mode` | PT1M | No |
| **Hybrid Search Model API Request Count**Total number of Hybrid Search Model API requests | `HybridSearchModelApiRequestCount` | No | Count | Count | `AppName`, `Method`, `Route` | PT1M | No |
| **Inference Answer Feedback**Inference Answer Feedback | `InferenceAnswerFeedback` | No | Count | Count | `AppName`, `ChunkMinScore`, `ChunkScores`, `GpuEnabled`, `LLMProvider`, `RunId`, `Thumb` | PT1M | No |
| **Inference API Request Count**Number of Inference API requests | `InferenceApiRequestCount` | No | Count | Count | `AppName`, `Method`, `Route` | PT1M | No |
| **Ingestion API Request Count**Number of Ingestion API requests | `IngestionApiRequestCount` | No | Count | Count | `AppName`, `Method`, `Route` | PT1M | No |
| **Knowledge Ingestion Queue Size**Number of ingestion jobs waiting in the queue | `KnowledgeIngestionQueueSize` | No | Count | Average | `AppId`, `CollectionName` | PT1M | No |
| **Number of Evaluations**Number of Evaluations | `NumberOfEvaluations` | No | Count | Count | `AppName`, `GpuEnabled`, `Method`, `Route` | PT1M | No |
| **Number of Jobs**Number of jobs | `NumberOfJobs` | No | Count | Count | `AppName`, `GpuEnabled`, `Method`, `Route` | PT1M | No |
| **Paging Attempts**Paging attempts rate (per minute) | `PagingAttempt` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Paging Failures**Paging failure rate (per minute) | `PagingFailure` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Provisioned Subscribers**Number of provisioned subscribers | `ProvisionedSubscribers` | No | Count | Total (Sum) | `PccpId`, `SiteId` | PT1M | No |
| **RAN Setup Failures**RAN setup failure rate (per minute) | `RanSetupFailure` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId`, `Cause` | PT1M | Yes |
| **RAN Setup Requests**RAN setup reuests rate (per minute) | `RanSetupRequest` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **RAN Setup Responses**RAN setup response rate (per minute) | `RanSetupResponse` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Registered Subscribers**Number of registered subscribers | `RegisteredSubscribers` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Registered Subscribers Connected**Number of registered and connected subscribers | `RegisteredSubscribersConnected` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Registered Subscribers Idle**Number of registered and idle subscribers | `RegisteredSubscribersIdle` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Registration Attempts**Registration attempts rate (per minute) | `RegistrationAttempt` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Registration Failures**Registration failure rate (per minute) | `RegistrationFailure` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId`, `Result` | PT1M | Yes |
| **Registration Successes**Registration success rate (per minute) | `RegistrationSuccess` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Service Request Attempts**Service request attempts rate (per minute) | `ServiceRequestAttempt` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Service Request Failures**Service request failure rate (per minute) | `ServiceRequestFailure` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId`, `Result`, `Tai` | PT1M | Yes |
| **Service Request Successes**Service request success rate (per minute) | `ServiceRequestSuccess` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Session Establishment Attempts**PDU session establishment attempts rate (per minute) | `SessionEstablishmentAttempt` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId`, `Dnn` | PT1M | Yes |
| **Session Establishment Failures**PDU session establishment failure rate (per minute) | `SessionEstablishmentFailure` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId`, `Dnn` | PT1M | Yes |
| **Session Establishment Successes**PDU session establishment success rate (per minute) | `SessionEstablishmentSuccess` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId`, `Dnn` | PT1M | Yes |
| **Session Releases**Session release rate (per minute) | `SessionRelease` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **UE Context Release Commands**UE context release command message rate (per minute) | `UeContextReleaseCommand` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **UE Context Release Completes**UE context release complete message rate (per minute) | `UeContextReleaseComplete` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **UE Context Release Requests**UE context release request message rate (per minute) | `UeContextReleaseRequest` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **User Plane Bandwidth**User plane bandwidth in bits/second. | `UserPlaneBandwidth` | No | BitsPerSecond | Total (Sum) | `PcdpId`, `SiteId`, `Direction`, `Interface` | PT1M | No |
| **User Plane Packet Drop Rate**User plane packet drop rate (packets/sec) | `UserPlanePacketDropRate` | No | CountPerSecond | Total (Sum) | `PcdpId`, `SiteId`, `Cause`, `Direction`, `Interface` | PT1M | No |
| **User Plane Packet Rate**User plane packet rate (packets/sec) | `UserPlanePacketRate` | No | CountPerSecond | Total (Sum) | `PcdpId`, `SiteId`, `Direction`, `Interface` | PT1M | No |
| **VectorDB API Request Count**Total number of API requests to VectorDB | `VectorDbApiRequestCount` | No | Count | Count | `AppName`, `Method`, `Route` | PT1M | No |
| **Xn Handover Attempts**Handover attempts rate (per minute) | `XnHandoverAttempt` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Xn Handover Failures**Handover failure rate (per minute) | `XnHandoverFailure` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |
| **Xn Handover Successes**Handover success rate (per minute) | `XnHandoverSuccess` | No | Count | Total (Sum) | `3gppGen`, `PccpId`, `SiteId` | PT1M | Yes |

### Supported metrics for Microsoft.Compute/virtualMachines

The following table lists the metrics available for the Microsoft.Compute/virtualMachines resource type.

- All columns might not be present in every table.
- Some columns might be beyond the viewing area of the page. Select **Expand table** to view all available columns.

**Table headings**

- **Category** - The metrics group or classification.
- **Metric** - The metric display name as it appears in the Azure portal.
- **Name in REST API** - The metric name as referred to in the [REST API](/en-us/azure/azure-monitor/essentials/rest-api-walkthrough).
- **Unit** - Unit of measure.
- **Aggregation** - The default [aggregation](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained) type. Valid values: Average (Avg), Minimum (Min), Maximum (Max), Total (Sum), Count.
- **Dimensions** - [Dimensions](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#dimensions-splitting-and-filtering) available for the metric.
- **Time Grains** - [Intervals](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#granularity) at which the metric is sampled. For example, `PT1M` indicates that the metric is sampled every minute, `PT30M` every 30 minutes, `PT1H` every hour, and so on.
- **DS Export**- Whether the metric is exportable to Azure Monitor Logs via diagnostic settings. For information on exporting metrics, see [Create diagnostic settings in Azure Monitor](/en-us/azure/azure-monitor/essentials/create-diagnostic-settings?tabs=portal).

### Category: Other

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Available Memory Bytes**Amount of physical memory, in bytes, immediately available for allocation to a process or for system use in the Virtual Machine | `Available Memory Bytes` | No | Bytes | Average | &lt;none&gt; | PT1M | Yes |
| **Available Memory Percentage**Amount of physical memory, in percentage, immediately available for allocation to a process or for system use in the Virtual Machine | `Available Memory Percentage` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **CPU Credits Consumed**Total number of credits consumed by the Virtual Machine. Only available on B-series burstable VMs | `CPU Credits Consumed` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **CPU Credits Remaining**Total number of credits available to burst. Only available on B-series burstable VMs | `CPU Credits Remaining` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **Data Disk Bandwidth Consumed Percentage**Percentage of data disk bandwidth consumed per minute. Only available on VM series that support premium storage. | `Data Disk Bandwidth Consumed Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Data Disk IOPS Consumed Percentage**Percentage of data disk I/Os consumed per minute. Only available on VM series that support premium storage. | `Data Disk IOPS Consumed Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Data Disk Latency**Average time to complete each IO during monitoring period for Data Disk. Values are in milliseconds. | `Data Disk Latency` | No | Milliseconds | Average | `LUN` | PT1M | Yes |
| **Data Disk Max Burst Bandwidth**Maximum bytes per second throughput Data Disk can achieve with bursting | `Data Disk Max Burst Bandwidth` | No | Count | Average | `LUN` | PT1M | Yes |
| **Data Disk Max Burst IOPS**Maximum IOPS Data Disk can achieve with bursting | `Data Disk Max Burst IOPS` | No | Count | Average | `LUN` | PT1M | Yes |
| **Data Disk Queue Depth**Data Disk Queue Depth(or Queue Length) | `Data Disk Queue Depth` | No | Count | Average | `LUN` | PT1M | Yes |
| **Data Disk Read Bytes/Sec**Bytes/Sec read from a single disk during monitoring period | `Data Disk Read Bytes/sec` | No | BytesPerSecond | Average | `LUN` | PT1M | Yes |
| **Data Disk Read Operations/Sec**Read IOPS from a single disk during monitoring period | `Data Disk Read Operations/Sec` | No | CountPerSecond | Average | `LUN` | PT1M | Yes |
| **Data Disk Target Bandwidth**Baseline bytes per second throughput Data Disk can achieve without bursting | `Data Disk Target Bandwidth` | No | Count | Average | `LUN` | PT1M | Yes |
| **Data Disk Target IOPS**Baseline IOPS Data Disk can achieve without bursting | `Data Disk Target IOPS` | No | Count | Average | `LUN` | PT1M | Yes |
| **Data Disk Used Burst BPS Credits Percentage**Percentage of Data Disk burst bandwidth credits used so far | `Data Disk Used Burst BPS Credits Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Data Disk Used Burst IO Credits Percentage**Percentage of Data Disk burst I/O credits used so far | `Data Disk Used Burst IO Credits Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Data Disk Write Bytes/Sec**Bytes/Sec written to a single disk during monitoring period | `Data Disk Write Bytes/sec` | No | BytesPerSecond | Average | `LUN` | PT1M | Yes |
| **Data Disk Write Operations/Sec**Write IOPS from a single disk during monitoring period | `Data Disk Write Operations/Sec` | No | CountPerSecond | Average | `LUN` | PT1M | Yes |
| **Disk Read Bytes**Bytes read from disk during monitoring period | `Disk Read Bytes` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Disk Read Operations/Sec**Disk Read IOPS | `Disk Read Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Disk Write Bytes**Bytes written to disk during monitoring period | `Disk Write Bytes` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Disk Write Operations/Sec**Disk Write IOPS | `Disk Write Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Inbound Flows**Inbound Flows are number of current flows in the inbound direction (traffic going into the VM) | `Inbound Flows` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **Inbound Flows Maximum Creation Rate**The maximum creation rate of inbound flows (traffic going into the VM) | `Inbound Flows Maximum Creation Rate` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Network In Billable (Deprecated)**The number of billable bytes received on all network interfaces by the Virtual Machine(s) (Incoming Traffic) (Deprecated) | `Network In` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Network In Total**The number of bytes received on all network interfaces by the Virtual Machine(s) (Incoming Traffic) | `Network In Total` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Network Out Billable (Deprecated)**The number of billable bytes out on all network interfaces by the Virtual Machine(s) (Outgoing Traffic) (Deprecated) | `Network Out` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Network Out Total**The number of bytes out on all network interfaces by the Virtual Machine(s) (Outgoing Traffic) | `Network Out Total` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **OS Disk Bandwidth Consumed Percentage**Percentage of operating system disk bandwidth consumed per minute. Only available on VM series that support premium storage. | `OS Disk Bandwidth Consumed Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **OS Disk IOPS Consumed Percentage**Percentage of operating system disk I/Os consumed per minute. Only available on VM series that support premium storage. | `OS Disk IOPS Consumed Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **OS Disk Latency**Average time to complete each IO during monitoring period for OS Disk. Values are in milliseconds. | `OS Disk Latency` | No | Milliseconds | Average | &lt;none&gt; | PT1M | Yes |
| **OS Disk Max Burst Bandwidth**Maximum bytes per second throughput OS Disk can achieve with bursting | `OS Disk Max Burst Bandwidth` | No | Count | Average | `LUN` | PT1M | Yes |
| **OS Disk Max Burst IOPS**Maximum IOPS OS Disk can achieve with bursting | `OS Disk Max Burst IOPS` | No | Count | Average | `LUN` | PT1M | Yes |
| **OS Disk Queue Depth**OS Disk Queue Depth(or Queue Length) | `OS Disk Queue Depth` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **OS Disk Read Bytes/Sec**Bytes/Sec read from a single disk during monitoring period for OS disk | `OS Disk Read Bytes/sec` | No | BytesPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **OS Disk Read Operations/Sec**Read IOPS from a single disk during monitoring period for OS disk | `OS Disk Read Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **OS Disk Target Bandwidth**Baseline bytes per second throughput OS Disk can achieve without bursting | `OS Disk Target Bandwidth` | No | Count | Average | `LUN` | PT1M | Yes |
| **OS Disk Target IOPS**Baseline IOPS OS Disk can achieve without bursting | `OS Disk Target IOPS` | No | Count | Average | `LUN` | PT1M | Yes |
| **OS Disk Used Burst BPS Credits Percentage**Percentage of OS Disk burst bandwidth credits used so far | `OS Disk Used Burst BPS Credits Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **OS Disk Used Burst IO Credits Percentage**Percentage of OS Disk burst I/O credits used so far | `OS Disk Used Burst IO Credits Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **OS Disk Write Bytes/Sec**Bytes/Sec written to a single disk during monitoring period for OS disk | `OS Disk Write Bytes/sec` | No | BytesPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **OS Disk Write Operations/Sec**Write IOPS from a single disk during monitoring period for OS disk | `OS Disk Write Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Outbound Flows**Outbound Flows are number of current flows in the outbound direction (traffic going out of the VM) | `Outbound Flows` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **Outbound Flows Maximum Creation Rate**The maximum creation rate of outbound flows (traffic going out of the VM) | `Outbound Flows Maximum Creation Rate` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Percentage CPU**The percentage of allocated compute units that are currently in use by the Virtual Machine(s) | `Percentage CPU` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **Premium Data Disk Cache Read Hit**Premium Data Disk Cache Read Hit | `Premium Data Disk Cache Read Hit` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Premium Data Disk Cache Read Miss**Premium Data Disk Cache Read Miss | `Premium Data Disk Cache Read Miss` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Premium OS Disk Cache Read Hit**Premium OS Disk Cache Read Hit | `Premium OS Disk Cache Read Hit` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **Premium OS Disk Cache Read Miss**Premium OS Disk Cache Read Miss | `Premium OS Disk Cache Read Miss` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Latency (Preview)**Average time to complete each IO during monitoring period for Temp Disk. Values are in milliseconds. | `Temp Disk Latency` | No | Milliseconds | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Queue Depth**Temp Disk Queue Depth(or Queue Length). | `Temp Disk Queue Depth` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Read Bytes/Sec**Bytes/Sec read from a single disk during monitoring period for Temp Disk. | `Temp Disk Read Bytes/sec` | No | BytesPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Read Operations/Sec**Read IOPS from a single disk during monitoring period for Temp Disk. | `Temp Disk Read Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Write Bytes/Sec**Bytes/Sec written to a single disk during monitoring period for Temp Disk. | `Temp Disk Write Bytes/sec` | No | BytesPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Write Operations/Sec**Write IOPS from a single disk during monitoring period for Temp Disk. | `Temp Disk Write Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **VM Cached Bandwidth Consumed Percentage**Percentage of cached disk bandwidth consumed by the VM. Only available on VM series that support premium storage. | `VM Cached Bandwidth Consumed Percentage` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **VM Cached IOPS Consumed Percentage**Percentage of cached disk IOPS consumed by the VM. Only available on VM series that support premium storage. | `VM Cached IOPS Consumed Percentage` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **VM Cached Used Burst BPS Credits Percentage**Percentage of Cached Burst BPS Credits used by the VM. | `VM Local Used Burst BPS Credits Percentage` | No | Percent | Average, Minimum, Maximum | &lt;none&gt; | PT1M | Yes |
| **VM Cached Used Burst IO Credits Percentage**Percentage of Cached Burst IO Credits used by the VM. | `VM Local Used Burst IO Credits Percentage` | No | Percent | Average, Minimum, Maximum | &lt;none&gt; | PT1M | Yes |
| **VM Uncached Used Burst BPS Credits Percentage**Percentage of Uncached Burst BPS Credits used by the VM. | `VM Remote Used Burst BPS Credits Percentage` | No | Percent | Average, Minimum, Maximum | &lt;none&gt; | PT1M | Yes |
| **VM Uncached Used Burst IO Credits Percentage**Percentage of Uncached Burst IO Credits used by the VM. | `VM Remote Used Burst IO Credits Percentage` | No | Percent | Average, Minimum, Maximum | &lt;none&gt; | PT1M | Yes |
| **VM Uncached Bandwidth Consumed Percentage**Percentage of uncached disk bandwidth consumed by the VM. Only available on VM series that support premium storage. | `VM Uncached Bandwidth Consumed Percentage` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **VM Uncached IOPS Consumed Percentage**Percentage of uncached disk IOPS consumed by the VM. Only available on VM series that support premium storage. | `VM Uncached IOPS Consumed Percentage` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **VM Availability Metric**Measure of availability of virtual machines over time. | `VmAvailabilityMetric` | No | Count | Average, Minimum, Maximum | `Context` | PT1M | Yes |
| **VM Time Offset**Time offset (drift) of the VM's clock compared to the Azure time source, in nanoseconds. | `VMTimeOffset` | No | Count | Average, Minimum, Maximum | `CompliantFlag` | PT1M | Yes |

### Supported metrics for Microsoft.Compute/virtualmachineScaleSets

The following table lists the metrics available for the Microsoft.Compute/virtualmachineScaleSets resource type.

- All columns might not be present in every table.
- Some columns might be beyond the viewing area of the page. Select **Expand table** to view all available columns.

**Table headings**

- **Category** - The metrics group or classification.
- **Metric** - The metric display name as it appears in the Azure portal.
- **Name in REST API** - The metric name as referred to in the [REST API](/en-us/azure/azure-monitor/essentials/rest-api-walkthrough).
- **Unit** - Unit of measure.
- **Aggregation** - The default [aggregation](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained) type. Valid values: Average (Avg), Minimum (Min), Maximum (Max), Total (Sum), Count.
- **Dimensions** - [Dimensions](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#dimensions-splitting-and-filtering) available for the metric.
- **Time Grains** - [Intervals](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#granularity) at which the metric is sampled. For example, `PT1M` indicates that the metric is sampled every minute, `PT30M` every 30 minutes, `PT1H` every hour, and so on.
- **DS Export**- Whether the metric is exportable to Azure Monitor Logs via diagnostic settings. For information on exporting metrics, see [Create diagnostic settings in Azure Monitor](/en-us/azure/azure-monitor/essentials/create-diagnostic-settings?tabs=portal).

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Available Memory Bytes**Amount of physical memory, in bytes, immediately available for allocation to a process or for system use in the Virtual Machine | `Available Memory Bytes` | No | Bytes | Average | `VMName` | PT1M | Yes |
| **Available Memory Percentage**Amount of physical memory, in percentage, immediately available for allocation to a process or for system use in the Virtual Machine | `Available Memory Percentage` | No | Percent | Average | `VMName` | PT1M | Yes |
| **CPU Credits Consumed**Total number of credits consumed by the Virtual Machine. Only available on B-series burstable VMs | `CPU Credits Consumed` | No | Count | Average | `VMName` | PT1M | Yes |
| **CPU Credits Remaining**Total number of credits available to burst. Only available on B-series burstable VMs | `CPU Credits Remaining` | No | Count | Average | `VMName` | PT1M | Yes |
| **Data Disk Bandwidth Consumed Percentage**Percentage of data disk bandwidth consumed per minute. Only available on VM series that support premium storage. | `Data Disk Bandwidth Consumed Percentage` | No | Percent | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk IOPS Consumed Percentage**Percentage of data disk I/Os consumed per minute. Only available on VM series that support premium storage. | `Data Disk IOPS Consumed Percentage` | No | Percent | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Latency**Average time to complete each IO during monitoring period for Data Disk. Values are in milliseconds. | `Data Disk Latency` | No | Milliseconds | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Max Burst Bandwidth**Maximum bytes per second throughput Data Disk can achieve with bursting | `Data Disk Max Burst Bandwidth` | No | Count | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Max Burst IOPS**Maximum IOPS Data Disk can achieve with bursting | `Data Disk Max Burst IOPS` | No | Count | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Queue Depth**Data Disk Queue Depth(or Queue Length) | `Data Disk Queue Depth` | No | Count | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Read Bytes/Sec**Bytes/Sec read from a single disk during monitoring period | `Data Disk Read Bytes/sec` | No | BytesPerSecond | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Read Operations/Sec**Read IOPS from a single disk during monitoring period | `Data Disk Read Operations/Sec` | No | CountPerSecond | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Target Bandwidth**Baseline bytes per second throughput Data Disk can achieve without bursting | `Data Disk Target Bandwidth` | No | Count | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Target IOPS**Baseline IOPS Data Disk can achieve without bursting | `Data Disk Target IOPS` | No | Count | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Used Burst BPS Credits Percentage**Percentage of Data Disk burst bandwidth credits used so far | `Data Disk Used Burst BPS Credits Percentage` | No | Percent | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Used Burst IO Credits Percentage**Percentage of Data Disk burst I/O credits used so far | `Data Disk Used Burst IO Credits Percentage` | No | Percent | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Write Bytes/Sec**Bytes/Sec written to a single disk during monitoring period | `Data Disk Write Bytes/sec` | No | BytesPerSecond | Average | `LUN`, `VMName` | PT1M | Yes |
| **Data Disk Write Operations/Sec**Write IOPS from a single disk during monitoring period | `Data Disk Write Operations/Sec` | No | CountPerSecond | Average | `LUN`, `VMName` | PT1M | Yes |
| **Disk Read Bytes**Bytes read from disk during monitoring period | `Disk Read Bytes` | No | Bytes | Total (Sum) | `VMName` | PT1M | Yes |
| **Disk Read Operations/Sec**Disk Read IOPS | `Disk Read Operations/Sec` | No | CountPerSecond | Average | `VMName` | PT1M | Yes |
| **Disk Write Bytes**Bytes written to disk during monitoring period | `Disk Write Bytes` | No | Bytes | Total (Sum) | `VMName` | PT1M | Yes |
| **Disk Write Operations/Sec**Disk Write IOPS | `Disk Write Operations/Sec` | No | CountPerSecond | Average | `VMName` | PT1M | Yes |
| **Inbound Flows**Inbound Flows are number of current flows in the inbound direction (traffic going into the VM) | `Inbound Flows` | No | Count | Average | `VMName` | PT1M | Yes |
| **Inbound Flows Maximum Creation Rate**The maximum creation rate of inbound flows (traffic going into the VM) | `Inbound Flows Maximum Creation Rate` | No | CountPerSecond | Average | `VMName` | PT1M | Yes |
| **Network In Billable (Deprecated)**The number of billable bytes received on all network interfaces by the Virtual Machine(s) (Incoming Traffic) (Deprecated) | `Network In` | No | Bytes | Total (Sum) | `VMName` | PT1M | Yes |
| **Network In Total**The number of bytes received on all network interfaces by the Virtual Machine(s) (Incoming Traffic) | `Network In Total` | No | Bytes | Total (Sum) | `VMName` | PT1M | Yes |
| **Network Out Billable (Deprecated)**The number of billable bytes out on all network interfaces by the Virtual Machine(s) (Outgoing Traffic) (Deprecated) | `Network Out` | No | Bytes | Total (Sum) | `VMName` | PT1M | Yes |
| **Network Out Total**The number of bytes out on all network interfaces by the Virtual Machine(s) (Outgoing Traffic) | `Network Out Total` | No | Bytes | Total (Sum) | `VMName` | PT1M | Yes |
| **OS Disk Bandwidth Consumed Percentage**Percentage of operating system disk bandwidth consumed per minute. Only available on VM series that support premium storage. | `OS Disk Bandwidth Consumed Percentage` | No | Percent | Average | `LUN`, `VMName` | PT1M | Yes |
| **OS Disk IOPS Consumed Percentage**Percentage of operating system disk I/Os consumed per minute. Only available on VM series that support premium storage. | `OS Disk IOPS Consumed Percentage` | No | Percent | Average | `LUN`, `VMName` | PT1M | Yes |
| **OS Disk Latency**Average time to complete each IO during monitoring period for OS Disk. Values are in milliseconds. | `OS Disk Latency` | No | Milliseconds | Average | `VMName` | PT1M | Yes |
| **OS Disk Max Burst Bandwidth**Maximum bytes per second throughput OS Disk can achieve with bursting | `OS Disk Max Burst Bandwidth` | No | Count | Average | `LUN`, `VMName` | PT1M | Yes |
| **OS Disk Max Burst IOPS**Maximum IOPS OS Disk can achieve with bursting | `OS Disk Max Burst IOPS` | No | Count | Average | `LUN`, `VMName` | PT1M | Yes |
| **OS Disk Queue Depth**OS Disk Queue Depth(or Queue Length) | `OS Disk Queue Depth` | No | Count | Average | `VMName` | PT1M | Yes |
| **OS Disk Read Bytes/Sec**Bytes/Sec read from a single disk during monitoring period for OS disk | `OS Disk Read Bytes/sec` | No | BytesPerSecond | Average | `VMName` | PT1M | Yes |
| **OS Disk Read Operations/Sec**Read IOPS from a single disk during monitoring period for OS disk | `OS Disk Read Operations/Sec` | No | CountPerSecond | Average | `VMName` | PT1M | Yes |
| **OS Disk Target Bandwidth**Baseline bytes per second throughput OS Disk can achieve without bursting | `OS Disk Target Bandwidth` | No | Count | Average | `LUN`, `VMName` | PT1M | Yes |
| **OS Disk Target IOPS**Baseline IOPS OS Disk can achieve without bursting | `OS Disk Target IOPS` | No | Count | Average | `LUN`, `VMName` | PT1M | Yes |
| **OS Disk Used Burst BPS Credits Percentage**Percentage of OS Disk burst bandwidth credits used so far | `OS Disk Used Burst BPS Credits Percentage` | No | Percent | Average | `LUN`, `VMName` | PT1M | Yes |
| **OS Disk Used Burst IO Credits Percentage**Percentage of OS Disk burst I/O credits used so far | `OS Disk Used Burst IO Credits Percentage` | No | Percent | Average | `LUN`, `VMName` | PT1M | Yes |
| **OS Disk Write Bytes/Sec**Bytes/Sec written to a single disk during monitoring period for OS disk | `OS Disk Write Bytes/sec` | No | BytesPerSecond | Average | `VMName` | PT1M | Yes |
| **OS Disk Write Operations/Sec**Write IOPS from a single disk during monitoring period for OS disk | `OS Disk Write Operations/Sec` | No | CountPerSecond | Average | `VMName` | PT1M | Yes |
| **Outbound Flows**Outbound Flows are number of current flows in the outbound direction (traffic going out of the VM) | `Outbound Flows` | No | Count | Average | `VMName` | PT1M | Yes |
| **Outbound Flows Maximum Creation Rate**The maximum creation rate of outbound flows (traffic going out of the VM) | `Outbound Flows Maximum Creation Rate` | No | CountPerSecond | Average | `VMName` | PT1M | Yes |
| **Percentage CPU**The percentage of allocated compute units that are currently in use by the Virtual Machine(s) | `Percentage CPU` | No | Percent | Average | `VMName` | PT1M | Yes |
| **Premium Data Disk Cache Read Hit**Premium Data Disk Cache Read Hit | `Premium Data Disk Cache Read Hit` | No | Percent | Average | `LUN`, `VMName` | PT1M | Yes |
| **Premium Data Disk Cache Read Miss**Premium Data Disk Cache Read Miss | `Premium Data Disk Cache Read Miss` | No | Percent | Average | `LUN`, `VMName` | PT1M | Yes |
| **Premium OS Disk Cache Read Hit**Premium OS Disk Cache Read Hit | `Premium OS Disk Cache Read Hit` | No | Percent | Average | `VMName` | PT1M | Yes |
| **Premium OS Disk Cache Read Miss**Premium OS Disk Cache Read Miss | `Premium OS Disk Cache Read Miss` | No | Percent | Average | `VMName` | PT1M | Yes |
| **Temp Disk Latency (Preview)**Average time to complete each IO during monitoring period for Temp Disk. Values are in milliseconds. | `Temp Disk Latency` | No | Milliseconds | Average | `VMName` | PT1M | Yes |
| **Temp Disk Queue Depth**Temp Disk Queue Depth(or Queue Length). | `Temp Disk Queue Depth` | No | Count | Average | `VMName` | PT1M | Yes |
| **Temp Disk Read Bytes/Sec**Bytes/Sec read from a single disk during monitoring period for Temp Disk. | `Temp Disk Read Bytes/sec` | No | BytesPerSecond | Average | `VMName` | PT1M | Yes |
| **Temp Disk Read Operations/Sec**Read IOPS from a single disk during monitoring period for Temp Disk. | `Temp Disk Read Operations/Sec` | No | CountPerSecond | Average | `VMName` | PT1M | Yes |
| **Temp Disk Write Bytes/Sec**Bytes/Sec written to a single disk during monitoring period for Temp Disk. | `Temp Disk Write Bytes/sec` | No | BytesPerSecond | Average | `VMName` | PT1M | Yes |
| **Temp Disk Write Operations/Sec**Write IOPS from a single disk during monitoring period for Temp Disk. | `Temp Disk Write Operations/Sec` | No | CountPerSecond | Average | `VMName` | PT1M | Yes |
| **VM Cached Bandwidth Consumed Percentage**Percentage of cached disk bandwidth consumed by the VM. Only available on VM series that support premium storage. | `VM Cached Bandwidth Consumed Percentage` | No | Percent | Average | `VMName` | PT1M | Yes |
| **VM Cached IOPS Consumed Percentage**Percentage of cached disk IOPS consumed by the VM. Only available on VM series that support premium storage. | `VM Cached IOPS Consumed Percentage` | No | Percent | Average | `VMName` | PT1M | Yes |
| **VM Cached Used Burst BPS Credits Percentage**Percentage of Cached Burst BPS Credits used by the VM. | `VM Local Used Burst BPS Credits Percentage` | No | Percent | Average, Minimum, Maximum | `VMName` | PT1M | Yes |
| **VM Cached Used Burst IO Credits Percentage**Percentage of Cached Burst IO Credits used by the VM. | `VM Local Used Burst IO Credits Percentage` | No | Percent | Average, Minimum, Maximum | `VMName` | PT1M | Yes |
| **VM Uncached Used Burst BPS Credits Percentage**Percentage of Uncached Burst BPS Credits used by the VM. | `VM Remote Used Burst BPS Credits Percentage` | No | Percent | Average, Minimum, Maximum | `VMName` | PT1M | Yes |
| **VM Uncached Used Burst IO Credits Percentage**Percentage of Uncached Burst IO Credits used by the VM. | `VM Remote Used Burst IO Credits Percentage` | No | Percent | Average, Minimum, Maximum | `VMName` | PT1M | Yes |
| **VM Uncached Bandwidth Consumed Percentage**Percentage of uncached disk bandwidth consumed by the VM. Only available on VM series that support premium storage. | `VM Uncached Bandwidth Consumed Percentage` | No | Percent | Average | `VMName` | PT1M | Yes |
| **VM Uncached IOPS Consumed Percentage**Percentage of uncached disk IOPS consumed by the VM. Only available on VM series that support premium storage. | `VM Uncached IOPS Consumed Percentage` | No | Percent | Average | `VMName` | PT1M | Yes |
| **VM Availability Metric**Measure of availability of virtual machines over time. | `VmAvailabilityMetric` | No | Count | Average, Minimum, Maximum | `VMName`, `Context` | PT1M | Yes |

### Supported metrics for Microsoft.Compute/virtualMachineScaleSets/virtualMachines

The following table lists the metrics available for the Microsoft.Compute/virtualMachineScaleSets/virtualMachines resource type.

- All columns might not be present in every table.
- Some columns might be beyond the viewing area of the page. Select **Expand table** to view all available columns.

**Table headings**

- **Category** - The metrics group or classification.
- **Metric** - The metric display name as it appears in the Azure portal.
- **Name in REST API** - The metric name as referred to in the [REST API](/en-us/azure/azure-monitor/essentials/rest-api-walkthrough).
- **Unit** - Unit of measure.
- **Aggregation** - The default [aggregation](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained) type. Valid values: Average (Avg), Minimum (Min), Maximum (Max), Total (Sum), Count.
- **Dimensions** - [Dimensions](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#dimensions-splitting-and-filtering) available for the metric.
- **Time Grains** - [Intervals](/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained#granularity) at which the metric is sampled. For example, `PT1M` indicates that the metric is sampled every minute, `PT30M` every 30 minutes, `PT1H` every hour, and so on.
- **DS Export**- Whether the metric is exportable to Azure Monitor Logs via diagnostic settings. For information on exporting metrics, see [Create diagnostic settings in Azure Monitor](/en-us/azure/azure-monitor/essentials/create-diagnostic-settings?tabs=portal).

| Metric | Name in REST API | [Advanced platform metrics](/en-us/azure/azure-monitor/metrics/metrics-advanced-platform) | Unit | Aggregation | Dimensions | Time Grains | DS Export |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Available Memory Bytes**Amount of physical memory, in bytes, immediately available for allocation to a process or for system use in the Virtual Machine | `Available Memory Bytes` | No | Bytes | Average | &lt;none&gt; | PT1M | Yes |
| **Available Memory Percentage**Amount of physical memory, in percentage, immediately available for allocation to a process or for system use in the Virtual Machine | `Available Memory Percentage` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **CPU Credits Consumed**Total number of credits consumed by the Virtual Machine. Only available on B-series burstable VMs | `CPU Credits Consumed` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **CPU Credits Remaining**Total number of credits available to burst. Only available on B-series burstable VMs | `CPU Credits Remaining` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **Data Disk Bandwidth Consumed Percentage**Percentage of data disk bandwidth consumed per minute. Only available on VM series that support premium storage. | `Data Disk Bandwidth Consumed Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Data Disk IOPS Consumed Percentage**Percentage of data disk I/Os consumed per minute. Only available on VM series that support premium storage. | `Data Disk IOPS Consumed Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Data Disk Latency**Average time to complete each IO during monitoring period for Data Disk. Values are in milliseconds. | `Data Disk Latency` | No | Milliseconds | Average | `LUN` | PT1M | Yes |
| **Data Disk Max Burst Bandwidth**Maximum bytes per second throughput Data Disk can achieve with bursting | `Data Disk Max Burst Bandwidth` | No | Count | Average | `LUN` | PT1M | Yes |
| **Data Disk Max Burst IOPS**Maximum IOPS Data Disk can achieve with bursting | `Data Disk Max Burst IOPS` | No | Count | Average | `LUN` | PT1M | Yes |
| **Data Disk Queue Depth**Data Disk Queue Depth(or Queue Length) | `Data Disk Queue Depth` | No | Count | Average | `LUN` | PT1M | Yes |
| **Data Disk Read Bytes/Sec**Bytes/Sec read from a single disk during monitoring period | `Data Disk Read Bytes/sec` | No | BytesPerSecond | Average | `LUN` | PT1M | Yes |
| **Data Disk Read Operations/Sec**Read IOPS from a single disk during monitoring period | `Data Disk Read Operations/Sec` | No | CountPerSecond | Average | `LUN` | PT1M | Yes |
| **Data Disk Target Bandwidth**Baseline bytes per second throughput Data Disk can achieve without bursting | `Data Disk Target Bandwidth` | No | Count | Average | `LUN` | PT1M | Yes |
| **Data Disk Target IOPS**Baseline IOPS Data Disk can achieve without bursting | `Data Disk Target IOPS` | No | Count | Average | `LUN` | PT1M | Yes |
| **Data Disk Used Burst BPS Credits Percentage**Percentage of Data Disk burst bandwidth credits used so far | `Data Disk Used Burst BPS Credits Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Data Disk Used Burst IO Credits Percentage**Percentage of Data Disk burst I/O credits used so far | `Data Disk Used Burst IO Credits Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Data Disk Write Bytes/Sec**Bytes/Sec written to a single disk during monitoring period | `Data Disk Write Bytes/sec` | No | BytesPerSecond | Average | `LUN` | PT1M | Yes |
| **Data Disk Write Operations/Sec**Write IOPS from a single disk during monitoring period | `Data Disk Write Operations/Sec` | No | CountPerSecond | Average | `LUN` | PT1M | Yes |
| **Disk Read Bytes**Bytes read from disk during monitoring period | `Disk Read Bytes` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Disk Read Operations/Sec**Disk Read IOPS | `Disk Read Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Disk Write Bytes**Bytes written to disk during monitoring period | `Disk Write Bytes` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Disk Write Operations/Sec**Disk Write IOPS | `Disk Write Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Inbound Flows**Inbound Flows are number of current flows in the inbound direction (traffic going into the VM) | `Inbound Flows` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **Inbound Flows Maximum Creation Rate**The maximum creation rate of inbound flows (traffic going into the VM) | `Inbound Flows Maximum Creation Rate` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Network In Billable (Deprecated)**The number of billable bytes received on all network interfaces by the Virtual Machine(s) (Incoming Traffic) (Deprecated) | `Network In` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Network In Total**The number of bytes received on all network interfaces by the Virtual Machine(s) (Incoming Traffic) | `Network In Total` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Network Out Billable (Deprecated)**The number of billable bytes out on all network interfaces by the Virtual Machine(s) (Outgoing Traffic) (Deprecated) | `Network Out` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Network Out Total**The number of bytes out on all network interfaces by the Virtual Machine(s) (Outgoing Traffic) | `Network Out Total` | No | Bytes | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **OS Disk Bandwidth Consumed Percentage**Percentage of operating system disk bandwidth consumed per minute. Only available on VM series that support premium storage. | `OS Disk Bandwidth Consumed Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **OS Disk IOPS Consumed Percentage**Percentage of operating system disk I/Os consumed per minute. Only available on VM series that support premium storage. | `OS Disk IOPS Consumed Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **OS Disk Latency**Average time to complete each IO during monitoring period for OS Disk. Values are in milliseconds. | `OS Disk Latency` | No | Milliseconds | Average | &lt;none&gt; | PT1M | Yes |
| **OS Disk Max Burst Bandwidth**Maximum bytes per second throughput OS Disk can achieve with bursting | `OS Disk Max Burst Bandwidth` | No | Count | Average | `LUN` | PT1M | Yes |
| **OS Disk Max Burst IOPS**Maximum IOPS OS Disk can achieve with bursting | `OS Disk Max Burst IOPS` | No | Count | Average | `LUN` | PT1M | Yes |
| **OS Disk Queue Depth**OS Disk Queue Depth(or Queue Length) | `OS Disk Queue Depth` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **OS Disk Read Bytes/Sec**Bytes/Sec read from a single disk during monitoring period for OS disk | `OS Disk Read Bytes/sec` | No | BytesPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **OS Disk Read Operations/Sec**Read IOPS from a single disk during monitoring period for OS disk | `OS Disk Read Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **OS Disk Target Bandwidth**Baseline bytes per second throughput OS Disk can achieve without bursting | `OS Disk Target Bandwidth` | No | Count | Average | `LUN` | PT1M | Yes |
| **OS Disk Target IOPS**Baseline IOPS OS Disk can achieve without bursting | `OS Disk Target IOPS` | No | Count | Average | `LUN` | PT1M | Yes |
| **OS Disk Used Burst BPS Credits Percentage**Percentage of OS Disk burst bandwidth credits used so far | `OS Disk Used Burst BPS Credits Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **OS Disk Used Burst IO Credits Percentage**Percentage of OS Disk burst I/O credits used so far | `OS Disk Used Burst IO Credits Percentage` | No | Percent | Average | `LUN` | PT1M | Yes |
| **OS Disk Write Bytes/Sec**Bytes/Sec written to a single disk during monitoring period for OS disk | `OS Disk Write Bytes/sec` | No | BytesPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **OS Disk Write Operations/Sec**Write IOPS from a single disk during monitoring period for OS disk | `OS Disk Write Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Outbound Flows**Outbound Flows are number of current flows in the outbound direction (traffic going out of the VM) | `Outbound Flows` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **Outbound Flows Maximum Creation Rate**The maximum creation rate of outbound flows (traffic going out of the VM) | `Outbound Flows Maximum Creation Rate` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Percentage CPU**The percentage of allocated compute units that are currently in use by the Virtual Machine(s) | `Percentage CPU` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **Premium Data Disk Cache Read Hit**Premium Data Disk Cache Read Hit | `Premium Data Disk Cache Read Hit` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Premium Data Disk Cache Read Miss**Premium Data Disk Cache Read Miss | `Premium Data Disk Cache Read Miss` | No | Percent | Average | `LUN` | PT1M | Yes |
| **Premium OS Disk Cache Read Hit**Premium OS Disk Cache Read Hit | `Premium OS Disk Cache Read Hit` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **Premium OS Disk Cache Read Miss**Premium OS Disk Cache Read Miss | `Premium OS Disk Cache Read Miss` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Latency (Preview)**Average time to complete each IO during monitoring period for Temp Disk. Values are in milliseconds. | `Temp Disk Latency` | No | Milliseconds | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Queue Depth**Temp Disk Queue Depth(or Queue Length). | `Temp Disk Queue Depth` | No | Count | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Read Bytes/Sec**Bytes/Sec read from a single disk during monitoring period for Temp Disk. | `Temp Disk Read Bytes/sec` | No | BytesPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Read Operations/Sec**Read IOPS from a single disk during monitoring period for Temp Disk. | `Temp Disk Read Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Write Bytes/Sec**Bytes/Sec written to a single disk during monitoring period for Temp Disk. | `Temp Disk Write Bytes/sec` | No | BytesPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **Temp Disk Write Operations/Sec**Write IOPS from a single disk during monitoring period for Temp Disk. | `Temp Disk Write Operations/Sec` | No | CountPerSecond | Average | &lt;none&gt; | PT1M | Yes |
| **VM Cached Bandwidth Consumed Percentage**Percentage of cached disk bandwidth consumed by the VM. Only available on VM series that support premium storage. | `VM Cached Bandwidth Consumed Percentage` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **VM Cached IOPS Consumed Percentage**Percentage of cached disk IOPS consumed by the VM. Only available on VM series that support premium storage. | `VM Cached IOPS Consumed Percentage` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **VM Cached Used Burst BPS Credits Percentage**Percentage of Cached Burst BPS Credits used by the VM. | `VM Local Used Burst BPS Credits Percentage` | No | Percent | Average, Minimum, Maximum | &lt;none&gt; | PT1M | Yes |
| **VM Cached Used Burst IO Credits Percentage**Percentage of Cached Burst IO Credits used by the VM. | `VM Local Used Burst IO Credits Percentage` | No | Percent | Average, Minimum, Maximum | &lt;none&gt; | PT1M | Yes |
| **VM Uncached Used Burst BPS Credits Percentage**Percentage of Uncached Burst BPS Credits used by the VM. | `VM Remote Used Burst BPS Credits Percentage` | No | Percent | Average, Minimum, Maximum | &lt;none&gt; | PT1M | Yes |
| **VM Uncached Used Burst IO Credits Percentage**Percentage of Uncached Burst IO Credits used by the VM. | `VM Remote Used Burst IO Credits Percentage` | No | Percent | Average, Minimum, Maximum | &lt;none&gt; | PT1M | Yes |
| **VM Uncached Bandwidth Consumed Percentage**Percentage of uncached disk bandwidth consumed by the VM. Only available on VM series that support premium storage. | `VM Uncached Bandwidth Consumed Percentage` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **VM Uncached IOPS Consumed Percentage**Percentage of uncached disk IOPS consumed by the VM. Only available on VM series that support premium storage. | `VM Uncached IOPS Consumed Percentage` | No | Percent | Average | &lt;none&gt; | PT1M | Yes |
| **VM Availability Metric (Preview)**Measure of Availability of Virtual machines over time. | `VmAvailabilityMetric` | No | Count | Average, Minimum, Maximum | &lt;none&gt; | PT1M | Yes |

## Minimal ingestion profile for control plane Metrics in Managed Prometheus

Azure Monitor metrics add-on collects many Prometheus metrics by default. `Minimal ingestion profile` is a setting that helps reduce ingestion volume of metrics, as only metrics used by default dashboards, default recording rules and default alerts are collected. This section describes how this setting is configured specifically for control plane metrics. This section also lists metrics collected by default when `minimal ingestion profile` is enabled.

Note

For add-on-based collection, `Minimal ingestion profile` setting is enabled by default. The discussion here is focused on control plane metrics. The current set of default targets and metrics is listed [here](/en-us/azure/azure-monitor/containers/prometheus-metrics-scrape-configuration-minimal).

Following targets are **enabled/ON** by default - meaning you don't have to provide any scrape job configuration for scraping these targets, as metrics add-on scrapes these targets automatically by default:

- `controlplane-apiserver` (job=`controlplane-apiserver`)
- `controlplane-etcd` (job=`controlplane-etcd`)

Following targets are available to scrape, but scraping isn't enabled (**disabled/OFF**) by default. Meaning you don't have to provide any scrape job configuration for scraping these targets, and you need to turn **ON/enable** scraping for these targets using the [ama-metrics-settings-configmap](https://github.com/Azure/prometheus-collector/blob/89e865a73601c0798410016e9beb323f1ecba335/otelcollector/configmaps/ama-metrics-settings-configmap.yaml) under the `default-scrape-settings-enabled` section.

- `controlplane-cluster-autoscaler`
- `controlplane-node-auto-provisioning`
- `controlplane-kube-scheduler`
- `controlplane-kube-controller-manager`

Note

The default scrape frequency for all default targets and scrapes is `30 seconds`. You can override it for each target using the [ama-metrics-settings-configmap](https://github.com/Azure/prometheus-collector/blob/89e865a73601c0798410016e9beb323f1ecba335/otelcollector/configmaps/ama-metrics-settings-configmap.yaml) under `default-targets-scrape-interval-settings` section.

### Minimal ingestion for default ON targets

The following metrics are allow-listed with `minimalingestionprofile=true` for default **ON** targets. The below metrics are collected by default, as these targets are scraped by default.

controlplane-apiserver:

- `apiserver_request_total`
- `apiserver_cache_list_fetched_objects_total`
- `apiserver_cache_list_returned_objects_total`
- `apiserver_flowcontrol_demand_seats_average`
- `apiserver_flowcontrol_current_limit_seats`
- ~~`apiserver_request_sli_duration_seconds_bucket`~~
- `apiserver_request_sli_duration_seconds_sum`
- `apiserver_request_sli_duration_seconds_count`
- `process_start_time_seconds`
- ~~`apiserver_request_duration_seconds_bucket`~~
- `apiserver_request_duration_seconds_sum`
- `apiserver_request_duration_seconds_count`
- `apiserver_storage_list_fetched_objects_total`
- `apiserver_storage_list_returned_objects_total`
- `apiserver_current_inflight_requests`

Note

`apiserver_request_sli_duration_seconds_bucket` and `apiserver_request_duration_seconds_bucket` are not collected now with a recent release. These are high cardinality metrics which may increase the number of metrics stored based on the number of custom resources in the cluster. If you would like to collect these bucket metrics, you can add it to the keep list. We highly recommend not turning off the minimal ingestion profile for the control plane components

controlplane-etcd:

- `etcd_server_has_leader`
- `rest_client_requests_total`
- `etcd_mvcc_db_total_size_in_bytes`
- `etcd_mvcc_db_total_size_in_use_in_bytes`
- `etcd_server_slow_read_indexes_total`
- `etcd_server_slow_apply_total`
- `etcd_network_client_grpc_sent_bytes_total`
- `etcd_server_heartbeat_send_failures_total`

### Minimal ingestion for default OFF targets

The following are metrics that are allow-listed with `minimalingestionprofile=true` for default **OFF** targets. These metrics aren't collected by default. You can turn **ON** scraping for these targets using `default-scrape-settings-enabled.<target-name>=true` using the [ama-metrics-settings-configmap](https://github.com/Azure/prometheus-collector/blob/89e865a73601c0798410016e9beb323f1ecba335/otelcollector/configmaps/ama-metrics-settings-configmap.yaml) under the `default-scrape-settings-enabled` section.

controlplane-kube-controller-manager:

- `workqueue_depth `
- `rest_client_requests_total`
- `rest_client_request_duration_seconds `

controlplane-kube-scheduler:

- `scheduler_pending_pods`
- `scheduler_unschedulable_pods`
- `scheduler_queue_incoming_pods_total`
- `scheduler_schedule_attempts_total`
- `scheduler_preemption_attempts_total`

controlplane-cluster-autoscaler:

- `rest_client_requests_total`
- `cluster_autoscaler_last_activity`
- `cluster_autoscaler_cluster_safe_to_autoscale`
- `cluster_autoscaler_failed_scale_ups_total`
- `cluster_autoscaler_scale_down_in_cooldown`
- `cluster_autoscaler_scaled_up_nodes_total`
- `cluster_autoscaler_unneeded_nodes_count`
- `cluster_autoscaler_unschedulable_pods_count`
- `cluster_autoscaler_nodes_count`
- `cloudprovider_azure_api_request_errors`
- `cloudprovider_azure_api_request_duration_seconds_bucket`
- `cloudprovider_azure_api_request_duration_seconds_count`

controlplane-node-auto-provisioning:

- `karpenter_pods_state`
- `karpenter_nodes_created_total`
- `karpenter_nodes_terminated_total`
- `karpenter_nodeclaims_disrupted_total`
- `karpenter_voluntary_disruption_eligible_nodes`
- `karpenter_voluntary_disruption_decisions_total`

Note

The CPU and memory usage metrics for all control-plane targets are not exposed irrespective of the profile.

## Metric dimensions

For information about what metric dimensions are, see [Multi-dimensional metrics](/en-us/azure/azure-monitor/platform/data-platform-metrics#multi-dimensional-metrics).

This service has the following dimensions associated with its metrics.

| Dimension Name | Description |
| --- | --- |
| requestKind | Used by metrics such as *Inflight Requests* to split by type of request. |
| condition | Used by metrics such as *Statuses for various node conditions*, *Number of pods in Ready state* to split by condition type. |
| status | Used by metrics such as *Statuses for various node conditions* to split by status of the condition. |
| status2 | Used by metrics such as *Statuses for various node conditions* to split by status of the condition. |
| node | Used by metrics such as *CPU Usage Millicores* to split by the name of the node. |
| phase | Used by metrics such as *Number of pods by phase* to split by the phase of the pod. |
| namespace | Used by metrics such as *Number of pods by phase* to split by the namespace of the pod. |
| pod | Used by metrics such as *Number of pods by phase* to split by the name of the pod. |
| nodepool | Used by metrics such as *Disk Used Bytes* to split by the name of the nodepool. |
| device | Used by metrics such as *Disk Used Bytes* to split by the name of the device. |
| 3gppGen | Used by metrics such as *Number of Active PDU Sessions*. |
| Cause | Used by metrics such as *User plane packet drop rate*. |
| Direction | Used by metrics such as *User plane bandwidth*. |
| Dnn | Used by metrics such as *PDU session establishment attempts rate*. |
| Interface | Used by metrics such as *User plane bandwidth*. |
| LUN | Used by metrics such as *Percentage of data disk bandwidth consumed*. |
| PccpId | Used by metrics such as *Number of Active PDU Sessions*. |
| Result | Used by metrics such as *Authentication failure rate*. |
| SiteId | Used by metrics such as *Number of Active PDU Sessions*. |
| Tai | Used by metrics such as *Service request failure rate*. |
| VMName | Used by metrics such as *Amount of physical memory*. |

## Resource logs

This section lists the types of resource logs you can collect for this service. The section pulls from the list of [all resource logs category types supported in Azure Monitor](/en-us/azure/azure-monitor/platform/resource-logs-schema).

### Supported resource logs for Microsoft.ContainerService/fleets

| Category | Costs to export | Log table | [Supports basic log plan](/en-us/azure/azure-monitor/logs/basic-logs-configure?tabs=portal-1#compare-the-basic-and-analytics-log-data-plans) | [Supports ingestion-time transformation](/en-us/azure/azure-monitor/essentials/data-collection-transformations) | Example queries |
| --- | --- | --- | --- | --- | --- |
| cloud-controller-manager | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| fleet-hub-agent | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| fleet-hub-net-controller-manager | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| guard | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| kube-apiserver | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| kube-audit | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| kube-audit-admin | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| kube-controller-manager | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| kube-scheduler | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |

### Supported resource logs for Microsoft.ContainerService/managedClusters

| Category | Costs to export | Log table | [Supports basic log plan](/en-us/azure/azure-monitor/logs/basic-logs-configure?tabs=portal-1#compare-the-basic-and-analytics-log-data-plans) | [Supports ingestion-time transformation](/en-us/azure/azure-monitor/essentials/data-collection-transformations) | Example queries |
| --- | --- | --- | --- | --- | --- |
| cloud-controller-manager | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| cluster-autoscaler | No | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| csi-azuredisk-controller | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| csi-azurefile-controller | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| csi-snapshot-controller | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| fleet-mcs-controller-manager | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| fleet-member-agent | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| fleet-member-net-controller-manager | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| guard | No | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| karpenter-events | Yes | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| kube-apiserver | No | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| kube-audit | No | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| kube-audit-admin | No | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| kube-controller-manager | No | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |
| kube-scheduler | No | [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics)<br>Logs from multiple Azure resources. | No | No | [Queries](/en-us/azure/azure-monitor/reference/queries/azurediagnostics#queries-for-microsoftcontainerservice) |

### Supported resource logs for microsoft.kubernetes/connectedClusters

| Category | Costs to export | Log table | [Supports basic log plan](/en-us/azure/azure-monitor/logs/basic-logs-configure?tabs=portal-1#compare-the-basic-and-analytics-log-data-plans) | [Supports ingestion-time transformation](/en-us/azure/azure-monitor/essentials/data-collection-transformations) | Example queries |
| --- | --- | --- | --- | --- | --- |
| cloud-controller-manager | Yes |  | No | No |  |
| cluster-autoscaler | Yes |  | No | No |  |
| csi-aksarcdisk-controller | Yes |  | No | No |  |
| csi-aksarcnfs-controller | Yes |  | No | No |  |
| csi-aksarcsmb-controller | Yes |  | No | No |  |
| guard | Yes |  | No | No |  |
| kube-apiserver | Yes | [ArcK8sControlPlane](/en-us/azure/azure-monitor/reference/tables/arck8scontrolplane)<br>Contains diagnostic logs for the Kubernetes API Server, Controller Manager, Scheduler, Cluster Autoscaler, Cloud Controller Manager, Guard, and the Azure CSI storage drivers. These diagnostic logs have distinct Category entries corresponding their diagnostic log setting (e.g. kube-apiserver, kube-audit-admin). Requires Diagnostic Settings to use the Resource Specific destination table. | Yes | Yes |  |
| kube-audit | Yes | [ArcK8sAudit](/en-us/azure/azure-monitor/reference/tables/arck8saudit)<br>Contains all Kubernetes API Server audit logs including events with the get and list verbs. These events are useful for monitoring all of the interactions with the Kubernetes API. To limit the scope to modifying operations see the ArcK8sAuditAdmin table. Requires Diagnostic Settings to use the Resource Specific destination table. | Yes | Yes |  |
| kube-audit-admin | Yes | [ArcK8sAuditAdmin](/en-us/azure/azure-monitor/reference/tables/arck8sauditadmin)<br>Contains Kubernetes API Server audit logs excluding events with the get and list verbs. These events are useful for monitoring resource modification requests made to the Kubernetes API. To see all modifying and non-modifying operations see the ArcK8sAudit table. Requires Diagnostic Settings to use the Resource Specific destination table. | Yes | Yes |  |
| kube-controller-manager | Yes |  | No | No |  |
| kube-scheduler | Yes |  | No | No |  |

### Supported resource logs for Microsoft.Compute/virtualMachines

| Category | Costs to export | Log table | [Supports basic log plan](/en-us/azure/azure-monitor/logs/basic-logs-configure?tabs=portal-1#compare-the-basic-and-analytics-log-data-plans) | [Supports ingestion-time transformation](/en-us/azure/azure-monitor/essentials/data-collection-transformations) | Example queries |
| --- | --- | --- | --- | --- | --- |
| SoftwareUpdateProfile | Yes |  | No | No |  |
| SoftwareUpdates | Yes |  | No | No |  |

## Azure Monitor Logs tables

This section lists the Azure Monitor Logs tables relevant to this service, which are available for query by Log Analytics using Kusto queries. The tables contain resource log data and possibly more depending on what is collected and routed to them.

### AKS Microsoft.ContainerService/managedClusters

- [AzureActivity](/en-us/azure/azure-monitor/reference/tables/azureactivity#columns)
- [AzureDiagnostics](/en-us/azure/azure-monitor/reference/tables/azurediagnostics#columns)
- [AzureMetrics](/en-us/azure/azure-monitor/reference/tables/azuremetrics#columns)
- [ContainerImageInventory](/en-us/azure/azure-monitor/reference/tables/containerimageinventory#columns)
- [ContainerInventory](/en-us/azure/azure-monitor/reference/tables/containerinventory#columns)
- [ContainerLog](/en-us/azure/azure-monitor/reference/tables/containerlog#columns)
- [ContainerLogV2](/en-us/azure/azure-monitor/reference/tables/containerlogv2#columns)
- [ContainerNodeInventory](/en-us/azure/azure-monitor/reference/tables/containernodeinventory#columns)
- [ContainerServiceLog](/en-us/azure/azure-monitor/reference/tables/containerservicelog#columns)
- [Heartbeat](/en-us/azure/azure-monitor/reference/tables/heartbeat#columns)
- [InsightsMetrics](/en-us/azure/azure-monitor/reference/tables/insightsmetrics#columns)
- [KubeEvents](/en-us/azure/azure-monitor/reference/tables/kubeevents#columns)
- [KubeMonAgentEvents](/en-us/azure/azure-monitor/reference/tables/kubemonagentevents#columns)
- [KubeNodeInventory](/en-us/azure/azure-monitor/reference/tables/kubenodeinventory#columns)
- [KubePodInventory](/en-us/azure/azure-monitor/reference/tables/kubepodinventory#columns)
- [KubePVInventory](/en-us/azure/azure-monitor/reference/tables/kubepvinventory#columns)
- [KubeServices](/en-us/azure/azure-monitor/reference/tables/kubeservices#columns)
- [Perf](/en-us/azure/azure-monitor/reference/tables/perf#columns)
- [Syslog](/en-us/azure/azure-monitor/reference/tables/syslog#columns)
- [AKSAudit](/en-us/azure/azure-monitor/reference/tables/aksaudit#columns)
- [AKSAuditAdmin](/en-us/azure/azure-monitor/reference/tables/aksauditAdmin#columns)
- [AKSControlPlane](/en-us/azure/azure-monitor/reference/tables/akscontrolplane#columns)

## Activity log

The linked table lists the operations that can be recorded in the activity log for this service. These operations are a subset of [all the possible resource provider operations in the activity log](/en-us/azure/role-based-access-control/resource-provider-operations).

For more information on the schema of activity log entries, see [Activity Log schema](/en-us/azure/azure-monitor/essentials/activity-log-schema).

- [Microsoft.ContainerService resource provider operations](/en-us/azure/role-based-access-control/resource-provider-operations#containers)

The following table lists a few example operations related to AKS that might be created in the Activity log. Use the Activity log to track information such as when a cluster is created or had its configuration change. You can view this information in the portal or by using [other methods](/en-us/azure/azure-monitor/essentials/activity-log#other-methods-to-retrieve-activity-log-events). You can also use it to create an Activity log alert to be proactively notified when an event occurs.

| Operation | Description |
| --- | --- |
| Microsoft.ContainerService/managedClusters/write | Create or update managed cluster |
| Microsoft.ContainerService/managedClusters/delete | Delete Managed Cluster |
| Microsoft.ContainerService/managedClusters/listClusterMonitoringUserCredential/action | List clusterMonitoringUser credential |
| Microsoft.ContainerService/managedClusters/listClusterAdminCredential/action | List clusterAdmin credential |
| Microsoft.ContainerService/managedClusters/agentpools/write | Create or Update Agent Pool |