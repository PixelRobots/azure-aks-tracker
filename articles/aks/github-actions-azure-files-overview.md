---
layout: Conceptual
title: Solution overview for deploying highly available GitHub Actions on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/github-actions-azure-files-overview
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
description: In this article, we provide an overview of deploying highly available GitHub Actions on Azure Kubernetes Service (AKS) using Azure Files.
ms.topic: overview
ms.subservice: aks-storage
ms.date: 2025-06-13T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: stateful-workloads
locale: en-us
document_id: 5f10665a-b77a-a770-4d6b-df147a51e85c
document_version_independent_id: f00da099-4387-620d-0dfc-1f551a14f144
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/github-actions-azure-files-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/github-actions-azure-files-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/github-actions-azure-files-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
platformId: 856435d0-7c6f-d57f-6361-0fe46534ccac
---

# Solution overview for deploying highly available GitHub Actions on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this guide, you deploy a highly available GitHub Actions controller and self-hosted agents running on Azure Kubernetes Service (AKS). The self-hosted runners use SMB Azure file shares for persistent storage.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## What is Actions Runner Controller (ARC)?

[Actions Runner Controller (ARC)](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller) is a Kubernetes operator that orchestrates and scales self-hosted runners for GitHub Actions. ARC relies on persistent volumes (PVs) to share job information between the runner pod and the container job pod. For more information, see [About Actions Runner Controller](https://docs.github.com/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller).

## Why use self-hosted GitHub Actions on AKS?

Self-hosting GitHub Actions runners on AKS provides organizations with greater control, scalability, and security over their CI/CD infrastructure. Instead of relying on GitHub-hosted runners, which are shared and ephemeral, self-hosted runners offer:

- **Custom environments**: Tailor runners to match specific build, test, or deployment requirements.
- **Performance gains**: Leverage persistent storage and caching to reduce build times and improve reliability.
- **Cost efficiency at scale**: Dynamically scale runners within your own infrastructure, optimizing for frequent or long-running workflows.
- **Enhanced security & isolation**: Maintain full control over infrastructure and data, which is ideal for regulated industries or sensitive workloads.

### Common use cases

- **Enterprise CI/CD pipelines**: For teams needing consistent, secure, and scalable build environments.
- **Large monorepos or ML pipelines**: Where caching or artifact persistence is critical.
- **Performance optimization**: Using Azure Files premium SMB shares to reduce metadata latency and increase IOPS.

## Prerequisites

- This guide assumes a basic understanding of [core Kubernetes concepts](concepts-clusters-workloads).
- You need the **Owner** or **User Access Administrator** and the **Contributor**[Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles) on a subscription in your Azure account.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- You need an active GitHub account. Refer to the [pricing information](https://github.com/pricing) based on your repository control.
- You need the following resources installed:
    - [Azure CLI](/en-us/cli/azure/install-azure-cli) version 2.56 or later.
    - [Azure Kubernetes Service (AKS) preview extension](draft#install-the-aks-preview-azure-cli-extension).
    - [jq](https://jqlang.github.io/jq/) version 1.5 or later.
    - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) version 1.21.0 or later.
    - [openssl](https://www.openssl.org/) version 3.3.1 or later.
    - [Visual Studio Code](https://code.visualstudio.com/Download) or another code editor of your choice.

## Deployment process

In this guide, you learn how to:

- Use Azure CLI to create a multizone AKS cluster.
- Deploy an Azure file share to use in AKS persistent volumes.
- Install the GitHub Actions Runner Controller (ARC) on AKS.
- Install an ARC runners scale set and mount the file share on AKS.
- Run a sample workflow using GitHub Actions.

## Deployment architecture

This reference architecture illustrates how to implement a GitHub Actions self-hosted runner solution using AKS and Azure File Share (SMB). The solution enables organizations to execute GitHub workflow jobs securely within their own Azure infrastructure while maintaining efficient storage management and scalability.

[![Screenshot of architecture diagram for GitHub Actions with Azure Files on AKS.](media/github-actions-azure-files/github-actions-files-architecture.png)](media/github-actions-azure-files/github-actions-files-architecture.png#lightbox)

The architecture consists of three main components:

1. **GitHub integration layer**: Connects workflows from GitHub repositories to your Azure infrastructure.
2. **AKS orchestration layer**: Manages the containerized runner instances and their lifecycle.
3. **Storage layer**: Provides persistent and ephemeral storage capabilities for runners.

### GitHub integration layer

The GitHub integration layer connects workflows from GitHub repositories to your Azure infrastructure. Workflow jobs are dispatched from GitHub via `api.github.com` and `githubusercontent.com` to self-hosted runners.

### AKS cluster orchestration layer

The AKS cluster orchestration layer manages the containerized runner instances and their lifecycle. The cluster is split into two namespaces: `arc-controller` and `arc-runners`.

`arc-controller` manages runner infrastructure and job listeners. `arc-runners` handles secrets, access control, and runner pods. Runners are containerized, use ephemeral storage, and connect to shared and dedicated volumes.

### Storage layer

The Azure File Shares storage layer provides both NuGet file share with `ReadWriteMany` access for shared dependencies and ephemeral storage for runners, all backed by persistent volume claims.