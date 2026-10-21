---
layout: Conceptual
title: Networking concepts for flex nodes (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/flex-nodes-networking-concepts
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
description: Learn how to plan API access, node and pod connectivity, address ranges, and customer-managed networking for flex nodes in AKS.
ms.topic: concept-article
ms.date: 2026-08-28T00:00:00.0000000Z
author: sdesai345
ms.author: sachidesai
ms.subservice: aks-nodes
ai-usage: ai-assisted
locale: en-us
document_id: cec10a7b-0112-0bf0-919a-c17b884d6cc3
document_version_independent_id: 4de7f68e-4499-1edd-f09f-c3da606765c4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/flex-nodes-networking-concepts.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/flex-nodes-networking-concepts
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/flex-nodes-networking-concepts.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 9ae71c61-718d-8b14-efe8-873e109ab7d6
---

# Networking concepts for flex nodes (preview) - Azure Kubernetes Service | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Flex nodes connect customer-managed Linux host machines to an Azure Kubernetes Service (AKS) cluster. Before you attach a host, plan how it reaches the AKS API server and how nodes, pods, and Kubernetes services communicate across the cluster.

## Understand the flex nodes networking model

Flex nodes use a bring-your-own networking model during public preview. You provide and maintain connectivity between the customer-managed host environment and the AKS cluster.

AKS-managed network plugins, including Azure Container Networking Interface (CNI) and Azure CNI Powered by Cilium, don't run on flex nodes during public preview. You can attach a flex node to an existing cluster that uses one of these plugins, but the plugin's pod networking, network identity, and network policy capabilities don't extend to the flex node.

The end-to-end configuration documented in [Configure networking and create a flex node pool in AKS](configure-flex-nodes-networking) creates an AKS cluster without a built-in network plugin and deploys [Unbounded-Net](https://aka.ms/unbounded/github) networking on both the AKS nodes in Azure and flex nodes. Other compatible customer-managed Container Network Interface (CNI) configurations can have different requirements and support boundaries.

## Understand multi-location pod networking

A standard CNI commonly assumes that cluster nodes already have direct network reachability. Flex nodes can run in a different Azure virtual network, region, data center, edge location, or third-party environment. Pod networking for flex nodes adds the address allocation and routing needed to connect those locations.

Flex nodes thus require a networking configuration that:

- Assigns pod address ranges to nodes without creating duplicate pod IP addresses.
- Configures local pod networking on every participating node.
- Routes pod traffic between AKS-managed nodes and flex nodes.
- Uses an existing Layer 3 path directly when both locations can reach each other's node addresses.
- Supports an encrypted gateway path for topologies that communicate over a public network.

This networking layer has two types of components. A controller manages node placement, pod address allocation, and cross-location routing state. A node agent runs on every participating AKS standard node and flex node to configure local pod networking and routes.

When a new flex node joins the cluster, the networking controller matches its internal IP address to a network location's node CIDR. The node then receives pod addresses from that location's pod CIDR.

## Make two independent network decisions

Plan AKS API exposure and flex node connectivity separately.

Note

Choosing a public or private API endpoint doesn't determine how workload traffic moves between nodes and pods.

- AKS API exposure: The first path connects the network administrator and customer-managed flex host to the AKS API server. A public AKS cluster exposes a secured public API endpoint. A private AKS cluster requires private network access and private DNS.
- Flex node connectivity: This path connects AKS standard nodes, flex nodes, pods, and Kubernetes services. It also provides the callback path from the API server to the flex node for operations such as logs, command execution, and port forwarding.

## Plan nonoverlapping address ranges

Plan separate address ranges for each part of the deployment:

| Address range | Purpose |
| --- | --- |
| **AKS node subnet and site node CIDR** | Addresses that identify AKS standard nodes as members of the AKS site. |
| **AKS pod CIDR** | Address pool from which per-node pod ranges are allocated to AKS standard nodes. |
| **Flex host subnet and site node CIDR** | Addresses that identify customer-managed hosts as members of the flex site. |
| **Flex pod CIDR** | Address pool from which per-node pod ranges are allocated to flex nodes. |
| **Kubernetes service CIDR** | Virtual addresses used by Kubernetes services. |

The AKS node, AKS pod, flex node, flex pod, and Kubernetes service ranges **should not** overlap each other or any network reachable through peering, VPN, or ExpressRoute. Each subnet must be contained within its corresponding site node CIDR. The DNS service IP must be inside the Kubernetes service CIDR.

Azure can detect some address conflicts, but it can't validate every external or routed network. Coordinate the final address plan with your network administrator.

## Flex nodes networking responsibilities

AKS provides the Kubernetes control plane, flex node pool, and machine resources. You're responsible for the external host network and the selected customer-managed multi-location CNI.

Customer responsibilities include:

- Routing between the AKS and flex host networks.
- Virtual network peering, VPN, ExpressRoute, or gateway configuration when required.
- Firewall and network security group rules.
- DNS, proxy, and outbound access configuration.
- Networking controller and node-agent installation, upgrades, health, and compatibility on all participating nodes.
- Validation of node, pod, service, DNS, outbound, and callback connectivity.