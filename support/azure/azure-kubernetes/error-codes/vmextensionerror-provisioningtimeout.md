---
layout: Conceptual
title: Troubleshoot the VMExtensionProvisioningTimeout error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/vmextensionerror-provisioningtimeout
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
description: Fix the VMExtensionProvisioningTimeout error in AKS. Learn to identify the cause and resolve the issue quickly.
ms.date: 2024-09-20T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: rissing, chiragpa, erbookbi, mariochaves, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 14e6253f-8d9a-d953-ac9c-2aac750dccba
document_version_independent_id: 14e6253f-8d9a-d953-ac9c-2aac750dccba
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/vmextensionerror-provisioningtimeout.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/vmextensionerror-provisioningtimeout
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/vmextensionerror-provisioningtimeout.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: aca965af-13be-a7da-aac4-36b633a8c697
---

# Troubleshoot the VMExtensionProvisioningTimeout error code - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `VMExtensionProvisioningTimeout` error that occurs when you try to create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli), version 2.28.0 or a later version. If Azure CLI is already installed, you can find the version number by running `az --version`.

## Symptoms

When you try to create an AKS cluster by using the Azure CLI, you receive the "VMExtensionProvisioningTimeout" error with text like the following example:

> 
> Code: "VMExtensionProvisioningTimeout"
> 
> Message: "Provisioning of VM extension `[extension name]` has timed out. Extension provisioning has taken too long to complete. The extension did not report a message. More information on troubleshooting is available at `https://aka.ms/vmextensionlinuxtroubleshoot`".
> 
> You also can [view the error details in the Azure portal](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues#view-error-details-in-the-azure-portal).

## Cause

Several different issues can cause the "VMExtensionProvisioningError" class of errors. However, the troubleshooting steps are the same for all the issues. Possible causes are as follows:

- The custom script extension that provisions the virtual machines (VMs) can't establish a connection to the endpoint that's used for downloading the Kubernetes binaries.
- The custom script extension that provisions the VMs can't establish a connection to the endpoint that's used for downloading the CNI binaries.
- The custom script extension that provisions the VMs can't establish the required outbound connectivity to obtain packages.
- The cluster can't resolve the necessary Domain Name System (DNS) address to correctly provision the node.
- The custom script extension that provisions the VMs reached a timeout while running a packet management update (such as [apt-get](https://manpages.ubuntu.com/manpages/xenial/man8/apt-get.8.html) in case the node pool uses Linux).

## Solution

Follow these steps:

1. If egress filtering is set up on the cluster (such as [custom user-defined routes](/en-us/azure/virtual-network/virtual-networks-udr-overview#custom-routes)), see [Limit network traffic with Azure Firewall in Azure Kubernetes Service (AKS)](/en-us/azure/aks/limit-egress-traffic) and [Outbound network and FQDN rules for AKS clusters](/en-us/azure/aks/outbound-rules-control-egress) to view the necessary prerequisites, and make sure that your setup meets the prerequisites.
2. On your DNS servers and firewall, make sure that nothing blocks the resolution of your cluster's fully qualified domain name (FQDN).
3. Because your custom DNS server might be configured incorrectly, review the following articles if FQDN resolution continues to be blocked:

    - [Create a private AKS cluster](/en-us/azure/aks/private-clusters)
    - [Private Azure Kubernetes service with custom DNS server](https://github.com/Azure/terraform/tree/00d15e09c54f25fb6387330c36aa4366122c5aaa/quickstart/301-aks-private-cluster)
    - [What is IP address 168.63.129.16?](/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16)

## More information

- [General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)