---
layout: Conceptual
title: Comparing AKS with Other Azure Container Options - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/compare-container-options-with-aks
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
description: Understand when to use Azure Kubernetes Service (AKS) and how it compares to other container options including Azure Container Instances, Azure App Service, Azure Functions, and Azure Container Apps.
author: schaffererin
ms.author: schaffererin
ms.topic: overview
ms.date: 2025-07-18T00:00:00.0000000Z
ms.custom: aks-getting-started
locale: en-us
document_id: da966fcd-1c14-5b37-baaa-9b27652980a6
document_version_independent_id: 64978e4c-23cd-338e-4743-2a311bb6b33b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/compare-container-options-with-aks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/compare-container-options-with-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/compare-container-options-with-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/32e8f006-5597-4144-9ccc-778e20833eca
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/bfbda2e5-bc4e-4e83-8c2a-41b7c4914a07
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d71449bf-21c2-6fc1-412f-29f4b2a9032d
---

# Comparing AKS with Other Azure Container Options - Azure Kubernetes Service | Microsoft Learn

There are many options for teams to build and deploy cloud native and containerized applications on Azure. This article compares several container options on Azure.

There's no perfect solution for every use case and every team. The following explanation provides general guidance and recommendations as a starting point to help find the best fit for your team and your requirements.

## Container option comparisons

### Azure Container Apps

[Azure Container Apps](/en-us/azure/container-apps/overview) enables you to build serverless microservices and jobs based on containers. Distinctive features of Container Apps include:

- Optimized to run general purpose containers, especially for applications that span many microservices deployed in containers.
- Powered by Kubernetes and open-source technologies like [Dapr](https://dapr.io/), [KEDA](https://keda.sh/), and [envoy](https://www.envoyproxy.io/).
- Supports Kubernetes-style apps and microservices with features like [service discovery](/en-us/azure/container-apps/connect-apps) and [traffic splitting](/en-us/azure/container-apps/revisions).
- Enables event-driven application architectures by supporting scale based on traffic and pulling from [event sources like queues](/en-us/azure/container-apps/scale-app), including [scale to zero](/en-us/azure/container-apps/scale-app).
- Supports running on demand, scheduled, and event-driven [jobs](/en-us/azure/container-apps/jobs).
- Enables running [Azure Functions](/en-us/azure/container-apps/functions-overview) for [event-driven scenarios](/en-us/azure/azure-functions/functions-scenarios) using triggers, bindings and automatic scaling.

Azure Container Apps doesn't provide direct access to the underlying Kubernetes APIs. If you require access to the Kubernetes APIs and control plane, you should use [Azure Kubernetes Service](/en-us/azure/aks/what-is-aks). However, if you would like to build Kubernetes-style applications and don't require direct access to all the native Kubernetes APIs and cluster management, Container Apps provides a fully managed experience based on best-practices. For these reasons, many teams prefer to start building container microservices with Azure Container Apps.

You can get started building your first container app [using the quickstarts](/en-us/azure/container-apps/get-started).

### Azure App Service

[Azure App Service](/en-us/azure/app-service/overview) provides fully managed hosting for web applications including websites and web APIs. You can deploy these web applications using code or containers. Azure App Service is optimized for web applications. Azure App Service is integrated with other Azure services including Azure Container Apps or Azure Functions. When building web apps, Azure App Service is an ideal option.

### Azure Container Instances

[Azure Container Instances (ACI)](/en-us/azure/container-instances/) provides a single pod of Hyper-V isolated containers on demand. It can be thought of as a lower-level "building block" option compared to Container Apps. Concepts like scale, load balancing, and certificates aren't provided with ACI containers. For example, to scale to five container instances, you create five distinct container instances. Azure Container Apps provide many application-specific concepts on top of containers, including certificates, revisions, scale, and environments. Users often interact with Azure Container Instances through other services. For example, Azure Kubernetes Service can layer orchestration and scale on top of ACI through [virtual nodes](/en-us/azure/aks/virtual-nodes). If you need a less "opinionated" building block that doesn't align with the scenarios Azure Container Apps is optimizing for, Azure Container Instances is an ideal option.

### Azure Kubernetes Service

[Azure Kubernetes Service (AKS)](/en-us/azure/aks/what-is-aks) provides a fully managed Kubernetes platform in Azure, with two experience models: AKS Standard and [AKS Automatic](/en-us/azure/aks/intro-aks-automatic). AKS supports direct access to the Kubernetes API and can run any Kubernetes workload. With AKS Standard, the cluster resides in your subscription and you manage cluster configuration and operations. With AKS Automatic, Azure preconfigures and manages common operational tasks such as node management, scaling, security defaults, and upgrades for a more hands-off, production-ready experience.

### Azure Functions

[Azure Functions](/en-us/azure/azure-functions/functions-overview) is a serverless Functions-as-a-Service (FaaS) solution. It's optimized for running event-driven applications using the functions programming model. It shares many characteristics with Azure Container Apps around scale and integration with events, but optimized for ephemeral functions deployed as either code or containers. The Azure Functions programming model provides productivity benefits for teams looking to trigger the execution of your functions on events and bind to other data sources. When building FaaS-style functions, Azure Functions is the ideal option. The Azure Functions programming model is available as a base container image, making it portable to other container based compute platforms allowing teams to reuse code as environment requirements change.

### Azure Red Hat OpenShift

[Azure Red Hat OpenShift](/en-us/azure/openshift/intro-openshift) is an integrated product with Red Hat and Microsoft jointly engineered, operated, and supported. This collaboration provides an integrated product and support experience for running Kubernetes-powered OpenShift. With Azure Red Hat OpenShift, teams can choose their own registry, networking, storage, and CI/CD solutions. Alternatively, they can use the built-in solutions for automated source code management, container and application builds, deployments, scaling, health management, and more from OpenShift. If your team or organization is using OpenShift, Azure Red Hat OpenShift is an ideal option.