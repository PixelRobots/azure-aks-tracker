---
layout: Conceptual
title: Troubleshoot missing or invalid service principal when creating an AKS cluster - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/missing-or-invalid-service-principal
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
description: Troubleshoot a missing or invalid service principal when you create an Azure Kubernetes Service (AKS) cluster. Learn how to fix validation errors and deploy successfully.
ms.date: 2026-11-17T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, v-leedennis, momajed, kaushika
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: 66c3c8e8-abf4-5ee2-457c-9925969d3580
document_version_independent_id: 66c3c8e8-abf4-5ee2-457c-9925969d3580
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/missing-or-invalid-service-principal.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/missing-or-invalid-service-principal
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/missing-or-invalid-service-principal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f427f78b-9a73-aa09-4184-1c6981d6877a
---

# Troubleshoot missing or invalid service principal when creating an AKS cluster - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot a missing or invalid service principal when you create an Azure Kubernetes Service (AKS) cluster. Follow the steps to resolve the validation error and complete your deployment.

## Prerequisites

Ensure you have Azure CLI version 2.0.81 or later installed for running the commands in this article.

## Cause

When you create an AKS cluster, AKS requires a service principal or managed identity to manage resources on your behalf. By default, AKS uses a system-assigned managed identity. If you prefer to use a service principal instead, be aware that AKS doesn't automatically create one for you. You need to provide your own service principal and reference it during cluster creation. For more information, see [Use a service principal with Azure Kubernetes Service (AKS)](/en-us/azure/aks/kubernetes-service-principal?tabs=azure-cli).

Although AKS supports service principals for authentication, use a system-assigned managed identity. This identity simplifies credential management and is the default option for new clusters.

Also, ensure Microsoft Entra ID propagates the service principal across all regions when you create it. If this propagation takes too long, the cluster might fail validation because AKS can't locate the service principal.

## Solution

Ensure there's a valid, findable service principal. Use one of the following methods:

- When you create an AKS cluster, consider using an existing service principal that already propagated across regions. Although you can't directly verify the propagation status, you can verify functionality by using a previously deployed service principal. Alternatively, if you're using a new principal, wait 5-10 minutes for the principal to propagate before you start the cluster creation.
- To verify that the service principal is ready, run the `az ad sp show --id <appId>` command and check the output before proceeding with the creation of the AKS cluster.
- If you use automation scripts, add time delays between service principal creation and AKS cluster creation. We recommend a delay of 5 to 10 minutes.
- If you use the [Azure portal](https://portal.azure.com), return to the cluster settings after you try to create the cluster, and then retry the validation page after a few minutes.