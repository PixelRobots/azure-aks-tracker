---
layout: Conceptual
title: Introduction to Azure Linux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/azure-linux-overview
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
description: Learn about Azure Linux, the Microsoft-maintained, open-source Linux distribution optimized for running workloads on Azure.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: ecd05408-0dea-b561-47b1-d1ca25128e3f
document_version_independent_id: c08c2af1-e138-8f73-143d-7b4ff3567130
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/azure-linux-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/azure-linux-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/azure-linux-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 4c61b291-4cbf-63a8-1c37-84577dbaf9fb
---

# Introduction to Azure Linux | Microsoft Learn

![](media/azure-linux-logo-new.png)

Azure Linux is a Microsoft-maintained, open-source Linux distribution built for Azure. It provides a lightweight, security-hardened operating system for virtual machines (VMs), containers, and Kubernetes clusters running on Azure infrastructure.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Why choose Azure Linux?

Azure Linux is built on a robust open-source foundation from the [Fedora](https://fedoraproject.org/) ecosystem and enhanced with Azure-specific innovations. This gives you the familiarity of RPM package ecosystem, while adding Azure-native security, compliance, and operational capabilities.

The following table highlights the key features and benefits of Azure Linux:

| Feature | Description |
| --- | --- |
| **Hardened security posture** | Hardened from the kernel up with kernel lockdown, dm-verity for verified boot, SELinux for mandatory access controls, and FIPS 140-3 cryptographic modules. |
| **Minimal footprint** | Ships only the packages required for cloud workloads, resulting in a smaller attack surface, fewer CVEs, and faster boot times and lower memory consumption. |
| **Azure-optimized kernel** | Purpose-built [kernel](whats-new-azure-linux-4) (6.18 LTS) with Hyper-V guest drivers, Azure-specific performance tuning, and security hardening validated across Azure environments like Virtual Machines (VM) / Virtual Machine Scale Sets and AKS. |
| **Native Azure integration** | Ships with validated Azure agents, VM extensions, and developer tools including Microsoft Defender for Cloud, Azure Monitor, Azure CLI, and more. See the full list in [Supported Azure services](supported-azure-services). |
| **Consistent across environments** | Same operating system (OS) foundation, package set, and update mechanisms whether running on [AKS](azure-linux-aks-overview), [Azure VM / Virtual Machine Scale Sets](azure-linux-vm-vmss-overview), or [container images](container-images-overview). See the [architecture overview](architecture). |
| **Predictable lifecycle** | Follows a lifecycle model designed to balance stability, security, and access to modern Linux capabilities. See [Release cadence and lifecycle](release-cadence-lifecycle). |

## How to use Azure Linux

Azure Linux is available across multiple Azure environments, each optimized for a specific Azure scenario while sharing the same trusted OS foundation, security baseline, and Microsoft-managed lifecycle. For full details, see the [deployment options overview](deployment-options).

| Platform | Best for | Description |
| --- | --- | --- |
| **[Azure Linux for VMs](azure-linux-vm-vmss-overview)** | VM-based infrastructure | Run infrastructure workloads on a Microsoft-supported, Azure-optimized Linux distribution. From web apps to AI workloads, Azure Linux delivers consistency, security, and performance while integrating natively with Azure services, extensions, and tooling. |
| **[Azure Linux for AKS](azure-linux-aks-overview)** | Kubernetes at scale | Already powering millions of cores running mission-critical workloads, Azure Linux is the container host for AKS. Offered as a standard host or as [Azure Container Linux (ACL)](azure-container-linux-overview), an immutable variant for teams with stricter security and compliance requirements. Optimized for fast boot, predictable updates, and end-to-end Microsoft ownership from kernel to CVE response. |
| **[Azure Linux Container Images](container-images-overview)** | Cloud-native applications | Build and run containerized applications on Microsoft-maintained base images to ensure consistency from build to production. Choose full-featured base images for flexibility, runtime-optimized images for Node.js, Python, Java, and .NET, or hardened distroless images for the smallest possible attack surface. |
| **[Azure Linux ISO](https://github.com/microsoft/azurelinux/releases)** | Local testing and evaluation | Download Azure Linux ISO artifacts from the [Azure Linux GitHub repository](https://github.com/microsoft/azurelinux/releases) for local testing and evaluation. |
| **[Azure Linux on Windows Subsystem for Linux (WSL)](windows-subsystem-for-linux-overview)** | Local development and learning | Run Azure Linux natively on Windows through Windows Subsystem for Linux (WSL) without requiring a dedicated VM or dual-boot configuration. Azure Linux on WSL provides a lightweight, fast-starting environment for application development, scripting, container workflows, and learning Azure Linux. |

Important

Azure Linux is open source, but Microsoft support and lifecycle commitments apply only to **Azure scenarios**. Specifically:

- Azure Linux VM / Virtual Machine Scale Sets, AKS container host, and container images are supported.
- Bare metal, ISO images, on-premises, and other clouds aren't supported.
- Customized images are supported only when built on top of a prebuilt Azure Linux image (for example, with [Image Customizer](customize-images)). Images built from scratch from the [Azure Linux sources on GitHub](https://github.com/microsoft/azurelinux) aren't covered.

## Azure Linux release notes

Each Azure Linux release includes security updates, package upgrades, and bug fixes. See the [Azure Linux release notes](https://github.com/microsoft/azurelinux/releases) on GitHub for more information.