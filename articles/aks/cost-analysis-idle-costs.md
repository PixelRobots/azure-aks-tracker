---
layout: Conceptual
title: Monitor Azure Kubernetes Service (AKS) idle costs - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/cost-analysis-idle-costs
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
description: Learn how to monitor and optimize idle costs in the Azure Kubernetes Service (AKS) cost analysis add-on.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-monitoring
ms.topic: how-to
ms.date: 2025-01-30T00:00:00.0000000Z
locale: en-us
document_id: e0dc0d43-d962-f842-f340-0c68d6f9c567
document_version_independent_id: 97e1c8e1-6cc3-0b48-64dd-660f7b9c3978
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/cost-analysis-idle-costs.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/cost-analysis-idle-costs
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/cost-analysis-idle-costs.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 71799f90-23e1-6b2a-f05b-4eb27047851f
---

# Monitor Azure Kubernetes Service (AKS) idle costs - Azure Kubernetes Service | Microsoft Learn

If you have the [Azure Kubernetes Service (AKS) cost analysis add-on enabled](cost-analysis#enable-cost-analysis-on-your-aks-cluster) and see high idle costs, then you have an opportunity to optimize your cluster and improve cost efficiency. This article explains what idle costs are, how to monitor them, and how to reduce them.

## What are idle costs?

*Idle costs* are due to idle resources, which come from overprovisioning, low utilization, and resource wastage scenarios. Customers often overprovision resources for various reasons, including:

- Concern about performance issues in the event of running out of memory resources.
- Unpredictable workloads, such as a batch workload that requires a lot of resources at once and then drops for a period of time before spiking again.
- Wanting to ensure that resources are available for buffer or unexpected periods of high resource demand.

If more nodes are provisioned than needed, or if resource requests are much greater than what's actually used, it can lead to idle costs.

## Monitor cluster metrics and cost data

To understand where your cluster idle costs come from, you can monitor the following metrics in [Azure Monitor](/en-us/azure/azure-monitor/essentials/monitor-azure-resource), [Managed Prometheus](/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview#azure-monitor-managed-service-for-prometheus), or [self-hosted Prometheus](/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview#azure-hosted-self-managed-prometheus):

- **Total memory request on the cluster** indicates the total amount of memory requested by all pods in the cluster and ensures the cluster has enough memory to meet the workload demands.
- **Total CPU request on the cluster** indicates total CPU requested by all pods in the cluster and ensures the cluster can handle the computational needs of the workloads.
- **Max memory usage** indicates the peak memory usage in the cluster and helps identify any memory spikes that could lead to performance issues or resource constraints. This is important for preventing OOMkill or pod crashes.
- **Max CPU usage** indicates the peak CPU usage observed in the cluster, helps detect CPU-intensive workloads, and ensures the cluster can handle peak loads or spikes in workload demand.
- **Average memory usage** is useful for identifying trends and determining if the cluster is overprovisioned or underutilized. If usage is consistently below the total memory capacity, it means the cluster has more memory resources than needed.
- **Average CPU usage** is useful for understanding the overall CPU demand. If usage is consistently below the total CPU capacity and CPU request, it means the cluster has more CPU resources than needed.
- **Node count** indicates the number of nodes in the cluster and helps identify if there's an excess number of nodes with low utilization.

To improve utilization, it's important to monitor these metrics and adjust your cluster size and resources accordingly.

## Optimize your cluster size and resources

| Recommended action | Description |
| --- | --- |
| [Manual resizing](resize-cluster) | Adjust the number of nodes in your cluster based on resource requirements. |
| [Enable the cluster autoscaler](cluster-autoscaler) | Automatically adjust the number of nodes in your cluster based on the resource requests of your pods. This helps ensure you only pay for the resources you need. |
| Use an [alternative VM SKU type](best-practices-cost#evaluate-sku-family) | Use a compute-optimized or memory-optimized SKU based on underutilized CPU and memory resources. |
| Consider using [Spot VMs](/en-us/azure/virtual-machines/spot-vms) | For noncritical workloads, Spot VMs can be a cost-effective option. |
| [Enable node autoprovisioning](node-autoprovision) | Automatically provision the optimal VM configuration to run the workload in the most efficient and cost effective way. |
| [Enable the Vertical Pod Autoscaler (VPA)](use-vertical-pod-autoscaler) | Automatically adjust the resource requests and limits of your pods based on their actual usage. This helps ensure that your pods are using the right amount of resources and can help reduce idle costs. |

Note

If a node is ready but has no pods running and is pending cluster autoscaler scale down, most of the node cost will be considered idle. A small amount will be considered system cost.