---
layout: Conceptual
title: AKS Regulated Cluster for PCI DSS 4.0.1 - Anti-phishing and Social Engineering - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/pci-anti-phishing-social-engineering
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
description: Anti-phishing and social engineering guidance for AKS clusters under PCI DSS 4.0.1.
ms.date: 2025-06-25T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: concept-article
author: schaffererin
ms.author: schaffererin
ms.custom:
- pci-dss
- compliance
locale: en-us
document_id: 4b6d16ee-f227-7ebb-48ad-b53167085f37
document_version_independent_id: a7101830-2c09-4c9f-adbd-915e8a4bad5c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/pci-anti-phishing-social-engineering.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/pci-anti-phishing-social-engineering
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/pci-anti-phishing-social-engineering.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: bb68a2bd-126c-4d8b-33f2-83c616dd1675
---

# AKS Regulated Cluster for PCI DSS 4.0.1 - Anti-phishing and Social Engineering - Azure Kubernetes Service | Microsoft Learn

PCI DSS 4.0.1 expands requirements for anti-phishing and social engineering protections. This document provides guidance for implementing these controls for AKS admin and developer access.

## AKS feature support

AKS provides several features to help you meet PCI DSS 4.0.1 anti-phishing and social engineering requirements:

- **Microsoft Defender for Cloud**: Provides threat protection, including anti-phishing and social engineering detection, for AKS clusters and integrated Azure resources.
- **Microsoft Entra ID (Azure AD) Conditional Access**: Supports risk-based access policies and can help mitigate phishing attempts by enforcing strong authentication and session controls.
- **Azure Policy**: Enforce security awareness and anti-phishing training requirements for AKS users.
- **Integration with Microsoft 365 Defender**: For organizations using Microsoft 365, anti-phishing and social engineering protections can be extended to email and collaboration tools used by AKS administrators and developers.

## Your responsibilities

- Ensure all AKS administrators and users complete regular security awareness and anti-phishing training.
- Configure and enforce Conditional Access policies to require MFA and block risky sign-ins.
- Integrate AKS with Microsoft Defender for Cloud and ensure threat detection is enabled for all clusters.
- Document and test incident response procedures for suspected phishing or social engineering attempts targeting AKS resources.
- Regularly review and update anti-phishing controls as new threats emerge.

## Key practices

- Enforce security awareness training for all AKS users.
- Implement anti-phishing protections in email and collaboration tools.
- Use just-in-time access and approval workflows for privileged actions.
- Document incident response for suspected phishing or social engineering attempts.

## Integrated AKS security context

You should implement anti-phishing and social engineering efforts as part of a broader security strategy that includes:

- [Security awareness training](pci-security-awareness-training) for user training.
- [Identity](pci-identity) for identity and access management.
- [Monitoring](pci-monitor) for monitoring and alerting.

For the latest AKS security features, see the [Azure Kubernetes Service (AKS) documentation](/en-us/azure/aks/).