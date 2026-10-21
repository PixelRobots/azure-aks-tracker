---
layout: Conceptual
title: Concepts - Services in Azure Kubernetes Services (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-network-services
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
description: Learn about networking services in Azure Kubernetes Service (AKS), including what Kubernetes Services are and what types of services are available in AKS.
ms.topic: concept-article
ms.date: 2024-04-08T00:00:00.0000000Z
ms.subservice: aks-networking
ms.custom: fasttrack-edit
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 412f6d82-c337-960e-21cf-9259cd08a040
document_version_independent_id: 80e6dc23-573c-af25-12ed-933e154d6983
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-network-services.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-network-services
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-network-services.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a54ff448-f332-145b-cc56-55d747327136
---

# Concepts - Services in Azure Kubernetes Services (AKS) - Azure Kubernetes Service | Microsoft Learn

You can use Kubernetes Services to logically group pods and provide network connectivity by allowing direct access to them through a specific IP address or DNS name on a designated port. This allows you to expose your application workloads to other services within the cluster or to external clients without having to manually manage the network configuration for each pod hosting a workload.

You can specify what kind of service you want using Kubernetes *Service `type` values*. For more information, see the [Kubernetes Service documentation](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types).

The following Service types are available in AKS: `ClusterIP`, `NodePort`, `LoadBalancer`, and `ExternalName`.

## ClusterIP

`ClusterIP` creates an internal IP address for use within the AKS cluster. The `ClusterIP` Service is good for *internal-only applications* that support other workloads within the cluster. ClusterIP is used by default if you don't explicitly specify a type for a Service.

![Screenshot of a diagram showing ClusterIP traffic flow in an AKS cluster.](media/concepts-network/aks-cluster-ip.png)

## NodePort

`NodePort` creates a port mapping on the underlying node that allows the application to be accessed directly with the node IP address and port.

![Screenshot of a diagram showing NodePort traffic flow in an AKS cluster.](media/concepts-network/aks-node-port.png)

## LoadBalancer

`LoadBalancer` creates an Azure load balancer resource, configures an external IP address, and connects the requested pods to the load balancer backend pool. To allow customer traffic to reach the application, load balancing rules are created on the desired ports.

![Screenshot of a diagram showing Load Balancer traffic flow in an AKS cluster.](media/concepts-network/aks-load-balancer.png)

For HTTP load balancing of inbound traffic, you can also use an [Ingress controller](concepts-network-ingress#ingress-controllers).

You can also use the `LoadBalancer` type to create multiple public load balancers in a single AKS cluster. This is useful for large clusters or port-heavy workloads that can quickly exhaust the limits of a single load balancer. For more information, see [Use multiple public load balancers in Azure Kubernetes Service (preview)](use-multiple-standard-load-balancer).

## ExternalName

`ExternalName` creates a specific DNS entry for easier application access. You can dynamically assign the load balancers and service IP address, or you can specify an existing static IP address. You can assign both internal and external static IP addresses. Existing static IP addresses are often tied to a DNS entry.

You can create both *internal* and *external* load balancers. Internal load balancers are only assigned a private IP address, so they can't be accessed from the Internet.