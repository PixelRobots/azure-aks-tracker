---
layout: Conceptual
title: Azure Linux Container Host for Azure Kubernetes Service (AKS) Core Concepts | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/aks-core-concepts
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
description: Learn about the core concepts of the Azure Linux Container Host when used with Azure Kubernetes Service (AKS), including CVE infrastructure, feature additions, upgrades, and testing.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: concept-article
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 7a6a3cf8-45ba-39d8-ea04-1c3df3f3725b
document_version_independent_id: 3798ec2c-fb44-6046-70d2-635fc6f4a58e
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/aks-core-concepts.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/aks-core-concepts
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/aks-core-concepts.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 0e419b64-1951-b991-e78a-9ca818abda81
---

# Azure Linux Container Host for Azure Kubernetes Service (AKS) Core Concepts | Microsoft Learn

Microsoft Azure Linux is an open-source project maintained by Microsoft, which means that Microsoft is responsible for the entire Azure Linux Container Host stack, from the Linux kernel to the Common Vulnerabilities and Exposures (CVE) infrastructure, support, and end-to-end validation.

This article explains the core concepts of the Azure Linux Container Host for AKS, including how Microsoft manages CVEs, implements feature requests, performs upgrades, and validates images through testing.

## CVE infrastructure

The Azure Linux team scans packages shipped with the Azure Linux Container Host twice daily against the [National Vulnerability Database (NVD)](https://nvd.nist.gov/) and collaborates with the [Microsoft Security Response Center (MSRC)](https://www.microsoft.com/msrc) to evaluate, patch, and publish fixes. High and critical CVEs might be released out-of-band as a package update ahead of the next node image; medium and low CVEs are rolled into the next image release.

For the full CVE pipeline, published advisories, SLAs, and delivery models across all Azure Linux and Azure Container Linux deployment options, see [Manage CVEs on Azure Linux and Azure Container Linux](manage-cves).

## Feature additions and upgrades

Given that Microsoft owns the entire Azure Linux Container Host stack, including the CVE infrastructure and other support streams, the process of submitting a feature request is streamlined. You can communicate directly with the Microsoft team that owns the Azure Linux Container Host, which ensures an accelerated process for submitting and implementing feature requests. If you have a feature request, please file an issue on the [AKS GitHub repository](https://github.com/Azure/AKS/issues).

## Testing

Before an Azure Linux node image is released for testing, it undergoes a series of Azure Linux and AKS specific tests to ensure that the image meets AKS requirements. This approach to quality testing helps catch and mitigate issues before they're deployed to your production nodes. Part of these tests are performance related, testing CPU, network, storage, memory, and cluster metrics such as cluster creation and upgrade times. This ensures that the performance of the Azure Linux Container Host doesn't regress as we upgrade the image.

We run Azure Linux node images and packages published to [packages.microsoft.com](https://packages.microsoft.com/azurelinux/) through a suite of tests that simulate an Azure environment, including Build Verification Tests (BVTs) that validate [AKS extensions and add-ons](/en-us/azure/aks/integrations) are supported on each release of the Azure Linux Container Host. We also test patches against the current Azure Linux node image before their release to ensure there are no regressions.