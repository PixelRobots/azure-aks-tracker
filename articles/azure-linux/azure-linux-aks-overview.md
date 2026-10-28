---
layout: Conceptual
title: Overview of the Azure Linux Container Host for Azure Kubernetes Service (AKS) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/azure-linux-aks-overview
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
description: Learn about the Azure Linux Container Host, a lightweight and secure operating system image optimized for running container workloads on Azure Kubernetes Service (AKS), including its key benefits and supported GPU VM sizes.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: overview
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 6b197b52-57af-2594-ce7a-9eb245f600bf
document_version_independent_id: 1519828c-1b31-3363-a9d6-eae0179668ef
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/azure-linux-aks-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/azure-linux-aks-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/azure-linux-aks-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: caf05e75-e45e-253b-37aa-94e9a708d3f7
---

# Overview of the Azure Linux Container Host for Azure Kubernetes Service (AKS) | Microsoft Learn

The Azure Linux Container Host is an operating system (OS) image optimized for running container workloads on [Azure Kubernetes Service (AKS)](/en-us/azure/aks/intro-kubernetes).

The Azure Linux Container Host is lightweight, containing only the packages needed to run container workloads. The container host is hardened based on significant validation tests and internal usage and is compatible with Azure agents. It provides reliability and consistency from cloud to edge across AKS, Azure Local, and Azure Arc. You can deploy Azure Linux node pools in a new cluster, add Azure Linux node pools to your existing clusters, or migrate your existing nodes to Azure Linux nodes.

This article provides an overview of the Azure Linux Container Host, its key benefits, and the GPU VM sizes it supports when running container workloads on AKS.

## Key benefits

The Azure Linux Container Host offers the following key benefits:

| Benefit | Description |
| --- | --- |
| Small and lightweight | • Includes only the necessary set of packages needed to run container workloads, consuming limited disk and memory resources and producing faster cluster operations on AKS.  • Has roughly 400 packages, taking up the least disk space by up to *five GB* on AKS. |
| Secure supply chain | • The Linux and AKS teams at Microsoft build, sign, and validate the [Azure Linux Container Host packages](https://packages.microsoft.com/azurelinux/3.0/prod/) from source, and host packages and sources in Microsoft-owned and secured platforms.  • Each package runs through a full set of unit tests and end-to-end testing on the existing image to prevent regressions before release.  • Azure Linux focuses on stability, backporting fixes in core components like the kernel or openssl and limiting substantial changes or version bumps to major release boundaries to prevent customer outages. |
| Secure by default | • Follows secure-by-default principles, including using a hardened Linux kernel with Azure cloud optimizations and flags tuned for Azure.  • Provides a reduced attack surface and eliminates patching and maintenance of unnecessary packages.  • Microsoft monitors the Common Vulnerabilities and Exposures (CVE) database and releases security patches monthly and critical updates within days if necessary.  • Azure Linux passes all the [CIS Level 1 benchmarks](/en-us/azure/aks/cis-azure-linux-v3), making it the only Linux distribution on AKS that does so. |
| Maintains compatibility with existing workloads | • All existing and future AKS extensions, add-ons, and open-source projects on AKS support Azure Linux. Extension support includes support for runtime components like Dapr, IaC tools like Terraform, and monitoring solutions like Dynatrace.  • Azure Linux ships with `containerd` as its container runtime and the upstream Linux kernel, which enables existing containers based on Linux images (like Alpine) to work seamlessly on Azure Linux. |

## Supported GPU virtual machine (VM) sizes

Azure Linux supports all the NVIDIA GPU VM sizes used on AKS. To get started deploying NVIDIA GPU workloads on AKS with Azure Linux, see [Use GPUs for compute-intensive workloads on Azure Kubernetes Service (AKS)](/en-us/azure/aks/use-nvidia-gpu).