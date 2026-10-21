---
layout: Conceptual
title: Troubleshoot OperationNotAllowed or PublicIPCountLimitReached error - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/operationnotallowed-publicipcountlimitreached-error
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
description: Troubleshoot the OperationNotAllowed or PublicIPCountLimitReached quota error in AKS to create and deploy clusters successfully. Follow the steps now.
ms.date: 2024-04-03T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: rissing, chiragpa, erbookbi, v-leedennis, dorinalecu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: a6e268aa-f76e-34e0-499b-32ca65068d83
document_version_independent_id: a6e268aa-f76e-34e0-499b-32ca65068d83
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/operationnotallowed-publicipcountlimitreached-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/operationnotallowed-publicipcountlimitreached-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/operationnotallowed-publicipcountlimitreached-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 7e3ba18f-e83c-856b-d16f-b8c5326305cb
---

# Troubleshoot OperationNotAllowed or PublicIPCountLimitReached error - Azure | Microsoft Learn

## Summary

This article explains how to troubleshoot the `OperationNotAllowed` or `PublicIPCountLimitReached` quota error so you can create and deploy an Azure Kubernetes Service (AKS) cluster successfully.

## Symptoms

When you try to create an AKS cluster, you receive the following error message:

> 
> **Code="OperationNotAllowed"**
> 
> Message="**Operation could not be completed as it results in exceeding approved standardEv3Family Cores quota.**
> 
> Additional details - Deployment Model: Resource Manager,
> 
> Location: uksouth,
> 
> Current Limit: 200,
> 
> Current Usage: 200,
> 
> Additional Required: 8,
> 
> (Minimum) New Limit Required: 208.
> 
> Submit a request for Quota increase at `https://aka.ms/ProdportalCRP/#blade/Microsoft_Azure_Capacity/UsageAndQuota.ReactView/Parameters/<parameter-id>` by specifying parameters listed in the 'Details' section for deployment to succeed. Please read more about quota limits at `https://learn.microsoft.com/azure/azure-supportability/per-vm-quota-requests`"

Or, you receive the following error message:

> 
> Reconcile standard load balancer failed.
> 
> Details: outboundReconciler retry failed: Category: ClientError; **SubCode: PublicIPCountLimitReached**;
> 
> **Dependency: Microsoft.Network/PublicIPAddresses;**
> 
> OrginalError: Code="PublicIPCountLimitReached"
> 
> Message="Cannot create more than 1000 public IP addresses for this subscription in this region." Details=[]; AKSTeam: Networking, Retriable: false.

## Cause

You've exhausted the quota for a resource in an SKU's region.

## Solution 1: Request a quota increase for your SKU

Typically, these error messages provide a link to create a support ticket to increase the quota for that SKU. In most cases, these requests are approved automatically, and the increased quota will be available in a short time.

If you don't have the link to request a quota increase, make the request in the Azure portal, as follows:

1. In the [Azure portal](https://portal.azure.com), search for and select **Quotas**.
2. Select **Microsoft.Compute** to view the list of quota records.
3. Use the **Location** list to filter for records from only your region.
4. In the specific record that's out-of-quota, select the pencil icon at the end of the record row.
5. In the **Request quota increase** pane, complete the **New limit** field, and then select **Submit**.

After your quota increase request is approved, you can retry the cluster creation operation.

## Solution 2: Reprovision the cluster in another region or SKU

Alternatively, you can reprovision the cluster in a different region or SKU that has enough capacity for your cluster.

## More information

- [General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)