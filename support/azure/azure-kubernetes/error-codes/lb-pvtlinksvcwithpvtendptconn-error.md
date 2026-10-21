---
layout: Conceptual
title: Can't delete a load balancer with a private link service or a private link service with private endpoint connections - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/lb-pvtlinksvcwithpvtendptconn-error
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
description: Resolve AKS cluster delete errors caused by a private link service or private endpoint connection. Follow these steps to delete the cluster successfully.
ms.date: 2024-12-04T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: rissing, chiragpa, edneto, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: caeb38d2-aa79-98aa-5c33-2547076d58be
document_version_independent_id: caeb38d2-aa79-98aa-5c33-2547076d58be
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/lb-pvtlinksvcwithpvtendptconn-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/lb-pvtlinksvcwithpvtendptconn-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/lb-pvtlinksvcwithpvtendptconn-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/16cd61cd-9ecf-429b-b494-91576c41f8e4
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/c4bdb33a-5524-4b66-b162-03f5621d7902
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 92d73467-5496-bf44-e227-e22e2fc15a7d
---

# Can't delete a load balancer with a private link service or a private link service with private endpoint connections - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `CannotDeleteLoadBalancerWithPrivateLinkService` or `PrivateLinkServiceWithPrivateEndpointConnectionsCannotBeDeleted` error that occurs when you try to delete a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

When you try to delete an AKS cluster, you receive one of the following error messages:

- For the `CannotDeleteLoadBalancerWithPrivateLinkService` error code:

> 
> internalErrorCode: "CannotDeleteLoadBalancerWithPrivateLinkService"
> 
> StatusCode=BadRequest
> 
> {
> 
> "Cannot delete load balancer ...../providers/Microsoft.Network/loadBalancers/kubernetes-internal since it is referenced by private link service ...../providers/Microsoft.Network/privateLinkServices/test. Please delete private link service prior to deleting load balancer."
> 
> }
- For the `PrivateLinkServiceWithPrivateEndpointConnectionsCannotBeDeleted` error code:

> 
> internalErrorCode: "PrivateLinkServiceWithPrivateEndpointConnectionsCannotBeDeleted"
> 
> StatusCode=BadRequest
> 
> {
> 
> message: "Private link service ...../Microsoft.Network/privateLinkServices/test cannot be deleted since it has 1 private endpoint connection. Please delete all private endpoint connections before deleting the private link service."
> 
> }

## Cause

The private link service can't be deleted because the cluster is associated with private endpoint connections.

## Solution

Make sure that the private link service isn't associated with any private endpoint connections. Delete all private endpoint connections before you delete the private link service. For more information, see [Azure: How to delete a private link service that has a private endpoint connected to it?](https://stackoverflow.com/questions/60623484/azure-how-to-delete-a-private-link-service-that-has-a-private-endpoint-connecte).

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.