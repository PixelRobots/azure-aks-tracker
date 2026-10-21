---
layout: Conceptual
title: Troubleshoot WINDOWS_CSE_ERROR_CHECK_API_SERVER_CONNECTIVITY error 5 - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/windows-cse-error-check-api-server-connectivity-error
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
description: Fix the WINDOWS_CSE_ERROR_CHECK_API_SERVER_CONNECTIVITY error (5) in AKS when adding Windows node pools. Follow these steps to restore API server connectivity.
ms.date: 2023-10-31T00:00:00.0000000Z
ms.reviewer: shtao, abelch, junjiezhang, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 5593316e-13e9-8e0e-6562-c02c27798716
document_version_independent_id: 5593316e-13e9-8e0e-6562-c02c27798716
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/windows-cse-error-check-api-server-connectivity-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/windows-cse-error-check-api-server-connectivity-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/windows-cse-error-check-api-server-connectivity-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 19ed9147-cca2-4f00-ada4-accadc0d77a6
---

# Troubleshoot WINDOWS_CSE_ERROR_CHECK_API_SERVER_CONNECTIVITY error 5 - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the "WINDOWS\_CSE\_ERROR\_CHECK\_API\_SERVER\_CONNECTIVITY" error 5 that occurs when you try to add a Windows node pool in an Azure Kubernetes Service (AKS) cluster.

## Prerequisites

One of the following tools is required:

- The PowerShell command-line shell for Windows nodes.
- The [Netcat](https://linuxcommandlibrary.com/man/netcat) (`nc`) command-line tool for Linux nodes.

## Symptoms

When you try to add a Windows node pool in an AKS cluster, you receive the following error message:

> 
> Code="VMExtensionProvisioningError" Message="CSE Error: WINDOWS\_CSE\_ERROR\_CHECK\_API\_SERVER\_CONNECTIVITY." Exit Code: 5. Details: Unable to establish connection from agents to Kubernetes API server.

## Cause

Your cluster nodes can't connect to the cluster API server pod.

## Troubleshooting steps

1. Verify that your nodes can resolve the cluster's fully qualified domain name (FQDN):

    On existing Windows nodes, run the following command:

    ```powershell
    Test-NetConnection -ComputerName <cluster-fqdn> -Port 443
    ```

    Or, on existing Linux nodes, run the following command:

    ```bash
    nc -vz <cluster-fqdn> 443
    ```
2. If the command output shows `False` or `Timeout`, check your network configuration. For example, check whether you set "Deny" rules for the API server in network security groups (NSGs) of the virtual network.
3. If you're using egress filtering through a firewall, make sure that traffic is allowed to your cluster FQDN.
4. If you've authorized IP addresses that are enabled on your cluster, the firewall's outbound IP address can be blocked. In this scenario, you must add the outbound IP address of the firewall to the list of authorized IP ranges for the cluster. For more information, see [Secure access to the API server using authorized IP address ranges in AKS](/en-us/azure/aks/api-server-authorized-ip-ranges).

## References

[General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.