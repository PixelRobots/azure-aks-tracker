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
ms.date: 2026-11-04T00:00:00.0000000Z
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
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 13bfda79-4bf2-afba-ad96-bd38dcaf34db
---

# Container network metrics overview - Azure Kubernetes Service | Microsoft Learn

Container network metrics in [Advanced Container Networking Services](advanced-container-networking-services-overview) for Azure Kubernetes Service (AKS) help you identify packet drops, track network activity, and investigate DNS behavior. Start with node-level metrics to find a network-health issue, then use pod-level metrics to identify the workloads involved.

Metric collection is available across supported Cilium and non-Cilium data planes. Pod-level metrics require Linux; the reference tables show which node-level metrics are also available on Windows.

## Metric collection at a glance

Use this table to check metric collection support across data planes:

| Capability | Cilium clusters | Non-Cilium clusters |
| --- | --- | --- |
| Node-level metric collection | ✅ | ✅ |
| Pod-level metric collection | ✅ (Linux) | ✅ (Linux) |

For initial collection, follow [Set up container network metrics](container-network-observability-how-to). For records of individual traffic details rather than counters, use [container network logs](container-network-observability-logs).

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images are removed, and you can't scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](upgrade-aks-control-plane) to a supported Kubernetes version or migrating to [osSku AzureLinux3](upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Key benefits

- **Node and pod-level granularity.** Track traffic volume, drop rates, and connection states at the node level for infrastructure health. Drill down to individual pods with source and destination labels to pinpoint the exact workload causing an issue.
- **Faster troubleshooting.** When a service starts dropping packets or DNS queries fail, pod-level metrics help you isolate the problem to a specific pod, namespace, or protocol.
- **Built-in visualization.** Store metrics in Azure Monitor managed service for Prometheus and open networking dashboards directly in the Azure portal with **Dashboards with Grafana**. The dashboard experience is free and doesn't require an Azure Managed Grafana instance; ACNS and metrics ingestion and storage charges still apply. You can also use a separate Grafana deployment.

## How it works

[![Diagram of the Container Network Observability architecture.](media/advanced-container-networking-services/advanced-network-observability.png)](media/advanced-container-networking-services/advanced-network-observability.png#lightbox)

The agent stack on each node depends on the data plane, as shown in the diagram.

**Linux Cilium nodes** use a layered eBPF-based stack: eBPF kernel hooks capture raw traffic data, Cilium processes it, and Hubble exposes it as Prometheus-format metrics.

**Linux non-Cilium nodes** use eBPF kernel hooks feeding into Microsoft Retina, with a Hubble layer on top for flow inspection. Microsoft Retina handles metric collection and exports node-level and pod-level metrics in Prometheus format.

From all paths, you scrape metrics in Prometheus format and ingest them into Azure Monitor managed service for Prometheus or your own Prometheus backend. For the managed path, open your AKS cluster in the Azure portal and select **Monitoring** &gt; **Dashboards with Grafana** to view networking dashboards. Azure Managed Grafana and your own Grafana deployment are optional alternatives. See [Use dashboards with Grafana with AKS](/en-us/azure/azure-monitor/visualize/grafana-kubernetes).

To get started, [Set up container network metrics](container-network-observability-how-to).

## When to use container network metrics

Container network metrics are designed for teams that need focused, actionable network data rather than raw telemetry. Common scenarios include:

- **Debugging a specific workload.** Use pod-level metrics to isolate packet drops, TCP resets, or DNS failures for a particular service.
- **Monitoring multitenant clusters.** Use pod-level metrics to track network health by namespace and understand each team's traffic patterns.
- **Capacity planning.** Track forwarded and dropped byte counts per node to identify saturated links or imbalanced workload placement.
- **DNS health monitoring.** Surface DNS query failures and slow resolution times to catch issues before they cascade into application errors.

## Before you review the metrics tables

Keep these points in mind:

- Node-level metrics are available across supported Cilium and non-Cilium data planes.
- Pod-level metrics are available on Linux.
- On Cilium clusters, DNS metrics require a Cilium FQDN network policy.

## Metrics reference

### Node-level metrics

Node-level metrics provide aggregate traffic statistics per node — forwarded and dropped packets, byte counts, and connection states. These metrics are stored in Prometheus format and can be visualized in Grafana.

The following metrics are aggregated per node. All metrics include these labels:

- `cluster`
- `instance` (node name)

#### Cilium

For Cilium data plane clusters, node-level metrics are available on Linux only. Cilium exposes the following metrics used by container network metrics:

| Metric name | Description | Extra labels | Linux | Windows |
| --- | --- | --- | --- | --- |
| **cilium\_forward\_count\_total** | Total forwarded packet count | `direction` | ✅ | ❌ |
| **cilium\_forward\_bytes\_total** | Total forwarded byte count | `direction` | ✅ | ❌ |
| **cilium\_drop\_count\_total** | Total dropped packet count | `direction`, `reason` | ✅ | ❌ |
| **cilium\_drop\_bytes\_total** | Total dropped byte count | `direction`, `reason` | ✅ | ❌ |

#### Non-Cilium

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

## Choose which metrics to collect on Cilium clusters

On Cilium clusters, use **source-level filtering** to select which observations contribute to individual Hubble metrics before they reach your monitoring backend. This filtering is different from filtering a Grafana dashboard, which changes only what you see. Narrow collection to an application, and then selectively enable external-IP or destination-port metrics when an investigation needs that detail.

Filtering can reduce unnecessary collection and help control ingestion costs. Additional metrics can increase time-series count and cost, so verify their value and volume before expanding them. Previously created series and historical samples can remain visible; savings depend on your traffic and configuration.

When you enable Container Network Observability, the agents expose the service's default network metrics. On Cilium clusters, use a `ContainerNetworkMetric` custom resource to select traffic for individual metric types.

Making a metric available on the cluster doesn't automatically make it available in Azure Monitor managed service for Prometheus. By default, the cluster agents expose `hubble_flows_processed_total`, but managed Prometheus excludes it from collection because it can produce a large number of time series. Managed Prometheus also excludes `hubble_flows_to_world_total` and `hubble_port_distribution_total` by default, even when you enable them on the cluster. To collect and query any of these metrics, add its name to the Hubble allow list in the `ama-metrics-settings-configmap` ConfigMap. For steps, see [Allow the metric families in managed Prometheus](container-network-observability-how-to#allow-the-metric-families-in-managed-prometheus).

There's one shared `ContainerNetworkMetric` resource per cluster, named `container-network-metric`. Coordinate updates with other administrators and preserve metric settings used by other teams.

Start with include filters to select traffic for an application or destination. Exclude filters are optional: use them to omit a subset of selected traffic, or use exclude-only filters to retain broad collection with specific exceptions. An exclusion takes precedence over a matching inclusion.

Filtering isn't limited to the optional world and destination-port metrics. Use the following configuration names for existing metrics:

| Metric type | `spec.filters[].metric` | Example filtering task |
| --- | --- | --- |
| DNS | `dns` | Select DNS observations from or to an application client. |
| TCP | `tcp` | Select TCP observations for pods with a particular label. |
| HTTP | `httpV2` | Select HTTP observations involving an application. |
| Flow | `flow` | Select flow observations by workload or security identity. |
| Drop | `drop` | Select drop observations for an application; optionally exclude load-test observations from broad collection. |

These filters apply when the metric is present in the service's base configuration. Filter configuration and observation generation are separate: DNS metric observations require an applied DNS inspection policy and DNS traffic. HTTP metric observations require cluster-level L7 enablement, an HTTP inspection policy applied to the workload, and HTTP traffic through that policy. Filter status doesn't verify these prerequisites. Filtering doesn't enable inspection or decrypt HTTPS traffic. For HTTP, use the case-sensitive name `httpV2`, not `http`.

For examples, see [DNS, TCP, HTTP, and drop filtering](how-to-configure-container-network-metrics-filtering#dns-tcp-http-and-drop-filtering-examples).

For example, use include filters to select flow metrics for TCP traffic from the `production` namespace to endpoints Cilium classifies as world. This changes flow metric collection without changing collection for other metric types. Filters support namespace and pod names, labels, IP addresses, Cilium security identities, protocols, and verdicts.

Filtering controls which observations contribute to a metric. It doesn't add or remove metric labels. Unlike additional aggregation fields for logs, metric dimensions remain managed by the service.

Filtering affects new metric observations at the source. Selecting a workload in Grafana changes the displayed results, not the collection configuration. Previously collected data remains in your metrics backend.

### Additional metrics

To collect either of the following metrics, add an entry to the cluster's `ContainerNetworkMetric` resource with include filters that select the traffic you want to monitor. If the metric isn't already enabled, the entry enables it for the selected traffic. If it's already enabled, the entry filters which traffic contributes to it without changing its existing labels or options.

| Metric | Use | What it counts |
| --- | --- | --- |
| **`hubble_flows_to_world_total`** | Identify destination IP addresses for selected TCP traffic to endpoints that Cilium classifies as world. Configure as `flows-to-world`. | Non-reply TCP SYN observations. With the service's SYN-only configuration, UDP traffic isn't counted. |
| **`hubble_port_distribution_total`** | Examine selected traffic by protocol and destination port. Configure as `port-distribution`. | Forwarded or redirected observations identified as non-reply traffic. Dropped traffic and traffic with unknown reply status aren't counted. |

For metrics newly enabled through this resource, the service configures source pod and destination IP labels for `flows-to-world`. For `port-distribution`, it configures source and destination pod labels and traffic direction. Protocol and verdict labels are included for `flows-to-world`; protocol and destination port labels are included for `port-distribution`. With these service-supplied options, the world metric doesn't count UDP traffic or non-policy drops.

These metrics count observed network events, not unique connections or application requests. For example, if a client sends a TCP SYN packet and then retransmits it while trying to connect, `hubble_flows_to_world_total` can count both observations even though they belong to the same connection attempt. Labels such as pod names are populated only when that information is available for the observed traffic.

For a complete custom resource and screenshots of both metrics collected from a test workload, see [Example configuration and captured results](how-to-configure-container-network-metrics-filtering#example-configuration-and-captured-results).

### Manage data relevance and noise

Use filtering to focus metrics on the workloads and traffic relevant to your monitoring or investigation. Excluding unrelated traffic reduces data noise and helps you focus on the network signals that matter.

Destination IP addresses, pod names, and ports can produce many time series. This detail can be useful, but collecting it for unrelated traffic adds noise and can increase ingestion costs. Start with a specific workload or namespace, review whether the metrics answer your questions, and check the resulting data volume before expanding collection.

The custom resource reports a warning for each enabled extra metric. The warning identifies a potential cost increase; it doesn't estimate your bill or indicate that a limit was exceeded. The service manages metric labels and you can't change them through this resource.

Removing an entry disables the metric only if that entry was what enabled it. If the service supplies the metric, it remains enabled without that entry's filters. Deleting the shared resource removes all its filters and restores service-provided collection, which can broaden the traffic included in those metrics and **increase** data noise and ingestion volume.

For YAML examples, verification queries, and cleanup steps, see [Configure container network metrics filtering](how-to-configure-container-network-metrics-filtering).

## Limitations

**Platform and data plane:**

- Pod-level metrics are available only on Linux.
- Cilium data plane is supported starting with Kubernetes version 1.29.
- Source-level metrics filtering is available only on Cilium clusters.
- Filter entries can enable `flows-to-world` and `port-distribution` when the service doesn't already supply them. The service manages their labels; this resource doesn't expose custom metric dimensions.
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