---
layout: Conceptual
title: Custom Azure Policy for validating controllers fails - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/custom-policy-for-validating-controller-not-working
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
description: Learn how to fix a custom Azure Policy for validating controllers in AKS. Follow these steps to resolve syntax errors and get your policy working.
ms.date: 2024-04-12T00:00:00.0000000Z
ms.reviewer: momajed, cssakscic
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: 68bc43cc-2e6e-d662-1cf2-ec8f788364a4
document_version_independent_id: 68bc43cc-2e6e-d662-1cf2-ec8f788364a4
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/custom-policy-for-validating-controller-not-working.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/custom-policy-for-validating-controller-not-working
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/custom-policy-for-validating-controller-not-working.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/eea02214-631d-404a-92d1-5a3357c32a26
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/f42c31d7-eed9-43b7-9757-54caffb53cdc
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 45a77831-377e-2ffa-705b-229a39caaabe
---

# Custom Azure Policy for validating controllers fails - Azure | Microsoft Learn

## Summary

This article explains how to fix a custom Azure Policy for validating controllers that fails when used with an Azure Kubernetes Service (AKS) cluster. Follow the steps below to resolve syntax errors and ensure your policy works correctly.

## Symptoms

A custom policy created for validating controllers fails with an error.

## Cause

The custom policy isn't defined using the correct syntax.

## Solution

To resolve this issue, follow these steps to ensure that the custom policy works correctly and meets the necessary requirements:

1. Generate the custom policy definition with the correct syntax by using Visual Studio Code extension for Azure Policy.

    Using this tool to generate a custom policy ensures that it can be properly defined and adhere to the required format.
2. Create and validate the custom policy by referencing [Azure Policy for Kubernetes releases support for custom policy](https://techcommunity.microsoft.com/t5/azure-governance-and-management/azure-policy-for-kubernetes-releases-support-for-custom-policy/ba-p/2699466).