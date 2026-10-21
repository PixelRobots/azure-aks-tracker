---
layout: Conceptual
title: Azure Kubernetes Application Network Architecture (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-network/architecture
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
learn_banner_products:
- azure
description: Learn about the architecture of Azure Kubernetes Application Network including management plane, control plane, data plane, and multi-cluster service discovery.
author: Kochhars
ms.author: kochhars
ms.service: azure-kubernetes-app-net
ms.topic: concept-article
ms.date: 2026-03-05T00:00:00.0000000Z
locale: en-us
document_id: c7073ca5-1133-e34e-63a1-8d0285c619c9
document_version_independent_id: 60c5ddb5-0cfd-d4eb-2294-36bbcd049c65
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/application-network/architecture.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: application-network/architecture
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-network/architecture.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 61f5e72a-a540-5080-39bf-e95a441bc68e
---

# Azure Kubernetes Application Network Architecture (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Azure Kubernetes Application Network architecture is organized into three layers: a **management plane**, a **control plane**, and a **data plane**. Each layer has distinct responsibilities that together provide a fully managed, Ambient-based service network solution for Azure Kubernetes Service (AKS). This architecture enables secure, policy-driven communication between services without requiring sidecars or changes to your applications.

This article provides an overview of the architectural layers of Azure Kubernetes Application Network, how they interact, and the multi-cluster service discovery model that enables scalable cross-cluster communication. For more information about Azure Kubernetes Application Network, see the [Overview of Azure Kubernetes Application Network for AKS](overview).

## Overview of Application Network architectural layers

The architectural layers manage the following responsibilities:

- **Management plane**: Handles Azure resource operations such as creating, updating, and deleting Application Network resources and managing cluster membership.
- **Control plane**: Manages mesh configuration, certificate lifecycle, and service discovery for each member cluster.
- **Data plane**: Secures service-to-service traffic directly in the member cluster using ambient mode, which requires no sidecars or changes to your applications.

For multi-cluster deployments, Application Network synchronizes service discovery information across member clusters so that services can communicate transparently across cluster boundaries.

The following diagram illustrates the architectural layers of Azure Kubernetes Application Network and how they interact with each other and with your AKS clusters:

[![Screenshot of a diagram illustrating the architectural layers of Azure Kubernetes Application Network and how they interact with each other and with AKS clusters.](media/architecture/application-network-architecture.png)](media/architecture/application-network-architecture.png#lightbox)

## Management plane

The management plane is the Azure resource provider that handles all Application Network resource operations. When you create an Application Network resource or join a member cluster, the management plane validates the request, provisions supporting Azure resources such as Azure Key Vault for certificate storage, and orchestrates the creation of a regional control plane for the member.

You interact with the management plane through the Azure CLI ([`az appnet`](/en-us/cli/azure/appnet)) or the ARM API. The management plane coordinates all downstream provisioning so that control plane and data plane components are deployed without manual intervention.

## Control plane

The control plane is fully managed infrastructure that runs outside your AKS cluster. When a member cluster joins an Application Network, a dedicated control plane is provisioned in the same Azure region as the member cluster, keeping latency between control and data plane components low.

Note

Members in different Azure regions have control planes deployed in their respective regions.

The control plane includes the following components:

- **Istiod**: Connects to the member cluster's Kubernetes API server to discover services and watch for configuration changes. It pushes xDS configuration to ztunnel and waypoint proxies in the data plane. In multi-cluster deployments, Istiod also connects to the Kubernetes API servers of other member clusters to obtain service discovery information, enabling cross-cluster service discovery.
- **Certificate management**: Provisions and rotates CA certificates backed by Azure Key Vault. A root CA establishes a shared trust boundary across all member clusters, and each member receives an intermediate CA that issues short-lived workload certificates. For more information, see the [Overview of Azure Kubernetes Application Network security](security).
- **Lifecycle management**: Deploys and upgrades all data plane components in the member cluster, including ztunnel, Istio CNI, waypoint proxies, and custom resource definitions (CRDs). For more information, see [Configure upgrades for Azure Kubernetes Application Network members](upgrades).

## Data plane

The data plane consists of components deployed into the member cluster's `applink-system` namespace. Application Network uses Istio ambient mode, so there are no sidecars injected into your workloads.

The data plane includes the following components:

- **Ztunnel**: A node-level L4 proxy deployed as a DaemonSet. Ztunnel intercepts service-to-service traffic on the node, establishes mTLS connections transparently, and enforces L4 authorization policies.
- **Waypoint proxies**: Optional per-namespace L7 proxies that provide HTTP routing, traffic shifting, fault injection, and L7 authorization. Waypoint proxies are deployed only when L7 policies are configured for a namespace.
- **East-west gateway**: Handles cross-cluster traffic in multi-cluster deployments. You're responsible for providing network connectivity between east-west gateways in each member cluster. For more information, see Multi-cluster service discovery.
- **Istio CNI**: A DaemonSet that configures pod networking for ambient mesh traffic interception.
- **CRDs**: Kubernetes custom resource definitions for configuring traffic management and security policies.

When a request is made between services, ztunnel intercepts the traffic, establishes an mTLS connection with the destination's ztunnel, and delivers the request to the destination workload. If L7 policies are configured, traffic routes through a waypoint proxy before reaching its destination. For cross-cluster traffic, ztunnel routes through the east-west gateway to reach workloads in remote member clusters.

## Multi-cluster service discovery

Application Network supports connecting multiple AKS clusters into a unified service mesh. Services in one member cluster can communicate with services in other member clusters, with mTLS enforced end-to-end across cluster boundaries.

In open-source Istio multi-cluster deployments, control planes typically connect to the Kubernetes API servers of other clusters to discover services and configuration changes. Application Network follows a similar service discovery model, where control planes obtain service information from member clusters so that services can be discovered across cluster boundaries. This approach enables workloads in one member cluster to resolve and communicate with services running in other clusters without requiring application changes. Adding a new member cluster expands the mesh membership so that services in the new cluster become discoverable by other members.

Cross-cluster traffic flows through east-west gateways deployed in each member cluster. You're responsible for providing network reachability between the east-west gateways of your member clusters — for example, through VNet peering, VPN, or other connectivity solutions. All cross-cluster traffic is encrypted with mTLS.

## How components interact

The control plane connects to the member cluster's Kubernetes API server, watches for service and configuration changes, and pushes xDS updates to ztunnel and waypoint proxies. When multiple members exist, each control plane also exchanges service information through managed messaging so that every member has a consistent view of all services across the mesh.

Certificate management provisions a root CA when the Application Network resource is created and issues intermediate CAs for each member cluster. Workload certificates are issued with a 24-hour validity period and rotated automatically every 12 hours. The entire certificate lifecycle, from root CA through intermediate and workload certificates, is managed without manual intervention.

For the full certificate hierarchy and rotation schedule, see the [Overview of Azure Kubernetes Application Network security](security).