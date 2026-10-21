---
layout: Conceptual
title: Deploy an AI Model on Azure Kubernetes Service (AKS) with the AI Toolchain Operator in the Azure Portal (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-toolchain-operator-azure-portal
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
description: Learn how to deploy an AI model on Azure Kubernetes Service (AKS) using the AI Toolchain Operator in the Azure portal (Preview).
ms.topic: how-to
ms.date: 2026-09-12T00:00:00.0000000Z
ai-usage: ai-assisted
author: schaffererin
ms.author: schaffererin
ms.custom: aks-ai-ml
locale: en-us
document_id: 4b4876dc-1fb1-34a2-e2db-3232f63896a8
document_version_independent_id: ab0bc27f-f419-97ca-6e13-d10f64c6ad2d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-toolchain-operator-azure-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/ai-toolchain-operator-azure-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-toolchain-operator-azure-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: ad2dca5c-b42b-7c12-3fbf-023c4aeec05c
---

# Deploy an AI Model on Azure Kubernetes Service (AKS) with the AI Toolchain Operator in the Azure Portal (Preview) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to use the AI toolchain operator (KAITO) in the Azure portal to efficiently self-host large language models on Kubernetes, reducing costs and resource complexity, enhancing customization, and maintaining full control over your data.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## About the AI toolchain operator (KAITO)

Self-hosting large language models (LLMs) on Kubernetes is gaining momentum among organizations with inference workloads at scale, such as batch processing, chatbots, agents, and AI-driven applications. These organizations often have access to commercial-grade GPUs and are seeking alternatives to costly per-token API pricing models, which can quickly scale out of control. Many also require the ability to fine-tune or customize their models, a capability typically restricted by closed-source API providers. Additionally, companies handling sensitive or proprietary data - especially in regulated sectors such as finance, healthcare, or defense - prioritize self-hosting to maintain strict control over data and prevent exposure through third-party systems.

To address these needs and more, the [Kubernetes AI Toolchain Operator (KAITO)](https://github.com/kaito-project/kaito), a Cloud Native Computing Foundation (CNCF) Sandbox project, simplifies the process of deploying and managing open-source LLM workloads on Kubernetes. KAITO integrates with vLLM, a high-throughput inference engine designed to serve large language models efficiently. vLLM as an inference engine helps reduce memory and GPU requirements without significantly compromising accuracy.

Built on top of the open-source KAITO project, the AI toolchain operator managed add-on offers a modular, plug-and-play setup that allows teams to quickly deploy models and expose them via production-ready APIs. It includes built-in features like OpenAI-compatible APIs, prompt formatting, and streaming response support. When deployed on an AKS cluster, KAITO ensures data stays within your organization’s controlled environment, providing a secure, compliant alternative to cloud-hosted LLM APIs.

## Before you begin

- This article assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for AKS](concepts-clusters-workloads).
- For ***the curated supported model list*** and default resource configuration, see the [KAITO GitHub document](https://kaito-project.github.io/kaito/docs/presets).
- The AI toolchain operator add-on typically lags one release behind the latest upstream KAITO version. Take this condition into consideration when choosing a model from the KAITO model repository.

## Limitations

- `Windows` OS SKU isn't currently supported.
- AMD GPU virtual machine (VM) sizes aren't a supported `instanceType` in a KAITO workspace.
- Virtual machine (VM) sizes using NVIDIA GPUs older than the Ampere architecture (such as the T4, V100, M60, and K80) aren't supported. KAITO requires NVIDIA GPUs with CUDA compute capability 8.0 or later.
- AI toolchain operator add-on is supported in **public** Azure regions.

## Prerequisites

- If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

    Note

    Your Azure subscription must have GPU VM quota recommended for your model deployment in the same Azure region as your AKS resources.
- An existing AKS cluster. If you don't have one, you can create one by following the steps in [Create an AKS cluster using the Azure portal](learn/quick-kubernetes-deploy-portal).

## Enable the AI toolchain operator on an AKS cluster

1. In the [Azure portal](https://portal.azure.com/), navigate to your **AKS cluster resource**.
2. From the service menu, select **Settings** &gt; **AI/ML (preview)** &gt; **Enable**.

    [![Screenshot that shows the AI/ML (preview) page and the option to enable KAITO in the Azure portal.](media/ai-toolchain-operator-azure-portal/enable-add-on-azure-portal.png)](media/ai-toolchain-operator-azure-portal/enable-add-on-azure-portal.png#lightbox)

## Connect to your AKS cluster using Azure Cloud Shell

You use the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/), to manage Kubernetes clusters. `kubectl` is already installed if you use Azure Cloud Shell. If you're unfamiliar with the Cloud Shell, review [Overview of Azure Cloud Shell](/en-us/azure/cloud-shell/overview).

If you're using Cloud Shell, open it with the `>_` button on the top of the Azure portal. If you're using PowerShell locally, connect to Azure via the `Connect-AzAccount` command. If you're using Azure CLI locally, connect to Azure via the `az login` command.

# [Azure CLI](#tab/azure-cli)
1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```
2. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command, which returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

    The following example output shows the single node created in the previous steps. Make sure the node status is *Ready*.

    ```output
    NAME                       STATUS   ROLES   AGE     VERSION
    aks-nodepool1-31718369-0   Ready    agent   6m44s   v1.15.10
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. Configure `kubectl` to connect to your Kubernetes cluster using the [`Import-AzAksCredential`](/en-us/powershell/module/az.aks/import-azakscredential) cmdlet. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurepowershell
    Import-AzAksCredential -ResourceGroupName $RESOURCE_GROUP -Name $CLUSTER_NAME
    ```
2. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command, which returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

    The following example output shows the single node created in the previous steps. Make sure the node status is *Ready*.

    ```output
    NAME                       STATUS  ROLES   AGE     VERSION
    aks-nodepool1-31718369-0   Ready   agent   6m44s   v1.15.10
    ```

---

## Deploy a default hosted AI model

1. Navigate through the supported model registry in the **Models** tab and select **Deploy** for your chosen model.

    [![Screenshot that shows the supported model registry in the AI/ML (preview) blade of the AKS cluster resource in the Azure portal.](media/ai-toolchain-operator-azure-portal/add-on-azure-portal-model.png)](media/ai-toolchain-operator-azure-portal/add-on-azure-portal-model.png#lightbox)
2. On the **1. Model** page, select a **Model family**, **Model**, and **Instance type**, and enter a **Workspace name**.

    [![Screenshot that shows the inference configuration and compute resource details for the selected model in the Azure portal.](media/ai-toolchain-operator-azure-portal/add-on-azure-portal-model-details.png)](media/ai-toolchain-operator-azure-portal/add-on-azure-portal-model-details.png#lightbox)
3. Deploy the model.
4. Track the resource readiness and progress of the inference service deployment in the **AI Deployments** tab.

    [![Screenshot that shows the AI Deployments tab in the Azure portal.](media/ai-toolchain-operator-azure-portal/add-on-azure-portal-deployment-progress.png)](media/ai-toolchain-operator-azure-portal/add-on-azure-portal-deployment-progress.png#lightbox)

## Test the model inference service

- Test different inputs on your model inference service and adjust the configurable parameters to evaluate model performance.

    [![Screenshot that shows the KAITO inference test page with sliders to configure LLM parameters in the Azure portal.](media/ai-toolchain-operator-azure-portal/add-on-azure-portal-model-testing.png)](media/ai-toolchain-operator-azure-portal/add-on-azure-portal-model-testing.png#lightbox)