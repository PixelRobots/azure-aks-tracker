---
layout: Conceptual
title: Failed to create file share on storage account - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/create-file-share-failed-storage-account
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
description: Troubleshoot AKS failures to create a file share on a storage account for dynamic provisioning, and use this guide to resolve authorization errors.
ms.date: 2025-03-14T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, wonkilee, v-leedennis, mariusbutuc
ms.service: azure-kubernetes-service
ms.custom: sap:Storage
locale: en-us
document_id: 87b44724-0bbb-3848-0e11-af2bfcac7a4e
document_version_independent_id: 87b44724-0bbb-3848-0e11-af2bfcac7a4e
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/storage/create-file-share-failed-storage-account.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/storage/create-file-share-failed-storage-account
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/storage/create-file-share-failed-storage-account.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68cb9039-df60-49b0-8ef8-89ad96497f63
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/725b6df3-93e8-472d-834e-e7e0d2953d35
platformId: 35fee947-ec57-0e22-1992-49040cb90d40
---

# Failed to create file share on storage account - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot why you can't create a file share on a storage account that's used for dynamic provisioning on Azure Kubernetes Service (AKS).

## Symptoms

When you create a file share on a storage account that's used for dynamic provisioning, the PersistentVolumeClaim (PVC) is stuck in the Pending status. In this case, if you run the `kubectl describe pvc` command, you receive the following error:

> 
> persistentvolume-controller (combined from similar events):
> 
> Failed to provision volume with StorageClass "azurefile":
> 
> failed to create share kubernetes-dynamic-pvc-xxx in account xxx:
> 
> failed to create file share, err:
> 
> storage: service returned error: StatusCode=403, ErrorCode=AuthorizationFailure,
> 
> ErrorMessage=This request is not authorized to perform this operation.

## Cause

The Kubernetes `persistentvolume-controller` isn't on the network that was chosen when the **Allow access from** network setting was enabled for **Selected networks** on the storage account. Especially, when you specify `useDataPlaneAPI: "true"` on the storage class, the `persistentvolume-controller` uses the data plane API for file share creation/deletion/resizing. However, this will fail when a firewall or virtual network is set on the storage account.

## Workaround

Create a file share and set up your AKS cluster to use [static provisioning with Azure Files](/en-us/azure/aks/azure-files-volume).