---
layout: Conceptual
title: AKS on Azure Local with disconnected operations | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/disconnected-operations/overview
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
description: Learn about Azure Kubernetes Service (AKS) enabled by Azure Arc for Azure Local with disconnected operations, including supported scenarios, prerequisites, and limitations.
ms.topic: overview
author: rishimody
ms.author: rmody
ms.date: 2026-10-06T00:00:00.0000000Z
ms.custom: disconnected-operations
ai-usage: ai-assisted
locale: en-us
document_id: fe9c11dd-6ef1-c73d-b8a1-4db9e5a4f5e0
document_version_independent_id: 7f11be7c-b422-eaf2-a93f-fb44632475b6
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/disconnected-operations/overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/disconnected-operations/overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/disconnected-operations/overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 87584d90-c4f3-1795-886f-e716ea43f66e
---

# AKS on Azure Local with disconnected operations | Microsoft Learn

[Disconnected operations](/en-us/azure/azure-local/manage/disconnected-operations-overview) is an Azure Local capability that you use to deploy and manage Azure Local instances without a connection to the Azure public cloud. Use select Azure Arc-enabled services from a local control plane. Azure Kubernetes Service (AKS) enabled by Azure Arc is one of the services supported for disconnected operations. You get the same familiar Azure portal, Azure CLI, and Azure Resource Manager experience for creating and managing Kubernetes clusters, entirely from the local control plane.

Note

Disconnected operations is a distinct Azure Local deployment mode with its own local control plane and hardware requirements. It's not the same as the [connectivity modes](../hyperconverged/connectivity-modes) that describe how a standard, cloud-connected AKS on Azure Local cluster behaves during a temporary loss of connectivity to Azure.

## Why use disconnected operations for AKS

Use disconnected operations for AKS on Azure Local for scenarios such as:

- **Sovereign requirements and compliance**: Sectors like government, healthcare, and finance often have data residency and sovereignty requirements that are hard to meet by using public sovereign cloud controls. Running disconnected keeps data, operations, and control within your organization's boundaries.
- **Remote or isolated locations**: Sites with limited or no network infrastructure, such as oil rigs or manufacturing floors, can still get an Azure portal and Azure CLI experience for managing Kubernetes clusters without relying on internet connectivity.
- **Security**: Industries with strict security requirements can reduce their attack surface by not exposing systems to external networks.

## How it works

AKS for disconnected operations closely mirrors AKS capabilities on Azure Local: you use the same Azure CLI extensions and largely the same commands to create logical networks, create and manage Kubernetes clusters, and retrieve `kubeconfig` files. The key difference is that the local control plane serves all these operations instead of the Azure public cloud. You maintain a consistent management and operational experience even without internet connectivity.

## Prerequisites

- [Azure Command-Line Interface (CLI)](/en-us/azure/azure-local/manage/disconnected-operations-cli) installed on your local machine.
- An Azure subscription associated with disconnected operations.
- Understanding of AKS and Azure Arc concepts.
- Complete [Identity for Azure Local with disconnected operations](/en-us/azure/azure-local/manage/disconnected-operations-identity).
- Complete [Networking for Azure Local with disconnected operations](/en-us/azure/azure-local/manage/disconnected-operations-network).
- Complete [Public key infrastructure (PKI) for Azure Local with disconnected operations](/en-us/azure/azure-local/manage/disconnected-operations-pki).
- Complete [Hardware for Azure Local with disconnected operations](/en-us/azure/azure-local/manage/disconnected-operations-overview#eligibility-criteria).
- Complete [Set up for Azure Local with disconnected operations](/en-us/azure/azure-local/manage/disconnected-operations-set-up).

## Limitations

Limitations for disconnected operations with AKS include:

- Support for disconnected operations begins with the 2408 release.
- Supported Kubernetes versions: 1.33.4 and 1.33.5.
- Microsoft Entra ID (formerly Azure Active Directory) isn't supported for disconnected operations.
- Arc Gateway isn't supported for configuring outbound URLs.
- Create logical networks by using the CLI only. The portal isn't supported.
- Create SSH keys by using the CLI only. The portal isn't supported.