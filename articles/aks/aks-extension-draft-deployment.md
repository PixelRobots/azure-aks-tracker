---
layout: Conceptual
title: Create a Kubernetes deployment using Automated Deployments in the Azure Kubernetes Service (AKS) extension for Visual Studio Code - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-extension-draft-deployment
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
description: Learn how create a Kubernetes deployment using Automated Deployments in the Azure Kubernetes Service (AKS) extension for Visual Studio Code.
author: schaffererin
ms.topic: how-to
ms.date: 2024-07-15T00:00:00.0000000Z
ms.author: schaffererin
ms.subservice: aks-developer
locale: en-us
document_id: e960e0b1-8991-1037-38ec-139551ff6fdc
document_version_independent_id: 7d3f9b75-2bce-9e25-6a19-8fdb69447ffd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-extension-draft-deployment.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-extension-draft-deployment
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-extension-draft-deployment.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/911a44a7-2f6c-477c-810f-dc8b7d425cce
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/14f2b9d5-6f06-45a8-ac5f-313eaa351153
platformId: dc0fd765-eb86-41d0-76e8-aedc40a41f5d
---

# Create a Kubernetes deployment using Automated Deployments in the Azure Kubernetes Service (AKS) extension for Visual Studio Code - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to create a Kubernetes deployment using Automated Deployments in the Azure Kubernetes Service (AKS) extension for Visual Studio Code. Automated Deployments provides an easy way to automate the process of scaling, updating, and maintaining your applications.

## Prerequisites

Before you begin, make sure you have the following resources:

- An active folder with code open in Visual Studio Code.
- The Azure Kubernetes Service (AKS) extension for Visual Studio Code downloaded. For more information, see [Install the Azure Kubernetes Service (AKS) extension for Visual Studio Code](aks-extension-vs-code#installation).

## Create a Kubernetes deployment using the Azure Kubernetes Service (AKS) extension

You can access the screen to create a Kubernetes deployment using the command palette or the explorer view.

# [Command palette](#tab/command-palette)
1. On your keyboard, press `Ctrl+Shift+P` to open the command palette.
2. In the search bar, search for and select **Automated Deployments: Create a Deployment**.
3. Enter the following information:

    - **Subscription**: Select your Azure subscription.
    - **Location**: Select a location where you want to save your Kubernetes deployment files.
    - **Deployment options**: Select `Kubernetes manifests`, `Helm`, or `Kustomize`.
    - **Target port**: Select the port in which your applications listen to in your deployment. This port usually matches what is exposed in your Dockerfile.
    - **Service port**: Select the port in which the service listens to for incoming traffic.
    - **Namespace**: Select the namespace in which your application will be deployed into.
4. Select **Create**.

# [Explorer view](#tab/explorer-view)
1. Right click on the explorer pane where your active folder is open and select **Create a Deployment**.
2. Enter the following information:

    - **Subscription**: Select your Azure subscription.
    - **Location**: Select a location where you want to save your Kubernetes deployment files.
    - **Deployment options**: Select `Kubernetes manifests`, `Helm`, or `Kustomize`.
    - **Target port**: Select the port in which your applications listen to in your deployment. This port usually matches what is exposed in your Dockerfile.
    - **Service port**: Select the port in which the service listens to for incoming traffic.
    - **Namespace**: Select the namespace in which your application will be deployed into.
3. Select **Create**.

---

For more information, see [AKS extension for Visual Studio Code features](https://code.visualstudio.com/docs/azure/aksextensions#_features).

## Product support and feedback

If you have a question or want to offer product feedback, please open an issue on the [AKS extension GitHub repository](https://github.com/Azure/vscode-aks-tools/issues/new/choose).