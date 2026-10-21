---
layout: Conceptual
title: Introduction to Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-intro
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Get basic information about the Azure service that provides cloud-based, managed container registries.
ms.topic: overview
ms.date: 2026-02-11T00:00:00.0000000Z
ms.custom: mvc
locale: en-us
document_id: b876f15f-5cad-5764-891d-ff8184f3d8ca
document_version_independent_id: 7831214a-7ed5-30ae-d3c0-d0474a90f56c
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-intro.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-intro
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-intro.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 401aed88-0b60-2e75-6dd2-e7cb08aea5b7
---

# Introduction to Azure Container Registry - Azure Container Registry | Microsoft Learn

Azure Container Registry is a managed registry service based on the open-source [Docker platform](https://docs.docker.com/get-started/docker-overview/). Create and maintain Azure container registries to store and manage your [container images and related artifacts](container-registry-concepts).

Use container registries with your existing container development and deployment pipelines, or use Azure Container Registry tasks to build container images in Azure. Build on demand, or fully automate builds with triggers such as source code commits and base image updates.

Azure provides tooling like the Azure CLI, the Azure portal, and API support to manage your container registries. Optionally, install the [Container Tools extension](https://code.visualstudio.com/docs/containers/overview) for Visual Studio Code. You can use this extension to perform tasks such as pulling and pushing images to your registry, all within Visual Studio Code.

Container registries are available in three tiers (SKUs): Basic, Standard, and Premium. Each tier supports common features such as webhook integration, registry authentication with Microsoft Entra ID, and delete functionality. Premium registries support additional capabilities and have greater storage and limits. For more details about the different tiers, see [Azure Container Registry SKUs](container-registry-skus).

Take advantage of local, network-close storage of your container images by creating a registry in the same Azure location as your deployments. The [geo-replication](container-registry-geo-replication) feature of Premium registries supports advanced replication and container image distribution across geographies.

## Container registry deployment targets and workflows

Pull images from an Azure container registry to various deployment targets:

- *Scalable orchestration systems* that manage containerized applications across clusters of hosts, including [Kubernetes](https://kubernetes.io/docs/), [DC/OS](https://dcos.io/), and [Docker Swarm](https://docs.docker.com/guides/swarm-deploy/).
- *Azure services* that support building and running applications at scale, such as [Azure Kubernetes Service (AKS)](/en-us/azure/aks/what-is-aks), [App Service](/en-us/azure/app-service/overview), [Batch](/en-us/azure/batch/batch-technical-overview), and [Service Fabric](/en-us/azure/service-fabric/service-fabric-overview).

Developers can also push to a container registry as part of a container development workflow. For example, you can target a container registry from a continuous integration and continuous delivery (CI/CD) tool such as [Azure Pipelines](/en-us/azure/devops/pipelines/ecosystems/containers/acr-template) or [Jenkins](https://jenkins.io/).

Configure [Azure Container Registry tasks](container-registry-tasks-overview) to automatically rebuild application images when their base images are updated, or automate image builds when your team commits code to a Git repository. Use tasks to extend your development inner loop to the cloud by offloading `docker build` operations to Azure, or configure build tasks to automate your container OS and framework patching pipeline. Create [multi-step tasks](container-registry-tasks-overview#multi-step-tasks) to automate building, testing, and patching container images in parallel in the cloud.

## Supported images and artifacts

When images are grouped in a repository, each image is a read-only snapshot of a Docker-compatible container. Azure container registries can include both Windows and Linux images. You control image names for all your container deployments.

Use standard [Docker commands](https://docs.docker.com/reference/cli/docker/) to push images into a repository or pull an image from a repository. Azure Container Registry stores Docker container images and [related content formats](container-registry-image-formats) such as [Helm charts](container-registry-helm-repos) and images built to the [Open Container Initiative (OCI) Image Format Specification](https://github.com/opencontainers/image-spec/blob/master/spec.md).

## Container registry security and access

You authenticate to a registry by using the Azure CLI or the standard `docker login` command. Azure Container Registry transfers container images over HTTPS, and it supports TLS to help secure client connections.

[Control access](container-registry-authentication) to a container registry by using an Azure identity, a Microsoft Entra [service principal](/en-us/azure/active-directory/develop/app-objects-and-service-principals), or a provided admin account. Use [Azure role-based access control (RBAC)](container-registry-rbac-built-in-roles-directory-reference) to assign specific registry permissions to users or systems.

Security features of the Premium service tier include [content trust](container-registry-content-trust) for image tag signing, and [private endpoints (preview)](container-registry-private-endpoints) to restrict access to the registry. Microsoft Defender for Cloud optionally integrates with Azure Container Registry to [scan images](/en-us/azure/container-registry/scan-images-defender) whenever you push an image to a registry.