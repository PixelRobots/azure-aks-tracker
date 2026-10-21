---
layout: Conceptual
title: Monitoring Data Reference for Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/monitor-container-registry-reference
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: jeburke
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: jeburke
ms.service: azure-container-registry
description: Access essential reference material for monitoring Azure Container Registry, including metrics, logs, and activity logs for comprehensive insights.
ms.date: 2026-10-09T00:00:00.0000000Z
ms.custom: horz-monitor, subject-monitoring
ms.topic: reference
ai-usage: ai-assisted
locale: en-us
document_id: 2980c5e5-8758-47d6-4b9c-1858d41d5e47
document_version_independent_id: 785d9f4d-d5da-24be-7536-48b65da04ba5
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/monitor-container-registry-reference.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/monitor-container-registry-reference
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/monitor-container-registry-reference.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 5473cbdf-87a8-0677-4e19-2d2316a8103b
---

# Monitoring Data Reference for Azure Container Registry - Azure Container Registry | Microsoft Learn

This article contains all the monitoring reference information for this service.

See [Monitor Azure Container Registry](monitor-container-registry) for details on the data you can collect for Azure Container Registry and how to use it.

## Metrics

This section lists all the automatically collected platform metrics for this service. These metrics are also part of the global list of [all platform metrics supported in Azure Monitor](/en-us/azure/azure-monitor/reference/supported-metrics/metrics-index#supported-metrics-per-resource-type).

For information on metric retention, see [Azure Monitor Metrics overview](/en-us/azure/azure-monitor/essentials/data-platform-metrics#retention-of-metrics).

### Supported metrics for Microsoft.ContainerRegistry/registries

The following table lists the metrics available for the Microsoft.ContainerRegistry/registries resource type.

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
| **AgentPool CPU Time**AgentPool CPU Time in seconds | `AgentPoolCPUTime` | No | Seconds | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Data Transfer**Total outbound data transferred from the registry, measured in bytes. | `DataTransfer` | No | Bytes | Total (Sum) | `ApiName`, `Region` | PT1M | Yes |
| **Run Duration**Run Duration in milliseconds | `RunDuration` | No | MilliSeconds | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Storage used**The amount of storage used by the container registry. For a registry account, it's the sum of capacity used by all the repositories within a registry. It's sum of capacity used by shared layers, manifest files, and replica copies in each of its repositories. | `StorageUsed` | No | Bytes | Average | `Geolocation` | PT1H | Yes |
| **Successful Pull Count**Number of successful image pulls | `SuccessfulPullCount` | No | Count | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Successful Push Count**Number of successful image pushes | `SuccessfulPushCount` | No | Count | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Total Pull Count**Number of image pulls in total | `TotalPullCount` | No | Count | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Total Push Count**Number of image pushes in total | `TotalPushCount` | No | Count | Total (Sum) | &lt;none&gt; | PT1M | Yes |
| **Transactions**Count of registry API operations, segmented by API name and response type. | `Transactions` | No | Count | Total (Sum) | `ApiName`, `ResponseType`, `Region` | PT1M | Yes |

Note

Because of layer sharing, registry **Storage used** might be less than the sum of storage for individual repositories. When you [delete](container-registry-delete) a repository or tag, you recover only the storage used by manifest files and the unique layers referenced.

## Metric dimensions

For information about what metric dimensions are, see [Multi-dimensional metrics](/en-us/azure/azure-monitor/platform/data-platform-metrics#multi-dimensional-metrics).

This service has the following dimensions associated with its metrics.

| Dimension name | Description |
| --- | --- |
| `ApiName` | The registry operation represented by the metric. Available values depend on the metric. |
| `ResponseType` | The outcome of a transaction, classified by its HTTP status code. |
| `Region` | The Azure region that handled the transaction or from which data was transferred. |

`Region` values depend on the registry's home region and [geo-replicas](container-registry-geo-replication).

Note

The `StorageUsed` metric uses the legacy `Geolocation` dimension to represent the Azure region where content is stored. Use `Geolocation` when filtering or splitting `StorageUsed`. Newer metrics use the `Region` dimension.

### API name values

The `Transactions` metric supports the following `ApiName` values:

- `HeadManifest`: Checks whether a manifest exists and retrieves its response headers.
- `GetManifest`: Retrieves a manifest.
- `GetManifestProperties`: Retrieves properties for a specific manifest.
- `GetListManifests`: Lists the manifests in a repository.
- `GetTag`: Retrieves information about a tag.
- `GetListTags`: Lists the tags in a repository.
- `HeadBlob`: Checks whether a blob or layer exists and retrieves its response headers.
- `GetBlobRedirection`: Redirects a blob or layer download request to its content location.
- `GetBlob`: Retrieves blob or layer content.
- `GetListRepositories`: Lists repositories in the registry.
- `GetListReferrers`: Lists artifacts that refer to a specified manifest digest.
- `GetRepositoryProperties`: Retrieves repository properties.
- `GetToken`: Requests an ACR access token for the requested scope.
- `PostToken`: Exchanges an ACR refresh token for an ACR access token.
- `PostExchange`: Exchanges a Microsoft Entra access token for an ACR refresh token.

For the corresponding API definitions, see [Registry data plane REST operation groups](/en-us/rest/api/registry-dataplane/operation-groups).

The `DataTransfer` metric supports the following `ApiName` values:

- `GetBlob`: Data transferred when a client downloads a blob or layer.
- `GetManifest`: Data transferred when a client retrieves a manifest.
- `GeoReplication`: Data transferred during service-initiated geo-replication, including initial synchronization and replication after a push.
- `ImportSource`: Data transferred when another Azure container registry uses this registry as the source of an import operation.

### Response type values

The `Transactions` metric supports the following `ResponseType` values:

- `Success`: The operation succeeded with HTTP status code 200, 201, or 202.
- `Redirect`: The operation returned HTTP status code 307. For example, a blob download can redirect the client to the blob's content location.
- `ClientErrorUnauthorized`: Authentication or authorization failed with HTTP status code 401 or 403.
- `ClientErrorNotFound`: The requested resource wasn't found and returned HTTP status code 404.
- `Throttled`: The request was rate limited and returned HTTP status code 429.
- `ClientErrorOther`: The operation returned a 4xx client error that doesn't have a dedicated response type.
- `ServerErrorOther`: The operation returned a 5xx server error.

## Resource logs

This section lists the types of resource logs you can collect for this service. The section pulls from the list of [all resource logs category types supported in Azure Monitor](/en-us/azure/azure-monitor/platform/resource-logs-schema).

### Supported resource logs for Microsoft.ContainerRegistry/registries

| Category | Costs to export | Log table | [Supports basic log plan](/en-us/azure/azure-monitor/logs/basic-logs-configure?tabs=portal-1#compare-the-basic-and-analytics-log-data-plans) | [Supports ingestion-time transformation](/en-us/azure/azure-monitor/essentials/data-collection-transformations) | Example queries |
| --- | --- | --- | --- | --- | --- |
| ContainerRegistryLoginEvents | No | [ContainerRegistryLoginEvents](/en-us/azure/azure-monitor/reference/tables/containerregistryloginevents)<br>Azure Container Registry Login Auditing Logs | No | Yes | [Queries](/en-us/azure/azure-monitor/reference/queries/containerregistryloginevents) |
| ContainerRegistryRepositoryEvents | No | [ContainerRegistryRepositoryEvents](/en-us/azure/azure-monitor/reference/tables/containerregistryrepositoryevents)<br>Azure Container Registry Repository Auditing Logs | No | Yes | [Queries](/en-us/azure/azure-monitor/reference/queries/containerregistryrepositoryevents) |

## Azure Monitor Logs tables

This section lists the Azure Monitor Logs tables relevant to this service, which are available for query by Log Analytics using Kusto queries. The tables contain resource log data and possibly more depending on what is collected and routed to them.

For a reference of all Azure Monitor Logs and Log Analytics tables, see the [Azure Monitor Log Table Reference](/en-us/azure/azure-monitor/reference/tables-index).

### Container Registry Microsoft.ContainerRegistry/registries

- [AzureActivity](/en-us/azure/azure-monitor/reference/tables/azureactivity#columns). Entries from the Azure Activity log that provide insight into any subscription-level or management group level events that occurred in Azure.
- [AzureMetrics](/en-us/azure/azure-monitor/reference/tables/azuremetrics#columns). Metric data emitted by Azure services that measure their health and performance.
- [ContainerRegistryLoginEvents](/en-us/azure/azure-monitor/reference/tables/containerregistryloginevents#columns). Registry authentication events and status, including the incoming identity and IP address.
- [ContainerRegistryRepositoryEvents](/en-us/azure/azure-monitor/reference/tables/containerregistryrepositoryevents#columns). Operations on images and other artifacts in registry repositories. The following operations are logged: push, pull, untag, delete (including repository delete), purge tag, and purge manifest.

    Purge events are logged only if a registry [retention policy](container-registry-retention-policy) is configured.

## Activity log

The linked table lists the operations that can be recorded in the activity log for this service. These operations are a subset of [all the possible resource provider operations in the activity log](/en-us/azure/role-based-access-control/resource-provider-operations).

For more information on the schema of activity log entries, see [Activity Log schema](/en-us/azure/azure-monitor/essentials/activity-log-schema).

- [Microsoft.ContainerRegistry resource provider operations](/en-us/azure/role-based-access-control/resource-provider-operations#microsoftcontainerregistry)

The following table lists operations related to Azure Container Registry that can be created in the Activity log. This list isn't exhaustive.

| Operation | Description |
| --- | --- |
| Create or Update Container Registry | Create a container registry or update a registry property |
| Delete Container Registry | Delete a container registry |
| List Container Registry Login Credentials | Show credentials for registry's admin account |
| Import Image | Import an image or other artifact to a registry |
| Create Role Assignment | Assign an identity a Role-based access control (RBAC) role to access a resource |