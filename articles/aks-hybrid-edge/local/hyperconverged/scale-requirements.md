---
layout: Conceptual
title: Scale requirements for AKS on Azure Local | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/scale-requirements
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
description: Learn about scale requirements for AKS on Azure Local.
ms.topic: limits-and-quotas
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: srikantsarwa
ms.lastreviewed: 2024-03-26T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: b99f3c30-c761-b09c-f8b3-558d6ada9b86
document_version_independent_id: e85cc49f-d940-6f7c-10e5-66759685b0e9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/scale-requirements.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/scale-requirements
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/scale-requirements.md
platformId: 8e14b2e2-e2c4-c142-c770-beca0345d202
---

# Scale requirements for AKS on Azure Local | Microsoft Learn

> 
> Applies to: AKS on Azure Local

This article describes the maximum and minimum supported scale count for AKS on Azure Local clusters and node pools.

## Support count for AKS on Azure Local

| Scale item | Minimum | Maximum |
| --- | --- | --- |
| Number of physical nodes in an Azure Local cluster | 1 | 16 |
| Count of control plane nodes (Allowed values are 1, 3, and 5) | 1 | 5 |
| Number of nodes in default node pool created during cluster create | 1 | 200 |
| Number of node pools in an AKS cluster | 1 | 16 |
| Number of nodes in a node pool (empty node pools not supported) | 1 | 64 |
| Total number of nodes in an AKS cluster across node pools | 1 | 200 |
| Number of AKS clusters per Azure Local cluster | 0 | 32 |

## Concurrency for AKS on Azure Local

| Scale item | Count |
| --- | --- |
| Number of concurrent AKS cluster creations on an ARB | 8 |
| Number of concurrent node pool creations on an ARB | 8 |
| Number of concurrent operations across all different AKS clusters such as upgrade/scaling, etc., excluding creating node pools or clusters | 32 |
| Number of long running operations that can be run simultaneously on an AKS cluster | 1 per cluster |

## Scale requirements when using autoscaler with AKS on Azure Local

Note

When the autoscaler is enabled, AKS on Azure Local currently supports a maximum of 12 clusters per Azure Local environment. If this limit is exceeded, operations such as creating additional clusters or node pools might not succeed. To manage capacity, we recommend deleting unused clusters using the [az aksarc delete](/en-us/cli/azure/aksarc#az-aksarc-delete) command.

If the autoscaler is enabled in an environment that already exceeds the supported cluster count, performance might be impacted. Managing within supported limits is recommended.

| Scale item | Count |
| --- | --- |
| Maximum number of AKS clusters with autoscaler enabled | 12 |
| Number of concurrent AKS cluster creations | 4 |
| Number of concurrent node pool creations | 4 |

For more information, see [autoscaling with AKS on Azure Local](/en-us/azure/aks/aksarc/auto-scale-aks-arc).

If you operate at enterprise scale and have scenarios that require higher cluster counts with the autoscaler enabled, contact your Microsoft account team or support to discuss potential options.

## Default values for virtual machine sizes

| System Role | VM Size | Memory, CPU |
| --- | --- | --- |
| AKS control plane nodes | Standard\_A4\_v2 | 8-GB memory, 4 vcpu |
| AKS Linux worker node | Standard\_A4\_v2 | 8-GB memory, 4 vcpu |
| AKS Windows worker node | Standard\_K8S3\_v1 | 6-GB memory, 4 vcpu |

Starting with the Azure Local 2509 release, the default OS disk size for VMs used as AKS nodes is set to 200 GB. These are dynamically expanding virtual hard disks and you should [ensure sufficient physical disk space is available](/en-us/windows-server/virtualization/hyper-v/best-practices-analyzer/ensure-sufficient-physical-disk-space-is-available-when-virtual-machines-use-dynamically?source=recommendations) for the node pools that you create on AKS.

## Supported values for control plane node sizes

| VM Size | CPU | Memory (GB) |
| --- | --- | --- |
| Standard\_K8S3\_v1 | 4 | 6 |
| Standard\_A4\_v2 | 4 | 8 |
| Standard\_D4s\_v3 | 4 | 16 |
| Standard\_D8s\_v3 | 8 | 32 |

## Supported values for worker node sizes

| VM Size | CPU | Memory (GB) |
| --- | --- | --- |
| Standard\_A2\_v2 | 2 | 4 |
| Standard\_K8S3\_v1 | 4 | 6 |
| Standard\_A4\_v2 | 4 | 8 |
| Standard\_D4s\_v3 | 4 | 16 |
| Standard\_D8s\_v3 | 8 | 32 |
| Standard\_D16s\_v3 | 16 | 64 |
| Standard\_D32s\_v3 | 32 | 128 |

For more worker node sizes with GPU support, see the next section.

## Supported GPU models

Azure Kubernetes Service (AKS) on Azure local supports the following GPU models. GPUs are only supported on Linux OS node pools. GPUs aren't supported on Windows OS node pools.

| Manufacturer | GPU model | Supported version |
| --- | --- | --- |
| NVIDIA | A2 | 2311.2 |
| NVIDIA | A16 | 2402.0 |
| NVIDIA | T4 | 2408.0 |
| NVIDIA | L4 | 2512.0 |
| NVIDIA | L40 | 2512.0 |
| NVIDIA | L40S | 2512.0 |
| NVIDIA | RTX Pro 6000 | 2603.0 |

## Supported GPU VM sizes

AKS on Azure Local supports the following VM sizes for each GPU model.

### NVIDIA T4 is supported by NK T4 SKUs

| VM size | GPUs | GPU Memory: GiB | vCPU | Memory: GiB |
| --- | --- | --- | --- | --- |
| Standard\_NK6 | 1 | 8 | 6 | 12 |
| Standard\_NK12 | 2 | 16 | 12 | 24 |

### NVIDIA A2 is supported by NC2 A2 SKUs

| VM size | GPUs | GPU Memory: GiB | vCPU | Memory: GiB |
| --- | --- | --- | --- | --- |
| Standard\_NC4\_A2 | 1 | 16 | 4 | 8 |
| Standard\_NC8\_A2 | 1 | 16 | 8 | 16 |
| Standard\_NC16\_A2 | 2 | 32 | 16 | 64 |
| Standard\_NC32\_A2 | 2 | 32 | 32 | 128 |

### NVIDIA A16 is supported by NC2 A16 SKUs

| VM size | GPUs | GPU Memory: GiB | vCPU | Memory: GiB |
| --- | --- | --- | --- | --- |
| Standard\_NC4\_A16 | 1 | 16 | 4 | 8 |
| Standard\_NC8\_A16 | 1 | 16 | 8 | 16 |
| Standard\_NC16\_A16 | 2 | 32 | 16 | 64 |
| Standard\_NC32\_A16 | 2 | 32 | 32 | 128 |

### NVIDIA L4 is supported by NC2 L4 SKUs (Preview)

| VM size | GPUs | GPU Memory: GiB | vCPU | Memory: GiB |
| --- | --- | --- | --- | --- |
| Standard\_NC16\_L4\_1 | 1 | 24 | 16 | 64 |
| Standard\_NC16\_L4\_2 | 2 | 48 | 16 | 64 |
| Standard\_NC32\_L4\_1 | 1 | 24 | 32 | 128 |
| Standard\_NC32\_L4\_2 | 2 | 48 | 32 | 128 |

### NVIDIA L40 is supported by NC2 L40 SKUs (Preview)

| VM size | GPUs | GPU Memory: GiB | vCPU | Memory: GiB |
| --- | --- | --- | --- | --- |
| Standard\_NC16\_L40\_1 | 1 | 48 | 16 | 64 |
| Standard\_NC16\_L40\_2 | 2 | 96 | 16 | 64 |
| Standard\_NC32\_L40\_1 | 1 | 48 | 32 | 128 |
| Standard\_NC32\_L40\_2 | 2 | 96 | 32 | 128 |

### NVIDIA L40S is supported by NC2 L40S SKUs (Preview)

| VM size | GPUs | GPU Memory: GiB | vCPU | Memory: GiB |
| --- | --- | --- | --- | --- |
| Standard\_NC16\_L40S\_1 | 1 | 48 | 16 | 64 |
| Standard\_NC16\_L40S\_2 | 2 | 96 | 16 | 64 |
| Standard\_NC32\_L40S\_1 | 1 | 48 | 32 | 128 |
| Standard\_NC32\_L40S\_2 | 2 | 96 | 32 | 128 |

### NVIDIA RTX Pro 6000 is supported by NC2 RTX Pro 6000 SKUs (Preview)

| VM size | GPUs | GPU Memory: GiB | vCPU | Memory: GiB |
| --- | --- | --- | --- | --- |
| Standard\_NC16\_RTX6000Pro\_1 | 1 | 48 | 16 | 64 |
| Standard\_NC16\_RTX6000Pro\_2 | 2 | 96 | 16 | 64 |
| Standard\_NC32\_RTX6000Pro\_1 | 1 | 48 | 32 | 128 |
| Standard\_NC32\_RTX6000Pro\_2 | 2 | 96 | 32 | 128 |