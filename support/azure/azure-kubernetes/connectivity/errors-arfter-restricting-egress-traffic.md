---
layout: Conceptual
title: Troubleshoot AKS errors after restricting egress traffic - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/errors-arfter-restricting-egress-traffic
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
description: Learn how to troubleshoot AKS errors after restricting egress traffic and restore cluster operations. Follow these steps to resolve connectivity issues.
ms.date: 2025-03-20T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, jaewonpark, v-leedennis
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Connectivity
locale: en-us
document_id: 1a03a0c2-db76-a0e2-9e7f-7e707ff74fff
document_version_independent_id: 1a03a0c2-db76-a0e2-9e7f-7e707ff74fff
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/errors-arfter-restricting-egress-traffic.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/errors-arfter-restricting-egress-traffic
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/errors-arfter-restricting-egress-traffic.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d94385af-0c8a-608c-edf4-b45d91c56dc5
---

# Troubleshoot AKS errors after restricting egress traffic - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot issues that occur after you restrict egress traffic for cluster nodes in Microsoft Azure Kubernetes Service (AKS).

## Symptoms

Certain commands of the [kubectl](https://kubernetes.io/docs/reference/kubectl/) command-line tool don't work correctly, or you experience errors when you create an AKS cluster or scale a node pool.

## Cause

When you restrict egress traffic from an AKS cluster, your settings must comply with required Outbound network and FQDN (fully qualified domain names) rules for AKS clusters. If your settings are in conflict with any of these rules, the egress traffic restriction issues occur.

## Solution

Verify that your configuration doesn't conflict with any of the [required Outbound network and FQDN (fully qualified domain names) rules for AKS clusters](/en-us/azure/aks/outbound-rules-control-egress) for the following items:

- Outbound ports
- Network rules
- FQDNs
- Application rules

Check for conflicts with the rules that might occur in the NSG (network security group), firewall, or appliance that AKS traffic passes through according to the configuration.

Note

The AKS outbound dependencies are almost entirely defined by using FQDNs. These FQDNs don't have static addresses behind them. The lack of static addresses means that you can't use NSGs to restrict outbound traffic from an AKS cluster. Additionally, scenarios that allow only IPs that are obtained from required FQDNs after all deny in NSG are not enough to restrict outbound traffic. Because the IPs are not static, issues might occur later.

## More information

- [Limit network traffic with Azure Firewall in AKS clusters](/en-us/azure/aks/limit-egress-traffic)

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.