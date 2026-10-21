---
layout: Conceptual
title: GPU observability best practices for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/best-practices-gpu-observability
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
description: This article provides insights into monitoring correlated GPU metrics to help improve long term GPU node utilization and performance on AKS.
ms.topic: best-practice
ms.date: 2026-05-01T00:00:00.0000000Z
author: sachidesai
ms.author: sachidesai
ai-usage: ai-assisted
locale: en-us
document_id: 8d4c2ecc-5b1e-e427-b171-bcdc56f8136a
document_version_independent_id: c01ff038-135f-6080-f437-6d69739b6deb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/best-practices-gpu-observability.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/best-practices-gpu-observability
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/best-practices-gpu-observability.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: f198993f-2071-edf5-7669-a0eb55a8b99d
---

# GPU observability best practices for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article provides best practices for monitoring and interpreting GPU signals on Azure Kubernetes Service (AKS). Instead of looking at NVIDIA GPU metrics in isolation, you correlate signals across utilization, memory, and workload context to improve long-term performance and node efficiency.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Understand GPU utilization versus saturation

Don't treat the NVIDIA DCGM metric `DCGM_FI_DEV_GPU_UTIL` as a direct efficiency score. `DCGM_FI_DEV_GPU_UTIL` only indicates how often kernels are active, so it doesn't tell you whether the workload is compute-efficient. You get more accurate guidance by correlating utilization signals instead of reading them independently. Compare `DCGM_FI_DEV_GPU_UTIL` with `DCGM_FI_PROF_SM_ACTIVE`, and then compare `DCGM_FI_PROF_SM_ACTIVE` with `DCGM_FI_PROF_DRAM_ACTIVE` to identify whether your bottleneck is compute, memory, or launch and synchronization overhead.

High `DCGM_FI_DEV_GPU_UTIL` with low `DCGM_FI_PROF_SM_ACTIVE` often points to launch overhead, synchronization stalls, or memory contention. High `DCGM_FI_PROF_SM_ACTIVE` with low `DCGM_FI_PROF_DRAM_ACTIVE` is more consistent with compute-bound behavior. Higher `DCGM_FI_PROF_DRAM_ACTIVE` with lower `DCGM_FI_PROF_SM_ACTIVE` usually points to memory-bound execution.

Note

`DCGM_FI_PROF_SM_ACTIVE` and `DCGM_FI_PROF_DRAM_ACTIVE` are DCGM profiling fields and may not appear by default for all NVIDIA GPU architecture types offered in Azure Virtual Machine (VM) sizes.

This correlation-first approach helps you avoid scaling out when the root issue might be kernel efficiency or memory access patterns. For detailed metric semantics, see the [NVIDIA DCGM user guide](https://docs.nvidia.com/datacenter/dcgm/latest/user-guide/index.html).

## Use memory pressure as a primary scheduling signal

If memory repeatedly approaches out-of-memory thresholds, treat that pattern as an early indicator of instability. Kubernetes has no native GPU-memory pressure signal, so VRAM exhaustion typically surfaces only as container OOM kills and pod disruption, often well after DCGM telemetry shows the trend.

## Automate node lifecycle actions from GPU health signals

This practice is especially important for long-lived AKS GPU node pools where host aging can vary across nodes.

## Align observability signals with scaling decisions

For vertical scaling, create a new node pool on a different Azure GPU-enabled VM SKU and migrate workloads when power or thermal constraints cap throughput, for example when `DCGM_FI_DEV_POWER_USAGE` stays near limit while `DCGM_FI_PROF_SM_ACTIVE` remains flat despite demand.

## Separate MIG and non-MIG observability policies

When MIG is enabled, the scope of each metric shifts, so interpret the signals differently.

## Publish cost-aware GPU efficiency metrics

Optimize for cost visibility, not only performance. A high-value derived metric for AKS platform teams is GPU-seconds used versus GPU-seconds allocated. Use DCGM telemetry and Kubernetes context joins to publish this metric by namespace and workload class, then review it over time as a shared KPI for platform and finance teams. This approach defines a common source of truth for optimization decisions and helps prevent over-allocation from being hidden by aggregate utilization averages.