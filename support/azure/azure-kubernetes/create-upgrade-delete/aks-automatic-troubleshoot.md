---
layout: Conceptual
title: Troubleshoot errors when creating or switching to an AKS Automatic cluster - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/aks-automatic-troubleshoot
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: wangamanda
ms.topic: troubleshooting
description: Learn how to troubleshoot AKS Automatic cluster errors when you create or switch clusters, and use the fixes in this guide to resolve issues quickly.
ms.date: 2026-06-15T00:00:00.0000000Z
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 37fb480b-6cc8-8334-e64a-d972d276bc20
document_version_independent_id: 37fb480b-6cc8-8334-e64a-d972d276bc20
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/aks-automatic-troubleshoot.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/aks-automatic-troubleshoot
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/aks-automatic-troubleshoot.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 1b1982ae-594e-aa1f-70d8-91ca78840ce9
---

# Troubleshoot errors when creating or switching to an AKS Automatic cluster - Azure | Microsoft Learn

## Summary

This article provides guidance for resolving errors that occur when you create or switch to an Azure Kubernetes Service (AKS) Automatic cluster.

## Error 1: Automatic SKU is not supported in this region

### Symptoms

When you try to create an AKS Automatic cluster, you receive the following error message:

> 
> Automatic SKU is not supported in this region.

### Cause

This error indicates that you can't create AKS Automatic clusters in regions where they're not generally available.

### Solution

Create the clusters in [GA regions](/en-us/azure/aks/automatic/aks-automatic-managed-system-node-pools-about#limitations).

## Error 2: Managed cluster `Automatic` SKU should set taint `CriticalAddonsOnlyNoSchedule` for the system node pool

### Symptoms

When you remove the `CriticalAddonsOnlyNoSchedule` taint from the system node pool of an AKS Automatic cluster, you receive the following error message:

> 
> Managed cluster `Automatic` SKU should set taint `CriticalAddonsOnlyNoSchedule` for the system node pool.

### Cause

You can't remove the `CriticalAddonsOnlyNoSchedule` taint from the system node pool of an AKS Automatic cluster.

### Solution

This behavior is by design. The `CriticalAddonsOnlyNoSchedule` taint keeps system add-ons running on the system node pool instead of on the user node pool.

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.