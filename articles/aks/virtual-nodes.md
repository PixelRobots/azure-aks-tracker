---
layout: Conceptual
title: Use virtual nodes with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/virtual-nodes
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
description: How to create and configure an Azure Kubernetes Service (AKS) cluster to use virtual nodes.
ms.topic: how-to
ms.date: 2023-11-06T00:00:00.0000000Z
ms.subservice: aks-nodes
author: schaffererin
ms.author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: 9861f977-2ece-8526-2726-7e81789b814f
document_version_independent_id: e2975b46-0121-62fa-756f-5bed2d3b6c21
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/virtual-nodes.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/virtual-nodes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/virtual-nodes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/dcc344b3-3794-4849-9766-7ea55b09218c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/54120bfe-7774-429b-9674-ff285a2c9445
platformId: 77a26d40-d9c3-93b5-0eae-8132470c9958
---

# Use virtual nodes with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Note

[Virtual Nodes v2 (preview)](virtual-nodes-v2) is the latest serverless experience for AKS. It's delivered as a cluster extension and brings new capabilities to virtual nodes. If you plan to deploy workloads on virtual nodes, start with [Virtual Nodes v2 (preview)](virtual-nodes-v2).

To rapidly scale application workloads in an AKS cluster, you can use virtual nodes. With virtual nodes, you have quick provisioning of pods, and only pay per second for their execution time. You don't need to wait for Kubernetes cluster autoscaler to deploy VM compute nodes to run more pods. Virtual nodes are only supported with Linux pods and nodes.

The virtual nodes add-on for AKS is based on the open source project [Virtual Kubelet](https://github.com/virtual-kubelet/virtual-kubelet).

This article gives you an overview of the region availability and networking requirements for using virtual nodes, and the known limitations.

## Regional availability

All regions, where ACI supports VNET SKUs, are supported for virtual nodes deployments. For more information, see [Resource availability for Azure Container Instances in Azure regions](/en-us/azure/container-instances/container-instances-region-availability).

For available CPU and memory SKUs in each region, review [Azure Container Instances Resource availability for Azure Container Instances in Azure regions - Linux container groups](/en-us/azure/container-instances/container-instances-region-availability#linux-container-groups)

## Network requirements

Virtual nodes enable network communication between pods that run in Azure Container Instances (ACI) and the AKS cluster. To support this communication, a virtual network subnet is created and delegated permissions are assigned. Virtual nodes only work with AKS clusters created using *advanced* networking (Azure CNI). By default, AKS clusters are created with *basic* networking (kubenet).

Pods running in Azure Container Instances (ACI) need access to the AKS API server endpoint, in order to configure networking.

## Limitations

Virtual nodes functionality is heavily dependent on ACI's feature set. In addition to the [quotas and limits for Azure Container Instances](/en-us/azure/container-instances/container-instances-quotas), the following are scenarios not supported with virtual nodes or are deployment considerations:

- Using service principal to pull ACR images. [Workaround](https://github.com/virtual-kubelet/azure-aci/blob/master/README.md#private-registry) is to use [Kubernetes secrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line).

    Important

    Secrets built according to the Kubernetes documentation (for standard nodes) will not work with virtual nodes. A specific server format is required, as detailed in [`ImageRegistryCredential`- Azure Container Instances](/en-us/azure/templates/microsoft.containerinstance/2022-10-01-preview/containergroups?pivots=deployment-language-bicep#imageregistrycredential).
- [Virtual Network Limitations](/en-us/azure/container-instances/container-instances-vnet) including VNet peering, Kubernetes network policies, and outbound traffic to the internet with network security groups.
- Init containers.
- [Host aliases](https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/).
- [Arguments](/en-us/azure/container-instances/container-instances-exec#restrictions) for exec in ACI.
- [DaemonSets](concepts-clusters-workloads#statefulsets-and-daemonsets) won't deploy pods to the virtual nodes.
- To schedule Windows Server containers to ACI, you need to manually install the open source [Virtual Kubelet ACI](https://github.com/virtual-kubelet/azure-aci) provider.
- Virtual nodes require AKS clusters with Azure CNI networking.
- Using API server authorized ip ranges for AKS.
- Volume mounting Azure Files share support [General-purpose V2](/en-us/azure/storage/common/storage-account-overview#types-of-storage-accounts) and [General-purpose V1](/en-us/azure/storage/common/storage-account-overview#types-of-storage-accounts). However, virtual nodes currently don't support [Persistent Volumes](concepts-storage#persistent-volumes) and [Persistent Volume Claims](concepts-storage#persistent-volume-claims). Follow the instructions for mounting [a volume with Azure Files share as an inline volume](azure-csi-files-storage-provision#mount-file-share-as-an-inline-volume).
- Using IPv6 isn't supported.
- Attaching managed identities to virtual node is not supported.
- Virtual nodes don't support the [Container hooks](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/) feature.