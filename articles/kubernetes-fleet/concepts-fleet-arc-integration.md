---
layout: Conceptual
title: Azure Kubernetes Fleet Manager with Arc-enabled Kubernetes clusters | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-fleet-arc-integration
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
description: This article provides a conceptual overview of Azure Kubernetes Fleet Manager integration with Azure Arc-enabled Kubernetes clusters.
ms.date: 2026-06-25T00:00:00.0000000Z
author: Ealianis
ms.author: sehobbs
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: 50e15a8c-726c-0c2c-a8e2-06cdcb935d6c
document_version_independent_id: 3399d554-3757-4ef0-62ec-ccbd7c7edcf6
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-fleet-arc-integration.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-fleet-arc-integration
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-fleet-arc-integration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: e471252b-688f-92e9-a9f9-43270c5ad4fd
---

# Azure Kubernetes Fleet Manager with Arc-enabled Kubernetes clusters | Microsoft Learn

**Applies to:** ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

This article provides a conceptual overview of how Azure Kubernetes Fleet Manager integrates with Azure Arc-enabled Kubernetes clusters to enable unified multicluster management across hybrid and multicloud environments.

If you're unfamiliar with Azure Kubernetes Fleet Manager, start with the [Azure Kubernetes Fleet Manager overview](overview).

## What does the integration solve?

The integration between Azure Kubernetes Fleet Manager and Azure Arc-enabled Kubernetes clusters extends centralized multicluster resource management beyond Azure-native AKS clusters, including many of the most popular Kubernetes distributions running anywhere:

- **Supported distributions**: [AKS on bare metal](https://aka.ms/aks-edge-baremetal) (preview), EKS (Amazon Elastic Kubernetes Service), GKE (Google Kubernetes Engine), K3s (Lightweight Kubernetes), OCP (Red Hat OpenShift), and Rancher (RKE).

## Key benefits and capabilities

Azure Kubernetes Fleet Manager integration with Arc-enabled Kubernetes clusters enables unified, intelligent, policy-driven multicluster resource management across hybrid and multicloud environments.

### Centralized policy-driven fleet governance

Azure Kubernetes Fleet Manager uses a hub-spoke architecture that creates a single control plane for the fleet. It enables fleet administrators to apply uniform cloud native policies on every member cluster, whether they reside in public clouds, private data centers, or edge locations. The hub-spoke architecture greatly simplifies governance across large, geographically distributed fleets spanning hybrid and multicloud environments.

### Progressive resource rollouts with safeguards

Azure Kubernetes Fleet Manager provides a cloud native progressive rollout by using [staged update runs](concepts-rollout-strategy). The application owner can stop a rollout or roll back to previous versions when they observe failures, limiting the blast radius. Progressive rollouts keep multicluster application deployments reliable and predictable spanning edge, on-premises, and cloud environments.

### Powerful multicluster scheduling

Azure Kubernetes Fleet Manager scheduler evaluates member cluster properties, available capacity, and declarative placement policies to select optimal destinations for workloads. It supports cluster affinity and anti-affinity rules, topology spread constraints to distribute workloads across failure domains, and resource-based placement to ensure sufficient compute, memory, and storage. The scheduler continuously reconciles as fleet conditions change, automatically adapting to cluster additions, removals, or capacity shifts across edge, on-premises, and cloud environments. For more details on the various scheduling capabilities, see the multicluster workload management section.

## Supported capabilities, prerequisites, and considerations

Before adding Arc-enabled Kubernetes clusters to Fleet Manager, review the important considerations noted in the [member cluster types documentation](concepts-member-cluster-types).

## Architecture overview

The Fleet Manager and Azure Arc integration uses the same hub-and-spoke architecture as AKS clusters:

When you join an Arc-enabled Kubernetes cluster to a Fleet Manager, you install the Fleet Manager Arc extension on your Arc-enabled Kubernetes cluster. This extension deploys the Fleet's member agents onto your underlying cluster. These agents communicate directly with the Fleet's hub cluster.

**Key components:**

- **Hub cluster**: Centralized control plane for managing the entire fleet.
- **Fleet extension**: Deployed to Arc-enabled clusters to enable Fleet Manager integration via the Fleet Arc Extension.
- **Member cluster representation**: Arc-enabled clusters appear as `MemberCluster` resources in the hub.

### Fleet extension resource requirements

When you add an Arc-enabled Kubernetes cluster to Fleet Manager, you deploy an extension that has these requirements:

- At least **210 MB** memory and **2%** of one CPU core available.
- The cluster reserves **3 pods** for the Azure Kubernetes Fleet Manager Arc extension agents.
- The **fleet-system** namespace is created for Fleet-related components and you shouldn't directly modify it.

## Getting started

To begin using Fleet Manager with Arc-enabled Kubernetes clusters:

1. **Connect clusters to Azure Arc**: Connect your Kubernetes clusters to Azure Arc. For instructions, see [Connect an existing Kubernetes cluster to Azure Arc](/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster).
2. **Create or upgrade your fleet**: Create or upgrade a fleet resource with a hub cluster, and then join your Arc-enabled clusters. For instructions, see [Create a fleet and join member clusters](quickstart-create-fleet-and-members).
3. **Configure workload placement**: Create `ClusterResourcePlacement` resources for your applications. For guidance, see [Kubernetes resource propagation concepts](concepts-resource-placement).

## Public region limitation

Fleet Manager support for Arc-enabled Kubernetes clusters is currently available only in Azure public cloud regions.

If you attempt to create an Arc-enabled member cluster in a non-public cloud region, the operation returns an error of type `FeatureNotAvailableInCloud` with the message `The feature 'Arc Member Cluster' is not available in cloud environment`.

When Azure Arc Gateway is available in Azure non-public cloud regions, Microsoft removes the restriction.

You can track the status of Azure Arc Gateway via its [official documentation](/en-us/azure/azure-arc/kubernetes/arc-gateway-simplify-networking).