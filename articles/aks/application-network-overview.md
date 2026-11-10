---
layout: Conceptual
title: Azure Kubernetes Application Network for AKS (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/application-network-overview
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
description: Explore managed, sidecar-free service networking for AKS and find the Azure Kubernetes Application Network documentation.
author: jack4it
ms.author: mjac
ms.subservice: aks-networking
ms.topic: overview
ms.date: 2026-11-09T00:00:00.0000000Z
ai-usage: ai-generated
locale: en-us
document_id: e2f8e889-7ba7-1e17-4ba8-2e38c4d9cd86
document_version_independent_id: 71a4f2ff-3de5-a698-bcdb-40229b9bd051
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/application-network-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/application-network-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/application-network-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 896d2fc4-77a4-6c72-176f-8483308b61cf
---

# Azure Kubernetes Application Network for AKS (Preview) - Azure Kubernetes Service | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Azure Kubernetes Application Network (Application Network) provides a fully managed, ambient service mesh for Azure Kubernetes Service (AKS). Use it to secure service-to-service communication within a cluster or across multiple member clusters without adding sidecars to your applications. Azure manages the control plane and data plane.

In an ambient mesh, workloads participate without sidecar proxies. A member cluster is an AKS cluster that you join to an Application Network. Enrolling a workload adds it to the mesh.

For the complete product documentation, see [Azure Kubernetes Application Network](../application-network/).

## When to use Application Network

Consider Application Network when you need:

- Mutual TLS (mTLS) and managed workload certificates for enrolled services.
- Optional layer 7 proxies for routing and service-level authorization.
- Service discovery and communication across participating AKS member clusters.

## Compare with the Istio add-on

Choose based on how you want to run the service mesh:

| Attribute | Application Network (preview) | [Istio add-on](istio-about) |
| --- | --- | --- |
| Mesh model | Ambient, without application sidecars | Sidecar-based |
| Control plane location | Hosted outside your AKS clusters | Runs in your AKS cluster |
| Ambient mode | Supported | Not supported |
| Multi-cluster support | Supported across member clusters | Not supported |
| Choose it when | You want to avoid application sidecars or connect services across member clusters. | You want an in-cluster Istio deployment. |

A cluster with the Istio add-on enabled can't join Application Network. To switch, plan for disruption: [uninstalling the add-on](istio-uninstall-addon) removes its control plane, custom resources, and gateway configurations. Then follow the [Application Network onboarding guide](../application-network/get-started) and enroll your workloads. This isn't an in-place migration.

## How it fits with AKS

Create an Application Network resource, join your AKS clusters as members, and enroll the workloads that should participate. Joining a cluster doesn't automatically enroll every workload or export every service.

The following diagram shows the management plane, the managed control plane outside your AKS clusters, and the data plane within member clusters:

[![Diagram showing the Application Network management and control planes, and the ambient data plane with workloads in AKS member clusters.](../application-network/media/architecture/application-network-architecture.svg)](../application-network/media/architecture/application-network-architecture.svg#lightbox)

The diagram shows three layers:

- **Management plane**: Creates Application Network resources and manages cluster membership.
- **Control plane**: Distributes mesh configuration and manages workload certificates.
- **Data plane**: Node-level proxies secure enrolled workload traffic; optional waypoints apply layer 7 policies.

Application Network doesn't upgrade your AKS cluster, Kubernetes version, or node images, and it doesn't create the underlying connectivity between clusters. For details, see the [Application Network architecture](../application-network/architecture).