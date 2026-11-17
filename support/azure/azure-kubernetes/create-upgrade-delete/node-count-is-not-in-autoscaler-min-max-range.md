---
layout: Conceptual
title: Troubleshoot current node count outside autoscaler minimum and maximum range in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/node-count-is-not-in-autoscaler-min-max-range
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
description: Troubleshoot why the current node count falls outside the autoscaler minimum and maximum range after you resume an AKS cluster. Learn why it happens and what to expect.
ms.date: 2026-11-17T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, albarqaw, v-leedennis, wonkilee, kaushika
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: 50b8385d-f22f-5e95-db7a-2dbdde4e6c73
document_version_independent_id: 50b8385d-f22f-5e95-db7a-2dbdde4e6c73
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/node-count-is-not-in-autoscaler-min-max-range.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/node-count-is-not-in-autoscaler-min-max-range
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/node-count-is-not-in-autoscaler-min-max-range.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 2f1ebffd-d904-ec29-8381-7a634cc7468e
---

# Troubleshoot current node count outside autoscaler minimum and maximum range in AKS - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot a node count that falls outside the autoscaler minimum and maximum range when you resume an Azure Kubernetes Service (AKS) cluster after a stop operation. It explains why this behavior is expected and when the node count returns to the configured range.

## Symptoms

You're using the autoscaler for an AKS cluster. When you restart your cluster, your current node count doesn't fall within the minimum and maximum range of values that you set.

## Cause

This behavior is expected. The cluster starts by setting the number of nodes that it needs to run its workloads. Your autoscaler settings don't affect these values. When your cluster does scaling operations, the minimum and maximum values affect your current node count.

Your cluster will eventually enter and remain in the desired range until you stop the cluster.

## References

- [My cluster is below minimum / above maximum number of nodes, but CA did not fix that! Why?](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#my-cluster-is-below-minimum--above-maximum-number-of-nodes-but-ca-did-not-fix-that-why)