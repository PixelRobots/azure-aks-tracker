---
layout: Conceptual
title: AKS Regulated Cluster for PCI DSS 4.0.1 - Third-party and Supply Chain Security - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/pci-third-party-supply-chain-security
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
description: Third-party and supply chain security guidance for AKS clusters for PCI DSS 4.0.1.
ms.date: 2025-06-25T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: concept-article
author: schaffererin
ms.author: schaffererin
ms.custom:
- pci-dss
- compliance
locale: en-us
document_id: 181f8988-bcaf-ea64-ae00-26d1180a8610
document_version_independent_id: b9d5c7cd-70a5-1620-e318-ce1303b00e0a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/pci-third-party-supply-chain-security.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/pci-third-party-supply-chain-security
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/pci-third-party-supply-chain-security.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 7569ab5a-36b3-3399-5088-7fc29839ca54
---

# AKS Regulated Cluster for PCI DSS 4.0.1 - Third-party and Supply Chain Security - Azure Kubernetes Service | Microsoft Learn

PCI DSS 4.0.1 expands requirements for managing third-party service providers and supply chain risk. This document provides guidance for managing dependencies, images, and providers in AKS.

## AKS feature support

AKS provides several features to help you meet PCI DSS 4.0.1 third-party and supply chain security requirements:

- **Microsoft Defender for Cloud**: Monitors third-party images and dependencies for vulnerabilities and compliance in AKS clusters.
- **Azure Policy**: Enforces approved image registries and controls deployment of third-party components.
- **Azure Container Registry (ACR) Tasks**: Supports automated image scanning and approval workflows for container images.
- **Azure Monitor**: Tracks provider activity and compliance status for third-party integrations.

## Your responsibilities

- Maintain an up-to-date inventory of all third-party components, images, and service providers used in AKS workloads.
- Enforce vulnerability scanning and approval for all dependencies and images before deployment.
- Monitor provider compliance and security posture using Defender for Cloud and Azure Monitor.
- Document contracts, SLAs, and security requirements for all third-party providers with access to the CDE.
- Regularly review and update supply chain security controls as new risks and dependencies emerge.

## Key practices

- Maintain an inventory of all third-party components and images.
- Enforce vulnerability scanning and approval for all dependencies.
- Monitor provider compliance and security posture.
- Document contracts and SLAs with third-party providers.

## Integrated AKS security context

You should implement third-party and supply chain security as part of a broader security strategy that includes:

- [Security policies](pci-policy) for policy and governance.
- [Identity and access management](pci-identity) for identity and access management.
- [Monitoring and logging](pci-monitor) for monitoring and alerting.

For the latest AKS security features, see the [Azure Kubernetes Service (AKS) documentation](/en-us/azure/aks/).