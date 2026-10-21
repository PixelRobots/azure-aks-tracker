---
layout: Conceptual
title: AKS Regulated Cluster for PCI DSS 4.0.1 - Customized Approach Guidance - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/pci-customized-approach-guidance
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
description: Customized approach guidance for AKS clusters under PCI DSS 4.0.1.
ms.date: 2025-06-25T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: concept-article
author: schaffererin
ms.author: schaffererin
ms.custom:
- pci-dss
- compliance
locale: en-us
document_id: f1b7822c-d688-5c52-9396-855ef4412826
document_version_independent_id: b708a5c5-1914-734b-75bd-af28bae7f423
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/pci-customized-approach-guidance.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/pci-customized-approach-guidance
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/pci-customized-approach-guidance.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 17ee49f5-f70f-2e42-46f0-e70f86b0d218
---

# AKS Regulated Cluster for PCI DSS 4.0.1 - Customized Approach Guidance - Azure Kubernetes Service | Microsoft Learn

PCI DSS 4.0.1 introduces the "customized approach" for meeting requirements, allowing organizations to implement alternative controls if they meet the intent and rigor of the standard. This document provides guidance for documenting, justifying, and validating customized controls in Azure Kubernetes Service (AKS) environments.

## When to use the customized approach

The customized approach is appropriate when:

- When standard controls aren't feasible due to technical or business constraints.
- When leveraging cloud-native or container-specific security features that differ from traditional controls.

## Documentation requirements

- Clearly describe the alternative control and how it meets the intent of the PCI DSS requirement.
- Provide a risk analysis and justification for the alternative control.
- Include validation and testing procedures.

## Example template

| Requirement | Standard Control | Customized Control | Rationale | Validation/Test |
| --- | --- | --- | --- | --- |
| MFA for admin access | Traditional MFA | Azure AD Conditional Access with FIDO2 | Stronger assurance, cloud-native | Review policy, test login |

## Integrated AKS security context

You should implement the customized approach as part of a broader security strategy that includes:

- [Security policies](pci-policy) for policy and governance.
- [Identity and access management](pci-identity) for identity and access management.
- [Monitoring and logging](pci-monitor) for monitoring and alerting.

For the latest AKS security features, see the [Azure Kubernetes Service (AKS) documentation](/en-us/azure/aks/).