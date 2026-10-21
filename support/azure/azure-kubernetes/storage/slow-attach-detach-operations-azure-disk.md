---
layout: Conceptual
title: Slow attach and detach operations for an Azure disk - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/slow-attach-detach-operations-azure-disk
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
description: Learn how to troubleshoot slow attach and detach operations for Azure disk storage in AKS clusters and migrate to CSI to improve performance.
ms.date: 2025-03-24T00:00:00.0000000Z
ms.reviewer: jopalhei, chiragpa, nickoman, v-leedennis, mariusbutuc
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Storage
locale: en-us
document_id: 394e68b9-6961-be9f-f3a0-2d706bb57ade
document_version_independent_id: 394e68b9-6961-be9f-f3a0-2d706bb57ade
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/storage/slow-attach-detach-operations-azure-disk.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/storage/slow-attach-detach-operations-azure-disk
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/storage/slow-attach-detach-operations-azure-disk.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: dd398f21-1ec4-3225-bbd9-c6d4e0ac14c5
---

# Slow attach and detach operations for an Azure disk - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot slow attach and detach operations when you use an Azure disk for storage on your Microsoft Azure Kubernetes Service (AKS) clusters.

## Symptoms

Attaching and detaching Azure disks takes more time than expected if there are many operations, as outlined in the following table.

| Target of attach and detach operations | Number of attach and detach operations |
| --- | --- |
| Single-node virtual machine | More than 10 |
| Single virtual machine scale set pool | More than 3 |

## Cause

This limitation is a known issue that affects the in-tree Azure disk driver (`kubernetes.io/azure-disk`) that performs the operations sequentially.

To verify that you're using the in-tree Azure Disk driver, check the storage class that's defined on the persistent volume claim. If the `provisioner` is `kubernetes.io/azure-disk`, then you're using the in-tree driver. This means that you're exposed to the referred limitation in which operations are done sequentially.

Usage of the in-tree driver was deprecated in AKS 1.21. We now use the Container Storage Interface (CSI) driver as the standard driver.

## Workaround

We recommend that you [migrate your in-tree volumes to CSI Drivers by using this documentation](/en-us/azure/aks/csi-migrate-in-tree-volumes).