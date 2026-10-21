---
layout: Conceptual
title: Scale an Azure Kubernetes Service cluster | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/scale-cluster
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
description: Learn how to scale the number of nodes in a Kubernetes cluster in AKS on Windows Server.
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.custom: windows-server
locale: en-us
document_id: 54fb658f-6559-c475-7849-b657d044deba
document_version_independent_id: 37bc694d-7abf-c498-f965-e4494ee9d99c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/scale-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/scale-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/scale-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: 3222f0cf-5488-bfa9-a57d-13a13d2e39c7
---

# Scale an Azure Kubernetes Service cluster | Microsoft Learn

> 
> Applies to: AKS on Windows Server

If the resource needs of your applications change in AKS on Windows Server, you can manually scale a Kubernetes cluster to run a different number of control plane nodes and worker nodes. You must scale the control plane nodes and worker nodes separately.

## Scale control plane nodes

Use the [Set-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/set-akshcicluster) command to scale the control plane nodes. The following example scales the control plane nodes in a cluster named `mycluster` to a node count of 3:

```powershell
Set-AksHciCluster -name mycluster -controlPlaneNodeCount 3
```

## Scale worker nodes in a node pool

Use the [Set-AksHciNodePool](/en-us/azure/aks/aksarc/reference/ps/set-akshcinodepool) command to scale the node pool. The following example scales a node pool called `linuxnodepool` in a cluster named `mycluster` to a node count of 3:

```powershell
Set-AksHciNodePool -clustername mycluster -name linuxnodepool -count 3
```