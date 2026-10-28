---
layout: Conceptual
title: Developer Guide for Azure Linux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/get-started-developer
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
description: This guide covers common developer tasks on Azure Linux, including building and packaging software, customizing images, and managing certificates for development and testing purposes.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: get-started
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 87de1984-c89f-8635-2968-40bf2c26c3f5
document_version_independent_id: 85b30e8e-4e4f-8c75-bba4-26dab1e06044
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/get-started-developer.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/get-started-developer
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/get-started-developer.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/a3955c7b-f5ee-420d-aff5-d7119738f38b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/b31948f4-2f38-404b-ac93-c3c8c5b3ae33
platformId: cba50617-5aa6-209d-8027-b4d24e698cff
---

# Developer Guide for Azure Linux | Microsoft Learn

This article covers common developer tasks on Azure Linux, from building and packaging software to customizing images for your environment.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Developer tasks

| Task | Description |
| --- | --- |
| [Build RPM packages](build-rpm-packages) | Package proprietary software, apply patches, or bundle internal tools using `mock` or `azldev`. |
| [Customize images](customize-images) | Modify Azure Linux base images like adding packages, configuring settings and applying partition layouts, without booting a virtual machine (VM). |
| [Manage certificates](certificate-management) | Add custom certificates to regular and distroless container images. |