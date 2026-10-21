---
layout: Conceptual
title: Azure Kubernetes Fleet Manager Automated Deployments conceptual overview | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-automated-deployments
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
learn_banner_products:
- azure
description: Learn about the concepts behind Fleet Manager Automated Deployments which simplify the process of building and deploying your application from Git.
author: sjwaight
ms.author: simonwaight
ms.topic: overview
ms.custom: build-2025
ms.date: 2026-07-28T00:00:00.0000000Z
ms.service: azure-kubernetes-fleet-manager
locale: en-us
document_id: 54a4ded4-10c0-1082-630c-9c797af9e69f
document_version_independent_id: c2e47e09-e484-7c5e-5bce-9a9be864366d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-automated-deployments.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-automated-deployments
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-automated-deployments.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: eda76d83-bd68-9a2e-b6d8-21c1497316b2
---

# Azure Kubernetes Fleet Manager Automated Deployments conceptual overview | Microsoft Learn

**Applies to**: ✔️ Fleet Manager with hub cluster

This article provides a conceptual overview of Fleet Manager's Automated Deployments capability. Fleet Manager Automated Deployments simplify the process of taking your application source code from a GitHub repository and deploying it across one or more AKS clusters in your fleet. Once configured, every new commit you make runs the pipeline, resulting in updates to your application wherever it's deployed in your fleet.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

## Prerequisites

To use Fleet Manager Automated Deployments the following prerequisites must be in place.

- A GitHub account.
- An application to deploy. The application can already be containerized, or Automated Deployments can containerize it based on the contents of the repository.
- An Azure Kubernetes Fleet Manager [with a hub cluster](concepts-choosing-fleet#fleet-manager-with-hub-cluster) and one or more member AKS clusters.
- A Kubernetes namespace on the Fleet Manager hub cluster.
- An Azure Container Registry (ACR) with [AcrPull rights granted to member AKS clusters](/en-us/azure/aks/cluster-container-registry-integration).

## Core concepts

Fleet Manager Automated Deployments help with the following activities:

- Securely connecting a source GitHub repository to a Fleet hub cluster without the need for an operator to handle credentials. You can connect multiple repositories or branches to a single Fleet Manager.
- Building container images and publishing to an existing Azure Container Registry (ACR) ensuring images are located in a known registry that fleet members can access.
- Staging resource manifests into an existing namespace on the Fleet Manager hub cluster so they're ready for [cluster resource placement (CRP)](concepts-resource-placement).

The generated GitHub Actions workflow can be modified to meet your needs by using an editor like Visual Studio Code.

### Existing resource requirements

These resources must already exist and be configured when using Fleet Manager Automated Deployments.

- **Container Registry** - in order to facilitate image pulls from Azure Container Registry, member AKS clusters must be granted `AcrPull` rights on the Registry. On initial configuration, Automated Deployments is unable to determine which member clusters might receive a placement, so it's not possible to automate permission setup for an unknown set of clusters. Granting all member clusters `AcrPull` rights on a Registry is likely undesirable, so the decision to configure this permission on clusters is delegated to an authorized user outside the scope of Automated Deployments.
- **Kubernetes Namespace** - while Fleet Manager's cluster resource placements can be used to deploy cluster-scoped resources we have limited Automated Deployments to deploying only namespace-scoped resources. This limitation simplifies the setup of deployments by focusing on application workloads in a namespace instead of broader Kubernetes constructs.

Note

We welcome feedback as we continue to work on Fleet Manager Automated Deployments.

As an example: We're considering adding further steps to generate a CRP on initial setup, along with automated execution of the CRP. Today you can add a CRP to your source repository and manually modify the generated GitHub Action to add a stage that applies the placement.

If you would like to provide feedback and suggestions on any aspect of Fleet Manager Automated Deployments add them to the [roadmap item for this feature](https://github.com/Azure/AKS/issues/4685).

## GitHub OAuth application

Once you grant Automated Deployments access to your GitHub repository you will find a new application in your GitHub `Authorized OAuth Apps` list named `AKS Developer Hub`. This is the same application as used by the AKS Automated Deployments capability.

## Single cluster support

To deploy to a single AKS cluster, you can use [Automated Deployments for AKS](/en-us/azure/aks/automated-deployments) which doesn't require Fleet Manager.