---
layout: Conceptual
title: Overview of Azure Linux package repositories | Microsoft Learn
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
description: Learn how to discover Azure Linux packages, understand the Azure Linux 4 repository structure, and distinguish production packages from preview and unsupported build dependencies.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-10-30T00:00:00.0000000Z
ai-usage: ai-assisted
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

# Overview of Azure Linux package repositories | Microsoft Learn

Azure Linux packages are published through [packages.microsoft.com](https://packages.microsoft.com/) (PMC), Microsoft's centralized service for hosting and distributing Linux packages. PMC provides authoritative repositories of signed RPM packages that Microsoft teams use to publish validated packages and deliver them to Azure, on-premises, and customer environments through standard Linux package managers such as DNF.

This article describes how to discover Azure Linux packages on PMC, how the Azure Linux 4 repositories are organized, and how repository purpose and release stage affect package support.

## Discover available packages

The supported and authoritative way to discover packages that are available for Azure Linux is to query repository metadata with a standard package manager such as `dnf`. For example:

```bash
dnf search <KEYWORD>
dnf list --available
```

- **`dnf search <KEYWORD>`**: Searches package names and summaries across every enabled repository for the given keyword. Use this when you know roughly what you want (for example, `dnf search nginx`) and need to find the matching package name.
- **`dnf list --available`**: Lists every package that's available in the enabled repositories but isn't currently installed. Pipe it through `grep` or `less` to scan large result sets, for example `dnf list --available | grep -i kernel`.

These commands query all enabled repositories. The `preview` channel is disabled by default.

PMC also provides a browsable directory listing for convenience. The HTML directory listing isn't a supported API. Use repository metadata rather than the directory listing for automation.

## Repository structure

Azure Linux 4 repositories on PMC are organized by major release, stage, repository name, and architecture:

1. **Azure Linux major release**: `azurelinux/4`. Azure Linux 4.0 and later 4.x image versions share this repository namespace.
2. **Release stage**: `prod` or `preview`.
3. **Repository name**: For example, `base`, `builddeps`, or `microsoft`.
4. **Target architecture**: `x86_64` or `aarch64`.

For example, the production repository for Azure Linux distribution packages on x86-64 systems is:

```text
https://packages.microsoft.com/azurelinux/4/prod/base/x86_64/
```

Azure Linux 4 uses `4`, not `4.0`, in production and preview repository paths. Use the major-version namespace rather than a separate repository path for each 4.x image version.

### Release stages

The release stage identifies the package channel, not a blanket support guarantee:

- **`prod`**: The production package channel. Use this channel for production packages, subject to the repository's purpose and the software's support terms.
- **`preview`**: A public channel for testing and validating packages. Enable this channel in nonproduction environments to evaluate packages before potential promotion to `prod`.

Publishing a repository under `prod` doesn't make unsupported packages supported. In particular, the `builddeps` repository remains unsupported.

### Repository layout

The repository names identify the following purposes. Architecture, source-package, and debug-symbol availability vary by repository.

| Repository name | Purpose | Support guidance |
| --- | --- | --- |
| `base` | Official Azure Linux distribution packages. | Use `prod/base` for production distribution packages. Azure Linux support applies to supported Azure scenarios; see [Azure Linux official support options](support-options). |
| `builddeps` | Azure Linux-specific dependencies required to build Azure Linux itself. | Unsupported. These packages aren't provided as a general-purpose SDK or as supported production application packages. |
| `microsoft` | Supplementary Microsoft-authored software, including open-source and proprietary packages. | Consult the software's support documentation. Publication in this repository doesn't establish Azure Linux distribution support for every package. |
| `cloud-native` | Cloud Native Computing Foundation (CNCF) and cloud-native packages. | Consult the software's support documentation rather than assuming that PMC hosting establishes support. |

This layout applies to Azure Linux 4. Repository names for earlier Azure Linux releases differ.

### Source packages and debug symbols

Source packages and debug symbols use separate paths where they're available:

| Content | Path pattern |
| --- | --- |
| Binary packages | `/azurelinux/4/<STAGE>/<REPOSITORY>/<ARCH>/` |
| Debug symbol packages | `/azurelinux/4/<STAGE>/<REPOSITORY>/debuginfo/<ARCH>/` |
| Source packages | `/azurelinux/4/<STAGE>/<REPOSITORY>/srpms/` |

Replace `<STAGE>` with `prod` or `preview`, `<REPOSITORY>` with the repository name, and `<ARCH>` with the target architecture. Not every repository provides every architecture or content type. Don't assume that proprietary software provides source code.

Source packages for components in the production `base` repository are published to `/azurelinux/4/prod/base/srpms/`. Source packages for components exclusive to `builddeps` use the corresponding `builddeps/srpms/` path.

Symbols for packages in `base` are published to `base/debuginfo/<ARCH>/`. Symbols for packages exclusive to `builddeps` are published to `builddeps/debuginfo/<ARCH>/`. If a source package produces subpackages in both repositories, its debug symbol package is published in the `base` debug symbol repository.

Match debug symbols to the installed binary package version, release stage, and architecture.

Note

The `builddeps` repository contains packages that satisfy Azure Linux-specific build requirements. These packages are needed to build Azure Linux itself; the repository isn't a general-purpose SDK for application development. These packages aren't officially supported. This support limitation also applies to the corresponding `builddeps` debug symbol packages. Their presence in the `prod` channel doesn't change their support status.