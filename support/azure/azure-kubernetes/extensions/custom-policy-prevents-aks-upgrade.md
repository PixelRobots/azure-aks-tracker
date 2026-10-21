---
layout: Conceptual
title: AKS upgrade fails when using an Azure custom policy - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/custom-policy-prevents-aks-upgrade
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: mosbahmajed
ms.author: momajed
ms.topic: troubleshooting-problem-resolution
description: Resolve AKS upgrade failures caused by Azure custom policies blocking upgrades. Learn how to fix this issue with the Azure Policy Add-on for AKS.
ms.date: 2024-04-23T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: cssakscic, v-rekhanain, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: d09dd89b-b2af-3c09-d4e7-e13536f497be
document_version_independent_id: d09dd89b-b2af-3c09-d4e7-e13536f497be
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/custom-policy-prevents-aks-upgrade.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/custom-policy-prevents-aks-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/custom-policy-prevents-aks-upgrade.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 1b7bdc08-260d-f876-079b-bfaceedabc93
---

# AKS upgrade fails when using an Azure custom policy - Azure | Microsoft Learn

## Summary

This article explains how to resolve AKS upgrade failures that occur when an Azure custom policy blocks the upgrade. Learn the cause of this issue and how to apply the correct fix using the Azure Policy Add-on for Azure Kubernetes Service (AKS).

## Symptoms

You see a message in the Azure portal that indicates that your AKS cluster is compliant with your Azure custom policy. However, when you try to upgrade AKS, the custom policy blocks the upgrade attempt.

## Cause

During an AKS upgrade, the policies that are defined for the upgrade might differ from the policies that are defined for a running cluster. This scenario can create policy-related issues that appear only during the upgrade process. The scenario might occur if you start the upgrade process by using Azure CLI.

## Solution

Try using the [Azure portal](https://portal.azure.com) instead of Azure CLI to start the upgrade.