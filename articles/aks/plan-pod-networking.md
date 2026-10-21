---
layout: Conceptual
title: Plan Pod Networking for Azure Kubernetes Service (AKS) Workloads - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/plan-pod-networking
breadcrumb_path: /azure/breadcrumb/azure-aks/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/200/azure-kubernetes-service/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: This article provides an overview of the networking components you need to consider for Azure Kubernetes Service (AKS) pods.
ms.topic: overview
ms.subservice: aks-networking
ms.date: 2026-09-09T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: 6143bd00-2987-ae44-ffa4-3c102fe49620
document_version_independent_id: bc2f0828-7cc3-7b19-e922-71f4a22e9bbb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/plan-pod-networking.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/plan-pod-networking
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/plan-pod-networking.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 0d7c02a7-4c40-61bc-09e2-9142ee063617
---

# Plan Pod Networking for Azure Kubernetes Service (AKS) Workloads - Azure Kubernetes Service | Microsoft Learn

Choose a pod networking configuration based on whether pods need direct IP access from connected networks and your IP address scale requirements.

## Do you need direct pod IP access?

Pod networking controls how pods get IP addresses and defines how pods communicate with each other, cluster nodes, and destinations outside the cluster. Kubernetes implements pod networking through a *Container Network Interface (CNI)* plugin, which manages pod IP addresses and network connectivity.

When setting up pod networking, you need to plan for **IP address management (IPAM)** and **routing and transport (data plane)**.

If your workloads require pods to be reachable by private IP from networks connected to the Azure Kubernetes Service (AKS) cluster VNet, use a Flat Networking Model. Otherwise, use Azure CNI Overlay.

## IP address management (IPAM) options

When setting up IPAM, you can choose between an **Overlay Networking Model** with **[Azure CNI Overlay](concepts-network-azure-cni-overlay)** and a **Flat Networking Model** with **[Azure CNI Pod Subnet](concepts-network-azure-cni-pod-subnet)** or **[Azure CNI Node Subnet](concepts-network-legacy-cni#azure-cni-node-subnet)**:

The following table compares the IPAM options available for AKS pod networking, including their key features and scale limits.

| IPAM options | Diagram of networking components | Features & functionality |
| --- | --- | --- |
| Overlay Networking Model (with Azure CNI Overlay) | ![Screenshot of a diagram of the networking components of an Overlay Networking Model.](media/plan-networking/overlay-networking.png) | • Pod IPs come from an overlay range that's *not* part of the VNet space.  • Highly scalable networking, with *up to 5,000 nodes* and *200,000 pods per cluster*. The node, per-node pod, and aggregate pod limits are independent.  • Pod overlay address space can be reused across independent clusters. The pod CIDR must not overlap with directly connected networks, including peered VNets, networks connected through ExpressRoute or a VPN, and other routes that expose private address space.  • Dual-stack (IPv4/IPv6) support.  • Pods can't be accessed directly from outside the cluster. |
| Flat Networking Model (with Azure CNI Pod Subnet *or* Node Subnet) | ![Screenshot of a diagram of the networking components of a Flat Networking Model.](media/plan-networking/flat-networking.png) | • Node and pod IPs come from VNet space.  • Pods can be accessed by their private IP addresses from connected networks. Azure CNI Pod Subnet preserves the pod source IP across connected VNets, while destinations outside the cluster VNet see the node source IP with Azure CNI Node Subnet.  • Azure CNI Pod Subnet options include **[Dynamic IP Allocation](configure-azure-cni-dynamic-ip-allocation)** for efficiency or **[Static Block Allocation](configure-azure-cni-static-block-allocation)** for scale. |

### Considerations for Flat Networking Model options

Keep the following considerations in mind when deciding between **Azure CNI Pod Subnet with Dynamic IP Allocation**, **Azure CNI Pod Subnet with Static Block Allocation**, and **Azure CNI Node Subnet**:

| Flat Networking Model option | Considerations |
| --- | --- |
| Azure CNI Pod Subnet with Dynamic IP Allocation | • Requires separate node and pod subnets that you can size and scale independently.  • Allocates pod IP addresses to nodes from the pod subnet in batches of 16.  • Subject to VNet configured private IP address limits. |
| Azure CNI Pod Subnet with Static Block Allocation | • Requires careful planning, as you need to allocate a specific range of IPs for your pods and ensure it doesn't overlap with other subnets.  • Can get *up to 1,000,000 IPs*.  • IPs might not be used as efficiently, which could lead to wastage. |
| Azure CNI Node Subnet | • Legacy option that can use an AKS-managed VNet or a customer-managed VNet and subnet.  • Nodes and pods share the node subnet, so you need to plan capacity in advance for nodes, pods, scaling, and upgrades.  • Subject to VNet configured private IP address limits. |

## Routing and transport (data plane) options

When setting up your data plane, you can choose between [**Azure CNI Powered by Cilium**](azure-cni-powered-by-cilium), [**Azure iptables data plane**](configure-azure-cni), and [**BYO CNI**](use-byo-cni):

The following table compares the data plane options available for AKS pod networking and their key capabilities.

| Data plane options | Features & functionality |
| --- | --- |
| Azure CNI Powered by Cilium | • Improved scale and performance for Linux node pools. Windows node pools aren't supported.  • Built-in Cilium network policy enforcement.  • FQDN filtering requires Advanced Container Networking Services and Kubernetes 1.29 or later. |
| Azure iptables | • Use *Calico* for Windows network policy enforcement. Azure Network Policy Manager (NPM) support ends on September 30, 2026, for Windows and September 30, 2028, for Linux. New subscriptions can no longer enable Azure NPM.  • For Linux clusters, use Azure CNI Powered by Cilium instead of Azure NPM.  • Supports Kubernetes NetworkPolicy. |
| BYO CNI | • No managed CNI plugin installed - you can use any option that supports AKS.  • Microsoft *doesn't support* any CNI-related issues. |

## AKS pod networking recommendations

Our **general recommendation** is to use **Azure CNI Overlay**. If you **need direct pod IP access from connected networks and have efficiency or scale requirements**, consider using **Azure CNI Pod Subnet with Dynamic IP Allocation** or **Azure CNI Pod Subnet with Static Block Allocation**. Azure CNI Node Subnet is a legacy option; in general, use it only if you need an AKS-managed VNet for your cluster.