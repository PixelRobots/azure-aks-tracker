---
layout: Conceptual
title: Optimize Azure Kubernetes Service (AKS) Usage and Costs - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/optimize-aks-costs
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
description: Learn how to optimize Azure Kubernetes Service (AKS) usage and costs with AKS Automatic as the recommended default for most production workloads.
author: schaffererin
ms.author: schaffererin
ms.custom: aks-cost
ms.topic: how-to
ms.date: 2026-06-24T00:00:00.0000000Z
locale: en-us
document_id: 05e49204-fdfc-831b-a8e3-c43420306fb1
document_version_independent_id: f24b1bed-4a3a-aa1b-7c4e-e13c36057b2b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/optimize-aks-costs.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/optimize-aks-costs
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/optimize-aks-costs.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a3dacbcf-9507-d2bc-e462-27ee5f6478ab
---

# Optimize Azure Kubernetes Service (AKS) Usage and Costs - Azure Kubernetes Service | Microsoft Learn

This article describes practical ways to optimize Azure Kubernetes Service (AKS) usage and costs across scaling, infrastructure sizing, GPU usage, multitenancy, and Azure discounts.

For most production workloads, AKS Automatic is the recommended starting point because it applies production-ready defaults, automates core operations, and helps reduce overprovisioning. AKS Standard remains the right choice when you need deeper platform customization.

This article covers:

- Choose your optimization baseline
- AKS Automatic cost advantages
- Automatic scaling
- Cluster right-sizing
- GPU optimizations
- Multitenancy
- Azure discounts

## Choose your optimization baseline

Start by selecting the AKS cluster mode that matches your cost and operations model.

| Scenario | Recommended cluster mode | Why |
| --- | --- | --- |
| Most production workloads where you want strong cost efficiency with lower operational overhead | AKS Automatic | Preconfigured production-ready defaults, managed operations, and efficient resource allocation help reduce waste and time spent tuning the platform. |
| Workloads requiring extensive custom cluster configuration, specialized add-ons, or strict platform controls | AKS Standard | Full control over cluster configuration and operating model. |
| Teams early in Kubernetes operations maturity and focused on fast, predictable delivery | AKS Automatic | Reduces platform management complexity so teams can focus on applications. |
| Teams with established platform engineering processes and specific architectural standards | AKS Standard | Supports advanced customization and custom operational patterns. |

For more information, see [What is Azure Kubernetes Service (AKS) Automatic?](intro-aks-automatic)

## AKS Automatic cost advantages

AKS Automatic reduces costs in two ways: it minimizes compute waste through automation, and it reduces the operational overhead of running Kubernetes. The following table summarizes the features that have a direct cost impact and how they compare to AKS Standard.

**Preconfigured** features are always enabled and can't be changed. **Default** features are configured for you but can be adjusted. **Optional** features are available to configure and aren't enabled by default.

| Feature | AKS Automatic | AKS Standard | Cost impact |
| --- | --- | --- | --- |
| Node autoprovisioning (NAP) | **Preconfigured** | **Optional** | Provisions right-sized nodes for pending pods automatically, reducing idle and overprovisioned capacity. |
| Horizontal Pod Autoscaler (HPA) | **Preconfigured** | **Optional** | Scales pods to match demand without manual intervention, preventing resource waste at low traffic. |
| Kubernetes Event-driven Autoscaler (KEDA) | **Preconfigured** | **Optional** | Event-driven scaling eliminates idle replicas waiting for work. |
| Vertical Pod Autoscaler (VPA) | **Preconfigured** | **Optional** | Automatically right-sizes pod resource requests and limits based on actual usage over time. |
| Pod bin-packing efficiency | **Preconfigured** | Manual tuning | Pods are bin-packed efficiently to maximize node utilization, reducing the total node count needed. |
| Managed Prometheus + Container Insights | **Default** | **Optional** | Provides immediate cost visibility from day one without requiring observability setup. |
| Automatic cluster and node OS upgrades | **Preconfigured** | Manual or optional | Eliminates upgrade-related engineering overhead and reduces the risk of costly security incidents from unpatched nodes. |
| Automatic node repair | **Preconfigured** | **Preconfigured** | Reduces downtime costs from unhealthy nodes without manual intervention. |
| Fully managed node resource group | **Preconfigured** | Optional lockdown | Prevents accidental or unauthorized resource modifications that can generate unexpected costs. |
| Uptime SLA (99.95% API server) | **Included** | Paid (Standard tier upgrade) | No extra cost to get a financially backed uptime guarantee. |
| Pod readiness SLA (99.9% within 5 min) | **Included** | Not available | Predictable scaling behavior without custom reliability investment. |

Note

Because scaling tools like HPA, KEDA, and VPA are preconfigured in AKS Automatic, teams don't incur the setup, testing, and maintenance cost of configuring these features themselves. In AKS Standard, each of these features requires manual configuration and ongoing tuning.

## Automatic scaling

### Horizontal pod autoscaling

The **Horizontal Pod Autoscaler (HPA)** monitors resource demand and automatically updates a workload resource to scale the number of pods to match demand. The response to increased load is to deploy more pods. If the load decreases and the number of pods is above the configured minimum, the autoscaler tells the workload resource to scale down.

The Metrics API gets data from the kubelet every 60 seconds, and the HPA checks the Metrics API every 15 seconds for any needed changes by default. This means that the HPA updates every 60 seconds. When you configure the HPA for a deployment, you define the minimum and maximum number of replicas that can run and the metrics that the HPA uses to determine when to scale.

Tip

In AKS Automatic, HPA is preconfigured and ready to use without additional setup. In AKS Standard, you configure HPA manually on each workload.

For more information, see [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) and [Autoscale pods in AKS](tutorial-kubernetes-scale#autoscale-pods).

### Kubernetes event-driven autoscaling

The [**Kubernetes Event-driven Autoscaler (KEDA)**](https://keda.sh/) applies event-driven autoscaling to your workloads. KEDA works with the HPA and can extend functionality without overwriting or duplication.

Tip

In AKS Automatic, KEDA is preconfigured and enabled on the cluster. In AKS Standard, you install and configure the KEDA add-on manually.

You can use the KEDA add-on for AKS to scale your applications and leverage a [rich catalog of Azure KEDA scalers](https://keda.sh/docs/2.16/scalers/). For more information, see [Application autoscaling with the KEDA add-on](keda-about) and [Install the KEDA add-on for AKS](keda-deploy-add-on-cli).

### Vertical pod autoscaling

The **Vertical Pod Autoscaler (VPA)** automatically sets resource requests and limits on containers per workload based on past usage. The VPA frees up CPU and Memory for pods to ensure effective utilization of your AKS clusters. Over time, the VPA provides recommendations for resource usage.

Tip

In AKS Automatic, VPA is preconfigured and enabled on the cluster. In AKS Standard, you enable and configure VPA manually.

For more information, see [Vertical pod autoscaling in Azure Kubernetes Service (AKS)](vertical-pod-autoscaler) and [Use the Vertical Pod Autoscaler (VPA) in Azure Kubernetes Service (AKS)](use-vertical-pod-autoscaler).

## Cluster right-sizing

### Right-size your cluster

Right-size your clusters to optimize costs and performance. Manually resize a cluster by adding or removing nodes to meet the needs of your applications. You can also autoscale your cluster to automatically adjust the number of nodes in response to changing demands.

Tip

AKS Automatic enables Managed Prometheus and Container Insights by default, so you get immediate visibility into resource utilization from day one. In AKS Standard, you set up observability separately. Early visibility helps you act on overprovisioning signals before they accumulate into sustained waste.

For more information, see [Resize Azure Kubernetes Service (AKS) clusters](resize-cluster).

### Cluster autoscaling

By using the **cluster autoscaler**, you can automatically scale node pools based on resource usage and constraints. For example, scale up to schedule pending pods or scale down to reduce costs for unused nodes. The [cluster autoscaler profile](cluster-autoscaler-overview#cluster-autoscaler-profile) is a set of parameters that you can fine-tune to control the behavior of the cluster autoscaler.

For more information, see [Cluster autoscaling in Azure Kubernetes Service (AKS) overview](cluster-autoscaler-overview) and [Use the cluster autoscaler in Azure Kubernetes Service (AKS)](cluster-autoscaler).

### Node autoprovisioning

Node autoprovisioning (NAP), based on [Karpenter](https://karpenter.sh/), provisions right-sized infrastructure for pending pods and improves bin-packing efficiency.

- In AKS Automatic, node autoprovisioning is part of the managed experience.
- In AKS Standard, node autoprovisioning is available when you need this capability with a custom cluster model.

For more information, see [Node autoprovisioning in Azure Kubernetes Service (AKS)](node-auto-provisioning).

## GPU optimizations

### GPU partitioning and sharing

GPU partitioning helps combat underutilization by splitting up or sharing GPUs across multiple workloads. The following sections cover different ways to partition and share GPUs in AKS.

#### Time-slicing

The [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/overview.html) enables the **time-slicing** of GPUs in Kubernetes clusters. By using time-slicing, a system administrator can define a set of *replicas* for a GPU, each of which the administrator can hand out independently to a pod to run workloads on. You can apply cluster-wide default time-slicing configurations and node-specific configurations.

![Screenshot of a visual chart example showing GPU time-slicing.](media/optimize-aks-costs/gpu-time-slicing.png)

For more information, see [Time-slicing GPUs in Kubernetes](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html).

#### Multi-Process Service (MPS)

A single process might not use all the memory and compute bandwidth capacity available on a GPU. The **Multi-Process Service (MPS)** enables logical partitioning of memory and compute resources between workloads. It also allows kernel and memcopy operations from different processes to overlap on the GPU. MPS helps you achieve higher GPU utilization and shorter running times.

![Screenshot of a visual chart example showing GPU multi-process service (MPS).](media/optimize-aks-costs/gpu-mps.png)

For more information, see [Multi-Process Service (MPS)](https://docs.nvidia.com/deploy/mps/index.html#mps).

#### Multi-instance GPUs (MIGs)

**Multi-instance GPUs (MIGs)** enable you to partition GPUs based on the NVIDIA Ampere and later architectures into separate and secure GPU instances for CUDA applications.

![Screenshot of a visual chart example showing multi-instance GPUs (MIGs).](media/optimize-aks-costs/gpu-migs.png)

For more information, see [GPU Operator with MIG](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html) and [Create a multi-instance GPU node pool in Azure Kubernetes Service (AKS)](gpu-multi-instance).

## Multitenancy

Multitenancy refers to the sharing of infrastructure across tenants, teams, and business units. The following table outlines different ways to implement multitenancy in AKS:

| Multitenancy type | Multitenancy level | Cluster pod density | Cost allocation | Ideal use case | Potential risks |
| --- | --- | --- | --- | --- | --- |
| **Dedicated cluster** | Hard multitenancy | Lower | Easiest | Complete security isolation boundaries and straightforward cost allocation | • Cluster sprawl at scale adds to management overhead costs  • Lower pod density and more overprovisioned resources |
| **Dedicated node pool** | Soft multitenancy | Medium | Medium | Medium pod density | • Requires trust between tenants  • Requires extra cluster configurations, like network policies, quota management, role-based access control (RBAC), etc. |
| **Dedicated namespace** | Soft multitenancy | Higher | Harder | Sharing infrastructure to maximize resource utilization | • Unsafe for hostile environments by default  • Requires extra cluster configurations, like network policies, quota management, role-based access control (RBAC), etc. |

### Dedicated cluster

With **dedicated cluster multitenancy**, clusters are dedicated to a single workload or team.

![Screenshot of a visual chart example showing dedicated cluster multitenancy.](media/optimize-aks-costs/dedicated-cluster.png)

The following table outlines pros and cons of using a dedicated cluster:

| Pros | Cons |
| --- | --- |
| • Easier isolation method  • Straightforward cost allocation and chargeback  • Great for cases where tenants don't trust each other (often from security and resource sharing perspectives) | • High management and financial overhead  • Generally low pod density and overprovisioned resources |

### Dedicated node pool

With **dedicated node pool multitenancy**, clusters are shared by many tenants.

![Screenshot of a visual chart example showing dedicated node pool multitenancy.](media/optimize-aks-costs/dedicated-node-pool.png)

The following table outlines pros and cons of using a dedicated node pool:

| Pros | Cons |
| --- | --- |
| • Medium pod density  • Some shared infrastructure  • Apply Azure tags to node pools dedicated to a single tenant (tags propagate to nodes and persist through upgrades) | • Requires trust between the tenants  • Requires extra cluster configurations, like network policies, quota management, role-based access control (RBAC), etc. |

### Dedicated namespace

With **dedicated namespace multitenancy**, clusters are shared by many tenants, with namespaces serving as the isolation boundary.

![Screenshot of a visual chart example showing dedicated namespace multitenancy.](media/optimize-aks-costs/dedicated-namespace.png)

The following table outlines pros and cons of using a dedicated namespace:

| Pros | Cons |
| --- | --- |
| • Higher pod density  • Best binpacking  • Sharing infrastructure to maximize resource utilization | • Unsafe for hostile environments by default  • Requires extra security measures in place if all tenants can't be trusted |

## Azure discounts

To take savings one step further, take advantage of Azure discounts such as Azure Savings Plans, Reserved Instances, and Azure Hybrid Benefits.

| Azure discount type | Details |
| --- | --- |
| [**Azure Savings Plans**](/en-us/azure/cost-management-billing/savings-plan/savings-plan-overview) | • 1-3 year upfront commitment  • Save up to 65% compared to pay-as-you-go  • Flexible, with no SKU family or region restrictions  • Best for workloads with consistent costs with resources in various SKUs and regions |
| [**Reserved Instances**](/en-us/azure/cost-management-billing/reservations/save-compute-costs-reservations) | • 1-3 year upfront commitment  • Save up to 72% compared to pay-as-you-go  • Restricted to specific SKU families and regions  • Best for stable workloads running continuously (with no unexpected SKU or region changes) |
| [**Azure Hybrid Benefits**](azure-hybrid-benefit) | • Bring your own on-premises Windows Server and SQL Server licenses to Azure  • Use any qualifying on-premises licenses that have an active Software Assurance (SA) or qualifying subscription |