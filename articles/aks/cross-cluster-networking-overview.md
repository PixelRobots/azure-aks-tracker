---
layout: Conceptual
title: Choose Cross-Cluster Networking for AKS - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/cross-cluster-networking-overview
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
description: Compare Cilium Cluster Mesh and Azure Kubernetes Application Network for cross-cluster connectivity, service discovery, and traffic policies.
author: jack4it
ms.author: mjac
ms.subservice: aks-networking
ms.topic: concept-article
ms.date: 2026-11-08T00:00:00.0000000Z
ai-usage: ai-generated
locale: en-us
document_id: 70df78ce-4cb1-dfa5-10db-808d5bf897a9
document_version_independent_id: af7c6c3c-2f85-66d6-0163-0756b3937296
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/cross-cluster-networking-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/cross-cluster-networking-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/cross-cluster-networking-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 0db06ec1-a6e6-f0a8-408e-a3ba595a2397
---

# Choose Cross-Cluster Networking for AKS - Azure Kubernetes Service | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

When services communicate across AKS clusters, plan both the network path between workloads and the service identity and traffic policies you need. Cilium Cluster Mesh and Azure Kubernetes Application Network provide different ways to address these needs.

## Compare the options

Use this comparison to find the documentation that matches your requirements.

| Option | Main focus | Configuration requirements |
| --- | --- | --- |
| [Cilium Cluster Mesh (preview)](cross-cluster-networking-fleet-use-cases) | Direct pod IP routing, shared service discovery, and network policies across clusters, managed through Azure Kubernetes Fleet Manager. | Azure CNI with Cilium, Advanced Container Networking Services (ACNS), and direct cross-cluster pod IP reachability. |
| [Azure Kubernetes Application Network (preview)](application-network-multi-cluster) | Managed workload identity, mutual TLS (mTLS), and optional layer 7 routing and authorization through a sidecar-free service network. | Workload enrollment, participating services, and reachability through direct pod IP paths or east-west gateways. |

## Choose by workload needs

Both options support direct cross-cluster pod connectivity. Choose based on the networking and service-mesh capabilities your workloads need:

- **Cilium-based networking across clusters**: Review [Cilium Cluster Mesh](cross-cluster-networking-fleet-use-cases) for shared service discovery and cross-cluster network policies.
- **A managed, sidecar-free service mesh across clusters**: Review [Application Network](application-network-multi-cluster) for workload identity, mTLS, and optional layer 7 traffic policies, with direct pod connectivity or east-west gateways.

You can't currently use Cilium Cluster Mesh and Application Network together on the same AKS cluster.

## Check connectivity requirements

Application Network doesn't create the underlying connectivity between clusters. For clusters that use Azure CNI Overlay, VNet peering alone doesn't provide direct cross-cluster pod IP reachability. See [Application Network topology requirements](../application-network/multi-cluster-connectivity#choose-a-topology).