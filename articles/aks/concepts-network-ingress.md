---
layout: Conceptual
title: Concepts - Ingress Networking in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-network-ingress
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
description: Learn about ingress networking in Azure Kubernetes Service (AKS), including ingress controllers, and how AKS Automatic provides the recommended production-ready default for most workloads.
ms.topic: concept-article
ms.date: 2026-06-05T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ai-usage: ai-assisted
locale: en-us
document_id: 426bef11-d4f1-d15e-0533-37fa4d861eed
document_version_independent_id: 44ffe972-aa48-8ee8-6e30-1a90f0965179
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-network-ingress.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-network-ingress
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-network-ingress.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 9eaf78d5-0a9e-0cd2-974c-dd75fd95bbc8
---

# Concepts - Ingress Networking in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Caution

The [Kubernetes SIG Network](https://github.com/kubernetes/community/blob/master/sig-network/README.md) and the Security Response Committee [announced the retirement](https://www.kubernetes.dev/blog/2025/11/12/ingress-nginx-retirement/) of the [Ingress NGINX project](https://github.com/kubernetes/ingress-nginx/), with maintenance that ended in March 2026. Microsoft will provide official support for critical security patches for application routing add-on NGINX Ingress resources through **November 2026**.

AKS aligns with upstream Kubernetes and uses **[Gateway API](https://gateway-api.sigs.k8s.io) as the long-term standard for ingress and L7 traffic management**. Migrate before support ends in November 2026, based on your requirements:

- **Application routing add-on users** and **OSS NGINX users**: Migrate to the [application routing Gateway API implementation](/en-us/azure/aks/app-routing-gateway-api) for a Gateway API-based ingress traffic management experience, or to [Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/overview), which supports both Ingress API and Gateway API.
- **Service mesh or advanced ingress requirements**: Consider [Gateway API ingress with the Istio service mesh add-on](/en-us/azure/aks/istio-gateway-api). You can use it for ingress without injecting sidecars into your workloads. If you need request header and body size limits, Lua scripts, or rate limiting, review the [Gateway API limitations and alternatives](/en-us/azure/aks/app-routing-gateway-api#limitations).

Ingress in AKS is a Kubernetes resource that manages external HTTP-like traffic access to [services](concepts-network-services) within a cluster. An AKS ingress may provide services like load balancing, SSL termination, and name-based virtual hosting. For more information about Kubernetes Ingress, see the [Kubernetes Ingress documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/).

For most production workloads, start with **AKS Automatic**. AKS Automatic is the recommended production-ready default in AKS and provides managed defaults for networking, scaling, security, monitoring, and upgrades. For ingress, that means you can start with the managed ingress path and only move to more specialized options when you need deeper control over topology, routing behavior, or service mesh integration.

Use AKS Standard when you need more explicit control over ingress controller selection, deployment topology, or advanced networking integration.

## AKS cluster modes and ingress

AKS supports two cluster modes:

- **AKS Automatic**: Recommended starting point for most production workloads. It reduces operational overhead and gives you managed defaults for ingress and related networking components.
- **AKS Standard**: Best when you need explicit control over ingress controller hosting, service exposure, and advanced traffic management patterns.

The ingress guidance in this article applies to both modes. The main difference is who owns more of the platform defaults and how much customization you need to manage directly.

## Ingress controllers

When managing application traffic, Ingress controllers provide advanced capabilities by operating at layer 7. They can route HTTP traffic to different applications based on the inbound URL, allowing for more intelligent and flexible traffic distribution rules. For example, an ingress controller can direct traffic to different microservices depending on the URL path, enhancing the efficiency and organization of your services.

On the other hand, a LoadBalancer-type Service, when created, sets up an underlying Azure load balancer resource. This load balancer works at layer 4, distributing traffic to the pods in your Service on a specified port. However, layer 4 services are unaware of the actual applications and can't implement these types of complex routing rules.

Understanding the distinction between these two approaches helps in selecting the right tool for your traffic management needs.

If you're using AKS Automatic, start with the managed ingress path first and use more specialized options only when your workload requires them. In AKS Standard, you have more flexibility to choose the ingress controller and topology that best matches your architecture.

![Diagram showing Ingress traffic flow in an AKS cluster](media/concepts-network/aks-ingress.png)

## Compare ingress options

### Feature comparison

The following table lists the feature differences between the different ingress controller options. For most production AKS workloads, the recommended default path is the managed ingress approach in AKS Automatic unless you specifically need custom routing, service mesh integration, or Azure-hosted ingress.

| Feature | Application Routing add-on | Application Gateway for Containers | Azure Service Mesh / Istio service mesh |
| --- | --- | --- | --- |
| **Ingress/Gateway controller** | NGINX ingress controller | Azure Application Gateway for Containers | Istio Ingress Gateway |
| **API** | Ingress API | Ingress API and Gateway API | [Istio Ingress API](https://istio.io/latest/docs/reference/config/networking/gateway/) |
| **Hosting** | In-cluster | Azure hosted | In-cluster |
| **Scaling** | Autoscaling | Autoscaling | Autoscaling |
| **Load balancing** | Internal/External | External | Internal/External |
| **SSL termination** | In-cluster | Yes: Offloading and E2E SSL | In-cluster |
| **mTLS** | N/A | Yes: frontend and backend | Yes |
| **Static IP address** | Yes | FQDN (no static IP) | N/A |
| **Azure Key Vault stored SSL certificates** | Yes | Yes | N/A |
| **Azure DNS integration for DNS zone management** | Yes | Yes | N/A |

### When to use each ingress controller

The following table lists the different scenarios where you might use each ingress controller:

| Ingress option | When to use |
| --- | --- |
| **Managed NGINX - Application Routing add-on** | • In-cluster hosted, customizable, and scalable NGINX ingress controllers.  • Basic load balancing and routing capabilities.  • Internal and external load balancer configuration.  • Static IP address configuration.  • Integration with Azure Key Vault for certificate management.  • Integration with Azure DNS Zones for public and private DNS management.  • Supports the Ingress API. |
| **Application Gateway for Containers** | • Azure hosted ingress gateway.  • Flexible deployment strategies managed by the controller or bring your own Application Gateway for Containers.  • Advanced traffic management features such as automatic retries, availability zone resiliency, mutual authentication (mTLS) to backend target, traffic splitting / weighted round robin, and autoscaling.  • Integration with Azure Key Vault for certificate management.  • Integration with Azure DNS Zones for public and private DNS management.  • Supports the Ingress and Gateway APIs. |
| **Istio Ingress Gateway** | • Based on Envoy, when using with Istio for a service mesh.  • Advanced traffic management features such as rate limiting and circuit breaking.  • Support for mTLS. |

Note

The Istio add-on currently doesn't support Gateway API for [Istio ingress traffic](istio-deploy-ingress).

## Create an Ingress resource

The Application Routing add-on is the recommended way to configure an ingress controller in AKS, and it's the managed ingress path to start with in AKS Automatic for most workloads. The application routing add-on is a fully managed ingress controller for AKS that provides the following features:

- Easy configuration of managed NGINX ingress controllers based on Kubernetes NGINX Ingress controller.
- Integration with Azure DNS for public and private zone management.
- SSL termination with certificates stored in Azure Key Vault.

For most production workloads, this is the right default to begin with. If you need custom ingress topology, Azure-hosted ingress, or service mesh behavior, you can move to one of the other ingress options.

For more information about the Application Routing add-on, see [Managed NGINX ingress with the Application Routing add-on](app-routing).

## Client source IP preservation

Configure your ingress controller to preserve the client source IP on requests to containers in your AKS cluster. When your ingress controller routes a client's request to a container in your AKS cluster, the original source IP of that request is unavailable to the target container. When you enable *client source IP preservation*, the source IP for the client is available in the request header under *X-Forwarded-For*.

If you're using client source IP preservation on your ingress controller, you can't use TLS pass-through. Client source IP preservation and TLS pass-through can be used with other services, such as the *LoadBalancer* type.

This remains an important design choice in both AKS Automatic and AKS Standard, because source IP handling affects observability, auditability, and application behavior regardless of the cluster mode.

To learn more about client source IP preservation, see [How client source IP preservation works for LoadBalancer Services in AKS](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/how-client-source-ip-preservation-works-for-loadbalancer/ba-p/3033722#:%7E:text=Enable%20Client%20source%20IP%20preservation%201%20Edit%20loadbalancer,is%20the%20same%20as%20the%20source%20IP%20%28srjumpbox%29.).