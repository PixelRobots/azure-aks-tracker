---
layout: Conceptual
title: Overview of Package Management on Azure Linux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/package-management-overview
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
description: Overview of how package management works on Azure Linux, including DNF5, RPM packages, and compatibility with YUM-era tooling.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: f430c5aa-c5e3-aeaf-69fd-8e5b9b2af2af
document_version_independent_id: c518d71b-556d-3559-3f4e-b2c4cd04d101
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/package-management-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/package-management-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/package-management-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 6c762787-21ef-6858-1a42-c111eb3f8503
---

# Overview of Package Management on Azure Linux | Microsoft Learn

Azure Linux uses **DNF5** as its package manager and ships software as **RPM packages**. This article covers the specifics of how Azure Linux is packaged, what's new in DNF5, and where to look when paths or tools still carry YUM-era names.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## DNF5

DNF5 is the latest major release of [DNF](https://github.com/rpm-software-management/dnf5), the package manager maintained by the upstream RPM software management community. Compared to DNF4, DNF5 provides:

- Faster dependency resolution.
- Reduced memory usage.
- An improved internal architecture.
- Full backward compatibility with existing YUM repository configurations.

The command-line surface is intentionally close to `yum` and `dnf` 4, so existing scripts and CI pipelines generally work without changes. The `dnf` and `yum` commands on Azure Linux are provided by DNF5.

## RPM packages

Software on Azure Linux is delivered as RPM packages. Each `.rpm` file bundles:

- Binaries, libraries, scripts, and other payload files.
- Configuration files marked with `%config` so they survive upgrades.
- Metadata: name, version, release, architecture, dependencies, file list, signatures, and changelog.

DNF resolves dependencies, fetches the required `.rpm` files from configured repositories, verifies their signatures, and hands them to the `rpm` library to install or upgrade. You can interact with installed packages directly using `rpm` (for example, `rpm -qa`, `rpm -qf <path>`, `rpm -V <pkg>`), but for installs and upgrades use DNF so that dependency resolution stays correct.

## YUM, DNF, and DNF5

RPM-based distributions have moved through three generations of front-end tooling:

```text
YUM → DNF → DNF5
```

Each generation kept the on-disk repository format compatible, so you still see paths and names like `/etc/yum.repos.d/` and `yum.conf` on current Azure Linux systems. They're aliases into DNF5, not separate tools, and you can use either name in scripts.