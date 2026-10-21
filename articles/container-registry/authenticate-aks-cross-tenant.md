---
layout: Conceptual
title: Cross-Tenant Authentication from AKS to ACR - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/authenticate-aks-cross-tenant
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Configure an AKS cluster's service principal with permissions to access your Azure container registry in a different Microsoft Entra tenant.
ms.topic: how-to
ms.date: 2026-01-07T00:00:00.0000000Z
locale: en-us
document_id: 2bb3308c-4f06-1de3-3ea5-c0f445d23c8e
document_version_independent_id: 440ce702-5525-b9ee-b189-f0b7181901c0
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/authenticate-aks-cross-tenant.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/authenticate-aks-cross-tenant
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/authenticate-aks-cross-tenant.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 41e9b2eb-59f9-3891-7915-7a7f9de75a33
---

# Cross-Tenant Authentication from AKS to ACR - Azure Container Registry | Microsoft Learn

If you have an Azure Kubernetes Service (AKS) cluster in one Microsoft Entra tenant, and an Azure container registry in a different tenant, you can configure cross-tenant authentication to enable the AKS cluster to pull images from the container registry. This article walks through the steps to enable cross-tenant authentication by using the AKS service principal credential to pull from the container registry.

In this article, we refer to the tenant containing the AKS cluster as **Tenant A**, and the tenant containing the Azure container registry as **Tenant B**.

The high-level steps to enable cross-tenant authentication are:

1. Create a new multitenant app (service principal) in **Tenant A**.
2. Provision the app in **Tenant B**.
3. Configure the service principal to pull from the registry in **Tenant B**.
4. Update the AKS cluster in **Tenant A** to authenticate by using the new service principal.

Note

When the cluster and the container registry are in different tenants, you can't use an AKS managed identity to attach the registry and authenticate.

## Prerequisites

The AKS cluster must be configured with [service principal authentication](/en-us/azure/aks/kubernetes-service-principal) in **Tenant A**.

You need at least the **Contributor** role for the AKS cluster's subscription. You also need the **Role Based Access Control Administrator** and **Container Registry Contributor and Data Access Configuration Administrator** roles in the container registry's subscription (or roles with an equivalent or greater level of access).

## Create a multitenant Microsoft Entra application

1. Sign in to the [Azure portal](https://portal.azure.com/) in **Tenant A**.
2. Search for and select **Microsoft Entra ID**.
3. In the service menu, under **Manage**, select **App registrations**.
4. Select **+ New registration**, and then complete the following steps:

    1. Enter a name for the application.
    2. In **Supported account types**, select **Accounts in any organizational directory**.
    3. In **Redirect URI**, select **Web** for **Platform** and enter `https://www.microsoft.com`.
    4. Select **Register**.
5. On the **Overview** page, take note of the **Application (client) ID**. You'll need this ID later.

    ![Service principal application ID](media/authenticate-aks-cross-tenant/service-principal-overview.png)
6. In the service menu, under **Manage**, select **Certificates & secrets**.
7. In the **Client secrets** section, select **+ New client secret**.
8. Enter a **Description** such as *Password*, and then select **Add**.
9. In **Client secrets**, take note of the value of the client secret. You'll use this value to update the AKS cluster's service principal.

## Provision the service principal in the ACR tenant

1. Edit the following link with the tenant ID for **Tenant B** and the application (client) ID of the multitenant app.

    ```console
    https://login.microsoftonline.com/<Tenant B ID>/oauth2/authorize?client_id=<Multitenant application ID>&response_type=code&redirect_uri=<redirect url>
    ```
2. Open the edited link with an admin account in **Tenant B**.
3. Select **Consent on behalf of your organization**, and then select **Accept**.

## Configure the service principal to pull from registry

In **Tenant B**, assign the correct role to the service principal, scoped to the target container registry:

- For [ABAC-enabled registries](container-registry-rbac-abac-repository-permissions), assign `Container Registry Repository Reader`.
- For non-ABAC registries, assign `AcrPull`.

You can use the [Azure portal](/en-us/azure/role-based-access-control/role-assignments-portal), [the Azure CLI](container-registry-auth-service-principal#use-an-existing-service-principal), or other tools to assign this role.

## Update the AKS cluster with the Microsoft Entra application secret

Use the multitenant app's application (client) ID and client secret to [update the AKS service principal credential](/en-us/azure/aks/update-credentials#update-aks-cluster-with-service-principal-credentials).

Updating the service principal can take several minutes to complete. After the update is finished, the AKS cluster in **Tenant A** can pull images from the Azure container registry in **Tenant B**.