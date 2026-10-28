---
layout: Conceptual
title: Overview of Azure Linux on Windows Subsystem for Linux (WSL) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/windows-subsystem-for-linux-overview
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
description: Learn about Azure Linux on Windows Subsystem for Linux (WSL), including its key capabilities, developer scenarios and installation options.
author: farhakareem
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-07-25T00:00:00.0000000Z
locale: en-us
document_id: cde66dfd-8d37-8fc6-03a4-e9677a2cbbe1
document_version_independent_id: f2fcf016-7418-53de-ad0d-eea5fb51c6fb
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/windows-subsystem-for-linux-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/windows-subsystem-for-linux-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/windows-subsystem-for-linux-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 1540d2a1-560e-d8ee-d7ba-57c38e213b44
---

# Overview of Azure Linux on Windows Subsystem for Linux (WSL) | Microsoft Learn

Azure Linux on WSL is a complete Azure Linux terminal environment with systemd support. It helps teams run Linux command-line tools, perform infrastructure management, and carry out Linux development alongside Windows desktop applications.

To install WSL for Azure Linux, see [Get started with Azure Linux 4.0 on Windows Subsystem for Linux (WSL)](get-started-windows-subsystem-for-linux).

> 
> **You can also download WSL for Azure Linux directly using the following links**:
> 
> - [X86_64](https://aka.ms/wslazlinux-x86_64)
> - [ARM 64](https://aka.ms/wslazlinux-aarch64)
> 

## Supported architectures

- x86\_64
- arm64

## Release cadence

The Azure Linux team releases updates **as needed** when issues reported by WSL users impact productivity.

## Developing in WSL

The [Visual Studio Code WSL extension](https://code.visualstudio.com/docs/remote/wsl) allows you to use WSL as a full-time development environment directly from VS Code, while running tools and terminals inside Azure Linux.

To learn more about using Visual Studio Code with Azure Linux on WSL, see [Get started with Azure Linux 4.0 on Windows Subsystem for Linux (WSL)](get-started-windows-subsystem-for-linux).

### WSL development resources

- [Developing directly inside WSL for best file system performance](https://code.visualstudio.com/docs/remote/wsl)
- [Sharing Git credentials between Windows and WSL](https://code.visualstudio.com/docs/remote/troubleshooting#_sharing-git-credentials-between-windows-and-wsl)