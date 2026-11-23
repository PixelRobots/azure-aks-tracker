---
layout: Conceptual
title: Node auto-repair | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/node-repair
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
description: Learn about automatic node repair of Windows and Linux nodes in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.custom: linux-related-content, windows-server
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2023-01-10T00:00:00.0000000Z
ms.reviewer: oadeniji
locale: en-us
document_id: 5ff20a9a-ebfe-a51d-b6c0-6731e102fc26
document_version_independent_id: bf889492-34cb-9648-af3a-cbab13554e3e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/node-repair.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/node-repair
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/node-repair.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 4ada337a-4dac-96b2-b207-48c76b255dd1
---

# Node auto-repair | Microsoft Learn

> 
> Applies to: AKS on Windows Server

To help minimize service disruptions for clusters, AKS on Windows Server continuously monitors the health state of worker nodes, and performs automatic node repair if issues arise or if they become unhealthy. This article describes how AKS checks for unhealthy nodes and automatically repairs both Windows and Linux nodes. The article also shows how to manually check node health.

## How AKS checks for unhealthy nodes

AKS uses the following rules to determine if a node is unhealthy and needs repair:

- The node reports a **NotReady** status on consecutive checks.
- The node doesn't report any status within 20-30 minutes.

You can manually check the health state of your nodes with `kubectl`, as follows:

```powershell
kubectl get nodes
```

The status of the nodes should look similar to the following output:

```output
NAME              STATUS   ROLES    AGE   VERSION
moc-l2tlqojhk2d   Ready    master   46h   v1.19.7
moc-l8h8i6lxk1h   Ready    <none>   46h   v1.19.7
moc-lqnjufwo2cy   Ready    master   46h   v1.19.7
moc-ltyl8mqy47z   Ready    <none>   47h   v1.19.7
moc-lwn5xnrapnj   Ready    master   47h   v1.19.7
moc-wvt025q406z   Ready    <none>   47h   v1.19.7
```

## How automatic repair works

If AKS identifies an unhealthy node that remains unhealthy for more than 20-30 minutes, it creates and reimages a new node.

It usually takes 20 to 30 minutes to repair the node. If AKS finds multiple unhealthy nodes during a health check, each node is repaired individually before another repair begins.