---
layout: Conceptual
title: Replicate an AWS EDW workload with KEDA and Karpenter in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/eks-edw-overview
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
description: Learn how to replicate an AWS EKS event-driven workflow (EDW) workload with KEDA and Karpenter in AKS.
ms.topic: how-to
ms.date: 2024-06-20T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: aks-migration
ms.collection:
- migration
- aws-to-azure
locale: en-us
document_id: 45d41fed-9235-5d85-3e21-45efc77bcd63
document_version_independent_id: 072134aa-d78c-e0ab-f1ea-d7665f8dc767
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/eks-edw-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/eks-edw-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/eks-edw-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 19c81b07-9b00-b35e-0e9c-9551f4c77d13
---

# Replicate an AWS EDW workload with KEDA and Karpenter in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to replicate an Amazon Web Services (AWS) Elastic Kubernetes Service (EKS) event-driven workflow (EDW) workload with [KEDA](https://keda.sh) and [Karpenter](https://karpenter.sh) in AKS.

This workload is an implementation of the [competing consumers](/en-us/azure/architecture/patterns/competing-consumers) pattern using a producer/consumer app that facilitates efficient data processing by separating data production from data consumption. You use KEDA to scale pods running consumer processing and Karpenter to autoscale Kubernetes nodes.

If you plan to migrate an AWS workload to Azure, see [Migrate compute from Amazon Web Services to Azure](/en-us/azure/migration/migrate-compute-from-aws), which includes [example migration scenarios](/en-us/azure/migration/migrate-compute-from-aws#migration-scenarios) that might align to your use case. For a more detailed understanding of the AWS workload, see [Scalable and Cost-Effective Event-Driven Workloads with KEDA and Karpenter on Amazon EKS](https://aws.amazon.com/blogs/containers/scalable-and-cost-effective-event-driven-workloads-with-keda-and-karpenter-on-amazon-eks/).

## Deployment process

1. [**Understand the conceptual differences**](eks-edw-understand): Start by reviewing the differences between AWS and AKS in terms of services, architecture, and deployment.
2. [**Rearchitect the workload**](eks-edw-rearchitect): Analyze the existing AWS workload architecture and identify the components or services that you need to redesign to fit AKS. You need to make changes to the workload infrastructure, application architecture, and deployment process.
3. [**Update the application code**](eks-edw-refactor): Ensure your code is compatible with Azure APIs, services, and authentication models.
4. [**Prepare for deployment**](eks-edw-prepare): Modify the AWS deployment process to use the Azure CLI.
5. [**Deploy the workload**](eks-edw-deploy): Deploy the replicated workload in AKS and test the workload to ensure that it functions as expected.

## Prerequisites

- An Azure account. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- The **Owner**[Azure built-in role](/en-us/azure/role-based-access-control/built-in-roles), or the **User Access Administrator** and **Contributor** built-in roles, on a subscription in your Azure account.
- [Azure CLI](/en-us/cli/azure/install-azure-cli) version 2.56 or later.
- [Azure Kubernetes Service (AKS) preview extension](draft#install-the-aks-preview-azure-cli-extension).
- [jq](https://jqlang.github.io/jq/) version 1.5 or later.
- [Python 3.12](https://www.python.org/downloads/) or later.
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) version 1.21.0 or later
- [Helm](https://helm.sh/docs/intro/install/) version 3.0.0 or later
- [Visual Studio Code](https://code.visualstudio.com/Download) or equivalent.

### Download the Azure application code

The **completed** application code for this workflow is available in our [GitHub repository](https://github.com/Azure-Samples/aks-event-driven-replicate-from-aws). Clone the repository to a directory called `aws-to-azure-edw-workshop` on your local machine by running the following command:

```bash
git clone https://github.com/Azure-Samples/aks-event-driven-replicate-from-aws ./aws-to-azure-edw-workshop
```

After you clone the repository, navigate to the `aws-to-azure-edw-workshop` directory and start Visual Studio Code by running the following commands:

```bash
cd aws-to-azure-edw-workshop
code .
```