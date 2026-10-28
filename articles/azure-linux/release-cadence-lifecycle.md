---
layout: Conceptual
title: Azure Linux Release Cadence and Lifecycle | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/release-cadence-lifecycle
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
description: Learn about the guiding principles behind Azure Linux release cadence, lifecycle, and update strategy.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-26T00:00:00.0000000Z
locale: en-us
document_id: e51674cb-460c-82ca-cc34-1d419ab7f1e8
document_version_independent_id: a918010b-755c-f1fd-46b8-9e920cf92f78
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/release-cadence-lifecycle.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/release-cadence-lifecycle
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/release-cadence-lifecycle.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: bc0010d3-5d80-e166-69b6-c30574ae6472
---

# Azure Linux Release Cadence and Lifecycle | Microsoft Learn

Azure Linux follows a lifecycle model designed to balance stability, security, and access to modern Linux capabilities. This page describes the guiding principles that shape how Azure Linux releases, supports, and retires kernels and packages.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Azure Linux lifecycle principles

The following table summarizes the four guiding principles that shape how Azure Linux releases, supports, and retires kernels and major packages:

| Principle | What it means for you |
| --- | --- |
| **Predictability** | You see published start dates and end-of-support dates for every kernel and major package, so you can plan upgrades on your schedule instead of reacting to surprises. |
| **Security first** | You receive upstream security fixes on defined SLAs. Critical and High CVEs are fast-tracked, so you don't wait for the next monthly window to be protected. |
| **Controlled change** | When a new kernel or major component releases, you keep support for the previous version through an overlap window. You have time to validate and migrate before the older version is retired. |
| **Cloud-native lifecycle** | You get an operating system (OS) designed for environments that update continuously, not one pinned to a single kernel for long periods of time. |

## What to expect

Azure Linux applies these principles across three areas:

- **Kernel lifecycle**: Azure Linux tracks upstream Linux Long-Term Support (LTS) kernels for production stability and introduces Hardware Enablement (HWE) kernels annually to support new hardware platforms, GPU drivers, and AI/ML accelerators. Azure Linux 4.0 ships with **kernel 6.18 LTS**.
- **Package updates**: Core OS components (kernel, glibc, OpenSSL, systemd) prioritize stability and receive security backports without disruptive version changes. Language runtimes and higher-level packages follow a structured refresh cadence with planned update windows.
- **Security servicing**: Azure Linux ships monthly security updates that backport CVE fixes to every supported package. Critical and High severity vulnerabilities are fast-tracked outside the regular monthly cycle. For details on the CVE pipeline, see [Manage CVEs](manage-cves).

Note

Specific support durations and update policies will be published ahead of General Availability (GA).