---
layout: Conceptual
title: Troubleshoot InUseRouteTableCannotBeDeleted Error Code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/inuseroutetablecannotbedeleted-error
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
description: Learn how to resolve the InUseRouteTableCannotBeDeleted error when you try to delete an Azure Kubernetes Service (AKS) cluster.
ms.date: 2025-03-28T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: rissing, chiragpa, edneto, wonkilee, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: f40761d4-7611-bde2-cbdd-7aa44e5d40a7
document_version_independent_id: f40761d4-7611-bde2-cbdd-7aa44e5d40a7
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/inuseroutetablecannotbedeleted-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/inuseroutetablecannotbedeleted-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/inuseroutetablecannotbedeleted-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: e395b4b5-ac84-d84e-edc5-38ae966371ae
---

# Troubleshoot InUseRouteTableCannotBeDeleted Error Code - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `InUseRouteTableCannotBeDeleted` error that occurs when you try to delete a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

When you try to delete an AKS cluster, you receive the following error message:

> 
> Error Code: "InUseRouteTableCannotBeDeleted"
> 
> {
> 
> "Route table aks-agentpool-routetable is in use and cannot be deleted. ...../providers/Microsoft.Network/routeTables/aks-agentpool-test-routetable"
> 
> }

## Cause

You tried to delete the AKS cluster while its associated route table was still in use.

## Solution

Remove the associated route table from the subnet. For instructions, see [Dissociate a route table from a subnet](/en-us/azure/virtual-network/manage-route-table#dissociate-a-route-table-from-a-subnet). Then, try again to delete the AKS cluster.