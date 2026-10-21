---
layout: Conceptual
title: Concepts - IP address planning in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-network-ip-address-planning
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
description: Learn about IP address planning in Azure Kubernetes Service (AKS).
ms.topic: concept-article
ms.subservice: aks-networking
ms.date: 2026-04-16T00:00:00.0000000Z
ai-usage: ai-assisted
author: schaffererin
ms.author: schaffererin
ms.custom: fasttrack-edit
locale: en-us
document_id: 27efc23c-218a-62c6-90f4-bf1ba9ea750e
document_version_independent_id: 48e40680-ecef-4107-8679-e1933ad9ff75
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-network-ip-address-planning.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-network-ip-address-planning
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-network-ip-address-planning.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 29dbdce4-7c36-1e29-fdcf-c9c6cd814b1d
---

# Concepts - IP address planning in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article provides guidance on IP address planning for Azure Kubernetes Service (AKS) clusters.

For specific guidance on IP address planning for individual CNI options, see the next steps section for links to plugin documentation.

## Subnet sizing

Your Azure VNet subnet must be large enough to accommodate your cluster, which depends on whether you're using an overlay network or a flat network.

Note

To share API, system, and agent node pool subnets between multiple clusters, ensure you allocate enough IP addresses to avoid issues.

### Overlay networks

With overlay networks, like [Azure CNI Overlay](concepts-network-azure-cni-overlay), your subnet needs to be large enough to assign IPs to your nodes. Pods are assigned IPs from a separate, private CIDR range and won't require VNet IPs. The VNet subnet you use for your cluster can be smaller than with flat networks.

It's important to ensure you allocate enough space in your private CIDR range for your pods to account for scaling. When planning your IP address range sizes, you should calculate your maximum pod count. Each node in your cluster is assigned a /24 (256 IP addresses) subnet for pods. You should plan your overlay network subnet to accommodate the maximum number of nodes you expect to run.

### Flat networks

Flat networks, like [Azure CNI Pod Subnet](concepts-network-azure-cni-pod-subnet), require a large enough subnet to accommodate both nodes *and* pods. Since nodes and pods receive IPs from your VNet, you need to plan for the maximum number of nodes and pods you expect to run. Azure CNI Pod Subnet uses a subnet for your nodes and a separate subnet for your pods, so you need to plan for both.

## IP address sizing

### Upgrading and scaling considerations

When IP address planning for your AKS cluster, you should **consider the number of IP addresses required for upgrade and scaling operations**. If you set the IP address range to only support a fixed number of nodes, you won't be able to upgrade or scale your cluster.

When you **upgrade** your AKS cluster, a new node is deployed in the cluster. Services and workloads begin to run on the new node, and an older node is removed from the cluster. This rolling upgrade process requires a minimum of one additional block of IP addresses to be available. Your node count is then `n + 1` where `n` is the number of nodes in your cluster.

When you **scale** an AKS cluster, a new node is deployed in the cluster. Services and workloads begin to run on the new node. Your IP address range needs to take into considerations how you want to scale up the number of nodes and pods your cluster can support. A minimum of one additional node for upgrade operations or the number of nodes set by the [Customize node surge upgrade](upgrade-aks-cluster#customize-node-surge-upgrade) option should also be included. Your node count is then `n + number-of-additional-scaled-nodes-you-anticipate + max surge`.

If you're using [Azure CNI Pod Subnet](concepts-network-azure-cni-pod-subnet) and you expect your nodes to run the maximum number of pods and you regularly destroy and deploy pods, you should also factor in extra IP addresses per node. There can be few seconds latency required to delete a service and release its IP address for a new service to be deployed and acquire the address. The extra IP addresses account for this possibility.

The IP address plan for an AKS cluster consists of a virtual network, at least one subnet for nodes and pods, and a Kubernetes service address range.

| Azure Resource | Address Range | Limits and Sizing |
| --- | --- | --- |
| Azure Virtual Network | Max size /8. 65,536 configured IP address limit. See [Azure CNI Pod Subnet Static Block Allocation](concepts-network-azure-cni-pod-subnet#static-block-allocation-mode) for more details | Overlapping address spaces within your network can cause issues. |
| Subnet | Must be large enough to accommodate nodes, pods, and all Kubernetes and Azure resources in your cluster. For instance, if you deploy an internal Azure Load Balancer, its front-end IPs are allocated from the cluster subnet, not public IPs. | Subnet size should also account for upgrade operations and future scaling needs.  Use the following equation to calculate the minimum subnet size, including an extra node for upgrade operations: `(number of nodes + max surge nodes) + ((number of nodes + max surge nodes) * maximum pods per node that you configure)` Example for a 50-node cluster: `(51) + (51 * 30 (default)) = 1,581` (/21 or larger)  Example for a 50-node cluster, preparing to scale up an extra 10 nodes with the default max surge of 1 node: `(61) + (61 * 30 (default)) = 1,891` (/21 or larger)  If you don't specify a maximum number of pods per node when you create your cluster, the maximum number of pods per node is set to 30. The minimum number of IP addresses required is based on that value. If you calculate your minimum IP address requirements on a different maximum value, see Maximum pods per node to set this value when you deploy your cluster. |
| Kubernetes Service Address Range | Any network element on or connected to this virtual network must not use this range. | The service address CIDR must be smaller than /12. You can reuse this range across different AKS clusters. Starting with Kubernetes 1.33, you can [extend the service IP range](https://kubernetes.io/docs/tasks/network/extend-service-ip-ranges/) after cluster creation using the `ServiceCIDR` resource. |
| Kubernetes DNS Service IP Address | IP address within the Kubernetes service address range used by cluster service discovery. | Don't use the first IP address in your address range. The first address in your subnet range is used for the *kubernetes.default.svc.cluster.local* address. |

## Maximum pods per node

The maximum number of pods per node in an AKS cluster is 250. The *default* maximum number of pods per node varies between *kubenet* and *Azure CNI* networking, and the method of cluster deployment.

| CNI | Default max pods | Configurable at deployment |
| --- | --- | --- |
| Azure CNI Overlay | 250 | Yes (up to 250) |
| Azure CNI Pod subnet | 110 | Yes (up to 250) |
| Azure CNI (Legacy) | 30 | Yes (up to 250) |
| Kubenet | 110 | Yes (up to 250) |

## Configuring maximum pods per node for your clusters

You can configure the maximum number of pods per node either at cluster deployment time or as you add new node pools. You can set the maximum pods per node value as high as 250.

A minimum value for maximum pods per node is enforced to guarantee space for system pods critical to cluster health. The minimum value that can be set for maximum pods per node is 10 if and only if the configuration of each node pool has space for a minimum of 30 pods. For example, setting the maximum pods per node to the minimum of 10 requires each individual node pool to have a minimum of three nodes. This requirement applies for each new node pool created as well, so if 10 is defined as maximum pods per node each subsequent node pool added must have at least three nodes.

| Networking | Minimum | Maximum |
| --- | --- | --- |
| Azure CNI | 10 | 250 |
| Kubenet | 10 | 250 |

Note

The minimum value in the previous table is strictly enforced by the AKS service. You cannot set a value for *maxPods* that is lower than the minimum shown, as doing so can prevent the cluster from starting.

### New clusters

You can define maximum pods per node when you create a new cluster using one of the following methods:

- **Azure CLI**: Specify the `--max-pods` argument when you deploy a cluster with the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.
- **Azure Resource Manager template**: Specify the `maxPods` property in the [ManagedClusterAgentPoolProfile] object when you deploy a cluster with an Azure Resource Manager template.
- **Azure portal**: Change the `Max pods per node` field in the node pool settings when creating a cluster or adding a new node pool.

### Existing clusters

You can define maximum pods per node when you create a new node pool. If you need to increase the *maxPods* setting on an existing cluster, add a new node pool with the new desired *maxPods* count. After migrating your pods to the new pool, delete the node older pool.