---
layout: Conceptual
title: Scale requirements for Azure Kubernetes Service (AKS) on Azure Local, Rack Scale | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/multi-rack/scale-requirements
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
description: Learn about scale requirements for AKS on Azure Local, Rack Scale deployments, including cluster, node pool, and node limits.
ms.topic: limits-and-quotas
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: sanjanamohan
ms.custom: multi-rack
author: sanjanamsft
locale: en-us
document_id: a4c4772e-dcfd-763f-748b-28d7fd2341f5
document_version_independent_id: 9ec4ea02-9f57-b1d0-3ad8-83991c71795f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/multi-rack/scale-requirements.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/multi-rack/scale-requirements
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/multi-rack/scale-requirements.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
platformId: 1428809b-44b3-3eba-91e0-5a7db0522607
---

# Scale requirements for Azure Kubernetes Service (AKS) on Azure Local, Rack Scale | Microsoft Learn

This article describes the supported node sizes and scale requirements for AKS on Azure Local for multi-rack deployments.

## Support count for AKS on Azure Local

The table below shares minimum count supported. While there are no enforced maximums for clusters per deployment, the effective maximum number of nodes and clusters are constrained by the available physical compute, memory, and logical network IP capacity in your deployment. Plan your logical network IP pools to have enough addresses for all cluster nodes, control plane nodes, plus two more IPs per cluster for internal services.

| Scale item | Minimum |
| --- | --- |
| Count of control plane nodes (odd numbers) | 1 |
| Number of node pools in an AKS cluster | 1 |
| Number of nodes in a node pool (empty node pools not supported) | 1 |

Note

The control plane node count must be an odd number (&gt;=1) to maintain etcd quorum.

## Autoscaler

Cluster autoscaler isn't currently supported on Azure Local for multi-rack deployments. You can manually scale node pools by updating the node count.

## Default values for virtual machine sizes

| System Role | VM Size | Memory, CPU |
| --- | --- | --- |
| AKS Arc control plane nodes | Standard\_D4s\_v3 | 16-GiB memory, 4 vCPU |
| AKS Arc Linux worker node | Standard\_A4\_v2 | 8-GiB memory, 4 vCPU |

## Supported values for control plane node sizes

| VM Size | CPU | Memory (GiB) |
| --- | --- | --- |
| Standard\_D4s\_v3 | 4 | 16 |
| Standard\_D8s\_v3 | 8 | 32 |

## Supported values for worker node sizes

| VM Size | CPU | Memory (GiB) |
| --- | --- | --- |
| Standard\_A2\_v2 | 2 | 4 |
| Standard\_K8S3\_v1 | 4 | 6 |
| Standard\_A4\_v2 | 4 | 8 |
| Standard\_D4s\_v3 | 4 | 16 |
| Standard\_D8s\_v3 | 8 | 32 |
| Standard\_D16s\_v3 | 16 | 64 |
| Standard\_D32s\_v3 | 32 | 128 |

## GPU requirements

Currently, the only supported GPU model is the NVIDIA RTX Pro 6000 Blackwell (96 GiB). For supported GPU-enabled VM sizes and deployment steps, see [Use GPUs for compute-intensive workloads](deploy-gpu-node-pool).