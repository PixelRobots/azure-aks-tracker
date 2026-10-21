---
layout: Conceptual
title: Troubleshoot the AksCapacityHeavyUsage error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/akscapacityheavyusage-error
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: axelgMS
ms.author: axelg
ms.topic: troubleshooting-problem-resolution
description: Learn how to troubleshoot the AksCapacityHeavyUsage error when you create or start an AKS cluster, and use the recommended fixes to deploy successfully.
ms.date: 2026-06-15T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: chiragpa, anbubin, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: aa49ccd1-c5ba-e666-47c1-6eda987fbf0b
document_version_independent_id: aa49ccd1-c5ba-e666-47c1-6eda987fbf0b
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/akscapacityheavyusage-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/akscapacityheavyusage-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/akscapacityheavyusage-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 80761cea-bdbd-2edd-4bf5-010bdf1c2f12
---

# Troubleshoot the AksCapacityHeavyUsage error code - Azure | Microsoft Learn

## Summary

This article explains how to identify and resolve the `AksCapacityHeavyUsage` error when you create an Azure Kubernetes Service (AKS) cluster so that you can complete deployment successfully.

## Symptoms

When you try to create an AKS cluster, you receive the following error message:

> 
> **Code:** AksCapacityHeavyUsage
> 
> **Message:** AKS is experiencing heavy usage in region &lt;Region&gt;. We are working on adding new capacity. In the meantime, please consider creating new AKS clusters in a different region. For a list of all the Azure regions, visit https://aka.ms/aks/regions. For more details on this error, visit https://aka.ms/akscapacityheavyusage.

## Cause

You're trying to create a cluster in a region that has limited capacity.

When you create an AKS cluster, Microsoft Azure allocates compute resources to your subscription. You might occasionally experience the `AksCapacityHeavyUsage` error because of significant growth in demand for Azure Kubernetes Service in specific regions.

If you're creating an AKS Automatic cluster with managed system node pools preconfigured, Microsoft Azure allocates compute resources for the system node pools in Azure subscriptions instead of your subscriptions. You might occasionally experience the `AksCapacityHeavyUsage` error because of significant growth in demand for AKS in specific regions.

## Resolution

### Solution 1: Select a different region

The easiest and quickest solution is to try to deploy to a different region (for example, NorthEurope instead of WestEurope or UAENorth instead of QatarCentral). To find nearby regions, visit the [Azure Geographies page](https://azure.microsoft.com/explore/global-infrastructure/geographies/#overview).

For AKS Automatic clusters, you can try to deploy to [one of the GA regions](/en-us/azure/aks/automatic/aks-automatic-managed-system-node-pools-about#limitations).

This approach might not be feasible if you already have existing resources in the requested region, but it's the preferred solution in a dev/test scenario.

### Solution 2: Deploy a cluster that has different settings

The infrastructure that hosts AKS-managed clusters uses different allocation reservations. Therefore, AKS might have more capacity for public clusters than it has for private clusters. If you experience the `AksCapacityHeavyUsage` error when you try to create a private cluster, try to create a public cluster instead (or vice versa).

### Solution 3: Use an Azure Enterprise subscription

When capacity is running low, non-Enterprise Agreement (EA) subscriptions are limited first in AKS cluster creation to reserve resources for real production scenarios. If you have an EA subscription, make sure that you use the EA subscription to create the AKS cluster.

### Solution 4: Retry the operation

Capacity is often reclaimed when other users stop or delete their AKS clusters. Therefore, the operation might succeed if you retry it later.

## More information

- Ensuring capacity for users is a top priority for Microsoft, and the company is working to scale up its infrastructure to accommodate the increasing popularity of Azure services.

    For more information about improvements that Microsoft is making toward delivering a resilient cloud supply chain, see [this September 2021 Azure Blog article](https://azure.microsoft.com/blog/advancing-reliability-through-a-resilient-cloud-supply-chain/).
- [General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)