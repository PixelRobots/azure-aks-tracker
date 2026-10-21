---
layout: Conceptual
title: Passive-cold solution overview for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/passive-cold-solution
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
description: Learn about a passive-cold disaster solution overview for Azure Kubernetes Service (AKS).
author: schaffererin
ms.author: schaffererin
ms.custom: aks-reliability
ms.topic: concept-article
ms.date: 2024-01-30T00:00:00.0000000Z
locale: en-us
document_id: c1adadcf-56c7-8c78-d2f4-fedab5afa700
document_version_independent_id: 5e8cf04f-bbf9-0052-3430-b791042c02fe
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/passive-cold-solution.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/passive-cold-solution
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/passive-cold-solution.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: a04e438d-b477-6f46-8636-eda987c155da
---

# Passive-cold solution overview for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

When you create an application in Azure Kubernetes Service (AKS) and choose an Azure region during resource creation, it's a single-region app. When the region becomes unavailable during a disaster, your application also becomes unavailable. If you create an identical deployment in a secondary Azure region, your application becomes less susceptible to a single-region disaster, which guarantees business continuity, and any data replication across the regions lets you recover your last application state.

This guide outlines a passive-cold solution for AKS. Within this solution, we deploy two independent and identical AKS clusters into two paired Azure regions with only one cluster actively serving traffic when the application is needed.

Note

The following practice has been reviewed internally and vetted in conjunction with our Microsoft partners.

## Passive-cold solution overview

In this approach, we have two independent AKS clusters being deployed in two Azure regions. When the application is needed, we activate the passive cluster to receive traffic. If the passive cluster goes down, we must manually activate the cold cluster to take over the flow of traffic. We can set this condition through a manual input every time or to specify a certain event.

## Scenarios and configurations

This solution is best implemented as a “use as needed” workload, which is useful for scenarios that require workloads to run at specific times of day or run on demand. Example use cases for a passive-cold approach include:

- A manufacturing company that needs to run a complex and resource-intensive simulation on a large dataset. In this case, the passive cluster is located in a cloud region that offers high-performance computing and storage services. The passive cluster is only used when the simulation is triggered by the user or by a schedule. If the cluster doesn’t work upon triggering, the cold cluster can be used as a backup and the workload can run on it instead.
- A government agency that needs to maintain a backup of its critical systems and data in case of a cyber attack or natural disaster. In this case, the passive cluster is located in a secure and isolated location that’s not accessible to the public.

## Components

The passive-cold disaster recovery solution uses many Azure services. This example architecture involves the following components:

**Multiple clusters and regions**: You deploy multiple AKS clusters, each in a separate Azure region. When the app is needed, the passive cluster is activated to receive network traffic.

**Key Vault**: You provision an [Azure Key Vault](/en-us/azure/key-vault/general/overview) in each region to store secrets and keys.

**Log Analytics**: Regional [Log Analytics](/en-us/azure/azure-monitor/logs/log-analytics-overview) instances store regional networking metrics and diagnostic logs. A shared instance stores metrics and diagnostic logs for all AKS instances.

**Hub-spoke pair**: A hub-spoke pair is deployed for each regional AKS instance. [Azure Firewall Manager](/en-us/azure/firewall-manager/overview) policies manage the firewall rules across each region.

**Container Registry**: The container images for the workload are stored in a managed container registry. With this solution, a single [Azure Container Registry](/en-us/azure/container-registry/container-registry-intro) instance is used for all Kubernetes instances in the cluster. Geo-replication for Azure Container Registry enables you to replicate images to the selected Azure regions and provides continued access to images even if a region experiences an outage.

## Failover process

If the passive cluster isn't functioning properly because of an issue in its specific Azure region, you can activate the cold cluster and redirect all traffic to that cluster's region. You can use this process while the passive cluster is deactivated until it starts working again. The cold cluster can take a couple minutes to come online, as it has been turned off and needs to complete the setup process. This approach isn't ideal for time-sensitive applications. In that case, we recommend considering an [active-active failover](active-active-solution#failover-process).

### Application Pods (Regional)

A Kubernetes deployment object creates multiple replicas of a pod (*ReplicaSet*). If one is unavailable, traffic is routed between the remaining replicas. The Kubernetes *ReplicaSet* attempts to keep the specified number of replicas up and running. If one instance goes down, a new instance should be recreated. [Liveness probes](/en-us/azure/container-instances/container-instances-liveness-probe) can check the state of the application or process running in the pod. If the pod is unresponsive, the liveness probe removes the pod, which forces the *ReplicaSet* to create a new instance.

For more information, see [Kubernetes ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/).

### Application Pods (Global)

When an entire region becomes unavailable, the pods in the cluster are no longer available to serve requests. In this case, the Azure Front Door instance routes all traffic to the remaining health regions. The Kubernetes clusters and pods in these regions continue to serve requests. To compensate for increased traffic and requests to the remaining cluster, keep in mind the following guidance:

- Make sure network and compute resources are right sized to absorb any sudden increase in traffic due to region failover. For example, when using Azure Container Network Interface (CNI), make sure you have a subnet that can support all pod IPs with a spiked traffic load.
- Use the [Horizontal Pod Autoscaler](concepts-scale#horizontal-pod-autoscaler) to increase the pod replica count to compensate for the increased regional demand.
- Use the AKS [Cluster Autoscaler](cluster-autoscaler) to increase the Kubernetes instance node counts to compensate for the increased regional demand.

### Kubernetes node pools (Regional)

Occasionally, localized failure can occur to compute resources, such as power becoming unavailable in a single rack of Azure servers. To protect your AKS nodes from becoming a single point regional failure, use [Azure Availability Zones](availability-zones). Availability zones ensure that AKS nodes in each availability zone are physically separated from those defined in another availability zones.

### Kubernetes node pools (Global)

In a complete regional failure, Azure Front Door routes traffic to the remaining healthy regions. Again, make sure to compensate for increased traffic and requests to the remaining cluster.

## Failover testing strategy

While no mechanisms currently exist within AKS to take down an entire region of deployment for testing purposes, you can use [Azure Chaos Studio Workspaces](/en-us/azure/chaos-studio/chaos-studio-aks-guidance) to simulate an availability zone outage for your cluster's node pools.