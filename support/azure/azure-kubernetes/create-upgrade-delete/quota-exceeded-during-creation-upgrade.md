---
layout: Conceptual
title: QuotaExceeded or InsufficientVCPUQuota error during creation or upgrade - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/quota-exceeded-during-creation-upgrade
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
description: Resolves a QuotaExceeded or InsufficientVCPUQuota error during a creation or upgrade operation in an Azure Kubernetes Service (AKS) cluster.
ms.date: 2025-03-07T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, v-weizhu, mariusbutuc
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 192241bf-1193-f6e8-eb1f-f7a86d7cdccd
document_version_independent_id: 192241bf-1193-f6e8-eb1f-f7a86d7cdccd
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/quota-exceeded-during-creation-upgrade.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/quota-exceeded-during-creation-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/quota-exceeded-during-creation-upgrade.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 221d1905-e50d-8482-2f8f-e398974da8eb
---

# QuotaExceeded or InsufficientVCPUQuota error during creation or upgrade - Azure | Microsoft Learn

## Summary

This article provides a solution to a "QuotaExceeded" or "InsufficientVCPUQuota" error that occurs during an Azure Kubernetes Service (AKS) creation or upgrade operation.

## Symptoms

When you try to scale up your node pools in an AKS cluster, deploy a new cluster, or deploy a new node pool, you receive an error message that resembles the following text:

- Family quota errors

> 
> Code: QuotaExceeded Message: Operation could not be completed as it results in exceeding approved standardDSv3Family Cores quota. Additional details - Deployment Model: Resource Manager, Location: eastus2, Current Limit: 1500, Current Usage: 1500, Additional Required: 16, (Minimum) New Limit Required: 1516.

    Or

> 
> Code: ErrCode\_InsufficientVCPUQuota Message: Insufficient vcpu quota requested 48, remaining 32 for family standardDSv5Family for region qatarcentral
- Regional quota errors

> 
> Code: QuotaExceeded Message: Operation could not be completed as it results in exceeding approved Total Regional Cores quota. Additional details - Deployment Model: Resource Manager, Location: eastus, Current Limit: 350, Current Usage: 348, Additional Required: 4, (Minimum) New Limit Required: 352.

    Or

> 
> Code: ErrCode\_InsufficientVCPUQuota Message: "Insufficient regional vcpu quota left for location eastus. left regional vcpu quota 0, requested quota 4"

## Cause

This error occurs because the operation that you try to perform exceeds the current quota limits.

## Solution

To resolve family quota errors, [increase VM-family vCPU quotas](/en-us/azure/quotas/per-vm-quota-requests).

To resolve regional quota errors, select a different region or [increase a regional vCPU quota](/en-us/azure/azure-portal/supportability/regional-quota-requests#increase-a-regional-vcpu-quota).