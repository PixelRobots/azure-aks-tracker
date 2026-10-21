---
layout: Conceptual
title: Use Service Tags for API Server Authorized IP Ranges in Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/api-server-service-tags
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
description: Learn how to use service tags to specify authorized IP ranges for the API server in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2024-05-19T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ms.subservice: aks-security
locale: en-us
document_id: cd3806ed-b57e-2cd1-0764-80ade35d58af
document_version_independent_id: 4678f7d5-cf90-e0b2-36d8-db3947bf2538
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/api-server-service-tags.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/api-server-service-tags
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/api-server-service-tags.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 2801c8fd-fc43-2b73-2913-f64f996d7c67
---

# Use Service Tags for API Server Authorized IP Ranges in Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn

Service tags for API server authorized IP ranges is a preview feature that allows you to use service tags to specify authorized IP ranges for the API server in Azure Kubernetes Service (AKS). This feature simplifies the management of authorized IP ranges by allowing you to use predefined service tags instead of manually specifying individual IP addresses or CIDR ranges.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- The Azure CLI version 2.0.76 or later installed and configured. Check your version using the `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The `aks-preview` Azure CLI extension installed.
- The `EnableServiceTagAuthorizedIPPreview` feature flag registered in your Azure subscription.

## Limitations

- Only one service tag is allowed in the `--api-server-authorized-ip-ranges` parameter. You can't specify multiple service tags.

## Install the `aks-preview` Azure CLI extension

1. Install the Azure CLI preview extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update the extension to make sure you have the latest version using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    az extension update --name aks-preview
    ```

## Register the service tag authorized IP feature flag

1. Register the `EnableServiceTagAuthorizedIPPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command. It takes a few minutes for the registration to complete.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "EnableServiceTagAuthorizedIPPreview"
    ```

    Example output:

    ```output
    {
      "id": "/subscriptions/<subscription-id>/providers/Microsoft.ContainerService/features/EnableServiceTagAuthorizedIPPreview",
      "name": "EnableServiceTagAuthorizedIPPreview",
      "properties": {
        "state": "Registering"
      },
      "type": "Microsoft.ContainerService/features"
    }
    ```
2. Once the feature flag state changes from `Registering` to `Registered`, refresh the registration of the `Microsoft.ContainerService` resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace "Microsoft.ContainerService"
    ```
3. Verify the registration using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show --namespace "Microsoft.ContainerService" --name "EnableServiceTagAuthorizedIPPreview"
    ```

    Example output:

    ```output
    {
      "id": "/subscriptions/<subscription-id>/providers/Microsoft.ContainerService/features/EnableServiceTagAuthorizedIPPreview",
      "name": "EnableServiceTagAuthorizedIPPreview",
      "properties": {
        "state": "Registered"
      },
      "type": "Microsoft.ContainerService/features"
    }
    ```

## Create an AKS cluster with service tag authorized IP ranges

- Create a cluster with service tag authorized IP ranges using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--api-server-authorized-ip-ranges` parameter. The following example creates a cluster named *myAKSCluster* in the *myResourceGroup* resource group and authorizes the `AzureCloud` service tag to allow all Azure services to access the API server and specify an extra IP address:

    ```azurecli
    az aks create --resource-group myResourceGroup --name myAKSCluster --api-server-authorized-ip-ranges AzureCloud,20.20.20.20
    ```

    Note

    You should be able to curl the API server from an Azure virtual machine (VM) or Azure service that's part of the `AzureCloud` service tag.