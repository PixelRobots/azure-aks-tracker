---
layout: Conceptual
title: Troubleshoot PublicIPCountLimitReached Error Code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/publicipcountlimitreached-error
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
description: Learn how to troubleshoot the PublicIPCountLimitReached error during Azure Kubernetes Service upgrades, then follow steps to request a quota increase.
ms.date: 2024-10-06T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: chiragpa, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 9e5fd106-2eb1-e3c2-7b69-f4265b948066
document_version_independent_id: 9e5fd106-2eb1-e3c2-7b69-f4265b948066
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/publicipcountlimitreached-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/publicipcountlimitreached-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/publicipcountlimitreached-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: c2dd20b8-96c8-afb4-31f4-b11393c1423a
---

# Troubleshoot PublicIPCountLimitReached Error Code - Azure | Microsoft Learn

## Summary

This article explains how to identify and resolve the "PublicIPCountLimitReached" error. This error occurs when you try to create, update, or upgrade an Azure Kubernetes Service (AKS) cluster. This error can also be caused by any other action that triggers the creation of a Public IP address, such as deploying a Kubernetes Service-type Public Load Balancer.

## Symptoms

An AKS cluster creation, update, upgrade, or other operation that triggers the creation of a Public IP address, such as deploying a Kubernetes Service that has a Public Load Balancer, fails and returns a "PublicIPCountLimitReached" error message.

## Cause

This error occurs if you've reached the maximum number of public IP addresses that are allowed for your subscription. The limit varies based on your subscription type. For more information about public IP address limits, refer to [this detailed guide](/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#publicip-address).

## Solution

To increase the public IP limit or quota for your subscription, follow these steps:

1. Navigate to the [Azure portal](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBladeV2), and select the subscriptions for which you're performing the operation.
2. In the **Settings** section, select **Usage + quotas**. Set the **Provider** to **Networking**, and optionally filter by the region of your AKS cluster.
3. Locate the **Public IP Addresses** record. On the same line, select the **Create a new support request** button.

    [![Screenshot of creating a support request for a Public IP address quota increase.](media/publicipcountlimitreached-error/submit-quotas-request.png)](media/publicipcountlimitreached-error/submit-quotas-request.png#lightbox)
4. On the **New support request** page, specify the new limit that you require, and then follow the instructions to create the support request.

    [![Screenshot of specifying the new limit for public IP addresses.](media/publicipcountlimitreached-error/new-limit-public-ip.png)](media/publicipcountlimitreached-error/new-limit-public-ip.png#lightbox)

After the quota change takes effect, retry the operation that initially triggered the "PublicIPCountLimitReached" error.