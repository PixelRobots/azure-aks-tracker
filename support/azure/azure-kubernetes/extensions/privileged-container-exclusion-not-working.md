---
layout: Conceptual
title: Azure Policy fails to exclude privileged containers from AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/privileged-container-exclusion-not-working
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
description: Learn how to fix Azure Policy when it fails to exclude privileged containers in AKS, and apply this workaround to restore policy control.
ms.date: 2024-04-12T00:00:00.0000000Z
ms.reviewer: momajed, cssakscic
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: e778d71b-5daa-2231-5660-07fd6377ad71
document_version_independent_id: e778d71b-5daa-2231-5660-07fd6377ad71
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/privileged-container-exclusion-not-working.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/privileged-container-exclusion-not-working
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/privileged-container-exclusion-not-working.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/eea02214-631d-404a-92d1-5a3357c32a26
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f42c31d7-eed9-43b7-9757-54caffb53cdc
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 08481760-99f6-cc22-87ae-5d7bcdf74e97
---

# Azure Policy fails to exclude privileged containers from AKS - Azure | Microsoft Learn

## Summary

This article provides a solution to an issue where Azure Policy can't exclude privileged containers from Azure Kubernetes Service (AKS) clusters.

## Symptoms

When you use Azure Policy in an AKS cluster, excluding privileged containers fails.

## Cause

Azure's built-in policies don't have container exclusion parameters for AKS clusters.

## Resolution

To resolve this issue, exclude containers from Azure Policy enforcement within your cluster. Here are the steps:

1. Create an exemption in the default Azure Security Center policy. This exemption allows you to customize the policy to meet specific requirements.

    When creating an exemption, you can apply it to the whole assignment or exempt specific assignments based on your requirements. For more information, see [Exempt a resource](/en-us/azure/defender-for-cloud/exempt-resource).
2. Create a new policy assignment that excludes the desired pods or containers. This overrides the default policy behavior and excludes the specified pods or containers from policy enforcement.