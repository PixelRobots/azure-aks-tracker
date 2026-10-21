---
layout: Conceptual
title: Plan Control Plane Networking for Azure Kubernetes Service (AKS) Workloads - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/plan-control-plane-networking
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
description: This article provides an overview of the networking components you need to consider when planning your Azure Kubernetes Service (AKS) control plane workloads.
ms.topic: overview
ms.subservice: aks-networking
ms.date: 2026-09-15T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 94929a93-79b2-b73e-dd38-27d7e1375445
document_version_independent_id: 8f8df3b3-bb6e-5b46-3278-434a5e9185ea
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/plan-control-plane-networking.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/plan-control-plane-networking
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/plan-control-plane-networking.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c7607490-3de5-b517-1e9e-e1e373e0e189
---

# Plan Control Plane Networking for Azure Kubernetes Service (AKS) Workloads - Azure Kubernetes Service | Microsoft Learn

In this article, you learn control plane networking options for Azure Kubernetes Service (AKS). We first pose a question to help guide your planning, and then provide options, recommendations, and best practices.

## How do you want to access your API server?

The Azure-managed AKS control plane consists of several components that help manage the cluster, including the API server. You need to configure networking so that nodes and end users can access the API server for things like updates and cluster management.

## Control plane networking options

When setting up control plane networking, you can choose a **public cluster** or a **private cluster**:

| Control plane networking option | Diagram of networking components | Features & functionality |
| --- | --- | --- |
| Public cluster | ![Screenshot of a diagram of the networking components of a public AKS cluster.](media/plan-networking/public-cluster.png) | • API server accessible via a *public IP address*, allowing users and nodes to connect without any extra configuration.  • You can restrict access to certain source IP ranges.  • Uses konnectivity tunnel for node and pod access.  • Supports API Server VNet Integration. |
| Private cluster | ![Screenshot of a diagram of the networking components of a private AKS cluster](media/plan-networking/private-cluster.png) | • API server accessible via internal IP address, with [Azure Private DNS](/en-us/azure/dns/private-dns-overview) used for API server hostname.  • Uses [Azure Private Link](/en-us/azure/private-link/private-link-overview) to securely connect to the API server.  • Uses konnectivity tunnel for node and pod access.  • Supports API Server VNet Integration. |

### API Server VNet Integration

[API Server VNet Integration](api-server-vnet-integration) is supported for public or private clusters. API Server VNet Integration enables network communication between the API server and the cluster nodes without requiring a private link or tunnel. The API server is available behind an internal load balancer VIP in the delegated subnet, which the nodes are configured to utilize.

With API Server VNet Integration:

- API server provisions into a delegated subnet within your virtual network (VNet).
- Can use a konnectivity tunnel for pod access in [Overlay](concepts-network-azure-cni-overlay) or [BYO CNI](use-byo-cni) clusters.
- Can add or remove API server public access at any time without cluster disruption.

Note

API Server VNet Integration isn't currently available in qatarcentral.

## Recommendations

Our **general recommendation** is to use a **public cluster**, as it simplifies the networking setup and allows for easier access to the API server. However, if you have **specific security or compliance requirements**, a **private cluster** might be more appropriate.

To enhance security and simplify network management, enable API Server VNet Integration for both public and private clusters.

Note

You can share subnets for the API server, system node pool, and agent node pool resources between multiple clusters. You must ensure sufficient IP addresses are allocated to avoid issues.