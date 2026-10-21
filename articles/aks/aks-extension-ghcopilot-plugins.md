---
layout: Conceptual
title: Use AKS plugins for GitHub Copilot for Azure - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-extension-ghcopilot-plugins
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
description: Learn how to use AKS plugins in GitHub Copilot for Azure to enhance your day-to-day experience in Azure Kubernetes Service
author: schaffererin
ms.topic: how-to
ms.date: 2024-10-28T00:00:00.0000000Z
ms.author: schaffererin
ms.subservice: aks-developer
ms.collection: ce-skilling-ai-copilot
ms.update-cycle: 180-days
locale: en-us
document_id: 09fdd0ac-f22f-cf27-73db-523dfc0d437b
document_version_independent_id: 65d4d89a-184c-fdba-8068-40e93f389612
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-extension-ghcopilot-plugins.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-extension-ghcopilot-plugins
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-extension-ghcopilot-plugins.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/341fdab2-4964-4759-8241-f5820b012a47
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/cc1f92bb-c0d6-4d40-99ce-dabea3161a84
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: cc9716de-7a1d-422b-1cf7-f846a2dfb6a9
---

# Use AKS plugins for GitHub Copilot for Azure - Azure Kubernetes Service | Microsoft Learn

The AKS plugins (or skills) for GitHub Copilot for Azure (@azure) extension enable users to perform various tasks related to Azure Kubernetes Service (AKS) directly from the GitHub Copilot Chat view. These skills include creating an AKS cluster, deploying a manifest to an AKS cluster, and generating Kubectl commands.

## Prerequisites

Before you begin, make sure you have the following resources:

- [GitHub Copilot](https://github.com/features/copilot) installed.
- [GitHub Copilot for Azure](https://github.com/microsoft/GitHub-Copilot-for-Azure) installed.
- The Azure Kubernetes Service (AKS) extension for Visual Studio Code downloaded. For more information, see [Install the Azure Kubernetes Service (AKS) extension for Visual Studio Code](aks-extension-vs-code#installation).

## How to start using the AKS plugins for GitHub Copilot for Azure

You can access the AKS plugins for GitHub Copilot for Azure by opening up the GitHub Copilot side-bar panel in Visual Studio Code.

### Create an AKS cluster

[![Screenshot showing a cluster being created via GitHub Copilot for Azure.](media/aks-extension/github-copilot-for-azure-aks/aks-github-chat-create-cluster.png)](media/aks-extension/github-copilot-for-azure-aks/aks-github-chat-create-cluster.png#lightbox)

You can create an AKS cluster using the following prompts:

- [@azure] can you help me create a Kubernetes cluster
- [@azure] can you set up an AKS cluster for me?
- [@azure] I have a containerized application, can you help me create an AKS cluster to host it?
- [@azure] create AKS cluster
- [@azure] Help me create a Kubernetes cluster to host my application

### Deploy a manifest to an AKS cluster

[![Screenshot showing a manifest being deployed via GitHub Copilot for Azure.](media/aks-extension/github-copilot-for-azure-aks/aks-github-chat-deploy-manifest.png)](media/aks-extension/github-copilot-for-azure-aks/aks-github-chat-deploy-manifest.png#lightbox)

You can deploy your application manifests to an AKS cluster directly from the GitHub Copilot Chat view. This simplifies the deployment process and ensures consistency. By using predefined prompts, the risk of errors during deployment is minimized leading to more reliable and stable deployments.

To deploy a manifest file to an AKS cluster you can use these prompts:

- [@azure] help me deploy my manifest file
- [@azure] can you deploy my manifest to my AKS cluster?
- [@azure] can you deploy my manifest to my Kubernetes cluster?
- [@azure] deploy my application manifest to an AKS cluster
- [@azure] deploy manifest for AKS cluster

### Generate Kubectl commands

[![Screenshot showing kubectl commands via GitHub Copilot for Azure.](media/aks-extension/github-copilot-for-azure-aks/aks-github-chat-kubectl-generation.png)](media/aks-extension/github-copilot-for-azure-aks/aks-github-chat-kubectl-generation.png#lightbox)

You can generate various Kubectl commands to manage your AKS clusters without needing to remember complex command syntax. This makes cluster management more accessible, especially for those who may not be Kubernetes experts. Quickly generating the necessary commands helps you perform cluster operations more efficiently, saving time and effort.

You can generate various Kubectl commands for your AKS cluster using these prompts:

- [@azure] list all services for my AKS cluster
- [@azure] kubectl command to get deployments with at least 2 replicas in AKS cluster
- [@azure] get me all services in my AKS cluster with external IPs
- [@azure] what is the kubectl command to get pod info for my AKS cluster?
- [@azure] Can you get kubectl command for getting all API resources

For more information, see [AKS extension for Visual Studio Code features](https://code.visualstudio.com/docs/azure/aksextensions#_features).

## Product support and feedback

If you have a question or want to offer product feedback, please open an issue on the [AKS extension GitHub repository](https://github.com/Azure/vscode-aks-tools/issues/new/choose).