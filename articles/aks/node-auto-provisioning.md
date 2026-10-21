---
layout: Conceptual
title: Overview of Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-auto-provisioning
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
description: Learn about node auto-provisioning in AKS, including how it works, upgrade behavior, prerequisites, limitations, and when to use AKS Automatic as the recommended production-ready default.
ms.topic: overview
ms.custom: devx-track-azurecli
ms.date: 2026-02-15T00:00:00.0000000Z
ms.author: wilsondarko
author: wdarko1
locale: en-us
document_id: eb8b3a14-e062-e504-0f10-ad5e02313866
document_version_independent_id: 507de265-34b3-f218-cb57-e46247513500
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-auto-provisioning.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/node-auto-provisioning
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-auto-provisioning.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: e28bc928-6980-9c09-2044-6399527f9b38
---

# Overview of Node Auto-Provisioning (NAP) in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article provides an overview of node auto-provisioning (NAP) in Azure Kubernetes Service (AKS), including how it works, upgrade behavior, prerequisites, limitations, and resources to get started.

For most production AKS workloads, AKS Automatic is the recommended default. AKS Automatic includes NAP as a preconfigured capability and provides a production-ready operational baseline with SLA-backed pod readiness.

## What is node auto-provisioning in AKS?

When you deploy workloads onto AKS, you need to select the appropriate virtual machine (VM) size as part of your node pool configuration. As your workloads become more complex, you might have different workloads with varying resource requirements, which makes it more difficult to design your VM configuration for numerous resource requests.

Node auto-provisioning (NAP) simplifies this process by automatically provisioning and managing the optimal VM configuration for your workloads. NAP uses pending pod resource requirements to decide the optimal VM configuration to run your workloads in the most efficient and cost-effective manner.

NAP automatically deploys, configures, and manages Karpenter on your AKS clusters and is based on the open-source [Karpenter](https://karpenter.sh) and [AKS Karpenter provider](https://github.com/Azure/karpenter-provider-azure) projects.

In AKS Automatic, NAP is preconfigured by default. In AKS Standard, you enable and configure NAP explicitly.

## Choose AKS Automatic or AKS Standard for NAP

Use the following guidance to select your starting point:

| Scenario | Recommended path | Why |
| --- | --- | --- |
| Most production workloads | AKS Automatic | NAP is preconfigured, pod readiness is SLA-backed, and day-2 node operations are reduced. |
| Advanced custom platform requirements | AKS Standard with NAP | More manual control over cluster and provisioning configuration. |
| Faster path to production with less VM planning | AKS Automatic | Reduced operational overhead for node sizing and lifecycle operations. |
| Fine-grained platform tuning from day one | AKS Standard with NAP | Greater flexibility for custom controls and operational patterns. |

For an AKS Automatic overview, see [Introduction to Azure Kubernetes Service (AKS) Automatic](intro-aks-automatic).

## How does node auto-provisioning work?

Node auto-provisioning provisions, scales, and manages VMs (nodes) in a cluster in response to pending pod pressure.

### Key components of node auto-provisioning

NAP uses the following key components to help manage your cluster's nodes:

| Component | Description |
| --- | --- |
| `NodePool` and `AKSNodeClass` | Custom Resource Definitions (CRDs) that you create and manage to define node provisioning policies, VM specifications, and constraints for your workloads. |
| `NodeClaims` | Managed by NAP to represent the current state of provisioned nodes that you can monitor. |
| Workload resource requirements | CPU, memory, and other specifications from your Pods, Deployments, Jobs, and other Kubernetes resources that drive provisioning decisions. |

Tip

On [AKS Automatic](intro-aks-automatic) clusters, NAP is preconfigured and backed by a [pod readiness SLA](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services) that guarantees 99.9% of qualifying pod readiness operations complete within 5 minutes. This means your workloads start running on the right-sized nodes promptly, without manual VM selection or capacity planning.

For most production teams, this makes AKS Automatic the default starting point for predictable startup behavior and lower day-2 operations overhead.

## Kubernetes upgrade behavior for node auto-provisioning nodes

Kubernetes upgrades for node auto-provisioning nodes follow the control plane Kubernetes version. If you perform a cluster upgrade, your nodes are automatically updated to follow the same versioning as your control plane.

We recommend setting a Kubernetes [auto-upgrade](/en-us/azure/aks/auto-upgrade-cluster#cluster-auto-upgrade-channels) channel, which automatically handles Kubernetes upgrades for your cluster. We also recommend setting a [planned maintenance window](planned-maintenance#create-a-maintenance-window) for your cluster. The `aksManagedAutoUpgradeSchedule` maintenance window allows you to control when to perform cluster upgrades scheduled by your designated auto-upgrade channel. For more information, see [Use planned maintenance to schedule and control upgrades for your Azure Kubernetes Service (AKS) cluster](planned-maintenance).

## Prerequisites

To use node auto-provisioning in AKS, you need the following prerequisites:

- An Azure subscription. If you don't have one, you can create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Azure CLI version `2.76.0` or later. To find the version, run `az --version`. For more information about installing or upgrading the Azure CLI, see [Install Azure CLI](/en-us/cli/azure/get-started-with-azure-cli).

## Limitations and unsupported features

The following limitations and unsupported features apply to node auto-provisioning in AKS:

- Windows node pools aren't supported.
- IPv6 clusters aren't supported.
- [Service principals](kubernetes-service-principal) aren't supported. You can use either a system-assigned or user-assigned managed identity.
- You can't [stop a cluster](start-stop-cluster) enabled with NAP.
- You can't change the [cluster egress outbound type](egress-outboundtype) after you create a cluster enabled with NAP.
- When creating a NAP cluster in a custom virtual network (VNet), you must use a [Standard Load Balancer](load-balancer-standard). The Basic Load Balancer isn't supported.

## Get started with node auto-provisioning on AKS

If you're starting a new production workload, begin with AKS Automatic:

- [Introduction to Azure Kubernetes Service (AKS) Automatic](intro-aks-automatic)
- [Create an AKS Automatic cluster](automatic/quick-automatic-managed-network)

For AKS Standard or advanced NAP customization scenarios, use these resources:

- [Enable or disable node auto-provisioning on an AKS cluster](use-node-auto-provisioning)
- [Use node auto-provisioning in a custom virtual network](node-auto-provisioning-custom-vnet)
- [Configure networking for node auto-provisioning on AKS](node-auto-provisioning-networking)
- [Configure node pools for node auto-provisioning on AKS](node-auto-provisioning-node-pools)
- [Configure disruption policies for node auto-provisioning on AKS](node-auto-provisioning-disruption)
- [Upgrade node images for node auto-provisioning on AKS](node-auto-provisioning-upgrade-image)