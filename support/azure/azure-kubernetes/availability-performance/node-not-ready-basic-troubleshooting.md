---
layout: Conceptual
title: Basic troubleshooting for Node Not Ready problems in Azure Kubernetes Service - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/node-not-ready-basic-troubleshooting
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
description: Troubleshoot Node Not Ready problems in Azure Kubernetes Service (AKS) cluster nodes. Follow these steps to identify causes and recover your nodes quickly.
ms.date: 2026-07-20T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, momajed, v-leedennis, wonkilee, v-weizhu, mariusbutuc
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance
locale: en-us
document_id: 12341141-4481-46c4-61dc-05e7a1626967
document_version_independent_id: 12341141-4481-46c4-61dc-05e7a1626967
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/node-not-ready-basic-troubleshooting.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/node-not-ready-basic-troubleshooting
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/node-not-ready-basic-troubleshooting.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/a3955c7b-f5ee-420d-aff5-d7119738f38b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/b31948f4-2f38-404b-ac93-c3c8c5b3ae33
platformId: a8b34fa8-d72d-5827-3335-66d05e94ed05
---

# Basic troubleshooting for Node Not Ready problems in Azure Kubernetes Service - Azure | Microsoft Learn

## Summary

This article provides troubleshooting steps to recover Azure Kubernetes Service (AKS) cluster nodes after a failure. It specifically addresses the most common error messages that appear when a Node Not Ready failure occurs, and explains how to repair nodes for both Windows and Linux nodes.

## Before you begin

Read the [official guide for troubleshooting Kubernetes clusters](https://kubernetes.io/docs/tasks/debug/debug-cluster/_print/). Also, read the [Microsoft engineer's guide to Kubernetes troubleshooting](https://github.com/feiskyer/kubernetes-handbook/blob/master/en/troubleshooting/index.md). This guide contains commands for troubleshooting pods, nodes, clusters, and other features.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli), version 2.31 or later. If you already have Azure CLI installed, run `az --version` to check your version.

## Basic troubleshooting

AKS continuously monitors the health state of worker nodes, and [automatically repairs](/en-us/azure/aks/node-auto-repair) the nodes if they become unhealthy. The Azure Virtual Machine (VM) platform [maintains VMs](/en-us/azure/virtual-machines/maintenance-and-updates) that experience issues. AKS and Azure VMs work together to reduce service disruptions for clusters.

For nodes, there are two forms of heartbeats:

- Updates to the *.status* of a `Node` object.
- [Lease](https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/lease-v1/) objects within the [kube-node-lease](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) namespace. Each `Node` has an associated `Lease` object.

Compared to updates to the *.status* of a `Node`, a `Lease` is a lightweight resource. Using `Lease` objects for heartbeats reduces the performance impact of these updates for large clusters.

The [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/) is responsible for creating and updating the *.status* for `Node` objects. It's also responsible for updating the `Lease` objects that are related to the `Node` objects.

- The kubelet updates the node `.status` when there's a change in status or if there hasn't been an update for a configured interval. The default interval for `.status` updates to nodes is five minutes, which is much longer than the 40-second default time-out for unreachable nodes.
- The kubelet creates and then updates its `Lease` object every 10 seconds (the default update interval). `Lease` updates occur independently from updates to the node `.status`. If the `Lease` update fails, the kubelet retries, using an exponential backoff that starts at 200 milliseconds and is capped at seven seconds.

You can't schedule a pod on a node that has a status of `NotReady` or `Unknown`. You can schedule a pod only on nodes that are in the `Ready` state.

If your node is in the `MemoryPressure`, `DiskPressure`, or `PIDPressure` state, you must manage your resources to schedule extra pods on the node. If your node is in `NetworkUnavailable` mode, you must configure the network on the node correctly.

AKS manages the lifecycle and operations of agent nodes for you. Modifying the IaaS resources associated with the agent nodes isn't supported. For example, customizing a node through SSH connections, updating packages, or changing the network configuration on a node isn't supported. For more information, see [AKS support coverage for agent nodes](/en-us/azure/aks/support-policies#user-customization-of-agent-nodes).

Make sure that the following conditions are met:

- Your cluster is in **Succeeded (Running)** state. To check the cluster status on the [Azure portal](https://portal.azure.com), search for and select **Kubernetes services**, and select the name of your AKS cluster. Then, on the cluster's **Overview** page, look in **Essentials** to find the **Status**. Or, enter the [az aks show](/en-us/cli/azure/aks#az-aks-show) command in Azure CLI.

    ![Screenshot of an Azure Kubernetes Service (AKS) cluster Overview page in the Azure portal. In the Essentials section, the Status field shows 'Succeeded (Running)'.](media/node-not-ready-basic-troubleshooting/aks-cluster-overview-page-essentials-status.png)
- Your node pool has a **Provisioning state** of **Succeeded** and a **Power state** of **Running**. To check the node pool status on the Azure portal, return to your AKS cluster's page, and then select **Node pools**. Alternatively, enter the [az aks nodepool show](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-show) command in Azure CLI.

    ![Screenshot of an Azure Kubernetes Service (AKS) cluster Node pools page in the Azure portal. The Provisioning state is Succeeded and the Power state is Running.](media/node-not-ready-basic-troubleshooting/aks-cluster-node-pools.png)
- The required egress ports are open in your network security groups (NSGs) and firewall so that the API server's IP address can be reached. For more information, see [Required outbound network rules and FQDNs for AKS clusters](/en-us/azure/aks/limit-egress-traffic#required-outbound-network-rules-and-fqdns-for-aks-clusters).
- Your nodes [have deployed the latest node images](/en-us/azure/aks/node-image-upgrade).
- Your nodes are in the `Running` state instead of `Stopped` or `Deallocated`.
- Your cluster is running an [AKS-supported version of Kubernetes](/en-us/azure/aks/supported-kubernetes-versions).

## More information

To troubleshoot the `Not Ready` status of a node, see [Troubleshoot a change in a healthy node to Not Ready status](node-not-ready-after-being-healthy).

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.