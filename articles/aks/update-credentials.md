---
layout: Conceptual
title: Update or rotate the credentials for an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/update-credentials
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
description: Learn how update or rotate the service principal or Microsoft Entra Application credentials for an Azure Kubernetes Service (AKS) cluster.
ms.author: schaffererin
author: schaffererin
ms.topic: how-to
ms.subservice: aks-security
ms.custom: devx-track-azurecli
ms.date: 2023-03-01T00:00:00.0000000Z
locale: en-us
document_id: f7ccbce4-aea5-a6eb-9e94-6362a133ed36
document_version_independent_id: 0f0bc51d-cf2c-b450-5807-0bb721b939c1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/update-credentials.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/update-credentials
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/update-credentials.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
platformId: 54a89aa6-d590-c93b-db04-0ea72880d795
---

# Update or rotate the credentials for an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

AKS clusters created with a service principal have a one-year expiration time. As you near the expiration date, you can reset the credentials to extend the service principal for an additional period of time. You might also want to update, or rotate, the credentials as part of a defined security policy. AKS clusters [integrated with Microsoft Entra ID](entra-id-control-plane-authentication) as an authentication provider have two more identities: the Microsoft Entra Server App and the Microsoft Entra Client App. This article details how to update the service principal and Microsoft Entra credentials for an AKS cluster.

Note

Alternatively, you can use a managed identity for permissions instead of a service principal. Managed identities don't require updates or rotations. For more information, see [Use managed identities](use-managed-identity).

## Before you begin

You need the Azure CLI version 2.0.65 or later installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Update or create a new service principal for your AKS cluster

When you want to update the credentials for an AKS cluster, you can choose to either:

- Update the credentials for the existing service principal.
- Create a new service principal and update the cluster to use these new credentials.

Warning

If you choose to create a *new* service principal, wait around 30 minutes for the service principal permission to propagate across all regions. Updating a large AKS cluster to use these credentials can take a long time to complete.

### Check the expiration date of your service principal

To check the expiration date of your service principal, use the [`az ad app credential list`](/en-us/cli/azure/ad/app/credential#az-ad-app-credential-list) command. The following example gets the service principal ID for the `$CLUSTER_NAME` cluster in the `$RESOURCE_GROUP_NAME` resource group using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command. The service principal ID is set as a variable named *SP\_ID*.

```azurecli
SP_ID=$(az aks show --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME \
    --query servicePrincipalProfile.clientId -o tsv)
az ad app credential list --id "$SP_ID" --query "[].endDateTime" -o tsv
```

### Reset the existing service principal credentials

To update the credentials for an existing service principal, get the service principal ID of your cluster using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command. The following example gets the ID for the `$CLUSTER_NAME` cluster in the `$RESOURCE_GROUP_NAME` resource group. The variable named *SP\_ID* stores the service principal ID used in the next step. These commands use the Bash command language.

Warning

When you reset your cluster credentials on an AKS cluster that uses Azure Virtual Machine Scale Sets, a [node image upgrade](node-image-upgrade) is performed to update your nodes with the new credential information.

```azurecli
SP_ID=$(az aks show --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME \
    --query servicePrincipalProfile.clientId -o tsv)
```

Use the variable *SP\_ID* containing the service principal ID to reset the credentials using the [`az ad app credential reset`](/en-us/cli/azure/ad/app/credential#az-ad-app-credential-reset) command. The following example enables the Azure platform to generate a new secure secret for the service principal and store it as a variable named *SP\_SECRET*.

```azurecli
SP_SECRET=$(az ad app credential reset --id "$SP_ID" --query password -o tsv)
```

Next, you update AKS cluster with service principal credentials. This step is necessary to update the service principal on your AKS cluster.

### Create a new service principal

Note

If you updated the existing service principal credentials in the previous section, skip this section and instead update the AKS cluster with service principal credentials.

To create a service principal and update the AKS cluster to use the new credential, use the [`az ad sp create-for-rbac`](/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac) command.

```azurecli
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/$SUBSCRIPTION_ID
```

The output is similar to the following example output. Make a note of your own `appId` and `password` to use in the next step.

```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "name": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

Define variables for the service principal ID and client secret using your output from running the [`az ad sp create-for-rbac`](/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac) command. The *SP\_ID* is the *appId*, and the *SP\_SECRET* is your *password*.

```console
SP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
SP_SECRET=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Next, you update AKS cluster with the new service principal credential. This step is necessary to update the AKS cluster with the new service principal credential.

## Update AKS cluster with service principal credentials

Important

For large clusters, updating your AKS cluster with a new service principal can take a long time to complete. Consider reviewing and customizing the [node surge upgrade settings](upgrade-aks-cluster#customize-node-surge-upgrade) to minimize disruption during the update. For small and midsize clusters, it takes a several minutes for the new credentials to update in the cluster.

Update the AKS cluster with your new or existing credentials by running the [`az aks update-credentials`](/en-us/cli/azure/aks#az-aks-update-credentials) command.

```azurecli
az aks update-credentials \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $CLUSTER_NAME \
    --reset-service-principal \
    --service-principal "$SP_ID" \
    --client-secret "${SP_SECRET}"
```

## Update AKS cluster with new Microsoft Entra application credentials

You can create new Microsoft Entra server and client applications by following the [Microsoft Entra integration steps](entra-id-control-plane-authentication), or reset your existing Microsoft Entra applications following the same method as for service principal reset. After that, you need to update your cluster Microsoft Entra application credentials using the [`az aks update-credentials`](/en-us/cli/azure/aks#az-aks-update-credentials) command with the *--reset-aad* variables.

```azurecli
az aks update-credentials \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $CLUSTER_NAME \
    --reset-aad \
    --aad-server-app-id $SERVER_APPLICATION_ID \
    --aad-server-app-secret $SERVER_APPLICATION_SECRET \
    --aad-client-app-id $CLIENT_APPLICATION_ID
```