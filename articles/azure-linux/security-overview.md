---
layout: Conceptual
title: Overview of Azure Linux Security | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/security-overview
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
description: Learn about the security features, protections, and compliance capabilities built into Azure Linux to help secure workloads running on Azure.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-26T00:00:00.0000000Z
locale: en-us
document_id: 1c03f42f-cd71-5d94-c6d5-a4aa58f6b385
document_version_independent_id: 2c57c714-eb11-6fe8-718c-d1bb0dd5b2dd
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/security-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/security-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/security-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 4fd57810-2fd6-1667-2d6e-716d923d1022
---

# Overview of Azure Linux Security | Microsoft Learn

Azure Linux is built with a secure-by-default baseline and layered protections across boot, runtime, and update workflows. This article covers the security model, key features, and recommendations for validating security settings on Azure Linux.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Security model

The following table summarizes the core security principles that guide the design of Azure Linux and how they are implemented across the platform:

| Security principle | Implementation in Azure Linux |
| --- | --- |
| Secure by default | Minimal package set, key-only SSH authentication, firewalld enabled |
| Defense in depth | SELinux mandatory access control, network hardening |
| Least privilege | SELinux policies, kernel capability restrictions |

## Core security features

### Secure by default baseline

- **Hardened kernel**: With ASLR, stack canaries, and pointer restrictions.
- **Minimal package set**: Only essential packages for core operating system (OS) functionality. No legacy protocols, development tools, or non-essential daemons in the base image.
- **No external network connections by default**: firewalld denies all inbound traffic except SSH.
- **Key-only SSH authentication**: Password authentication is disabled.
- **Package integrity**: All packages and repository metadata are GPG-signed.

### Runtime protections

- **SELinux:** In Enforcing mode. Targeted policy with pre-labeled packages.
- **eBPF hardening**: Unprivileged BPF disabled, interpreter disabled in favor of JIT.

### Network security

- **firewalld**: Enabled by default with nftables backend.
- **Network sysctl hardening**: Strict reverse path filtering, ICMP redirects disabled, SYN cookies enabled.
- **IPv6**: Enabled with hardening settings applied.

### Identity and access

- **SSSD/realmd**: Available from the Azure Linux repositories for hybrid identity scenarios with Active Directory and LDAP.

### Cryptography

- **FIPS 140-3**: Validated cryptographic modules with a simple enablement mechanism.
- **Post-quantum cryptography**: ML-KEM hybrid key exchange support.
- **System crypto libraries**: Applications can use OS-level crypto.

### Logging, auditing, and monitoring

- **auditd**: enabled by default; rule profiles ship under /usr/share/audit-rules/ and can be activated by copying the profile you need into /etc/audit/rules.d/.
- **journald**: Persistent storage with structured JSON output.

### Vulnerability scanning integrations

Azure Linux supports integration with common vulnerability scanning and security tooling. For a list of supported tools, see [Azure Linux partner solutions](ecosystem-support).