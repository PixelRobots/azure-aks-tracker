---
layout: Conceptual
title: Troubleshoot AKS API Server Authorized IP Range Access - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/cannot-access-cluster-api-server-using-authorized-ip-ranges
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
description: Can't access the AKS cluster API server with authorized IP ranges? Learn the fix steps and restore kubectl connectivity quickly. Start troubleshooting now.
ms.date: 2025-03-26T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, wonkilee, v-leedennis
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Connectivity
locale: en-us
document_id: 7dee42b7-8334-7686-fcc8-396a8a063166
document_version_independent_id: 7dee42b7-8334-7686-fcc8-396a8a063166
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/cannot-access-cluster-api-server-using-authorized-ip-ranges.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/cannot-access-cluster-api-server-using-authorized-ip-ranges
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/cannot-access-cluster-api-server-using-authorized-ip-ranges.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 7880cd20-569e-3589-bf24-c184fa9097dd
---

# Troubleshoot AKS API Server Authorized IP Range Access - Azure | Microsoft Learn

## Summary

This article discusses how to resolve a scenario in which you can't use authorized IP address ranges to access the API server for a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

If you try to create or manage resources in an AKS cluster, you can't access the cluster API server. When you run `kubectl`, you receive the following error message:

> 
> Unable to connect to the server: dial tcp x.x.x.x:443: i/o timeout

## Cause

You configured your AKS cluster to access the cluster API server by using authorized IP address ranges that your computer can't access.

## Solution

Make sure that when you run the [az aks create](/en-us/cli/azure/aks#az-aks-create) or [az aks update](/en-us/cli/azure/aks#az-aks-update) command in [Azure CLI](/en-us/cli/azure/install-azure-cli), the `--api-server-authorized-ip-ranges` parameter includes the IP addresses or IP address ranges of the automation, development, or tooling systems that are being used.

## More information

- [How to find my IP to include in --api-server-authorized-ip-ranges?](/en-us/azure/aks/api-server-authorized-ip-ranges#how-to-find-my-ip-to-include-in---api-server-authorized-ip-ranges)