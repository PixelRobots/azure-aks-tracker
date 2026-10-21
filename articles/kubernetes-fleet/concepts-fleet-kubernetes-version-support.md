---
layout: Conceptual
title: Supported Kubernetes versions in Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-fleet-kubernetes-version-support
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
description: Learn the Kubernetes version support policy and lifecycle of clusters in Azure Kubernetes Fleet Manager.
ms.date: 2025-09-02T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
ai-usage: ai-assisted
locale: en-us
document_id: 1ee6d06c-0a6e-f3bc-119c-8fc8756cdfe2
document_version_independent_id: b5ab33a9-1e1e-ad74-9cba-379c152faca2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-fleet-kubernetes-version-support.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-fleet-kubernetes-version-support
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-fleet-kubernetes-version-support.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 4a9af317-aaba-cfab-0407-69ba2a02f968
---

# Supported Kubernetes versions in Azure Kubernetes Fleet Manager | Microsoft Learn

**Applies to:** ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

This article describes the Kubernetes version support policy for member clusters in Azure Kubernetes Fleet Manager, along with how Kubernetes versions affect access to some Fleet Manager features.

## Azure Kubernetes Service (AKS) member clusters

Azure Kubernetes Fleet Manager follows the [Kubernetes version support policy](../aks/supported-kubernetes-versions) for Azure Kubernetes Service (AKS).

To ensure you can take advantage of the latest Fleet Manager, AKS, and Kubernetes features, we recommend upgrading your clusters to a supported AKS Kubernetes version, including [AKS long term support (LTS)](../aks/supported-kubernetes-versions#long-term-support-lts).

## Azure Arc-enabled Kubernetes member clusters

Azure Arc-enabled Kubernetes clusters are subject to the [version support policy](/en-us/azure/azure-arc/kubernetes/agent-upgrade#version-support-policy) of Azure Arc's Kubernetes agent.

## Fleet Manager feature support

Some Fleet Manager features require a minimum Kubernetes version in order to function. Those features indicate the minimum version on their documentation page.

Member clusters running supported AKS and Arc-enabled Kubernetes versions, but that don't meet the minimum Kubernetes version required for a Fleet Manager feature, don't have access to that feature.