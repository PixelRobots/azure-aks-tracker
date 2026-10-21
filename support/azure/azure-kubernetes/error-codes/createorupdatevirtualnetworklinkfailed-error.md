---
layout: Conceptual
title: CreateOrUpdateVirtualNetworkLinkFailed Error Code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/createorupdatevirtualnetworklinkfailed-error
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
description: Learn how to fix the CreateOrUpdateVirtualNetworkLinkFailed error when updating or upgrading an AKS cluster. Follow these steps to resolve it.
ms.date: 2024-03-13T00:00:00.0000000Z
ms.reviewer: axelg, chiragpa, jpalma, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 43c54c71-a404-877a-bafa-04d33e478ebd
document_version_independent_id: 43c54c71-a404-877a-bafa-04d33e478ebd
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/createorupdatevirtualnetworklinkfailed-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/createorupdatevirtualnetworklinkfailed-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/createorupdatevirtualnetworklinkfailed-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
platformId: 5dd8187e-ab0d-1afd-9ab9-92bb6c1d3f5d
---

# CreateOrUpdateVirtualNetworkLinkFailed Error Code - Azure | Microsoft Learn

## Summary

This article provides a solution to the "CreateOrUpdateVirtualNetworkLinkFailed" error code that occurs when you try to update or upgrade a Microsoft Azure Kubernetes Service (AKS) cluster.

## Prerequisites

[Azure CLI](/en-us/cli/azure/install-azure-cli)

## Symptoms

An AKS cluster update or upgrade operation fails and returns the following error message:

> 
> **Code: CreateOrUpdateVirtualNetworkLinkFailed** - SubCode: BadRequest
> 
> Message: Reconcile private dns failed
> 
> Details: Create or update virtual network link failed. Subscription: &lt;SubscriptionID&gt;; resource group: &lt;RGName&gt;; private dns zone: &lt;GUID&gt;.privatelink.&lt;region&gt;.azmk8s.io; virtual network link: &lt;VNET\_Link&gt;.
> 
> Message: A virtual network cannot be linked to multiple zones with overlapping namespaces. You tried to link virtual network with '&lt;GUID&gt;.privatelink.&lt;region&gt;.azmk8s.io' and '&lt;GUID&gt;.privatelink.&lt;region&gt;.azmk8s.io' zones.

## Cause

This error happens in this scenario:

- You disassociate the original private Domain Name System (DNS) zone of the AKS cluster.
- You link a private DNS zone that has the same name as the original zone but is located in a different resource group or subscription.

That's why you see the same private DNS zone name "&lt;GUID&gt;.privatelink.&lt;region&gt;.azmk8s.io" in the error message. The first is the new zone in the new resource group or subscription, while the second is the original zone created with the AKS cluster.

## Solution

To resolve this issue, follow these steps:

1. Remove the link between the AKS cluster's virtual network (VNET) and the private DNS zone created in the wrong resource group or subscription.
2. Update the cluster by running the following command:

    ```azurecli
    az aks update  -n <myAKSCluster> -g <myResourceGroup>
    ```

    The command output should show the cluster's `ProvisioningState` as `Running`.