---
layout: Conceptual
title: Manage Storage and Filesystems on Azure Linux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/storage-file-system-management
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
description: Learn how to manage storage and filesystems on Azure Linux, including identifying the root filesystem, discovering available filesystem packages, using filesystem management utilities, and forcing a filesystem check on boot.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: how-to
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 9dfa0c2c-4620-5d6f-9d19-127e6e425919
document_version_independent_id: 44627792-e258-be5d-871e-e64a092fba2c
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/storage-file-system-management.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/storage-file-system-management
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/storage-file-system-management.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: a7edc650-05e0-7fff-bcac-83bfb2219098
---

# Manage Storage and Filesystems on Azure Linux | Microsoft Learn

Azure Linux virtual machines (VMs) are commonly deployed with [ext4](https://www.kernel.org/doc/html/latest/filesystems/ext4/index.html) as the root filesystem. Other filesystems, such as `xfs` and `btrfs`, are available for extra disks or non-root volumes when your workload requires them.

This article shows you how to identify the filesystem on your Azure Linux system, discover the filesystem packages that are available for installation, use the standard utilities for managing ext4 and other filesystems, and force a filesystem check on the next boot.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Prerequisites

- An Azure Linux system that you can authenticate to with shell access.
- A user account with `sudo` privileges, which is required to create or repair filesystems, modify partitions, and force a filesystem check on boot.

## Identify the root filesystem

Identify the filesystem type that's currently in use for the root volume (`/`) using the following command:

```bash
df -T /
```

The following example shows typical output on an Azure Linux VM that uses ext4 for the root filesystem:

Filesystem Type 1K-blocks Used Available Use% Mounted on /dev/sda2 ext4 30681648 1870824 27231892 7% /

The `Type` column shows the filesystem type, and the `Mounted on` column confirms that the filesystem is mounted at `/`.

## Discover available filesystem packages

Azure Linux ships with `ext4` support out of the box. To discover other filesystem-related packages that are available for installation, such as `xfsprogs` and `btrfs-progs`, use the following command:

```bash
dnf search filesystem | grep -Ei "fs|ext4|xfs|btrfs"
```

The output lists packages whose name or summary mentions a filesystem, which provides a starting point for choosing the right filesystem and tooling for additional disks.

## Filesystem management utilities

Azure Linux includes the standard Linux filesystem utilities for creating, inspecting, repairing, and tuning filesystems.

### ext4 utilities (`e2fsprogs`)

The `e2fsprogs` package provides the standard suite of utilities for managing `ext4` filesystems. Key commands include:

- `mkfs.ext4`: Creates a new ext4 filesystem on a disk or partition.
- `fsck.ext4`: Checks and repairs the integrity of an ext4 filesystem.
- `tune2fs`: Adjusts ext4 parameters such as reserved-block percentage and journaling options.

### General disk and filesystem utilities

The following utilities work with any filesystem and are useful for managing disks, partitions, and mounts:

- `parted`: Partition management tool that supports GPT and MBR layouts, including creating and resizing partitions.
- `gdisk`: Interactive GPT partition table editor.
- `lsblk`: Lists block devices and their relationships in a tree view.
- `blkid`: Displays the filesystem type and UUID for each block device.
- `df`: Shows disk space usage for mounted filesystems.
- `du`: Shows disk space usage for files and directories.
- `mount`: Mounts a filesystem at a specified mount point.
- `umount`: Unmounts a previously mounted filesystem.
- `fsck`: Generic filesystem check wrapper that calls the appropriate filesystem-specific checker, such as `fsck.ext4`.

## Force a filesystem check on the next boot

If you need to recover from suspected corruption or verify the integrity of the root filesystem, you can ask the system to run `fsck` on `/` the next time it boots before the root filesystem is mounted.

Force a filesystem check at the next boot using the following commands:

```bash
sudo touch /forcefsck
sudo reboot
```

When the system boots, it detects the `/forcefsck` flag file, runs `fsck` against the root filesystem, and then removes the flag file automatically. This is useful for recovering from suspected corruption or for verifying filesystem integrity after an unexpected shutdown.

Warning

A forced `fsck` can take a significant amount of time on large filesystems, during which the VM is unavailable. Schedule this operation during a maintenance window.