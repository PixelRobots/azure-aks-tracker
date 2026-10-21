---
layout: Conceptual
title: Migrate Amazon Web Services (AWS) web application to Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/eks-web-refactor
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
description: Step-by-step guide on updating and migrating the AWS web application to Azure Kubernetes Service (AKS).
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.date: 2024-10-31T00:00:00.0000000Z
ms.custom: aks-migration - migration - aws-to-azure - eks-to-aks
locale: en-us
document_id: 1aa3ee41-25a7-2a12-0371-5d88146ce639
document_version_independent_id: 3475a381-aafb-2d93-22ae-fe8d0da03204
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/eks-web-refactor.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/eks-web-refactor
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/eks-web-refactor.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 18d6a5ad-87d5-78cf-f1c8-a330bae32de9
---

# Migrate Amazon Web Services (AWS) web application to Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article outlines the steps necessary for migrating the Yelb application from AWS EKS to AKS. Please note that the [Yelb](https://github.com/mreferre/yelb/) application is self-contained and doesn't rely on external services, so it can be migrated from AWS to Azure without code changes.

## Migrating from AWS IAM to Azure RBAC

If the web application on AWS uses an [AWS Identity and Access Management (IAM)](https://aws.amazon.com/iam/) role for accessing managed services, you need to assign the role to the [EKS](https://docs.aws.amazon.com/en_us/eks/latest/userguide/what-is-eks.html) pods to grant access to AWS resources. In Azure, you can assign a [role](/en-us/azure/role-based-access-control/role-assignments-portal) to users, groups, service principals, or managed identities at a specific scope: management group, subscription, resource group, or resource. This allows you to grant specific permissions to the workload identity on a Microsoft Entra protected resource.

You can configure Azure RBAC using the following steps:

1. Create a [user-assigned managed identity](/en-us/entra/identity/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp) and [Kubernetes service account](https://kubernetes.io/docs/concepts/security/service-accounts/) for the workload.
2. Assign the necessary [roles](/en-us/azure/role-based-access-control/role-assignments-portal) to the managed identity to let the AKS-hosted workload access the required Microsoft Entra protected resources.
3. Enable the OpenID Connect (OIDC) issuer and Microsoft Entra Workload ID on your AKS cluster. For detailed instructions, see [Deploy and configure workload identity on an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/workload-identity-deploy-cluster).
4. Create a token federation for the managed identity with the [Kubernetes service account](https://kubernetes.io/docs/concepts/security/service-accounts/) used by the workload on AKS.

[Microsoft Entra Workload ID](/en-us/azure/active-directory/develop/workload-identities-overview) uses [Service Account Token Volume Projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#serviceaccount-token-volume-projection), specifically a service account, to enable pods to use a Kubernetes identity. A Kubernetes token is issued and [OIDC federation](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens) enables Kubernetes applications to securely access Azure resources with Microsoft Entra ID based on annotated service accounts.

Microsoft Entra Workload ID works well with the [Azure Identity client libraries](/en-us/azure/aks/workload-identity-overview?tabs=dotnet#azure-identity-client-libraries) or the [Microsoft Authentication Library](/en-us/azure/active-directory/develop/msal-overview), along with [application registration](/en-us/azure/active-directory/develop/application-model#register-an-application). These libraries enable your workload to authenticate seamlessly and access Azure cloud resources. For more information, see [Use Microsoft Entra Workload ID with Azure Kubernetes Service (AKS)](/en-us/azure/aks/workload-identity-overview?tabs=dotnet).