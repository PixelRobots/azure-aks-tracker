---
layout: Conceptual
title: Troubleshoot issue in which AKS cluster creation fails | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/gpu-enabled-cluster-issue
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
description: Learn how to troubleshoot and mitigate an issue that causes AKS cluster creation to fail.
ms.topic: troubleshooting
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.lastreviewed: 2026-05-27T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: 5d250f5e-4b45-2fac-a09d-4f2dcb211aee
document_version_independent_id: 7db70bc5-0587-2a0f-eb45-0e4fbe5ce389
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/gpu-enabled-cluster-issue.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/gpu-enabled-cluster-issue
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/gpu-enabled-cluster-issue.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 37dfee3f-8271-7fbd-713a-0e5ff727d9d9
---

# Troubleshoot issue in which AKS cluster creation fails | Microsoft Learn

This article describes an issue in which creating an AKS cluster with a GPU-enabled default node pool fails. This issue occurs when you specify newly added GPU types, including NVIDIA L-series GPUs and NVIDIA RTX 6000 Ada GPUs, as the default node pool.

## Symptoms

The following command causes the AKS cluster creation to fail:

```azurecli
az aksarc create --node-vm-size <GPU_ENABLED_VM_SIZE>
```

## Workaround

Create an AKS cluster with a non-GPU enabled default node pool, then add the needed GPU enabled node pool.

```azurecli
az aksarc create <default node pool size>
az aksarc nodepool add --node-vm-size <GPU_ENABLED_VM_SIZE>
```

## Verification

Once the fix is done, you should be able to create your cluster. If you still encounter issues, please reach out to Microsoft Support.

## Contact Microsoft Support

If the problem persists, collect the [AKS cluster logs](get-on-demand-logs) before you [create a support request](help-support).