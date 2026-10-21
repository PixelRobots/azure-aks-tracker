---
layout: Conceptual
title: Compare Azure Linux and Ubuntu for AKS on bare metal | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-compare-azure-linux-ubuntu
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Compare infrastructure, host preparation, lifecycle ownership, and cluster management for Azure Linux and Ubuntu on AKS on bare metal.
ms.topic: concept-article
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: rishimody
ms.author: rmody
ms.custom: bare-metal
locale: en-us
document_id: c628d47d-c75b-a578-09c1-9a210ea67331
document_version_independent_id: 9edb5ada-83af-04ee-d935-f9cc1aab67fd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-compare-azure-linux-ubuntu.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-compare-azure-linux-ubuntu
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-compare-azure-linux-ubuntu.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 19175359-c9ef-a844-0252-fb7106903dc3
---

# Compare Azure Linux and Ubuntu for AKS on bare metal | Microsoft Learn

Azure Kubernetes Service (AKS) on bare metal supports Azure Linux and Ubuntu hosts. Choose the host operating system that matches your infrastructure and management model.

| Area | Azure Linux | Ubuntu |
| --- | --- | --- |
| **Infrastructure** | Validated and supported Azure Local small form factor hardware. | Customer-provided hardware that meets the published requirements. |
| **Typical scenario** | New infrastructure. | Existing infrastructure. |
| **Host preparation** | Azure Local provisioning workflow. | You install and prepare Ubuntu, then connect the host to Azure Arc. |
| **Cluster creation** | Azure portal, Azure Resource Manager template, or Bicep. | Azure CLI. |
| **Host OS lifecycle** | Azure Local platform lifecycle. | Customer-managed. |
| **Kubernetes lifecycle** | AKS-managed. | AKS-managed. |
| **Portal experience** | Cluster creation, status, and patch-version upgrades. | Read-only cluster status. Use Azure CLI for lifecycle operations. |

Both options deploy Kubernetes directly on the host operating system without a hypervisor. Both use Azure Arc to connect the host and Kubernetes cluster to Azure.

## Choose Azure Linux

Choose Azure Linux when you want to deploy new, validated Azure Local small form factor hardware. Start with the [Azure Linux system requirements](aks-bare-metal-system-requirements), then select a cluster creation method:

- [Azure portal](aks-bare-metal-create-cluster-portal).
- [Azure Resource Manager template](aks-bare-metal-create-cluster-arm-template).
- [Bicep](aks-bare-metal-create-cluster-bicep).

## Choose Ubuntu

Choose Ubuntu when you want to use customer-provided hardware and maintain the host operating system yourself. Start with [System requirements and prepare your Ubuntu host](aks-bare-metal-ubuntu-system-requirements), then [create a cluster with Azure CLI](aks-bare-metal-create-cluster-ubuntu-cli).