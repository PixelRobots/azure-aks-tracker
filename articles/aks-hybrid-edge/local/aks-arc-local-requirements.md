---
layout: Conceptual
title: System requirements for AKS on Azure Local | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/aks-arc-local-requirements
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn about system storage requirements for Azure Kubernetes Service (AKS) for Azure Local.
ms.topic: concept-article
author: Xelu86
ms.author: alalve
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: local
locale: en-us
document_id: 651aa831-8582-ce49-587a-83017501bd69
document_version_independent_id: bef1cac9-6af2-6963-61f1-fd4fdaaca6f5
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/aks-arc-local-requirements.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/local/aks-arc-local-requirements
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/aks-arc-local-requirements.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
platformId: 3fe75f96-9a3a-72d5-890b-5be142055067
---

# System requirements for AKS on Azure Local | Microsoft Learn

With Azure Kubernetes Service (AKS) Arc on Azure Local, you can deploy and manage Kubernetes clusters on your own infrastructure with integrated Azure Arc control. Cluster creation and lifecycle management are supported via familiar Azure tools such as the portal, Azure CLI, and Resource Manager templates. These clusters are automatically onboarded to Azure Arc, enabling centralized governance and secure access through Microsoft Entra ID.

## System requirements

Microsoft and trusted hardware partners preconfigure and validate certified Azure Local platforms to deliver dependable AKS deployments. These platforms feature the following essential infrastructure components:

- **Hardware:** Enterprise-grade servers and devices designed for high availability and performance.
- **Networking:** Integrated network fabric supporting redundancy, security, and scalable connectivity.
- **Storage:** Robust storage solutions optimized for Kubernetes workloads and data durability.
- **Operating systems:** Supported and secure OS images tailored for AKS compatibility.
- **Management tools:** Built-in monitoring, automation, and lifecycle management utilities for streamlined operations.

The platform delivers out-of-the-box Azure Arc integration, allowing administrators to focus on workload operations while underlying maintenance and optimizations are handled automatically. While the hardware provides baseline requirements, the cluster and workload sizing should be tailored to your specific environment needs.

## Storage requirements

Storage sizing requirements for AKS on Azure Local depend primarily on hardware configuration, expected AKS workloads, and overall cluster sizing. While certified Azure Local platforms provide built-in baseline hardware, it’s important to assess your storage needs according to the types and scale of applications you plan to run.

- **Single storage path:** Ensure at least one storage path is configured in your Azure Local environment. To learn more, see [Create storage path for Azure Local](/en-us/azure/azure-local/manage/create-storage-path).
- **Storage per AKS cluster:** For a standard AKS cluster with a single control plane, such as a virtual machine (VM) with one node pool and one control plane running Azure on Linux:

    - **Minimum required:** A total of 10 GB of storage per node.
    - **Maximum usage:** Up to 200 GB total, depending on the number of VMs and the workloads deployed.
- **Workload usage recommendations:**

    - Use the designated storage volume exclusively for Kubernetes workloads.
    - Avoid storing unrelated files or data on these storage paths.
    - Store backup files and related data in a different location to prevent potential storage exhaustion issues.