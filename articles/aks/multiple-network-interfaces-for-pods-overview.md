---
layout: Conceptual
title: Multi-NIC Pods on Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/multiple-network-interfaces-for-pods-overview
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
description: Learn about multi-NIC pod support in AKS using Dynamic Resource Allocation (DRA) and the DRAnet network driver to attach secondary network interfaces to pods.
ms.topic: concept-article
ms.date: 2026-06-16T00:00:00.0000000Z
ms.author: josephyostos
author: JosephYostos
locale: en-us
document_id: d58bbff2-36d7-bea4-fc2d-112579453f29
document_version_independent_id: f6f8f668-59b1-e1d7-ecfe-f1281a695205
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/multiple-network-interfaces-for-pods-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/multiple-network-interfaces-for-pods-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/multiple-network-interfaces-for-pods-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: afb2b5e3-06e8-b85b-9e09-674efa992539
---

# Multi-NIC Pods on Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn

By using multi-NIC pod support in Azure Kubernetes Service (AKS), you can attach one or more secondary network interfaces to pods running on your cluster, along with the standard CNI-assigned primary interface. This capability uses Kubernetes [Dynamic Resource Allocation (DRA)](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/) and a managed [DRAnet network driver](https://github.com/kubernetes-sigs/dranet), which automatically discover and inject secondary NICs into pods at runtime.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Overview

By default, every pod in an AKS cluster receives a single network interface (`eth0`) managed by the Azure CNI plugin. While this interface is sufficient for most workloads, certain scenarios require pods to have multiple network interfaces connected to different subnets or virtual networks.

Multi-NIC pod support addresses these scenarios by allowing you to:

- Provision AKS node pools with secondary network interfaces attached to each node.
- Use an AKS DRANET driver to automatically discover the secondary NICs on each node.
- Inject those secondary interfaces into pods at scheduling time through resource claims.

Important

Secondary NICs with public IPs bypass the Azure Load Balancer and SNAT, so they expose workloads directly to the internet. AKS doesn't provide a default protection layer for this traffic. You must configure and maintain appropriate NSG and firewall rules to restrict inbound and outbound access.

## How it works

Multi-NIC pod support in AKS relies on three key components working together:

### 1. Secondary network interfaces configuration

When you create or update a node pool, specify one or more secondary network interfaces in the node pool's network profile. AKS provisions the nodes with these extra NICs attached, and each NIC connects to the subnet you specify.

```json
"networkProfile": {
    "secondaryNetworkInterfaces": [
        {
            "type": "Standard",
            "vnetSubnetId": "<subnet-resource-id>"
        }
    ]
}
```

### 2. Dynamic Resource Allocation (DRA)

[Dynamic Resource Allocation (DRA)](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/) is a Kubernetes feature (GA in Kubernetes 1.34) that provides a framework for requesting and managing access to hardware resources. In the multi-NIC context, DRA manages the lifecycle of secondary network interfaces as allocatable devices.

The following DRA resources are used:

- **DeviceClass** — Defines a class of devices (secondary NICs) that the DRAnet driver publishes, with selectors to filter which devices match.
- **ResourceClaimTemplate** — A template that pods reference to request a specific number of NICs from a given device class.

### 3. Managed DRAnet network driver

The [DRAnet network driver](https://github.com/kubernetes-sigs/dranet) runs as a DaemonSet on each node. It:

- Discovers all network interfaces on the node.
- Publishes available secondary NICs as DRA device resources.
- Handles the attachment and detachment of NICs to and from pod network namespaces at pod scheduling time.

### End-to-end flow

```mermaid
sequenceDiagram
    participant User
    participant AKS as AKS Control Plane
    participant Node as AKS Node
    participant DRAnet as DRAnet Driver
    participant Scheduler as K8s Scheduler
    participant Pod

    User->>AKS: Create node pool with secondary NICs
    AKS->>Node: Provision node with primary + secondary NICs
    DRAnet->>Node: Discover available NICs
    DRAnet->>Scheduler: Publish NIC devices via DRA
    User->>Scheduler: Deploy pod with ResourceClaim
    Scheduler->>DRAnet: Allocate NIC to pod
    DRAnet->>Pod: Inject secondary NIC into pod namespace
    Pod->>Pod: Pod runs with eth0 + secondary NIC(s)
```

## Limitations

- **Kubernetes version** — Requires Kubernetes **1.34 or later** (for DRA GA support).
- **Virtual network scope** — All secondary NICs must connect to the same virtual network as the primary NIC. You can attach them to different subnets within that virtual network.
- **NIC assignment** — Each secondary NIC can be assigned to only one pod. You can't share a secondary NIC across multiple pods.
- DRANET supports **Linux node pools only**. Windows node pools aren't supported.
- **Network policies** are enforced only on the primary NIC. Traffic flowing through secondary NICs bypasses AKS network policy enforcement.
- **VM size** — The node pool VM size must support the total number of network interfaces (primary + secondary). To verify the maximum number of supported network interfaces and Accelerated Networking capabilities, see the Azure VM size documentation or use the `az vm list-skus` command. Here's an example:

```bash
az vm list-skus \
  --location eastus \
  --resource-type virtualMachines \
  --all \
  --query "[?name=='Standard_D8s_v5'].{
      SKU:name,
      MaxNICs:capabilities[?name=='MaxNetworkInterfaces']|[0].value,
      AcceleratedNetworking:capabilities[?name=='AcceleratedNetworkingEnabled']|[0].value
  }" \
  -o table
```