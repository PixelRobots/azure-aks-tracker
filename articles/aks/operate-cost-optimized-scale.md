---
layout: Conceptual
title: Operate cost optimized Azure Kubernetes Service (AKS) at scale - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/operate-cost-optimized-scale
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
description: Learn how to operate cost optimized Azure Kubernetes Service (AKS) at scale.
author: schaffererin
ms.author: schaffererin
ms.custom: aks-scaling
ms.topic: how-to
ms.date: 2025-03-18T00:00:00.0000000Z
locale: en-us
document_id: bb28c13c-ac1b-4629-3166-1c46d5767349
document_version_independent_id: b54d48a0-f7bc-2861-983d-2474034bf66d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/operate-cost-optimized-scale.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/operate-cost-optimized-scale
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/operate-cost-optimized-scale.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 26dd0b90-c464-3228-9747-68cd8fb0bada
---

# Operate cost optimized Azure Kubernetes Service (AKS) at scale - Azure Kubernetes Service | Microsoft Learn

This article provides guidance on how to operate cost optimized Azure Kubernetes Service (AKS) at scale.

## Azure Kubernetes Fleet Manager (Kubernetes Fleet)

[Azure Kubernetes Fleet Manager (Kubernetes Fleet)](/en-us/azure/kubernetes-fleet/overview) enables at-scale management of multiple AKS clusters. You can create a *Fleet resource* and use it to manage multiple clusters as a single entity, orchestrate updates across multiple clusters, and propagate Kubernetes resources across multiple clusters. When creating a new *Fleet resource*, you can create it with or without a *hub cluster*. A *hub cluster* is a managed AKS cluster that acts a hub to store and propagate Kubernetes resources.

![Screenshot of a diagram representing Azure Kubernetes Fleet Manager.](media/operate-cost-optimized-at-scale/kubernetes-fleet-manager.png)

Kubernetes Fleet can help you reduce the management overhead cost of operating multiple clusters by providing a single entry point for managing multiple clusters. For more information, see the [Azure Kubernetes Fleet Manager documentation](/en-us/azure/kubernetes-fleet/).

### Resource propagation

Kubernetes Fleet provides *resource propagation* to enable at-scale management of Kubernetes resources. You can create Kubernetes resources in the *hub cluster* and propagate them to specified *member clusters* using the `MemberCluster` and `ClusterResourcePlacement` custom resources.

![Screenshot of a diagram representing Azure kubernetes Fleet Manager resource propagation.](media/operate-cost-optimized-at-scale/kubernetes-resource-propagation.png)

For more information, see [Kubernetes Fleet resource placement from hub cluster to member clusters](/en-us/azure/kubernetes-fleet/concepts-resource-propagation).

### Intelligent resource placement

Kubernetes Fleet provides *intelligent resource placement*, which can make scheduling decisions based on node count, cost of compute/memory in target member clusters, and resource availability in target member clusters. This allows you to place workloads in the most cost-effective member cluster based on your workload requirements.

![Screenshot of a diagram showing how intelligent resource placement works.](media/operate-cost-optimized-at-scale/intelligent-resource-placement.png)

For more information, see [Intelligent cross-cluster Kubernetes resource placement using Azure Kubernetes Fleet Manager](/en-us/azure/kubernetes-fleet/intelligent-resource-placement).

## AKS Automatic

[AKS Automatic](intro-aks-automatic) offers an experience that makes the most common tasks on Kubernetes fast and frictionless, while preserving the flexibility, extensibility, and consistency of Kubernetes. Azure takes care of cluster setup, including node management, scaling, and security, and preconfigures settings that follow AKS well-architected recommendations.

AKS Automatic clusters are designed to help reduce management overhead costs of creating cluster templates, managing the cluster lifecycle, guardrails, and updates. Scaling is seamless and dynamic. Nodes are created based on workload requests using [node autoprovisioning (NAP)](node-autoprovision) and workloads are automatically scaled with features like Horizontal Pod Autoscaler (HPA), [Kubernetes Event Driven Autoscaling (KEDA)](keda-about), and [Vertical Pod Autoscaler (VPA)](vertical-pod-autoscaler).

## Azure Advisor cost recommendations

AKS cost recommendations in Azure Advisor provide recommendations to help you achieve cost-efficiency without sacrificing reliability. Advisor analyzes your resource configurations and recommends optimization solutions. For more information, see [Get Azure Kubernetes Service (AKS) cost recommendations in Azure Advisor](cost-advisors).