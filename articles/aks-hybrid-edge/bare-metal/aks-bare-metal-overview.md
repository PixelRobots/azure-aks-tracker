---
layout: Conceptual
title: What is Azure Kubernetes Service on bare metal? (preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-overview
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
description: Learn how Azure Kubernetes Service on bare metal runs Kubernetes directly on Azure Linux or Ubuntu hosts without a hypervisor.
ms.topic: overview
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: SummerSmith
ms.author: sumsmith
ms.custom: bare-metal
locale: en-us
document_id: 2728dc02-6e93-b33f-acb2-78b8c95b29e2
document_version_independent_id: a9dc6af9-7ddd-cd14-9044-757ce22aed54
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f6934729-9309-5498-f877-3cab62d36869
---

# What is Azure Kubernetes Service on bare metal? (preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Azure Kubernetes Service (AKS) on bare metal deploys Kubernetes directly on a supported host operating system without a hypervisor. The Kubernetes control plane and worker components run on the host hardware, and Azure Arc connects the cluster and host to Azure for management.

## Key benefits

- **No hypervisor overhead**: Run Kubernetes directly on the host operating system and hardware.
- **Azure-connected management**: Use Azure Arc and the AKS resource provider to manage the Kubernetes lifecycle from Azure.
- **Consistent Kubernetes experience**: Use standard Kubernetes APIs and tools to manage workloads.
- **Flexible infrastructure choices**: Deploy on validated Azure Local hardware with Azure Linux or on customer-provided hardware with Ubuntu.

## Choose a host operating system

AKS on bare metal currently supports two host operating systems:

- **Azure Linux** runs on validated and supported Azure Local small form factor hardware. Use this option for a new-infrastructure deployment managed through the Azure Local platform lifecycle. Create clusters by using the Azure portal, an Azure Resource Manager template, or Bicep.
- **Ubuntu** runs on customer-provided hardware that meets the published requirements. Use this option to add AKS to existing infrastructure without reimaging the host. You install, configure, patch, and maintain Ubuntu, while AKS manages the Kubernetes layer. Create and manage clusters by using the Azure CLI extension.

The supported interfaces for cluster creation, upgrade, and deletion differ by host operating system. Follow the procedure for your host option.

For a detailed comparison, see [Compare Azure Linux and Ubuntu](aks-bare-metal-compare-azure-linux-ubuntu).

## When to use AKS on bare metal

Use AKS on bare metal when you need to:

- Run workloads without hypervisor overhead.
- Deploy Kubernetes at retail stores, factories, field sites, or other edge locations.
- Keep workloads and data on-premises while managing the Kubernetes layer through Azure.
- Deploy AKS to an existing Ubuntu host or deploy new validated Azure Local hardware.

## How it works

AKS on bare metal has three layers:

- **Azure management and Azure Arc** connect the host and Kubernetes cluster to Azure.
- **The AKS-managed Kubernetes layer** provides the control plane and worker components.
- **The host operating system and hardware layer** provides compute, storage, and networking.

AKS manages the Kubernetes layer for both host options. Host ownership differs: Azure Linux follows the Azure Local platform lifecycle, while you maintain the Ubuntu host operating system and hardware.

## Public preview scope

During public preview, capabilities and limitations can differ between Azure Linux and Ubuntu. See [AKS on bare metal preview limitations](aks-bare-metal-preview-limitations) before you deploy.