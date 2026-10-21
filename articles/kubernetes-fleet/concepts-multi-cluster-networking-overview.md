---
layout: Conceptual
title: Azure Kubernetes Fleet Manager multi-cluster networking concepts | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-multi-cluster-networking-overview
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
learn_banner_products:
- azure
description: This article provides a conceptual overview of Azure Kubernetes Fleet Manager multi-cluster networking.
ms.date: 2026-05-14T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: 5f5af223-a05f-362e-7dec-a8d320a3f253
document_version_independent_id: 68988c1a-e70f-9036-ce16-2e4a6dbd59d9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-multi-cluster-networking-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-multi-cluster-networking-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-multi-cluster-networking-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 18d21962-f18f-27c1-0dff-1ad045ff46a4
---

# Azure Kubernetes Fleet Manager multi-cluster networking concepts | Microsoft Learn

In Kubernetes networking, traffic patterns are often described using the north-south and east-west metaphors. These concepts help clarify where traffic originates, where it’s going, and which networking components handle it.

As platform teams scale from one Kubernetes cluster to many, networking quickly becomes a key area to address - moving from an **intra**-cluster to an **inter**-cluster scope. Workloads across clusters require highly available north–south entry points, resilient east-west failover with consistent secured east–west service discovery between clusters.

## Seamless service‑to‑service across clusters (east–west)

Azure Kubernetes Fleet Manager delivers capabilities that extend the Kubernetes datapath across clusters, meaning endpoints can talk directly with full network‑policy enforcement and the option to configure global services.

Multiple cross-cluster networks can be defined in Fleet Manager, providing administrators with the flexibility to control which member clusters can publish and access global services integrated with standard Kubernetes Services and CoreDNS.

For more information, see [configure and use cross-cluster networking](concepts-cross-cluster-networking).

## Resilient public entry point across clusters (north–south)

Fleet Manager exposes a Kubernetes‑driven entry point by configuring Azure Traffic Manager with a weighted routing profile to spread traffic across services exported from member clusters.

Fleet administrators deploy Kubernetes Custom Resource Definitions (CRDs) `TrafficManagerProfile` and `TrafficManagerBackend` on the Fleet Manager hub cluster, then opt in `Services` by creating a `ServiceExport` on appropriate member clusters. Fleet Manager wires the exported Service into Traffic Manager, providing a unique public DNS name that provides access to the exported Services. You can run both L4 and L7 apps behind this DNS since the decision is made at the DNS layer.

For more information, see [overview of DNS load balancing](concepts-dns-load-balancing).

## Distribute traffic across clusters inside a virtual network (north–south)

Using Fleet Manager's Layer 4 (L4) load balancing capability, administrators declare a `MultiClusterService` that instructs each member cluster's Azure Load Balancer to route traffic not only to local endpoints but also to endpoints of the same `Service` in other member clusters.

For more information, see [overview of layer 4 load balancing](concepts-l4-load-balancing).