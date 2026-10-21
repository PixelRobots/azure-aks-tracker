---
layout: Conceptual
title: Adapt applications for use in mixed-OS Kubernetes clusters | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/adapt-apps-mixed-os-clusters
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
description: Learn how to use node selectors or taints and tolerations on Azure Kubernetes Service to ensure applications in mixed OS Kubernetes clusters running on AKS on Windows Server are scheduled on the correct worker node operating system.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: windows-server
locale: en-us
document_id: f5a9d6bc-e5d8-8d6c-2d92-d054bbf95304
document_version_independent_id: 8f127fa0-9d93-f9a7-a8f6-20833d823220
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/adapt-apps-mixed-os-clusters.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/adapt-apps-mixed-os-clusters
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/adapt-apps-mixed-os-clusters.md
platformId: 9664d4bb-7d89-9afc-bf9a-912c89085adf
---

# Adapt applications for use in mixed-OS Kubernetes clusters | Microsoft Learn

> 
> Applies to: AKS on Windows Server

AKS on Windows Server enables you to run Kubernetes clusters with both Linux and Windows nodes, but you must make small edits to your apps for use in these mixed-OS clusters. This how-to guide describes how to ensure your application gets scheduled on the right host OS using either node selectors or taints and tolerations.

This article assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for AKS on Windows Server](kubernetes-concepts).

## Node selectors

A *node selector* is a simple field in the pod specification YAML that constrains pods to only be scheduled onto healthy nodes matching the operating system. In your pod specification YAML, specify a `nodeSelector` value of Windows or Linux, as shown in the following examples:

```yaml
kubernetes.io/os = Windows
```

or,

```yaml
kubernetes.io/os = Linux
```

For more information about node selectors, see [node selectors](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/).

## Taints and tolerations

**Taints** and **tolerations** work together to ensure that pods aren't unintentionally scheduled on nodes. A node can be "tainted" to reject pods that don't explicitly tolerate its taint through a "toleration" in the pod specification YAML.

Windows OS nodes in AKS can be tainted when created with the [New-AksHciNodePool](/en-us/azure/aks/aksarc/reference/ps/new-akshcinodepool) or the [New-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/new-akshcicluster) commands. You can also use these commands to taint Linux OS nodes. The following example taints Windows nodes.

### Apply taint to new cluster

If you also create a new cluster, run the following command to create a Windows node pool with a taint. If you have an existing cluster to which you want to add a node pool with a taint, see the next example, which uses the `New-AksHciNodePool` command.

```powershell
New-AksHciCluster -name mycluster -nodePoolName taintnp -nodeCount 1 -osType Windows -osSku Windows2022 -taints sku=Windows:NoSchedule
```

### Add tainted node pool to existing cluster

To add a tainted node pool to an existing cluster, run the following command:

```powershell
New-AksHciNodePool -clusterName <cluster-name> -nodePoolNAme taintnp -count 1 -osType Windows -osSku Windows2022 -taints sku=Windows:NoSchedule
```

To check that the node pool was successfully deployed with the taint, run the following command:

```powershell
Get-AksHciNodePool -clusterName <cluster-name> -name taintnp
```

Example output:

```output
Status       : {Phase, Details}
ClusterName  : mycluster
NodePoolName : taintnp
Version      : v1.20.7-kvapkg.1
OsType       : Windows
NodeCount    : 0
VmSize       : Standard_K8S3_v1
Phase        : Deployed
Taints       : {sku=Windows:NoSchedule}
```

### Specify toleration for pod

You can specify a toleration for a pod in the pod specification YAML. The following toleration "matches" the taint created by the `kubectl` taint line shown in the previous example. The result is that a pod with the toleration can schedule onto the tainted nodes.

```yaml
tolerations:
- key: node.kubernetes.io/os
  operator: Equal
  value: Windows
  effect: NoSchedule
```

The steps in this section work well if you're in control of the pod spec that you're deploying. However, in some cases, users have a pre-existing large number of deployments for Linux containers, as well as an ecosystem of common configurations, such as community [Helm charts](https://helm.sh/docs/intro/using_helm/#helm-search-finding-charts). You won't have access to the pod spec unless you want to download and edit the chart.

If you deploy these Helm charts to a mixed cluster environment with both Linux and Windows worker nodes, your application pods fail with the error "ImagePullBackOff". For example:

```powershell
kubectl get pods
```

```output
NAMESPACE              NAME                                                    READY   STATUS              RESTARTS   AGE
default                nginx-deployment-558fc78868-795dp                       0/1     ImagePullBackOff    0          6m24s
default                nginx-deployment-6b474476c4-gpb77                       0/1     ImagePullBackOff    0          11m
```

In this instance, you can use [taints](https://cloud.google.com/kubernetes-engine/docs/how-to/node-taints) to help with this. Windows Server nodes can be tainted with the key-value pair `node.kubernetes.io/os=windows:NoSchedule`.

For more information about taints and tolerations, see [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/).