---
layout: Conceptual
title: Azure policy reports ConstraintNotProcessed for a running container - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/error-azure-policy-constraintnotprocessed
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
description: Learn why Azure Policy reports running containers as ConstraintNotProcessed in AKS, and follow the fix to upgrade your cluster and restore compliance.
ms.date: 2024-03-27T00:00:00.0000000Z
ms.reviewer: momajed
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: 0571eab2-d003-3c90-03eb-174fc1d742e9
document_version_independent_id: 0571eab2-d003-3c90-03eb-174fc1d742e9
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/error-azure-policy-constraintnotprocessed.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/error-azure-policy-constraintnotprocessed
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/error-azure-policy-constraintnotprocessed.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/eea02214-631d-404a-92d1-5a3357c32a26
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f42c31d7-eed9-43b7-9757-54caffb53cdc
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c7164dae-a04d-3ee9-03fa-ba59f1a2b99f
---

# Azure policy reports ConstraintNotProcessed for a running container - Azure | Microsoft Learn

## Summary

If Azure Policy reports a running container as `ConstraintNotProcessed`, this article helps you identify the AKS version issue and apply the cluster upgrade fix.

## Symptoms

A container such as Gatekeeper is running. However, Azure Policy reports the container as `ConstraintNotProcessed`.

## Cause

The issue could be related to the version or compatibility of your Azure Kubernetes Service (AKS).

## Solution

To resolve the issue, upgrade the AKS cluster to a newer or supported version that offers additional features, security enhancements, and updates to prevent issues such as this one.