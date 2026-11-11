---
layout: Conceptual
title: Supported Azure VM sizes for AKS-managed GPU node pools - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/supported-skus-aks-managed-gpu
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
description: Review supported Azure VM families and exclusions before choosing a node VM size for an AKS-managed GPU node pool
author: sdesai345
ms.author: sachidesai
ms.date: 2026-11-09T00:00:00.0000000Z
ms.topic: concept-article
ms.subservice: aks-nodes
locale: en-us
document_id: c7a1d890-1a9e-b555-6ebb-4691cac37a65
document_version_independent_id: 78274c72-bfc1-5801-08d5-59cfba640c60
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/supported-skus-aks-managed-gpu.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/supported-skus-aks-managed-gpu
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/supported-skus-aks-managed-gpu.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 13111a3b-7815-a8e3-bde4-91e1d9903aa4
---

# Supported Azure VM sizes for AKS-managed GPU node pools - Azure Kubernetes Service | Microsoft Learn

## Overview

Azure Kubernetes Service (AKS) can install and maintain GPU software for supported NVIDIA GPU-enabled nodes. Use this article to choose a virtual machine (VM) family, then follow [Create an AKS-managed GPU node pool](aks-managed-gpu-nodes) to configure the feature and verify your GPU workload deployment.

## Supported GPU-enabled VM sizes

AKS-managed GPU node pools currently support GPU-enabled VM sizes in the NC, ND, and NV families, subject to the exclusions in the following table. The GPU model varies by VM series. Check [regional availability](https://azure.microsoft.com/global-infrastructure/services/) before you choose a size.

| Azure VM family | Supported GPU series | Exclusions and retired series |
| --- | --- | --- |
| [NC family](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nc-family) | NVIDIA GPU series, including NCasT4, NC A100, and NC H100. | Non-NVIDIA GPU series aren't supported. |
| [ND family](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nd-family) | Include [ND A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndasra100v4-series), [NDm A100 v4](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndma100v4-series), and [ND H100 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ndh100v5-series). | [ND GB200 v6](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nd-gb200-v6-series) and [ND GB300 v6](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nd-gb300-v6-series) aren't yet supported. ND MI300X v5 isn't currently supported because it uses AMD GPUs. |
| [NV family](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nv-family) | [NVads A10 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nvadsa10v5-series). | [NVads V710 v5](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nvadsv710-v5-series) isn't currently supported because it uses AMD GPUs. NVv3 and NVv4 retired on September 30, 2026. |
| [NG family](/en-us/azure/virtual-machines/sizes/gpu-accelerated/ng-family) | None. | The NG family isn't currently supported. NGads V620 uses AMD GPUs. |
| [NP family](/en-us/azure/virtual-machines/sizes/fpga-accelerated/np-family) | None. | The NP family isn't supported. NP-series uses field-programmable gate arrays (FPGAs), not GPUs. |

## Node pool considerations

- Use an AKS node pool with `--os-type Linux`. For Windows GPU workloads, see [Use Windows GPUs on AKS](use-windows-gpu).
- Confirm that your subscription has sufficient quota for the selected VM family in the target region. Regional availability doesn't guarantee deployment capacity.

Note

GPU-enabled VMs contain specialized hardware subject to higher pricing and regional availability. For more information, see the [pricing](https://azure.microsoft.com/pricing/) tool and [regional availability](https://azure.microsoft.com/global-infrastructure/services/).

## Match VM resources to workload requests and limits

- Check the specifications of the exact GPU VM size you plan to use, because GPU models, GPU counts, GPU memory, CPUs, storage, and network performance can differ within the same VM family.
- Choose a VM size with enough GPU memory for the peak memory usage of your GPU workload. Host `memory` limits don't control GPU memory. In the [NVads A10 v5 series](/en-us/azure/virtual-machines/sizes/gpu-accelerated/nvadsa10v5-series), `Standard_NV6ads_A10_v5`, `Standard_NV12ads_A10_v5`, and `Standard_NV18ads_A10_v5` provide 1/6, 1/3, and 1/2 of a physical NVIDIA A10 GPU, respectively. On these sizes, requesting `nvidia.com/gpu: 1` doesn't provide a full physical GPU. Check the selected size's GPU memory allocation rather than inferring it from the Kubernetes resource count.
- Check the network bandwidth and connections between GPUs that your distributed workload requires. GPU requests don't reserve network bandwidth or enable remote direct memory access (RDMA), so configure any required network software separately.
- Multi-Instance GPU (MIG) is supported on select NVIDIA GPU VM sizes in AKS. For supported hardware and compatible GPU instance profiles, see [Create a multi-instance GPU node pool in AKS](gpu-multi-instance). To configure MIG with AKS-managed GPU software, see [Create a managed MIG node pool](aks-managed-gpu-nodes#create-a-managed-multi-instance-gpu-mig-node-pool).
- Test your application with representative model sizes, batch sizes, and numbers of concurrent requests, then adjust resource requests and limits based on observed usage.