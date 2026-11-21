---
layout: Conceptual
title: Resolve tls client offered only unsupported versions error in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/tls-client-offered-unsupported-versions
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
description: Fix the "tls - client offered only unsupported versions" error when connecting to the AKS API server. Learn the cause and upgrade to TLS 1.2 to resolve it.
ms.date: 2026-11-19T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, v-leedennis, kaushika
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: 4ed58fcb-a061-388a-807c-8c03f6ef25b5
document_version_independent_id: 4ed58fcb-a061-388a-807c-8c03f6ef25b5
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/tls-client-offered-unsupported-versions.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/tls-client-offered-unsupported-versions
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/tls-client-offered-unsupported-versions.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 2f0ef625-896a-949d-7e47-1be4778a5260
---

# Resolve tls client offered only unsupported versions error in AKS - Azure | Microsoft Learn

## Summary

This article helps you resolve the "tls: client offered only unsupported versions" error that occurs on a client computer or virtual machine when you connect to the Azure Kubernetes Service (AKS) API server. Upgrade your client to TLS 1.2 to restore the connection.

## Symptoms

When you try to connect to the AKS API server, you receive the following error message from your client computer or virtual machine.

> 
> tls: client offered only unsupported versions

## Cause

Your version of the Transport Layer Security (TLS) protocol is out of date. The minimum supported version in AKS is TLS 1.2.

## Solution

Upgrade your TLS version to 1.2. For upgrade instructions, see [Enable support for TLS 1.2 in your environment](../../entra-id/ad-dmn-services/enable-support-tls-environment).