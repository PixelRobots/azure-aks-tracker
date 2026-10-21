---
layout: Conceptual
title: About service meshes - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/servicemesh-about
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
description: Obtain an overview of service meshes, supported scenarios, selection criteria, and next steps to explore.
author: phillipgibson
ms.topic: concept-article
ms.subservice: aks-networking
ms.date: 2023-04-18T00:00:00.0000000Z
ms.author: schaffererin
locale: en-us
document_id: 0656773d-d265-9555-f195-c2bd8562986f
document_version_independent_id: d75497bd-86ef-09f2-595d-7d79c9f4d345
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/servicemesh-about.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/servicemesh-about
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/servicemesh-about.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/1ae5c491-970a-4062-8301-6336e69f9026
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/f2c3e52e-3667-4e8a-bf11-20b9eaccdc8c
platformId: 315cb7f0-97b4-fad5-e0f6-a2795f8cb0a1
---

# About service meshes - Azure Kubernetes Service | Microsoft Learn

A service mesh is an infrastructure layer in your application that facilitates communication between services. Service meshes provide capabilities like traffic management, resiliency, policy, security, strong identity, and observability to your workloads. Your application is decoupled from these operational capabilities, while the service mesh moves them out of the application layer and down to the infrastructure layer.

## Scenarios

When you use a service mesh, you can enable scenarios such as:

- **Encrypting all traffic in cluster**: Enable mutual TLS between specified services in the cluster. This can be extended to ingress and egress at the network perimeter and provides a secure-by-default option with no changes needed for application code and infrastructure.
- **Canary and phased rollouts**: Specify conditions for a subset of traffic to be routed to a set of new services in the cluster. On successful test of canary release, remove conditional routing and phase gradually increasing % of all traffic to a new service. Eventually, all traffic will be directed to the new service.
- **Traffic management and manipulation**: Create a policy on a service that rate limits all traffic to a version of a service from a specific origin, or a policy that applies a retry strategy to classes of failures between specified services. Mirror live traffic to new versions of services during a migration or to debug issues. Inject faults between services in a test environment to test resiliency.
- **Observability**: Gain insight into how your services are connected and the traffic that flows between them. Gather metrics, logs, and traces for all traffic in the cluster, including ingress/egress. Add distributed tracing abilities to applications.

## Selection criteria

Before you select a service mesh, make sure you understand your requirements and reasoning for installing a service mesh. Ask the following questions:

- **Is an ingress controller sufficient for my needs?**: Sometimes having a capability like A/B testing or traffic splitting at the ingress is sufficient to support the required scenario. Don't add complexity to your environment with no upside.
- **Can my workloads and environment tolerate the additional overheads?**: All the components required to support the service mesh require resources like CPU and memory. All the proxies and their associated policy checks add latency to your traffic. If you have workloads that are very sensitive to latency or can't provide extra resources to cover service mesh components, you should reconsider using a service mesh.
- **Is this adding unnecessary complexity?**: If you want to install a service mesh to use a capability that isn't critical to the business or operational teams, then consider whether the added complexity of installation, maintenance, and configuration is worth it.
- **Can this be adopted in an incremental approach?**: Some of the service meshes that provide a lot of capabilities can be adopted in a more incremental approach. Install just the components you need to ensure your success. If you later find that more capabilities are required, explore them at a later time. Resist the urge to install *everything* from the start.