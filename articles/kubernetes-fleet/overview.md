---
layout: Conceptual
title: Overview of Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/overview
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
services: kubernetes-fleet
ms.service: azure-kubernetes-fleet-manager
ms.date: 2026-06-15T00:00:00.0000000Z
ms.topic: overview
author: sjwaight
ms.author: simonwaight
description: Overview of Azure Kubernetes Fleet Manager which enables at-scale management of hundreds of Kubernetes clusters.
keywords: Kubernetes, Azure, multi-cluster, multi, containers, multi-cloud
locale: en-us
document_id: 1a8ee6aa-3c54-e9e9-b7f7-6e492c9d4396
document_version_independent_id: 7c20c8d7-12f3-e0a2-11df-1ce2f91f0ecb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: dc2be365-9c28-fdc1-d5c7-168db2c1e0ed
---

# Overview of Azure Kubernetes Fleet Manager | Microsoft Learn

Azure Kubernetes Fleet Manager enables at-scale management of multiple [supported Kubernetes clusters](concepts-member-cluster-types). Fleet Manager provides platform administrators with access to automated safe multi-cluster updates, intelligent Kubernetes resource placement, and a centralized location to access monitoring data for their clusters.

[![A screenshot of the Azure Kubernetes Fleet Manager overview page in the Azure portal. The overview shows there are five Kubernetes clusters running different Kubernetes versions. There are 125 total update runs with 55 failures and 70 successes. Across the five Kubernetes clusters there is a spread of node images.](media/overview/fleet-manager-portal-overview.png)](media/overview/fleet-manager-portal-overview.png#lightbox)

Fleet Manager supports the following scenarios:

- Join AKS clusters across regions and subscriptions, as well as Arc-enabled Kubernetes clusters across clouds and on-premises as member clusters. Read [Azure Kubernetes Fleet Manager member cluster types](concepts-member-cluster-types) to understand more.
- Use [Managed Fleet Namespaces](concepts-fleet-managed-namespace) to grant application teams access to a namespace across multiple clusters. Enforce resource quotas, network policies, and assign user access at the namespace level across multiple clusters.
- Safely and consistently apply Kubernetes version and node image upgrades across multiple clusters with [update runs](concepts-update-orchestration), attaching reusable update strategies to control the order and timing of cluster updates.
- Include optional [manual or automated approvals](update-strategies-gates-approvals) for update groups and stages to provide more fine-grained control over when updates are applied.
- Automatically trigger version upgrades when new Kubernetes or node image versions are published by defining one or more [auto-upgrade profile](concepts-update-orchestration#auto-upgrade-profiles-overview).
- Deploy a hub cluster to enable intelligent placing of Kubernetes resources across member clusters based on cluster labels and properties using Fleet Manager [cluster resource placement](concepts-resource-placement) and [namespace-scoped resource placement](concepts-namespace-scoped-resource-propagation).
- Stage Kubernetes resources from Git repositories to Fleet Manager's hub cluster using [Automated Deployments](concepts-automated-deployments) (preview).
- Load balance incoming public traffic across service endpoints on multiple AKS clusters using [DNS-based load balancing](concepts-dns-load-balancing) (preview).
- Simplify creating globally available services by configuring [cross-cluster networking](concepts-cross-cluster-networking) for your member clusters (preview).