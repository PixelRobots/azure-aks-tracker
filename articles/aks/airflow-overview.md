---
layout: Conceptual
title: Deploy Apache Airflow on AKS with Helm - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/airflow-overview
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
description: Learn the high-level architecture of deploying production-ready Apache Airflow on Azure Kubernetes Service (AKS) and the available Airflow executors.
ms.topic: overview
ms.date: 2025-07-14T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: stateful-workloads, aks-data-messaging
locale: en-us
document_id: a56f359f-2d85-6343-a895-29f023d39228
document_version_independent_id: 2b7d72e2-64d4-f467-c07f-613cb3d24830
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/airflow-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/airflow-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/airflow-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 88926db3-7ae7-393c-9898-0081052209ea
---

# Deploy Apache Airflow on AKS with Helm - Azure Kubernetes Service | Microsoft Learn

In this guide, you deploy Apache Airflow on Azure Kubernetes Service (AKS) using Helm. You learn how to set up an AKS cluster, install Helm, deploy Airflow using the Helm chart, and explore the Airflow UI. This article provides a high-level overview of the architecture and components involved in deploying production-ready Airflow on AKS.

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## What is Apache Airflow?

[Apache Airflow](https://airflow.apache.org/) is an open-source platform built for developing, scheduling, and monitoring batch-oriented workflows. With its flexible Python framework, Airflow allows you to design workflows that integrate seamlessly with nearly any technology. In Airflow, you must define Python workflows, represented by Directed Acyclic Graph (DAG). You can deploy Airflow anywhere, and after deploying, you can access Airflow UI and set up workflows.

## Airflow architecture

At a high level, Airflow includes:

- A metadata database that tracks the state of DAGs, task instances, XComs, and more.
- A web server providing the Airflow UI for monitoring and management.
- A scheduler responsible for triggering DAGs and task instances.
- Executors that handle the execution of task instances.
- Workers that perform the tasks.
- Other components like the Command Line Interface (CLI).

![Architecture diagram of Apache Airflow on AKS.](media/airflow-overview/airflow-architecture.png)

## Airflow distributed architecture for production

Airflow’s modular, distributed architecture offers several key advantages for production workloads:

- **Separation of concerns**: Each component has a distinct role, keeping the system simple and maintainable. The scheduler manages DAGs and task scheduling, while workers execute tasks, ensuring that each part stays focused on its specific function.
- **Scalability**: As workloads grow, the architecture allows for easy scaling. You can run multiple schedulers or workers concurrently and leverage a hosted database for automatic scaling to accommodate increased demand.
- **Reliability**: Because components are decoupled, the failure of a single scheduler or worker doesn’t lead to a system-wide outage. The centralized metadata database ensures consistency and continuity across the entire system.
- **Extensibility**: The architecture is flexible, allowing components like the executor or queueing service to be swapped out and customized as needed.

This design provides a robust foundation for scaling, reliability, and flexibility in managing complex data pipelines.

### Airflow executors

A very important design decision when making Airflow production-ready is choosing the correct executor. When a task is ready to run, the executor is responsible for managing its execution. Executors interact with a pool of workers that carry out the tasks. The most commonly used executors are:

- **LocalExecutor**: Runs task instances in parallel on the host system. This executor is ideal for testing, but offers limited scalability for larger workloads.
- **CeleryExecutor**: Distributes tasks across multiple machines using a Celery pool, providing horizontal scalability by running workers on different nodes.
- **KubernetesExecutor**: Tailored for Airflow deployments in Kubernetes, this executor dynamically launches worker Pods within the Kubernetes cluster. It offers excellent scalability and ensures strong resource isolation.

As we transition Airflow to production, scaling workers becomes essential, making KubernetesExecutor the best fit for our needs. For local testing, however, LocalExecutor is the simplest option.