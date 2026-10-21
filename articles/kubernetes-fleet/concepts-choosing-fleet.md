---
layout: Conceptual
title: Choosing an Azure Kubernetes Fleet Manager option | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-choosing-fleet
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
learn_banner_products:
- azure
description: This article provides an overview of the various Azure Kubernetes Fleet Manager options and why you may choose a specific configuration.
ms.date: 2025-12-10T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: 215940db-c0a8-be76-a158-520149061431
document_version_independent_id: 33ebf34b-0ad1-507f-45b3-534af0f7de7a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-choosing-fleet.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-choosing-fleet
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-choosing-fleet.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
platformId: 4936faf8-80b6-8311-1c6a-317eb616f5bd
---

# Choosing an Azure Kubernetes Fleet Manager option | Microsoft Learn

This article provides an overview of the various Azure Kubernetes Fleet Manager options and the considerations you should use to guide your selection of a specific configuration.

## Fleet types

A Fleet Manager resource can be created with or without a hub cluster. A hub cluster is a managed Azure Kubernetes Service (AKS) cluster that acts as a hub to stage Kubernetes resources ready for placement.

The following table outlines the supported capabilities of Fleet Manager with and without a hub cluster:

| Capability | Fleet Manager without hub cluster | Fleet Manager with hub cluster |
| --- | --- | --- |
| **Hub cluster hosting** | ❌ | ✅ |
| **Kubernetes and node image updates** | ✅ | ✅ |
| **Workload placement** | ❌ | ✅ |
| **Managed Fleet Namespaces** | ❌ | ✅ |
| **DNS load balancing** | ❌ | ✅ |
| **Billing considerations** | No cost | You pay for hub cluster, which is a single node standard-tier AKS cluster. |
| **Converting fleet types** | Can upgrade to a Fleet Manager with a hub cluster. | Can't be downgraded to a Fleet Manager resource without a hub cluster. |

## Fleet Manager without hub cluster

Without a hub cluster, Fleet Manager acts solely as a grouping entity in Azure Resource Manager (ARM). Certain features, such as Kubernetes and node image update runs and auto-upgrades, don't require a Kubernetes API and thus don't require a hub cluster. To take full advantage of all the features available, you need a Fleet Manager with a hub cluster.

For more information, see [Create a Kubernetes Fleet resource without a hub cluster](quickstart-create-fleet-and-members?pivots=no-hub#create-a-resource-group).

## Fleet Manager with hub cluster

A Fleet Manager with a hub cluster has an associated AKS-managed cluster, which hosts the open source [KubeFleet](https://kubefleet.dev/) solution for workload placement and the [fleet network manager](https://github.com/Azure/fleet-networking) for network management and load balancing.

Upon the creation of a Fleet Manager with a hub cluster, a hub AKS cluster is automatically created in the same Azure subscription under a managed resource group that begins with `FL_`. To improve reliability, hub clusters are denied any user-initiated mutations to the corresponding AKS cluster (under the Fleet-managed resource group `FL_`) and their underlying Azure resources (under the AKS-managed resource group `MC_FL_*`), such as virtual machines (VMs).

Control plane operations, such as changing the hub cluster's configuration through Azure Resource Manager (ARM) or deleting the cluster entirely, are denied. Data plane operations, such as connecting to the hub cluster's Kubernetes API server in order to configure workload placement, are allowed.

Hub clusters are exempted from [Azure policies](/en-us/azure/governance/policy/overview) to avoid undesirable policy effects.

### Network access modes for hub cluster

For a Fleet Manager with a hub cluster, there are two network access modes:

- **Public hub clusters** expose the hub cluster to the internet. This means that with the right credentials, anyone on the internet can connect to the hub cluster. This configuration can be useful during the development and testing phase, but represents a security concern, which is largely undesirable in production.

For more information, see [Create a Kubernetes Fleet resource with a public hub cluster](quickstart-create-fleet-and-members?pivots=public-hub#create-a-resource-group).

- **Private hub clusters** use a [private AKS cluster](/en-us/azure/aks/private-clusters) as the hub, which prevents open access over the internet. All considerations for a private AKS cluster apply, so review the prerequisites and limitations to determine whether a Fleet Manager with a private hub cluster meets your needs.

Some other details to consider:

- Whether you choose a public or private hub, the type can't be changed after creation.
- When using an AKS private cluster, you have the ability to configure fully qualified domain names (FQDNs) and FQDN subdomains. This functionality doesn't apply to the private hub cluster of the Fleet Manager.
- When you connect to a private hub cluster, you can use the same methods that you would use to [connect to any private AKS cluster](/en-us/azure/aks/private-clusters?tabs=azure-portal#options-for-connecting-to-the-private-cluster). However, connecting using AKS command invoke and private endpoints aren't currently supported.
- When you use private hub clusters, you're required to specify the subnet in which the Fleet Manager hub cluster's node VMs reside. This process differs slightly from the AKS private cluster equivalent. For more information, see [create a Fleet Manager with a private hub cluster](quickstart-create-fleet-and-members?pivots=private-hub#create-a-resource-group).