---
layout: Conceptual
title: Configure queues with managed Kueue using default workload priority on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-queues-with-automatic-resource-flavors
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
description: Simplify workload queueing and prioritization on AKS with managed Kueue automatically generated resource flavors and default workload priority classes
ms.topic: how-to
ms.date: 2026-10-08T00:00:00.0000000Z
author: colinmixon
ms.author: colinmixon
locale: en-us
document_id: 811b411d-f1fe-b080-ee04-3eb4804314c3
document_version_independent_id: 8b0d89c1-72f0-8c72-c075-6f60eaa9dcd1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-queues-with-automatic-resource-flavors.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/configure-queues-with-automatic-resource-flavors
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-queues-with-automatic-resource-flavors.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 18a0b657-009d-c1d6-ce1f-cf83a37df337
---

# Configure queues with managed Kueue using default workload priority on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Managed Kueue on Azure Kubernetes Service (AKS) simplifies workload queueing and prioritization by providing managed resource flavors when you add any node pool to a cluster and three default workload priority classes from low to high priority.

In this article, you learn how to:

- Configure a ClusterQueue using the generated `aks-cpu` ResourceFlavor.
- Create a LocalQueue for submitting workloads.
- Use managed workload priority classes to control admission and preemption.

## Understand managed Kueue resources

Managed Kueue provides AKS-managed resources that you can reference when configuring queues and workloads. For CPU workloads, managed Kueue provides the `aks-cpu` ResourceFlavor. You can reference this ResourceFlavor from a `ClusterQueue` to associate queue quota with eligible CPU nodes.

Managed Kueue also provides the following workload priority classes:

| Priority class | Value |
| --- | --- |
| `aks-low-priority` | `100` |
| `aks-medium-priority` | `500` |
| `aks-high-priority` | `1000` |

When workloads compete for limited quota, Kueue uses workload priority as part of admission ordering. You can also configure preemption on the ClusterQueue to allow higher-priority workloads to reclaim quota from lower-priority workloads.

## Prerequisites

Before you begin, ensure you have the following resources and tools:

- An AKS cluster with the managed Kueue extension installed.
- [Azure CLI](/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- An Azure subscription with permissions to create AKS node pools.
- The `RESOURCE_GROUP` and `CLUSTER_NAME` environment variables set for your AKS cluster.

## Add a CPU user node pool

Add a CPU user node pool to your AKS cluster:

```bash
az aks nodepool add \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$CLUSTER_NAME" \
  --name cpupool \
  --node-count 1 \
  --node-vm-size Standard_D2s_v3 \
  --mode User
```

Wait for the node to become ready:

```bash
kubectl wait \
  --for=condition=Ready nodes \
  --selector kubernetes.azure.com/agentpool=cpupool \
  --timeout=10m
```

The managed Kueue extension creates an `aks-cpu` ResourceFlavor for eligible CPU user nodes. A `ClusterQueue` can use this ResourceFlavor to associate queue quota with those nodes.

Note

The managed Kueue extension manages resources prefixed with `aks-`, such as `aks-cpu`. Use these resources in your Kueue configuration instead of creating replacements with the same `aks-` prefix.

## Create a ClusterQueue and LocalQueue

Kueue uses two queue resources: a `ClusterQueue` and a `LocalQueue`. A `ClusterQueue` defines cluster-level resource quotas and admission policies. A `LocalQueue` provides a namespaced queue that workloads reference when submitting work.

You can combine the automatically generated `aks-cpu` ResourceFlavor with workload priority and preemption policies in the same `ClusterQueue`. This configuration lets workloads share managed CPU capacity while giving higher-priority workloads access to constrained quota when needed.

This configuration:

1. Provides the `ClusterQueue` with three CPUs of nominal quota through the automatically generated `aks-cpu` ResourceFlavor.
2. Creates the `kueue-demo-queue``LocalQueue` for workloads in the `kueue-demo` namespace.
3. Sets `withinClusterQueue` to `LowerPriority`, which allows a higher-priority workload to reclaim quota from a lower-priority workload in the same `ClusterQueue`.

Create a file named `kueue-demo.yaml` with the following configuration:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: kueue-demo
---
apiVersion: kueue.x-k8s.io/v1beta2
kind: ClusterQueue
metadata:
  name: kueue-demo-cq
spec:
  namespaceSelector: {}
  queueingStrategy: BestEffortFIFO
  preemption:
    withinClusterQueue: LowerPriority
  resourceGroups:
  - coveredResources:
    - cpu
    flavors:
    - name: aks-cpu
      resources:
      - name: cpu
        nominalQuota: "3"
---
apiVersion: kueue.x-k8s.io/v1beta2
kind: LocalQueue
metadata:
  name: kueue-demo-queue
  namespace: kueue-demo
spec:
  clusterQueue: kueue-demo-cq
Apply the configuration:
```

```batch
kubectl apply -f kueue-demo.yaml
```

## Use workload priority and preemption

When you submit workloads to the `LocalQueue`, you can assign one of the managed workload priority classes:

- Use `aks-high-priority` for workloads that should receive constrained queue capacity ahead of lower-priority work.
- Use `aks-medium-priority` for workloads with standard priority requirements.
- Use `aks-low-priority` for workloads that can wait when queue capacity is constrained.

When you configure `withinClusterQueue` to `LowerPriority`, a higher-priority workload can preempt a lower-priority workload when both workloads require quota from the same `ClusterQueue`. When quota becomes available again, the lower-priority workload remains eligible for admission.

This approach lets you use AKS-managed ResourceFlavors and priority classes without creating and maintaining custom ResourceFlavor or workload priority resources.