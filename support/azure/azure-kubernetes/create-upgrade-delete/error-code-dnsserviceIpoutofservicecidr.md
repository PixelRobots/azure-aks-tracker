---
layout: Conceptual
title: Troubleshoot the DnsServiceIpOutOfServiceCidr error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-dnsserviceipoutofservicecidr
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
description: Learn how to troubleshoot the DnsServiceIpOutOfServiceCidr error when you try to create or upgrade an AKS cluster.
ms.date: 2024-10-17T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: rissing, chiragpa, edneto, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: c338828e-f333-41ce-2cc7-3022ae895a8a
document_version_independent_id: c338828e-f333-41ce-2cc7-3022ae895a8a
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/error-code-dnsserviceIpoutofservicecidr.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/error-code-dnsserviceipoutofservicecidr
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/error-code-dnsserviceIpoutofservicecidr.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 9f3539aa-99f0-b11d-97bd-dce68d600133
---

# Troubleshoot the DnsServiceIpOutOfServiceCidr error code - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `DnsServiceIpOutOfServiceCidr` error that occurs when you try to create or upgrade an Azure Kubernetes Service (AKS) cluster.

## Prerequisites

This article requires Azure CLI version 2.0.65 or a later version. To find the version number, run `az --version`. If you have to install or upgrade Azure CLI, see [How to install the Azure CLI](/en-us/cli/azure/install-azure-cli).

For more detailed information about the upgrade process, see [Upgrade an AKS cluster](/en-us/azure/aks/upgrade-cluster#upgrade-an-aks-cluster).

## Symptoms

An AKS cluster create operation fails, and you receive a `DnsServiceIpOutOfServiceCidr` error message.

> 
> `(DnsServiceIpOutOfServiceCidr) The DNS service IP 10.0.0.10 is out of the range defined by service CIDR 10.200.0.0/16.`

- **Code**: `DnsServiceIpOutOfServiceCidr`
- **Message**: The DNS service IP 10.0.0.10 is out of the range defined by service CIDR 10.200.0.0/16.
- **Target**: networkProfile.dnsServiceIP

## Cause

This error occurs if the DNS service IP (`--dns-service-ip`) for AKS is out of the range that's defined by the service CIDR (`--service-cidr`).

## Solution

Make sure that the DNS service IP is within the range that's defined by service CIDR.