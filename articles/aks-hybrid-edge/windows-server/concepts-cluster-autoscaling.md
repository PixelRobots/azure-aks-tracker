---
layout: Conceptual
title: Cluster autoscaling in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/concepts-cluster-autoscaling
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn about automatically scaling node pools in AKS on Windows Server.
ms.topic: concept-article
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: windows-server
locale: en-us
document_id: 6726f6e7-807e-2501-807f-e443138d1911
document_version_independent_id: 424c5e93-29e2-cf13-af06-540fceaf54e4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/concepts-cluster-autoscaling.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/concepts-cluster-autoscaling
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/concepts-cluster-autoscaling.md
platformId: 18df68ad-48c9-5068-c03f-c681f46dfc4c
---

# Cluster autoscaling in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

You can adjust the number of nodes that run application workloads in AKS by using Azure Kubernetes Service (AKS) to keep up with demand. You can use PowerShell to enable the autoscaler and to manage automatic scaling of node pools in your target clusters.

This article describes the context of the autoscaler in AKS on Windows Server, and how the autoscaler works. For cluster autoscaling to work effectively, you can also use the Kubernetes horizontal pod autoscaler, which is a standard Kubernetes component. For more information about the Kubernetes horizontal pod autoscaler, see [Horizontal pod autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).

## Cluster autoscaling

In AKS, the cluster autoscaler watches for pods in your cluster that can't be scheduled because of resource constraints. When issues are detected, the number of nodes in a node pool increases to meet application demand. Nodes are also regularly checked for a lack of running pods, and then the number of nodes decreases, as needed. This ability to automatically scale up or scale down the number of nodes in your AKS cluster lets you run efficient, cost-effective clusters. *Autoscaling* is the ability of the system to automatically adjust your workloads through automation and configuration that contains specific parameters based on input, measures, and rules.

To enable the cluster autoscaler, AKS needs to implement basic resource management. AKS estimates resource requirements that will trigger autoscaling events at a point in time. AKS won't take into account resource consumption from outside AKS. For example, when you add VMs after enabling the autoscaler, this event occurs outside the context of the autoscaler.

## Purpose of cluster autoscaling

The autoscaler automatically increases the size of a node pool from the minimum to the maximum number of nodes specified. When you enable automatic scaling, the autoscaler determines if the maximum number of nodes is feasible and warns you about over-provisioning the available hardware resources.

The autoscaler tracks available and promised resources across all deployed target clusters and node pools. The scaler uses this data to make an informed decision. As the autoscaler increases the node pool, the autoscaler checks for the availability of resources.

AKS uses the built-in Kubernetes autoscaling feature to support operations similar to the Azure autoscaler.

## How cluster autoscaling works

The autoscaler adjusts to changing application demands. As demands change between workday and evening loads, the autoscaler shifts your clusters resources. Kubernetes clusters scale in two ways:

- **Triggers based on node utilization**. The cluster autoscaler watches for pods that can't be scheduled on nodes because of resource constraints. The cluster autoscaler decreases the number of nodes when there has been unused capacity for time.
- **Triggers defined in the autoscaler profiles**. The cluster autoscaler uses startup parameters for triggers like time intervals between scale events and resource thresholds. See [Autoscaler Profiles](work-with-autoscaler-profiles).

When you enable autoscaling on a node pool, the default profile is applied unless you override one or more of the settings using the `-ClusterAutoScalingProfile` parameter on `Set-AksHciCluster`. Unless you enable them, the default state of the node autoscaler is disabled at both the cluster and node pool creation time.

When you enable the autoscaler for a cluster and you don't provide an **autoscalerconfig** object, the default autoscaler profile is added to the cluster. You can then fine tune the parameters in the profile by using the `Set-AksHciCluster` command and passing an **autoscalerconfig** object with the updated values. You don't need to provide all parameters in the object, you can just provide your updated parameters in the object.

## Working with the autoscaler

You can set the parameters in the autoscaler profile to configure the autoscaler. For more information, see [How to use the autoscaler profiles](work-with-autoscaler-profiles).

You can use PowerShell to enable, configure, and disable the autoscaler. For more information, see [Use PowerShell for cluster autoscaling](work-with-horizontal-autoscaler).

## Cluster autoscale during a cluster upgrade

During a cluster upgrade and update, the autoscaler is paused and no scaling operation occurs until the cluster and all node pools in the cluster complete the update operation. If a specific node pool in a cluster is updated to a newer Kubernetes version, the autoscaler for that node pool is paused. The autoscaling operation continues on all other node pools.