---
layout: Conceptual
title: Istio service mesh Azure Kubernetes Service add-on latency comparison - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-latency
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
description: Istio service mesh Azure Kubernetes Service add-on latency compared across add-on versions
ms.topic: concept-article
ms.custom: 
ms.date: 2024-09-30T00:00:00.0000000Z
author: schaffererin
ms.author: shalierxia
ai-usage: ai-assisted
locale: en-us
document_id: cdd4e7c3-6525-41e8-eaea-184a571dfb01
document_version_independent_id: 3658a6b2-a531-353a-5b05-d915b3fa81b3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-latency.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/istio-latency
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-latency.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f98b5a1b-9ee4-2f3b-cf72-0730d9ea6b6f
---

# Istio service mesh Azure Kubernetes Service add-on latency comparison - Azure Kubernetes Service | Microsoft Learn

This document elaborates on the [data plane latency performance](istio-scale#data-plane-performance) across Istio add-on versions and Kubernetes version. The results evaluate the impact of adding sidecar proxies to the data path, showcasing the P90 and P99 latency difference. The comparison measures the difference between traffic routed through the sidecar and traffic sent directly to the pod.

- Traffic going through the sidecar: client --&gt; client-sidecar --&gt; server-sidecar --&gt; server
- Traffic directly going to the pod: client --&gt; server

## Test specifications

- Node SKU: Standard D16 v5 (16 vCPU, 64-GB memory)
- Two proxy workers
- 1-KB payload
- 1,000 Queries per second (QPS) at varying client connections
- `http/1.1` protocol and mutual Transport Layer Security (TLS) enabled

| P99 Latency Difference | P90 Latency Difference |
| --- | --- |
| [![Diagram that compares P99 Latency Difference vs Istio | Kubernetes Version across CNI Plugins.](media/aks-istio-addon/latency-comparison/p99.png)](media/aks-istio-addon/latency-comparison/p99.png#lightbox) | [![Diagram that compares P90 Latency Difference vs Istio | Kubernetes Version across CNI Plugins.](media/aks-istio-addon/latency-comparison/p90.png)](media/aks-istio-addon/latency-comparison/p90.png#lightbox) |