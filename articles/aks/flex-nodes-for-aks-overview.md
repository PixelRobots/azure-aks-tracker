---
layout: Conceptual
title: What are flex nodes for AKS? (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/flex-nodes-for-aks-overview
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
description: Learn how flex nodes extend Azure Kubernetes Service to external virtual machines and bare metal hosts for Kubernetes workloads.
ms.topic: concept-article
ms.date: 2026-08-28T00:00:00.0000000Z
author: sdesai345
ms.author: sachidesai
ms.subservice: aks-nodes
ai-usage: ai-assisted
locale: en-us
document_id: ea6c10bb-093d-74b4-7b5a-abab2c2fef96
document_version_independent_id: 16db7f0e-b293-955d-7385-543a8d4e6f01
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/flex-nodes-for-aks-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/flex-nodes-for-aks-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/flex-nodes-for-aks-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 0caa6405-6804-7a61-6261-3448ce7b384d
---

# What are flex nodes for AKS? (preview) - Azure Kubernetes Service | Microsoft Learn

Flex nodes extend Azure Kubernetes Service (AKS) to user-managed virtual machines and bare metal hosts. Use flex nodes to add existing compute capacity to an AKS cluster without moving that compute into a standard AKS node pool. This capability is useful when you need to access capacity outside the AKS cluster's Azure region. It lets you manage these nodes through AKS lifecycle operations while retaining control of the underlying machines.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## How flex nodes work

A flex node runs on a virtual machine (VM) or bare metal host machine that you manage. The flex node agent prepares the machine, joins it to an AKS cluster, and keeps its node configuration aligned with the state requested by AKS. The agent runs the node in an isolated environment so that it can update the node without replacing the underlying machine.

The agent creates an isolated Kubernetes node environment on the host. After the node joins the cluster, Kubernetes can schedule workloads to it according to the scheduling configuration that you define.

## Flex node components

Flex nodes use the following components:

- **User-managed host**: A virtual machine or bare metal host that provides compute capacity and runs the flex node agent.
- **Flex node agent**: Software on the host that bootstraps the node environment, joins the host to the cluster, and keeps the node aligned with the configuration requested by AKS. The agent is open source in the [AKSFlexNode repository](https://aka.ms/aks-flex-node/github).
- **AKS cluster**: The cluster control plane schedules and manages Kubernetes workloads across standard node pools and connected flex nodes.
- **ARM machine resource**: An Azure Resource Manager (ARM) resource that stores the authoritative desired state for one flex node instance, including its desired Kubernetes version.
- **AKS management APIs**: Lifecycle operations that you use to manage a pool of flex nodes.

## Authentication options for flex nodes

Flex nodes support multiple authentication methods for different host and connectivity models.

| Authentication method | When to use it |
| --- | --- |
| Azure Arc managed identity | Azure Arc extends Azure's trust relationship to a non-Azure server, so that server can also get a secretless identity. |
| System-assigned or user-assigned managed identity | Azure already manages the VM, so it can hand the VM a secretless identity directly. |
| Service principal | Azure has no existing relationship with the host, so you create and manage an application identity for it yourself. |

Choose an authentication method that matches how you manage host identity and access in your environment.

The flex node agent uses two separate identities with limited permissions. One identity communicates with Azure to get the node's desired configuration and report its status. The other identity communicates with Kubernetes to monitor the node and remove it from the cluster after a reset or delete operation.

## Workload scenarios for flex nodes

Flex nodes are useful for scenarios in which standard AKS node pools might not provide the required host location or regional capacity, or when selected jobs need to run on your own infrastructure to support your data residency strategy.

### Capacity outside the AKS region

Connect your virtual machines or bare metal hosts located outside the AKS cluster's Azure region. Flex nodes make this capacity available to the cluster and let you schedule selected jobs on your own infrastructure when needed for data residency.

### Lab and test environments

Use available virtual machines or physical hosts as AKS nodes in lab and test environments. Support for both `amd64` and `arm64` hosts lets you evaluate workloads across processor architectures.

## Flex nodes and standard AKS node pools

Standard AKS node pools use Azure virtual machines that AKS provisions and manages as part of the cluster. Flex nodes use virtual machines or bare metal hosts that you manage outside standard AKS node pools.

Use standard node pools for workloads that fit the AKS-managed Azure virtual machine model. Consider flex nodes when selected jobs need to run on your own infrastructure to support data residency, when you need to connect bare metal hardware, or when you need capacity outside the cluster's Azure region.

Flex nodes don't replace standard node pools. A cluster can use standard node pools for general workloads and flex nodes for workloads that need a different host model.