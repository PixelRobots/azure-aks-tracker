---
layout: Conceptual
title: Concepts - Networking in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-network
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
description: Learn how AKS provides application networking through virtual network models, egress controls, network security groups, DNS, and network policies.
ms.topic: concept-article
ms.subservice: aks-networking
ms.date: 2026-09-04T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: fasttrack-edit
locale: en-us
document_id: b2aebd77-53f0-b2b0-2af4-46b95b1b4d82
document_version_independent_id: be2ca189-d338-6a3b-2303-1d08fad6def1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-network.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-network
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-network.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 6a54186d-3b00-4b26-57f9-47242f389846
---

# Concepts - Networking in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In a container-based, microservices approach to application development, application components work together to process their tasks. Kubernetes provides various resources enabling this cooperation:

- You can connect to and expose applications internally or externally.
- You can build highly available applications by load balancing your applications.
- You can restrict the flow of network traffic into or between pods and nodes to improve security.
- You can configure Ingress traffic for SSL/TLS termination or routing of multiple components for your more complex applications.

This article introduces the core concepts that provide networking to your applications in AKS:

- Azure virtual networks
- Network policies

## Kubernetes networking basics

Kubernetes employs a virtual networking layer to manage access within and between your applications or their components:

- **Kubernetes nodes and virtual network**: Kubernetes nodes are connected to a virtual network. This setup enables pods (basic units of deployment in Kubernetes) to have both inbound and outbound connectivity.
- **Service routing component**: Depending on the network data plane, nodes use either `kube-proxy` or Cilium for Kubernetes Service routing. AKS clusters that use Azure CNI Powered by Cilium don't use `kube-proxy`.

Regarding specific Kubernetes functionalities:

- **Load balancer**: You can use a load balancer to distribute network traffic evenly across various resources.
- **Ingress controllers**: These facilitate Layer 7 routing, which is essential for directing application traffic.
- **Egress traffic control**: Kubernetes allows you to manage and control outbound traffic from cluster nodes.
- **Network policies**: These policies enable security measures and filtering for network traffic in pods.

In the context of the Azure platform:

- Azure streamlines virtual networking for AKS (Azure Kubernetes Service) clusters.
- Creating a Kubernetes load balancer on Azure simultaneously sets up the corresponding Azure load balancer resource.
- When you create a Kubernetes `LoadBalancer` Service, Azure configures the necessary network security group rules for service traffic on resources managed by AKS.
- Azure can also manage external DNS configurations for HTTP application routing as new Ingress routes are established.

## Azure virtual networks

In AKS, you can deploy a cluster that uses one of the following network models:

- **Overlay network model**: Overlay networking is the most common networking model used in Kubernetes. Pods are given an IP address from a private, logically separate CIDR from the Azure virtual network subnet where AKS nodes are deployed. This model enables simpler, improved scalability when compared to the flat network model.
- **Flat network model**: A flat network model in AKS assigns IP addresses to pods from a subnet in the same Azure virtual network as the AKS nodes. For private network traffic, the source IP address that a destination sees depends on the IP address management (IPAM) option. Azure CNI Pod Subnet preserves the pod IP address across connected virtual networks. With Azure CNI Node Subnet, destinations in the cluster virtual network see the pod IP address, but destinations outside the cluster virtual network see the node IP address. For internet egress, the configured outbound method determines the public source IP address that internet destinations see.

For more information on networking models in AKS, see [CNI Networking in AKS](concepts-network-cni-overview).

## Control outbound (egress) traffic

AKS clusters are deployed on a virtual network and have outbound dependencies on services outside of that virtual network, which are almost entirely defined with fully qualified domain names (FQDNs). AKS provides several outbound configuration options which allow you to customize the way in which these external resources are accessed.

Important

Starting on **March 31, 2026**, Azure Kubernetes Service (AKS) no longer supports default outbound access for virtual machines (VMs). New AKS clusters that use the **AKS-managed virtual network** option will place cluster subnets into [private subnets](/en-us/azure/virtual-network/ip-services/default-outbound-access#why-is-disabling-default-outbound-access-recommended) by default (`defaultOutboundAccess = false`). This setting **doesn't impact AKS-managed cluster traffic**, which uses explicitly configured outbound paths. It might affect **unsupported scenarios**, such as deploying other resources into the same subnet. Clusters using **BYO VNets are unaffected** by this change. In supported configurations, no action is required. For more information on this retirement, see the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=default-outbound-access-for-vms-in-azure-will-be-retired-transition-to-a-new-method-of-internet-access). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

### Outbound configuration options

For more information on the supported AKS cluster outbound configuration types, see [Customize cluster egress with outbound types in Azure Kubernetes Service (AKS)](egress-outboundtype).

By default, AKS clusters have unrestricted outbound (egress) Internet access, which allows the nodes and services you run to access external resources as needed. If desired, you can restrict outbound traffic.

For more information on how to restrict outbound traffic from your cluster see [Control egress traffic for cluster nodes in AKS](limit-egress-traffic).

## Network security groups

A network security group filters traffic for VMs like the AKS nodes. As you create Services, such as a `LoadBalancer`, the Azure platform automatically configures the necessary network security group rules for service traffic on resources managed by AKS.

AKS doesn't apply network security groups to its subnet or modify network security groups that you associate with a customer-provided subnet. If you associate a network security group with a custom subnet, you must ensure that its rules allow the required node and pod traffic. For more information, see [AKS CNI networking prerequisites](concepts-network-cni-overview#aks-cni-networking-prerequisites).

You can also use network policies to automatically apply traffic filter rules to pods.

For more information, see [How network security groups filter network traffic](/en-us/azure/virtual-network/network-security-group-how-it-works).

### Custom virtual network requirements

When you use a custom virtual network with AKS clusters, if you add network security group rules to restrict traffic between subnets, ensure that the rules allow the traffic required by your cluster configuration.

API Server VNet Integration is preconfigured in AKS Automatic. In AKS Standard, the feature is optional and you must enable it explicitly. When your cluster uses API Server VNet Integration, allow the following traffic:

| Destination | Source | Protocol | Port | Use |
| --- | --- | --- | --- | --- |
| APIServer Subnet CIDR | Cluster Subnet | TCP | 443 and 4443 | Required to enable communication between Nodes and the API server. |
| APIServer Subnet CIDR | Azure Load Balancer | TCP | 9988 | Required to enable communication between Azure Load Balancer and the API server. You can also enable all communication between the Azure Load Balancer and the API Server Subnet CIDR. |

For more information, see [API Server VNet Integration](api-server-vnet-integration).

For node and pod communication, allow the following traffic when network security group rules restrict the corresponding CIDR ranges:

| Destination | Source | Protocol | Port | Use |
| --- | --- | --- | --- | --- |
| Node CIDR | Node CIDR | All Protocols | All Ports | Required to enable communication between Nodes. |
| Pod CIDR | Node CIDR | All Protocols | All Ports | Required for Service traffic routing. |
| Pod CIDR | Pod CIDR | All Protocols | All Ports | Required for Pod to Pod and Pod to Service traffic, including DNS. |

The applicable node and pod CIDR ranges depend on your cluster's network model. For more information, see [AKS CNI networking prerequisites](concepts-network-cni-overview#aks-cni-networking-prerequisites).

## DNS resolution

DNS resolution is essential for service discovery and communication in AKS. By default, AKS uses [CoreDNS](coredns-custom) to provide internal name resolution for pods and services.

For improved DNS performance and reliability, AKS offers [LocalDNS](dns-concepts), which deploys a DNS proxy on each node. LocalDNS resolves queries locally, reducing latency and eliminating `conntrack` table pressure from DNS traffic. You can configure LocalDNS to serve cached responses during upstream DNS outages, but stale-response caching operates on a best-effort basis. LocalDNS is particularly beneficial in large clusters or environments with high DNS query volumes.

LocalDNS is preconfigured in AKS Automatic. In AKS Standard, LocalDNS is optional and configured per node pool. Before you enable it in AKS Standard, verify the Kubernetes version, node operating system, and VM SKU prerequisites. Enabling LocalDNS on an existing node pool reimages its nodes. For prerequisites and rollout planning, see [Configure LocalDNS](localdns-custom).

## Network policies

By default, all pods in an AKS cluster can send and receive traffic without limitations. For improved security, define rules that control the flow of traffic, like:

- Back-end applications are only exposed to required frontend services.
- Database components are only accessible to the application tiers that connect to them.

Network policy is a Kubernetes feature available in AKS that lets you control the traffic flow between pods. You can allow or deny traffic to the pod based on settings such as assigned labels, namespace, or traffic port. While network security groups are better for AKS nodes, network policies are a more suited, cloud-native way to control the flow of traffic for pods. As pods are dynamically created in an AKS cluster, required network policies can be automatically applied.

For more information, see [Secure traffic between pods using network policies in Azure Kubernetes Service (AKS)](use-network-policies).