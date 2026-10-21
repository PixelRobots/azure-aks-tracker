---
layout: Conceptual
title: Limits for resources, SKUs, and regions in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/quotas-skus-regions
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
description: Learn about default quotas, restricted node VM SKU sizes, and regional availability in Azure Kubernetes Service (AKS).
ms.topic: concept-article
ms.date: 2026-08-03T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 18a59abd-892d-f486-4f19-025d53513c68
document_version_independent_id: aff6c20e-425a-57fe-9db8-5bfe7502df63
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/quotas-skus-regions.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/quotas-skus-regions
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/quotas-skus-regions.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: e37a5bf2-aa5e-7d48-e9ed-c221ad32812e
---

# Limits for resources, SKUs, and regions in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Azure services set default limits and quotas for resources and features, including usage restrictions for certain virtual machine (VM) SKUs.

This article describes the default resource limits for Azure Kubernetes Service (AKS) and the availability of AKS in Azure regions.

## Service quotas and limits

| Resource | Limit |
| --- | --- |
| Maximum number of clusters per subscription globally | 5,000 |
| Maximum nodes per cluster with Virtual Machine Scale Sets and [Standard Load Balancer SKU](/en-us/azure/load-balancer/load-balancer-overview) | 5,000 across all [node pools](/en-us/azure/aks/create-node-pools)Note: If you're unable to scale up to 5,000 nodes per cluster, see [Best Practices for Large Clusters](/en-us/azure/aks/best-practices-performance-scale-large). |
| Maximum nodes per node pool (Virtual Machine Scale Sets node pools) | 1000 |
| Maximum node pools per cluster | 100 |
| Maximum pods per node: with [Kubenet](/en-us/azure/aks/concepts-network-legacy-cni#kubenet) networking plug-in | Maximum: 250  Azure CLI default: 110  Azure Resource Manager template default: 110  Azure portal deployment default: 30 |
| Maximum pods per node: with [Azure Container Networking Interface (Azure CNI)](/en-us/azure/aks/concepts-network-cni-overview)^1^ | Maximum: 250  Maximum recommended for Windows Server containers: 110  Default: 30 |
| Open Service Mesh (OSM) AKS addon | Kubernetes Cluster Version: AKS Supported VersionsOSM controllers per cluster: 1Pods per OSM controller: 1600Kubernetes service accounts managed by OSM: 160 |
| Maximum load-balanced kubernetes services per cluster with [Standard Load Balancer SKU](/en-us/azure/load-balancer/load-balancer-overview) | 300 |
| Maximum nodes per cluster with Virtual Machine Availability Sets and Basic Load Balancer SKU | 100 |

^1^ Windows Server containers must use Azure CNI networking plug-in. Kubenet isn't supported for Windows Server containers.

| Kubernetes Control Plane tier | Limit |
| --- | --- |
| Standard tier | Automatically scales Kubernetes API server based on load. Larger control plane component limits and API server/etcd instances. |
| Free tier | Limited resources with [inflight requests limit](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/). Recommended node limit of 10 nodes per cluster. Best for experimenting, learning, and simple testing. **Not advised for production/critical workloads**. |

Note

In addition to the Free and Standard tiers listed in the preceding table, AKS offers a Premium tier for production workloads that require an uptime SLA and 24-month Long Term Support (LTS). For a complete comparison, see [AKS pricing tiers](free-standard-pricing-tiers).

Important

The Basic Load Balancer limit in the preceding table applies only to legacy configurations. Starting on September 30, 2025, AKS no longer supports Basic Load Balancer. Use Standard Load Balancer for new deployments and [upgrade existing deployments to Standard Load Balancer](upgrade-basic-load-balancer-on-aks).

Important

Starting on **September 30, 2027**, Azure Kubernetes Service (AKS) no longer supports the Open Service Mesh (OSM) add-on. The upstream [Open Service Mesh project](https://www.cncf.io/projects/open-service-mesh/) has been retired.

If your cluster uses the OSM add-on, migrate to the Istio add-on before the end-of-support date. This retirement notice applies only to the managed OSM add-on and doesn't address open-source or self-managed service mesh installations. For migration steps, see [Migration guidance from the OSM add-on to the Istio add-on](open-service-mesh-istio-migration-guidance). To stay informed about AKS announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

### Quota limits on AKS managed clusters

Use the Azure portal Quotas page to [view quota limits and usage](/en-us/azure/quotas/view-quotas) and [request additional quota](/en-us/azure/quotas/quickstart-increase-quota-portal).

The following screenshot shows current usage and limits for AKS managed clusters by region and the controls for requesting quota adjustments.

[!\[Screenshot of the Azure portal Quotas page.\](media/quotas-skus-regions/portal-quotas-page-inline.png)
 Screenshot of the Azure portal Quotas page. The page is filtered to a specific subscription and the Azure Kubernetes Service provider. It shows managed cluster usage and quota limits for each region in the subscription.](media/quotas-skus-regions/portal-quotas-page-expanded.png#lightbox)

If you exceed your managed cluster quota, you might see an error message similar to the following:

```
ManagedClusterCountExceedsQuotaLimit: Operation results in exceeding quota limits for managed clusters. Maximum allowed: %d, Current usage: %d, Additional requested: %d. Consider deleting unused clusters or requesting a quota increase. To request a quota increase, follow the instructions here: https://learn.microsoft.com/azure/quotas/quickstart-increase-quota-portal.
```

To resolve this error, [request additional quota on the Azure portal Quotas page](/en-us/azure/quotas/view-quotas).

#### AKS managed clusters quota limits

| Subscription Type | Default number of AKS clusters per subscription per region for new subscriptions^1^ | Maximum number of AKS clusters per subscription per region via self service using[Azure portal Quotas page](/en-us/azure/quotas/quickstart-increase-quota-portal)^2^ |
| --- | --- | --- |
| Enterprise Agreement subscriptions | 100 | 1,000 |
| CSP, Pay-as-you-go, Sponsored, MSDN, MPN, Azure Pass, Azure In Open, and Azure Pass subscriptions | 10 | 100 |
| Free Trial and Azure for Students subscriptions | 3 | 3 |

^1^ The default number of AKS clusters per subscription per region for new subscriptions may vary in regions with capacity constraints.^2^ To request an increase of the quota limit, [use the Azure portal Quotas request process](/en-us/azure/quotas/quickstart-increase-quota-portal). Quota increase requests above the maximum self service amount will require a support ticket. Free Trial and Azure for Students subscriptions aren't eligible for limit or quota increases. If you have a Free Trial or Azure for Students subscription, you can upgrade to a pay-as-you-go subscription to get higher quota limits.

### Throttling limits on AKS resource provider APIs

AKS uses the [token bucket](https://en.wikipedia.org/wiki/Token_bucket) throttling algorithm to limit certain AKS [resource provider](/en-us/azure/azure-resource-manager/management/resource-providers-and-types) APIs. Throttling helps maintain service performance and promotes fair usage.

The token buckets have a fixed size (also known as a burst rate) and refill over time at a fixed rate (also known as a sustained rate). Each throttling limit applies to the specified resource in each region. For example, a subscription can call `ListManagedClusters` up to 60 times at once for each resource group (burst rate) and then continue to make one call per second (sustained rate).

| API request | Bucket size | Refill rate | Scope |
| --- | --- | --- | --- |
| LIST `ManagedClusters` | 500 requests | 1 request per second | Subscription |
| LIST `ManagedClusters` | 60 requests | 1 request per second | Resource group |
| PUT `AgentPool` | 20 requests | 1 request per minute | Agent pool |
| PUT `ManagedCluster` | 20 requests | 1 request per minute | Managed cluster |
| GET `ManagedCluster` | 60 requests | 1 request per second | Managed cluster |
| GET operation status | 200 requests | 2 requests per second | Subscription |
| All other APIs | 60 requests | 1 request per second | Subscription |

Note

The `ManagedClusters` and `AgentPools` buckets are counted separately for the same AKS cluster.

When AKS throttles a request, it returns HTTP status code `429` (Too Many Requests) and the `Throttled` error code. The response includes a `Retry-After` header that specifies the number of seconds to wait before retrying. If your client uses a bursty API call pattern, configure it to handle the `Retry-After` value. For more information, see the [`Retry-After` header](https://developer.mozilla.org/docs/Web/HTTP/Headers/Retry-After). AKS uses `delay-seconds` to specify the retry interval.

## Provisioned infrastructure

All other network, compute, and storage limitations apply to the provisioned infrastructure. For the relevant limits, see [Azure subscription and service limits](/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits).

Important

When you upgrade an AKS cluster, the upgrade temporarily consumes extra resources. These resources include available IP addresses in a virtual network subnet or virtual machine vCPU quota.

For Windows Server containers, upgrade the node pool to apply the latest node updates. If you don't have enough IP address space or vCPU quota for these temporary resources, the cluster upgrade fails. For more information, see [Upgrade a node pool in AKS](upgrade-node-pools#upgrade-a-single-node-pool).

## Supported VM sizes in AKS

Azure Kubernetes Service (AKS) support for VM sizes changes as Azure releases new VM versions. For updates about supported versions, see the [AKS release notes](https://github.com/Azure/AKS/releases).

## Restricted VM sizes in AKS

Each node in an AKS cluster contains a fixed amount of compute resources, such as vCPU and memory. Because Kubernetes requires specific compute resources to operate correctly, AKS restricts certain VM versions by default. These restrictions help ensure that pods can be scheduled and function correctly on the nodes.

### User node pools

For user node pools, you might not be able to use VM versions with fewer than two vCPUs and 2 GB of memory.

### System node pools

For system node pools, you might not be able to use VM versions with fewer than two vCPUs and 4 GB of memory. To help ensure reliable scheduling for the required *kube-system* pods and your applications, AKS doesn't support [B series VMs](/en-us/azure/virtual-machines/sizes-b-series-burstable) for system node pools and doesn't recommend [Av1 series VMs](/en-us/azure/virtual-machines/sizes/retirement/av1-series-retirement).

For more information on VM types and their compute resources, see [Sizes for virtual machines in Azure](/en-us/azure/virtual-machines/sizes).

## Supported container image sizes in AKS

AKS doesn't set a service-level limit on container image size. Large images can increase pull latency and consume more node disk space, disk I/O, and network bandwidth. If a node doesn't have sufficient disk space, the kubelet might not be able to pull the image. For optimization guidance, see [Improve container image pull performance in AKS](/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/container-image-pull-performance).

Runtime memory use depends on workload behavior rather than image artifact size. Set container memory requests and limits based on measured runtime requirements. For more information, see [Resource management for pods and containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).

## Region availability

AKS availability varies by Azure region. Even in supported regions, regional capacity, VM version availability, and subscription quota can affect deployment.

For the latest list of where you can deploy and run clusters, see [AKS region availability](https://azure.microsoft.com/global-infrastructure/services/?products=kubernetes-service).

## Smart VM defaults in AKS

Before May 2025, the default AKS VM SKU was `Standard_DS2_v2`. For deployments created since May 2025, if you don't specify a VM SKU, AKS dynamically selects a default based on available capacity and quota. This selection improves deployment reliability and resource utilization.

## Cluster configuration presets in the Azure portal

When you create a cluster in the Azure portal, select a preset to quickly configure the cluster for your scenario. You can modify the preset values during cluster creation. The settings that you can modify after deployment vary.

| Preset | Description |
| --- | --- |
| Production Standard | Best for most applications serving production traffic with AKS-recommended best practices. |
| Dev/Test | Best for developing new workloads or testing existing workloads. |
| Production Economy | Best for serving production traffic cost-effectively if your workloads can tolerate interruptions. |
| Production Enterprise | Best for serving production traffic with rigorous permissions and hardened security. |

| Configuration setting | Production Standard | Dev/Test | Production Economy | Production Enterprise |
| --- | --- | --- | --- | --- |
| **System node pool node size** | Standard\_D8ds\_v5 | Standard\_D4ds\_v5 | Standard\_D8ds\_v5 | Standard\_D16ds\_v5 |
| **System node pool autoscaling range** | 2-5 nodes | 2-5 nodes | 2-5 nodes | 2-5 nodes |
| **User node pool node size** | Standard\_D8ds\_v5 | - | Standard\_D8as\_v4 | Standard\_D8ds\_v5 |
| **User node pool autoscaling range** | 2-100 nodes | - | 0-25 nodes | 2-100 nodes |
| **Private cluster** | - | - | - | ![](media/quotas-skus-regions/yes-icon.svg) |
| **Availability zones** | ![](media/quotas-skus-regions/yes-icon.svg) | - | - | ![](media/quotas-skus-regions/yes-icon.svg) |
| **Azure Policy** | ![](media/quotas-skus-regions/yes-icon.svg) | - | - | ![](media/quotas-skus-regions/yes-icon.svg) |
| **Azure Monitor** | ![](media/quotas-skus-regions/yes-icon.svg) | - | - | ![](media/quotas-skus-regions/yes-icon.svg) |
| **Secrets store CSI driver** | ![](media/quotas-skus-regions/yes-icon.svg) | - | - | ![](media/quotas-skus-regions/yes-icon.svg) |
| **Network configuration** | Azure CNI Overlay | Azure CNI Overlay | Azure CNI Overlay | Azure CNI Overlay |
| **Network policy** | None | None | None | None |
| **Authentication and authorization** | Local accounts with Kubernetes role-based access control (RBAC) | Local accounts with Kubernetes RBAC | Microsoft Entra ID authentication with Azure role-based access control (Azure RBAC) | Microsoft Entra ID authentication with Azure RBAC |