---
layout: Conceptual
title: Multi-cluster identity binding management with Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-fleet-identity-binding
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
description: This article provides a conceptual overview of how you can manage identity binding resources across multiple clusters using Azure Kubernetes Fleet Manager.
ms.date: 2026-10-06T00:00:00.0000000Z
author: nibooy
ms.author: yoobinshin
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: 9bfd042b-b82d-5f7f-67d2-056522eb1d16
document_version_independent_id: 580881ef-2d26-0767-1440-814763a4cfdd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-fleet-identity-binding.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-fleet-identity-binding
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-fleet-identity-binding.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c9977a96-69b4-7caf-4591-715a98428965
---

# Multi-cluster identity binding management with Azure Kubernetes Fleet Manager | Microsoft Learn

**Applies to**: ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Fleet Manager identity binding profiles let you centrally manage workload identity across multiple clusters.

[Identity bindings for Azure Kubernetes Service (AKS)](../aks/identity-bindings-concepts) solve the scaling limitation of the existing [workload identity feature](../aks/workload-identity-overview) by creating a single federated identity credential (FIC) per user-assigned managed identity (UAMI), allowing multiple AKS clusters to reuse the FIC. An identity binding maps one UAMI to one AKS cluster. If workloads on multiple clusters need to use the same UAMI, you need to create an identity binding for each cluster.

Identity binding profiles address this limitation by allowing you to define an identity binding once at the fleet level and distribute it across multiple clusters.

In this article, we introduce key concepts for managing identity bindings across multiple clusters by using Azure Kubernetes Fleet Manager and identity binding profiles.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

## Prerequisites and limitations

- Member clusters must have [workload identity](/en-us/azure/aks/workload-identity-overview) and OIDC issuer enabled.
- Member clusters configured with [API server VNet integration](/en-us/azure/aks/api-server-vnet-integration) aren't supported.
- Arc-enabled Kubernetes clusters aren't supported.
- An identity binding profile can authorize a maximum of 100 subjects.
- Identity Binding properties (name and managed identity) can't be changed after creation.
- Fleet Manager doesn't take over identity bindings that already exist on a member cluster.
- Identity bindings configured and distributed by Fleet Manager can't be directly modified on member clusters.

## What is an identity binding profile?

An identity binding profile defines the identity binding that each selected member cluster should have. It holds two things:

- The **managed identity** that workloads use for Microsoft Entra token acquisition. Every selected cluster binds the same identity.
- An optional list of **allowed subjects** defined by a JSON array of label selectors that match the namespaces and service accounts on the clusters that are authorized to use the identity.

Note

The `allowedSubjects` field of AKS Identity Binding is in preview.

If you omit this field, the system uses `ClusterRole` and `ClusterRoleBinding` objects on the member cluster for authorization, and you must define them manually. See [authorize namespaces and service accounts](../aks/identity-bindings#authorize-namespaces-and-service-accounts). On a fleet with a hub cluster, you can distribute these objects to multiple clusters by using workload placement with a [ClusterResourceEnvelope](quickstart-envelope-reserved-resources).

When you apply the identity binding profile, Fleet Manager creates and manages the identity binding resource on each selected member cluster by using the profile's configuration. Every selected cluster gets the same configuration.

Identity binding profiles select member clusters with [member cluster labels](concepts-member-cluster-labels) in the same way [resource placement](concepts-resource-placement) does. Use the same labels for both so that your workloads target the clusters where the identity is configured. When you add a cluster to the selection, apply the profile and confirm that the binding is created before you place workloads on it.