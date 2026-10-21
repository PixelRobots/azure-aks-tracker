---
layout: Conceptual
title: Best Practices for Cost Optimization in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/best-practices-cost
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
description: Learn best practices for cost optimization in AKS, including using AKS Automatic for built-in cost optimization, FinOps practices, autoscaling, and Azure discounts.
ms.topic: best-practice
ms.date: 2026-08-13T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: biannual, aks-cost, aeo-round-2
locale: en-us
document_id: 4c94e991-cabc-d228-9354-43b76b5c72ac
document_version_independent_id: d6d908bd-c69a-5113-b7d8-26efd8131540
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/best-practices-cost.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/best-practices-cost
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/best-practices-cost.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 9cf7b7b9-fc3a-19b0-8606-9f6519da7e69
---

# Best Practices for Cost Optimization in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Cost optimization is about maximizing the value of resources while minimizing unnecessary expenses within your cloud environment. This process involves identifying cost-effective configuration options and implementing best practices to improve operational efficiency. An AKS environment can be optimized to minimize cost while taking into account performance and reliability requirements.

> 
> **Quick Answer: What are the best practices for AKS cost optimization?**
> 
> - Start with AKS Automatic for built-in cost optimization features like node auto-provisioning and workload autoscaling
> - Enable dynamic rightsizing through VPA, HPA, and KEDA to match resources to actual demand
> - Select cost-efficient infrastructure using Spot VMs (up to 90% savings), Arm64 processors, or Reserved Instances (up to 72% savings)
> - Monitor spending with Microsoft Cost Management and migrate to Azure Monitor managed service for Prometheus (managed Prometheus) for lower metrics costs
> - Leverage Azure discounts through Reservations, Azure savings plan for compute, or Hybrid Benefit for long-term workloads
> 

In this article, you learn about:

- Starting with AKS Automatic for built-in cost optimization.
- Holistic monitoring and FinOps practices.
- Strategic infrastructure selection.
- Dynamic rightsizing and autoscaling.
- Leveraging Azure discounts for substantial savings.

## Start with AKS Automatic for built-in cost optimization

[AKS Automatic](intro-aks-automatic) is a cluster mode that preconfigures many of the cost optimization practices described in this article. If you're creating a new cluster, consider AKS Automatic to reduce engineering effort, configuration risk, and the ongoing operational overhead that leads to unnecessary cloud spend.

AKS Automatic provides the following cost optimization capabilities by default, without any extra configuration:

| Capability | Cost benefit |
| --- | --- |
| [Node auto-provisioning (NAP)](node-auto-provisioning) | Automatically selects the most cost-efficient VM SKU for each workload based on actual pod resource requests. Eliminates manual node pool management and overprovisioning. |
| Workload autoscaling (VPA, HPA, and KEDA) | All workload autoscalers are enabled by default, so pods and nodes scale dynamically to actual demand rather than peak assumptions. |
| Efficient bin packing | Pods are scheduled to maximize node utilization, reducing the total number of nodes required to serve your workloads. |
| managed Prometheus | managed Prometheus is the default metrics platform. You avoid the higher cost of Container Insights metrics without any migration effort. |
| [Deployment safeguards](deployment-safeguards) | Azure Policy controls enforce resource requests and limits on all pods in enforcement mode, preventing uncontrolled resource consumption and overprovisioning at the cluster level. |

For workloads that require AKS Standard, the rest of this article describes each of these practices and how to configure them manually. Where AKS Automatic provides a practice by default, a note indicates that no extra steps are needed.

## Embrace FinOps to build a cost saving culture

[Financial operations (FinOps)](https://www.finops.org/introduction/what-is-finops/) is a discipline that combines financial accountability with cloud management and optimization. It focuses on driving alignment between finance, operations, and engineering teams to understand and control cloud costs. The FinOps foundation has several notable projects, such as the [**FinOps Framework**](https://finops.org/framework) and the [**FOCUS Specification**](https://focus.finops.org/).

For more information, see [What is FinOps?](/en-us/azure/cost-management-billing/finops/)

## Select cost-efficient infrastructure and cluster configuration

### Evaluate SKU family

Note

If you use AKS Automatic, [node auto-provisioning (NAP)](node-auto-provisioning) automatically selects the most cost-efficient VM SKU for each workload based on its resource requests. You don't need to manually evaluate, create, or manage node pools.

It's important to evaluate the resource requirements of your application before deployment. Small development workloads have different infrastructure needs than large production-ready workloads. While a combination of CPU, memory, and networking capacity configurations heavily influences the cost effectiveness of a SKU, consider the following virtual machine (VM) types:

| SKU family | Description | Best for |
| --- | --- | --- |
| [**Azure Spot Virtual Machines**](/en-us/azure/virtual-machines/spot-vms) | Azure Spot Virtual Machine Scale Sets back [Spot node pools](spot-node-pool) and are deployed to a single fault domain with no high availability or service-level agreement (SLA) guarantees. Spot VMs let you take advantage of unutilized Azure capacity with significant discounts (up to 90% compared to pay-as-you-go prices). If Azure needs capacity back, the Azure infrastructure evicts the Spot nodes. | Dev/test environments, workloads that can handle interruptions such as batch processing jobs, and workloads with flexible execution time. |
| [**Arm-based processors (Arm64)**](/en-us/azure/virtual-machines/sizes/cobalt-overview) | Arm64 VMs are power-efficient and cost-effective without compromising on performance. With [Arm64 node pool support in AKS](use-arm64-vms), you can create Arm64 Ubuntu agent nodes and mix Intel and Arm architecture nodes within a cluster. These VMs are engineered to efficiently run dynamic, scalable workloads and can deliver up to 50% better price-performance than comparable x86-based VMs for scale-out workloads. | Web or application servers, open-source databases, cloud-native applications, gaming servers, and more. |
| [**GPU optimized SKUs**](/en-us/azure/virtual-machines/sizes) | Depending on the nature of your workload, consider using compute-optimized, memory-optimized, storage-optimized, or GPU-optimized VM SKUs. GPU VM sizes are specialized VMs available with single, multiple, and fractional GPUs. | [GPU-enabled Linux node pools on AKS](gpu-cluster) are best for compute-intensive workloads like graphics rendering, large model training, and inferencing. |

Note

The cost of compute varies across regions. When picking a less expensive region to run workloads, be conscious of the potential impact of latency as well as data transfer costs. To learn more about VM SKUs and their characteristics, see [Sizes for virtual machines in Azure](/en-us/azure/virtual-machines/sizes).

### Review storage options

For more information on storage options and related cost considerations, see the following articles:

- [Best practices for storage and backups in Azure Kubernetes Service (AKS)](operator-best-practices-storage)
- [Storage options for applications in Azure Kubernetes Service (AKS)](concepts-storage)

### Use cluster preset configurations

It can be difficult to pick the right VM SKU, regions, number of nodes, and other configuration options. [Cluster preset configurations](quotas-skus-regions#cluster-configuration-presets-in-the-azure-portal) in the Azure portal offload this initial challenge by providing recommended configurations for different application environments that are cost-conscious and performant. The Dev/Test preset is best for developing new workloads or testing existing workloads. The Production Economy preset is best for serving production traffic in a cost-conscious way if your workloads can tolerate interruptions. Noncritical features are off by default, and you can modify the preset values at any time.

For a more comprehensive approach that goes beyond static presets, consider [AKS Automatic](intro-aks-automatic). AKS Automatic fully manages node pools using [node auto-provisioning (NAP)](node-auto-provisioning), which continuously right-sizes infrastructure to your actual workload demands. It also enables all workload autoscalers by default and enforces resource governance through deployment safeguards, which are extra benefits that cluster presets don't provide.

### Consider multitenancy

AKS offers flexibility in how you run multitenant clusters and isolate resources. For friendly multitenancy, you can share clusters and infrastructure across teams and business units through [*logical isolation*](operator-best-practices-cluster-isolation#logically-isolated-clusters). Kubernetes [Namespaces](concepts-clusters-workloads#namespaces) form the logical isolation boundary for workloads and resources. Sharing infrastructure reduces cluster management overhead while also improving resource utilization and pod density within the cluster. To learn more about multitenancy on AKS and to determine if it's right for your organizational needs, see [AKS considerations for multitenancy](/en-us/azure/architecture/guide/multitenant/service/aks) and [Design clusters for multitenancy](operator-best-practices-cluster-isolation#design-clusters-for-multi-tenancy).

Warning

Kubernetes environments aren't entirely safe for hostile multitenancy. If any tenant on the shared infrastructure can't be trusted, more planning is needed to prevent tenants from impacting the security of other services.

Consider [*physical isolation*](operator-best-practices-cluster-isolation#physically-isolated-clusters) boundaries. In this model, teams or workloads are assigned to their own cluster. Added management and financial overhead is a tradeoff.

## Reduce resource waste through application and cluster configuration

### Make your container as lean as possible

A lean container refers to optimizing the size and resource footprint of the containerized application. Check that your base image is minimal and only contains the necessary dependencies. Remove any unnecessary libraries and packages. A smaller container image accelerates deployment times and increases the efficiency of scaling operations. [Artifact Streaming on AKS](artifact-streaming) lets you stream container images from Azure Container Registry (ACR). It pulls only the necessary layer for initial pod startup, reducing the pull time for larger images from minutes to seconds.

### Enforce resource quotas

Note

[AKS Automatic](intro-aks-automatic) clusters enforce resource requests and limits on all pods automatically through [deployment safeguards](deployment-safeguards), which are enabled in enforcement mode by default. This prevents uncontrolled resource consumption and overprovisioning without requiring manual policy configuration. For AKS Standard clusters, configure resource quotas at the namespace level as described in this section.

[Resource quotas](operator-best-practices-scheduler#enforce-resource-quotas) provide a way to reserve and limit resources across a development team or project. Quotas are defined on a namespace and can be set on compute resources, storage resources, and object counts. When you define resource quotas, individual namespaces are prevented from consuming more resources than allocated. Resource quotas are useful for multitenant clusters where teams are sharing infrastructure.

### Use cluster start/stop

When left unattended, small development and test clusters can accrue unnecessary costs. You can turn off clusters that don't need to run at all times using the [cluster start and stop](start-stop-cluster?tabs=azure-cli) feature. This feature shuts down all system and user node pools so you don't pay for extra compute. The state of your cluster and objects is maintained when you start the cluster again.

### Use capacity reservations

Capacity reservations let you reserve compute capacity in an Azure region or availability zone for any duration of time. Reserved capacity is available for immediate use until the reservation is deleted. [Associating an existing capacity reservation group to a node pool](manage-node-pools#associate-capacity-reservation-groups-to-node-pools) guarantees allocated capacity for your node pool and helps you avoid potential on-demand pricing spikes during periods of high compute demand.

## Monitor your environment and spend

### Increase visibility with Microsoft Cost Management

[Microsoft Cost Management](/en-us/azure/cost-management-billing/cost-management-billing-overview) offers a broad set of capabilities to help with cloud budgeting, forecasting, and visibility for costs both inside and outside of the cluster. Proper visibility is essential for deciphering spending trends, identifying optimization opportunities, and increasing accountability among application developers and platform teams. Enable the [AKS Cost Analysis add-on](cost-analysis) for granular cluster cost breakdown by Kubernetes constructs along with Azure Compute, Network, and Storage categories.

### Azure Monitor

Note

[AKS Automatic](intro-aks-automatic) clusters use managed Prometheus as the default metrics platform. Container Insights metrics aren't enabled by default. If you use AKS Automatic, this cost optimization is already in place and no migration steps are needed.

If you're ingesting metric data via Container insights, we recommend migrating to managed Prometheus, which offers a significant cost reduction. You can [disable Container insights metrics using the data collection rule (DCR)](/en-us/azure/azure-monitor/containers/container-insights-data-collection-dcr?tabs=portal) and deploy the [managed Prometheus add-on](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable#enable-prometheus-and-grafana), which supports configuration via Azure Resource Manager, Azure CLI, Azure portal, and Terraform.

For more information, see [Azure Monitor best practices](/en-us/azure/azure-monitor/best-practices-containers#cost-optimization) and [managing costs for Container insights](/en-us/azure/azure-monitor/containers/container-insights-cost).

### Log Analytics

For control plane logs, consider disabling the categories you don't need and/or using the Basic Logs API when applicable to reduce Log Analytics costs. For more information, see [Azure Kubernetes Service (AKS) control plane/resource logs](monitor-aks#aks-control-plane-resource-logs). For data plane logs, or application logs, consider adjusting the [cost optimization settings](monitor-aks#aks-data-plane-container-insights-logs).

You can also use [Transformations in Azure Monitor](/en-us/azure/azure-monitor/data-collection/data-collection-transformations) to filter or modify control plane and data plane logs before they are sent to a Log Analytics workspace. For more information on how to create a transformation see [Create a transformation in Azure Monitor](/en-us/azure/azure-monitor/data-collection/data-collection-transformations-create?tabs=portal).

### Azure Advisor cost recommendations

AKS cost recommendations in Azure Advisor provide recommendations to help you achieve cost-efficiency without sacrificing reliability. Advisor analyzes your resource configurations and recommends optimization solutions. For more information, see [Get Azure Kubernetes Service (AKS) cost recommendations in Azure Advisor](cost-advisors).

## Optimize workloads through autoscaling

### Establish a baseline

Before configuring your autoscaling settings, you can use [Azure Load Testing](/en-us/azure/load-testing/overview-what-is-azure-load-testing) to establish a baseline for your application. Load testing helps you understand how your application behaves under different traffic conditions and identify performance bottlenecks. Once you have a baseline, you can configure autoscaling settings to ensure your application can handle the expected load.

### Enable application autoscaling

#### Vertical pod autoscaling

Note

[AKS Automatic](intro-aks-automatic) clusters have VPA enabled by default. If you use AKS Standard, see [Use the Vertical Pod Autoscaler in Azure Kubernetes Service (AKS)](vertical-pod-autoscaler) to enable and configure VPA.

Requests and limits that are higher than actual usage can result in overprovisioned workloads and wasted resources. In contrast, requests and limits that are too low can result in throttling and workload issues due to lack of memory. The [Vertical Pod Autoscaler (VPA)](vertical-pod-autoscaler) allows you to fine-tune CPU and memory resources required by your pods. VPA provides recommended values for CPU and memory requests and limits based on historical container usage, which you can set manually or update automatically. **Best for applications with fluctuating resource demands**. VPA’s recommendation-only *off mode* allows teams to review resource suggestions without enforcing them automatically. This mode can be enabled during testing, and VPA recommendations can be used to set the CPU and memory request and limits for production environments.

#### Horizontal pod autoscaling

Note

[AKS Automatic](intro-aks-automatic) clusters have HPA enabled by default. If you use AKS Standard, configure HPA on your workloads as described in [Horizontal pod autoscaling](concepts-scale#horizontal-pod-autoscaler).

The [Horizontal Pod Autoscaler (HPA)](concepts-scale#horizontal-pod-autoscaler) dynamically scales the number of pod replicas based on observed metrics, such as CPU or memory utilization. During periods of high demand, HPA scales out, adding more pod replicas to distribute the workload. During periods of low demand, HPA scales in, reducing the number of replicas to conserve resources. **Best for applications with predictable resource demands**.

Warning

You shouldn't use the VPA with the HPA on the same CPU or memory metrics. This combination can lead to conflicts, as both autoscalers attempt to respond to changes in demand using the same metrics. However, you can use the VPA for CPU or memory with the HPA for custom metrics to prevent overlap and ensure that each autoscaler focuses on distinct aspects of workload scaling.

#### Kubernetes event-driven autoscaling

Note

[AKS Automatic](intro-aks-automatic) clusters have KEDA enabled by default. If you use AKS Standard, see [Install the KEDA add-on using Azure CLI](keda-deploy-add-on-cli) to enable KEDA.

The [Kubernetes Event-driven Autoscaler (KEDA) add-on](keda-about) provides extra flexibility to scale based on various event-driven metrics that align with your application behavior. For example, for a web application, KEDA can monitor incoming HTTP request traffic and adjust the number of pod replicas to ensure the application remains responsive. For processing jobs, KEDA can scale the application based on message queue length. Managed support is provided for all [Azure Scalers](https://keda.sh/docs/2.13/scalers/). KEDA also allows you to scale down to 0 replicas, especially helpful for sporadic event-driven workloads, periodic machine learning (ML) or GPU workloads, and dev/test or low traffic environments.

### Enable infrastructure autoscaling

#### Cluster autoscaling

Note

In [AKS Automatic](intro-aks-automatic), node scaling is handled by node auto-provisioning (NAP), which is preconfigured by default. For AKS Standard without NAP, configure the Cluster Autoscaler as described in this section.

To keep up with application demand, the [Cluster Autoscaler](cluster-autoscaler-overview) watches for pods that can't be scheduled due to resource constraints and scales the number of nodes in the node pool accordingly. When nodes don't have running pods, the Cluster Autoscaler scales down the number of nodes. The Cluster Autoscaler profile settings apply to all autoscaler-enabled node pools in a cluster. For more information, see [Cluster Autoscaler best practices and considerations](cluster-autoscaler-overview#best-practices-and-considerations).

#### Node auto-provisioning

Note

In [AKS Automatic](intro-aks-automatic), node auto-provisioning (NAP) is preconfigured by default. AKS selects the optimal VM SKU for each workload automatically, with no manual node pool creation or SKU selection required. For AKS Standard clusters, follow the steps in [Enable or disable NAP in AKS](use-node-auto-provisioning) to enable NAP.

Complicated workloads might require several node pools with different VM size configurations to accommodate CPU and memory requirements. Accurately selecting and managing several node pool configurations adds complexity and operational overhead. [Node auto-provisioning (NAP)](node-autoprovision?tabs=azure-cli) simplifies the SKU selection process and decides the optimal VM configuration based on pending pod resource requirements to run workloads in the most efficient and cost effective manner.

Note

For more information on scaling best practices, see [Performance and scaling for small to medium workloads in Azure Kubernetes Service (AKS)](best-practices-performance-scale) and [Performance and scaling best practices for large workloads in Azure Kubernetes Service (AKS)](best-practices-performance-scale-large).

## Save with Azure discounts

### Azure Reservations

If your workload is predictable and exists for an extended period of time, consider purchasing an [Azure Reservation](/en-us/azure/cost-management-billing/reservations/save-compute-costs-reservations) to further reduce your resource costs. Azure Reservations operate on a one-year or three-year term, offering up to 72% discount as compared to pay-as-you-go prices for compute. Reservations automatically apply to matching resources. **Best for workloads that are committed to running in the same SKUs and regions over an extended period of time**.

### Azure savings plan for compute

If you have consistent spend, but your use of disparate resources across SKUs and regions makes Azure Reservations infeasible, consider purchasing an [Azure savings plan for compute](/en-us/azure/cost-management-billing/savings-plan/savings-plan-overview). Like Azure Reservations, savings plans operate on a one-year or three-year term and automatically apply to any resources within benefit scope. You commit to spend a fixed hourly amount on compute resources irrespective of SKU or region. **Best for workloads that utilize different resources and/or different data center regions**.

### Azure Hybrid Benefit

[Azure Hybrid Benefit for Azure Kubernetes Service (AKS)](azure-hybrid-benefit) allows you to maximize your on-premises licenses at no extra cost. Use any qualifying on-premises licenses that also have an active Software Assurance (SA) or a qualifying subscription to get Windows VMs on Azure at a reduced cost.