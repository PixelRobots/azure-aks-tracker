---
layout: Conceptual
title: Azure Linux Container Host Support Lifecycle for Azure Kubernetes Service (AKS) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/aks-support-cycle
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
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
manager: kumud
description: Learn about the support lifecycle for the Azure Linux Container Host when used with Azure Kubernetes Service (AKS), including minor and major image releases, and the mapping of Azure Linux versions to supported AKS versions.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: overview
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 36130c15-b0c7-78a4-6ede-b5e9151dc6fb
document_version_independent_id: bd8cea87-969f-0756-ce9e-6815b786d0a9
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/aks-support-cycle.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/aks-support-cycle
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/aks-support-cycle.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 4f8b26c3-73e4-971b-7fb2-6006842a37f6
---

# Azure Linux Container Host Support Lifecycle for Azure Kubernetes Service (AKS) | Microsoft Learn

This article describes the support lifecycle for the Azure Linux Container Host for Azure Kubernetes Service (AKS).

Important

Microsoft is committed to meeting this support lifecycle and reserves the right to make changes to the support agreement and new scenarios that require modifications at any time with proper notice to customers and partners.

## Image releases

### Minor releases

At the beginning of each month, Azure Linux releases a minor image version containing medium, high, and critical package updates from the previous month. This release also includes minor kernel updates and bug fixes.

For more information on the Common Vulnerabilities and Exposures (CVE) service level agreement (SLA), see [CVE infrastructure](manage-cves).

### Major releases

For information on Azure Linux major release cadence and lifecycle, see [Azure Linux release cadence and lifecycle](release-cadence-lifecycle).

The following table outlines the first and last AKS release supported by each Azure Linux version:

| Azure Linux version | First supported preview AKS version | First supported GA AKS version | Last supported AKS version |
| --- | --- | --- | --- |
| Azure Linux 2.0 | 1.24 | 1.26 | 1.31 |
| Azure Linux 3.0 | 1.31 | 1.32 | Roughly three years after 1.32 release |

### AKS Long-Term Support (LTS) releases

| AKS version | Azure Linux version during AKS Standard support | Azure Linux version during AKS LTS |
| --- | --- | --- |
| 1.27 | Azure Linux 2.0 | Azure Linux 2.0 |
| 1.28 - 1.31 | Azure Linux 2.0 | Azure Linux 2.0 (migrate to 3.0 by Nov 2025) |
| 1.32+ | Azure Linux 3.0 | Azure Linux 3.0 |