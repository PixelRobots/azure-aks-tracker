---
layout: Conceptual
title: Node Images in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-images
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
description: Learn about the different node images available in Azure Kubernetes Service (AKS).
ms.topic: overview
ms.subservice: aks-nodes
ms.date: 2026-08-06T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: 5f1c104b-db9a-9bbc-287b-6b0db3ef31cc
document_version_independent_id: 73b6b0b3-291b-fd38-d02a-2f7a16ea26fd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-images.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/node-images
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-images.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 536867e5-27c0-b9e2-42f4-062476ca99e3
---

# Node Images in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article describes the node images available for Azure Kubernetes Service (AKS) nodes.

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Starting on **March 17, 2027**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Ubuntu 20.04. Any existing node images will be deleted, and you'll be unable to scale any node pools running Ubuntu 20.04. Migrate to a supported Ubuntu version by [upgrading your node pools](upgrade-aks-cluster) to Kubernetes version 1.35+. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4874) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=485795). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Starting on **June 30, 2027**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Ubuntu 22.04. To avoid disruptions, [transition](upgrade-aks-cluster) to Ubuntu 24.04 or later by that date. Between now and June 30, 2027, you can continue to use Ubuntu 22.04 on AKS without disruption. If you don't migrate by June 30, 2027, you won't be able to create new node pools, AKS won't produce new node images, and you'll no longer receive security patches for existing node pools. If you want to enable long-term support (LTS) with Kubernetes version 1.33 or later, first update your node pools to Ubuntu 24.04. On **April 30, 2028**, AKS will remove Ubuntu 22.04 node images and existing code, causing scaling and remediation operations to fail. To avoid service disruptions such as security vulnerabilities, failed node image upgrades, and scaling failures, [migrate](upgrade-aks-cluster) to Ubuntu 24.04 or later by June 30, 2027. Your migration options include:

- **Default Operating System SKU (OSSku)**: If you're using `Ubuntu`, you'll automatically migrate to Ubuntu 24.04 when you upgrade your Kubernetes version to 1.35 or later.
- **Versioned OSSku**: If you're using `Ubuntu2204`, update your OSSku to `Ubuntu` for Kubernetes 1.35 or later or `Ubuntu2404` for Kubernetes 1.32 or later.

For more information on this retirement, see the [Retirement GitHub issue](https://aka.ms/aks/ubuntu2204-retirement-github) and [Azure Updates post](https://azure.microsoft.com/updates/?id=557928). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Starting on June 30, 2028, Azure Kubernetes Service (AKS) no longer supports Windows Server 2022 node pools. Windows Server 2022 isn't supported in Kubernetes version 1.37 and later. Starting on June 30, 2029, AKS will remove all existing node images for Windows Server 2022, meaning that scaling operations will fail. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4168) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=ws2022-retirement-aks). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Starting on **May 15, 2026**, AKS no longer supports Windows Server Annual Channel (Preview). AKS will no longer produce new Windows Server Annual Channel node images or provide security patches. You won't be able to create new node pools with Windows Server Annual Channel. On **May 15, 2027**, AKS will remove all existing Windows Server Annual Channel node images, which will cause scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, we recommend migrating to the [Long Term Servicing Channel (LTSC)](/en-us/azure/aks/upgrade-windows-os).

- Windows Server Annual Channel uses Windows Server 2022 base images, which will run on Windows Server 2022 and Windows Server 2025.
- If you're using [Host Process Containers (HPC)](use-windows-hpc) or running other privileged containers for administration purposes, you need to do extra testing.

For more information on this retirement, see the [Retirement GitHub issue](https://aka.ms/aks/windows-annual-channel-retirement). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Older node images can contain unpatched security vulnerabilities and might not work properly with recently released features. Using older images might lead to issues with scaling, node readiness, and security. Depending on the age of the image version, it could also place the cluster outside of the support scope until you perform a node image upgrade. **We recommend that you keep node images [current](https://releases.aks.azure.com/) and enable automatic upgrades**.

## Node image releases

Azure Kubernetes Service (AKS) regularly provides new node images, so it's beneficial to upgrade your node images frequently to access the latest AKS features, component updates, and security fixes. You can find detailed summaries of each node image version in the [AKS VHD notes](https://github.com/Azure/AKS/tree/master/vhd-notes).

Linux node images are released weekly, and Windows node images are released monthly. New node images are included in the [AKS release notes](https://github.com/Azure/AKS/releases).

> 
> **Best practice guidance**
> 
> Configure [automatic node image upgrades](auto-upgrade-node-os-image) and schedule them using [planned maintenance](planned-maintenance). This will ensure that your node images are always up to date without requiring manual upgrades.

When new node images are released, it can take up to two weeks for the updates to be rolled out across all regions. The [AKS Release Tracker](release-tracker) shows the current latest node image version, three previously available node image versions for each region, and the node image update order by region. Once the node image is available in your region, you can perform a [manual node image upgrade](node-image-upgrade) or configure [automatic node image upgrades](auto-upgrade-node-os-image) and schedule them using [planned maintenance](planned-maintenance).

## Default node images

AKS sets a default operating system (OS) and node image during cluster and node pool creation. OS Type can be used to filter between Linux or Windows.

| OS Type | Default OS | Default node image |
| --- | --- | --- |
| Not Specified | Ubuntu Linux | Ubuntu with containerd and gen 2 |
| Linux | Ubuntu Linux | Ubuntu with containerd and gen 2 |
| Windows | Windows Server | Windows Server Long Term Servicing Channel (LTSC) with containerd and gen 2 |

Note

You can't specify the Windows OS Type during cluster creation since the system node pool in every cluster must be Linux.

### Factors that influence the default node image

The following factors influence the default image AKS chooses for your node pool:

- **OS SKU**: If `--os-sku` is specified, then your default OS changes. For example, if you specify Azure Linux as the OS SKU, then your node image is Azure Linux with containerd.
- **Virtual machine (VM) size**:
    - [Confidential virtual machines (CVM)](use-cvm)
    - [AMR64 virtual machines](create-node-pools)
- **Hypervisor generation**: Each VM size supports Generation 1, [Generation 2](generation-2-vm), or both.
    - If Generation 2 is supported, AKS defaults to using the Generation 2 node image in all OS versions except for Windows Server 2022.
    - If only Generation 1 is supported, AKS defaults to using the Generation 1 node image. Generation 1 isn't supported for Azure Linux OS Guard (preview) or Flatcar Container Linux for AKS (preview).
- **Feature enablement**: There are some features embedded into the node image. If you choose to use any of these features, your default node image changes.
    - [Federal Information Processing Standards (FIPS)](enable-fips-nodes) changes the default node image for all Linux node pools.
    - [Pod Sandboxing](use-pod-sandboxing) changes the default node image for Azure Linux node pools.
    - [Trusted Launch](use-trusted-launch) changes the default node image for all Linux node pools.

Note

Certain features can't be combined in a single node pool. Follow links to the feature documentation to review the limitations.

## Available Linux node images

### Ubuntu node images

The Ubuntu node images are fully validated by AKS and supported by Microsoft, Canonical, and the Ubuntu community. AKS won't retire an Ubuntu version before the end of Canonical's support lifecycle.

| Node image | Use case | Limitations |
| --- | --- | --- |
| **Ubuntu with containerd and Gen 1** | This image is the standard node image for Ubuntu node pools that use a VM size that supports only Generation 1. | Ubuntu 26.04 doesn't support this image. |
| **Ubuntu with containerd and Gen 2** | This is the standard node image for Ubuntu node pools using a VM size that supports Generation 2. If a VM size supports both Generation 1 and Generation 2, this node image is selected. | N/A |
| **Ubuntu with containerd and FIPS** | This node image is a variant of the default node image for customers that enable [Federal Information Processing Standards (FIPS)](enable-fips-nodes). These images support both Generation 1 and Generation 2. | Not yet supported for Ubuntu 24.04+. Can't be combined with Arm64 or CVM. |
| **Ubuntu with containerd and Arm64** | This is a variant of the default node image for customers that use a VM size that supports [Arm64](use-arm64-vms). These images support Generation 2 only. | Can't be combined with FIPS, CVM, or Trusted Launch. |
| **Ubuntu with containerd and CVM** | This is a variant of the default node image for customers that use a [Confidential VM](use-cvm) size. These images support Generation 2 only. | Supported for Ubuntu 20.04 and Ubuntu 24.04. Not supported for Ubuntu 22.04. Can't be combined with FIPS, Arm64, or Trusted Launch. |
| **Ubuntu with containerd and Trusted Launch** | This node image is a variant of the default node image for customers that enable [Trusted Launch](use-trusted-launch). These images support Generation 2 only. | Can't be combined with Arm64 or CVM. |

### Azure Linux node images

The Azure Linux node images are fully validated by AKS and built from source, using a native AKS image.

| Node image | Use case | Limitations |
| --- | --- | --- |
| **Azure Linux with containerd and Gen 1** | This is the standard node image for Azure Linux node pools using a VM size that only supports Generation 1. | N/A |
| **Azure Linux with containerd and Gen 2** | This is the standard node image for Azure Linux node pools using a VM size that supports Generation 2. If a VM size supports both Generation 1 and Generation 2, node image is selected. | N/A |
| **Azure Linux with containerd and FIPS** | This is a variant of the default node image for customers that enable [Federal Information Processing Standards (FIPS)](enable-fips-nodes). These images support both Generation 1 and Generation 2. | Can't be combined with Trusted Launch, or Pod Sandboxing. Azure Linux supports a separate image for FIPS and ARM64. |
| **Azure Linux with containerd and Arm64** | This is a variant of the default node image for customers that use a VM size that supports [Arm64](use-arm64-vms). These images support Generation 2 only. | Can't be combined with Trusted Launch or Pod Sandboxing. Azure Linux supports a separate image for FIPS and ARM64. |
| **Azure Linux with containerd, FIPS, and Arm64** | This is a variant of the default node image for customers that enable [Federal Information Processing Standards (FIPS)](enable-fips-nodes) and use a VM size that supports [Arm64](use-arm64-vms). These images support Generation 2 only. | Can't be combined with Trusted Launch or Pod Sandboxing. |
| **Azure Linux with containerd and Trusted Launch** | This is a variant of the default node image for customers that enable [Trusted Launch](use-trusted-launch). These images support Generation 2 only. | Can't be combined with FIPS, Arm64, or Pod Sandboxing. |
| **Azure Linux with containerd and Pod Sandboxing** | This is a variant of the default node image for customers that enable [Pod Sandboxing](use-pod-sandboxing). These images support Generation 2 only. | Can't be combined with FIPS, Arm64, or Trusted Launch. |

### Azure Linux with OS Guard for AKS (preview) node images

The Azure Linux with OS Guard for AKS node images are fully validated by AKS and built from source, using a native AKS image. Versioning for Azure Linux with OS Guard node images follows the AKS date-based format (for example: 202509.23.0). You can check the node images in the release notes and by running the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command to view the `nodeImageVersion`. For more information, see [Azure Linux with OS Guard for AKS](use-azure-linux-os-guard).

| Node image | Use case | Limitations |
| --- | --- | --- |
| **Azure Linux with OS Guard with containerd, Gen 2, FIPS, and Trusted Launch** | This image is the standard node image for Azure Linux with OS Guard for AKS node pools that use a VM size. If you use a VM size that supports Gen 1 only, you can't use Azure Linux with OS Guard. | N/A |

### Flatcar Container Linux for AKS (preview) node images

The Flatcar Container Linux for AKS node images are fully validated by AKS and supported by Microsoft and the Flatcar community. Versioning for Flatcar Container Linux node images follows the AKS date-based format (for example: 202506.13.0). You can check the node images in the release notes and by using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command to view the `nodeImageVersion`. You can check the Flatcar version number (for example: Flatcar 4344.0.0) in the release notes and by running the `kubectl get nodes` command. For more information, see [Flatcar Container Linux for AKS](flatcar-container-linux-for-aks).

| Node image | Use case | Limitations |
| --- | --- | --- |
| **Flatcar Container Linux with containerd and Gen 2** | This image is the standard node image for Flatcar Container Linux for AKS node pools that use a VM size. If you use a VM size that supports Gen 1 only, you can't use Flatcar OS. | N/A |
| **Flatcar Container Linux with containerd and Arm64** | This is a variant of the default node image for customers that use a VM size that supports [Arm64](use-arm64-vms). These images support Generation 2 only. | N/A |

### Azure Container Linux (ACL) node images

ACL node images are fully validated by AKS and built from Azure Linux packages with Flatcar tooling and image composition principles. For more information, see [Azure Container Linux (ACL) for AKS](azure-container-linux-overview).

| Node image | Use case |
| --- | --- |
| **ACL with containerd and Gen 2, Trusted Launch, and AMD64** | Standard node image for ACL node pools that use Trusted Launch on an AMD64 VM size. Supports Generation 2 only. |
| **ACL with containerd and Gen 2, FIPS, Trusted Launch, and AMD64** | This image is a variant of the standard ACL node image for customers that enable [Federal Information Processing Standards (FIPS)](enable-fips-nodes) and use Trusted Launch on an AMD64 VM size. Supports Generation 2 only. |
| **ACL with containerd and Gen 2, Trusted Launch, and ARM64** | This image is a variant of the standard ACL node image for customers that enable Trusted Launch on an [Arm64](use-arm64-vms) VM size. Supports Generation 2 only. |
| **ACL with containerd and Gen 2, FIPS, Trusted Launch, and ARM64** | This image is a variant of the standard ACL node image for customers that enable [Federal Information Processing Standards (FIPS)](enable-fips-nodes) and use Trusted Launch on an [Arm64](use-arm64-vms) VM size. Supports Generation 2 only. |

## Available Windows Server node images

The Windows Server node images are fully validated by AKS and supported by Microsoft.

### Windows Server Long Term Servicing Channel (LTSC) node images

| Node image | Use case | Limitations |
| --- | --- | --- |
| **Windows Server with containerd and Gen 1** | This image is the standard node image for Windows node pools that use a VM size supporting Generation 1. If a VM size supports both Generation 1 and Generation 2, the process selects this node image when you use Windows Server 2022. | N/A |
| **Windows Server with containerd and Gen 2** | This is the standard node image for Windows node pools using a VM size that supports Generation 2. If a VM size supports both Generation 1 and Generation 2, this node image is selected if using Windows Server 2025. | N/A |

### Windows Server Annual Channel for Containers (preview) node images

| Node image | Use case | Limitations |
| --- | --- | --- |
| **Windows Server with containerd and Gen 1** | This is the standard node image for Windows node pools using a VM size that only supports Generation 1. If a VM size supports both Generation 1 and Generation 2, this node image is selected. | N/A |
| **Windows Server with containerd and Gen 2** | This is the standard node image for Windows node pools using a VM size that supports Generation 2. | N/A |