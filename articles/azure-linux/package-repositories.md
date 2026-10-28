---
layout: Conceptual
title: Overview of Azure Linux Package Repositories | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/package-repositories
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
description: Overview of how Azure Linux packages are published and organized in Microsoft's package repositories, including guidance on discovering available packages and understanding repository structure.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 8df34175-9196-9a9b-82fc-2fb1def06ebb
document_version_independent_id: 948ecacd-8575-39df-ee8e-4e34b6b83ef0
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/package-repositories.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/package-repositories
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/package-repositories.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: a9ffa19e-c4ce-4734-f408-bbc3546872d2
---

# Overview of Azure Linux Package Repositories | Microsoft Learn

Azure Linux packages are published through [packages.microsoft.com](https://packages.microsoft.com/) (PMC), Microsoft's centralized service for hosting and distributing Linux packages. PMC provides authoritative, signed RPM repositories that Microsoft teams use to publish validated packages and deliver them to Azure, on-premises, and customer environments through standard Linux package managers such as DNF.

This article describes how to discover Azure Linux packages on PMC, how the Azure Linux repositories are organized, and what each repository contains.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Discover available packages

The supported and authoritative way to discover packages that are available for Azure Linux is to query repository metadata with a standard package manager such as `dnf`. For example:

```bash
dnf search <KEYWORD>
dnf list --available
```

- **`dnf search <KEYWORD>`**: Searches package names and summaries across every enabled repository for the given keyword. Use this when you know roughly what you want (for example, `dnf search nginx`) and need to find the matching package name.
- **`dnf list --available`**: Lists every package that's available in the enabled repositories but isn't currently installed. Pipe it through `grep` or `less` to scan large result sets, for example `dnf list --available | grep -i kernel`.

## Repository structure

For each major Azure Linux release, the repositories on PMC are organized indicate release, stage, name, and architecture. Within each release, repositories are nested in the following order:

1. **Azure Linux release version**: For example, `azurelinux/4.0`.
2. **Release stage**: For example, `beta`.
3. **Repository name**: For example, `base` or `microsoft`.`.
4. **Target architecture**: `x86_64` or `aarch64`.

### Repository layout

The repositories are structured as follows:

| Repository name | Purpose |
| --- | --- |
| `base` | Official Azure Linux distribution packages. |
| `microsoft` | Supplementary software that's published by Microsoft. |

Tip

Any component included in the `base` repository has its source package in a `/azurelinux/4.0/beta/base/srpms` repository.

Note

Additional packages are published to `/azurelinux/4.0/beta/sdk` and `azurelinux/4.0/beta/sdk/srpms`. These packages are only provided to satisfy development requirements and aren't officially supported.