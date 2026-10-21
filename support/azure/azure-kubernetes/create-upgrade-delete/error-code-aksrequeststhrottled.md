---
layout: Conceptual
title: Troubleshoot Throttled Error Code (429) - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-aksrequeststhrottled
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
description: Introduces how to resolve the Throttled error (status 429) when you try to create and deploy an Azure Kubernetes Service (AKS) cluster.
ms.date: 2025-03-05T00:00:00.0000000Z
ms.reviewer: jovieir, chiragpa, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: aca92b1d-7e38-8ca2-3d63-671e0b8511d4
document_version_independent_id: aca92b1d-7e38-8ca2-3d63-671e0b8511d4
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/error-code-aksrequeststhrottled.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/error-code-aksrequeststhrottled
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/error-code-aksrequeststhrottled.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: ffef5e94-a9d4-ae28-1cff-b6d83f856916
---

# Troubleshoot Throttled Error Code (429) - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `Throttled` error (status 429) that occurs when you try to create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

When you try to create an AKS cluster, you receive the following "The PutManagedClusterHandler.PUT request limit has been exceeded" error message that shows a "SubCode" value of **Throttled** and a "Status" value of **429**:

> 
> Category: ClientError;
> 
> SubCode: Throttled;
> 
> OrginalError: autorest/azure: Service returned an error. **Status=429**
> 
> **Code="Throttled"**
> 
> Message="&gt; The PutManagedClusterHandler.PUT request limit has been exceeded for SubID='*&lt;subscription-id-guid&gt;*', please retry again in X seconds. For more information, please visit aka.ms/aks/throttling"; Request throttling can occur on various Azure components, so the error message might be different depending on the type of resource where this issue occurs.

Resource provider throttling is independent of ARM throttling and is tailored to the operations of a specific resource provider. In this scenario, AKS resource provider throttling is specific to the AKS resource provider and applies only to operations related to AKS resources.

## Cause

AKS requests are throttled. For information about how AKS limits work and the specific limits per hour, see [Throttling limits on AKS resource provider APIs](/en-us/azure/aks/quotas-skus-regions#throttling-limits-on-aks-resource-provider-apis).

## Solution

To resolve this issue, examine and modify your access pattern of the throttled subscription. The following table lists the possible access patterns and corresponding solutions.

| Access pattern | Solution |
| --- | --- |
| Automated scripts constantly run LIST operations against managedCluster resources. | Run the scripts less frequently. |
| Users attempt to deploy multiple AKS clusters in a short period of time. | Space out deployments or use different subscriptions. |
| Users attempt to modify the same AKS cluster multiple times consecutively. | Space out operations. Ensure successful completion before initiating another one. |
| Users attempt to add, modify, or delete one or more agentPools on the same AKS cluster. | Space out operations. Ensure successful completion before initiating another one. |

## More information

[General troubleshooting of AKS cluster creation issues](troubleshoot-aks-cluster-creation-issues)