---
layout: Conceptual
title: Get started with Azure Linux for Azure Kubernetes Service (AKS) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/get-started-aks
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
description: Learn about the Azure Linux deployment options available for Azure Kubernetes Service (AKS) and how to choose the right one for your workloads.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: get-started
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 68462a2d-2e8c-ad30-d429-6d61cf34ab86
document_version_independent_id: a1f5775d-f164-ede9-0fe0-d228de822877
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/get-started-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/get-started-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/get-started-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: dab42583-2d43-a028-ba0b-9b35d83fd2eb
---

# Get started with Azure Linux for Azure Kubernetes Service (AKS) | Microsoft Learn

Azure Linux offers two container-optimized operating system (OS) options for Azure Kubernetes Service (AKS): the [Azure Linux Container Host](azure-linux-aks-overview) and [Azure Container Linux (ACL)](azure-container-linux-overview). Both are built on the Azure Linux foundation and maintained by Microsoft, but they differ in design philosophy, update model, and security posture.

This article helps you understand the differences between the two Azure Linux container-optimized OS options for AKS and provides guidance on selecting the right option based on your workload requirements.

## Azure Linux Container Host and Azure Container Linux (ACL) comparison

The following table summarizes the key differences between Azure Linux Container Host and Azure Container Linux (ACL) across several dimensions, including base OS, filesystem model, update mechanism, OS upgrade channels, and other operational and security characteristics:

| Aspect | Azure Linux Container Host | Azure Container Linux (ACL) |
| --- | --- | --- |
| **Based on** | Azure Linux | Flatcar Container Linux with Azure Linux packages and servicing |
| **Filesystem model** | Mutable (standard read-write) | Immutable (`/usr` is read-only, protected by dm-verity) |
| **Update mechanism** | Package-based OS updates | Weekly image-based updates (no individual package updates) |
| **OS upgrade channels** | All AKS node OS upgrade channels supported | `NodeImage` and `None` only |
| **Package management** | RPM-based (`dnf`) | No package management (immutable OS) |
| **Customization** | Package-level customization possible | Workload customization primarily via containers; when host-level software delivery is needed, extensibility is provided via systemd extensions |
| **Security model** | Hardened Linux kernel with Azure optimizations, CIS Level 1 compliant | Kernel-enforced immutability (dm-verity), SELinux enforcing by default, Trusted Launch with Secure Boot required |
| **Boot requirements** | Standard AKS virtual machine (VM) sizes | Trusted Launch with Secure Boot and vTPM required (Generation 2 VMs only) |
| **Architecture support** | AMD64 and ARM64 | AMD64 and ARM64 |
| **GPU support** | All NVIDIA GPU AMD64 VM sizes on AKS | All NVIDIA GPU AMD64 VM sizes on AKS |
| **FIPS support** | Supported | Supported |
| **Pod Sandboxing** | Supported | Not supported |
| **Artifact Streaming** | Supported | Not yet supported |
| **Confidential VMs** | Supported | Not yet supported |

## When to use Azure Linux Container Host

Use Azure Linux Container Host when you need:

- **Broad feature compatibility**: Full support for all AKS OS upgrade channels, FIPS, Pod Sandboxing, Artifact Streaming, and Confidential VMs.
- **Package-level flexibility**: The ability to install, update, or customize individual packages on your nodes.
- **General-purpose container workloads**: A lightweight, secure, and stable container host that works with existing AKS extensions, add-ons, and open-source tooling.

To get started with Azure Linux Container Host on AKS, see [Quickstart: Deploy an Azure Linux Container Host for AKS cluster using the Azure CLI](quick-create-azure-linux-aks).

## When to use Azure Container Linux (ACL)

Use ACL when you need:

- **Tamper-proof infrastructure**: Kernel-enforced immutability with dm-verity ensures the OS image can't be modified at runtime.
- **Smallest attack surface**: Only the components required to run containers are included, reducing the number of packages and potential entry points for attackers.
- **Consistent, automated updates**: Weekly image-based auto updates keep every node at the same OS version with the latest security patches.
- **Strict security and compliance**: SELinux (enforcing by default) and Trusted Launch with Secure Boot (via a Unified Kernel Image) are enabled by default.

To get started with ACL on AKS, see [Quickstart: Deploy an Azure Container Linux (ACL) AKS cluster using the Azure CLI](quick-deploy-azure-container-linux-aks-cli).