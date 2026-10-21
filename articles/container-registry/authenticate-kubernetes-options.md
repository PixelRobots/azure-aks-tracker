---
layout: Conceptual
title: Kubernetes Authentication Scenarios for ACR - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/authenticate-kubernetes-options
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
description: Overview of options and scenarios to authenticate to an Azure container registry from a Kubernetes cluster to pull container images
ms.topic: concept-article
ms.date: 2026-01-07T00:00:00.0000000Z
locale: en-us
document_id: 5b84af83-627a-a074-cce7-ed51cb1e692f
document_version_independent_id: 8ffbb26c-9dc0-5ceb-2e3f-e593a2cd696d
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/authenticate-kubernetes-options.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/authenticate-kubernetes-options
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/authenticate-kubernetes-options.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 8d3fa448-1c9d-d5c8-b2d0-b3f6f68fcfcf
---

# Kubernetes Authentication Scenarios for ACR - Azure Container Registry | Microsoft Learn

You can use an Azure container registry as a source of container images for Kubernetes. This setup can include clusters you manage, managed clusters hosted in [Azure Kubernetes Service (AKS)](/en-us/azure/aks/intro-kubernetes) or other clouds, and "local" Kubernetes configurations such as [minikube](https://minikube.sigs.k8s.io/) and [kind](https://kind.sigs.k8s.io/).

To pull images to your Kubernetes cluster from an Azure container registry, you need to establish an authentication and authorization mechanism. Depending on your cluster environment, choose one of the following methods:

## Scenarios

| Kubernetes cluster | Authentication method | Description | Example |
| --- | --- | --- | --- |
| AKS cluster | AKS managed identity | Lets the AKS kubelet [managed identity](/en-us/azure/aks/use-managed-identity) pull images from an attached Azure container registry. The registry and cluster must be in the same Azure tenant, but can be in different Azure subscriptions. | [Authenticate with Azure Container Registry from Azure Kubernetes Service](/en-us/azure/aks/cluster-container-registry-integration?toc=/azure/container-registry/toc.json&amp;bc=/azure/container-registry/breadcrumb/toc.json) |
| AKS cluster | AKS service principal | Grants the [AKS service principal](/en-us/azure/aks/kubernetes-service-principal) permissions to a target Azure container registry.The registry and cluster can be in different Azure tenants or subscriptions. | [Pull images from an Azure container registry to an AKS cluster in a different tenant](authenticate-aks-cross-tenant) |
| Kubernetes cluster other than AKS | Pod [imagePullSecrets](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) | Use the general Kubernetes mechanism to manage registry credentials for pod deployments.Configure service principal, repository-scoped token, or other supported [registry credentials](container-registry-authentication). | [Pull images from an Azure container registry to a Kubernetes cluster using a pull secret](container-registry-auth-kubernetes) |