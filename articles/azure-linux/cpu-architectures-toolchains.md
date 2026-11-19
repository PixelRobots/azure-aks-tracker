---
layout: Conceptual
title: CPU architectures and toolchain compatibility in Azure Linux 4 | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/cpu-architectures-toolchains
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
description: Learn how to identify Azure Linux CPU architectures, inspect compiler toolchains, and validate native applications when moving to Azure Linux 4.
author: poorvinarang
ms.author: poorvinarang
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: concept-article
ms.date: 2026-10-12T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 09b02d27-c97e-fe1e-0de8-5a17b693bf55
document_version_independent_id: 0a899ff1-213f-ee3c-8329-d5c860d55d43
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/cpu-architectures-toolchains.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/cpu-architectures-toolchains
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/cpu-architectures-toolchains.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 39062af8-ab85-9bcc-b6b0-05801cbd6f82
---

# CPU architectures and toolchain compatibility in Azure Linux 4 | Microsoft Learn

Azure Linux 4 provides 64-bit VM images for x64 and ARM64. Use the architecture-specific image and package repositories that match your Azure VM size and workload.

## Supported architectures

| Architecture | Linux architecture value | Azure Marketplace SKU |
| --- | --- | --- |
| x64 or AMD64 | `x86_64` | `4` |
| ARM64 | `aarch64` | `4-arm64` |

Azure Linux 4 doesn't provide 32-bit VM images. Package architecture values can include `x86_64`, `aarch64`, and `noarch`.

Identify the architecture of a running system:

```bash
uname -m
rpm --eval '%{_arch}'
```

List the architecture of an installed package:

```bash
rpm -q --qf '%{NAME} %{ARCH}\n' <PACKAGE_NAME>
```

## Select an Azure VM architecture

Use an Azure VM size that supports the selected image architecture. List the available Azure Linux 4 image SKUs in a region:

```azurecli
az vm image list-skus \
  --location <REGION> \
  --publisher microsoftazurelinux \
  --offer azurelinux-4 \
  --output table
```

Don't copy binaries between x64 and ARM64 systems unless the artifact is architecture independent. Rebuild native applications and RPM packages for each target architecture.

## Inspect the compiler toolchain

Compiler and library package versions can change through Azure Linux servicing and minor releases. Query the system and enabled repositories for the versions you build against:

```bash
gcc --version
clang --version
ld --version
rpm -q gcc clang llvm binutils glibc glibc-devel
dnf info gcc clang llvm binutils glibc glibc-devel
```

Not every compiler package is installed in the base VM image. Install build dependencies from the appropriate package repository before compiling software.

## Validate native software when moving to Azure Linux 4

Azure Linux 4 updates the compiler, C library, linker, RPM tooling, and other build components from Azure Linux 3. Treat a major-version migration as a rebuild and validation event.

1. Rebuild native applications and RPM packages on Azure Linux 4.
2. Resolve compiler warnings and errors instead of assuming Azure Linux 3 build behavior.
3. Run application, performance, and integration tests on every target architecture.
4. Verify dynamically linked dependencies:

    ```bash
    ldd <BINARY_PATH>
    ```
5. Inspect an RPM's architecture and dependencies:

    ```bash
    rpm -qp --qf '%{NAME} %{VERSION}-%{RELEASE} %{ARCH}\n' <RPM_PATH>
    rpm -qpR <RPM_PATH>
    ```
6. Confirm that required packages are available in production repositories before deployment.

## Avoid architecture assumptions

Use the Marketplace image and Azure VM-size requirements as the compatibility boundary. Don't assume a specific x86-64 microarchitecture level, ARM instruction-set revision, or optional CPU extension unless the selected Azure VM size and your own application validation establish that requirement.