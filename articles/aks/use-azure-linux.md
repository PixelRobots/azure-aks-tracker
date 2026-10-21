---
layout: Conceptual
title: Use the Azure Linux Container Host on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-azure-linux
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
description: Learn how Azure Linux is used on Azure Kubernetes Service (AKS), including how it fits into AKS Automatic and how to use it with AKS Standard clusters.
ms.topic: how-to
ms.custom: build-2023, linux-related-content
ms.date: 2026-07-06T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 2687cf7f-907d-e3da-c743-4063cb691d4c
document_version_independent_id: d011fa21-a09e-790e-ca66-5e3175906eae
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-azure-linux.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/use-azure-linux
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-azure-linux.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: c7431039-255f-c1ea-ece3-5abdb754882a
---

# Use the Azure Linux Container Host on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic ✔️ AKS Standard

The Azure Linux container host for AKS is an open-source Linux distribution created by Microsoft. It's generally available as a container host on Azure Kubernetes Service (AKS). You can deploy Azure Linux node pools in a new cluster, add Azure Linux node pools to your existing Ubuntu clusters, or migrate your Ubuntu nodes to Azure Linux nodes. To learn more about Azure Linux, see the [Azure Linux documentation](/en-us/azure/azure-linux/intro-azure-linux).

For most production workloads, AKS Automatic is the recommended production-ready default for AKS. In AKS Automatic, Azure Linux is preconfigured as the default operating system (OS) for the system node pool. This configuration means Azure Linux is part of the managed, production-ready default experience in AKS Automatic, rather than a separate decision you need to make for cluster system components.

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Why use Azure Linux

The Azure Linux container host on AKS uses a native AKS image that provides one place to do all Linux development. Every package is built from source and validated, ensuring your services run on proven components. Azure Linux is lightweight, only including the necessary set of packages needed to run container workloads. Azure Linux provides a reduced attack surface and eliminates patching and maintenance of unnecessary packages. At the base layer, it has a Microsoft hardened kernel tuned for Azure. Learn more about the [key capabilities of Azure Linux](/en-us/azure/azure-linux/intro-azure-linux#azure-linux-container-host-key-benefits).

Azure Linux is also the default OS for the system node pool in AKS Automatic. This default supports the AKS Automatic goal of providing a production-ready cluster configuration with preconfigured platform choices for reliability, security, and reduced operational overhead.

## Azure Linux in AKS Automatic

AKS Automatic is the recommended production-ready default for most AKS workloads. In AKS Automatic:

- Azure Linux is preconfigured as the default OS for the system node pool.
- AKS manages core cluster setup and platform defaults for you.
- Azure Linux is part of the built-in production-oriented experience, alongside other preconfigured security, scaling, and operations defaults.

If you want a managed AKS experience with production-ready defaults, start with AKS Automatic. To learn more, see [What is Azure Kubernetes Service (AKS) Automatic?](intro-aks-automatic)

## Deployment options for Azure Linux on AKS

How you use Azure Linux depends on whether you're using AKS Automatic or AKS Standard.

### AKS Automatic

In AKS Automatic, the system node pool uses Azure Linux by default. If you're creating a new production workload and want the recommended production-ready default experience for AKS, start with AKS Automatic.

To get started, see:

- [What is Azure Kubernetes Service (AKS) Automatic?](intro-aks-automatic)
- [Create an AKS Automatic cluster](automatic/quick-automatic-managed-network)

### AKS Standard

In AKS Standard, you can choose Azure Linux as the node OS option based on your cluster and workload requirements.

To get started using Azure Linux with AKS Standard, see:

- [Creating a cluster with Azure Linux](/en-us/azure/azure-linux/quickstart-azure-cli)
- [How to upgrade Azure Linux clusters](/en-us/azure/azure-linux/tutorial-azure-linux-upgrade)
- [Add an Azure Linux node pool to your existing cluster](create-node-pools#create-an-aks-cluster-with-a-single-node-pool-using-the-azure-cli)
- [Ubuntu to Azure Linux migration](/en-us/azure/azure-linux/tutorial-azure-linux-migration)
- [Azure Linux supported GPU SKUs](/en-us/azure/azure-linux/intro-azure-linux#azure-linux-container-host-supported-gpu-skus)

## Considerations

When deciding how to use Azure Linux in AKS, keep the following points in mind:

- For new production workloads, AKS Automatic is the recommended production-ready default for most AKS scenarios.
- In AKS Automatic, the system node pool is preconfigured to use Azure Linux.
- In AKS Standard, you can explicitly choose Azure Linux for new clusters, added node pools, or migration scenarios.
- Regional availability for Azure Linux follows AKS regional availability.

## Regional availability

The Azure Linux container host is available for use in the same regions as AKS.