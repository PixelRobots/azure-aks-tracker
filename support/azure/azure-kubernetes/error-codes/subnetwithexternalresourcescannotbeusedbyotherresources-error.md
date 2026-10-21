---
layout: Conceptual
title: AKS cluster error code SubnetWithExternalResourcesCannotBeUsedByOtherResources - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/subnetwithexternalresourcescannotbeusedbyotherresources-error
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: axelgMS
ms.author: axelg
ms.topic: troubleshooting
description: Learn how to fix the SubnetWithExternalResourcesCannotBeUsedByOtherResources error in AKS when creating, upgrading, or scaling a cluster.
ms.date: 2024-11-18T00:00:00.0000000Z
ms.reviewer: chiragpa, eddie
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 065ffe98-3478-f8a5-2c0f-f88aed6b091c
document_version_independent_id: 065ffe98-3478-f8a5-2c0f-f88aed6b091c
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/subnetwithexternalresourcescannotbeusedbyotherresources-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/subnetwithexternalresourcescannotbeusedbyotherresources-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/subnetwithexternalresourcescannotbeusedbyotherresources-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f87a58a0-2483-eed6-19d6-3104fb85e43f
---

# AKS cluster error code SubnetWithExternalResourcesCannotBeUsedByOtherResources - Azure | Microsoft Learn

## Summary

This article provides solutions to the "SubnetWithExternalResourcesCannotBeUsedByOtherResources" error code that occurs when you create, update, or scale a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

When attempting to create an AKS cluster or perform an "update" or "scale" operation on an existing AKS cluster, you may encounter the following error message:

> 
> Code: SubnetWithExternalResourcesCannotBeUsedByOtherResources Error Message: Subnet &lt;URI of subnet1&gt; referenced by &lt;URI of the AKS resource referencing the subnet1&gt; cannot be used because it contains external resources. The external resources in this subnet are &lt;URI of the external reference used by subnet1&gt;. You need to delete these external resources before deploying into this subnet.

## Cause

This error is related to the configuration of subnets. It means that you're trying to use a subnet that already has external resources associated with it for another resource. However, a subnet that has external resources associated with it isn't allowed to be used by other resources. For more information, see [Effect of subnet delegation on your subnet](/en-us/azure/virtual-network/subnet-delegation-overview#effect-of-subnet-delegation-on-your-subnet).

## Solution

If you need to use the subnet for another resource, use one of the following methods:

- Create a new subnet and associate it with the new resource.
- Delete the external references, including service association links, subnet delegations, and so on.