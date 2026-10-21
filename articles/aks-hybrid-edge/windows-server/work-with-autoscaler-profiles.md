---
layout: Conceptual
title: Use the autoscaler profile to configure cluster autoscaling in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/work-with-autoscaler-profiles
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
description: Learn how to use the autoscaler profile to configure Cluster autoscaler in Azure Kubernetes Service (AKS) on Windows Server.
ms.topic: how-to
author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2024-06-27T00:00:00.0000000Z
ms.custom: windows-server
locale: en-us
document_id: 53ced5b7-6bfe-1ebf-be17-6c5c9cd42e76
document_version_independent_id: 1c1139d5-5de2-7706-9042-ffeaeb58c15c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/work-with-autoscaler-profiles.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/work-with-autoscaler-profiles
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/work-with-autoscaler-profiles.md
platformId: 0def6cbe-4d76-f4c8-f022-6f30465af811
---

# Use the autoscaler profile to configure cluster autoscaling in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

You can use the parameters in the autoscaler profile object to define scale events in AKS on Windows Server. The cluster autoscaler profile affects all node pools that use the cluster autoscaler; you can't set an autoscaler profile per node pool. This article explains how the autoscaler works, describes default autoscaler profile values, and describes how to configure and use a profile definition.

## Using profiles

Cluster autoscaler profiles have the following attributes:

- Autoscaler profiles apply to all node pools in a cluster.
- Profiles are global deployment-level objects.
- Multiple profiles are available in AKS.
- Only one profile is assigned to a given cluster. The profile is used for all node pools in the cluster.
- Changes to the profile are applied to all node pools that have the autoscaler function enabled.

## Profile settings

The default profile uses the following default values. You can update the following settings.

| Setting | Description | Default value |
| --- | --- | --- |
| `min-node-count` | The minimum node count that the node pool to which this profile is assigned can scale down to. | 0 |
| `max-node-count` | The maximum node count that the node pool to which this profile is assigned can scale up to. | 1 |
| `scan-interval` | How often cluster is reevaluated for scale up or down. | 10 seconds |
| `scale-down-delay-after-add` | How long after scale up that scale down evaluation resumes. | 10 minutes |
| `scale-down-delay-after-delete` | How long after node deletion that scale down evaluation resumes. | `scan-interval` |
| `scale-down-delay-after-failure` | How long after a scale down failure that scale down evaluation resumes. | 3 minutes |
| `scale-down-unneeded-time` | How long a node should be unneeded before it's eligible for scale down. | 10 minutes |
| `scale-down-unready-time` | How long an unready node should be unneeded before it's eligible for scale down. | 20 minutes |
| `scale-down-utilization-threshold` | Node utilization level, defined as the sum of requested resources divided by capacity, below which a node can be considered for scale down. | 0.5 |
| `max-graceful-termination-sec` | Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node. | 600 seconds |
| `balance-similar-node-groups` | Detects similar node pools and balances the number of nodes between them. | false |
| `expander` | Type of node pool [expander](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders) to use in scale up. Possible values: `most-pods`, `random`, `least-waste`, `priority`. | `random` |
| `skip-nodes-with-local-storage` | If **true**, cluster autoscaler never deletes nodes with pods with local storage, for example, **EmptyDir** or **HostPath**. | **true** |
| `skip-nodes-with-system-pods` | If **true**, cluster autoscaler never deletes nodes with pods from `kube-system` (except for DaemonSet or mirror pods). | **true** |
| `max-empty-bulk-delete` | Maximum number of empty nodes that can be deleted at the same time. | 10 |
| `new-pod-scale-up-delay` | For scenarios such as burst or batch scale where you don't want the CA to act before the Kubernetes scheduler can schedule all the pods, you can tell the CA to ignore unscheduled pods before they're a certain age. | 0 seconds |
| `max-total-unready-percentage` | Maximum percentage of unready nodes in the cluster. After this percentage is exceeded, CA halts operations. | 45% |
| `max-node-provision-time` | Maximum time the autoscaler waits for a node to be provisioned. | 15 minutes |

## Notes on autoscaler configuration

You can change settings in the cluster autoscaler profile by using the [Set-AksHciAutoScalerConfig](work-with-horizontal-autoscaler#change-an-existing-akshciautoscalerconfig-profile-object) PowerShell cmdlet.

The cluster autoscaler makes scaling decisions based on the minimum and maximum counts set on each node pool, but it doesn't enforce them after updating the min or max counts. For example, setting a minimum count of 5 when the current node count is 3 doesn't immediately scale the pool up to 5.

If the minimum count on the node pool is higher than the current number of nodes, the new minimum or maximum settings take effect when there are enough unschedulable pods that require two new additional nodes and trigger an autoscaler event. After the scale event, the new count limits are respected.

You can also configure more granular details of the cluster autoscaler by changing the default values in the cluster-wide autoscaler profile. For example, a scale down event happens after nodes are under-utilized for 10 minutes. If you have workloads that run every 15 minutes, you might want to change the autoscaler profile to scale down under-utilized nodes after 15 or 20 minutes. When you enable the cluster autoscaler, a default profile is used unless you specify different settings.

## Save and load the autoscaler profile

You can save and store your autoscaler profile in a profile definition as a YAML file. You can manually edit the YAML file from a text editor, and you can load saved definitions.

### Save your profile definition

You save a copy of the profile as a YAML file by using `kvactl`. After you define your profile, run the following commands:

```powershell
kvactl.exe autoscalerprofile get --name default --kubeconfig (Get-AksHciConfig).Kva.kubeconfig --outputformat=yaml > def.yaml
```

### Edit your profile definition

You can edit the profile definition in the YAML file. For example, you can open **def.yaml** in Notepad, Visual Studio Code, or other text editors.

### Load your profile definition

You can load the profile definition by using `kvactl` from the saved YAML file. Run the following command:

```powershell
kvactl.exe autoscalerprofile create --profileconfig .\def-new.yaml --kubeconfig (Get-AksHciConfig).Kva.kubeconfig
```