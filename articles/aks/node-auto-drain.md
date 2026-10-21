---
layout: Conceptual
title: Automatically drain Azure Kubernetes Service (AKS) nodes - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-auto-drain
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
description: Learn about node auto-drain functionality and how AKS protects your workloads from scheduled VM maintenance events.
ms.topic: concept-article
ms.subservice: aks-nodes
ms.date: 2026-03-30T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: 661759ae-2bfb-6ae6-86b2-6bb3acd40a9f
document_version_independent_id: d76f935a-eb3c-b2d1-fbd1-513cd47ed51b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-auto-drain.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/node-auto-drain
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-auto-drain.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 2444e75a-2556-2109-525a-6d6e7489e28a
---

# Automatically drain Azure Kubernetes Service (AKS) nodes - Azure Kubernetes Service | Microsoft Learn

Node auto-drain helps you protect your node workloads from disruptions when [scheduled events](/en-us/azure/virtual-machines/linux/scheduled-events) occur on the underlying virtual machines (VMs) in any of your node pools. When certain node events happen, node auto-drain attempts a cordon and drain of the affected node so the workloads can be rescheduled safely. An example of when node auto-drain might occur is when scheduled events on a [spot node pool](spot-node-pool) cause a preempt node event. The spot node with the taint `"kubernetes.azure.com/scalesetpriority: spot"` may receive a taint with `"remediator.kubernetes.azure.com/unschedulable"` when a scheduled event occurs on that node.

Note

Node auto-drain is a best effort service and can't be guaranteed to operate perfectly in all scenarios.

## Scheduled event actions

The following table shows the node events for AKS node auto-drain and describes their associated actions:

| Event | Description | Action |
| --- | --- | --- |
| Freeze | The underlying virtual machine (VM) is scheduled to pause for a few seconds. CPU and network connectivity might be suspended, but there's no impact on memory or open files. | Opt in to [pod eviction on freeze events (preview)](node-auto-drain-evict-on-freeze). |
| Reboot | The VM is scheduled for reboot. The VM's non-persistent memory is lost. | No action. |
| Redeploy | The VM is scheduled to move to another node. The VM's ephemeral disks are lost. | Cordon and drain. |
| Preempt | The spot VM is being deleted. The VM's ephemeral disks are lost. | Cordon and drain. |
| Terminate | The VM is scheduled for deletion. | No action. |

Note

Redeploy and Preempt use default behavior and don't require extra configuration. Freeze and Terminate require opt-in configuration:

- Freeze: [Configure pod eviction for freeze events](node-auto-drain-evict-on-freeze).
- Terminate: Enable [Virtual Machine Scale Set terminate notifications](/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-terminate-notification) as a prerequisite for AKS node auto-drain.