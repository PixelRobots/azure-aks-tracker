---
layout: Conceptual
title: Windows Container Considerations in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/windows-vs-linux-containers
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
description: See the Windows container considerations with Azure Kubernetes Service (AKS).
ms.topic: overview
ms.custom: linux-related-content, aks-windows
ms.date: 2025-07-07T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: fb3894df-ca95-0134-d47a-62980f9786b2
document_version_independent_id: dd6bd8eb-2dbd-6e3d-77ba-29bf1118f0e0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/windows-vs-linux-containers.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/windows-vs-linux-containers
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/windows-vs-linux-containers.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 8fed20df-18fb-63fc-dc9e-cfcd9b75c6a9
---

# Windows Container Considerations in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

When you create deployments that use Windows Server containers on Azure Kubernetes Service (AKS), there are a few differences relative to Linux deployments you should keep in mind. For a detailed comparison of the differences between Windows and Linux in upstream Kubernetes, see [Windows containers in Kubernetes](https://kubernetes.io/docs/concepts/windows/intro/).

Some of the major differences include:

- **Identity**: Windows Server uses a larger binary security identifier (SID) that's stored in the Windows Security Access Manager (SAM) database. This database isn't shared between the host and containers or between containers.
- **File permissions**: Windows Server uses an access control list based on SIDs rather than a bitmask of permissions and UID+GID.
- **File paths**: The convention on Windows Server is to use \ instead of /. In pod specs that mount volumes, specify the path correctly for Windows Server containers. For example, rather than a mount point of */mnt/volume* in a Linux container, specify a drive letter and location such as */K/Volume* to mount as the *K:* drive.

Important

Starting on March 01, 2026, Azure Kubernetes Service (AKS) no longer supports Windows Server 2019 node pools. Node pools running Kubernetes version 1.33+ can't use Windows Server 2019. Starting on April 01, 2027, AKS will remove all existing node images for Windows Server 2019, meaning that scaling operations will fail. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4091) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=aks-will-stop-support-for-windows-server-2019-on-march-1-2026). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Starting on June 30, 2028, Azure Kubernetes Service (AKS) no longer supports Windows Server 2022 node pools. Windows Server 2022 isn't supported in Kubernetes version 1.37 and later. Starting on June 30, 2029, AKS will remove all existing node images for Windows Server 2022, meaning that scaling operations will fail. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4168) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=ws2022-retirement-aks). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Starting on **May 15, 2026**, AKS no longer supports Windows Server Annual Channel (Preview). AKS will no longer produce new Windows Server Annual Channel node images or provide security patches. You won't be able to create new node pools with Windows Server Annual Channel. On **May 15, 2027**, AKS will remove all existing Windows Server Annual Channel node images, which will cause scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, we recommend migrating to the [Long Term Servicing Channel (LTSC)](/en-us/azure/aks/upgrade-windows-os).

- Windows Server Annual Channel uses Windows Server 2022 base images, which will run on Windows Server 2022 and Windows Server 2025.
- If you're using [Host Process Containers (HPC)](use-windows-hpc) or running other privileged containers for administration purposes, you need to do extra testing.

For more information on this retirement, see the [Retirement GitHub issue](https://aka.ms/aks/windows-annual-channel-retirement). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

This article covers important considerations to keep in mind when using Windows containers instead of Linux containers in Kubernetes. For an in-depth comparison of Windows and Linux containers, see [Comparison with Linux](https://kubernetes.io/docs/concepts/windows/intro/#compatibility-linux-similarities).

## Considerations

| Feature | Windows considerations |
| --- | --- |
| [Cluster creation](quotas-skus-regions#cluster-configuration-presets-in-the-azure-portal) | • The first system node pool *must* be Linux. • The maximum number of nodes per cluster is 5000. • The Windows Server node pool name has a limit of six characters. |
| [Privileged containers](use-windows-hpc#limitations) | Not supported. The equivalent is **HostProcess Containers (HPC) containers**. |
| [HPC containers](use-windows-hpc#limitations) | • HostProcess containers are the Windows alternative to Linux privileged containers. For more information, see [Create a Windows HostProcess pod](https://kubernetes.io/docs/tasks/configure-pod-container/create-hostprocess-pod/). |
| [Azure Network Policy Manager (Azure)](use-network-policies#overview-of-network-policy) | Azure Network Policy Manager doesn't support: • Named ports • SCTP protocol • Negative match labels or namespace selectors (all labels except "debug=true") • "except" CIDR blocks (a CIDR with exceptions) • Windows Server 2019 |
| [Node upgrade](manage-node-pools#upgrade-a-single-node-pool) | Windows Server nodes on AKS don't automatically apply Windows updates. Instead, you perform a node pool upgrade or [node image upgrade](node-image-upgrade). These upgrades deploy new nodes with the latest Window Server 2019 and Windows Server 2022 base node image and security patches. |
| [AKS Image Cleaner](image-cleaner#limitations) | Not supported. |
| [BYOCNI](use-byo-cni) | Not supported. |
| [Open Service Mesh](open-service-mesh-about) | Not supported. |
| [GPU](use-windows-gpu) | Supported in preview. |
| [Multi-instance GPU](gpu-multi-instance) | Not supported. |
| [Generation 2 VMs](generation-2-vms) | Supported. Default in Windows Server 2025. |
| [Custom node config](custom-node-configuration) | • Custom node config has two configurations: • [kubelet](custom-node-configuration#kubelet-configuration): Supported. • OS config: Not supported. |