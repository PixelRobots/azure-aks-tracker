---
layout: Conceptual
title: Observability Overview of Azure Kubernetes Application Network (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-network/observability
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
description: Learn about the observability features available for Azure Kubernetes Application Network, including supported metrics, logs, and tracing capabilities, as well as workspace options for monitoring.
author: Kochhars
ms.author: kochhars
ms.service: azure-kubernetes-app-net
ms.topic: overview
ms.date: 2025-11-04T00:00:00.0000000Z
locale: en-us
document_id: e438be07-cd8f-63c3-7a39-48271e5d19ea
document_version_independent_id: 03fcea6c-7f72-b631-034a-1f27e429ea0b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/application-network/observability.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: application-network/observability
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-network/observability.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 4a580a28-48ea-4cae-48f7-df8d18e41234
---

# Observability Overview of Azure Kubernetes Application Network (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Azure Kubernetes Application Network leverages [Azure Monitor](/en-us/azure/azure-monitor/fundamentals/overview) for comprehensive observability of member clusters. This article provides an overview of the observability features available for Azure Kubernetes Application Network, including supported metrics, logs, and tracing capabilities.

## Observability features

Azure Kubernetes Application Network member observability infrastructure includes the following features:

| Feature | Workspace type | Description |
| --- | --- | --- |
| [**Managed Prometheus**](/en-us/azure/azure-monitor/metrics/prometheus-metrics-overview) | [Azure Monitor workspace](/en-us/azure/azure-monitor/metrics/azure-monitor-workspace-overview) | Stores Prometheus metrics scraped from your cluster. |
| [**Container logging**](/en-us/azure/azure-monitor/containers/container-insights-log-query) | [Log Analytics workspace](/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview) | Stores container logs and control plane logs. |
| [**Dashboards with Grafana**](/en-us/azure/azure-monitor/visualize/visualize-grafana-overview) | [Azure Monitor workspace](/en-us/azure/azure-monitor/metrics/azure-monitor-workspace-overview) | Links to your Azure Monitor workspace to visualize Prometheus metrics in Grafana dashboards. |

## Workspace options for Azure Kubernetes Application Network observability

You can create new workspaces or use existing ones. If you don't specify a workspace ID during onboarding, a default workspace will be created in your resource group. You can onboard workspaces for [metrics](metrics) or [logs](logs). For more information about workspace options, see [Create workspaces](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=cli#create-workspaces).

## Observability limitations

Azure Kubernetes Application Network currently doesn't support tracing or control plane metrics.