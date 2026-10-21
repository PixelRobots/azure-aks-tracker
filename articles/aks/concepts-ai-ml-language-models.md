---
layout: Conceptual
title: Concepts - Small and Large Language Models - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-ai-ml-language-models
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
description: Learn about small and large language models, when to use each model type, and how to run AI and machine learning workflows on Azure Kubernetes Service (AKS), with AKS Automatic as the recommended production default for most workloads.
ms.topic: concept-article
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: schaffererin
ms.author: schaffererin
ms.custom: aks-ai-ml
locale: en-us
document_id: bbd395c4-0338-fbe0-b58d-2d2ddbcbefd4
document_version_independent_id: 78e0ec25-0315-b7ea-6f1d-d09b64d3479c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-ai-ml-language-models.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-ai-ml-language-models
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-ai-ml-language-models.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c6f99e62-1cf6-4b71-af9b-649b05f80cce
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/3f56b378-07a9-4fa1-afe8-9889fdc77628
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 425142b8-2582-38df-efcd-dec4641b5d89
---

# Concepts - Small and Large Language Models - Azure Kubernetes Service | Microsoft Learn

In this article, you learn about small and large language models, including when to use them and how you can use them with your AI and machine learning workflows on Azure Kubernetes Service (AKS).

For most production AI and machine learning workloads on AKS, AKS Automatic is the recommended default. AKS Automatic provides production-ready defaults for scaling, security, networking, and operations so teams can focus on model onboarding, evaluation, and application behavior instead of cluster management.

## What are language models?

Language models are powerful machine learning models used for natural language processing (NLP) tasks, such as text generation and sentiment analysis. These models represent natural language based on the probability of words or sequences of words occurring in a given context.

*Conventional language models* have been used in supervised settings for research purposes where the models are trained on well-labeled text datasets for specific tasks. *Pre-trained language models* offer an accessible way to get started with AI and have become more widely used in recent years. These models are trained on large-scale text corpora from the internet using deep neural networks and can be fine-tuned on smaller datasets for specific tasks.

The size of a language model is determined by its number of parameters, or *weights*, that determine how the model processes input data and generates output. Parameters are learned during the training process by adjusting the weights within layers of the model to minimize the difference between the model's predictions and the actual data. The more parameters a model has, the more complex and expressive it is, but also the more computationally expensive it is to train and use.

In general, **small language models** have *fewer than 10 billion parameters*, and **large language models** have *more than 10 billion parameters*. For example, the Microsoft Phi-4 model family includes versions with different sizes: Phi-4-mini (3.8 billion parameters) and Phi-4 (14 billion parameters).

## When to use small language models

### Advantages

Small language models are a good choice if you want models that are:

- **Faster and more cost-effective to train and run**: They require less data and compute power.
- **Easy to deploy and maintain**: They have smaller storage and memory footprints.
- **Less prone to overfitting**, which is when a model learns the noise or specific patterns of the training data and fails to generalize new data.
- **Interpretable and explainable**: They have fewer parameters and components to understand and analyze.

### Use cases

Small language models are suitable for use cases that require:

- **Limited data or resources**, and you need a quick and simple solution.
- **Well-defined or narrow tasks**, and you don't need much creativity in the output.
- **High-precision and low-recall tasks**, and you value accuracy and quality over coverage and quantity.
- **Sensitive or regulated tasks**, and you need to ensure the transparency and accountability of the model.

The following table lists some popular, high-performance small language models:

| Model family | Model sizes (Number of parameters) | Software license |
| --- | --- | --- |
| Microsoft Phi-4 | Phi-4-mini (3.8 billion) | MIT license |
| Google Gemma | Gemma-4-E2B (2 billion), Gemma-4-E4B (4 billion) | Apache 2.0 license |

## When to use large language models

### Advantages

Large language models are a good choice if you want models that are:

- **Powerful and expressive**: They can capture more complex patterns and relationships in the data.
- **General and adaptable**: They can handle a wider range of tasks and transfer knowledge across domains.
- **Robust and consistent**: They can handle noisy or incomplete inputs and avoid common errors and biases.

### Use cases

Large language models are suitable for use cases that require:

- **Abundant data and resources**, and you have the budget to build and maintain a complex solution.
- **Low-precision and high-recall tasks**, and you value coverage and quantity over accuracy and quality.
- **Challenging or exploratory tasks**, and you want to leverage the model's capacity to learn and adapt.

The following table lists some popular, high-performance large language models:

| Model family | Model sizes (Number of parameters) | Software license |
| --- | --- | --- |
| Microsoft Phi-4 | Phi-4 (14 billion) | MIT license |
| Google Gemma | Gemma-4-31B (31 billion) | Apache 2.0 license |

## Experiment with small and large language models on AKS

Kubernetes AI Toolchain Operator (KAITO) is an open-source operator that automates small and large language model deployments in Kubernetes clusters. The KAITO add-on for AKS simplifies onboarding and reduces the time-to-inference for open-source models on your AKS clusters. The add-on automatically provisions right-sized GPU nodes and sets up the associated inference server as an endpoint server to your chosen model.

For more information, see [Deploy an AI model on AKS with the AI toolchain operator](ai-toolchain-operator). To get started with a range of supported small and large language models for your inference workflows, see the [KAITO model GitHub repository](https://kaito-project.github.io/kaito/docs/presets).

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## AKS platform guidance for production AI and machine learning workloads

For most production AI and machine learning workloads, use AKS Automatic as your default starting point.

AKS Automatic helps reduce operational overhead with:

- Production-ready default cluster configuration.
- Built-in node management and scaling behavior.
- Built-in security and policy safeguards.
- Automatic patching and upgrades.
- Pod readiness and uptime SLA coverage.

Use AKS Standard when your workload requires advanced cluster customization beyond default AKS Automatic settings.

For more information, see [Introduction to Azure Kubernetes Service (AKS) Automatic](intro-aks-automatic).