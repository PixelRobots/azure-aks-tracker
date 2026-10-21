---
layout: Conceptual
title: Troubleshoot timeout and latency issues in AKS with Azure Storage - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/troubleshoot-timeout-latency-aks-azure-storage
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
description: Troubleshoot AKS timeout and latency issues when you use Azure Storage. Learn diagnostic steps and solutions to improve performance and reliability.
ms.date: 2026-04-09T00:00:00.0000000Z
ms.reviewer: chiragpa, meghadubey
ms.service: azure-kubernetes-service
ms.custom: sap:Storage
locale: en-us
document_id: 9f037ff9-b7e6-b4a8-e31f-fe64e1231c8f
document_version_independent_id: 9f037ff9-b7e6-b4a8-e31f-fe64e1231c8f
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/storage/troubleshoot-timeout-latency-aks-azure-storage.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/storage/troubleshoot-timeout-latency-aks-azure-storage
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/storage/troubleshoot-timeout-latency-aks-azure-storage.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/de8ce683-cbe1-461b-bae7-77db0888ec6d
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/a06cf482-4ca9-4582-a142-bcf842258d42
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 9107201a-d709-cc89-013b-97dd9ea4b139
---

# Troubleshoot timeout and latency issues in AKS with Azure Storage - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot timeout and latency issues that occur in Azure Kubernetes Service (AKS) when you use Azure Storage. You'll learn common causes, diagnostic steps, and recommended solutions to improve performance and reliability.

## Symptoms

Applications in AKS experience intermittent timeouts or slow access to Azure Storage accounts. Pod logs contain error entries such as the following examples:

- `Connection timeout`
- `Connection reset by peer`
- `503 Service Unavailable`

When this problem occurs, the `kubectl describe` pod shows no Persistent Volume Claim (PVC) errors. This condition indicates that the problem is network-related.

## Cause

- **SNAT port exhaustion**: AKS nodes that use outbound connectivity with Azure Load Balancer can run out of Source Network Address Translation (SNAT) ports under heavy traffic.
- **Public endpoint dependency**: Traffic that's routed over the public internet is susceptible to transient network problems and DDoS protection throttling.

## Solution

To mitigate connectivity timeouts and improve reliability, use the following methods as applicable.

### Enable private endpoints for storage

Take the following actions:

- Create a private endpoint for the storage account in the same virtual network (VNet) as the AKS cluster.
- Make sure that DNS resolves the storage account to the private IP.

This configuration keeps traffic within Azure's backbone network, and avoids public network disruptions.

### Use Azure NAT Gateway for outbound connectivity

Assign a NAT Gateway to the AKS subnet to provide:

- Increased SNAT port capacity
- Stable, dedicated outbound IP

This setup prevents SNAT exhaustion scenarios that cause intermittent failures.

### Implement application-level connection pooling

Take the following actions:

- Avoid creating excessive short‑lived outbound connections to Azure Storage.
- Enable persistent or pooled connections in application code or SDK configuration.

### Enable network flow logs and DDoS diagnostic logging

Enable logging to capture connection patterns, drops, and anomalies, including:

- Network security group (NSG) flow logs (or VNet flow logs) that help identify:

    - Dropped packets
    - Outbound connection failures
    - Saturated connection patterns
- DDoS diagnostic logs that provide visibility into:

    - Mitigated attacks
    - Threshold-triggered throttling events
    - High-volume spikes potentially impacting outbound calls

## References

[Collect and analyze resource logs from an Azure resource in Azure Monitor](/en-us/azure/azure-monitor/platform/tutorial-resource-logs?tabs=DDoSProtectionNotifications)