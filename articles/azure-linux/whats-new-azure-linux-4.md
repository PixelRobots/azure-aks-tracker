---
layout: Conceptual
title: What's New in Azure Linux 4.0? | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/whats-new-azure-linux-4
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
description: Learn about the new features and updates in Azure Linux 4.0, including the updated kernel, package manager, and core libraries.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: whats-new
ms.date: 2026-04-26T00:00:00.0000000Z
locale: en-us
document_id: b7c29cfb-8cfe-3410-5b75-3936a20c2427
document_version_independent_id: 1c0d621c-d078-b687-7b9b-3300007a96a5
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/whats-new-azure-linux-4.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/whats-new-azure-linux-4
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/whats-new-azure-linux-4.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: bc5f10fb-27ab-3a33-b68b-716f079944be
---

# What's New in Azure Linux 4.0? | Microsoft Learn

Azure Linux 4.0 is the next major release of Microsoft's Linux distribution for Azure. It brings a newer kernel (6.18 LTS), a new package manager (dnf5), and updated core libraries across the stack. For a deeper look at how the operating system (OS) is structured, see the [Architecture overview](architecture).

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Key components

The following table lists the core component versions included in Azure Linux 4.0:

| Component | Version | Highlights |
| --- | --- | --- |
| **Kernel** | 6.18 LTS | New hardware drivers, improved Hyper-V integration, GPU/AI accelerator support |
| **glibc** | 2.42 | Performance improvements in string operations, memory allocation, and thread handling |
| **OpenSSL** | 3.5.4 | Modern cryptographic algorithms, deprecated older cipher suites removed |
| **systemd** | 258.4 | Fast boot sequences, improved service management and logging |
| **Python 3** | 3.14.3 | JIT compiler, new syntax features, updated standard library |
| **bash** | 5.3.9 | Scripting improvements and bug fixes |
| **binutils** | 2.45.1 | Modern toolchain |
| **coreutils** | 9.7 | Security fixes and utility improvements |
| **curl** | 8.15.0 | Protocol updates and security patches |
| **util-linux** | 2.41.3 | Updated system utilities |
| **rpm** | 6.0.1 | Modernized database backend, improved signature verification |
| **Package manager** | dnf5 | Faster dependency resolution, lower memory usage |
| **FIPS 140-3** | In progress | Certification pending; use a certified release for FIPS-required workloads |

## Package manager: dnf5

Azure Linux 4.0 uses **dnf5** as its package manager. dnf5 is a complete rewrite that delivers faster dependency resolution and lower memory usage compared to older package managers.

If you have scripts, Dockerfiles, or CI pipelines that reference `tdnf` (the package manager used in earlier Azure Linux releases), update those references to `dnf5` or `dnf` before deploying on Azure Linux 4.0.