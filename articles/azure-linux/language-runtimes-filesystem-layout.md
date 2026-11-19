---
layout: Conceptual
title: Language runtimes and filesystem layout in Azure Linux 4 | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/language-runtimes-filesystem-layout
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
description: Learn how to discover available language runtimes, inspect installed versions, and validate filesystem paths when moving applications to Azure Linux 4.
author: poorvinarang
ms.author: poorvinarang
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: concept-article
ms.date: 2026-10-12T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 28f09cad-9623-d5cc-fc2d-fc7f0bd2aa0a
document_version_independent_id: 468f4f7d-6a84-a2ce-e91f-ac46a8858a47
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/language-runtimes-filesystem-layout.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/language-runtimes-filesystem-layout
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/language-runtimes-filesystem-layout.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c6f99e62-1cf6-4b71-af9b-649b05f80cce
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/3f56b378-07a9-4fa1-afe8-9889fdc77628
platformId: 64903dc0-db25-48e8-b52b-7f8d6b504ecb
---

# Language runtimes and filesystem layout in Azure Linux 4 | Microsoft Learn

Azure Linux delivers language runtimes and development tools as RPM packages. Query the production repositories for current package names and versions instead of relying on a fixed runtime list.

## Discover language runtimes

Search the repositories enabled on your system:

```bash
dnf search python
dnf search dotnet
dnf search openjdk
dnf search nodejs
dnf search golang
dnf search rust
```

For instructions to inspect package details and dependencies and install the runtime you select, see [Manage packages with DNF](manage-packages).

A package being searchable or installable doesn't by itself define a long-term runtime support commitment. Review the package's repository, maintenance policy, changelog, and release notes when you choose a runtime version.

## Verify installed runtime versions

Use both the runtime command and RPM metadata when you collect version information. Replace `<RUNTIME_COMMAND>` with the command that starts your runtime, and `<PACKAGE_NAME>` with its package name. For Python, for example, use `python3` for both:

```bash
<RUNTIME_COMMAND> --version
rpm -q <PACKAGE_NAME>
dnf info --installed <PACKAGE_NAME>
```

RPM metadata identifies the exact Azure Linux package release even when the runtime reports only its upstream version.

## Understand the filesystem layout

Azure Linux uses standard Linux filesystem locations. Common locations include:

| Path | Purpose |
| --- | --- |
| `/etc` | System and application configuration. |
| `/usr/bin` and `/usr/sbin` | Executable programs and administrative commands. |
| `/usr/lib` and `/usr/lib64` | Libraries and package-managed runtime files. |
| `/var` | Variable data, including logs, caches, and service state. |
| `/opt` | Optional application software. |
| `/home` | User home directories. |
| `/run` | Runtime state that doesn't persist across restarts. |

Don't depend on a library, executable, or configuration path only because it existed in Azure Linux 3. Package renames, versioned runtime streams, and updated upstream layouts can change package-owned paths in Azure Linux 4.

## Find package-owned files

List all files installed by a package:

```bash
rpm -ql <PACKAGE_NAME>
```

Identify which package owns a path:

```bash
rpm -qf <PATH>
```

Verify that package-owned files haven't changed:

```bash
sudo rpm -V <PACKAGE_NAME>
```

Query an RPM file before installing it. Replace `<RPM_PATH>` with the path to the `.rpm` file you downloaded.

```bash
rpm -qlp <RPM_PATH>
rpm -qpR <RPM_PATH>
```

Use RPM ownership and metadata as the source of truth for package-managed paths. Avoid manually replacing package-owned files or creating compatibility links unless the application vendor documents that configuration.

## Identify the operating system and mounted filesystems

Identify the distribution and version, and then inspect how the system mounts its filesystems.

### Identify the operating system

Use `/etc/os-release` to identify Azure Linux:

```bash
cat /etc/os-release
```

The output includes the distribution identity and version. For example:

```output
...
ID=azurelinux
ID_LIKE=fedora
VERSION_ID=4.0
...
```

### Inspect mounted filesystems

Use standard storage commands to inspect mounted filesystems and paths:

```bash
findmnt
findmnt /
lsblk --fs
df -T
cat /proc/self/mounts
```

The filesystem type and mount layout can differ between Marketplace images, custom images, and attached data disks. Inspect the running system instead of assuming a fixed device name or mount layout.

## Validate an application migration

When you move an application from Azure Linux 3 to Azure Linux 4:

1. Resolve runtime packages from Azure Linux 4 production repositories.
2. Rebuild native dependencies and language extensions on Azure Linux 4.
3. Replace hard-coded paths with package discovery or configuration where possible.
4. Use `rpm -qf` and `rpm -ql` to confirm package ownership and installed locations.
5. Test configuration, service startup, logging, data paths, and upgrades in a nonproduction environment.
6. Record the exact RPM versions used in the validated deployment.