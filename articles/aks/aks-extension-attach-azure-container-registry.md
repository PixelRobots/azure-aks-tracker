---
layout: Conceptual
title: Attach to Azure Container Registry (ACR) using the Azure Kubernetes Service (AKS) extension for Visual Studio Code - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-extension-attach-azure-container-registry
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
description: Learn how to attach to Azure Container Registry (ACR) using the Azure Kubernetes Service (AKS) extension for Visual Studio Code.
author: schaffererin
ms.topic: how-to
ms.date: 2024-07-15T00:00:00.0000000Z
ms.author: schaffererin
ms.subservice: aks-developer
locale: en-us
document_id: 7ea4de1c-964f-5152-a2da-b335cf830f39
document_version_independent_id: 9e2e5397-7578-20e4-0990-0060155dbde4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-extension-attach-azure-container-registry.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-extension-attach-azure-container-registry
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-extension-attach-azure-container-registry.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/911a44a7-2f6c-477c-810f-dc8b7d425cce
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/14f2b9d5-6f06-45a8-ac5f-313eaa351153
platformId: 2e95babf-f51c-977b-810d-0d8d92770324
---

# Attach to Azure Container Registry (ACR) using the Azure Kubernetes Service (AKS) extension for Visual Studio Code - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to attach to Azure Container Registry (ACR) using the Azure Kubernetes Service (AKS) extension for Visual Studio Code.

## Prerequisites

Before you begin, make sure you have the following resources:

- An Azure container registry. If you don't have one, create one using the steps in [Quickstart: Create a private container registry](/en-us/azure/container-registry/container-registry-get-started-azure-cli).
- An AKS cluster. If you don't have one, create one using the steps in [Quickstart: Deploy an AKS cluster](learn/quick-kubernetes-deploy-cli).
- The Azure Kubernetes Service (AKS) extension for Visual Studio Code downloaded. For more information, see [Install the Azure Kubernetes Service (AKS) extension for Visual Studio Code](aks-extension-vs-code#installation).

## Attach your Azure container registry to your AKS cluster

You can access the screen for attaching your container registry to your AKS cluster using the command palette or the Kubernetes view.

# [Command palette](#tab/command-palette)
1. On your keyboard, press `Ctrl+Shift+P` to open the command palette.
2. Enter the following information:

    - **Subscription**: Select the Azure subscription that holds your resources.
    - **ACR Resource Group**: Select the resource group for your container registry.
    - **Container Registry**: Select the container registry you want to attach to your cluster.
    - **Cluster Resource Group**: Select the resource group for your cluster.
    - **Cluster**: Select the cluster you want to attach to your container registry.
3. Select **Attach**.

    You should see a green checkmark, which means your container registry is attached to your AKS cluster.

# [Kubernetes view](#tab/kubernetes-view)
1. In the Kubernetes tab, under Clouds &gt; Azure &gt; your subscription &gt; Automated Deployments, right click on your cluster and select **Attach ACR to Cluster**.
2. Enter the following information:

    - **Subscription**: Select the Azure subscription that holds your resources.
    - **ACR Resource Group**: Select the resource group for your container registry.
    - **Container Registry**: Select the container registry you want to attach to your cluster.
    - **Cluster Resource Group**: Select the resource group for your cluster.
    - **Cluster**: Select the cluster you want to attach to your container registry.
3. Select **Attach**.

    You should see a green checkmark, which means your container registry is attached to your AKS cluster.

---

For more information, see [AKS extension for Visual Studio Code features](https://code.visualstudio.com/docs/azure/aksextensions#_features).

## Product support and feedback

If you have a question or want to offer product feedback, please open an issue on the [AKS extension GitHub repository](https://github.com/Azure/vscode-aks-tools/issues/new/choose).