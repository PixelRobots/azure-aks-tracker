---
layout: Conceptual
title: VMExtensionError_VHDFileNotFound when creating AKS clusters - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/vmextensionerror-vhdfilenotfound
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
description: Troubleshoot VMExtensionError_VHDFileNotFound in AKS clusters. Learn the causes and step-by-step solutions to fix this error and deploy successfully.
ms.date: 2024-10-14T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: axelg, chiragpa, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: eee0680b-0e3e-3d0a-5660-ab0192cfe7eb
document_version_independent_id: eee0680b-0e3e-3d0a-5660-ab0192cfe7eb
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/vmextensionerror-vhdfilenotfound.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/vmextensionerror-vhdfilenotfound
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/vmextensionerror-vhdfilenotfound.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 348e639a-8ba1-2c0d-3cb8-e8197848c8b4
---

# VMExtensionError_VHDFileNotFound when creating AKS clusters - Azure | Microsoft Learn

## Summary

This article explains how to identify and resolve the `VMExtensionError_VHDFileNotFound` error in Azure Kubernetes Service (AKS) when you try to create and deploy a cluster, helping you restore connectivity and complete deployment successfully.

## Symptoms

When you try to create an AKS cluster, you receive the following error message:

> 
> VMExtensionProvisioningError: VM has reported a failure when processing extension 'vmssCSE'.
> 
> Message: CSE failed with 'VMExtensionError\_VHDFileNotFound'. There was a connectivity issue between your cluster and required azure endpoints, please see `https://learn.microsoft.com/troubleshoot/azure/azure-kubernetes/error-codes/vhdfilenotfound` for more information.
> 
> "In some logs, this may also appear as exit status=65 / ExitCode: 65"

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

- [Troubleshoot the VMExtensionError_OutboundConnFail message](vmextensionerror-outboundconnfail)
- [Troubleshoot the VMExtensionError_K8SAPIServerConnFail message](vmextensionerror-k8sapiserverconnfail)
- [Troubleshoot the VMExtensionError_K8SAPIServerDNSLookupFail message](vmextensionerror-k8sapiserverdnslookupfail)

## References

- [General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)
- [Outbound network and FQDN rules for Azure Kubernetes Service (AKS) clusters](/en-us/azure/aks/outbound-rules-control-egress)