---
layout: Conceptual
title: Open Service Mesh in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-about
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
description: Learn about the Open Service Mesh (OSM) add-on in Azure Kubernetes Service (AKS).
ms.topic: concept-article
ms.subservice: aks-networking
ms.date: 2024-09-25T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: be159621-c0bc-cfa9-1bf2-4708b17c5dbc
document_version_independent_id: 43fa0d77-1064-e588-5ef3-5e6f30a6bbda
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/open-service-mesh-about.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/open-service-mesh-about
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/open-service-mesh-about.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: e44d2e83-30d7-a2c9-2f33-9ef4fd6e3717
---

# Open Service Mesh in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

[Open Service Mesh (OSM)](https://docs.openservicemesh.io/) is a lightweight, extensible, cloud native service mesh that allows you to uniformly manage, secure, and get out-of-the-box observability features for highly dynamic microservice environments.

OSM runs an Envoy-based control plane on Kubernetes and can be configured with [SMI](https://smi-spec.io/) APIs. OSM works by injecting an Envoy proxy as a sidecar container with each instance of your application. The Envoy proxy contains and executes rules around access control policies, implements routing configuration, and captures metrics. The control plane continually configures the Envoy proxies to ensure policies and routing rules are up to date and proxies are healthy.

Microsoft started the OSM project, but it's now governed by the [Cloud Native Computing Foundation (CNCF)](https://www.cncf.io/).

Important

Starting on **September 30, 2027**, Azure Kubernetes Service (AKS) no longer supports the Open Service Mesh (OSM) add-on. The upstream [Open Service Mesh project](https://www.cncf.io/projects/open-service-mesh/) has been retired.

If your cluster uses the OSM add-on, migrate to the Istio add-on before the end-of-support date. This retirement notice applies only to the managed OSM add-on and doesn't address open-source or self-managed service mesh installations. For migration steps, see [Migration guidance from the OSM add-on to the Istio add-on](open-service-mesh-istio-migration-guidance). To stay informed about AKS announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Enable the OSM add-on

OSM can be added to your Azure Kubernetes Service (AKS) cluster by enabling the OSM add-on using the [Azure CLI](open-service-mesh-deploy-addon-az-cli) or a [Bicep template](open-service-mesh-deploy-addon-bicep). The OSM add-on provides a fully supported installation of OSM that's integrated with AKS.

Important

Based on the version of Kubernetes your cluster is running, the OSM add-on installs a different version of OSM.

| Kubernetes version | OSM version installed |
| --- | --- |
| 1.24.0 or greater | 1.2.5 |
| Between 1.23.5 and 1.24.0 | 1.1.3 |
| Below 1.23.5 | 1.0.0 |

Older versions of OSM might not be available for install or be actively supported if the corresponding AKS version reached end of life. You can check the [AKS Kubernetes release calendar](supported-kubernetes-versions#aks-kubernetes-release-calendar-and-upcoming-versions) for information on AKS version support windows.

## Capabilities and features

OSM provides the following capabilities and features:

- Secure service-to-service communication by enabling mutual TLS (mTLS).
- Onboard applications onto the OSM mesh using automatic sidecar injection of Envoy proxy.
- Transparently configure traffic shifting on deployments.
- Define and execute fine-grained access control policies for services.
- Monitor and debug services using observability and insights into application metrics.
- Encrypt communications between service endpoints deployed in the cluster.
- Enable traffic authorization of both HTTP/HTTPS and TCP traffic.
- Configure weighted traffic controls between two or more services for A/B testing or canary deployments.
- Collect and view KPIs from application traffic.
- Integrate with external certificate management.
- Integrate with existing ingress solutions such as [NGINX](https://github.com/kubernetes/ingress-nginx), [Contour](https://projectcontour.io/), and [Application Routing](app-routing).

For more information on ingress and OSM, see [Using ingress to manage external access to services within the cluster](https://release-v1-2.docs.openservicemesh.io/docs/guides/traffic_management/ingress/) and [Integrate OSM with Contour for ingress](https://release-v1-2.docs.openservicemesh.io/docs/demos/ingress_contour). For an example of how to integrate OSM with ingress controllers using the `networking.k8s.io/v1` API, see [Ingress with Kubernetes Nginx ingress controller](https://release-v1-2.docs.openservicemesh.io/docs/demos/ingress_k8s_nginx). For more information on using Application Routing, which automatically integrates with OSM, see [Application Routing](app-routing).

## Limitations

The OSM AKS add-on has the following limitations:

- After installation, you must enable Iptables redirection for port IP address and port range exclusion using `kubectl patch`. For more information, see [iptables redirection](https://release-v1-2.docs.openservicemesh.io/docs/guides/traffic_management/iptables_redirection/).
- Any pods that need access to IMDS, Azure DNS, or the Kubernetes API server must have their IP addresses added to the global list of excluded outbound IP ranges using [Global outbound IP range exclusions](https://release-v1-2.docs.openservicemesh.io/docs/guides/traffic_management/iptables_redirection/#global-outbound-ip-range-exclusions).

- The add-on doesn't work on AKS clusters that are using [Istio-based service mesh add-on for AKS](istio-about).

- OSM doesn't support Windows Server containers.