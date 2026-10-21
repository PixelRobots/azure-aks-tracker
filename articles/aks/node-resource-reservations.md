---
layout: Conceptual
title: Node resource reservations in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-resource-reservations
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
description: Learn about node resource reservations in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.subservice: aks-nodes
ms.author: schaffererin
author: schaffererin
ms.date: 2026-10-06T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 05c690bd-2407-cb12-e0a8-02e80f0d767d
document_version_independent_id: 29842f1d-1a29-3867-7c80-77ec1c77b922
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-resource-reservations.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/node-resource-reservations
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-resource-reservations.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: d8753340-fc73-ad45-3e4b-767bb99e76e5
---

# Node resource reservations in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn about node resource reservations in Azure Kubernetes Service (AKS).

## Resource reservations

AKS uses node resources to help the nodes function as part of the cluster. This usage can cause a discrepancy between the node's total resources and the allocatable resources in AKS.

AKS reserves two types of resources, **CPU** and **memory**, on each node to maintain node performance and functionality. As a node grows larger in resources, the resource reservations also grow due to a higher need for management of user-deployed pods.

### CPU reservations

Reserved CPU is dependent on node type and cluster configuration, which might result in less allocatable CPU due to running extra features. The following table shows CPU reservations in millicores:

| CPU cores on host | 1 core | 2 cores | 4 cores | 8 cores | 16 cores | 32 cores | 64 cores |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Kube-reserved CPU (millicores) | 60 | 100 | 140 | 180 | 260 | 420 | 740 |

### Memory reservations

In AKS, reserved memory consists of the sum of two values:

**AKS 1.29 and later**

- **`kubelet` daemon** has the *memory.available &lt; 100 Mi* eviction rule by default. This rule ensures that a node has at least 100 Mi allocatable at all times. When a host is below that available memory threshold, the `kubelet` triggers the termination of one of the running pods and frees up memory on the host machine.
- **A rate of memory reservations** set according to the lesser value of: *20 MB \* Max Pods supported on the Node + 50 MB* or *25% of the total system memory resources*.

    **Examples**:

    - If the virtual machine (VM) provides 8 GB of memory and the node supports up to 30 pods, AKS reserves *20 MB \* 30 Max Pods + 50 MB = 650 MB* for kube-reserved. `Allocatable space = 8 GB - 0.65 GB (kube-reserved) - 0.1 GB (eviction threshold) = 7.25 GB or 90.625% allocatable.`
    - If the VM provides 4 GB of memory and the node supports up to 70 pods, AKS reserves *25% \* 4 GB = 1000 MB* for kube-reserved, as this is less than *20 MB \* 70 Max Pods + 50 MB = 1450 MB*.

    For more information, see [Configure maximum pods per node in an AKS cluster](concepts-network-ip-address-planning#maximum-pods-per-node).

Note

To apply hardened kube-reserved, system-reserved, and eviction defaults on Linux node pools, register the `CustomNodeConfigPreview` feature flag and enable Node Hardening on your cluster by using the `--enable-node-hardening` parameter. To customize `kubeReserved` CPU and memory values or eviction thresholds, use the preview custom node configuration settings. For more information, see [Node Hardening (preview) in AKS](node-hardening).

**AKS versions prior to 1.29**

- **`kubelet` daemon** has the *memory.available &lt; 750 Mi* eviction rule by default. This rule ensures that a node has at least 750 Mi allocatable at all times. When a host is below that available memory threshold, the `kubelet` triggers the termination of one of the running pods and free up memory on the host machine.
- **A regressive rate of memory reservations** for the kubelet daemon to properly function (*kube-reserved*).
    - 25% of the first 4 GB of memory
    - 20% of the next 4 GB of memory (up to 8 GB)
    - 10% of the next 8 GB of memory (up to 16 GB)
    - 6% of the next 112 GB of memory (up to 128 GB)
    - 2% of any memory more than 128 GB

Note

AKS reserves an extra 2 GB for system processes in Windows nodes that isn't part of the calculated memory.

Memory and CPU allocation rules are designed to:

- Keep agent nodes healthy, including some hosting system pods critical to cluster health.
- Cause the node to report less allocatable memory and CPU than it would report if it weren't part of a Kubernetes cluster.

For example, if a node offers 7 GB, it reports 34% of memory not allocatable including the 750 Mi hard eviction threshold.

`0.75 + (0.25*4) + (0.20*3) = 0.75 GB + 1 GB + 0.6 GB = 2.35 GB / 7 GB = 33.57% reserved`

In addition to reservations for Kubernetes itself, the underlying node OS also reserves an amount of CPU and memory resources to maintain OS functions.

For associated best practices, see [Best practices for basic scheduler features in AKS](operator-best-practices-scheduler).