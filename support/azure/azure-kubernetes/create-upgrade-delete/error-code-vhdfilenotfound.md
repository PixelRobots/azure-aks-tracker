---
layout: Conceptual
title: Troubleshoot the ERR_VHD_FILE_NOT_FOUND error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-vhdfilenotfound
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
description: Learn how to troubleshoot the ERR_VHD_FILE_NOT_FOUND error (65) when you try to create and deploy an Azure Kubernetes Service (AKS) cluster.
ms.date: 2025-02-13T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: axelg, chiragpa, lilypan, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 7299bd8b-fdcd-b3f7-5c91-858c29ceb345
document_version_independent_id: 7299bd8b-fdcd-b3f7-5c91-858c29ceb345
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/error-code-vhdfilenotfound.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/error-code-vhdfilenotfound
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/error-code-vhdfilenotfound.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 4f15209b-11b2-7bb0-2687-22ed4c436d06
---

# Troubleshoot the ERR_VHD_FILE_NOT_FOUND error code - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `ERR_VHD_FILE_NOT_FOUND` error code (error code number 65) that occurs when you try to create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

When you try to create an AKS cluster, you receive the following error message:

> 
> VMExtensionProvisioningError: VM has reported a failure when processing extension 'vmssCSE'.
> 
> Error message: "Enable failed: failed to execute command: command terminated with exit status=65

## Cause

Under rare circumstances, the 65 exit code for the Azure Virtual Machine Scale Set custom script extension (`vmssCSE`) might happen instead of the following error codes:

| Error code name | Error code number |
| --- | --- |
| `OutboundConnFailVMExtensionError` | 50 |
| `K8SAPIServerConnFailVMExtensionError` | 51 |
| `K8SAPIServerDNSLookupFailVMExtensionError` | 52 |

This error occurs if a connectivity issue exists between your AKS cluster and the required Azure endpoints, such as `mcr.microsoft.com` or `acs-mirror.azureedge.net`.

## Solution

Review [outbound network and FQDN rules for Azure Kubernetes Service (AKS) clusters](/en-us/azure/aks/outbound-rules-control-egress) and make sure that all API services FQDN are allowed.

For detailed troubleshooting steps, refer to the troubleshooting guides in the following articles:

- [Troubleshoot the OutboundConnFailVMExtensionError error code (50)](error-code-outboundconnfailvmextensionerror)
- [Troubleshoot the K8SAPIServerConnFailVMExtensionError error code (51)](error-code-k8sapiserverconnfailvmextensionerror)
- [Troubleshoot the K8SAPIServerDNSLookupFailVMExtensionError error code (52)](error-code-k8sapiserverdnslookupfailvmextensionerror)

## References

- [General troubleshooting of AKS cluster creation issues](troubleshoot-aks-cluster-creation-issues)
- [Outbound network and FQDN rules for Azure Kubernetes Service (AKS) clusters](/en-us/azure/aks/outbound-rules-control-egress)