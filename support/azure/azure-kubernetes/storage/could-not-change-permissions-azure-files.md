---
layout: Conceptual
title: Could not change permissions using Azure Files - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/could-not-change-permissions-azure-files
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
description: Troubleshoot the "could not change permissions" Azure Files error in Azure Kubernetes Service (AKS), then apply the workaround to get PostgreSQL running.
ms.date: 2025-02-28T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, v-leedennis
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Storage
locale: en-us
document_id: d011fb27-a8d7-b5b2-593a-0658411afd77
document_version_independent_id: d011fb27-a8d7-b5b2-593a-0658411afd77
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/storage/could-not-change-permissions-azure-files.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/storage/could-not-change-permissions-azure-files
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/storage/could-not-change-permissions-azure-files.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/01a89bec-e73f-4ce0-a00a-ae34ad62e5fe
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/50038ab9-5431-4515-9dfc-c24291ef4fce
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 9033c34f-3491-236d-b1e2-05560a05d2fc
---

# Could not change permissions using Azure Files - Azure | Microsoft Learn

## Summary

Use this article to troubleshoot the "could not change permissions" error in Azure Files and restore PostgreSQL startup in your Azure Kubernetes Service (AKS) cluster.

## Symptoms

When you run PostgreSQL on the Azure Files plug-in, you receive an error that resembles the following output:

> 
> initdb: could not change permissions of directory "/var/lib/postgresql/data": Operation not permitted
> 
> fixing permissions on existing directory /var/lib/postgresql/data
> 
> Message: 'OSError while changing ownership of the log file. 'Arguments: PermissionError: [Errno 1] Operation not permitted

## Cause

The Azure Files plug-in uses the Common Internet File System (CIFS) protocol, which is a dialect of the Server Message Block (SMB) protocol. When this protocol is in use, the file and directory permissions can't be changed after the files and directories are mounted.

## Workaround

Use the Azure Disk plug-in instead, and [use the subPath property](https://kubernetes.io/docs/concepts/storage/volumes/#using-subpath).

Note

For the ext3 or ext4 disk type, there's a *lost+found* directory after the disk is formatted.

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.