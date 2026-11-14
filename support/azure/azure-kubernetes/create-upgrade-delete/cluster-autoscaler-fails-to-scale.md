---
layout: Conceptual
title: Cluster autoscaler fails to scale with failed to fix group sizes error in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/cluster-autoscaler-fails-to-scale
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Learn how to resolve the cluster autoscaler "failed to fix node group sizes" error in AKS when scaling stops working. Follow these steps to restore scaling.
ms.date: 2026-11-11T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, albarqaw, v-leedennis, v-weizhu, kaushika
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: 333a3607-4fe4-1ae6-8e17-c367b07a30d0
document_version_independent_id: 333a3607-4fe4-1ae6-8e17-c367b07a30d0
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/cluster-autoscaler-fails-to-scale.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/cluster-autoscaler-fails-to-scale
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/cluster-autoscaler-fails-to-scale.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: cb103f16-5081-10fa-2172-361f2638e016
---

# Cluster autoscaler fails to scale with failed to fix group sizes error in AKS - Azure | Microsoft Learn

## Summary

This article explains how to resolve the cluster autoscaler "failed to fix node group sizes" error in Azure Kubernetes Service (AKS). Use the solution to restore scaling up and down when the autoscaler is stuck.

## Symptoms

Your cluster autoscaler isn't scaling up or down, and you see an error similar to the following error in the [cluster autoscaler logs](/en-us/azure/aks/monitor-aks-reference#resource-logs).

```output
E1114 09:58:55.367731 1 static_autoscaler.go:239] Failed to fix node group sizes: failed to decrease aks-default-35246781-vmss: attempt to delete existing nodes
```

## Cause

This error is caused by an upstream cluster autoscaler race condition. In this case, cluster autoscaler gets stuck in a deadlock. For more information, see [cluster-autoscaler gets stuck with "Failed to fix node group sizes" error](https://github.com/kubernetes/autoscaler/issues/6128).

## Solution

To get out of this state, disable and re-enable the [cluster autoscaler](/en-us/azure/aks/cluster-autoscaler).