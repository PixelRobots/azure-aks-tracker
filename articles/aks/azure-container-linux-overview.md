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

ACL is generally available (GA) as an OS option on AKS starting AKS v1.34. You can deploy ACL node pools in a new AKS cluster or add ACL node pools to your existing clusters.

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Benefits of using ACL on AKS

ACL is a secure, minimal OS that includes only the critical components required to run containers. It uses an immutable design to preserve OS integrity and reduce node configuration drift.

| Benefit | Description |
| --- | --- |
| **Layered OS security** | ACL combines an immutable OS, mandatory access controls, verified boot, and trusted build processes to protect nodes from boot through runtime. For details, see [ACL security features](/en-us/articles/azure-linux/azure-container-linux-security-features.md). |
| **Minimal container host** | ACL includes only the components required to run containers, reducing OS complexity and simplifying node management. |
| **Consistent node servicing** | Weekly image-based updates provide security patches and bug fixes while keeping the OS version consistent across each node image. |
| **Open-source transparency** | Flatcar as well as many of the underlying technologies (dm-verity and SELinux) are upstream or open source, and Microsoft has tooling and contributions to support these features. |

## Capabilities and compatibility

ACL supports the following AKS capabilities:

- **NVIDIA GPU node support**: ACL supports NVIDIA GPU-enabled node pools on AMD64 architectures, allowing you to run high-performance computing (HPC) and AI/ML workloads on AKS with a hardened, container-optimized OS. ACL doesn't support ARM64 architectures for GPU-enabled node pools.
- **FIPS**: ACL supports FIPS-enabled node pools.
- **AMD64 and ARM64 architecture support**: ACL is available for both AMD64 and ARM64 architectures on AKS.
- **[Node auto-provisioning](/en-us/azure/aks/node-auto-provisioning)**: ACL supports node auto-provisioning (NAP).
- **[Confidential VM](/en-us/azure/aks/use-cvm)**: ACL is available as a confidential VM (CVM) image for AKS, with a FIPS-enabled option.

## Unsupported features

ACL doesn't currently support the following features:

- The `SecurityPatch` and `Unmanaged`[node OS upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image).
- [Generation 1 VMs](/en-us/azure/aks/aks-virtual-machine-sizes): You can't use VM sizes that only support Generation 1 with ACL.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing).
- A non-Trusted Launch variant. ACL requires Trusted Launch.

If your existing cluster uses any of these unsupported features, you might not be able to add an ACL node pool to that cluster.

## Feature roadmap

Azure Linux publishes a [feature roadmap](https://github.com/orgs/microsoft/projects/970/views/2) that contains features that are in development and available for general availability (GA) and public preview.

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