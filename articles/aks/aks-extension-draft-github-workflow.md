---
layout: Conceptual
title: Create a GitHub Workflow using Automated Deployments in the Azure Kubernetes Service (AKS) extension for Visual Studio Code - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-extension-draft-github-workflow
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
description: Learn how to create a GitHub Workflow using Automated Deployments in the Azure Kubernetes Service (AKS) extension for Visual Studio Code.
author: schaffererin
ms.topic: how-to
ms.date: 2024-07-15T00:00:00.0000000Z
ms.author: schaffererin
ms.subservice: aks-developer
locale: en-us
document_id: 7a9f408b-c947-2c29-ec82-d0f61d0db5a9
document_version_independent_id: d5c1edce-c14a-e890-3d57-535d12c6ea45
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-extension-draft-github-workflow.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-extension-draft-github-workflow
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-extension-draft-github-workflow.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
- https://authoring-docs-microsoft.poolparty.biz/devrel/911a44a7-2f6c-477c-810f-dc8b7d425cce
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
- https://authoring-docs-microsoft.poolparty.biz/devrel/14f2b9d5-6f06-45a8-ac5f-313eaa351153
platformId: d9d33e51-80a4-59c2-1afd-c0300ab9ef20
---

# Create a GitHub Workflow using Automated Deployments in the Azure Kubernetes Service (AKS) extension for Visual Studio Code - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to create a GitHub Workflow using Automated Deployments in the Azure Kubernetes Service (AKS) extension for Visual Studio Code. A GitHub Workflow automates various development tasks, such as building, testing, and deploying code, ensuring consistency and efficiency across the development process. It enhances collaboration by integrating seamlessly with version control, enabling continuous integration and continuous deployment (CI/CD) pipelines, and ensuring that all changes are thoroughly vetted before being merged into the main codebase.

## Prerequisites

Before you begin, make sure you have the following resources:

- An active folder with code open in Visual Studio Code.
- Make sure the current workspace is an active `git` repository.
- The Azure Kubernetes Service (AKS) extension for Visual Studio Code downloaded. For more information, see [Install the Azure Kubernetes Service (AKS) extension for Visual Studio Code](aks-extension-vs-code#installation).

## Create a GitHub Workflow using the Azure Kubernetes Service (AKS) extension

You can access the screen to create a GitHub Workflow using the command palette or the Kubernetes view.

# [Command palette](#tab/command-palette)
1. On your keyboard, press `Ctrl+Shift+P` to open the command palette.
2. Enter the following information:

    - **Workflow name**: Enter a name for your GitHub Workflow.
    - **GitHub repository**: Select the location where want to save your Kubernetes deployment files.
    - **Subscription**: Select your Azure subscription.
    - **Dockerfile**: Select the Dockerfile that you want to build in the GitHub Action.
    - **Build context**: Select a build context.
    - **ACR Resource Group**: Select an ACR resource group.
    - **Container Registry**: Select a container registry.
    - **Azure Container Registry image**: Select or enter an Azure Container Registry image.
    - **Cluster Resource Group**: Select your cluster resource group.
    - **Cluster**: Select your AKS cluster.
    - **Namespace**: Select or enter a namespace in which you will deploy into.
    - **Type**: Select the type of deployment option.
3. Select **Create**.

# [Kubernetes view](#tab/kubernetes-view)
1. In the Kubernetes tab, under Clouds &gt; Azure &gt; your subscription &gt; Automated Deployments, right click on your cluster and select **Create a GitHub Workflow**.
2. Enter the following information:

    - **Workflow name**: Enter a name for your GitHub Workflow.
    - **GitHub repository**: Select the location where want to save your Kubernetes deployment files.
    - **Subscription**: Select your Azure subscription.
    - **Dockerfile**: Select the Dockerfile that you want to build in the GitHub Action.
    - **Build context**: Select a build context.
    - **ACR Resource Group**: Select an ACR resource group.
    - **Container Registry**: Select a container registry.
    - **Azure Container Registy image**: Select or enter an Azure Container Registry image.
    - **Cluster Resource Group**: Select your cluster resource group.
    - **Cluster**: Select your AKS cluster.
    - **Namespace**: Select or enter a namespace in which you will deploy into.
    - **Type**: Select the type of deployment option.
3. Select **Create**.

---

For more information, see [AKS extension for Visual Studio Code features](https://code.visualstudio.com/docs/azure/aksextensions#_features).

## Product support and feedback

If you have a question or want to offer product feedback, please open an issue on the [AKS extension GitHub repository](https://github.com/Azure/vscode-aks-tools/issues/new/choose).