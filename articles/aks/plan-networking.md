---
layout: Conceptual
title: Plan Networking for Azure Kubernetes Service (AKS) Workloads - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/plan-networking
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
description: This article provides an overview of the networking components you need to consider when planning your Azure Kubernetes Service (AKS) workloads.
ms.topic: overview
ms.subservice: aks-networking
ms.date: 2026-09-15T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 46622a47-568d-074a-b5d6-c93de4011a00
document_version_independent_id: 8c334c93-89e0-0949-6246-ae876e3b0a6e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/plan-networking.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/plan-networking
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/plan-networking.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 66a2746b-0771-5f97-79f0-11943a584bbb
---

# Plan Networking for Azure Kubernetes Service (AKS) Workloads - Azure Kubernetes Service | Microsoft Learn

This article provides an overview of the networking components you need to consider when planning your Azure Kubernetes Service (AKS) workloads.

## Networking components

When planning your AKS networking, you need to consider four main components: the **control plane**, **nodes**, **pods**, and **applications**.

Each component has its own networking requirements, considerations, and options. You can use the following articles to learn more about and plan for each component:

- [Plan control plane networking for Azure Kubernetes Service (AKS)](plan-control-plane-networking)
- [Plan node networking for Azure Kubernetes Service (AKS)](plan-node-networking)
- [Plan pod networking for Azure Kubernetes Service (AKS)](plan-pod-networking)
- [Plan application networking for Azure Kubernetes Service (AKS)](plan-application-networking)

Each article poses a question to help guide your planning, and then provides options, recommendations, and best practices.

Note

You can share subnets for API server, system node pool, and agent node pool resources between multiple clusters. Ensure you allocate sufficient IP addresses to avoid issues.