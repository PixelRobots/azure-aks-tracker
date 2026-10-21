---
layout: Conceptual
title: AKS Regulated Cluster for PCI DSS 4.0.1 - Targeted Risk Analysis - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/pci-targeted-risk-analysis
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
description: Targeted risk analysis guidance for AKS clusters under PCI DSS 4.0.1.
ms.date: 2025-06-25T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: concept-article
author: schaffererin
ms.author: schaffererin
ms.custom:
- pci-dss
- compliance
locale: en-us
document_id: 1e925a71-abb8-f178-dd22-5eb03a6aee8b
document_version_independent_id: e8bb66e0-3b99-e24f-5e6b-30fa6bc098f3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/pci-targeted-risk-analysis.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/pci-targeted-risk-analysis
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/pci-targeted-risk-analysis.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: bdd9957b-2096-e716-df96-efc958ded5ab
---

# AKS Regulated Cluster for PCI DSS 4.0.1 - Targeted Risk Analysis - Azure Kubernetes Service | Microsoft Learn

PCI DSS 4.0.1 introduces targeted risk analysis for certain requirements. This document outlines how to perform and document risk analysis for AKS workloads.

## AKS feature support

AKS provides several features to help you meet PCI DSS 4.0.1 targeted risk analysis requirements:

- **Azure Policy**: Supports risk-based policy enforcement and can help automate risk analysis for AKS resources.
- **Microsoft Defender for Cloud**: Provides risk assessment, security recommendations, and compliance tracking for AKS clusters.
- **Azure Monitor**: Enables tracking of risk indicators and audit events for ongoing risk analysis.

## Your responsibilities

- Identify which PCI DSS requirements in your AKS environment allow for targeted risk analysis (e.g., key rotation, access reviews).
- Document the risk analysis process, findings, and mitigation steps for each applicable requirement.
- Use Azure Policy and Defender for Cloud to automate risk identification and mitigation where possible.
- Regularly review and update risk analysis documentation as the AKS environment and threat landscape evolve.

## Key steps

- Identify requirements that allow for targeted risk analysis.
- Document the risk analysis process, findings, and mitigation steps.
- Review and update risk analysis regularly.

## Example template

| Requirement | Risk Identified | Mitigation | Review Date |
| --- | --- | --- | --- |
| Key rotation frequency | Key compromise | Automated rotation | 2025-06-01 |

## Integrated AKS security context

You should implement targeted risk analysis as part of a broader security strategy that includes:

- [Security policies](pci-policy) for policy and governance.
- [Identity and access management](pci-identity) for identity and access management.
- [Monitoring and logging](pci-monitor) for monitoring and alerting.

For the latest AKS security features, see the [Azure Kubernetes Service (AKS) documentation](/en-us/azure/aks/).