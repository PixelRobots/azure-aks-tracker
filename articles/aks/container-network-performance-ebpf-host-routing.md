---
layout: Conceptual
title: eBPF Host Routing with Advanced Container Networking Services (ACNS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/container-network-performance-ebpf-host-routing
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
description: An overview of eBPF Host Routing on Advanced Container Networking Services with Azure Kubernetes Service (AKS).
author: sf-msft
ms.author: samfoo
ms.subservice: aks-networking
ms.topic: concept-article
ms.date: 2025-09-23T00:00:00.0000000Z
locale: en-us
document_id: 596c9776-eb3f-dce5-770d-f1e02bd37dda
document_version_independent_id: 08f423dc-5911-c30c-37c4-2e8a7f32c128
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/container-network-performance-ebpf-host-routing.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/container-network-performance-ebpf-host-routing
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/container-network-performance-ebpf-host-routing.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 77116777-ca7d-d308-02e6-89b0ca1b56f6
---

# eBPF Host Routing with Advanced Container Networking Services (ACNS) - Azure Kubernetes Service | Microsoft Learn

As containerized workloads scale across distributed environments, the need for high-performance, low-latency networking becomes critical. eBPF Host Routing is a performance-focused feature within [Advanced Container Networking Services (ACNS)](advanced-container-networking-services-overview) that uses extended Berkeley Packet Filter (eBPF) technology to optimize traffic flow in Kubernetes clusters. Legacy routing on Kubernetes hosts introduces overhead in the form of iptables and netfilter rule processing in the host network namespace. eBPF Host Routing has benefits over legacy host routing by:

- Implementing the routing logic in eBPF programs.
- Allowing Cilium eBPF to bypass iptables in the host namespace.

This direct path reduces the number of hops and processing layers, resulting in faster packet delivery.

## Key benefits

Reduced latency - Bypassing iptables in host results in lower pod-to-pod latency

Increased throughput - Compared to legacy routing, significant improvements can be observed for pod-to-pod traffic between nodes

Reduced CPU usage - Due to removing iptables-based SNAT and routing logic, a modest reduction of CPU usage

Use cases for eBPF Host Routing are performance-critical workloads such as high-throughput microservices, real-time services, or AI/ML workloads. Ensure deployment environment meets the requirements before enabling.

## Components of eBPF Host Routing

**`iptables blocker`** - An init container that prevents any future installation of iptables rules in the host network namespace (such rules will be bypassed when eBPF host routing is enabled).

**`IP Masquerade Agent`** - When eBPF Host Routing is active, Cilium takes over SNAT responsibilities using BPF-based masquerading. `ip-masq-agent` remains running to maintain consistent behavior if eBPF Host Routing is later disabled; however, its iptables rules are ignored while eBPF Host Routing is active.

## Considerations

- Enabling eBPF Host Routing causes iptables rules in the host network namespace to be bypassed. Hence, AKS attempts to detect and block enablement of eBPF Host Routing on clusters where iptables rules are in use in the host network namespace.
- On clusters with eBPF host routing enabled, AKS blocks attempts to install iptables rules in the host network namespace. Trying to bypass this block may cause the cluster to be inoperational.
- Enabling eBPF Host Routing updates nodes by [rolling upgrades for node pools](upgrade-aks-node-pools-rolling) to respect existing connections through node drain timeout. Nodes are labeled `kubernetes.azure.com/ebpf-host-routing=true` once eBPF Host Routing is enabled on a given node.
- Dual-stack connectivity is supported by eBPF Host Routing.

## Limitations

- eBPF Host Routing is currently incompatible with nodes running OSes other than Ubuntu 24.04, or Azure Linux 3.0. eBPF host routing is currently also not supported with Confidential VMs and Pod Sandboxing.
- eBPF Host Routing can only be enabled for all nodes in a cluster. Hybrid node scenarios aren't supported.
- Windows nodes aren't supported by Azure CNI Powered by Cilium, and by extension, eBPF Host Routing.
- eBPF Host Routing can't be used with [Static Egress Gateway](configure-static-egress-gateway).
- Istio Ambient through a self-managed installation with ACNS Performance mode isn't supported.

## Pricing

Important

Advanced Container Networking Services is a paid offering. For more information about pricing, see [Advanced Container Networking Services - Pricing](https://azure.microsoft.com/pricing/details/azure-container-networking-services/).