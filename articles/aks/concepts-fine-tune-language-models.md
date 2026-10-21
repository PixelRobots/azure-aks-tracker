---
layout: Conceptual
title: Concepts - Fine-tuning language models for AI and machine learning workflows - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-fine-tune-language-models
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
description: Learn about how you can customize language models to use in your AI and machine learning workflows on Azure Kubernetes Service (AKS).
ms.topic: concept-article
ms.custom: aks-ai-ml
ms.date: 2026-09-12T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: b8d390a0-ccdd-5c60-6a15-7c7de9fca3e2
document_version_independent_id: e985ca9d-2ec5-6529-e05c-cc1062c5831d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-fine-tune-language-models.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-fine-tune-language-models
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-fine-tune-language-models.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c6f99e62-1cf6-4b71-af9b-649b05f80cce
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/d6f38669-3d05-40f2-afd8-e49f7dd20884
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/3f56b378-07a9-4fa1-afe8-9889fdc77628
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/55265cca-de9b-48dc-a77a-9047cc39a575
platformId: 7231154f-2ece-ed94-98f5-266ca5a68648
---

# Concepts - Fine-tuning language models for AI and machine learning workflows - Azure Kubernetes Service | Microsoft Learn

In this article, you learn about fine-tuning [language models](concepts-ai-ml-language-models), including some common methods and how applying the tuning results can improve the performance of your AI and machine learning workflows on Azure Kubernetes Service (AKS).

## Pre-trained language models

*Pre-trained language models (PLMs)* offer an accessible way to get started with AI inferencing and are widely used in natural language processing (NLP). PLMs are trained on large-scale text corpora from the internet using deep neural networks and can be fine-tuned on smaller datasets for specific tasks. These models typically consist of billions of parameters, or *weights*, that are learned during the pre-training process.

PLMs can learn universal language representations that capture the statistical properties of natural language, such as the probability of words or sequences of words occurring in a given context. These representations can be transferred to downstream tasks, such as text classification, named entity recognition, and question answering, by fine-tuning the model on task-specific datasets.

### Pros and cons

The following table lists some pros and cons of using PLMs in your AI and machine learning workflows:

| Pros | Cons |
| --- | --- |
| • Get started quickly with deployment in your machine learning lifecycle.  • Avoid heavy compute costs associated with model training.  • Reduces the need to store large, labeled datasets. | • Might provide generalized or outdated responses based on pre-training data sources.  • Might not be suitable for all tasks or domains.  • Performance can vary depending on inferencing context. |

## Fine-tuning methods

### Parameter efficient fine-tuning

*Parameter efficient fine-tuning (PEFT)* is a method for fine-tuning PLMs on relatively small datasets with limited compute resources. PEFT uses a combination of techniques, like additive and selective methods to update weights, to improve the performance of the model on specific tasks. PEFT requires minimal compute resources and flexible quantities of data, making it suitable for low-resource settings. This method retains most of the weights of the original pre-trained model and updates the remaining weights to fit context-specific, labeled data.

### Low rank adaptation

*Low rank adaptation (LoRA)* is a PEFT method commonly used to customize large language models for new tasks. This method tracks changes to model weights and efficiently stores smaller weight matrices that represent only the model's trainable parameters, reducing memory usage and the compute power needed for fine-tuning. LoRA creates fine-tuning results, known as *adapter layers*, that can be temporarily stored and pulled into the model's architecture for new inferencing jobs.

*Quantized low rank adaptation (QLoRA)* is an extension of LoRA that further reduces memory usage by introducing quantization to the adapter layers. For more information, see [Making LLMs even more accessible with bitsandbites, 4-bit quantization, and QLoRA](https://huggingface.co/blog/4bit-transformers-bitsandbytes#:%7E:text=We%20present%20QLoRA%2C%20an%20efficient%20finetuning%20approach%20that,pretrained%20language%20model%20into%20Low%20Rank%20Adapters%7E%20%28LoRA%29.).

## Experiment with fine-tuning language models on AKS

Kubernetes AI Toolchain Operator (KAITO) is an open-source operator that automates small and large language model deployments in Kubernetes clusters. The AI toolchain operator add-on leverages KAITO to simplify onboarding, save on infrastructure costs, and reduce the time-to-inference for open-source models on an AKS cluster. The add-on automatically provisions right-sized GPU nodes and sets up the associated inference server as an endpoint server to your chosen model.

With KAITO version 0.3.0 or later, you can efficiently fine-tune supported MIT and Apache 2.0 licensed models with the following features:

- Store your retraining data as a container image in a private container registry.
- Host the new adapter layer image in a private container registry.
- Efficiently pull the image for inferencing with adapter layers in new scenarios.

For guidance on getting started with fine-tuning on KAITO, see the [Kaito Tuning Workspace API documentation](https://kaito-project.github.io/kaito/docs/tuning). To learn more about deploying language models with KAITO in your AKS clusters, see the [KAITO model GitHub repository](https://kaito-project.github.io/kaito/docs/presets).

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).