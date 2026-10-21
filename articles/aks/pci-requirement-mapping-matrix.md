---
layout: Conceptual
title: AKS Regulated Cluster for PCI DSS 4.0.1 - Requirement Mapping Matrix - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/pci-requirement-mapping-matrix
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
description: Requirement mapping matrix guidance for AKS clusters.
ms.date: 2025-06-25T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: concept-article
author: schaffererin
ms.author: schaffererin
ms.custom:
- pci-dss
- compliance
locale: en-us
document_id: 95ab98ff-a13a-37f9-f398-93979222fb57
document_version_independent_id: 2845fb31-3868-4a66-4719-84df42d1fbfd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/pci-requirement-mapping-matrix.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/pci-requirement-mapping-matrix
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/pci-requirement-mapping-matrix.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ac6b0e68-c91a-16f9-f2f5-2c3e1e658018
---

# AKS Regulated Cluster for PCI DSS 4.0.1 - Requirement Mapping Matrix - Azure Kubernetes Service | Microsoft Learn

This document provides a mapping of AKS controls and documentation to PCI DSS 4.0.1 requirements, including customized approaches where applicable.

## AKS PCI DSS 4.0.1 requirement mapping matrix

| PCI DSS 4.0.1 requirement | AKS control | Customized approach |
| --- | --- | --- |
| MFA for admin access | [Enhanced MFA implementation](pci-enhanced-mfa-implementation) | Yes (if using Azure AD Conditional Access) |
| Continuous monitoring | [Continuous security and monitoring](pci-continuous-security-monitoring) | No |
| Key management | [Cryptography and key management](pci-cryptography-key-management) | No |
| Third-party management | [Third-party and supply chain security](pci-third-party-supply-chain-security) | No |
| Security awareness | [Security awareness and training](pci-security-awareness-training) | No |

## Integrated AKS security context

You should leverage the requirement mapping matrix as part of a broader security strategy that includes:

- [Security policies](pci-policy) for policy and governance.
- [Identity and access management](pci-identity) for identity and access management.
- [Monitoring and logging](pci-monitor) for monitoring and alerting.