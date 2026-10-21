---
layout: Conceptual
title: Create a Kubernetes DaemonSet in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/create-daemonsets
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
description: Learn how to create a DaemonSet in Azure Kubernetes Service (AKS) on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: EkeleAsonye
ms.custom: windows-server
locale: en-us
document_id: 159020d2-0168-b8f3-b111-1753e26dc228
document_version_independent_id: ff88cce2-8e6d-bcd1-309f-58b04aa28054
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/create-daemonsets.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/create-daemonsets
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/create-daemonsets.md
platformId: 66ca57a3-727e-ee23-8ab2-2b680d816d92
---

# Create a Kubernetes DaemonSet in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to create and use a Kubernetes *DaemonSet* in AKS on Windows Server to ensure that a copy of a pod is always available on every worker node in a cluster. You can use a DaemonSet to improve cluster performance by ensuring that an app runs on all the worker nodes, and to deploy pods that do maintenance and provide support services for nodes.

## Overview of DaemonSets

A DaemonSet is a Kubernetes object that ensures a copy of a pod that's defined in the configuration is always available on every worker node in a cluster. When a new node is added to a cluster, the DaemonSet automatically allocates the pod on that node.

Similarly, when a node is deleted, the pod that's running on the node is also deleted and isn't rescheduled on another node (for example, as happens with **ReplicaSets**). This enables you to overcome Kubernetes scheduling limitations and make sure a specific application is deployed on all nodes within the cluster.

DaemonSets can improve the overall cluster performance. For example, you can use them to deploy pods to perform maintenance tasks and support services to every node:

- Run a log collection daemon, such as `Fluentd` and `Logstash`.
- Run a node monitoring daemon, such as `Prometheus`.
- Run a cluster storage daemon, such as `glusterd` or `ceph`.

Although DaemonSets create a pod on every node by default, you can limit the number of acceptable nodes by predefining the node selector field in the YAML file. The DaemonSet controller only creates pods on nodes that match the node selector.

Usually, one DaemonSet deploys one daemon type across all nodes, but it's possible to have multiple DaemonSets control one daemon type by using different labels. A Kubernetes label specifies deployment rules based on the characteristics of individual nodes.

For more information about how to use DaemonSets, see [Kubernetes DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/).

## Create a DaemonSet

You describe a DaemonSet by using a YAML file, and then create it using the `kubectl create` or `kubectl apply` commands (for example, `kubectl create –f example-daemon.yaml`).

The following example describes the features of a DaemonSet configuration file using an nginx image:

```yaml
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: nginx
  name: example-daemon
spec:
  template:
    metadata: null
    labels:
      app: nginx
containers: null
name: nginx
image: nginx
```

To view the current state of the DaemonSet, use the `kubectl describe` command (for example, `kubectl describe daemonset example-daemon`).

## Limit DaemonSet to specific nodes

By default, DaemonSets create pods on all the nodes in a cluster, but with node selectors, you can configure them to create pods only in specific nodes. If you want to limit a DaemonSet to specific nodes, use the `kubectl label` command.

## Update a DaemonSet

You can update a DaemonSet using the `kubectl edit ds<NAME>` command. However, it's recommended that you edit the original configuration file, and then use the `kubectl apply` command when it was initially created. After you apply an update, you can view the update status using the `kubectl rollout status ds <daemonset-name>` command.

## Delete a DaemonSet

To remove a DaemonSet, use the `kubectl delete` command (for example, `kubectl delete –f example-daemon.yaml -n monitoring`). You should be cautious when specifying the name of the DaemonSet file, as deleting a DaemonSet cleans up all the pods it deployed.