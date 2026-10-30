---
layout: Conceptual
title: Troubleshoot Kubernetes resource viewer access in Azure portal for AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/cannot-view-resources-kubernetes-resource-viewer-portal
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
description: Can't view resources in the Kubernetes resource viewer in the Azure portal? Learn how to fix authorized IP range and private cluster issues. Resolve access now.
ms.date: 2026-10-29T00:00:00.0000000Z
ms.reviewer: edneto, chiragpa, nickoman, jaewonpark, v-leedennis, kaushika
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Connectivity
ai-usage: ai-assisted
locale: en-us
document_id: 3a6074f4-686b-7221-67c4-2a8c1d637ac2
document_version_independent_id: 3a6074f4-686b-7221-67c4-2a8c1d637ac2
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/cannot-view-resources-kubernetes-resource-viewer-portal.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/cannot-view-resources-kubernetes-resource-viewer-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/cannot-view-resources-kubernetes-resource-viewer-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/970f20f1-2f12-4aa9-9c95-c00fe1f5e722
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/432c4950-b799-4ed5-93d5-b9b2934edf7d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 7430d882-e91d-f052-0b26-b20ad6fda085
---

# Troubleshoot Kubernetes resource viewer access in Azure portal for AKS - Azure | Microsoft Learn

## Summary

This article discusses how to resolve an issue that prevents you from using the Azure portal to view resources in the Kubernetes resource viewer for Azure Kubernetes Service (AKS).

## Symptoms

When you try to view resources in the [Kubernetes resource viewer](/en-us/azure/aks/kubernetes-portal) in the [Azure portal](https://portal.azure.com), you receive the following error message.

> 
> `Unable to reach the API server '<server-url>' or API is too busy to respond. Check your network settings`.

[![Screenshot of the Kubernetes resource viewer in the Azure portal showing an API server network connectivity error message.](media/cannot-view-resources-kubernetes-resource-viewer-portal/network-error.png)](media/cannot-view-resources-kubernetes-resource-viewer-portal/network-error.png#lightbox)

## Cause 1: You configured authorized IP address ranges

You configured your AKS cluster to access the cluster API server by using authorized IP address ranges that your computer can't access.

### Solution

When you run the [az aks create](/en-us/cli/azure/aks#az-aks-create) or [az aks update](/en-us/cli/azure/aks#az-aks-update) command in [Azure CLI](/en-us/cli/azure/install-azure-cli), make sure that the `--api-server-authorized-ip-ranges` parameter includes access for the local client computer to the IP addresses or IP address ranges from which the portal is being browsed.

## Cause 2: Your AKS cluster is private

You created your AKS cluster as a private cluster, and you're accessing the Azure portal from a network that can't communicate with the subnet to which your AKS is connected.

### Solution

This behavior is expected. To view the AKS resources in the Azure portal, you must access the Azure portal from a client that's located on a network that has connectivity to the AKS subnet. Then, you can view all AKS-related resources in the Azure portal.

## References

- [How to find my IP to include in --api-server-authorized-ip-ranges?](/en-us/azure/aks/api-server-authorized-ip-ranges#how-to-find-my-ip-to-include-in---api-server-authorized-ip-ranges)