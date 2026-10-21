---
layout: Conceptual
title: Multi-cluster layer-4 load balancing (preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-l4-load-balancing
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
description: This article describes the concept of multi-cluster layer-4 load balancing.
ms.date: 2026-05-14T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: 959b5e7a-6bae-0fd9-83d8-c421f8529026
document_version_independent_id: 6578a44b-a034-6a67-e737-12e46a6b2887
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-l4-load-balancing.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-l4-load-balancing
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-l4-load-balancing.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 56cd36dc-e5b2-3650-50b3-a5d18e0523ee
---

# Multi-cluster layer-4 load balancing (preview) | Microsoft Learn

**Applies to**: ✔️ Fleet Manager with hub cluster

Azure Kubernetes Fleet Manager can be used to set up layer 4 multi-cluster load balancing across workloads deployed across member clusters.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

[![Diagram showing how multi-cluster layer 4 load balancing works.](media/conceptual-load-balancing.png)](media/conceptual-load-balancing.png#lightbox)

For multi-cluster load balancing, Fleet Manager requires target clusters to be using [Azure CNI networking](/en-us/azure/aks/configure-azure-cni). Azure CNI networking enables pod IPs to be directly addressable on the Azure virtual network so that they can be routed to from the Azure Load Balancer.

The `ServiceExport` itself can be distributed from the Fleet Manager hub cluster to one or more member clusters using the Fleet Manager's [resource placement feature](concepts-resource-placement), or it can be created directly on the member cluster. Once the `ServiceExport` is created, it results in a `ServiceImport` being created on the Fleet Manager hub cluster, and all other member clusters to build the awareness of the service.

The user can then create a `MultiClusterService` custom resource to indicate that they want to set up layer 4 multi-cluster load balancing. This `MultiClusterService` configures the Azure Load Balancer in each member cluster to distribute incoming layer 4 traffic across the service’s endpoints in multiple member clusters.