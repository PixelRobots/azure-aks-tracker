---
layout: Conceptual
title: Troubleshoot the K8SAPIServerConnFailVMExtensionError error code (51) - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-k8sapiserverconnfailvmextensionerror
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
description: Learn how to troubleshoot the K8SAPIServerConnFailVMExtensionError error (51) when you try to start or create and deploy an Azure Kubernetes Service (AKS) cluster.
ms.date: 2025-03-12T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, erbookbi, v-leedennis, jovieir, mariusbutuc
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: c8efd23e-3875-6a18-4793-24c358be388a
document_version_independent_id: c8efd23e-3875-6a18-4793-24c358be388a
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/error-code-k8sapiserverconnfailvmextensionerror.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/error-code-k8sapiserverconnfailvmextensionerror
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/error-code-k8sapiserverconnfailvmextensionerror.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 863d9828-a1e6-86f1-884c-7a5fb226969c
---

# Troubleshoot the K8SAPIServerConnFailVMExtensionError error code (51) - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `K8SAPIServerConnFailVMExtensionError` error (also known as error code ERR\_K8S\_API\_SERVER\_CONN\_FAIL, error number 51) that occurs when you try to start or create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- The [Netcat](https://linuxcommandlibrary.com/man/netcat) (nc) command-line tool

## Symptoms

When you try to start or create an AKS cluster, you receive the following error message:

> 
> Unable to establish connection from agents to Kubernetes API server, please see https://aka.ms/aks-required-ports-and-addresses for more information.
> 
> Details: Code="VMExtensionProvisioningError"
> 
> Message="VM has reported a failure when processing extension 'vmssCSE'.
> 
> Error message: "**Enable failed: failed to execute command: command terminated with exit status=51**\n[stdout]\n{
> 
> "ExitCode": "51",
> 
> "Output": "Thu Oct 14 18:07:37 UTC 2021,aks-nodepool1-18315663-vmss000000\nConnection to

## Cause

Your cluster nodes can't connect to your cluster API server pod.

## Solution

Run a Netcat command to verify that your nodes can resolve the cluster's fully qualified domain name (FQDN):

```shell
nc -vz <cluster-fqdn> 443
```

If you're using egress filtering through a firewall, make sure that traffic is allowed to your cluster FQDN.

In rare cases, the firewall's outbound IP address can be blocked if you've authorized IP addresses that are enabled on your cluster. In this scenario, you must add the outbound IP address of your firewall to the list of authorized IP ranges for the cluster. For more information, see [Secure access to the API server using authorized IP address ranges in AKS](/en-us/azure/aks/api-server-authorized-ip-ranges).

## More information

- [General troubleshooting of AKS cluster creation issues](troubleshoot-aks-cluster-creation-issues)