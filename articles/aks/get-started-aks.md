---
layout: Conceptual
title: Get Started With Azure Kubernetes Service (AKS) Basics - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/get-started-aks
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
description: Learn the basics of Azure Kubernetes Service (AKS) and start with AKS Automatic as the recommended production-ready default for most workloads.
author: schaffererin
ms.author: schaffererin
ms.custom: aks-getting-started
ms.topic: get-started
ms.date: 2026-06-05T00:00:00.0000000Z
locale: en-us
document_id: 1a6fae9b-7d15-b2a6-2b48-471627fd8dab
document_version_independent_id: 83a31d6c-229d-5daf-8d5a-dff456fd61e3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/get-started-aks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/get-started-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/get-started-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: fe378fcb-22f0-cc5c-1f75-676420ac9d54
---

# Get Started With Azure Kubernetes Service (AKS) Basics - Azure Kubernetes Service | Microsoft Learn

This guide provides resources to help you learn the basics of [Azure Kubernetes Service (AKS)](what-is-aks).

For most production workloads, start with [**AKS Automatic**](intro-aks-automatic). AKS Automatic is the recommended production-ready default in AKS and provides preconfigured best-practice defaults for scaling, security, networking, monitoring, and upgrades.

Use AKS Standard when you need deeper control over platform configuration and lifecycle operations.

## AKS cluster modes

AKS supports two cluster modes:

- **AKS Automatic (recommended default)**: Best for most production workloads and faster time to value with preconfigured production-ready defaults.
- **AKS Standard**: Best when you require advanced customization for networking, identity, node topology, or upgrade behavior.

For detailed differences, see [AKS Automatic and AKS Standard feature comparison](intro-aks-automatic#aks-automatic-and-standard-feature-comparison).

Note

AKS Automatic is the recommended starting point for most production-ready AKS workloads. If your requirements demand deeper infrastructure customization, AKS Standard remains fully supported.

## Learn the basics of AKS

The resources in the following sections provide an introduction to AKS fundamentals and common platform areas.

### AKS fundamentals

- [What is AKS?](what-is-aks)
- [What is AKS Automatic?](intro-aks-automatic)
- [Core concepts](core-aks-concepts)
- [Deploy clusters with AKS Automatic lab](https://azure-samples.github.io/aks-labs/docs/getting-started/aks-automatic/)
- [Kubernetes and AKS fundamentals lab](https://azure-samples.github.io/aks-labs/docs/getting-started/k8s-aks-fundamentals/)
- Create an AKS cluster
    - [Create a Linux-based AKS Automatic cluster](automatic/quick-automatic-from-code)
    - [Create a Linux-based AKS cluster](learn/quick-kubernetes-deploy-cli)
    - [Create a Windows-based AKS cluster](learn/quick-windows-container-deploy-cli)

### Networking

- [AKS networking overview](concepts-network)
- [AKS networking best practices video](https://www.youtube.com/watch?v=mAGqnX2WW1M)
- [Istio service mesh on AKS lab](https://azure-samples.github.io/aks-labs/docs/networking/istio-lab/)

### Access and identity

- [Access and identity concepts](concepts-identity)
- [Workload identity lab](https://azure-samples.github.io/aks-labs/docs/security/workload-identity-lab/)

### Storage

- [Storage concepts](concepts-storage)
- [Advanced storage concepts lab](https://azure-samples.github.io/aks-labs/docs/storage/advanced-storage-concepts/)