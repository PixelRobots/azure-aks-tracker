---
layout: Conceptual
title: Multi-Cluster Service Connectivity with Application Network (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/application-network-multi-cluster
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
description: Plan service-to-service connectivity across AKS clusters and find the Application Network topology and configuration guides.
author: jack4it
ms.author: mjac
ms.subservice: aks-networking
ms.topic: concept-article
ms.date: 2026-11-07T00:00:00.0000000Z
ai-usage: ai-generated
locale: en-us
document_id: e5cf8345-38a5-2e2d-2a4f-0e9f8a4b6386
document_version_independent_id: 9ec0a06f-ca8f-424c-13e7-042e921e3b30
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/application-network-multi-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/application-network-multi-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/application-network-multi-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 9cb970e0-d21b-cd11-384f-a19fcd62c241
---

# Multi-Cluster Service Connectivity with Application Network (Preview) - Azure Kubernetes Service | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

[Azure Kubernetes Application Network (Application Network)](application-network-overview) connects participating services across AKS member clusters through an ambient service network. Use it for service-to-service communication with workload identity, mutual TLS (mTLS), and optional layer 7 routing.

For configuration steps, see [Configure multi-cluster connectivity](../application-network/multi-cluster-connectivity) in the [Application Network documentation](../application-network/).

## Choose the service traffic path

Join the clusters to the same Application Network, and then choose a topology based on pod IP reachability. Clusters with a flat, routable pod address space can communicate directly. Clusters with separate pod address spaces that aren't directly reachable, or that overlap, communicate through east-west gateways.

| Topology | Service traffic path | Connectivity you provide |
| --- | --- | --- |
| Flat, routable pod address space | Direct pod IP communication through the ambient data plane. | Bidirectional reachability between non-overlapping pod IP addresses. |
| Separate pod address spaces without direct reachability, or overlapping address spaces | Communication through east-west gateways. | Reachability from each member cluster's data plane to the other member clusters' gateways. |

When you join a cluster, use `--network-name` on `az appnet member join` to identify which member clusters share direct pod IP reachability. Assign the same name only to members with bidirectional reachability between non-overlapping pod addresses; use different names for members that require gateways. The name declares connectivity; it doesn't create it. Virtual network (VNet) peering alone doesn't make Azure CNI Overlay pod IP addresses directly reachable across clusters. An east-west gateway carries cross-cluster service traffic, not application ingress. See [Configure multi-cluster connectivity](../application-network/multi-cluster-connectivity).

## Enroll workloads and export services

Joining clusters doesn't automatically enroll workloads or export services. Enroll workloads in the ambient data plane by labeling their namespace with `istio.io/dataplane-mode=ambient`. Mark each service you want other member clusters to discover as a global service with `istio.io/global="true"`. To configure enrollment, global services, and optional waypoints, follow the [traffic management walkthrough](../application-network/traffic-management-use-cases).