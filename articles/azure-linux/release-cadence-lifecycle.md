---
layout: Conceptual
title: Azure Linux release cadence and maintenance | Microsoft Learn
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
description: Learn how Azure Linux 4 uses semiannual minor releases, monthly security updates, and package maintenance policies.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-10-30T00:00:00.0000000Z
ai-usage: ai-assisted
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

# Azure Linux release cadence and maintenance | Microsoft Learn

Azure Linux follows a predictable release model for planned package changes while continuing to deliver security and high-impact reliability fixes between releases. This article explains when changes occur and how package maintenance policies affect update behavior.

## Azure Linux lifecycle principles

The following table summarizes the four guiding principles that shape how Azure Linux releases, supports, and retires kernels and major packages:

| Principle | What it means for you |
| --- | --- |
| **Security first** | You receive security fixes monthly. Critical and High CVEs are fast-tracked, so you don't wait for the next monthly window to be protected. |
| **Predictability** | You see published start dates and end-of-support dates for every kernel and major package, so you can plan upgrades on your schedule instead of reacting to surprises. |
| **Controlled change** | When a new kernel or major component releases, you keep support for the previous version through an overlap window. You have time to validate and migrate before the older version is retired. |
| **Cloud-native lifecycle** | You get a distribution designed for environments that update continuously, not one pinned to a single kernel for long periods of time. |

## Major and minor releases

Azure Linux 4 is a major release. Semiannual minor releases, such as 4.1 and 4.2, introduce new features and package version upgrades. Azure Linux always aims to preserve application programming interface (API) and application binary interface (ABI) compatibility across these minor releases.

These releases provide regular points for you to review, validate, and adopt changes. Each package's maintenance policy guides its updates.

## Servicing between minor releases

Azure Linux ships security fixes monthly. Between minor releases, servicing also focuses on high-impact reliability fixes and patch-level package updates where the package's maintenance policy permits them.

Azure Linux might make a servicing exception between minor releases to address a security or high-impact reliability issue. Such changes aim to minimize disruption and preserve compatibility.

## Package maintenance policies

Each package follows a maintenance policy that balances compatibility and software freshness. Some packages receive backported fixes without version upgrades, while others track newer upstream releases.

Upgrade behavior depends on the package. A newer version might require explicit adoption, become the default while an older version remains available, or coexist with an older version before becoming the default.

## Plan for updates

Before you adopt a minor release:

1. Review the [Azure Linux release notes](https://github.com/microsoft/azurelinux/releases) and package changelogs.
2. Test your workload and its package dependencies in a nonproduction environment.
3. Rebuild and validate custom VM images.
4. Roll out the update by using your normal deployment and rollback process.

For package-level changes, use `dnf changelog <PACKAGE_NAME>` and `dnf info <PACKAGE_NAME>`.