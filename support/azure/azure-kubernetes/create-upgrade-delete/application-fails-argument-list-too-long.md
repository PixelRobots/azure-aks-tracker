---
layout: Conceptual
title: Argument list too long application failures - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/application-fails-argument-list-too-long
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
description: Troubleshoot an argument list too long error message that causes an application to fail in Azure Kubernetes Service (AKS).
ms.date: 2024-10-23T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, v-leedennis
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 8c4a8c36-bb46-e64b-7147-e387e33cbfdf
document_version_independent_id: 8c4a8c36-bb46-e64b-7147-e387e33cbfdf
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/application-fails-argument-list-too-long.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/application-fails-argument-list-too-long
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/application-fails-argument-list-too-long.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 8207c8dd-557c-cae1-f788-9dbe467f7b30
---

# Argument list too long application failures - Azure | Microsoft Learn

## Summary

This article discusses troubleshooting strategies for resolving application failures that are caused by the "argument list too long" error message in Microsoft Azure Kubernetes Service (AKS).

## Symptoms

Your application fails when the [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/) tries to run the executable, and you receive an error message that resembles the following output:

> 
> standard\_init\_linux.go:228: exec user process caused: argument list too long

## Cause 1: The argument list provided to the executable is too long

The arguments that are provided to the application's executable are too long to be processed.

### Solution: Shorten the argument list

Eliminate any redundant or unnecessary arguments that you specify for the executable.

## Cause 2: The set of environment variables provided to the executable is too large

If too many services are deployed in one namespace, the environment variable list can become too large, and the kubelet will produce the error message when it tries to run the executable. The error occurs because the kubelet adds environment variables that record the host and port for each active service, so that [services can use this information to find other active services](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/#accessing-the-service).

### Solution 1: Reduce the number of services that are active

You can reduce the total number of active services, so that the kubelet adds a smaller number of overall environment variables.

### Solution 2: Reconfigure the kubelet so that it doesn't add environment variables for the service host and port

Within the [PodSpec core API](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#podspec-v1-core), set the `enableServiceLinks` field to `false`. This change reconfigures the kubelet behavior so that the host and port aren't automatically added as environment variables for each active service.

Warning

If your service relies on these environment variables to find other services, this field change will cause the service to fail. To avoid this scenario, rely on DNS for service discovery instead of environment variables, by using [CoreDNS](https://kubernetes.io/docs/tasks/administer-cluster/coredns/).

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.