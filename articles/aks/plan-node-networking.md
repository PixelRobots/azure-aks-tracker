---
layout: Conceptual
title: Plan Node Networking for Azure Kubernetes Service (AKS) Workloads - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/plan-node-networking
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
description: This article provides an overview of the networking components you need to consider for Azure Kubernetes Service (AKS) nodes.
ms.topic: overview
ms.subservice: aks-networking
ms.date: 2026-09-15T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 0fd740ab-a9d2-0348-1eb4-06c5cacf522f
document_version_independent_id: a96e407c-e90a-5499-8204-29bc2415a502
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/plan-node-networking.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/plan-node-networking
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/plan-node-networking.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ac787872-337a-4f79-0ea5-4f745100cd88
---

# Plan Node Networking for Azure Kubernetes Service (AKS) Workloads - Azure Kubernetes Service | Microsoft Learn

In this article, you learn node networking options for Azure Kubernetes Service (AKS). We first pose a question to help guide your planning, and then provide options, recommendations, and best practices.

## How do you want your cluster to access the internet?

You need to configure networking for AKS nodes (Azure virtual machines (VMs)) to access each other, the API server, and the internet. When selecting a VNet, you can choose between a managed VNet or a bring-your-own (BYO) VNet. There are also different cluster outbound types available depending on your networking needs.

## Node networking options

When setting up node networking, you can choose between **Load Balancer**, **NAT Gateway**, and **User Defined Routing (UDR)** :

| Node networking option | Diagram of networking components | Features & functionality |
| --- | --- | --- |
| Load Balancer | ![Screenshot of a diagram of the networking components of a Load Balancer.](media/plan-networking/load-balancer.png) | • Default configuration.  • Managed entirely by AKS.  • Follows [Azure Standard Load Balancer](/en-us/azure/load-balancer/load-balancer-overview) rules.  • Provides fixed SNAT ports assigned per node upon node creation. |
| NAT Gateway | ![Screenshot of a diagram of the networking components of a NAT Gateway.](media/plan-networking/nat-gateway.png) | • Can select a managed or user-assigned (BYO) option.  • Provides improved SNAT port handling over Load Balancer.  • Requires extra configuration for zone redundancy. |
| User Defined Routing (UDR) | ![Screenshot of a diagram of the networking components of a User Defined Routing (UDR).](media/plan-networking/user-defined-routing.png) | • Used for explicit network control with BYO VNet.  • Managed by you, providing a more customizable experience.  • Must have a default route to an Azure Firewall, vWAN, or third-party network virtual appliance (NVA).  • Typically doesn't support external Load Balancer services directly. |

## Recommendations

Our **general recommendation** is to use a **Load Balancer**. If you have a **high volume of outbound connections**, consider using a **NAT Gateway** for better SNAT port management. If you have any **custom egress needs (Azure Firewall, NVA, etc.)**, you might want to explore **User Defined Routing (UDR)**.

Note

You can share subnets for system and agent node pools between multiple clusters. You must ensure sufficient IP addresses are allocated to avoid issues.