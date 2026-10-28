---
layout: Conceptual
title: Azure Linux Architecture Overview | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/architecture
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
description: Learn about the layered architecture of Azure Linux, including the kernel, core OS, user-space packages, and workload layers, and how these layers are optimized for running workloads on Azure.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 4aadcb7f-0ee4-fcc9-b1c5-02c200110206
document_version_independent_id: b7b17e15-cc61-0bc5-8a8e-836d11f2fff3
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/architecture.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/architecture
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/architecture.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 3ff96551-8114-ff6c-91a2-110a92c734bf
---

# Azure Linux Architecture Overview | Microsoft Learn

Azure Linux is a Microsoft-maintained Linux distribution built on the Fedora ecosystem and optimized for Azure. This article explains how Azure Linux is structured, what it includes by default, and where it intentionally draws boundaries.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## How Azure Linux relates to Fedora

Azure Linux derives from [Fedora](https://fedoraproject.org/) and uses the same RPM-based packaging ecosystem. You get the familiarity of `dnf5`, Fedora build tooling (`mock`, `fedpkg`, `koji`, `kiwi`), and modern compiler toolchains — all tracked from upstream Fedora. On top of that foundation, Microsoft adds Azure-specific hardening, a custom kernel, and a managed lifecycle suited for cloud workloads.

The kernel ships as version 6.18 LTS, extended with Hyper-V guest drivers, Azure-specific performance tuning, and security hardening validated across Azure VM SKUs.

## Layered architecture

Azure Linux uses a layered model. Each layer builds on the one below it, from hardware and firmware at the base up to your workloads at the top.

[![Screenshot of a diagram showing the Azure Linux layered architecture.](media/layered-architecture-azure-linux.png)](media/layered-architecture-azure-linux.png#lightbox)

### Kernel layer

The custom Azure Linux kernel includes Hyper-V guest drivers, security hardening patches, and performance optimizations tuned for Azure infrastructure. You can choose between Long-Term Support (LTS) kernels for stability or Hardware Enablement (HWE) kernels for new hardware and GPU support. See [Release cadence and lifecycle](release-cadence-lifecycle) for details.

### Core OS layer

This layer provides the minimal root filesystem: `systemd` for service management, `glibc` as the C runtime, and OpenSSL for cryptography. These are Tier 1 components, meaning they're version-locked for the lifetime of a major release and receive only security backports. This keeps application binary interface (ABI) stable and behavior predictable.

### User-space packages layer

Language runtimes (Python, Go, Rust, Node.js), container tooling, and application dependencies live here. Tier 1 packages are locked for stability. Tier 2 packages are updated on a predictable cadence. For more information, see [Release cadence and lifecycle](release-cadence-lifecycle).

### Workload layer

Your Azure services and applications run here. Azure Linux presents the same OS foundation, package set, and behavior whether you're running on AKS, Azure VMs, or container images.

## Platform scope

Azure Linux is designed for Azure cloud workloads. Although Azure Linux is open source, Microsoft support and lifecycle commitments apply only to Azure scenarios.

The following table outlines what is and isn't supported on Azure Linux:

| Area | Supported | Not supported |
| --- | --- | --- |
| **Architectures** | x86-64 (v2 minimum), ARMv8 (64-bit) | 32-bit architectures |
| **Environments** | Azure VMs, AKS, container images | ISO images, on-premises, multicloud, IoT, edge devices |
| **User interface** | Text-based console, SSH | Graphical desktop environments, GUI installer |
| **Virtualization** | KVM guests, Hyper-V | Xen |
| **Peripheral hardware** | Azure-attached storage, networking, GPUs | Bluetooth, Wi-Fi, printers, audio/video, robotics |
| **Trusted platform** | TPM 2.0 | TPM 1.x |
| **Language support** | Global locale support available | Not all language packs are included in the base image |

Every Azure Linux image includes `waagent` and `cloud-init`. These components are required for Azure integration and must always be present.

## Repository structure

Azure Linux ships packages in several separate repositories. Knowing which repository a package comes from helps you reason about supportability, what's available out of the box, and what you need to opt into. For day-to-day package management information, see [Package management](package-management-overview).

## Networking defaults

Azure Linux ships with a networking stack tuned for Azure VMs, AKS nodes, and container workloads. Most workloads can use the defaults without changes.

The following table summarizes the default networking components in Azure Linux and the alternatives that are available if you need to override the defaults for a specific scenario:

| Component | Default | Alternative | Notes |
| --- | --- | --- | --- |
| **Network manager** | systemd‑networkd + cloud‑init | NetworkManager (available, not default) | systemd‑networkd is the default for Azure VM and container scenarios. |
| **Firewall** | firewalld | N/A | Enabled by default with a deny‑inbound, allow‑outbound policy. |
| **Firewall backend** | nftables | iptables (legacy, available) | nftables is the modern replacement for iptables. iptables legacy support is available but not default. |
| **IPv6** | Enabled and hardened | N/A | Strict sysctl hardening applied for both IPv4 and IPv6. |

## Storage defaults

Azure Linux storage defaults are tuned for Azure-attached disks and the Hyper-V hypervisor underneath every Azure VM. The filesystem, boot loader, and clock source are chosen for predictable performance and compatibility with Azure platform features such as snapshots and managed disks.

The following table summarizes the default storage settings in Azure Linux and the alternatives that are available if you need to override the defaults for a specific scenario:

| Setting | Default | Alternatives |
| --- | --- | --- |
| **Filesystem** | ext4 | xfs, btrfs |
| **Boot** | GRUB2 bootloader | N/A |
| **Clock** | Hyper‑V PTP clock source | N/A |
| **NVMe** | Timeout tuned for Azure attached storage | N/A |

## Security architecture

Azure Linux is hardened at every layer, from the kernel up through the supply chain. The following sections describe the security controls that are enabled by default. See [Security and compliance](security-overview) for more information.

### Mandatory access control

Mandatory access control (MAC) confines processes to the access they actually need, even when they run as root.

Azure Linux 4.0 preview enables SELinux in enforcing mode as its MAC framework.

### Secure Boot

Secure Boot ensures only signed bootloaders and kernels run. Kernel lockdown protects the running kernel and disables loading untrusted kernel modules at runtime.

Note

Azure Linux 4.0 is now in **preview** and its components aren't yet signed for Secure Boot.

### Kernel and system hardening

The kernel and userspace are built with mitigations that make exploits harder to write and easier to contain if they succeed.

The following table summarizes the kernel and system hardening capabilities in Azure Linux:

| Capability | Description |
| --- | --- |
| **ASLR** | Strong address space layout randomization enabled. |
| **Stack protection** | Compiler‑level stack protections applied to all packages. |
| **Syscall restrictions** | Default seccomp profiles and syscall filtering. |
| **Minimal base image** | Reduced attack surface through minimal package set. |

### Cryptography

Azure Linux centralizes cryptographic policy so that algorithms and key sizes stay consistent across OpenSSL, GnuTLS, NSS, and OpenSSH.

The following table summarizes the cryptography settings in Azure Linux:

| Setting | Value |
| --- | --- |
| **FIPS** | FIPS 140‑3 certification is mandatory. |
| **Crypto policies** | Fedora crypto‑policies adopted for consistent algorithm selection. |
| **Post‑quantum** | ML‑KEM planned, aligned with Fedora and RHEL roadmap. |

### Logging and auditing

The following table summarizes the logging and auditing settings in Azure Linux:

| Setting | Value |
| --- | --- |
| **Audit daemon** | auditd enabled. |
| **Journal storage** | Persistent journald storage. |