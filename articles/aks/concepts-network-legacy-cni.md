---
layout: Conceptual
title: Concepts - AKS Legacy Container Networking Interfaces (CNI) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-network-legacy-cni
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
description: Learn about legacy CNI networking options in Azure Kubernetes Service (AKS)
ms.topic: concept-article
ms.subservice: aks-networking
ms.date: 2026-04-16T00:00:00.0000000Z
ai-usage: ai-assisted
author: schaffererin
ms.author: schaffererin
ms.custom: fasttrack-edit
locale: en-us
document_id: f881d28f-4bcd-1f85-899d-89f235078c72
document_version_independent_id: 70f1a54b-6138-4f51-52a1-5f3c094e4e69
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-network-legacy-cni.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-network-legacy-cni
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-network-legacy-cni.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
platformId: 4142916a-8477-19ed-8d8d-36387c4bab0b
---

# Concepts - AKS Legacy Container Networking Interfaces (CNI) - Azure Kubernetes Service | Microsoft Learn

Important

On **31 March 2028**, kubenet networking for Azure Kubernetes Service (AKS) will be retired.

To avoid service disruptions, **you'll need to**[upgrade to Azure Container Networking Interface (CNI) overlay](/en-us/azure/aks/upgrade-aks-ipam-and-dataplane#upgrade-an-existing-cluster-to-azure-cni-overlay)**before that date**, when workloads running on kubenet for AKS will no longer be supported.

In Azure Kubernetes Service (AKS), while [Azure CNI Overlay](concepts-network-azure-cni-overlay) and [Azure CNI Pod Subnet](concepts-network-azure-cni-pod-subnet) are recommended for most scenarios, legacy networking models such as Azure CNI Node Subnet and kubenet are still available and supported. These legacy models offer different approaches to pod IP address management and networking, each with its own set of capabilities and considerations. This article provides an overview of these legacy networking options, detailing their prerequisites, deployment parameters, and key characteristics to help you understand their roles and how they can be used effectively within your AKS clusters.

## Prerequisites

The following prerequisites are required for Azure CNI Node Subnet:

- The virtual network for the AKS cluster must allow outbound internet connectivity.
- AKS clusters can't use `169.254.0.0/16`, `172.30.0.0/16`, `172.31.0.0/16`, or `192.0.2.0/24` for the Kubernetes service address range, pod address range, or cluster virtual network address range.
- The cluster identity used by the AKS cluster must have at least [Network Contributor](/en-us/azure/role-based-access-control/built-in-roles#network-contributor) permissions on the subnet within the virtual network. If you want to define a [custom role](/en-us/azure/role-based-access-control/custom-roles) instead of using the built-in Network Contributor role, the following permissions are required:

    - `Microsoft.Network/virtualNetworks/subnets/join/action`
    - `Microsoft.Network/virtualNetworks/subnets/read`
    - `Microsoft.Authorization/roleAssignments/write`
- The subnet assigned to the AKS node pool can't be a [delegated subnet](/en-us/azure/virtual-network/subnet-delegation-overview).

- AKS doesn't apply Network Security Groups (NSGs) to its subnet and doesn't modify any of the NSGs associated with that subnet. If you provide your own subnet and add NSGs associated with that subnet, make sure the security rules in the NSGs allow traffic within the node CIDR range. For more information, see [Network security groups](concepts-network#network-security-groups).

## Azure CNI Node Subnet

With [Azure Container Networking Interface (CNI)](https://github.com/Azure/azure-container-networking/blob/master/docs/cni.md), every pod gets an IP address from the subnet and can be accessed directly. Systems in the same virtual network as the AKS cluster see the pod IP as the source address for any traffic from the pod. Systems outside the AKS cluster virtual network see the node IP as the source address for any traffic from the pod. These IP addresses must be unique across your network space and must be planned in advance. Each node has a configuration parameter for the maximum number of pods that it supports. The equivalent number of IP addresses per node are then reserved up front for that node. This approach requires more planning, and often leads to IP address exhaustion or the need to rebuild clusters in a larger subnet as your application demands grow.

With Azure CNI Node Subnet, each pod receives an IP address in the IP subnet and can communicate directly with other pods and services. Your clusters can be as large as the IP address range you specify. However, you must plan the IP address range in advance, and all the IP addresses are consumed by the AKS nodes based on the maximum number of pods they can support. Advanced network features and scenarios such as [virtual nodes](virtual-nodes-cli) or Network Policies (either Azure or Calico) are supported with Azure CNI.

### Deployment parameters

When you create an AKS cluster, the following parameters are configurable for Azure CNI networking:

**Virtual network**: The virtual network into which you want to deploy the Kubernetes cluster. You can create a new virtual network or use an existing one. If you want to use an existing virtual network, make sure it's in the same location and Azure subscription as your Kubernetes cluster. For information about the limits and quotas for an Azure virtual network, see [Azure subscription and service limits, quotas, and constraints](/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-resource-manager-virtual-networking-limits).

**Subnet**: The subnet within the virtual network where you want to deploy the cluster. You can add new subnets into the virtual network during the cluster creation process. For hybrid connectivity, the address range shouldn't overlap with any other virtual networks in your environment.

**Azure Network Plugin**: When Azure network plugin is used, the internal LoadBalancer service with "externalTrafficPolicy=Local" can't be accessed from VMs with an IP in clusterCIDR that doesn't belong to AKS cluster.

**Kubernetes service address range**: This parameter is the set of virtual IPs that Kubernetes assigns to internal [services](concepts-network-services) in your cluster. You can use any private address range that satisfies the following requirements:

Note

Starting with Kubernetes 1.33, you can extend the service IP range after cluster creation by using the `ServiceCIDR` Kubernetes resource. For more information, see [Extend Service IP Ranges](https://kubernetes.io/docs/tasks/network/extend-service-ip-ranges/) in the Kubernetes documentation. On clusters running earlier versions, the service address range can't be updated after you create the cluster.

- Must not be within the virtual network IP address range of your cluster.
- Must not overlap with any other virtual networks with which the cluster virtual network peers.
- Must not overlap with any on-premises IPs.
- Must not be within the ranges `169.254.0.0/16`, `172.30.0.0/16`, `172.31.0.0/16`, or `192.0.2.0/24`.

While it's possible to specify a service address range within the same virtual network as your cluster, we don't recommend it. Overlapping IP ranges can result in unpredictable behavior. For more information, see the FAQ. For more information on Kubernetes services, see [Services](concepts-network-services) in the Kubernetes documentation.

**Kubernetes DNS service IP address**: The IP address for the cluster's DNS service. This address must be within the *Kubernetes service address range*. Don't use the first IP address in your address range. The first address in your subnet range is used for the *kubernetes.default.svc.cluster.local* address.

- **Azure CNI**: That same basic */24* subnet range can only support a maximum of *8* nodes in the cluster. This node count can only support up to *240* pods, with a default maximum of 30 pods per node.

Note

These maximums don't take into account upgrade or scale operations. In practice, you can't run the maximum number of nodes the subnet IP address range supports. You must leave some IP addresses available for scaling or upgrading operations.

## Virtual network peering and ExpressRoute connections

You can use [Azure virtual network peering](/en-us/azure/virtual-network/virtual-network-peering-overview) or [ExpressRoute connections](/en-us/azure/expressroute/expressroute-introduction) with *Azure CNI* to provide on-premises connectivity. Make sure you plan your IP addresses carefully to prevent overlap and incorrect traffic routing. For example, many on-premises networks use a *10.0.0.0/8* address range that's advertised over the ExpressRoute connection. We recommend creating your AKS clusters in Azure virtual network subnets outside of this address range, such as *172.16.0.0/16*.

For more information, see [Compare network models and their support scopes](concepts-network-cni-overview).

## Azure CNI Pod Subnet frequently asked questions

- **Can I deploy VMs in my cluster subnet?**

    Yes for Azure CNI Node Subnet, the VMs can be deployed in the same subnet as the AKS cluster.
- **What source IP do external systems see for traffic that originates in an Azure CNI-enabled pod?**

    Systems in the same virtual network as the AKS cluster see the pod IP as the source address for any traffic from the pod. Systems outside the AKS cluster virtual network see the node IP as the source address for any traffic from the pod. But for [Azure CNI dynamic IP allocation](concepts-network-azure-cni-pod-subnet#dynamic-ip-allocation-mode), no matter the connection is inside the same virtual network or cross virtual networks, the pod IP is always the source address for any traffic from the pod. This is because the [Azure CNI for dynamic IP allocation](concepts-network-azure-cni-pod-subnet#dynamic-ip-allocation-mode) implements [Microsoft Azure Container Networking](https://github.com/Azure/azure-container-networking) infrastructure, which gives end-to-end experience. Hence, it eliminates the use of [`ip-masq-agent`](https://kubernetes.io/docs/tasks/administer-cluster/ip-masq-agent/), which is still used by traditional Azure CNI.
- **Can I configure per-pod network policies?**

    Yes, Kubernetes network policy is available in AKS. To get started, see [Secure traffic between pods by using network policies in AKS](use-network-policies).
- **Is the maximum number of pods deployable to a node configurable?**

    With [Azure Container Networking Interface (CNI)](https://github.com/Azure/azure-container-networking/blob/master/docs/cni.md), every pod gets an IP address from the subnet and can be accessed directly. Systems in the same virtual network as the AKS cluster see the pod IP as the source address for any traffic from the pod. Systems outside the AKS cluster virtual network see the node IP as the source address for any traffic from the pod. These IP addresses must be unique across your network space and must be planned in advance. Each node has a configuration parameter for the maximum number of pods that it supports. The equivalent number of IP addresses per node are then reserved up front for that node. This approach requires more planning, and often leads to IP address exhaustion or the need to rebuild clusters in a larger subnet as your application demands grow.
- **Can I deploy VMs in my cluster subnet?**

    Yes. But for [Azure CNI for dynamic IP allocation](configure-azure-cni-dynamic-ip-allocation), the VMs cannot be deployed in pod's subnet.
- **What source IP do external systems see for traffic that originates in an Azure CNI-enabled pod?**

    Systems in the same virtual network as the AKS cluster see the pod IP as the source address for any traffic from the pod. Systems outside the AKS cluster virtual network see the node IP as the source address for any traffic from the pod.

    But for [Azure CNI for dynamic IP allocation](configure-azure-cni-dynamic-ip-allocation), no matter the connection is inside the same virtual network or cross virtual networks, the pod IP is always the source address for any traffic from the pod. This is because the [Azure CNI for dynamic IP allocation](configure-azure-cni-dynamic-ip-allocation) implements [Microsoft Azure Container Networking](https://github.com/Azure/azure-container-networking) infrastructure, which gives end-to-end experience. Hence, it eliminates the use of [`ip-masq-agent`](https://kubernetes.io/docs/tasks/administer-cluster/ip-masq-agent/), which is still used by traditional Azure CNI.
- **Can I use a different subnet within my cluster virtual network for the *Kubernetes service address range*?**

    It's not recommended, but this configuration is possible. The service address range is a set of virtual IPs (VIPs) that Kubernetes assigns to internal services in your cluster. Azure Networking has no visibility into the service IP range of the Kubernetes cluster. The lack of visibility into the cluster's service address range can lead to issues. It's possible to later create a new subnet in the cluster virtual network that overlaps with the service address range. If such an overlap occurs, Kubernetes could assign a service an IP that's already in use by another resource in the subnet, causing unpredictable behavior or failures. By ensuring you use an address range outside the cluster's virtual network, you can avoid this overlap risk. Yes, when you deploy a cluster with the Azure CLI or a Resource Manager template. See [Maximum pods per node](concepts-network-ip-address-planning#maximum-pods-per-node).
- **Can I use a different subnet within my cluster virtual network for the *Kubernetes service address range*?**

    It's not recommended, but this configuration is possible. The service address range is a set of virtual IPs (VIPs) that Kubernetes assigns to internal services in your cluster. Azure Networking has no visibility into the service IP range of the Kubernetes cluster. The lack of visibility into the cluster's service address range can lead to issues. It's possible to later create a new subnet in the cluster virtual network that overlaps with the service address range. If such an overlap occurs, Kubernetes could assign a service an IP that's already in use by another resource in the subnet, causing unpredictable behavior or failures. By ensuring you use an address range outside the cluster's virtual network, you can avoid this overlap risk.