---
layout: Conceptual
title: Multi-instance GPU (MIG) partitioning strategies in AKS - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/multi-instance-gpu-overview
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
description: Understand single and mixed multi-instance GPU strategies in AKS, compare workload resource requests, and choose a partition layout for your applications.
author: sdesai345
ms.author: sachidesai
ms.topic: overview
ms.date: 2026-11-10T00:00:00.0000000Z
ms.subservice: aks-nodes
ai-usage: ai-assisted
locale: en-us
document_id: 99fafa51-03b9-766a-07d3-dd01ffd35313
document_version_independent_id: 8384e4a4-6c39-da76-c656-1eaf4ef97be9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/multi-instance-gpu-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/multi-instance-gpu-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/multi-instance-gpu-overview.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f3e14dd4-3b72-445a-a3c6-dc32ea965a1a
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/2263a632-bbca-49e8-acf1-589e723ad155
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 82a53e01-5f40-6da7-1529-17885f828acc
---

# Multi-instance GPU (MIG) partitioning strategies in AKS - Azure Kubernetes Service | Microsoft Learn

Teams running GPU workloads in production often need to balance utilization with memory, throughput, and latency requirements. GPU types have different capacities, and certain workloads don't require all the resources offered by a physical GPU. Assigning a whole GPU to each workload can leave capacity idle, while choosing a smaller GPU size might not meet the job's requirements. These mismatches make it harder to use available capacity efficiently as demand changes.

Multi-instance GPU (MIG) divides a [compatible NVIDIA GPU](https://www.nvidia.com/en-us/technologies/multi-instance-gpu/) into partitions with dedicated compute and memory resources. In an AKS cluster, workloads request these partitions through Kubernetes extended resources. Multiple workloads can share a physical GPU, with partition sizes matched to their requirements instead of each workload needing an entire GPU.

MIG supports two strategies. With the single strategy, every partition in a node pool uses the same profile, and the node advertises each partition as a standard GPU resource, such as `nvidia.com/gpu`. With the mixed strategy, a node pool can combine profiles, and the node advertises each profile under its own resource name, such as `nvidia.com/mig-1g.5gb`.

Choose a single strategy when multiple jobs need the same partition size. Choose a mixed strategy when workloads need different sizes. Matching partitions to workload requirements can improve GPU utilization, but the right layout depends on measured memory and throughput requirements.

## Understand partitions and Kubernetes resources

A *partition* is a hardware allocation of compute and memory within a GPU. A *profile* defines a partition's size, such as `1g.5gb`. A *layout* is the set of profiles configured on a GPU. A *resource name* is the Kubernetes extended resource that a node advertises for scheduling, and workloads request it by name and count. With MIG, a request for one GPU resource can represent one partition rather than an entire physical GPU. Partition memory depends on the GPU model, so inspect the resources your nodes advertise before you write workload manifests.

## Compare single and mixed strategies

The following table compares the single strategy and mixed strategy workflows.

| Consideration | Single strategy | Mixed strategy with mixed layouts |
| --- | --- | --- |
| **Partition sizes** | One profile creates a uniform layout. | A compatible list creates partitions of different sizes, or repeated partitions of the same size. |
| **What one requested GPU resource represents** | One partition of the node pool's configured profile. | One partition of the requested MIG profile. |
| **Typical fit** | Similar workloads with comparable GPU requirements. | Workloads with different compute and memory requirements. |
| **Capacity planning** | Count available partitions of the uniform size. | Count available partitions separately for each resource type. |
| **Kubernetes resource name** | A shared name, such as `nvidia.com/gpu`. | One name per profile, such as `nvidia.com/mig-1g.5gb`. |
| **Configuration guide** | [Configure a single-strategy MIG node pool](gpu-multi-instance) | [Configure a mixed-strategy MIG node pool (preview)](mixed-gpu-multi-instance) |

## Supported GPU VM sizes

The following table lists Azure VM sizes that support multi-instance GPU partitioning.

| VM size | VM series | GPU |
| --- | --- | --- |
| `Standard_NC24ads_A100_v4` | [NC A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nca100v4-series) | A100 |
| `Standard_NC48ads_A100_v4` | [NC A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nca100v4-series) | A100 |
| `Standard_NC96ads_A100_v4` | [NC A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nca100v4-series) | A100 |
| `Standard_ND96asr_v4` | [ND A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndasra100v4-series) | A100 |
| `Standard_ND112asr_A100_v4` | [ND A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndasra100v4-series) | A100 |
| `Standard_ND120asr_A100_v4` | [ND A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndasra100v4-series) | A100 |
| `Standard_ND96amsr_A100_v4` | [NDm A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndma100v4-series) | A100 |
| `Standard_ND112amsr_A100_v4` | [NDm A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndma100v4-series) | A100 |
| `Standard_ND120amsr_A100_v4` | [NDm A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndma100v4-series) | A100 |
| `Standard_ND96ams_A100_v4` | [NDm A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndma100v4-series) | A100 |
| `Standard_ND96ams_v4` | [NDm A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndma100v4-series) | A100 |
| `Standard_ND100isr_H100_v5` | [ND H100 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndh100v5-series) | H100 |
| `Standard_ND100is_H100_v5` | [ND H100 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndh100v5-series) | H100 |
| `Standard_ND50s_H100_v5` | [ND H100 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndh100v5-series) | H100 |
| `Standard_ND96isr_H100_v5` | [ND H100 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndh100v5-series) | H100 |
| `Standard_ND96is_H100_v5` | [ND H100 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndh100v5-series) | H100 |
| `Standard_ND92isr_H100_v5` | [ND H100 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndh100v5-series) | H100 |
| `Standard_ND92is_H100_v5` | [ND H100 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndh100v5-series) | H100 |
| `Standard_ND46s_H100_v5` | [ND H100 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndh100v5-series) | H100 |
| `Standard_NC40ads_H100_v5` | [NC H100 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ncadsh100v5-series) | H100 |
| `Standard_NC80adis_H100_v5` | [NC H100 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ncadsh100v5-series) | H100 |

Note

GPU-enabled VMs contain specialized hardware subject to higher pricing and region availability. For more information, see the [pricing](https://azure.microsoft.com/pricing/) tool and [region availability](https://azure.microsoft.com/global-infrastructure/services/).

### Use single strategy MIG for consistent resource needs

The single strategy suits workloads with similar compute and memory requirements. Uniform partitions let teams share GPUs while keeping a common GPU resource name in their Kubernetes manifests. This consistency can simplify allocation when a node pool serves a consistent workload class.

The tradeoff of the single strategy is that the resource name doesn't describe partition size. Use a pool selector or node affinity to target the intended capacity. The resource name alone doesn't distinguish a MIG partition from a full GPU advertised by another MIG node pool, or distinguish partition sizes in different single-strategy pools. Without placement controls, a pod might receive a device that doesn't match the application's sizing assumptions.

If workload requirements vary substantially, a uniform layout can leave larger partitions underused or make smaller partitions unsuitable for some pods.

### Use mixed strategy MIG for different resource needs

Mixed strategy lets teams allocate different partition sizes on the same GPU. This approach helps when a shared pool serves workloads with different requirements and allocating the same size to every pod would waste capacity or prevent larger GPU workloads from running.

With the mixed strategy, each partition type has a distinct Kubernetes resource name. Workload manifests request the type they need, so size selection is explicit rather than relying only on a pool's uniform configuration. Teams must maintain those requests as part of their application sizing and deployment configuration.

The tradeoff of the mixed strategy is capacity fragmentation: a pod can remain pending even when other partition types are free. Kubernetes doesn't combine smaller partitions or automatically resize the layout to satisfy a request. Adding nodes with the same layout increases capacity for its configured types, not for types missing from the layout. Plan the mix around simultaneous demand for each size, not only total GPU utilization.

## How AKS configures the mixed strategy for MIG

In AKS, the mixed strategy configures both the partition layout and the managed device plugin. AKS handles the Kubernetes-facing components, while you choose a supported layout and size your workload requests. Changing a layout requires a replacement node pool and workload migration.

## Choose a strategy for your workloads

- Benchmark representative GPU workloads and select a partition with enough memory and compute capacity to meet your requirements.
- Use the single strategy for workloads that consistently need the same size. Use mixed layouts when simultaneous GPU resource demand includes multiple sizes.
- Budget capacity by resource type. Spare GPU memory or unused partitions of another type don't guarantee that a pod can schedule.
- Check host CPU and memory capacity as well as GPU partition (MIG doesn't remove other scheduling constraints).
- Keep workloads requiring full GPUs on separate unpartitioned pools, and validate distributed workloads against GPU-specific MIG capabilities.
- Plan layout changes as workload migrations to replacement pools, with quota for overlapping pools and application disruption controls.