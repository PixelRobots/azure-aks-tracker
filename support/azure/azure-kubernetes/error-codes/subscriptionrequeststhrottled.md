---
layout: Conceptual
title: Troubleshoot the SubscriptionRequestsThrottled error code (429) - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/subscriptionrequeststhrottled
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
description: Fix the SubscriptionRequestsThrottled error (429) in AKS. Discover what causes Azure request throttling and how to resolve it to successfully create and deploy your cluster.
ms.date: 2024-09-10T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: rissing, chiragpa, erbookbi, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: c7d5741a-7b3a-0884-938c-fec9336c0f19
document_version_independent_id: c7d5741a-7b3a-0884-938c-fec9336c0f19
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/subscriptionrequeststhrottled.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/subscriptionrequeststhrottled
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/subscriptionrequeststhrottled.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: fa45278c-8b00-b4b5-cc93-5bb7c2b143bb
---

# Troubleshoot the SubscriptionRequestsThrottled error code (429) - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `SubscriptionRequestsThrottled` error (status 429) that occurs when you try to create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

When you try to create an AKS cluster, you receive the following "Reconcile standard load balancer failed" error message that shows a "SubCode" value of **SubscriptionRequestsThrottled** and a "Status" value of **429**:

> 
> Reconcile standard load balancer failed.
> 
> Details: outboundReconciler retry failed:
> 
> Category: ClientError;
> 
> SubCode: SubscriptionRequestsThrottled;
> 
> Dependency: Microsoft.Network/PublicIPAddresses;
> 
> OrginalError: autorest/azure: Service returned an error. **Status=429**
> 
> **Code="SubscriptionRequestsThrottled"**
> 
> Message="Number of requests for subscription '*&lt;subscription-id-guid&gt;*' and operation 'GET/SUBSCRIPTIONS/RESOURCEGROUPS/PROVIDERS/MICROSOFT.NETWORK/PUBLICIPADDRESSES' exceeded the backend storage limit. Please try again after '6' seconds.";
> 
> AKSTeam: Networking, Retriable: false.

Request throttling can occur on different Azure components, so the error message might be different based on the kind of resource this issue is occurring on.

## Cause

Azure Resource Manager requests are being throttled. For information about how Azure Resource Manager limits work, and the specific limits per hour, see [Throttling Resource Manager requests](/en-us/azure/azure-resource-manager/management/request-limits-and-throttling).

## Solution 1: Use another subscription

If you have access to a different subscription, you can simply deploy the cluster to that subscription.

## Solution 2: Modify your access patterns

To resolve this issue, examine your access patterns for the throttled subscription. The following table lists the possible access patterns and corresponding solutions.

| Access pattern | Solution |
| --- | --- |
| Automated scripts constantly scan the subscription | Run the scripts less frequently |
| Many users access the subscription | Have each user use their own subscription |
| Scripts scan every storage account in the subscription | Scope the script to query only the resources that it must have |

## More information

- [General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)