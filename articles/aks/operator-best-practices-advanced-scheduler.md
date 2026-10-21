---
layout: Conceptual
title: Best practices for scheduler features in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-advanced-scheduler
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
description: Learn the cluster operator best practices for using advanced scheduler features such as taints and tolerations, node selectors and affinity, or inter-pod affinity and anti-affinity in Azure Kubernetes Service (AKS).
ms.topic: best-practice
ms.custom: aeo-round-2, aks-scaling
ms.date: 2026-08-25T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: bdafadb7-9083-44aa-7e5b-2d17b51005d1
document_version_independent_id: e49f2bc7-f59e-f20c-b8c1-e25e65ad097e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/operator-best-practices-advanced-scheduler.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/operator-best-practices-advanced-scheduler
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/operator-best-practices-advanced-scheduler.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 08971d00-112b-7340-8b68-f8afdf5ad96e
---

# Best practices for scheduler features in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

The best practices for AKS advanced scheduler features include using taints and tolerations to dedicate nodes, node selectors and node affinity to control pod placement, and inter-pod affinity/anti-affinity to manage workload distribution across your cluster. As you manage clusters in Azure Kubernetes Service (AKS), you often need to isolate teams and workloads. Advanced features provided by the Kubernetes scheduler let you control:

- Which pods can be scheduled on certain nodes.
- How multi-pod applications can be appropriately distributed across the cluster.

This best practices article focuses on advanced Kubernetes scheduling features for cluster operators. In this article, you learn how to:

- Use taints and tolerations to limit what pods can be scheduled on nodes.
- Give preference to pods to run on certain nodes with node selectors or node affinity.
- Split apart or group together pods with inter-pod affinity or anti-affinity.
- Restrict scheduling of workloads that require GPUs only on nodes with schedulable GPUs.

If additional capabilities or ML frameworks are needed to schedule and queue batch workloads, you can [install and configure Kueue on AKS](kueue-overview) to ensure efficient, policy-driven scheduling in AKS clusters.

If fine-grained scheduler configuration is needed to optimize how pods and jobs prioritize specific nodes, storage resources, topology, and more, you can [configure a scheduler on AKS](concepts-scheduler-configuration).

## Comparison of scheduling features

| Feature | Use case | Scheduling behavior | When to choose |
| --- | --- | --- | --- |
| Taints and tolerations | Dedicate nodes for specific workloads (e.g., GPU nodes) | Hard restriction: pods without matching toleration cannot schedule on tainted nodes | When you need strict node isolation and want to prevent unauthorized workloads |
| Node selectors | Simple label-based pod placement | Soft restriction: pods require matching labels, but unlabeled pods can still schedule on labeled nodes | When you need basic scheduling control with simple label matching |
| Node affinity | Flexible node targeting with fallback options | Configurable: supports both required (hard) and preferred (soft) matching rules | When you need advanced expressions or want scheduling preferences with fallback behavior |
| Inter-pod affinity/anti-affinity | Co-locate or separate pods based on existing pod placement | Controls pod distribution relative to other pods on nodes | When pod-to-pod relationships matter (e.g., co-locating app and cache, or spreading replicas) |

## What are taints and tolerations?

Taints and tolerations are a Kubernetes mechanism that allows nodes to repel pods unless those pods explicitly tolerate the node's taint, providing hard isolation for dedicated workloads.

> 
> **Best Practice: Use taints and tolerations to dedicate GPU nodes** Limit access for resource-intensive applications, such as ingress controllers, to specific nodes. Keep node resources available for workloads that require them, and don't allow scheduling of other workloads on the nodes.

When you create your AKS cluster, you can deploy nodes with GPU support or a large number of powerful CPUs. For more information, see [Use GPUs on AKS](gpu-cluster). You can use these nodes for large data processing workloads such as machine learning (ML) or artificial intelligence (AI).

Because this node resource hardware is typically expensive to deploy, limit the workloads that can be scheduled on these nodes. Instead, dedicate some nodes in the cluster to run ingress services and prevent other workloads.

This support for different nodes is provided by using multiple node pools. An AKS cluster supports one or more node pools.

The Kubernetes scheduler uses taints and tolerations to restrict what workloads can run on nodes.

- Apply a **taint** to a node to indicate only specific pods can be scheduled on them.
- Then apply a **toleration** to a pod, allowing them to *tolerate* a node's taint.

When you deploy a pod to an AKS cluster, Kubernetes only schedules pods on nodes whose taint aligns with the toleration. Taints and tolerations work together to ensure that pods aren't scheduled onto inappropriate nodes. One or more taints are applied to a node, marking the node so that it doesn't accept any pods that don't tolerate the taints.

### How do I implement taints and tolerations in AKS?

For example, assume you added a node pool in your AKS cluster for nodes with GPU support. You define name, such as *gpu*, then a value for scheduling. Setting this value to *NoSchedule* restricts the Kubernetes scheduler from scheduling pods with undefined toleration on the node.

```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name taintnp \
    --node-taints sku=gpu:NoSchedule \
    --no-wait
```

With a taint applied to nodes in the node pool, you define a toleration in the pod specification that allows scheduling on the nodes. The following example defines the `sku: gpu` and `effect: NoSchedule` to tolerate the taint applied to the node pool in the previous step:

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: app
spec:
  containers:
  - name: app
    image: <your-workload>:gpu
    resources:
      requests:
        cpu: 0.5
        memory: 2Gi
      limits:
        cpu: 4.0
        memory: 16Gi
  tolerations:
  - key: "sku"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
```

When this pod is deployed using `kubectl apply -f gpu-toleration.yaml`, Kubernetes can successfully schedule the pod on the nodes with the taint applied. This logical isolation lets you control access to resources within a cluster.

#### Dedicate node pools to multiple applications

To dedicate separate nodes to different applications, create a node pool for each application with a unique taint and matching label. The taint prevents other pods from being scheduled on the node pool, while the label lets you require that an application runs only on its dedicated node pool.

The following example creates separate node pools for frontend and backend applications:

```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name frontpool \
    --node-count 1 \
    --labels workload=frontend \
    --node-taints workload=frontend:NoSchedule

az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name backpool \
    --node-count 1 \
    --labels workload=backend \
    --node-taints workload=backend:NoSchedule
```

Create a file named `dedicated-apps.yaml` and add the following pod definitions. Each pod has a toleration that matches its node pool's taint and a `nodeSelector` that requires the corresponding node pool label:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  nodeSelector:
    workload: frontend
  tolerations:
  - key: "workload"
    operator: "Equal"
    value: "frontend"
    effect: "NoSchedule"
  containers:
  - name: frontend
    image: mcr.microsoft.com/oss/nginx/nginx:1.25.5
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 250m
        memory: 256Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: backend
  labels:
    app: backend
spec:
  nodeSelector:
    workload: backend
  tolerations:
  - key: "workload"
    operator: "Equal"
    value: "backend"
    effect: "NoSchedule"
  containers:
  - name: backend
    image: mcr.microsoft.com/oss/nginx/nginx:1.25.5
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 250m
        memory: 256Mi
```

Apply the manifest:

```bash
kubectl apply -f dedicated-apps.yaml
```

Verify each pod is running on a node with the expected workload label:

```bash
kubectl get pods -o wide
kubectl get nodes -L workload
```

The `frontend` pod is scheduled on a node labeled `workload=frontend`, and the `backend` pod is scheduled on a node labeled `workload=backend`. A toleration alone allows a pod to use a tainted node but doesn't require placement on that node. The `nodeSelector` provides that requirement.

Delete the example resources when you no longer need them:

```azurecli
kubectl delete -f dedicated-apps.yaml

az aks nodepool delete \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name frontpool

az aks nodepool delete \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name backpool
```

When you apply taints, work with your application developers and owners to allow them to define the required tolerations in their deployments.

For more information about how to use multiple node pools in AKS, see [Create multiple node pools for a cluster in AKS](create-node-pools).

### Behavior of taints and tolerations in AKS

When you upgrade a node pool in AKS, taints and tolerations follow a set pattern as they're applied to new nodes:

#### Default clusters that use Azure Virtual Machine Scale Sets

You can [taint a node pool](manage-node-pools#specify-a-taint-label-or-tag-for-a-node-pool) from the AKS API to have newly scaled out nodes receive API specified node taints.

Let's assume:

1. You begin with a two-node cluster: *node1* and *node2*.
2. You upgrade the node pool.
3. Two other nodes are created: *node3* and *node4*.
4. The taints are passed on respectively.
5. The original *node1* and *node2* are deleted.

#### Clusters without Virtual Machine Scale Sets support

Again, let's assume:

1. You have a two-node cluster: *node1* and *node2*.
2. You upgrade the node pool.
3. An extra node is created: *node3*.
4. The taints from *node1* are applied to *node3*.
5. *node1* is deleted.
6. A new *node1* is created to replace the original *node1*.
7. The *node2* taints are applied to the new *node1*.
8. *node2* is deleted.

In essence, *node1* becomes *node3*, and *node2* becomes the new *node1*.

When you scale a node pool in AKS, taints and tolerations don't carry over by design.

## What are node selectors and node affinity?

Node selectors and node affinity are Kubernetes features that allow pods to specify preferences for which nodes they should run on, based on node labels.

> 
> **Best Practice: Use node selectors and affinity to control pod placement by hardware type** Control the scheduling of pods on nodes using node selectors, node affinity, or inter-pod affinity. These settings allow the Kubernetes scheduler to logically isolate workloads, such as by hardware in the node.

Taints and tolerations logically isolate resources with a hard cut-off. If the pod doesn't tolerate a node's taint, it isn't scheduled on the node.

Alternatively, you can use node selectors. For example, you label nodes to indicate locally attached SSD storage or a large amount of memory, and then define in the pod specification a node selector. Kubernetes schedules those pods on a matching node.

Unlike tolerations, pods without a matching node selector can still be scheduled on labeled nodes. This behavior allows unused resources on the nodes to consume, but prioritizes pods that define the matching node selector.

Let's look at an example of nodes with a high amount of memory. These nodes prioritize pods that request a high amount of memory. To ensure the resources don't sit idle, they also allow other pods to run. The following example command adds a node pool with the label *hardware=highmem* to the *myAKSCluster* in the *myResourceGroup*. All nodes in that node pool have this label.

```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name labelnp \
    --node-count 1 \
    --labels hardware=highmem \
    --no-wait
```

A pod specification then adds the `nodeSelector` property to define a node selector that matches the label set on a node:

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: app
spec:
  containers:
  - name: app
    image: <your-workload>:gpu
    resources:
      requests:
        cpu: 0.5
        memory: 2Gi
      limits:
        cpu: 4.0
        memory: 16Gi
  nodeSelector:
      hardware: highmem
```

When you use these scheduler options, work with your application developers and owners to allow them to correctly define their pod specifications.

For more information about using node selectors, see [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).

### What is node affinity?

A node selector is a basic solution for assigning pods to a given node. *Node affinity* provides more flexibility, allowing you to define what happens if the pod can't be matched with a node. You can:

- *Require* that Kubernetes scheduler matches a pod with a labeled host. Or,
- *Prefer* a match but allow the pod to be scheduled on a different host if no match is available.

The following example sets the node affinity to *requiredDuringSchedulingIgnoredDuringExecution*. This affinity requires the Kubernetes schedule to use a node with a matching label. If no node is available, the pod has to wait for scheduling to continue. To allow the pod to be scheduled on a different node, you can instead set the value to *preferredDuringSchedulingIgnoreDuringExecution*:

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: app
spec:
  containers:
  - name: app
    image: <your-workload>:gpu
    resources:
      requests:
        cpu: 0.5
        memory: 2Gi
      limits:
        cpu: 4.0
        memory: 16Gi
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: hardware
            operator: In
            values:
            - highmem
```

The *IgnoredDuringExecution* part of the setting indicates that the pod shouldn't be evicted from the node if the node labels change. The Kubernetes scheduler only uses the updated node labels for new pods being scheduled, not pods already scheduled on the nodes.

For more information, see [Affinity and anti-affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

### What is inter-pod affinity and anti-affinity?

One final approach for the Kubernetes scheduler to logically isolate workloads is using inter-pod affinity or anti-affinity. These settings define that pods either *shouldn't* or *should* be scheduled on a node that has an existing matching pod. By default, the Kubernetes scheduler tries to schedule multiple pods in a replica set across nodes. You can define more specific rules around this behavior.

For example, you have a web application that also uses an Azure Managed Redis resource.

- You use pod anti-affinity rules to request that the Kubernetes scheduler distributes replicas across nodes.
- You use affinity rules to ensure each web app component is scheduled on the same host as a corresponding cache.

The distribution of pods across nodes looks like the following example:

| **Node 1** | **Node 2** | **Node 3** |
| --- | --- | --- |
| webapp-1 | webapp-2 | webapp-3 |
| cache-1 | cache-2 | cache-3 |

Inter-pod affinity and anti-affinity provide a more complex deployment than node selectors or node affinity. With the deployment, you logically isolate resources and control how Kubernetes schedules pods on nodes.

For a complete example of this web application with Azure Managed Redis, see [Co-locate pods on the same node](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#always-co-located-in-the-same-node).