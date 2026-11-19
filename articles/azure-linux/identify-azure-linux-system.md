---
layout: Conceptual
title: Identify an Azure Linux system and version | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/identify-azure-linux-system
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
description: Learn how to identify Azure Linux 4, its architecture, kernel, installed packages, and Azure Marketplace VM image versions.
author: poorvinarang
ms.author: poorvinarang
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: concept-article
ms.date: 2026-10-12T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 52b10cb5-510c-fbdb-ccd4-dd509aeaa340
document_version_independent_id: 00a40cbc-a629-0edc-5138-1dcae44c659a
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/identify-azure-linux-system.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/identify-azure-linux-system
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/identify-azure-linux-system.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 0da33d01-0e6c-9e84-f2dc-d7173ff8d6b6
---

# Identify an Azure Linux system and version | Microsoft Learn

Use standard Linux and Azure tools to identify the operating system, architecture, kernel, installed RPM packages, and available Azure Marketplace VM images.

## Product name

**Azure Linux 4** is the product name for the general-purpose, package-managed Linux distribution. Don't use Mariner 4.0 or CBL-Mariner 4.0 as product names.

## Identify the operating system

Read `/etc/os-release` to identify the distribution and major version:

```bash
cat /etc/os-release
```

Use the fields instead of parsing the human-readable text. An Azure Linux 4 system reports:

```text
NAME="Azure Linux"
ID=azurelinux
VERSION_ID="4.0"
```

Build-specific fields can change as the system is updated. Don't use `/etc/mariner-release` as the Azure Linux 4 identity source.

## Identify the architecture

Run:

```bash
uname -m
```

Azure Linux 4 VM images are available for the following 64-bit architectures:

| `uname -m`value | Architecture name |
| --- | --- |
| `x86_64` | x64 or AMD64 |
| `aarch64` | ARM64 |

## Identify the kernel

Display the running kernel release:

```bash
uname -r
```

Display the installed kernel RPM packages:

```bash
rpm -q kernel
dnf info --installed kernel
```

Kernel release and RPM version strings change through servicing. Use the complete value when you report an issue instead of relying on only the upstream kernel version.

## Identify package versions and repositories

Display an installed package's name, epoch, version, release, architecture, and source repository:

```bash
rpm -q --qf '%{NAME}-%{EPOCHNUM}:%{VERSION}-%{RELEASE}.%{ARCH}\n' <PACKAGE_NAME>
dnf info --installed <PACKAGE_NAME>
dnf repoquery --installed --info <PACKAGE_NAME>
```

Azure Linux RPM release strings commonly include an `azl4` distribution suffix. Treat the full RPM identifier as the package version.

## Identify Azure Marketplace VM images

Azure Linux 4 VM images use these Marketplace identifiers:

| Architecture | Publisher | Offer | SKU | URN using the latest version |
| --- | --- | --- | --- | --- |
| x64, Gen2 | `microsoftazurelinux` | `azurelinux-4` | `4` | `microsoftazurelinux:azurelinux-4:4:latest` |
| ARM64, Gen2 | `microsoftazurelinux` | `azurelinux-4` | `4-arm64` | `microsoftazurelinux:azurelinux-4:4-arm64:latest` |

List the versions available in a region:

```azurecli
az vm image list \
  --location <REGION> \
  --publisher microsoftazurelinux \
  --offer azurelinux-4 \
  --sku 4 \
  --all \
  --output table
```

For ARM64, replace `--sku 4` with `--sku 4-arm64`.

Use `latest` when you want Azure to resolve the current image at deployment time. Use a version returned by `az vm image list` when you need to select an explicit Marketplace image version.

## Collect identification details for support

When you report an issue, include:

- Relevant fields from `/etc/os-release`.
- Output from `uname -m` and `uname -r`.
- The full RPM identifier for affected packages.
- The Marketplace image URN or version used to create the VM, if available.
- Whether the system is an unmodified Marketplace image or a custom image.

If Microsoft Support requests a diagnostic archive, follow [Collect diagnostic information](support-options#collect-diagnostic-information) to generate and provide an sos report.