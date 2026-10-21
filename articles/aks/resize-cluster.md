---
layout: Conceptual
title: Resize Azure Kubernetes Service (AKS) clusters - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/resize-cluster
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
description: In this article, you learn about the importance of right-sizing your AKS clusters and how you can right-size them to optimize costs and performance.
ms.topic: how-to
ms.date: 2024-06-13T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: devx-track-azurecli, aks, scaling, cluster-management, aks-scaling
locale: en-us
document_id: 9dafb0c0-d490-e2a9-0533-6b9dbd6030bc
document_version_independent_id: b6f43d2a-b2ff-a389-383a-a15f2ab84db0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/resize-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/resize-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/resize-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ad2cb83a-2050-c12c-7505-60ab812263ec
---

# Resize Azure Kubernetes Service (AKS) clusters - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to resize an Azure Kubernetes Service (AKS) cluster. It's important to right-size your clusters to optimize costs and performance. You can manually resize a cluster by adding or removing the nodes to meet the needs of your applications. You can also autoscale your cluster to automatically adjust the number of nodes in response to changing demands.

## Cluster right-sizing

When you create an AKS cluster, you specify the number of nodes and the size of the nodes, which determines the compute capacity of the cluster. Oversized clusters can lead to unnecessary costs, while undersized clusters can lead to performance issues. You can adjust the number and size of the nodes in the cluster to right-size the cluster to meet the needs of your applications.

Consider the following factors when right-sizing your cluster:

- **Resource requirements**: Understand the resource requirements of your applications to determine the number of nodes and the size of the nodes needed to run your workloads.
- **Performance requirements**: Determine the performance requirements of your applications to ensure that the cluster can meet the demands of your workloads.
- **Cost considerations**: Optimize costs by right-sizing your cluster to avoid unnecessary costs associated with oversized clusters.
- **Application demands**: Monitor the demands of your applications to adjust the size of the cluster in response to changing demands.
- **Infrastructure constraints**: Consider the infrastructure constraints of your environment, such as capacity or reserved instance limiting to specific SKUs, to ensure that the cluster can be right-sized within the limits of your environment.

## Monitor cluster performance and cost

Closely monitor the performance and cost of your clusters to ensure they're right-sized to meet the needs of your application and make adjustments as needed. You can use the following resources for monitoring:

- [Identify high CPU usage in Azure Kubernetes Service (AKS) clusters](/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/identify-high-cpu-consuming-containers-aks)
- [Troubleshoot memory saturation in Azure Kubernetes Service (AKS) clusters](/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/identify-memory-saturation-aks)
- [Cost analysis add-on for Azure Kubernetes Service (AKS)](cost-analysis)
- [Configure the Metrics Server Vertical Pod Autoscaler (VPA) in Azure Kubernetes Service (AKS)](use-metrics-server-vertical-pod-autoscaler)

## When to resize a cluster

You might want to resize a cluster in scenarios such as the following:

- If you see that CPU and memory usage is consistently low, consider *downsizing* the cluster. If usage is consistently high, make sure you have autoscaling enabled and increase the maximum node count if necessary.
- The [cost analysis add-on for AKS](cost-analysis) shows you details about node usage and cost that indicate you might benefit from cluster resizing. For example, if you see that your nodes have a *high idle cost* with a *low usage cost*, you might consider resizing your cluster to reduce costs.
- The [Metrics Server VPA](use-metrics-server-vertical-pod-autoscaler) shows you that your requests and/or limits are too high or low based on historical usage. You can use this information to adjust your cluster size to better match your workload.
- You experience performance issues such as resource starvation. This might be a result of the cluster being undersized for the demands of your applications.

## What happens when I resize a cluster?

### Increasing cluster size

You can increase the size of an AKS cluster by adding nodes to the cluster. You can [add nodes to the cluster manually](scale-cluster) or configure autoscaling to automatically adjust the number of nodes in response to changing demands.

When you increase the size of a cluster, the following changes occur:

- New node instances are created using the same configuration as the existing nodes in the cluster.
- New pods might be scheduled on the new nodes to distribute the workload across the cluster.
- Existing pods don't move to the new nodes unless they are rescheduled due to node failures or other reasons.

### Decreasing cluster size

You can decrease the size of an AKS cluster by removing nodes from the cluster. When you remove nodes from the cluster, the nodes are automatically drained and removed from the cluster. You can remove nodes from the cluster manually or configure autoscaling to automatically adjust the number of nodes in response to changing demands.

When you decrease the size of a cluster, the following changes occur:

- AKS gracefully terminates the nodes and drains the pods running on the nodes before removing the nodes from the cluster.
- Any pods managed by a replication controller are rescheduled on other node instances in the cluster.
- Any pods that aren't managed by a replication controller aren't restarted.

## Manually resize an AKS cluster

# [Azure CLI](#tab/azure-cli)
- Resize an AKS cluster using the [`az aks scale`](/en-us/cli/azure/aks#az-aks-scale) command with the `--node-count` and `--nodepool-name` parameters.

Before running the resize command, set the required environment variables with your own values. The example values should be substituted with your actual resource group, cluster, desired node count, and node pool name.

```azurecli
az aks scale --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-count $NUM_NODES --nodepool-name $NODE_POOL_NAME
```

Results:

```output
{
  "agentPoolProfiles": [
    {
      "count": 4,
      "maxCount": null,
      "minCount": null,
      "name": "nodepool1",
      ...
    }
  ],
  "dnsPrefix": "xxxxx",
  "fqdn": "xxxxx.xxxxx.xxxxxx.cloudapp.azure.com",
  ...
}
```

Repeat this command for each node pool in the cluster that you want to resize. If your cluster has only one node pool, you can omit the `--nodepool-name` parameter.

# [Azure portal](#tab/azure-portal)
1. In the Azure portal, go to the AKS cluster that you want to resize.
2. Under **Settings**, select **Node pools**.
3. Select the node pool that you want to resize &gt; **Scale node pool**.
4. On the **Scale node pool** page, enter the new **Node count** value.
5. Select **Apply** and repeat the steps for each node pool in the cluster that you want to resize.

---

## Automatically resize an AKS cluster

Use the [cluster autoscaler](cluster-autoscaler-overview) to automatically resize your node pools in response to changing demands.

For more information, see the [Cluster autoscaling in Azure Kubernetes Service (AKS) overview](cluster-autoscaler-overview). To configure cluster autoscaling in AKS, see [Use the cluster autoscaler in Azure Kubernetes Service (AKS)](cluster-autoscaler).