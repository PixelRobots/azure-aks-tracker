---
layout: Conceptual
title: AI and ML Workloads in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-ml-overview
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
description: Learn about running AI and ML workloads in Azure Kubernetes Service (AKS), including guidance for AKS Automatic and AKS Standard.
ms.topic: overview
ms.custom: aks-ai-ml
ms.date: 2026-06-05T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 88c3d9c0-2473-c926-41a1-95259959db0b
document_version_independent_id: b62ba235-f5a7-c984-3924-e01bec7dcb20
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-ml-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/ai-ml-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-ml-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 7407f45a-3fb6-8b25-4188-86ee56b94afc
---

# AI and ML Workloads in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic ✔️ AKS Standard

This article provides an overview of running artificial intelligence (AI) and machine learning (ML) workloads in Azure Kubernetes Service (AKS).

## AKS cluster modes for AI and ML

AKS supports two cluster modes:

- **AKS Automatic**, which provides more preconfigured platform defaults.
- **AKS Standard**, which provides broader direct operator control.

Many workload-level AI and ML practices apply to both cluster modes. The primary differences are in platform ownership and day-2 operations.

| Area | AKS Automatic | AKS Standard |
| --- | --- | --- |
| Cluster operations | More preconfigured defaults for production readiness | More explicit operator configuration and lifecycle control |
| Node management and scaling | Managed system node pools and node autoprovisioning are preconfigured | Operators explicitly define and manage node pools and scaling strategy |
| Upgrades | Automatic cluster and node OS image upgrades are preconfigured | Operators choose manual or configured upgrade channels |
| Security baseline | Deployment safeguards and baseline Pod Security Standards are preconfigured in enforce mode | Security and policy controls are optional and explicitly configured |
| Monitoring baseline | Managed Prometheus and Container Insights are default when using Azure CLI or Azure portal creation flows | Monitoring components are optional and enabled explicitly |
| Networking baseline | Managed virtual network defaults and managed ingress and egress patterns in supported configurations | Networking model and ingress and egress patterns are selected explicitly |

For detailed feature comparisons, see [AKS Automatic and AKS Standard feature comparison](intro-aks-automatic#aks-automatic-and-standard-feature-comparison).

## Develop and deploy AI and ML applications with AKS

AKS is an effective platform for deploying and managing containerized AI and ML applications that require scalability, portability, and high availability.

Using AKS for AI and ML enables you to:

- Use high-performance infrastructure for training and inference workloads.
- Integrate with open-source frameworks and existing DevOps processes.
- Improve operational reliability with managed Kubernetes capabilities.
- Strengthen security posture with policy and platform controls.
- Optimize cost by aligning compute resources to workload demand.

For platform strategy:

- Choose AKS Automatic when you want faster setup, more preconfigured production defaults, and reduced operational overhead.
- Choose AKS Standard when you need deeper customization of networking, identity, node pool topology, and upgrade behavior.

## Design and deploy AI and ML workloads on Azure

- [Deploy an application that uses OpenAI on Azure Kubernetes Service (AKS)](open-ai-quickstart)
- [Deploy an AI model on Azure Kubernetes Service (AKS) with the AI toolchain operator add-on](ai-toolchain-operator)
- [Run Ray AI workloads with Kueue on Azure Kubernetes Service (AKS)](ray-overview)
- [Build and deploy data and machine learning pipelines with Flyte on Azure Kubernetes Service (AKS)](use-flyte)