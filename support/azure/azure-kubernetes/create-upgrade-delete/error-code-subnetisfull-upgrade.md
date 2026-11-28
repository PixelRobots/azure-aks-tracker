---
layout: Conceptual
title: Troubleshoot a SubnetIsFull error code that occurs during an AKS cluster upgrade - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-subnetisfull-upgrade
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
description: Learn how to troubleshoot the SubnetIsFull error during an Azure Kubernetes Service (AKS) cluster upgrade. Free up IP addresses or add a node pool today.
ms.date: 2026-11-25T00:00:00.0000000Z
ms.reviewer: chiragpa, albarqaw, v-leedennis, kaushika, addobres
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: 924983af-bbcf-b42d-7912-a20809ce1a1f
document_version_independent_id: 924983af-bbcf-b42d-7912-a20809ce1a1f
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/error-code-subnetisfull-upgrade.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/error-code-subnetisfull-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/error-code-subnetisfull-upgrade.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 7df9e23f-fa83-4e60-a9ac-a4b72a8885bd
---

# Troubleshoot a SubnetIsFull error code that occurs during an AKS cluster upgrade - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot and resolve the "SubnetIsFull" error that occurs when you upgrade an Azure Kubernetes Service (AKS) cluster, so that you can complete the upgrade successfully.

Here's an example of the error message.

> 
> Failed to scale node pool &lt;AGENT POOL NAME&gt;' in Kubernetes service '&lt;NAME&gt;'. Error: VMSSAgentPoolReconciler retry failed: Code='SubnetIsFull' Message='&lt;SUBNET NAME&gt;\ with address prefix &lt;PREFIX&gt;\ doesn't have enough capacity for IP addresses.' Details=[]

## Prerequisites

This article requires Azure CLI version 2.0.65 or a later version. To find the version number, run `az --version`. To install or upgrade Azure CLI, see [How to install the Azure CLI](/en-us/cli/azure/install-azure-cli).

For more detailed information about the upgrade process, see [Upgrade an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/upgrade-cluster#upgrade-an-aks-cluster).

## Symptoms

An AKS cluster upgrade fails, and you receive a "SubnetIsFull" error message.

## Cause

This error occurs if your cluster doesn't have enough IP addresses to create a new node.

When you plan an upgrade or scaling operation, consider the number of required IP addresses. If the IP address range that you configured in the cluster supports only a fixed number of nodes, the upgrade or scaling operation fails. For more information, see [IP address planning for your Azure Kubernetes Service (AKS) clusters](/en-us/azure/aks/concepts-network-ip-address-planning).

## Solution 1: Not enough node subnet capacity → Free IP addresses or use a larger subnet

Reduce the cluster nodes to reserve IP addresses for the upgrade.

If scaling down isn't an option, and your virtual network Classless Inter‑Domain Routing (CIDR) has enough IP addresses, try to add a node pool that has a [unique subnet](/en-us/azure/aks/use-multiple-node-pools#add-a-node-pool-with-a-unique-subnet-preview).

Follow these steps:

1. Add a new user node pool in the virtual network on a larger subnet.
2. Switch the original node pool to a system node pool type.
3. Scale up the user node pool.
4. Scale down the original node pool.

## Solution 2: Expand the pod CIDR for an Azure CNI Overlay cluster

If your cluster uses **Azure CNI Overlay** and the **pod CIDR** doesn't have sufficient address space for the additional nodes created during the upgrade, expand the pod CIDR before retrying the upgrade.

Pod CIDR expansion has the following requirements and limitations:

- The cluster must use Azure CNI Overlay.
- The cluster must use Linux nodes. Windows nodes and hybrid node scenarios aren't supported.
- The new pod CIDR must be a larger superset that contains the complete original range.
- Shrinking or changing the pod CIDR isn't supported.
- Adding a discontinuous pod CIDR isn't supported.
- IPv6 pod CIDR expansion isn't supported.

For the complete procedure, please visit [Expand POD CIDR space in Azure CNI Overlay](/en-us/azure/aks/azure-cni-overlay-pod-expand).

Note

Pod CIDR space and the Azure virtual network subnet used by the cluster nodes are separate address spaces. Expanding the pod CIDR provides additional address space for pod allocation but doesn't increase the available IP addresses in the node subnet. If the node subnet itself doesn't have sufficient available IP addresses, use **Solution 1**.

## References

- [InsufficientSubnetSize error code](../connectivity/insufficientsubnetsize-error-advanced-networking)
- [Expand POD CIDR space in Azure CNI Overlay](/en-us/azure/aks/azure-cni-overlay-pod-expand)
- [Azure CNI Overlay in AKS concepts](/en-us/azure/aks/concepts-network-azure-cni-overlay)