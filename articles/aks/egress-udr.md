---
layout: Conceptual
title: Customize cluster egress with a user-defined routing table in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/egress-udr
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
description: Learn how to define a custom egress route with a routing table in Azure Kubernetes Service (AKS).
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2023-05-10T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 0efe19ff-82d3-bb39-68c0-05a281b1f9b7
document_version_independent_id: ad7f5dec-f564-b5ec-fbd8-3be6d009c1c8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/egress-udr.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/egress-udr
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/egress-udr.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: 531ce591-cb3e-c239-ebe6-66f230c2eec9
---

# Customize cluster egress with a user-defined routing table in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

You can customize the egress for your Azure Kubernetes Service (AKS) clusters to fit specific scenarios. AKS provisions a `Standard` SKU load balancer for egress by default. However, the default setup may not meet the requirements of all scenarios if public IPs are disallowed or the scenario requires extra hops for egress.

This article walks through how to customize a cluster's egress route to support custom network scenarios. These scenarios include ones which disallow public IPs and require the cluster to sit behind a network virtual appliance (NVA).

## Prerequisites

- Azure CLI version 2.0.81 or greater. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- API version `2020-01-01` or greater.

## Requirements and limitations

Using outbound type is an advanced networking scenario and requires proper network configuration. The following requirements and limitations apply to using outbound type:

- Setting `outboundType` requires AKS clusters with a `vm-set-type` of `VirtualMachineScaleSets` and a `load-balancer-sku` of `Standard`.
- Setting `outboundType` to a value of `UDR` requires a user-defined route with valid outbound connectivity for the cluster.
- Setting `outboundType` to a value of `UDR` implies the ingress source IP routed to the load-balancer may **not match** the cluster's outgoing egress destination address.

## Overview of customizing egress with a user-defined routing table

AKS doesn't automatically configure egress paths if `userDefinedRouting` is set, which means you must configure the egress.

When you don't use standard load balancer (SLB) architecture, you must establish explicit egress. You must deploy your AKS cluster into an existing virtual network with a subnet that has been previously configured. This architecture requires explicitly sending egress traffic to an appliance like a firewall, gateway, or proxy, so a public IP assigned to the standard load balancer or appliance can handle the Network Address Translation (NAT).

### Load balancer creation with `userDefinedRouting`

AKS clusters with an outbound type of UDR get a standard load balancer only when the first Kubernetes service of type `loadBalancer` is deployed. The load balancer is configured with a public IP address for *inbound* requests and a backend pool for *inbound* requests. The Azure cloud provider configures inbound rules, but it **doesn't configure outbound public IP address or outbound rules**. Your UDR is the only source for egress traffic.

Note

Azure load balancers [don't incur a charge until a rule is placed](https://azure.microsoft.com/pricing/details/load-balancer/).

## Deploy a cluster with outbound type of UDR and Azure Firewall

To see an application of a cluster with outbound type using a user-defined route, see this [restrict egress traffic with Azure firewall example](limit-egress-traffic).

Important

Outbound type of UDR requires a route for 0.0.0.0/0 and a next hop destination of NVA in the route table. The route table already has a default 0.0.0.0/0 to the Internet. Without a public IP address for Azure to use for Source Network Address Translation (SNAT), simply adding this route won't provide you outbound Internet connectivity. AKS validates that you don't create a 0.0.0.0/0 route pointing to the Internet but instead to a gateway, NVA, etc. When using an outbound type of UDR, a load balancer public IP address for **inbound requests** isn't created unless you configure a service of type *loadbalancer*. AKS never creates a public IP address for **outbound requests** if you set an outbound type of UDR.