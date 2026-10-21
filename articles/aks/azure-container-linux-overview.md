---
layout: Conceptual
title: Azure Container Linux (ACL) for AKS Overview - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-container-linux-overview
breadcrumb_path: /azure/breadcrumb/azure-aks/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/200/azure-kubernetes-service/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn about Azure Container Linux (ACL), an immutable, container-optimized operating system for Azure Kubernetes Service (AKS) that builds on Flatcar Container Linux while integrating Azure Linux packages and platform features.
author: schaffererin
ms.author: schaffererin
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 2fbac03d-b96f-6188-b3b3-0c29e123cca6
document_version_independent_id: 1617099f-9818-f91c-9829-e8c1f0b456a4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-container-linux-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/azure-container-linux-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-container-linux-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 08463750-e126-2790-73cb-d2fc720a43da
---

# Azure Container Linux (ACL) for AKS Overview - Azure Kubernetes Service | Microsoft Learn

In this article, we provide an overview of Azure Container Linux (ACL), an immutable, container-optimized operating system (OS) for Azure Kubernetes Service (AKS). ACL is derived from the Flatcar Container Linux project, building on Flatcar's proven, container-first immutable design while layering in Azure Linux packages, servicing, and platform integration. This allows ACL to stay closely aligned with upstream Flatcar innovation while meeting Azure's production, security, and compliance requirements. To learn more about Flatcar Container Linux, see the [Flatcar documentation](https://www.flatcar.org/).

ACL is generally available (GA) as an OS option on AKS starting AKS v1.34. You can deploy ACL node pools in a new AKS cluster, add ACL node pools to your existing clusters, and migrate existing Linux node pools to ACL.

Note

ACL is the GA release of Flatcar Container Linux for AKS, which entered preview in November 2025. OS Guard (preview) features, such as code integrity with Integrity Policy Enforcement (IPE), currently aren't supported. If you need OS Guard features today, we recommend continuing to use OS Guard and migrating to ACL once those features become available.

## Benefits of using ACL on AKS

Using ACL as the OS for your AKS node pools provides several benefits that enhance security, reliability, and operational efficiency:

- **Built-in immutability for stronger security**: Kernel-enforced immutability of the `/usr` directory verifies the integrity of the OS image at boot and runtime. This design helps block unauthorized changes before they can affect your cluster and reduces the risk of OS-level tampering.
- **Minimal attack surface**: ACL ships only the components required to run containers. By reducing the size and complexity of the OS, ACL minimizes the number of packages, services, and potential entry points available to attackers and simplifies security management.
- **Automated node image updates**: ACL delivers weekly image-based updates that include the latest security patches and bug fixes. This approach keeps node OS versions consistent and current across the cluster and helps reduce exposure to known vulnerabilities.
- **Supply-chain trust**: Builds on Azure Linux’s signed packages and supply-chain processes, delivering clear provenance for system components.
- **Integration with Azure security features**: Native support for [Trusted Launch](/en-us/azure/aks/use-trusted-launch) and Secure Boot provides measured boot protections and attestation.
- **Open-source transparency**: Flatcar as well as many of the underlying technologies (dm-verity and SELinux) are upstream or open source, and Microsoft has tooling and contributions to support these features.

## Key features of ACL

The following key features distinguish ACL as a hardened, container-optimized OS for AKS:

- **Immutability**: The '/usr' directory is mounted as a read-only volume protected by dm-verity. At runtime, the kernel validates a signed root hash to detect and block tampering
- **Mandatory access control with SELinux**: ACL includes SELinux to enforce mandatory access control policies that restrict which processes can access sensitive system resources. Note that *SELinux is operating in enforcing mode by default. SELinux policies might evolve over time*.
- **Trusted Launch and Secure Boot**: ACL requires [Trusted Launch](/en-us/azure/virtual-machines/trusted-launch) with Secure Boot and vTPM, to ensure the integrity of the boot chain before the OS loads. This is achieved using a Unified Kernel Image (UKI), which bundles the kernel, initramfs, and kernel command line into a single signed artifact. During boot, the UKI is measured and recorded in the vTPM, ensuring integrity from the earliest stage.
- **NVIDIA GPU node support**: ACL supports NVIDIA GPU-enabled node pools on AMD64 architectures, allowing you to run high-performance computing (HPC) and AI/ML workloads on AKS with a hardened, container-optimized OS. ACL doesn't support ARM64 architectures for GPU-enabled node pools.
- **AMD64 and ARM64 architecture support**: ACL is available for both AMD64 and ARM64 architectures on AKS.
- **Sovereign Supply Chain Security**: ACL inherits Azure Linux’s secure build pipelines and signed Unified Kernel Images (UKIs).
- **[Node auto-provisioning](node-auto-provisioning)**: ACL supports node auto-provisioning (NAP).

Important

If you're using **Azure Container Linux (ACL)** on AKS, make sure you review the following considerations and limitations:

- ACL is generally available starting AKS v1.34.
- ACL requires [Trusted Launch](/en-us/azure/aks/use-trusted-launch) with Secure Boot and vTPM. Non-Trusted Launch variants aren't available.
- ACL on Arm64 requires Cobalt-based (v6) SKUs to enable Trusted Launch compatibility.
- `NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image). `Unmanaged` and `SecurityPatch` are incompatible with ACL due to the immutable `/usr` directory.
- [Artifact Streaming](/en-us/azure/aks/artifact-streaming) isn't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Generation 1 VMs](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.

## Feature roadmap

For more information, see the [Azure Linux Feature Roadmap](https://github.com/orgs/microsoft/projects/970/views/2).

## OS migrations and upgrades with ACL

AKS supports migrating existing node pools to ACL using in-place OS SKU migration or by creating new ACL node pools. For detailed migration steps, considerations, and rollback instructions, see [Migrate existing nodes to ACL](migrate-nodes-azure-container-linux).

## ACL for AKS versioning

ACL for AKS releases weekly AKS node images. Versioning follows the AKS date-based format (for example: 202506.13.0). ACL currently only supports full node image updates. For more information, see [Azure Container Linux (ACL) node images](node-images#azure-container-linux-acl-node-images).

You can check available node images in the release notes and view the `nodeImageVersion` for a running cluster using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command. For example:

```azurecli
az aks nodepool list --resource-group <resource-group-name> --cluster-name <aks-cluster-name> --query '[].{name: name, nodeImageVersion: nodeImageVersion}'
```

Example output:

```output
[
{
    "name": "nodes",
    "nodeImageVersion": "AKSAzureContainerLinux-202606.01.0"
}
]
```