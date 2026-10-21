---
layout: Conceptual
title: InsufficientSubnetSize error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/insufficientsubnetsize-error-advanced-networking
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: jotavar
ms.author: jotavar
ms.topic: troubleshooting
description: Fix the InsufficientSubnetSize error in AKS advanced networking. Learn how to restore subnet IP capacity and deploy your cluster successfully today.
ms.date: 2026-06-09T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity
locale: en-us
document_id: c55da4b6-33fb-a282-a9db-85224be315bc
document_version_independent_id: c55da4b6-33fb-a282-a9db-85224be315bc
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/insufficientsubnetsize-error-advanced-networking.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/insufficientsubnetsize-error-advanced-networking
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/insufficientsubnetsize-error-advanced-networking.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c032dc9a-b7b2-9f1f-a593-7c5f05e3ec39
---

# InsufficientSubnetSize error code - Azure | Microsoft Learn

## Summary

Use this article to fix the `InsufficientSubnetSize` error when deploying an Azure Kubernetes Service (AKS) cluster with advanced networking. You learn why it happens and how to restore enough subnet IP capacity for successful cluster and node pool operations across Kubenet, Azure CNI, and Azure CNI Overlay.

## Symptoms

The `InsufficientSubnetSize` error occurs during any of the following operations. You also encounter this error in [AKS Diagnostics](/en-us/azure/aks/concepts-diagnostics), which proactively discovers issues such as an insufficient subnet size.

#### Operation 1: Scaling an AKS cluster or an AKS node pool

| Cluster type | Symptom:The number of free IP addresses in the subnet is*less than*... |
| --- | --- |
| Kubenet | The number of new nodes that you request. |
| Azure CNI | The number of new nodes that you request **times** the node pool value in the `--max-pod` parameter. |
| Azure CNI Overlay | The number of new nodes that you request.(In the node pools that use the autoscaler, the number of nodes is the value in the `--max-count` parameter.) |

#### Operation 2: Upgrading an AKS cluster or an AKS node pool

| Cluster type | Symptom:The number of free IP addresses in the subnet is*less than*... |
| --- | --- |
| Kubenet | The number of buffer nodes that you need to upgrade. |
| Azure CNI | The number of buffer nodes that you need to upgrade **times** the node pool value in the `--max-pod` parameter. |
| Azure CNI Overlay | The number of buffer nodes that you need to upgrade.(In the node pools that use autoscaler, the number of nodes is the value in the `--max-count` parameter.) |

By default, an AKS cluster sets a maximum surge (upgrade buffer) value of one (1). However, you can customize this upgrade behavior by setting the maximum surge value of a node pool. This action increases the number of available IP addresses that are necessary to complete an upgrade.

#### Operation 3: Creating an AKS cluster or adding an AKS node pool

| Cluster type | Symptom:The number of free IP addresses in the subnet is*less than*... |
| --- | --- |
| Kubenet | The number of nodes that you request. |
| Azure CNI | The number of nodes that you request **times** the node pool value in the `--max-pod` parameter. |
| Azure CNI Overlay | The number of nodes that you request.(In the node pools that use the autoscaler, the number of nodes is the value in the `--max-count` parameter.) |

## Cause

A subnet that's in use for a cluster no longer has available IP addresses within its Classless Inter-Domain Routing (CIDR) address space for successful resource assignment.

| Cluster type | Requirement |
| --- | --- |
| Kubenet | Sufficient IP space for each *node* in the cluster |
| Azure CNI | Sufficient IP space for each *node and pod* in the cluster |
| Azure CNI Overlay | Sufficient IP space for each *node* in the cluster |

Read more about the [design of Azure CNI to assign IP addresses to pods](/en-us/azure/aks/configure-azure-cni#plan-ip-addressing-for-your-cluster).

AKS considers all node pools in the cluster and their respective subnet. If you upgrade a node pool, AKS considers the IP requirements of all node pools in the cluster. For example, if you upgrade node pool "pool-A" in subnet "subnet-A", and there's another subnet "subnet-B" linked to another node pool "pool-B" facing IP exhaustion, then the following error might happen:

`Code: InsufficientSubnetSize; Message: Pre-allocated IPs <number> exceeds IPs available <number> in Subnet Cidr <CIDR>, Subnet Name <subnet-name>. If Autoscaler is enabled, the max-count from each nodepool is counted towards this total, which means that pre-allocated IPs count represents a theoretical max value, not the actual number of IPs requested. See http://aka.ms/aks/insufficientsubnetsize for troubleshooting steps. Surge nodes would also consume the subnet IP space, consider use smaller maxSurge or use maxUnavailable (aka.ms/aks/maxUnavailable).`

## Solution

You can't currently update a subnet's CIDR address space in an existing node pool. To migrate your workloads to a new node pool in a larger subnet, follow these steps:

1. Create a subnet in the cluster virtual network that contains a larger CIDR address range than the existing subnet. For information about how to size the subnet adequately for your cluster, see [Plan IP addressing for your cluster](/en-us/azure/aks/azure-cni-overview#plan-ip-addressing-for-your-cluster).
2. Create a node pool on the new subnet by running the [az aks nodepool add](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command together with the `--vnet-subnet-id` parameter.
3. Migrate your workloads to the new node pool by draining the nodes in the old node pool. For information about how to drain AKS worker nodes safely, see [Safely Drain a Node](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node).
4. Delete the original node pool by running the [az aks nodepool delete](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-delete) command.

Alternatively, if you have some node pools with Cluster Autoscaler enabled, you can temporarily decrease the `MaxCount` of nodes in these pools (whenever possible) so that AKS counts fewer IPs against the total available. After the scale, upgrade, or add operation finishes, you can increase the `MaxCount` back to its original value.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.