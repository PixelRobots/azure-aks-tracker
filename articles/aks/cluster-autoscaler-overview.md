---
layout: Conceptual
title: Cluster autoscaling in Azure Kubernetes Service (AKS) overview - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler-overview
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
description: Learn how the cluster autoscaler works in Azure Kubernetes Service (AKS) and best practices for configuring it to automatically adjust resources to meet application demands while optimizing performance and cost.
ms.topic: concept-article
ms.custom: aks-scaling
ms.date: 2026-09-04T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 9887d0c8-6150-10cf-fa21-205b3e0f7c58
document_version_independent_id: d72c23ae-9769-3264-895f-243840ef4b0e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/cluster-autoscaler-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/cluster-autoscaler-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/cluster-autoscaler-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a5006bdb-cca1-a896-e441-3bef0d28f86c
---

# Cluster autoscaling in Azure Kubernetes Service (AKS) overview - Azure Kubernetes Service | Microsoft Learn

To keep up with application demands in Azure Kubernetes Service (AKS), you might need to adjust the number of nodes that run your workloads. The cluster autoscaler component watches for pods in your cluster that can't be scheduled because of resource constraints. When the cluster autoscaler detects unscheduled pods, it scales up the number of nodes in the node pool to meet the application demand. It also checks for underutilized nodes and scales down eligible nodes when their workloads can be safely rescheduled.

This article helps you understand how the cluster autoscaler works in AKS. It also provides guidance, best practices, and considerations when configuring the cluster autoscaler for your AKS workloads. If you want to enable, disable, or update the cluster autoscaler for your AKS workloads, see [Use the cluster autoscaler in AKS](cluster-autoscaler).

## About the cluster autoscaler

Clusters often need a way to scale automatically to adjust to changing application demands, such as between workdays and evenings or weekends. AKS clusters can scale in the following ways:

- The **cluster autoscaler** periodically checks for pods that can't be scheduled on nodes because of resource constraints. The cluster then automatically increases the number of nodes. Manual scaling is disabled when you use the cluster autoscaler. For more information, see [How does scale up work?](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-does-scale-up-work)
- The **[Horizontal Pod Autoscaler](concepts-scale#horizontal-pod-autoscaler)** uses the Metrics Server in a Kubernetes cluster to monitor the resource demand of pods. If an application needs more resources, the number of pods is automatically increased to meet the demand.
- The **[Vertical Pod Autoscaler](vertical-pod-autoscaler)** automatically sets resource requests and limits on containers per workload based on past usage to ensure pods are scheduled onto nodes that have the required CPU and memory resources.

![Screenshot of how the cluster autoscaler and horizontal pod autoscaler often work together to support the required application demands.](media/cluster-autoscaler/cluster-autoscaler.png)

It's a common practice to enable cluster autoscaler for nodes and either the Vertical Pod Autoscaler or Horizontal Pod Autoscaler for pods. When you enable the cluster autoscaler, it applies the specified scaling rules when the node pool size is lower than the minimum node count, up to the maximum node count. The cluster autoscaler waits to take effect until a new node is needed in the node pool or until a node might be safely deleted from the current node pool. For more information, see [How does scale down work?](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-does-scale-down-work)

## Best practices and considerations

- When you implement **availability zones with the cluster autoscaler**, use a single node pool for each zone. Set the `--balance-similar-node-groups` parameter to `True` to keep a balanced distribution of nodes across zones for your workloads during scale-up operations. If you don't use this approach, scale-down operations can disrupt the balance of nodes across zones. For multizonal node pools, you can also let AKS pick zones dynamically by using [automatic zone placement (`--zones auto`)](configure-automatic-zone-placement), which places nodes in zones that have capacity while applying a maximum instance percentage of 50% per zone. You can use automatic zone placement when you create a node pool or update an existing node pool.

    Note

    The Cluster Autoscaler isn't zone-aware, and the underlying Virtual Machine Scale Sets handle zone allocation. The preceding best practice becomes even more relevant when you use zone-based [pod topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) on a single multizonal node pool, as restrictive constraints might leave pods in a pending state, especially in capacity-constrained regions or during zone-down scenarios.
- For **clusters with more than 400 nodes**, use Azure CNI or Azure CNI Overlay.
- To **effectively run workloads concurrently on both Spot and on-demand node pools**, consider using [*priority expanders*](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders). A priority expander uses the priorities and node-pool name patterns in the `cluster-autoscaler-priority-expander` ConfigMap to select a node pool during scale-up. The following configuration illustrates this setup.

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: cluster-autoscaler-priority-expander
      namespace: kube-system
    data:
      priorities: |-
        10:
          - .*spotpool1.*
          - .*spotpool2.*
        50:
          - .*ondemandpool1.*
    ```
- Exercise caution when **assigning CPU and memory requests on pods**. The cluster autoscaler scales up based on pending pods rather than CPU or memory pressure on nodes.
- For **clusters concurrently hosting both long-running workloads, like web apps, and short or bursty job workloads**, separate them into distinct node pools with [Affinity Rules](operator-best-practices-advanced-scheduler#what-is-node-affinity) or [expanders](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders).
- Use [PodDisruptionBudget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) to help prevent unnecessary node drain or scale-down operations. Specifying the annotation [cluster-autoscaler.kubernetes.io/safe-to-evict: "false"](https://kubernetes.io/docs/reference/labels-annotations-taints/#cluster-autoscaler-kubernetes-io-safe-to-evict) on the Pod spec also prevents the pods from being evicted. Use this annotation with caution, as it might cause the Cluster Autoscaler to encounter issues when draining a node with a running Pod that includes this annotation.
- In an autoscaler-enabled node pool, don't manually change the current node count. To change the allowed scaling range, [update the cluster autoscaler minimum and maximum node counts](cluster-autoscaler#update-the-cluster-autoscaler-settings) after assessing your workload and capacity requirements.
- Nodes don't scale up if pods have a PriorityClass value below -10. Priority -10 is reserved for [overprovisioning pods](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-can-i-configure-overprovisioning-with-cluster-autoscaler). For more information, see [Using the cluster autoscaler with Pod Priority and Preemption](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-does-cluster-autoscaler-work-with-pod-priority-and-preemption).
- **Don't combine other node autoscaling mechanisms**, such as Virtual Machine Scale Set autoscalers, with the cluster autoscaler.
- The cluster autoscaler **might be unable to scale down if pods can't move, such as in the following situations**:

    - A directly created pod not backed by a controller object, such as a Deployment or ReplicaSet.
    - A pod disruption budget (PDB) that's too restrictive and doesn't allow the number of pods to fall below a certain threshold.
    - A pod uses node selectors or anti-affinity that can't be honored if scheduled on a different node. For more information, see [What types of pods can prevent the cluster autoscaler from removing a node?](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-types-of-pods-can-prevent-ca-from-removing-a-node).

Important

**Don't make changes to individual nodes within the autoscaled node pools**. All nodes in the same node group should have uniform capacity, labels, taints and system pods running on them.

- The cluster autoscaler isn't responsible for enforcing a "maximum node count" in a cluster node pool irrespective of pod scheduling considerations. If any non-cluster autoscaler actor sets the node pool count to a number beyond the cluster autoscaler's configured maximum, the cluster autoscaler doesn't automatically remove nodes. The cluster autoscaler scale down behaviors remain scoped to removing underutilized nodes. The sole purpose of the cluster autoscaler's max node count configuration is to enforce an upper limit for scale-up operations. It doesn't have any effect on scale-down considerations.

## Cluster autoscaler profile

The [cluster autoscaler profile](cluster-autoscaler#cluster-autoscaler-profile-settings) is a set of parameters that control the behavior of the cluster autoscaler. You can configure the cluster autoscaler profile when you create a cluster or update an existing cluster.

### Optimizing the cluster autoscaler profile

You should fine-tune the cluster autoscaler profile settings according to your specific workload scenarios while also considering tradeoffs between performance and cost. This section provides examples that demonstrate those tradeoffs.

It's important to note that the cluster autoscaler profile settings are cluster-wide and applied to all autoscale-enabled node pools. Any scaling actions that take place in one node pool can affect the autoscaling behavior of other node pools, which can lead to unexpected results. Make sure you apply consistent and synchronized profile configurations across all relevant node pools to ensure you get your desired results.

#### Example 1: Optimizing for performance

For clusters that handle substantial and bursty workloads with a primary focus on performance, use a short `scan-interval` so the cluster autoscaler reevaluates the cluster frequently. Increasing this interval reduces reevaluation frequency and related API activity but increases the time before the cluster autoscaler reacts. Decrease `scale-down-utilization-threshold` to reduce scale-down eligibility for underutilized nodes. Also, increase `ok-total-unready-count` and `max-total-unready-percentage`.

For clusters with DaemonSet pods, set `ignore-daemonsets-utilization` to `true` so DaemonSet pod requests aren't included when the cluster autoscaler calculates node utilization for scale down. This setting can make nodes more likely to fall below `scale-down-utilization-threshold` and become eligible for scale down. See [Configure the cluster autoscaler profile for bursty workloads](cluster-autoscaler#configure-cluster-autoscaler-profile-for-bursty-workloads).

#### Example 2: Optimizing for cost

If you want a [cost-optimized profile](cluster-autoscaler#configure-cluster-autoscaler-profile-for-aggressive-scale-down), we recommend setting the following parameter configurations:

- Reduce `scale-down-unneeded-time`, which is the amount of time a node should be unneeded before it's eligible for scale down.
- Reduce `scale-down-delay-after-add`, which is the amount of time to wait after a node is added before considering it for scale down.
- Increase `scale-down-utilization-threshold`, which is the utilization threshold for removing nodes.
- Increase `max-empty-bulk-delete`, which is the maximum number of nodes that can be deleted in a single call.
- Set `skip-nodes-with-local-storage` to false.
- Increase `ok-total-unready-count` and `max-total-unready-percentage`.

## Common issues and mitigation recommendations

View scaling failures and scale-up not triggered events via [CLI or Portal](cluster-autoscaler#retrieve-cluster-autoscaler-logs-and-status).

### Not triggering scale up operations

| Common causes | Mitigation recommendations |
| --- | --- |
| PersistentVolume node affinity conflicts, which can arise when using the cluster autoscaler with multiple availability zones or when a pod's or persistent volume's zone differs from the node's zone. | Use one node pool per availability zone and enable `--balance-similar-node-groups`. You can also set the [`volumeBindingMode` field to `WaitForFirstConsumer`](azure-disk-csi#create-a-custom-storage-class) in the pod specification to prevent the volume from being bound to a node until a pod using the volume is created. |
| Taints and Tolerations/Node affinity conflicts | Assess the taints assigned to your nodes and review the tolerations defined in your pods. If necessary, make adjustments to the [taints and tolerations](operator-best-practices-advanced-scheduler#what-are-taints-and-tolerations) to ensure that your pods can be efficiently scheduled on your nodes. |
| [Restrictive Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) | Cluster Autoscaler runs scheduling simulations before initiating scale-up operations. If it determines that a pod cannot be scheduled on a new node due to restrictive topology spread constraints, it will not attempt to scale up. To mitigate this, consider relaxing the topology spread constraints. |

### Scale up operation failures

| Common causes | Mitigation recommendations |
| --- | --- |
| IP address exhaustion in the subnet | Add another subnet in the same virtual network and add another node pool into the new subnet. |
| Core quota exhaustion | Approved core quota has been exhausted. [Request a quota increase](/en-us/azure/quotas/quickstart-increase-quota-portal). The cluster autoscaler enters an exponential backoff state within the specific node group when it experiences multiple failed scale up attempts. |
| Max size of node pool | Increase the max nodes on the node pool or create a new node pool. |
| Requests/Calls exceeding the rate limit | See [429 Too Many Requests errors](/en-us/troubleshoot/azure/azure-kubernetes/429-too-many-requests-errors). |

### Scale down operation failures

| Common causes | Mitigation recommendations |
| --- | --- |
| Pod preventing node drain/Unable to evict pod | • View [what types of pods can prevent scale down](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-types-of-pods-can-prevent-ca-from-removing-a-node).  • For pods using local storage, such as hostPath and emptyDir, set the cluster autoscaler profile flag `skip-nodes-with-local-storage` to `false`.  • In the pod specification, set the `cluster-autoscaler.kubernetes.io/safe-to-evict` annotation to `true`.  • Check your [PDB](https://kubernetes.io/docs/tasks/run-application/configure-pdb/), as it might be restrictive. |
| Min size of node pool | Reduce the minimum size of the node pool. |
| Requests/Calls exceeding the rate limit | See [429 Too Many Requests errors](/en-us/troubleshoot/azure/azure-kubernetes/429-too-many-requests-errors). |
| Write operations locked | Don't make any changes to the [fully managed AKS resource group](cluster-configuration#fully-managed-resource-group-preview) (see [AKS support policies](support-policies)). Remove or reset any [resource locks](/en-us/azure/azure-resource-manager/management/lock-resources) you previously applied to the resource group. |

### Other issues

| Common causes | Mitigation recommendations |
| --- | --- |
| PriorityConfigMapNotMatchedGroup | Ensure every node group that requires autoscaling matches at least one node-pool name pattern in the `priorities` data of the `cluster-autoscaler-priority-expander` ConfigMap. For general expander behavior, see [What are Expanders?](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders) |

### Node pool in backoff

Node pool in backoff was introduced in version 0.6.2 and causes the cluster autoscaler to back off from scaling a node pool after a failure.

Depending on how long the scaling operations have been experiencing failures, the autoscaler might wait up to 30 minutes before making another attempt. You can reset the node pool's backoff state by disabling and then re-enabling autoscaling.