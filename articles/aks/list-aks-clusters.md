---
layout: Conceptual
title: List running Azure Kubernetes Service (AKS) clusters in an Azure subscription - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/list-aks-clusters
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
description: Learn how to list the running AKS clusters in an Azure subscription.
ms.topic: how-to
ms.date: 2026-08-12T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ai-usage: ai-assisted
ms.custom: aeo-round-2
locale: en-us
document_id: ecf31d89-ed7b-a04e-50a6-88813b3ebbb9
document_version_independent_id: eb50aa98-2dee-10ba-0fae-d9ca8b781575
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/list-aks-clusters.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/list-aks-clusters
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/list-aks-clusters.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: b906b212-0c3f-9835-54ab-09da6c310b83
---

# List running Azure Kubernetes Service (AKS) clusters in an Azure subscription - Azure Kubernetes Service | Microsoft Learn

You can list Azure Kubernetes Service (AKS) clusters in a subscription by using the Azure portal, Azure CLI, or the AKS REST API. Use Azure CLI or REST API results to identify which clusters are running.

## Before you begin

- An Azure account with access to the subscription that contains the AKS clusters and permission to read the cluster resources.
- The latest version of Azure CLI. For more information, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli) or [Update Azure CLI](/en-us/cli/azure/update-azure-cli). Azure CLI is preinstalled in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview).
- A [Microsoft Entra access token for Azure Resource Manager (ARM)](/en-us/azure/azure-resource-manager/management/manage-resources-rest) to call the REST API directly.

## Understand AKS cluster states

AKS cluster details include both a power state and a provisioning state:

- The `powerState.code` property indicates whether the cluster is `Running` or `Stopped`.
- The `provisioningState` property indicates the status of the latest Azure resource operation, such as `Succeeded`, `Creating`, `Starting`, or `Stopping`.

To determine whether a cluster is currently running, use `powerState.code`. A `provisioningState` value of `Succeeded` doesn't indicate whether the cluster is running because a stopped cluster can also have a successful provisioning state.

## List AKS clusters in the Azure portal

1. Sign in to the Azure portal.
2. In the portal search box, enter **Kubernetes services**, and then select **Kubernetes services**.
3. Select the subscription that contains your AKS clusters. You can also filter the list by resource group, location, or other available properties.
4. Select a cluster name to open its **Overview** page and view its configuration.

On the cluster page, select **Connect** to get connection instructions. To view resources in a running cluster, select **Kubernetes resources**. You need permissions for the AKS cluster, the Kubernetes API, and the Kubernetes objects. For more information, see [Access Kubernetes resources by using the Azure portal](kubernetes-portal).

The portal procedure lists and opens clusters. To determine the power state of clusters consistently across a subscription, use the Azure CLI or REST API method in this article and check `powerState.code`.

## List AKS clusters by using Azure CLI

1. Sign in to Azure.

    ```azurecli
    az login
    ```
2. If you have access to multiple subscriptions, set the subscription that contains the AKS clusters.

    ```azurecli
    az account set --subscription <subscription-id>
    ```
3. List the AKS clusters in the selected subscription. The following command displays each cluster's name, resource group, location, power state, and provisioning state:

    ```azurecli
    az aks list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location, PowerState:powerState.code, ProvisioningState:provisioningState}" --output table
    ```

    The output resembles the following example:

    ```output
    Name          ResourceGroup    Location    PowerState    ProvisioningState
    ------------  ---------------  ----------  ------------  -------------------
    aks-prod      rg-aks-prod      eastus      Running       Succeeded
    aks-dev       rg-aks-dev       westus2     Stopped       Succeeded
    ```

    To list clusters in a specific resource group, add the `--resource-group` parameter.

    ```azurecli
    az aks list --resource-group <resource-group-name> --query "[].{Name:name, PowerState:powerState.code}" --output table
    ```
4. To list only running clusters, filter on `powerState.code`.

    ```azurecli
    az aks list --query "[?powerState.code=='Running'].{Name:name, ResourceGroup:resourceGroup, Location:location}" --output table
    ```

For more information about the command and its output options, see the [`az aks list`](/en-us/cli/azure/aks#az-aks-list) reference.

## List AKS clusters by using the REST API

Use the [Managed Clusters - List](/en-us/rest/api/aks/managed-clusters/list) operation to get AKS clusters in a subscription. Send the following request, replacing `<subscription-id>` with your Azure subscription ID:

```http
GET https://management.azure.com/subscriptions/<subscription-id>/providers/Microsoft.ContainerService/managedClusters?api-version=2025-09-01
Authorization: Bearer <access-token>
```

The response contains a `value` array of AKS cluster resources. When `properties.powerState.code` is present, its value indicates whether the cluster is `Running` or `Stopped`. If `powerState` is missing or null, treat the cluster's power state as unknown; don't infer it from `provisioningState`. If the response includes `nextLink`, send a GET request to that URL to retrieve the next page of results.

Important

Azure exposes Kubernetes cluster resources for multiple services. The Azure Operator Nexus Network Cloud operation uses the `Microsoft.NetworkCloud/kubernetesClusters` resource type and doesn't list AKS clusters. To list AKS clusters, use the `Microsoft.ContainerService/managedClusters` operation shown in this article.