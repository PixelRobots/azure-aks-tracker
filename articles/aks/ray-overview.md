---
layout: Conceptual
title: Run Ray AI workloads with Kueue on Azure Kubernetes Service (AKS) overview - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ray-overview
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
description: Learn how to run Ray AI workloads with Kueue admission control on Azure Kubernetes Service (AKS), including training, inference, and serving.
ms.topic: overview
ms.date: 2026-06-26T00:00:00.0000000Z
author: feiskyer
ms.author: peni
ms.custom: stateful-workloads
locale: en-us
document_id: 222a5fe8-b939-ffe4-3474-e39f5d07e12a
document_version_independent_id: 6124b0db-3429-b5b6-9b93-8a786d23f9fc
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ray-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/ray-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ray-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 71535d47-7d79-87a5-cb93-6e6f6b8c2dbe
---

# Run Ray AI workloads with Kueue on Azure Kubernetes Service (AKS) overview - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to run distributed AI workloads on Azure Kubernetes Service (AKS) using Ray for the compute runtime and Kueue for admission control. This solution covers the full lifecycle from infrastructure provisioning through training, batch inference, and online serving.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## What is Ray?

[Ray](https://docs.ray.io/en/latest/index.html) is an open-source framework for scaling AI and Python applications. It provides a unified runtime for distributed training, hyperparameter tuning, batch inference, and model serving, so you can scale workloads across multiple nodes without rewriting application logic.

Ray simplifies distributed computing by handling scheduling, fault tolerance, and resource management. The framework supports machine learning libraries like PyTorch, TensorFlow, and Hugging Face through integrations such as Ray Train, Ray Data, and Ray Serve. For more information, see the [Ray GitHub repository](https://github.com/ray-project/ray).

## What is KubeRay?

[KubeRay](https://docs.ray.io/en/latest/cluster/kubernetes/getting-started.html) is a Kubernetes operator that manages the lifecycle of Ray clusters. It provides custom resources - `RayJob` for batch workloads and `RayService` for persistent serving endpoints - that automate cluster creation, scaling, and teardown. For more information, see the [KubeRay GitHub repository](https://github.com/ray-project/kuberay).

For managed operator installation outside this Terraform workflow, see [Install the managed KubeRay extension on AKS (preview)](kuberay-overview).

## What is Kueue?

[Kueue](https://kueue.sigs.k8s.io/) is a Kubernetes-native job queueing controller that manages workload admission based on resource quotas. Instead of letting every submitted job consume resources immediately, Kueue gates admission against defined quotas - jobs that fit run, jobs that don't wait in line. For a detailed overview of Kueue concepts and configuration, see [Kueue overview on AKS](kueue-overview).

For managed installation and operation, see [Install the managed Kueue extension on AKS (preview)](kueue-overview).

## Solution architecture

This solution combines Kueue for admission control with KubeRay for Ray cluster lifecycle management on AKS. Terraform provisions the infrastructure, Helm installs the operators from Microsoft Container Registry (MCR), and workload identity provides secure access to Azure Blob Storage without stored credentials.

The deployment process consists of three modules:

- **Infrastructure** — Terraform provisions the AKS cluster with GPU node pools, installs KubeRay and Kueue operators via Helm, creates Azure Blob Storage, and configures workload identity.
- **Kueue queues** — Kubernetes manifests define ResourceFlavors (CPU and GPU node types), ClusterQueues (quotas and admission policies), and LocalQueues (namespace-scoped submission points).
- **Workloads** — RayJob and RayService manifests submit AI workloads that Kueue admits based on available quota.

Ray workloads start with `suspend: true`. Kueue evaluates quota availability and unsuspends admitted workloads, at which point KubeRay creates the Ray cluster and runs the job.

## Workload examples

| Example | Type | GPUs | Description |
| --- | --- | --- | --- |
| [Fine-tune Aurora weather model](ray-finetune-aurora) | RayJob | 1×A100 | LoRA fine-tune of the Microsoft Aurora weather foundation model |
| [Train an LLM](ray-train-llm) | RayJob | 4×A100 | Distributed Qwen2.5-7B LoRA fine-tune with LLaMA-Factory |
| [Run batch inference](ray-batch-inference) | RayJob | 1×A100 | vLLM offline inference with a trained LoRA adapter |
| [Serve a model online](ray-online-serving) | RayService | 1×GPU | Persistent HTTP endpoint with Ray Serve |