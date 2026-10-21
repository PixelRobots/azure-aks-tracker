---
layout: Conceptual
title: Deploy and test inference models with the AI toolchain operator (KAITO) in Visual Studio Code - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-extension-kaito
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
description: Learn how to deploy and test an inference model with the AI toolchain operator (KAITO) in Visual Studio Code.
author: schaffererin
ms.topic: how-to
ms.date: 2026-09-12T00:00:00.0000000Z
ms.author: schaffererin
ms.custom: aks-ai-ml
locale: en-us
document_id: 79263308-1aae-6aac-6119-8288f37186a7
document_version_independent_id: 9e35a07f-41c9-f291-902f-517e7c27ba7d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-extension-kaito.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-extension-kaito
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-extension-kaito.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/911a44a7-2f6c-477c-810f-dc8b7d425cce
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/14f2b9d5-6f06-45a8-ac5f-313eaa351153
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: a36f5969-a739-b19b-58a5-b634ee287cd1
---

# Deploy and test inference models with the AI toolchain operator (KAITO) in Visual Studio Code - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to use the AI toolchain operator (KAITO) add-on in the Azure Kubernetes Service (AKS) extension for Visual Studio Code. KAITO automatically provisions the right-sized GPU nodes and sets up the inference server as an endpoint server to your AI model(s), allowing you to test and experiment with AI on AKS with ease.

## Prerequisites

- The Azure Kubernetes Service (AKS) extension for Visual Studio Code needs to be installed to use the KAITO experience. For more information, see [Install the Azure Kubernetes Service (AKS) extension for Visual Studio Code](aks-extension-vs-code#installation).
- The cluster that you are deploying to is a Standard Cluster *(Kaito cannot currently be installed on Automatic clusters)*.
- Verify that your Azure subscription has GPU quota for your chosen model by checking the [KAITO model catalog](https://kaito-project.github.io/kaito/docs/presets).

## Install KAITO on your cluster

1. In the Kubernetes tab, under **Clouds** &gt; **Azure** &gt; **your subscription** &gt; **Deploy a LLM with KAITO**, right click on your cluster and select **Install KAITO**.
2. Once on the page, select **Install KAITO** to start the KAITO installation process.
3. When the installation completes, you will see a **Generate Workspace** button that redirects you to the model deployment page.

[![Screenshot showing the KAITO install screen.](media/aks-extension/kaito/kaito-install.png)](media/aks-extension/kaito/kaito-install.png#lightbox)

## Create a KAITO workspace

When creating a KAITO workspace, you can either deploy the default workspace CRD directly into your AKS cluster or save the CRD and customize it for your needs.

1. In the Kubernetes tab, under **Clouds** &gt; **Azure** &gt; **your subscription** &gt; **Deploy a LLM with KAITO**, right click on your cluster and select **Create KAITO workspace**.
2. Find and select the model you want to deploy.
3. Select **Deploy default workspace CRD** or **Customize workspace CRD**.
4. Select **Deploy default workspace CRD** to deploy the model. It tracks the progress of the model and notifies you once the model successfully deploys. It also notifies you if the model was already deployed unsuccessfully onto your cluster.
5. When the deployment completes, you see a **View Deployed Models** button that redirects you to the deployment management page.

[![Screenshot showing the model select screen.](media/aks-extension/kaito/kaito-select-model.png)](media/aks-extension/kaito/kaito-select-model.png#lightbox)

## Manage KAITO models

The **Manage KAITO models** page shows all models deployed in your AKS cluster along with their status (*ongoing*, *successful*, or *failed*).

1. In the Kubernetes tab, under **Clouds** &gt; **Azure** &gt; **your subscription** &gt; **Deploy a LLM with KAITO**, right click on your cluster and select **Manage KAITO models**.
2. From this page, you can choose to perform one of the following actions:

    - **Get logs**: Select **Get Logs** to access the latest logs from the KAITO workspace pods for your deployment. This action generates a new text file containing the most recent 500 lines of logs.
    - **Delete a model**: Select **Delete Workspace** (or **Cancel** for ongoing deployments). For failed deployments, select **Redeploy Default CRD** to remove the current deployment and restart the model deployment process from scratch.
    - **Test a model**: Select **Test**. This action brings you to a new page where you can interact with the deployed model through a chat interface.

[![Screenshot showing the manage models screen.](media/aks-extension/kaito/kaito-manage-models.png)](media/aks-extension/kaito/kaito-manage-models.png#lightbox)

## Test your model

1. In the Kubernetes tab, under **Clouds** &gt; **Azure** &gt; **your subscription** &gt; **Deploy a LLM with KAITO**, right click on your cluster and select **Manage KAITO models**.
2. Select **Test**. This action brings you to a new page where you can interact with the deployed model through the **Prompt** box chat interface.
3. You can optionally adjust the parameters:

    - **Temperature**: Controls the randomness of the model's output. A low temperature is good for tasks needing precision, like math problems, while a high temperature is better for tasks like creative writing.
    - **Top P**: Limits the next-word choices to a dynamic subset of the vocabulary, determined by a cumulative probability threshold.
    - **Top K**: Limits the next-word selection to the top `K` most probable words. Smaller `K` values lead to more predictable outputs, while larger values increase variability.
    - **Repetition Penalty**: Penalizes the model for repeating the same phrases, words, or sequences. This is useful for avoiding repetitive or looping outputs, especially in longer generations.
    - **Max Length**: Defines the maximum number of tokens (words or subwords) in the generated output.

[![Screenshot showing test models screen.](media/aks-extension/kaito/kaito-test-model.png)](media/aks-extension/kaito/kaito-test-model.png#lightbox)

For more information, see [AKS extension for Visual Studio Code features](https://code.visualstudio.com/docs/azure/aksextensions#_features).

## Delete your model inference deployment

1. Once you've finished testing the model(s) and you want to free up the allocated GPU resources on your cluster, go to the Kubernetes tab, and under **Clouds** &gt; **Azure** &gt; **your subscription** &gt; **Deploy a LLM with KAITO**, right click on your cluster and select **Manage KAITO models**.
2. For each deployed model, select **Delete Workspace** to clear all allocated resources created by the inference deployment.

## Product support and feedback

If you have a question or want to offer product feedback, please open an issue on the [AKS extension GitHub repository](https://github.com/Azure/vscode-aks-tools/issues/new/choose).