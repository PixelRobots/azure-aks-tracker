---
layout: Conceptual
title: Overview of Azure Linux with OS Guard for Azure Kubernetes Service (AKS) (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/os-guard-overview
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
description: Overview of Azure Linux with OS Guard (preview), a hardened, immutable variant of Azure Linux that provides enhanced runtime integrity, tamper resistance, and enterprise-grade security for container hosts on Azure Kubernetes Service (AKS).
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 42b656ad-3964-e2a4-448e-3583f0e4abe1
document_version_independent_id: 46b0bdab-3241-54bb-0136-1d2b26c85907
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/os-guard-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/os-guard-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/os-guard-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 5eb25ebb-4d52-8d64-8dd6-7f6eb655acfb
---

# Overview of Azure Linux with OS Guard for Azure Kubernetes Service (AKS) (Preview) | Microsoft Learn

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Note

Azure Container Linux (ACL) is the replacement for Azure Linux with OS Guard (preview) as the long‑term, immutable, container‑optimized Linux operating system (OS) for Azure Kubernetes Service (AKS). It provides a secure, minimal, and operationally consistent host OS designed to run containerized workloads at scale. For more information, see the [Azure Container Linux (ACL) overview](azure-container-linux-overview).

In this article, we provide an overview of Azure Linux with OS Guard, which is a hardened, immutable variant of Azure Linux. It provides strong runtime integrity, tamper resistance, and enterprise-grade security for container hosts on AKS. Built on Azure Linux, OS Guard adds kernel and runtime features that enforce code integrity, protect the root file system from unauthorized changes, and apply mandatory access controls. Use OS Guard when you need elevated assurances about your container host and workload runtime.

## Key features

The following table outlines key features of Azure Linux with OS Guard:

| Feature | Description | Notes |
| --- | --- | --- |
| **Immutability** | The /usr directory is mounted as a read-only volume protected by dm-verity. At runtime, the kernel validates a signed root hash to detect and block tampering. | N/A |
| **Code integrity** | OS Guard integrates the [Integrity Policy Enforcement (IPE) Linux Security Module](https://docs.kernel.org/next/admin-guide/LSM/ipe.html) to ensure that only binaries from trusted, signed volumes are allowed to execute. This helps prevent tampered or untrusted code from executing, including within container images. | IPE is running in *audit* mode during preview. |
| **Mandatory access control** | OS Guard integrates SELinux to limit which processes can access sensitive resources in the system. | SELinux is operating in *permissive* mode during preview. |
| **Measured boot and Trusted Launch** | OS Guard supports measured boot and integrates with [Trusted Launch](/en-us/azure/aks/use-trusted-launch) to provide cryptographic measurements of boot components stored in a virtual TPM (vTPM). This is achieved using a Unified Kernel Image (UKI), which bundles the kernel, initramfs, and kernel command line into a single signed artifact. During boot, the UKI is measured and recorded in the vTPM, ensuring integrity from the earliest stage. | N/A |
| **Verified container layers** | Container images and layers are validated using signed dm-verity hashes. This ensures that only verified layers are used at runtime, reducing the risk of container escape or tampering. IPE also extends within container images, ensuring that only binaries matching a trusted signature can be executed, even if they exist in a verified layer. | IPE is running in *audit* mode during preview. |
| **Sovereign Supply Chain Security** | OS Guard inherits Azure Linux’s secure build pipelines, signed Unified Kernel Images (UKIs), and Software Bill of Materials (SBOMs). | N/A |

## Key benefits

The following table outlines key benefits of using Azure Linux with OS Guard:

| Benefit | Description |
| --- | --- |
| **Strong runtime integrity guarantee** | Kernel-enforced immutability and IPE prevent execution of tampered or untrusted code. |
| **Reduced attack surface** | A read-only /usr directory, reduced package count, and SELinux policies limit opportunities for an attacker to install persistent backdoors or alter system binaries. |
| **Supply-chain trust** | Builds on Azure Linux’s signed images and supply-chain processes, delivering clear provenance for system components. |
| **Integration with Azure security features** | Native support for [Trusted Launch](/en-us/azure/aks/use-trusted-launch) and Secure Boot provides measured boot protections and attestation. |
| **Open-source transparency** | Many of the underlying technologies (dm-verity, SELinux, IPE) are upstream or open source, and Microsoft has tooling and contributions to support these features. |
| **Compliance inheritance** | OS Guard inherits compliance properties from Azure Linux (for example, cryptographic modules and certifications available to Azure Linux), making it easier to adopt in regulated environments. |

## Considerations and limitations

Keep the following considerations and limitations in mind when using Azure Linux with OS Guard for AKS:

- Kubernetes version 1.32.0 or higher is required for Azure Linux with OS Guard.
- All Azure Linux with OS Guard images have [Federal Information Process Standard (FIPS)](/en-us/azure/aks/enable-fips-nodes) and [Trusted Launch](/en-us/azure/aks/use-trusted-launch) enabled.
- Azure CLI and ARM templates are the only supported deployment methods for Azure Linux with OS Guard on AKS in preview. PowerShell and Terraform aren't supported.
- [Arm64](/en-us/azure/aks/use-arm64-vms) images aren't supported with Azure Linux with OS Guard on AKS in preview.
- `NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image) for Azure Linux with OS Guard on AKS. `Unmanaged` and `SecurityPatch` are incompatible with Azure Linux with OS Guard due to the immutable /usr directory.
- [Artifact Streaming](/en-us/azure/aks/artifact-streaming) isn't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Gen 1 virtual machines (VMs)](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.

## How to choose an Azure Linux container host option

Azure Linux with OS Guard is built on Azure Linux and benefits from the same supply-chain protections and signed images. Both OS variants can be appropriate depending on your security, compliance, and operational requirements:

| Container host option | Azure Linux Container Host | Azure Linux with OS Guard |
| --- | --- | --- |
| **Security benefits** | Azure Linux provides the security benefits Microsoft views as critical for AKS workloads. | All the benefits of Azure Linux plus the extra security benefits mentioned above. |
| **User familiarity** | Operations and tools are familiar to customers coming from other Linux distributions like Ubuntu. | Familiar to customers coming from other container optimized distributions. |
| **Target audience** | Targeted for customers doing lift and shifts, migrations, and coming from other Linux distributions. | Targeted for cloud-native customers who are born in the cloud or who are looking to modernize. |
| **Security controls** | Option to enable AppArmor if necessary for security minded customers. | Security toggles like SELinux and IPE are permissive by default. |