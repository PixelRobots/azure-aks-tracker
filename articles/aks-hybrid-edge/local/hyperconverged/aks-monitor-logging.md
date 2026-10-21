---
layout: Conceptual
title: Monitor and log data | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/aks-monitor-logging
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
description: Learn how to create and access monitoring and logging data for AKS Hybrid and Edge.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2024-01-17T00:00:00.0000000Z
ms.reviewer: guanghu
ms.custom: hyperconverged
locale: en-us
document_id: 0425bf24-a6b1-ae6f-3500-3ba67751e4f5
document_version_independent_id: 9b6f8abb-aef5-ad81-cae6-89523ae58c6a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/aks-monitor-logging.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/aks-monitor-logging
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/aks-monitor-logging.md
platformId: e9ce14a3-b707-5d78-081d-b29abbf977a6
---

# Monitor and log data | Microsoft Learn

&gt; Applies to: AKS on Windows Server, AKS on Azure Local

This article describes how to monitor your AKS Hybrid and Edge deployment using on-premises monitoring. Two types of monitoring and logging solutions are available, as described in the following table:

| Solution | Azure connectivity | Support and service | Cost |
| --- | --- | --- | --- |
| Container Insights | Requires connecting the Kubernetes cluster to Azure using Azure Arc for Kubernetes. | Full support and servicing from Microsoft. | Requires signing up for the Azure Monitor service. |
| On-premises monitoring | Doesn't require Azure connectivity. | Supported as open-source software by Microsoft (with no support agreement or SLAs), the community, and/or external vendors. | Vendor-dependent. |

You can choose Container Insights or on-premises monitoring, depending on your monitoring use cases. For Container Insights, see [Enable Container Insights](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable).

## Monitoring solution overview

**Prometheus** is a monitoring and alerting toolkit you can use for monitoring containerized workloads. As part of the Prometheus solution in AKS Hybrid and Edge, the following components are deployed and automatically configured:

- [Prometheus operator](https://github.com/prometheus-operator/prometheus-operator)
- [Prometheus](https://github.com/prometheus/prometheus)
- [Kube state metrics](https://github.com/kubernetes/kube-state-metrics)
- [Node exporter](https://github.com/prometheus/node_exporter)
- [Windows exporter](https://github.com/prometheus-community/windows_exporter)

The deployment is based on the publicly available [Kube-Prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) helm chart, which is extended to support the Windows exporter and secures metrics scraping between Prometheus and agents. Once you deploy the Prometheus solution, the node exporter runs on each Linux node, and the Windows exporter runs on each Windows node.

Note

Since the Prometheus operator, Prometheus, and Kube state metrics components are only supported on Linux, you must provision at least one Linux node in your Kuberneted cluster to deploy this solution.

The objects and endpoints that the Prometheus solution scrapes include the following items:

- Kube state metrics to collect [various metrics provided by Kubernetes](https://github.com/kubernetes/kube-state-metrics/tree/master/docs#exposed-metrics)
- Kubernetes API server
- Kubelet
- Node exporter to collect metrics for Linux nodes
- Windows exporter to collect metrics for Windows nodes

## Deploy monitoring solution

Prometheus is an open-source monitoring system with a dimensional data model, flexible query language, efficient time series database and modern alerting approach. Grafana is a tool used to view, query, and visualize metrics on the Grafana dashboards. It can be configured to use Prometheus as the data source. Usually, they are used together for Kubernetes cluster monitoring.

To view the Grafana dashboards available in AKS Hybrid and Edge, see [Grafana dashboards available in AKS](https://github.com/microsoft/AKS-Arc-Apps/blob/main/Monitoring/Grafana.md#grafana-dashboards-available-in-aks-hci).

You can view Microsoft's deployment [guidance on GitHub](https://github.com/microsoft/AKS-Arc-Apps/tree/main/Monitoring) to deploy Prometheus on your Kubernetes cluster and configure Grafana to use Prometheus as data source. You can also follow any publicly available documentation to deploy any specific version of Prometheus or Grafana.