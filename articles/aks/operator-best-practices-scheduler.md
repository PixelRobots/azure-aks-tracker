---
layout: Conceptual
title: Operator best practices - Basic scheduler features in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-scheduler
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
description: Learn the cluster operator best practices for using basic scheduler features such as resource quotas and pod disruption budgets in Azure Kubernetes Service (AKS)
ms.topic: best-practice
ms.custom: aks-scaling
ms.date: 2026-08-06T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 6ae95cd2-8eb9-f73f-b44b-f3854eab3dfe
document_version_independent_id: 109d519d-3c74-eaf7-49c0-a049ed2474b8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/operator-best-practices-scheduler.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/operator-best-practices-scheduler
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/operator-best-practices-scheduler.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/63959238-cb90-4871-a33d-4a5519097e47
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/78d87f42-5582-4a6b-90be-7db2f12b34e6
platformId: 1335e3bf-c9d7-1ea2-a4c5-cbcac863dbcb
---

# Operator best practices - Basic scheduler features in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

As you manage clusters in Azure Kubernetes Service (AKS), you often need to isolate teams and workloads. The Kubernetes scheduler lets you control the distribution of compute resources and limit the impact of maintenance events.

This best practices article focuses on basic Kubernetes scheduling features for cluster operators. In this article, you learn how to:

- Use resource quotas to give teams or workloads a fixed amount of resources
- Limit the impact of scheduled maintenance by using pod disruption budgets

## Enforce resource quotas

> 
> **Best practice guidance**
> 
> Plan and apply resource quotas at the namespace level. Use quotas and limit ranges to require or provide default resource requests and limits for pods. Monitor resource usage and adjust quotas as needed.

Set resource requests and resource limits in the pod specification. A resource request is the amount of CPU or memory that the Kubernetes scheduler uses to place a pod. A resource limit constrains how much of that resource a container can use. The system enforces CPU limits by throttling, while it enforces memory limits reactively through out-of-memory (OOM) termination. For more information, see [Define pod resource requests and limits](developer-best-practices-resource-management#define-pod-resource-requests-and-limits).

Use *resource quotas* to limit aggregate resource consumption for a development team or project. Define quotas at the namespace level for:

- **Compute resources**, such as CPU and memory, or GPUs.
- **Storage resources**, including the total number of volumes or amount of disk space for a given storage class.
- **Object count**, such as the maximum number of secrets, services, or jobs that can be created.

The Kubernetes scheduler uses resource requests to place pods. Containers can use more CPU or memory than requested when capacity is available, and resource limits can exceed requests. A resource quota separately limits aggregate namespace consumption. If creating or updating a resource would exceed a hard quota, the API server rejects the request with an HTTP `403 Forbidden` response. You can still create a workload object such as a Deployment even when the quota prevents its controller from creating all requested pods.

If a resource quota tracks CPU or memory, each new pod must specify a request or limit for that resource. Otherwise, the API server might reject the pod. You can [configure default requests and limits for a namespace](https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/) by using a LimitRange.

The following example YAML manifest named *dev-app-team-quotas.yaml* sets a hard limit of a total of *10* CPUs, *20Gi* of memory, and *10* pods:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-app-team
spec:
  hard:
    cpu: "10"
    memory: 20Gi
    pods: "10"
```

This quota caps aggregate CPU requests at 10 CPUs, aggregate memory requests at 20Gi, and the number of nonterminal pods at 10 in the namespace.

Apply this resource quota to a namespace, such as *dev-apps*:

```bash
kubectl apply -f dev-app-team-quotas.yaml --namespace dev-apps
```

Work with your application developers and owners to understand their needs and apply the appropriate resource quotas.

For more information about available resource objects, scopes, and priorities, see [Resource quotas in Kubernetes](https://kubernetes.io/docs/concepts/policy/resource-quotas/).

## Limit disruption impact by using pod disruption budgets (PDBs)

> 
> **Best practice guidance**
> 
> Define Pod Disruption Budgets (PDBs) for replicated applications to limit concurrent voluntary evictions during events such as AKS node drains. Maintain enough healthy replicas and allow at least one disruption when the workload permits so that cluster maintenance can proceed.

Disruptive events that remove pods fall into two categories:

### Involuntary disruptions

*Involuntary disruptions* are events beyond the typical control of the cluster operator or application owner. Examples include:

- Hardware failure on the physical machine
- Kernel panic
- Deletion of a node VM

You can mitigate involuntary disruptions by:

- Using multiple replicas of your pods in a deployment.
- Running multiple nodes in the AKS cluster.

### Voluntary disruptions

\_ Voluntary disruptions\_ are events that the cluster operator or application owner requests. Examples include:

- Draining a node during a cluster upgrade
- Updating a deployment template
- Directly deleting a pod

Not all voluntary disruptions are constrained by PDBs. Directly deleting a pod or workload object bypasses PDBs, and workload controllers such as Deployments and StatefulSets aren't limited by PDBs during rolling updates. Configure the workload's rollout strategy separately to maintain availability during application updates. For more information, see [Disruptions in Kubernetes](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/).

PDBs limit concurrent voluntary evictions for selected pods through the Kubernetes Eviction API. During an [AKS rolling upgrade](upgrade-conceptual#rolling-upgrade-behavior-in-aks), AKS adds surge capacity according to the node pool settings, cordons and drains a node, and then reimages or replaces the drained node. The Eviction API evaluates the PDB during the drain. After an eviction, the workload controller creates a replacement pod, and the scheduler places it on a node with available capacity. A restrictive PDB, insufficient healthy replicas, or insufficient cluster capacity can delay or block the drain.

### Set a minimum number of available pods

Consider a ReplicaSet with five NGINX pods labeled `app: nginx-frontend`. During a voluntary disruption event, such as a cluster upgrade, at least three pods must remain available. The following `PodDisruptionBudget` manifest defines this requirement:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
spec:
  minAvailable: 3
  unhealthyPodEvictionPolicy: AlwaysAllow
  selector:
    matchLabels:
      app: nginx-frontend
```

This budget requires at least three pods with the label `app: nginx-frontend` to remain healthy during a voluntary eviction.

You can specify a percentage, such as *60%*, so the budget adjusts when the ReplicaSet scales.

### Set a maximum number of unavailable pods

A PDB can define either `minAvailable` or `maxUnavailable`, but not both. To constrain voluntary evictions based on unavailable pods, specify `maxUnavailable` as an integer or a percentage. The following manifest permits a voluntary eviction only when no more than two pods in the ReplicaSet would be unavailable after the eviction:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
spec:
  maxUnavailable: 2
  unhealthyPodEvictionPolicy: AlwaysAllow
  selector:
    matchLabels:
      app: nginx-frontend
```

This budget permits a voluntary eviction only when no more than two pods with the label `app: nginx-frontend` would be unavailable after the eviction. Involuntary disruptions can still cause availability to fall below this threshold.

The `AlwaysAllow` unhealthy pod eviction policy lets a drain evict running pods that aren't healthy. Without this setting, the default `IfHealthyBudget` policy can block a drain while waiting for unhealthy pods to become healthy. Use `AlwaysAllow` when drainability is more important than giving an unhealthy pod more time to recover.

Save the PDB manifest you want to use as *nginx-pdb.yaml*, and then apply it to your AKS cluster:

```bash
kubectl apply -f nginx-pdb.yaml
```

Before cluster maintenance, verify that each PDB permits the expected eviction:

```bash
kubectl get poddisruptionbudgets --namespace <namespace>
```

An `ALLOWED DISRUPTIONS` value of `0` can block an AKS node drain. Work with your application developers and owners to maintain enough healthy replicas and choose a budget that balances application availability with maintenance requirements.

For more information about using pod disruption budgets, see [Specify a disruption budget for your application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/).