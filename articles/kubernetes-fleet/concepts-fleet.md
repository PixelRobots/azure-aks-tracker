---
layout: Conceptual
title: Azure Kubernetes Fleet Manager fleets and member clusters | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-fleet
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
description: This article provides a conceptual overview of Azure Kubernetes Fleet Manager and member clusters.
ms.date: 2026-04-01T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: 0f8af6b3-3091-0dfc-f27c-e96d26d6e52b
document_version_independent_id: a0060418-2d65-2356-1e4e-85e75e959b4c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-fleet.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-fleet
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-fleet.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 2f4e3575-96e3-3bf9-9774-e1ac3af6180c
---

# Azure Kubernetes Fleet Manager fleets and member clusters | Microsoft Learn

This article provides a conceptual overview of fleets and member clusters in Azure Kubernetes Fleet Manager.

## What are fleets?

A fleet is a group for Kubernetes clusters that can be managed via a single Fleet Manager resource.

A Fleet Manager, depending on the selected configuration, supports safe multi-cluster updates (Kubernetes and node images), Kubernetes resource propagation, and multi-tenancy with Managed Fleet Namespaces.

For more information about the configuration options for Fleet Manager see [choosing an Azure Kubernetes Fleet Manager option](concepts-choosing-fleet).

## What are member clusters?

You can join [supported Kubernetes clusters](concepts-member-cluster-types) as members. Member clusters must reside in the same Microsoft Entra tenant as the Fleet Manager, but they can be in different Azure regions, resource groups, or subscriptions.

When Fleet Manager is configured with a hub cluster, a `MemberCluster` Kubernetes resource is created on the hub cluster to represent each member cluster. The API for this resource offers a dependable way for multi-cluster application placements to identify registered clusters within a fleet. It also facilitates querying a list of clusters managed by the Fleet Manager or in observing cluster statuses for placement management actions.

### Labels

When Fleet Manager is configured with a hub cluster, Member clusters can have service-defined and user-defined labels associated with them, which are used to select clusters for workload placement. When you apply a [resource placement](concepts-resource-placement), you can use label selectors to target specific member clusters based on their labels. This allows you to deploy workloads only to clusters that match certain criteria, such as region, environment, team, or other custom attributes.

By default, Fleet populates these [service-defined labels](concepts-resource-placement#member-cluster-labels) on each `MemberCluster` resource on the hub cluster.

Member labels should be modified using the Azure CLI (`az fleet member update`) or REST API. They may not be modified directly on the `MemberCluster` resource on the hub cluster.

### Taints

When Fleet Manager is configured with a hub cluster, member clusters support the specification of taints, which apply to the `MemberCluster` resource on the hub cluster. Each taint object consists of the following fields:

- `key`: The key of the taint.
- `value`: The value of the taint.
- `effect`: The effect of the taint, such as `NoSchedule`.

Once a `MemberCluster` is tainted with `NoSchedule` it lets the Fleet Manager scheduler know that the cluster shouldn't receive resources as part of [resource placements](concepts-resource-placement) from the hub cluster.