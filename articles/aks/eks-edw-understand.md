---
layout: Conceptual
title: Understand platform differences for the event-driven workflow (EDW) workload - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/eks-edw-understand
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
description: Learn about the key differences between the AWS and Azure platforms related to the EDW scaling workload.
ms.topic: how-to
ms.date: 2024-06-20T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: aks-migration
locale: en-us
document_id: 1ae21d75-0218-bfd5-2219-eb676ca140c8
document_version_independent_id: da5f0954-0bf9-4236-626f-f5e5bd85b1b4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/eks-edw-understand.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/eks-edw-understand
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/eks-edw-understand.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 33bf1092-39b1-07ee-3a1f-b8314f423a1c
---

# Understand platform differences for the event-driven workflow (EDW) workload - Azure Kubernetes Service | Microsoft Learn

Before you replicate the EDW workload in Azure, ensure you have a solid understanding of the operational differences between the AWS and Azure platforms.

This article walks through some of the key concepts for this workload and provides links to resources for more information.

## Identity and access management

The AWS EDW workload uses an AWS Identity and Access Management (IAM) role that is assumed by the EKS service. This role is assigned to EKS pods to permit access to AWS resources, such as queues or databases, without the need to store credentials.

Azure implements [role-based access control (RBAC)](/en-us/azure/role-based-access-control/overview) differently than AWS. In Azure, role assignments are **associated with a security principal** (user, group, managed identity, or service principal), and that security principal is associated with a resource.

## Authentication between services

The AWS EDW workload uses service communication to connect with a queue and a database. AWS EKS uses `AssumeRole`, a feature of IAM, to acquire temporary security credentials to access AWS users, applications, or services. This implementation allows services to assume an IAM role that grants specific access, providing secure and limited permissions between services.

For Amazon Simple Queue Service (SQS) and Amazon DynamoDB database access using service communication, the AWS workflow uses `AssumeRole` with EKS, which is an implementation of Kubernetes [service account token volume projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#serviceaccount-token-volume-projection). In the EKS EDW workload, a configuration allows a Kubernetes service account to assume an AWS Identity and Access Management (IAM) role. Pods that are configured to use the service account can then access any AWS service that the role has permissions to access. In the EDW workload, two IAM policies are defined to grant permissions to access Amazon DynamoDB and Amazon SQS.

With AKS, you can use [Microsoft Entra Managed Identity](/en-us/entra/identity/managed-identities-azure-resources/overview) with [Microsoft Entra Workload ID](/en-us/azure/architecture/aws-professional/eks-to-aks/workload-identity#microsoft-entra-workload-id-for-kubernetes).

A [user-assigned managed identity](/en-us/azure/templates/microsoft.managedidentity/userassignedidentities?pivots=deployment-language-bicep) is created and granted access to an Azure Storage Table by assigning it the **Storage Table Data Contributor** role. The managed identity is also granted access to an Azure Storage Queue by assigning it the **Storage Queue Data Contributor** role. These role assignments are scoped to specific resources, allowing the managed identity to read messages in a specific Azure Storage Queue and write them to a specific Azure Storage Table. The managed identity is then mapped to a Kubernetes workload identity that will be associated with the identity of the pods where the app containers are deployed. For more information, see [Use Microsoft Entra Workload ID with AKS](workload-identity-overview#how-it-works).

On the client side, the Python Azure SDKs support a transparent means of leveraging the context of a workload identity, which eliminates the need for the developer to perform explicit authentication. Code running in a namespace/pod on AKS with an established workload identity can authenticate to external services using the mapped managed identity.

## Resources

The following resources can help you learn more about the differences between AWS and Azure for the technologies used in the EDW workload:

| **Topic** | **AWS to Azure resource** |
| --- | --- |
| Services | [AWS to Azure services comparison](/en-us/azure/architecture/aws-professional/services) |
| Identity | [Mapping AWS IAM concepts to similar ones in Azure](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/mapping-aws-iam-concepts-to-similar-ones-in-azure/ba-p/3612216) |
| Accounts | [Azure AWS accounts and subscriptions](/en-us/azure/architecture/aws-professional/accounts) |
| Resource management | [Resource containers](/en-us/azure/architecture/aws-professional/resources) |
| Messaging | [Amazon SQS to Azure Queue Storage](/en-us/azure/architecture/aws-professional/messaging#simple-queue-service) |
| Kubernetes | [AKS for Amazon EKS professionals](/en-us/azure/architecture/aws-professional/eks-to-aks/) |