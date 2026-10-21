---
layout: Conceptual
title: Istio-based service mesh add-on for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-about
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
description: Istio-based service mesh add-on for Azure Kubernetes Service.
ms.topic: concept-article
ms.date: 2023-04-09T00:00:00.0000000Z
ms.author: shasb
author: shashankbarsin
ai-usage: ai-assisted
locale: en-us
document_id: ac5f6e20-de19-b3ba-d08f-367507914900
document_version_independent_id: 52c409b9-51f5-639a-41ff-edc219338ef1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-about.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/istio-about
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-about.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: a8fb3937-b188-bb99-d705-838a4db14241
---

# Istio-based service mesh add-on for Azure Kubernetes Service - Azure Kubernetes Service | Microsoft Learn

[Istio](https://istio.io/latest/) addresses the challenges developers and operators face with a distributed or microservices architecture. The Istio-based service mesh add-on provides an officially supported and tested integration for Azure Kubernetes Service (AKS).

## What is a Service Mesh?

Modern applications are typically architected as distributed collections of microservices, with each collection of microservices performing some discrete business function. A service mesh is a dedicated infrastructure layer that you can add to your applications. It allows you to transparently add capabilities like observability, traffic management, and security, without adding them to your own code. The term **service mesh** describes both the type of software you use to implement this pattern, and the security or network domain that is created when you use that software.

As the deployment of distributed services, such as in a Kubernetes-based system, grows in size and complexity, it can become harder to understand and manage. You may need to implement capabilities such as discovery, load balancing, failure recovery, metrics, and monitoring. A service mesh can also address more complex operational requirements like A/B testing, canary deployments, rate limiting, access control, encryption, and end-to-end authentication.

Service-to-service communication is what makes a distributed application possible. Routing this communication, both within and across application clusters, becomes increasingly complex as the number of services grow. Istio helps reduce this complexity while easing the strain on development teams.

## What is Istio?

Istio is an open-source service mesh that layers transparently onto existing distributed applications. Istio’s powerful features provide a uniform and more efficient way to secure, connect, and monitor services. Istio enables load balancing, service-to-service authentication, and monitoring – with few or no service code changes. Its powerful control plane brings vital features, including:

- Secure service-to-service communication in a cluster with TLS (Transport Layer Security) encryption, strong identity-based authentication, and authorization.
- Automatic load balancing for HTTP, gRPC, WebSocket, and TCP traffic.
- Fine-grained control of traffic behavior with rich routing rules, retries, failovers, and fault injection.
- A pluggable policy layer and configuration API supporting access controls, rate limits, and quotas.
- Automatic metrics, logs, and traces for all traffic within a cluster, including cluster ingress and egress.

## How is the add-on different from open-source Istio?

This service mesh add-on uses and builds on top of open-source Istio. The add-on flavor provides the following extra benefits:

- Istio versions are tested and verified to be compatible with supported versions of Azure Kubernetes Service.
- Microsoft handles scaling and configuration of Istio control plane
- Microsoft adjusts scaling of AKS components like `coredns` when Istio is enabled.
- Microsoft provides managed lifecycle (upgrades) for Istio components when triggered by user.
- Verified external and internal ingress set-up.
- Verified to work with [Azure Monitor managed service for Prometheus](/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview) and [Azure Managed Grafana](/en-us/azure/managed-grafana/overview).
- Official Azure support provided for the add-on.

## Limitations

Istio-based service mesh add-on for AKS has the following limitations:

- The add-on doesn't work on AKS clusters that are using [Open Service Mesh add-on for AKS](open-service-mesh-about).
- The add-on doesn't work on AKS clusters with self-managed installations of Istio.
- The add-on doesn't support adding pods associated with virtual nodes to be added under the mesh.
- The add-on doesn't yet support the sidecar-less Ambient mode. Microsoft is currently contributing to Ambient workstream under Istio open source. Product integration for Ambient mode is on the roadmap and is being continuously evaluated as the Ambient workstream evolves.
- The add-on doesn't yet support multi-cluster deployments.
- The add-on doesn't yet support Windows Server containers. Windows Server containers aren't yet supported in open source Istio right now. Issue tracking this feature ask can be found [here](https://github.com/istio/istio/issues/27893).
- Customization of mesh through the following custom resources is currently blocked - `ProxyConfig, WorkloadEntry, WorkloadGroup, IstioOperator, WasmPlugin`.
- While the add-on allows the use of `EnvoyFilter`'s, issues arising from them (for example from the Lua script or from the compression library) are outside the support scope of the Istio add-on. See the [support policy document](istio-support-policy#allowed-supported-and-blocked-customizations) for more information about the support categories for Istio add-on features and configuration options.
- Gateway API for Istio ingress gateway or managing mesh traffic (GAMMA) is currently not yet supported with Istio add-on. However, Gateway API for Istio ingress traffic management is currently under active development for the add-on. While the add-on supports [annotation and `externalTrafficPolicy` customization for the Istio ingress gateways](istio-deploy-ingress#ingress-gateway-customizations), port or protocol configuration is currently not supported.
- The add-on supports customization of a subset of the fields in [MeshConfig](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/). Other customizations may be allowed but unsupported or disallowed entirely, as detailed [here](istio-meshconfig#allowed-supported-and-blocked-meshconfig-values).
- The add-on doesn't support automatic upgrades. It can be enabled on clusters that are automatically upgraded (such as [AKS Automatic](intro-aks-automatic) clusters), but it isn't upgraded when the cluster auto-upgrades, so an out-of-date mesh revision can eventually block the cluster's automatic upgrade. [Upgrade the add-on](istio-upgrade) to keep it compatible with the cluster's Kubernetes version.

## Feedback and feature ask

Feedback and feature ask for the Istio add-on can be provided by creating [issues with label 'service-mesh' on AKS GitHub repository](https://github.com/Azure/AKS/issues?q=is%3Aopen+is%3Aissue+label%3Aservice-mesh).