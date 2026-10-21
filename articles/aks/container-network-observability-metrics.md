---
layout: Conceptual
title: Container network metrics overview - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/container-network-observability-metrics
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
description: An overview of container network metrics collection and filtering in Advanced Container Networking Services for Azure Kubernetes Service (AKS).
author: shaifaligargmsft
ms.author: shaifaligarg
ms.subservice: aks-networking
ms.topic: overview
ms.date: 2025-05-10T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 475f19b1-832c-2836-d836-c70fae3c2bb0
document_version_independent_id: 73e6dc98-d2f2-148b-eefc-635c33e4574e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/container-network-observability-metrics.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/container-network-observability-metrics
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/container-network-observability-metrics.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 13bfda79-4bf2-afba-ad96-bd38dcaf34db
---

# Container network metrics overview - Azure Kubernetes Service | Microsoft Learn

Every pod, service, and node in a Kubernetes cluster is constantly generating network activity: connections opening, packets being forwarded or dropped, DNS queries resolving or failing. Understanding that activity is essential for debugging, capacity planning, and keeping services healthy. But most monitoring setups fall short in two ways:

- **Not enough visibility.** Node-level aggregates tell you something is wrong, but not *where*. Without pod-level breakdowns that include source and destination context, isolating a failing workload means guessing.
- **Too much data at scale.** A cluster running hundreds of microservices can produce thousands of metric time series per node. Collecting everything drives up storage costs and slows down dashboards.

Container network metrics in [Advanced Container Networking Services](advanced-container-networking-services-overview) for Azure Kubernetes Service (AKS) tackle both. The feature collects network metrics at the node level and the pod level across supported Cilium and non-Cilium data planes, on Linux and Windows.

On Cilium clusters, you can go a step further with source-level filtering, which lets you select exactly which namespaces, workloads, and metric types are collected *before* data leaves the node.

Container metrics filtering is a pre-ingestion control for observability data. Instead of collecting every available metric and filtering later in dashboards or queries, you define what to collect at the source. This keeps high-value metrics for the workloads you care about and avoids ingesting low-value or noisy time series.

The result: actionable network observability on any supported data plane, with optional cost-efficient filtering on Cilium.

Container network metrics give you deep workload-level visibility for troubleshooting and planning, while source-level filtering on Cilium helps keep observability costs proportional to business-critical workloads.

## Collection and filtering at a glance

Use this table to quickly understand where broad collection is available and where fine-grained filtering is available:

| Capability | Cilium clusters | Non-Cilium clusters |
| --- | --- | --- |
| Node-level metric collection | ✅ | ✅ |
| Pod-level metric collection | ✅ (Linux) | ✅ (Linux) |
| Source-level filtering by namespace, pod label, and metric type | ✅ | ❌ |
| Cost control through pre-ingestion filtering | ✅ | ❌ |

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Key benefits

- **Node and pod-level granularity.** Track traffic volume, drop rates, and connection states at the node level for infrastructure health. Drill down to individual pods with source and destination labels to pinpoint the exact workload causing an issue.
- **Faster troubleshooting.** When a service starts dropping packets or DNS queries fail, pod-level metrics let you isolate the problem to a specific pod, namespace, or protocol in seconds, not hours.
- **Flexible visualization.** Store metrics in Azure Managed Prometheus and visualize in Azure Managed Grafana (fully managed), or bring your own Prometheus and Grafana infrastructure.
- **Scalable by design.** The pipeline handles large, dynamic clusters with hundreds of nodes and thousands of pods without requiring you to choose between comprehensive coverage and manageable data volumes.
- **Targeted observability (Cilium clusters).** On Cilium clusters, source-level filtering lets you define the namespaces, pod labels, or metric types you care about and collect only those. No post-collection trimming required.
- **Lower metrics ingestion costs (Cilium clusters).** Because filtering happens at the source on each node, unwanted metric time series are never scraped, transmitted, or ingested into your Prometheus backend. You pay only for the metrics you actually need. In large clusters where unfiltered collection can produce thousands of time series per node, source-level filtering can significantly reduce Azure Managed Prometheus ingestion and storage costs.

## How it works

[![Diagram of the Container Network Observability architecture.](media/advanced-container-networking-services/advanced-network-observability.png)](media/advanced-container-networking-services/advanced-network-observability.png#lightbox)

The agent stack on each node depends on the data plane, as shown in the diagram.

**Linux Cilium nodes** use a layered eBPF-based stack: eBPF kernel hooks capture raw traffic data, Cilium processes it, and Hubble exposes it as Prometheus-format metrics. Because Hubble sits between the node and the scrape endpoint, source-level filtering runs at this layer — you select which namespaces, pod labels, and metric types are exported before data leaves the node.

**Linux non-Cilium nodes** use eBPF kernel hooks feeding into Microsoft Retina, with a Hubble layer on top for flow inspection. Microsoft Retina handles metric collection and exports node-level and pod-level metrics in Prometheus format.

From all paths, metrics are scraped in Prometheus format and ingested into Azure Managed Prometheus or your own Prometheus backend, then visualized in Azure Managed Grafana or your own Grafana stack.

To get started, [Set up container network metrics](container-network-observability-how-to), and then [configure container network metrics filtering](how-to-configure-container-network-metrics-filtering) for Cilium clusters.

## When to use container network metrics

Container network metrics are designed for teams that need focused, actionable network data rather than raw telemetry. Common scenarios include:

- **Debugging a specific workload.** Use pod-level metrics to isolate packet drops, TCP resets, or DNS failures for a particular service. On Cilium clusters, filtering can narrow collection to just that namespace or pod label, cutting through cluster-wide noise.
- **Monitoring multi-tenant clusters.** Track network health per namespace so each team has visibility into its own traffic patterns. On Cilium clusters, scoped filtering keeps collection limited to tenant-specific namespaces.
- **Capacity planning.** Track forwarded and dropped byte counts per node to identify saturated links or imbalanced workload placement.
- **DNS health monitoring.** Surface DNS query failures and slow resolution times to catch issues before they cascade into application errors.
- **Reducing observability costs at scale.** In large clusters, unfiltered collection can generate thousands of time series per node. On Cilium clusters, source-level filtering removes unwanted series before ingestion so costs stay aligned with the workloads and metric types you choose.

## How to choose what to collect (Cilium clusters)

Use this rollout model to balance visibility and cost:

1. Start with broad collection in a nonproduction namespace to establish a baseline.
2. Keep packet drop, DNS, and TCP state metrics for critical namespaces.
3. Scope high-cardinality flow metrics to business-critical workloads only.
4. Review Prometheus ingestion trends and refine filters weekly.

This approach helps you keep high-value metrics while controlling time-series growth and ingestion costs.

## Before you review the metrics tables

Keep these points in mind:

- Node-level metrics are available across supported Cilium and non-Cilium data planes.
- Pod-level metrics are available on Linux.
- Source-level filtering is available on Cilium clusters only.
- On Cilium clusters, DNS metrics require a Cilium FQDN network policy.

## Metrics reference

### Node-level metrics

Node-level metrics provide aggregate traffic statistics per node — forwarded and dropped packets, byte counts, and connection states. These metrics are stored in Prometheus format and can be visualized in Grafana.

The following metrics are aggregated per node. All metrics include these labels:

- `cluster`
- `instance` (node name)

# [Cilium](#tab/Cilium)
For Cilium data plane clusters, node-level metrics are available on Linux only. Cilium exposes the following metrics used by container network metrics:

| Metric name | Description | Extra labels | Linux | Windows |
| --- | --- | --- | --- | --- |
| **cilium\_forward\_count\_total** | Total forwarded packet count | `direction` | ✅ | ❌ |
| **cilium\_forward\_bytes\_total** | Total forwarded byte count | `direction` | ✅ | ❌ |
| **cilium\_drop\_count\_total** | Total dropped packet count | `direction`, `reason` | ✅ | ❌ |
| **cilium\_drop\_bytes\_total** | Total dropped byte count | `direction`, `reason` | ✅ | ❌ |

# [Non-Cilium](#tab/non-Cilium)
For non-Cilium data plane scenarios, container network metrics are available for both Linux and Windows.

| Metric name | Description | Extra labels | Linux | Windows |
| --- | --- | --- | --- | --- |
| **networkobservability\_conntrack\_bytes\_rx** | Conntrack RX byte count |  | ✅ | ❌ |
| **networkobservability\_conntrack\_bytes\_tx** | Conntrack TX byte count |  | ✅ | ❌ |
| **networkobservability\_conntrack\_packets\_rx** | Conntrack RX packet count |  | ✅ | ❌ |
| **networkobservability\_conntrack\_packets\_tx** | Conntrack TX packet count |  | ✅ | ❌ |
| **networkobservability\_conntrack\_total\_connections** | Total conntrack connections |  | ✅ | ❌ |
| **networkobservability\_dns\_request\_count** | DNS request count |  | ✅ | ❌ |
| **networkobservability\_dns\_response\_count** | DNS response count |  | ✅ | ❌ |
| **networkobservability\_drop\_bytes** | Total dropped byte count | `reason`, `direction` | ✅ | ❌ |
| **networkobservability\_drop\_count** | Total dropped packet count | `reason`, `direction` | ✅ | ✅ |
| **networkobservability\_forward\_bytes** | Total forwarded byte count | `direction` | ✅ | ✅ |
| **networkobservability\_forward\_count** | Total forwarded packet count | `direction` | ✅ | ✅ |
| **networkobservability\_infiniband\_counter\_stats** | InfiniBand counter statistics | `statistic_name`, `device`, `port` | ✅ | ❌ |
| **networkobservability\_infiniband\_status\_params** | InfiniBand status parameters | `statistic_name`, `interface_name` | ✅ | ❌ |
| **networkobservability\_interface\_stats** | Interface statistics (rx/tx packets, drops, and more) | `interface_name`, `statistic_name` | ✅ | ❌ |
| **networkobservability\_ip\_connection\_stats** | IP connection statistics | `statistic_name` | ✅ | ❌ |
| **networkobservability\_node\_apiserver\_handshake\_latency** | TCP handshake latency to API server |  | ✅ | ❌ |
| **networkobservability\_node\_apiserver\_latency** | Node to API server latency |  | ✅ | ❌ |
| **networkobservability\_node\_apiserver\_no\_response** | No response from API server count |  | ✅ | ❌ |
| **networkobservability\_node\_connectivity\_latency\_seconds** | Node-to-node connectivity latency | `source_node_name`, `target_node_name` | ✅ | ✅ |
| **networkobservability\_node\_connectivity\_status** | Node-to-node connectivity status (ICMP/HTTP) | `source_node_name`, `target_node_name` | ✅ | ✅ |
| **networkobservability\_tcp\_connection\_remote** | TCP active socket count by remote IP | `address` | ✅ | ❌ |
| **networkobservability\_tcp\_connection\_stats** | TCP connection statistics (for example, DelayedACKs, TCPKeepAlive, TCPSackFailures) | `statistic_name` | ✅ | ✅ |
| **networkobservability\_tcp\_flag\_gauges** | TCP packet counts by flag | `direction`, `flag` | ❌ | ✅ |
| **networkobservability\_tcp\_retransmission\_count** | TCP retransmission count |  | ✅ | ❌ |
| **networkobservability\_tcp\_state** | TCP active socket count by state | `state` | ✅ | ❌ |
| **networkobservability\_udp\_connection\_stats** | UDP connection statistics | `statistic_name` | ✅ | ❌ |
| **networkobservability\_windows\_hns\_stats** | Windows HNS statistics (packets sent and received) | `direction` | ❌ | ✅ |

---

### Pod-level metrics (Hubble metrics)

Pod-level metrics include source and destination pod information, so you can pinpoint network issues at the individual workload level. These metrics cover traffic volume, dropped packets, TCP resets, and Layer 4/Layer 7 flows.

DNS metrics (query counts, response codes, and errors) are collected by default on non-Cilium data planes. On Cilium data planes, DNS metrics require a Cilium FQDN network policy. You can also troubleshoot DNS in real time by using the Hubble CLI.

The following table describes the metrics that are aggregated per pod (node information is preserved).

All metrics include labels:

- `cluster`
- `instance` (node name)
- `source` or `destination`

    - For *outgoing traffic*, a `source` label indicates the source pod namespace and name.
    - For *incoming traffic*, a `destination` label indicates the destination pod namespace and name.

| Metric name | Description | Extra labels | Linux | Windows |
| --- | --- | --- | --- | --- |
| **hubble\_dns\_queries\_total** | Total DNS requests by query | `source` or `destination`, `query`, `qtypes` (query type) | ✅ | ❌ |
| **hubble\_dns\_responses\_total** | Total DNS responses by query/response | `source` or `destination`, `query`, `qtypes` (query type), `rcode` (return code), `ips_returned` (number of IPs) | ✅ | ❌ |
| **hubble\_drop\_total** | Total dropped packet count | `source` or `destination`, `protocol`, `reason` | ✅ | ❌ |
| **hubble\_tcp\_flags\_total** | Total TCP packet count by flag | `source` or `destination`, `flag` | ✅ | ❌ |
| **hubble\_flows\_processed\_total** | Total network flows processed (Layer 4/Layer 7 traffic) | `source` or `destination`, `protocol`, `verdict`, `type`, `subtype` | ✅ | ❌ |

## Limitations

**Platform and data plane:**

- Pod-level metrics are available only on Linux.
- Cilium data plane is supported starting with Kubernetes version 1.29.
- Source-level metrics filtering is available only on Cilium clusters.
- Metric labels have subtle differences between Cilium and non-Cilium clusters.

**DNS metrics:**

- On Cilium clusters, DNS metrics require a Cilium FQDN network policy, or you can use the Hubble CLI for real-time DNS troubleshooting.

**Known issues:**

- If a Hubble node agent goes down, the Hubble relay might crash, which can interrupt Hubble CLI sessions.

**FIPS support (non-Cilium data planes only):**

- FIPS isn't available on Ubuntu 20.04 nodes due to kernel restrictions. Use an Azure Linux or Ubuntu 22.04 node pool instead. This limitation doesn't apply to Cilium data planes.

| Operating system | FIPS support |
| --- | --- |
| Azure Linux 3.0 | Yes |
| Azure Linux 2.0 | Yes |
| Ubuntu 20.04 | No |
| Ubuntu 22.04 | Yes |

**Scale:**

- The managed service for Prometheus in Azure Monitor and Azure Managed Grafana impose service-specific scale limitations. For more information, see [Scrape Prometheus metrics at scale in Azure Monitor](/en-us/azure/azure-monitor/essentials/prometheus-metrics-scrape-scale).

## Pricing

Important

Advanced Container Networking Services is a paid offering.

For more information about pricing, see [Advanced Container Networking Services - Pricing](https://azure.microsoft.com/pricing/details/azure-container-networking-services/).