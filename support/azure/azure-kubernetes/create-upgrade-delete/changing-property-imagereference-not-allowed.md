---
layout: Conceptual
title: Resolve changing property imageReference isn't allowed error in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/changing-property-imagereference-not-allowed
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
description: Resolve the 'Changing property imageReference isn't allowed' error when you upgrade or scale an Azure Kubernetes Service (AKS) cluster. Follow these steps to resolve it.
ms.date: 2026-11-10T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, v-leedennis, kaushika
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: efa88cd4-eb01-e6c0-d46f-55048f122891
document_version_independent_id: efa88cd4-eb01-e6c0-d46f-55048f122891
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/changing-property-imagereference-not-allowed.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/changing-property-imagereference-not-allowed
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/changing-property-imagereference-not-allowed.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 4500a182-49b2-2f2f-737c-b705bd32e15d
---

# Resolve changing property imageReference isn't allowed error in AKS - Azure | Microsoft Learn

## Summary

This article helps you resolve the "Changing property 'imageReference' isn't allowed" error that occurs when you upgrade or scale an Azure Kubernetes Service (AKS) cluster, so that your operation completes successfully.

## Symptoms

When you try to upgrade or scale an AKS cluster, you might receive the "Changing property 'imageReference' isn't allowed" error message.

## Cause

Unexpected results can occur if you modify or delete tags and other properties of resources within the *MC\_*\* resource group. Also, altering the resources within the *MC\_*\* group in the AKS cluster breaks the service-level objective (SLO).

## Solution

Add another node pool, and then delete the affected node pool to resolve the error.