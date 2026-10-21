---
layout: Conceptual
title: Troubleshoot the VMExtensionError_CniDownloadTimeout message - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/vmextensionerror-cnidownloadtimeout
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
description: Fix the VMExtensionError_CniDownloadTimeout error in AKS. Learn why CNI download fails and follow step-by-step guidance to deploy your cluster successfully.
ms.date: 2023-05-03T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: axelg, chiragpa, mariochaves, v-weizhu, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: eb4cc7c2-a2a8-d224-f4ed-17645e65139e
document_version_independent_id: eb4cc7c2-a2a8-d224-f4ed-17645e65139e
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/vmextensionerror-cnidownloadtimeout.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/vmextensionerror-cnidownloadtimeout
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/vmextensionerror-cnidownloadtimeout.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: b6a5f203-e0f5-ab64-90a1-fe991dd80b3e
---

# Troubleshoot the VMExtensionError_CniDownloadTimeout message - Azure | Microsoft Learn

## Summary

This article explains how to identify and resolve the `VMExtensionError_CniDownloadTimeout` error (also known as error code `ERR_CNI_DOWNLOAD_TIMEOUT`) in Azure Kubernetes Service (AKS) so that you can successfully create and deploy your cluster.

## Prerequisites

- The [Curl](https://curl.se/download.html) command-line tool

## Symptoms

When you try to create a Linux-based AKS cluster, you receive the following error message:

> 
> Code: "VMExtensionProvisioningError"
> 
> Message: CSE failed with 'VMExtensionError\_CniDownloadTimeout', which means agents are unable to connect to the endpoint that's used to download the container network interface libraries. It's likely that a network virtual appliance is blocking SSL communication or an SSL certificate, please see https://aka.ms/aks/vmextensionerror_cnidownloadtimeout for more information.
> 
> "In some logs, this may also appear as exit status=41 / ExitCode: 41"

## Cause

Your cluster nodes can't connect to the endpoint that's used to download the Container Network Interface (CNI) libraries. In most cases, this issue occurs because a network virtual appliance is blocking Secure Sockets Layer (SSL) communication or an SSL certificate.

## Solution

Run a Curl command to verify that your nodes can download the binaries:

```bash
curl https://acs-mirror.azureedge.net/cni/azure-vnet-cni-linux-amd64-v1.0.25.tgz

curl --fail --ssl https://acs-mirror.azureedge.net/cni/azure-vnet-cni-linux-amd64-v1.0.25.tgz  --output /opt/cni/downloads/azure-vnet-cni-linux-amd64-v1.0.25.tgz
```

If you can't download these files, make sure that traffic is allowed to the downloading endpoint. For more information, see [Azure Global required FQDN/application rules](/en-us/azure/aks/outbound-rules-control-egress#azure-global-required-fqdn--application-rules).

## References

- [General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)