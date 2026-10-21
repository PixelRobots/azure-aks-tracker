---
layout: Conceptual
title: Troubleshoot the ServicePrincipalValidationClientError error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/serviceprincipalvalidationclienterror-error
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Troubleshoot the ServicePrincipalValidationClientError error in AKS. Learn how to reset or replace a service principal to successfully deploy your cluster.
ms.date: 2024-10-23T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, erbookbi, momajed, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: b88c028d-480d-51dc-b900-59e49208f89b
document_version_independent_id: b88c028d-480d-51dc-b900-59e49208f89b
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/serviceprincipalvalidationclienterror-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/serviceprincipalvalidationclienterror-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/serviceprincipalvalidationclienterror-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 45be94ed-af4a-ba58-bf2f-87f6abbfd291
---

# Troubleshoot the ServicePrincipalValidationClientError error code - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `ServicePrincipalValidationClientError` error that might occur if you try to create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli), version 2.0.59 or a later version. If Azure CLI is already installed, you can find the version number by running `az --version`.

## Symptoms

When you try to deploy an AKS cluster, you receive the following error message:

> 
> adal: Refresh request failed. Status Code = '401'.
> 
> Response body: {
> 
> "error": "invalid\_client",
> 
> "error\_description": "AADSTS7000215: **Invalid client secret provided. Ensure the secret being sent in the request is the client secret value, not the client secret ID, for a secret added to app '123456789-1234-1234-1234-1234567890987'.\r\n**
> 
> Trace ID: 12345\r\n
> 
> Correlation ID: 6789\r\n
> 
> Timestamp: 2022-02-03 03:07:11Z",
> 
> "error\_codes": [7000215],
> 
> "timestamp": "2022-02-03 03:07:11Z",
> 
> "trace\_id": "12345",
> 
> "correlation\_id": "6789",
> 
> "error\_uri": "https://login.microsoftonline.com/error?code=7000215"
> 
> } Endpoint https://login.microsoftonline.com/123456787/oauth2/token?api-version=1.0

## Cause

The secret that's provided for the highlighted service principal isn't valid.

## Solution 1: Reset the service principal secret in AKS

To resolve this issue, reset the service principal secret by using one of the following methods:

- Reset the service principal's credential by running the [az ad sp credential reset](/en-us/cli/azure/ad/sp/credential#az-ad-sp-credential-reset) command:

    ```azurecli
    az ad sp credential reset --name "01234567-89ab-cdef-0123-456789abcdef" --query password --output tsv
    ```
- Specify the expiration date by running the following command:

    ```azurecli
    az ad sp credential reset --name <service-principal-name> --credential-description "New secret for AKS" --years 1
    ```

The preceding command resets the secret and displays it as output. Then, you can specify the new secret when you try to create the new cluster again.

For failed operations in an existing cluster, ensure that you update your AKS cluster with the new secret:

```azurecli
az aks update-credentials --resource-group <resource-group> --name <aks-cluster> --reset-service-principal --client-secret <new-client-secret>
```

## Solution 2: Create a new service principal for AKS

You can create a new service principal and get the secret that's associated with it by running the [az ad sp create-for-rbac](/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac) command:

```azurecli
az ad sp create-for-rbac --role Contributor
```

The output of the command should resemble the following JSON string:

```json
{
  "appId": "00001111-aaaa-2222-bbbb-3333cccc4444",
  "name": "23456789-abcd-ef01-2345-6789abcdef01",
  "password": "3456789a-bcde-f012-3456-789abcdef012",
  "tenant": "456789ab-cdef-0123-4567-89abcdef0123"
}
```

Note the `appId` and `password` values that are generated. After you get these values, you can rerun the cluster creation command for the new service principal and secret.

To update your AKS cluster with the new service principal's credential, run the following command:

```azurecli
az aks update-credentials --resource-group <resource-group> --name <aks-cluster> --service-principal <new-client-id> --client-secret <new-client-secret>
```

## More information

- [General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)