---
layout: Conceptual
title: Rearchitect the event-driven workflow (EDW) workload for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/eks-edw-rearchitect
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
description: Learn about architectural differences for replicating the AWS EKS scaling with KEDA and Karpenter event-driven workflow (EDW) workload in AKS.
ms.topic: how-to
ms.date: 2024-06-20T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: aks-migration
locale: en-us
document_id: 23655b53-f9f3-8bb2-d688-3a48c69231c2
document_version_independent_id: 64300065-888d-db0b-3dda-6e1eb3f636c2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/eks-edw-rearchitect.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/eks-edw-rearchitect
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/eks-edw-rearchitect.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/54918a83-0404-4863-9c91-715186c1f582
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/b26f5f7a-0913-4a95-8337-ed7543902f2d
platformId: 3e6218e5-da11-b13c-7c58-5b0440aced3b
---

# Rearchitect the event-driven workflow (EDW) workload for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Now that you understand some key platform differences between AWS and Azure relevant to this workload, let's take a look at the workflow architecture and we can change it to work on AKS.

## AWS workload architecture

The AWS workload is a basic example of the [competing consumers design pattern](/en-us/azure/architecture/patterns/competing-consumers). The AWS implementation is a reference architecture for managing scale and cost for event-driven workflows using [Kubernetes](https://kubernetes.io/), [Kubernetes Event-driven Autoscaling (KEDA)](https://keda.sh/), and [Karpenter](https://karpenter.sh/).

A producer app generates load through sending messages to a queue, and a consumer app running in a Kubernetes pod processes the messages and writes the results to a database. KEDA manages pod autoscaling through a declarative binding to the producer queue, and Karpenter manages node autoscaling with just enough compute to optimize for cost. Authentication to the queue and the database uses OAuth-based [service account token volume projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#serviceaccount-token-volume-projection).

The workload consists of an AWS EKS cluster to orchestrate consumers reading messages from an Amazon Simple Queue Service (SQS) and saving processed messages to an Amazon DynamoDB table. A producer app generates messages and queues them in the Amazon SQS queue. KEDA and Karpenter dynamically scale the number of EKS nodes and pods used for the consumers.

The following diagram represents the architecture of the EDW workload in AWS:

![Architecture diagram of the EDW workload in AWS.](media/eks-edw-rearchitect/aws-edw-architecture.png)

## Map AWS services to Azure services

To recreate the AWS workload in Azure with minimal changes, use an Azure equivalent for each AWS service and keep authentication methods similar to the original. This example doesn't require the [advanced features](/en-us/azure/service-bus-messaging/service-bus-azure-and-service-bus-queues-compared-contrasted) of Azure Service Bus or Azure Event Hubs. Instead, you can use [Azure Queue Storage](/en-us/azure/storage/queues/storage-queues-introduction) to queue up work, and [Azure Table storage](/en-us/azure/storage/tables/table-storage-overview) to store results.

The following table summarizes the service mapping:

| **Service mapping** | **AWS service** | **Azure service** |
| --- | --- | --- |
| Queuing | Simple Queue Service | [Azure Queue Storage](/en-us/azure/storage/queues/storage-queues-introduction) |
| Persistence | DynamoDB (No SQL) | [Azure Table storage](/en-us/azure/storage/tables/table-storage-overview) |
| Orchestration | Elastic Kubernetes Service (EKS) | [Azure Kubernetes Service (AKS)](what-is-aks) |
| Identity | AWS IAM | [Microsoft Entra](/en-us/entra/fundamentals/whatis) |

### Azure workload architecture

The following diagram represents the architecture of the Azure EDW workload using the AWS to Azure service mapping:

![Architecture diagram of the EDW workload in Azure.](media/eks-edw-rearchitect/azure-edw-architecture.png)

## Compute options

Depending on cost considerations and resilience to possible node eviction, you can choose from different types of compute.

In AWS, you can choose between on-demand compute (more expensive but no eviction risk) or Spot instances (cheaper but with eviction risk). In AKS, you can choose an [on-demand node pool](create-node-pools) or a [Spot node pool](spot-node-pool) depending on your workload's needs.