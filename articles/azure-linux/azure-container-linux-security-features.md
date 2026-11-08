---
layout: Conceptual
title: Azure Container Linux (ACL) for Azure Kubernetes Service (AKS) security features | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/azure-container-linux-security-features
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
description: Learn about the security features of Azure Container Linux (ACL) for Azure Kubernetes Service (AKS), including immutability, SELinux, IPE, Trusted Launch, and supply-chain protections.
author: florataagen
ms.author: florataagen
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: concept-article
ms.date: 2026-10-13T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 6d3cef5e-1cdb-ed3a-f30f-ad38c3d47ab3
document_version_independent_id: fe9a09a7-83b9-3755-c6cd-73c83774f8c4
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/azure-container-linux-security-features.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/azure-container-linux-security-features
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/azure-container-linux-security-features.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 4b0cb0ec-1e92-8bc2-919a-69869b574d98
---

# Azure Container Linux (ACL) for Azure Kubernetes Service (AKS) security features | Microsoft Learn

Azure Container Linux (ACL) is an immutable, container-optimized operating system (OS) for Azure Kubernetes Service (AKS). ACL includes several layered security features that protect the OS from the boot chain through runtime. This article describes these features and how they work together.

## Protect the boot chain

ACL requires [Trusted Launch](/en-us/azure/virtual-machines/trusted-launch) with Secure Boot and a virtual Trusted Platform Module (vTPM). ACL uses a Unified Kernel Image (UKI), which bundles the kernel, initramfs, and kernel command line into a single signed artifact. During boot, the UKI is measured and recorded in the vTPM. These protections help verify the integrity of the boot chain before the OS loads.

## Protect OS integrity

ACL mounts the `/usr` directory as a read-only volume protected by dm-verity. At runtime, the kernel validates a signed root hash to detect and block tampering with the OS image. This design prevents unauthorized changes to system binaries and libraries and reduces configuration drift across nodes.

### Integrity Policy Enforcement

ACL supports the [Integrity Policy Enforcement (IPE) Linux Security Module](https://docs.kernel.org/admin-guide/LSM/ipe.html), which evaluates whether executable code comes from a trusted source. IPE complements SELinux by validating code integrity before execution, while SELinux controls what resources a process can access.

You can enable IPE in audit mode to record policy violations without blocking the affected operations. Audit mode helps you evaluate workload compatibility before you enable enforcement. For configuration steps, see [Enable IPE in audit mode](enable-integrity-policy-enforcement-audit-mode).

## Restrict runtime access

ACL includes SELinux to enforce mandatory access control policies. These policies restrict which processes can access sensitive system resources. SELinux runs in enforcing mode by default.

To temporarily change the SELinux mode for troubleshooting, see [Toggle SELinux mode for troubleshooting](selinux-toggle-troubleshoot).

ACL also includes only the components required to run containers. Fewer packages and services reduce the number of potential entry points and simplify security management.

## Protect the software supply chain

ACL builds on Azure Linux signed packages and secure build pipelines. Signed UKIs and component provenance help establish the origin and integrity of the OS image.

## Maintain security over time

ACL receives weekly image-based node updates that include security patches and bug fixes. Image-based updates keep OS versions consistent across your cluster and reduce exposure to known vulnerabilities.

For the release format, supported update model, and instructions to check the node image version, see [ACL for AKS versioning](azure-container-linux-overview#acl-for-aks-versioning).

## Package inventory for security scanners

ACL doesn't include an RPM database or a package manager on the node, so vulnerability scanners can't query installed packages the way they do on a general-purpose OS. Instead, each ACL image includes a package inventory in the standard [Software Package Data Exchange (SPDX) 2.2](https://spdx.github.io/spdx-spec/v2.2.2/) JSON format. The inventory is stored in SPDX package manifest files, which are different from Kubernetes manifests. The build process generates these files from the packages in the image, so they match what the node runs.

On an ACL node, the SPDX package manifest files are in the following locations:

| File | Contents |
| --- | --- |
| `/usr/share/os-manifests/package-manifest.spdx.json` | Packages in the base OS image. |
| `/usr/share/os-manifests/package-manifest.<extension-name>.spdx.json` | Packages in a system extension, such as `containerd`. One file exists for each system extension that's merged on the ACL node. |

Each package entry includes the package `name`, its `versionInfo`, and a [package URL (PURL)](https://github.com/package-url/purl-spec) in `externalRefs`, for example `pkg:rpm/azurelinux/bash@5.2.15-3.azl3?arch=x86_64`. Scanners and other tools can match these identifiers against vulnerability data without access to the node's package manager.

SPDX package manifest files for system extensions appear and disappear as extensions are merged and unmerged. To get the complete package inventory of a node, read the base OS manifest file (`package-manifest.spdx.json`) together with every `package-manifest.*.spdx.json` file that's present, rather than a fixed list of file names. These SPDX package manifest files describe the OS packages that ACL ships. They don't list software that your container images include.

To check the SPDX package manifest files on an ACL node, connect to the node by using [`kubectl debug`](/en-us/azure/aks/node-access#connect-with-kubectl-debug), replacing the node name with the name of your ACL node. Then run `chroot /host` and list the package URLs:

```bash
ls /usr/share/os-manifests/
grep -h -o '"pkg:rpm/[^"]*"' /usr/share/os-manifests/*.spdx.json
```

To find the latest list of supported vulnerability scanners for ACL, see [Ecosystem support](ecosystem-support).

## CIS hardening out of the box

The CIS Benchmark for ACL is generally available, providing a published baseline for evaluating your ACL node configurations. You can find the latest ACL Benchmark [here](https://www.cisecurity.org/benchmark/azure_linux).