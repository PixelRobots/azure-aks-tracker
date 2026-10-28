---
layout: Conceptual
title: Get started with Azure Linux 4.0 on Windows Subsystem for Linux (WSL) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/get-started-windows-subsystem-for-linux
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
description: Learn about resources you can use to quickly learn and start using Azure Linux on Windows Subsystem for Linux (WSL) for development, testing, and troubleshooting.
author: farhakareem
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: get-started
ms.date: 2026-07-25T00:00:00.0000000Z
locale: en-us
document_id: 86d07e22-a6ef-72c3-3939-d7d1c95f30f7
document_version_independent_id: fe5e5baa-2d1d-00f2-3c81-d3127e00d4a4
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/get-started-windows-subsystem-for-linux.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/get-started-windows-subsystem-for-linux
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/get-started-windows-subsystem-for-linux.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 1692c2ad-57c5-c2fe-1f6e-a16b9c0aa494
---

# Get started with Azure Linux 4.0 on Windows Subsystem for Linux (WSL) | Microsoft Learn

This guide helps you install Azure Linux on Windows Subsystem for Linux (WSL) and start using it as a local Linux environment for development, testing, and troubleshooting without needing a virtual machine (VM) or an Azure subscription.

Azure Linux on WSL uses the same command-line tools and behavior as Azure Linux running in Azure, so you can use it for day-to-day work and to reproduce issues locally.

## Prerequisites

- Windows 10 (22H2) or Windows 11.
- WSL 2 installed and enabled. To install or enable, see [How to install Linux on Windows with WSL](/en-us/windows/wsl/install).
- An internet connection.
- Permissions to install WSL distributions.

## Install Azure Linux 4.0 on WSL

1. Open **Windows Terminal** (no admin required).
2. Follow the [GitHub README guide](https://github.com/microsoft/azurelinux/blob/4.0/README.md) to install Azure Linux.
3. Launch Azure Linux:

    ```bash
    wsl -d AzureLinux-4
    ```

On first launch, you're prompted to create a Linux username and password. Use these credentials only inside the Azure Linux environment.

## Verify the installation

After signing in, validate that Azure Linux is installed and running as expected.

```bash
cat /etc/os-release
```

You see output indicating **Azure Linux** and the installed version number.

At this point, Azure Linux is fully installed and ready to use.

## Update packages (recommended)

After installation, update your system packages to ensure you have the latest fixes and security updates.

```bash
sudo dnf update -y
```

## Use Visual Studio Code with Azure Linux (optional)

Note

Visual Studio Code isn't required, but you can use it with WSL for editing, debugging, and terminal workflows.

1. Install [Visual Studio Code](https://code.visualstudio.com/) on Windows.
2. Install the [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) extension.
3. From an Azure Linux terminal, open a folder in VS Code.

    ```bash
    code .
    ```

For more information, see the [Visual Studio Code documentation](https://code.visualstudio.com/Docs).