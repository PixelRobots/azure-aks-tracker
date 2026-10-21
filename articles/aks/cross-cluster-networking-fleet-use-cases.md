---
layout: Conceptual
title: Cross-cluster networking use cases with Azure Kubernetes Fleet Manager - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/cross-cluster-networking-fleet-use-cases
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
description: Learn about cross-cluster networking use cases for Azure Kubernetes Fleet Manager (Fleet), including high availability, shared services, and multi-cluster observability across AKS clusters.
author: Khushbu-Parekh
ms.author: kparekh
ms.subservice: aks-networking
ms.topic: concept-article
ms.date: 2026-04-26T00:00:00.0000000Z
locale: en-us
document_id: 0fe74456-3a7b-0bd5-0ca7-4c9d4bbe9b01
document_version_independent_id: 9015f230-ef8d-67a9-50f8-a32a6e415e76
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/cross-cluster-networking-fleet-use-cases.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/cross-cluster-networking-fleet-use-cases
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/cross-cluster-networking-fleet-use-cases.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: cba828c1-8205-75eb-598d-bf90f0d2224b
---

# Cross-cluster networking use cases with Azure Kubernetes Fleet Manager - Azure Kubernetes Service | Microsoft Learn

Cross-cluster networking for Azure Kubernetes Fleet Manager (Fleet) is a managed offering built on [Cilium Cluster Mesh](https://cilium.io/use-cases/cluster-mesh/) that allows you to establish direct pod-to-pod communication across multiple Azure Kubernetes Service (AKS) clusters. By creating a cross-cluster network, you can enable seamless east-west connectivity without the need for gateways, while also gaining multi-cluster observability and consistent security enforcement.

## Architecture and capabilities

In a cross-cluster networking setup, a flat virtual network allows pods in different clusters to route traffic directly across cluster boundaries. Each cluster is typically assigned two subnets: one for nodes and one for pods. This consistent architecture ensures that the pod network remains flat across the cross-cluster network, without the use of overlays or tunnels.

![Diagram showing architecture of Azure Kubernetes Fleet Manager managing cross-cluster east-west connectivity. Pods in different clusters communicate directly via Cilium Agents across peered virtual networks.](media/cross-cluster-networking-fleet/east-west-connectivity.png)

Key components and capabilities for this scenario include:

- **Azure CNI with Cilium data plane**: Both AKS clusters must use Azure CNI with the Azure CNI powered by Cilium data plane.
- **Advanced Container Networking Services (ACNS)**: ACNS must be enabled on the clusters to support this scenario.
- **Azure Kubernetes Fleet Manager**: Fleet manages the lifecycle and configuration of the cross-cluster network through resources like the `ClusterMesh` profile.
- **Native performance**: Pod IP routing happens across clusters at native performance via direct-routing, circumventing the need for any gateways or proxies.
- **Unified Network Policy Enforcement**: Extends Cilium's Layer 3-7 network policy enforcement to all clusters in the cross-cluster network, ensuring a consistent security approach.
- **Multi-cluster observability**: Provides end-to-end visibility into traffic flows across clusters. This visibility helps you monitor application health, troubleshoot connectivity issues, and analyze traffic patterns across the cross-cluster network.

## Use cases

Cross-cluster networking enables several key multi-cluster scenarios. The following sections describe the most common use cases for cross-cluster networking with Fleet.

### Use case: Transparent service discovery and load balancing

When you use standard Kubernetes services and mark them as global, Cilium automatically discovers endpoints for those services across all clusters in the cross-cluster network. Any traffic destined for a global service's `ClusterIP` is automatically load-balanced across all contributing clusters, simplifying cross-cluster communication.

Applications can discover and interact with services regardless of the cluster they reside in, without requiring application-level changes or external service registries.

### Use case: High availability and fault tolerance

High availability is the most common use case for cross-cluster networking. This use case includes operating Kubernetes clusters across multiple regions or availability zones and running replicas of the same services in each cluster. Upon failure, requests can fail over to other clusters in the cross-cluster network.

The failure scenario covered in this use case isn't primarily the complete unavailability of an entire region or failure domain. A more likely scenario is the temporary unavailability of resources or misconfiguration in one cluster, leading to the inability to run or scale particular services in that cluster. With cross-cluster networking, traffic destined for the affected service is automatically routed to healthy endpoints in other clusters, keeping your application available.

![Diagram showing two AKS clusters across regions. Frontends in each cluster route to a local orders service backed by orders pods. When pods in cluster B become unhealthy, the orders service in cluster B fails over to the orders service in cluster A.](media/cross-cluster-networking-fleet/high-availability-failover.png)

### Use case: Shared services

While the initial trend of Kubernetes-based platforms was to build large, multitenant clusters, it's becoming increasingly common to build individual clusters per tenant or to build clusters for different categories of services, such as different levels of security sensitivity.

However, some services such as secrets management, logging, monitoring, or DNS are often still shared between all clusters. Centralizing these services in a shared "service" cluster avoids the operational overhead of maintaining them in each tenant cluster.

The primary motivation of this model is isolation between tenant clusters. To maintain that goal, tenant clusters are connected only to the shared services cluster and aren't connected to other tenant clusters.

![Diagram showing two tenant AKS clusters with applications calling a secrets client. Both tenant clusters route to a shared services cluster that hosts the secrets service backed by vault-1 and vault-2 pods. Tenant clusters connect only to the shared services cluster, not to each other.](media/cross-cluster-networking-fleet/shared-services.png)

### Use case: Stateful and stateless separation

You can isolate the operational complexity of stateful services, such as databases and storage, in dedicated clusters. This separation keeps stateless application clusters agile and easy to migrate. It also improves security, simplifies cluster lifecycle management, and lets you scale stateless workloads independently from stateful ones.

![Diagram showing two stateless AKS clusters, each with ingress routing to a frontend and datastore client. Both stateless clusters connect to a dedicated stateful cluster hosting the datastore service backed by data-1, data-2, and data-n pods.](media/cross-cluster-networking-fleet/stateful-stateless-service.png)

### Use case: Multi-cluster security and policy enforcement

Cross-cluster networking extends Cilium's Layer 3-7 network policy enforcement across all clusters in the cross-cluster network. This unified enforcement ensures a consistent security posture and simplifies policy management by avoiding the need to manually replicate policies in every environment. Policies applied on one cluster are honored across the other clusters, providing unified, identity-aware security across your fleet.

### Use case: Multi-cluster observability

Cross-cluster networking provides end-to-end visibility into traffic flowing between services across clusters. By aggregating flow data from every cluster in the cross-cluster network, you can visualize east-west traffic, monitor application health across regions, troubleshoot cross-cluster connectivity issues, and analyze traffic patterns for capacity planning.

With [container network logs](container-network-observability-logs), operators get a unified view of pod-to-pod communication regardless of which cluster the source or destination resides in, without instrumenting applications.

## Global services

To enable traffic flow between clusters, you must configure your Kubernetes services as global services. In a cross-cluster network, a global service is a standard Kubernetes service that is shared across multiple clusters. When you mark a service as global, Cilium automatically discovers endpoints for that service in all clusters within the cross-cluster network and performs load balancing across them.

Once a service is marked as global, any policies applied on one cluster are honored across the other clusters in the cross-cluster network, providing a consistent security posture. This configuration allows for:

- **Transparent Service Discovery**: Applications can discover and interact with services regardless of the cluster they reside in.
- **High Availability**: If a service in one cluster becomes unavailable, traffic is automatically shifted to a healthy instance in another cluster.

Cilium manages this discovery by watching for services with the `io.cilium/global-service: "true"` annotation. For these services, all endpoints with the same name and namespace across clusters are merged into a single global service. Any traffic destined for that service's `ClusterIP` is then load-balanced across all contributing clusters.

## Limitations

- A member cluster can participate in only one cross-cluster network at a time.
- A single cross-cluster network supports up to 255 member clusters.
- Self-managed Cilium multi-cluster configurations aren't supported alongside Fleet-managed cross-cluster networking.
- Cilium CLI commands that modify the mesh, such as `cilium clustermesh connect` or `cilium upgrade`, are unsupported because Fleet manages these operations.
- Cross-cluster networking is restricted to clusters within the same reachable flat routing domain. It doesn't support mesh connectivity across nonpeered virtual networks.