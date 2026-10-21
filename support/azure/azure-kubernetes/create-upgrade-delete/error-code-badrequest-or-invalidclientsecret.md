---
layout: Conceptual
title: AADSTS7000222 - BadRequest or InvalidClientSecret error - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-badrequest-or-invalidclientsecret
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: axelgMS
ms.author: axelg
ms.topic: article
description: Learn how to troubleshoot the BadRequest or InvalidClientSecret error when you try to create or upgrade an Azure Kubernetes Service (AKS) cluster.
ms.date: 2026-07-20T00:00:00.0000000Z
ms.reviewer: mariusbutuc
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool), innovation-engine
locale: en-us
document_id: 0f7f24ab-419b-d191-731f-0366d1fc623a
document_version_independent_id: 0f7f24ab-419b-d191-731f-0366d1fc623a
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/error-code-badrequest-or-invalidclientsecret.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/error-code-badrequest-or-invalidclientsecret
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/error-code-badrequest-or-invalidclientsecret.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: c158a9ed-860d-c942-3fef-632138c26521
---

# AADSTS7000222 - BadRequest or InvalidClientSecret error - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `AADSTS7000222` error (`BadRequest` or `InvalidClientSecret`) that occurs when you try to create or upgrade a Microsoft Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli)

## Symptoms

When you try to create or upgrade an AKS cluster, you receive one of the following error messages.

| Error code | Message |
| --- | --- |
| `BadRequest` | **The credentials in ServicePrincipalProfile were invalid.** Please see https://aka.ms/aks-sp-help for more details. (Details: adal: Refresh request failed. Status Code = '401'. Response body: {"error": "invalid\_client", "error\_description": "**AADSTS7000222: The provided client secret keys for app '&lt;application-id&gt;' are expired.** Visit the Azure portal to create new keys for your app: https://aka.ms/NewClientSecret, or consider using certificate credentials for added security: https://aka.ms/certCreds." |
| `InvalidClientSecret` | **Customer auth is not valid for tenant: &lt;tenant-id&gt;**: adal: Refresh request failed. Status Code = '401'. Response body: {"error": "invalid\_client", "error\_description": "**AADSTS7000222: The provided client secret keys for app '&lt;application-id&gt;' are expired.** Visit the Azure portal to create new keys for your app: https://aka.ms/NewClientSecret, or consider using certificate credentials for added security: https://aka.ms/certCreds." |

## Cause

The issue that generates this service principal alert usually occurs for one of the following reasons:

- The client secret expired.
- Incorrect credentials were provided.
- The service principal doesn't exist within the Microsoft Entra ID tenant of the subscription.

#### Verify the cause

Use the following commands to retrieve the service principal profile for your AKS cluster and check the expiration date of the service principal. Make sure to set the appropriate variables for your AKS resource group and cluster name.

```azurecli
SP_ID=$(az aks show --resource-group $RESOURCE_GROUP_NAME \
    --name $AKS_CLUSTER_NAME \
    --query servicePrincipalProfile.clientId \
    --output tsv)
az ad app credential list --id "$SP_ID"
```

Alternatively, you can verify that the service principal name and secret are correct and aren't expired. To do this, follow these steps:

1. In the [Azure portal](https://portal.azure.com), search for and select **Microsoft Entra ID**.
2. In the navigation pane of Microsoft Entra ID, select **App registrations**.
3. On the **Owned applications** tab, select the affected application.
4. Find the service principal name and secret information, and verify that the information is correct and current.

## Solution

1. In the [Update or rotate the credentials for an AKS cluster](/en-us/azure/aks/update-credentials) article, follow the instructions in one of the following article sections, as appropriate:

    - [Reset the existing service principal credentials](/en-us/azure/aks/update-credentials#reset-the-existing-service-principal-credentials)
    - [Create a new service principal](/en-us/azure/aks/update-credentials#create-a-new-service-principal)
2. Using your new service principal credentials, follow the instructions in the [Update AKS cluster with service principal credentials](/en-us/azure/aks/update-credentials#update-aks-cluster-with-service-principal-credentials) section of that article.

## More information

- [Use a service principal with Azure Kubernetes Service (AKS)](/en-us/azure/aks/kubernetes-service-principal) (especially the [Troubleshoot](/en-us/azure/aks/kubernetes-service-principal#troubleshoot) section)