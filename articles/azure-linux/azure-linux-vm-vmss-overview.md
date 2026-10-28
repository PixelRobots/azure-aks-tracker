---
layout: Conceptual
title: Overview of Deploying Azure Linux on Azure Virtual Machines (VMs) and Virtual Machine Scale Sets | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/azure-linux-vm-vmss-overview
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
description: This article provides an overview of deploying Azure Linux on Azure Virtual Machines (VMs) and Virtual Machine Scale Sets, including supported images and VM sizes.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: e602f22b-0801-7ed9-d450-7b74bacb86ae
document_version_independent_id: a184ebbb-c4fd-cdf1-0ad0-0c4ab5f91d18
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/azure-linux-vm-vmss-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/azure-linux-vm-vmss-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/azure-linux-vm-vmss-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f5f58e8a-3818-bd8c-8374-488640b991fd
---

# Overview of Deploying Azure Linux on Azure Virtual Machines (VMs) and Virtual Machine Scale Sets | Microsoft Learn

This article provides an overview of how to deploy Azure Linux on Azure Virtual Machines (VMs) and Virtual Machine Scale Sets.

## Overview of Azure Linux

Azure Linux is a lightweight, security-hardened Linux distribution with a small on-disk footprint, built and maintained for Azure workloads. You can run the core image as-is or use it as the starting point for a customized build tailored to your workload.

The core image is published to Azure Marketplace with a curated set of base packages. To customize it, add packages from https://packages.microsoft.com and VM extensions from the Azure Marketplace, or use [Image Customizer](customize-images) to automate the process. Once your image is ready, store it in an Azure Compute Gallery and deploy it consistently across your environment. For more information, see [Package management](package-management-overview).

For a single workload, deploy Azure Linux to an individual VM. To scale out automatically based on demand, use virtual machine scale sets instead.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Available images

Azure Linux 4.0 images are published to Azure Marketplace under the `microsoftazurelinux` publisher. Use the URN that matches your architecture and VM generation:

| Architecture | Generation | URN |
| --- | --- | --- |
| x86\_64 | Gen2 | `microsoftazurelinux:azurelinux-4:4:latest` |
| x86\_64 | Gen1 | Not available for Preview |
| ARM64 | Gen2 | `microsoftazurelinux:azurelinux-4:4-arm64:latest` |

You can browse these images in the Azure portal using the guidance in the [Launch an Azure Linux VM](create-vm-azure-linux-4-0) quickstart or query them programmatically using the following Azure CLI commands:

```azurecli
# List all offers from the publisher
az vm image list-offers --publisher microsoftazurelinux --location eastus

# List all SKUs for an offer
az vm image list-skus --publisher microsoftazurelinux --offer azurelinux-4 --location eastus

# List all versions of a SKU
az vm image list --publisher microsoftazurelinux --offer azurelinux-4 --sku 4 --all

# Show details for a specific image version
az vm image show --urn microsoftazurelinux:azurelinux-4:4:latest
```

## Supported VM sizes

Azure Linux runs on a broad range of Azure VM sizes, including:

- General Purpose Compute SKUs (for example, A, Dav#, Dv#-Series)
- SGX SKU (DCv2)
- Memory Optimized (E-Series)
- Compute Optimized (F-series)
- Storage Optimized (L-series)
- ARM64 SKU (v5 Ampere and v6 Cobalt)
- GPU (NVIDIA v100, T4, NC A100 V4, NDasr A100 V4, NDm A100 V4, NCads H100 V5, ND-H100-v5, ND-H200-v5, ND GB200-v6)

## Disk size

The Azure Linux VM disk size is set at *five GBs*. If you need to expand the Azure Linux disk size, use the parameter `--os-disk-size-gb <NUMBER_OF_GB_DESIRED>` or follow the guidance in [Expand virtual hard disks on a Linux VM](/en-us/azure/virtual-machines/linux/expand-disks).