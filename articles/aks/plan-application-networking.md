---
layout: Conceptual
title: Plan Application Networking for Azure Kubernetes Service (AKS) Workloads - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/plan-application-networking
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
description: This article provides an overview of the networking components you need to consider for Azure Kubernetes Service (AKS) applications.
ms.topic: overview
ms.subservice: aks-networking
ms.date: 2025-03-24T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 49784edf-8214-1d02-2676-2bb76d67ad1e
document_version_independent_id: 31c38cc5-084f-be11-6e2f-df13ef7249f9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/plan-application-networking.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/plan-application-networking
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/plan-application-networking.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 4ac6dbec-9af8-ea67-3e82-ceeab374d276
---

# Plan Application Networking for Azure Kubernetes Service (AKS) Workloads - Azure Kubernetes Service | Microsoft Learn

In this article, you learn application networking options for Azure Kubernetes Service (AKS). We first pose a question to help guide your planning, and then provide options, recommendations, and best practices.

## How do you want to access your applications?

Application networking controls how the applications running in your Kubernetes pods are exposed to clients from outside the cluster.

## Application networking options

When setting up application networking, you can choose between a **Load Balancer Service with layer-4 load balancing** or **Ingress controllers with layer-7 load balancing**:

| Application networking option | Features & functionality |
| --- | --- |
| Load Balancer Service | • Uses a Kubernetes `LoadBalancer` Service to directly expose an application on a public or private IP.  • Supports multiple ports and any TCP or UDP traffic.  • Requires *at least one* unique IP:port pair per application. |
| Ingress controllers | • Exposes an application behind a layer-7 reverse proxy.  • Usable only for HTTP-like traffic (HTTP, HTTPS, gRPC).  • Can share a single public IP and ports for all ingress definitions on the same ingress controller.  • Managed ingress options include: Managed ingress-nginx through the [application routing add-on](app-routing), [Azure Application Gateway for Containers (recommended)](/en-us/azure/application-gateway/for-containers/overview), and [Istio ingress gateway](istio-about). |

## Recommendations

For **non-HTTP traffic**, we recommend using **Load Balancer Service with layer-4 load balancing**. This approach provides direct access to your applications and supports a wide range of protocols. For **HTTP-like traffic**, we recommend using **Ingress controllers with layer-7 load balancing**. This approach allows you to take advantage of advanced routing features and share a single public IP for multiple applications.