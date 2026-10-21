---
layout: Conceptual
title: Automatically Repair Azure Kubernetes Service (AKS) Nodes - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-auto-repair
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
description: Learn how AKS node auto-repair works, including health detection, repair actions, limitations, and monitoring guidance for production workloads.
ms.topic: concept-article
ms.subservice: aks-nodes
ms.date: 2026-07-01T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: d6e03959-4b56-0b9a-e6e1-1518e0006056
document_version_independent_id: 37bd998a-df9a-8423-3466-3d87a5efb29b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-auto-repair.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/node-auto-repair
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-auto-repair.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: bfc22d83-71bd-99aa-c0db-62896eef358e
---

# Automatically Repair Azure Kubernetes Service (AKS) Nodes - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic ✔️ AKS Standard

Azure Kubernetes Service (AKS) continuously monitors the health state of worker nodes and performs automatic node repair if they become unhealthy. The Azure virtual machine (VM) platform [performs maintenance on VMs](/en-us/azure/virtual-machines/maintenance-and-updates) experiencing issues. AKS and Azure VMs work together to minimize service disruptions for clusters.

For most production workloads, AKS Automatic is the recommended production-ready default experience for AKS. Both AKS Automatic and AKS Standard clusters come preconfigured with node auto-repair.

In this article, you learn how node auto-repair works, when repair actions trigger, what limitations apply, and how to monitor repair events.

## Node auto-repair behavior by cluster mode

Both AKS cluster modes come preconfigured with node auto-repair:

- **AKS Automatic**: Preconfigured as part of AKS Automatic production-ready defaults.
- **AKS Standard**: Preconfigured on AKS Standard clusters without extra setup.

Both modes use the same node health checks and the same repair sequence described in this article.

For more information about AKS Automatic platform defaults, see [What is Azure Kubernetes Service (AKS) Automatic?](intro-aks-automatic)

## How AKS checks for NotReady nodes

AKS uses the following rules to determine if a node is unhealthy and needs repair:

- The node reports the [**NotReady**](https://kubernetes.io/docs/reference/node/node-status/#condition) status on consecutive checks within a 10-minute time frame.
- The node doesn't report any status within 10 minutes.

You can manually check the health state of your nodes with the `kubectl get nodes` command.

## How automatic repair works

Note

AKS initiates repair operations with the user account **aks-remediator**.

If AKS identifies an unhealthy node that stays unhealthy for at least five minutes, AKS performs the following actions:

1. AKS reboots the node.
2. If the node stays unhealthy after reboot, AKS reimages the node.
3. If the node stays unhealthy after reimage and it's a Linux node, AKS redeploys the node.

AKS retries the restart, reimage, and redeploy sequence up to three times if the node stays unhealthy. The overall auto-repair process can take up to one hour to complete.

## Production considerations

Node auto-repair is a core resilience mechanism, but combine it with workload-level resiliency practices:

- Run critical workloads with multiple replicas.
- Use PodDisruptionBudgets and readiness probes to reduce user-visible impact.
- Monitor repair activity and error events to detect repeated node problems.
- Incorporate auto-repair timing into SLO/SLA and incident-response planning.

## Limitations

AKS node auto-repair is a best-effort service. AKS doesn't guarantee a node is restored to healthy status in every scenario. If a node remains unhealthy, perform manual investigation. For more information, see [Troubleshoot node NotReady status](/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/node-not-ready-basic-troubleshooting).

AKS might not perform automatic repair in the following scenarios:

- A network configuration error prevents reporting of a node status.
- A node fails to register as a healthy node.
- A node has either of the following taints:
    - `node.cloudprovider.kubernetes.io/shutdown`
    - `ToBeDeletedByClusterAutoscaler`
- A node is being upgraded and has the following annotations:
    - `"cluster-autoscaler.kubernetes.io/scale-down-disabled": "true"`
    - `"kubernetes.azure.com/azure-cluster-autoscaler-scale-down-disabled-reason": "upgrade"`

## Monitor node auto-repair using Kubernetes events

When AKS performs node auto-repair, it emits Kubernetes events from the `aks-auto-repair` source. The following events appear on a node object when auto-repair occurs.

To learn more about accessing, storing, and alerting on Kubernetes events, see [Use Kubernetes events for troubleshooting in AKS](events).

| Reason | Event message | Description |
| --- | --- | --- |
| NodeRebootStart | Node auto-repair is initiating a reboot action due to NotReady status persisting for more than five minutes. | This event notifies you when reboot is about to be performed on your node. This action is the first in the overall node auto-repair sequence. |
| NodeRebootEnd | Reboot action from node auto-repair is completed. | Emitted once reboot is complete on the node. This event doesn't indicate the health status (healthy or unhealthy) of the node after the reboot is performed. |
| NodeReimageStart | Node auto-repair is initiating a reimage action due to NotReady status persisting for more than five minutes. | This event notifies you when reimage is about to be performed on your node. |
| NodeReimageEnd | Reimage action from node auto-repair is completed. | Emitted once reimage is complete on the node. This event doesn't indicate the health status (healthy or unhealthy) of the node after the reimage is performed. |
| NodeRedeployStart | Node auto-repair is initiating a redeploy action due to NotReady status persisting more than five minutes. | This event notifies you when redeploy is about to be performed on your node. Redeploy is the last action in the node auto-repair sequence. |
| NodeRedeployEnd | Redeploy action from node auto-repair is completed. | Emitted once redeploy is complete on the node. This event doesn't indicate the health status (healthy or unhealthy) of the node after redeploy is performed. |

If errors occur during node auto-repair, AKS emits the following events with the verbatim error message. For more information, see [Troubleshooting common node auto-repair errors](/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/node-auto-repair-errors).

Note

*Error code* in the following event messages varies based on the reported error.

| Reason | Event message | Description |
| --- | --- | --- |
| NodeRebootError | Node auto-repair reboot action failed due to an operation failure. See error details here: *Error code* | Emitted when there's an error with the reboot action. |
| NodeReimageError | Node auto-repair reimage action failed due to an operation failure. See error details here: *Error code* | Emitted when there's an error with the reimage action. |
| NodeRedeployError | Node auto-repair redeploy action failed due to an operation failure. See error details here: *Error code* | Emitted when there's an error with the redeploy action. |