---
layout: Conceptual
title: Overview of Azure Linux Deployment Options | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/deployment-options
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
description: Learn about the different deployment options for Azure Linux, including AKS container hosts, Azure Container Linux (ACL), virtual machines, and container images, and how to choose the right option for your workloads.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 79e5d38c-dfd0-adac-f182-0105d718f634
document_version_independent_id: f15e21b7-dfe2-06a7-a046-12a68bc1c13f
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/deployment-options.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/deployment-options
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/deployment-options.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 9c22fb19-4b6e-1b50-6a78-0fb0fc3df970
---

# Overview of Azure Linux Deployment Options | Microsoft Learn

Azure Linux is available across multiple Azure experiences, each optimized for a specific scenario while sharing the same trusted Azure Linux foundation. Whether you're deploying virtual machines (VMs), running Kubernetes workloads, building containerized applications, or setting up a local developer environment, Azure Linux provides a consistent platform with Microsoft-managed engineering, security response, and Azure-native integration.

This article provides an overview of the different Azure Linux deployment options, explains the scenarios each option is optimized for, and helps you determine which deployment approach is best suited for your workloads.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Deployment options

The following table summarizes the primary Azure Linux deployment options, the scenarios they are optimized for, and the key features and benefits each option provides:

| Use case | Deployment option | Features and benefits |
| --- | --- | --- |
| **Run Kubernetes workloads on a secure, Azure-native container host** | [Azure Linux container host for Azure Kubernetes Service (AKS)](azure-linux-aks-overview) | A container host optimized for AKS that delivers fast boot times, predictable updates, and strong security defaults with tight AKS lifecycle integration. Microsoft owns the full stack from kernel to CVE response, simplifying operations and reducing customer overhead. |
| **Run containers on an immutable, hardened operating system (OS) with a minimal attack surface** | [Azure Container Linux (ACL)](azure-container-linux-overview) | An immutable, container-optimized OS for AKS derived from Flatcar Container Linux with Azure Linux packages and servicing. The OS uses kernel-enforced immutability (dm-verity), SELinux, Trusted Launch with Secure Boot, and a minimal package set to reduce the attack surface and block tampering. Automated weekly image-based updates and supply-chain signing keep nodes current and verifiable. |
| **Run general-purpose VM workloads with Microsoft-supported Linux** | [Azure Linux for Virtual Machines](azure-linux-vm-vmss-overview) | A Microsoft-supported, Azure-optimized Linux distribution for scalable web apps, infrastructure services, and AI workloads. It integrates natively with Azure services, extensions, and tooling, and includes Microsoft-managed security response and lifecycle support. |
| **Build and ship containerized applications on a consistent base image** | [Azure Linux Container Images](container-images-overview) | Microsoft-maintained base images built from the Azure Linux supply chain that provide consistency from build to production. Customers can choose from full-featured base images for flexibility, runtime-optimized images for Node.js, Python, Java, and .NET, or hardened distroless images for the smallest possible attack surface. |
| **Develop, test, and learn Linux applications directly on Windows without a VM or dual boot setup** | [Azure Linux on Windows Subsystem for Linux (WSL)](windows-subsystem-for-linux-overview) | A Microsoft-supported Azure Linux experience running natively on Windows through WSL 2. Provides a lightweight, fast-starting Linux environment for development, scripting, container workflows, and learning Azure Linux. Developers can use familiar Linux tools, package management, and command-line workflows while seamlessly integrating with Windows applications, IDEs, files, and networking, enabling a productive local development experience without dedicated Linux infrastructure. |

Important

Azure Linux is open source, but Microsoft support and lifecycle commitments apply only to **Azure scenarios**. Specifically:

- Azure Linux Virtual Machines (VM) / Virtual Machine Scale Sets (VMSS), AKS container host, and container images are supported.
- Bare metal, ISO images, on-premises, and other clouds aren't supported.
- Customized images are supported only when built on top of a prebuilt Azure Linux image (for example, with [Image Customizer](customize-images)). Images built from scratch from the [Azure Linux sources on GitHub](https://github.com/microsoft/azurelinux) aren't covered.