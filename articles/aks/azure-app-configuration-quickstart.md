---
layout: Conceptual
title: Quickstart Generate ConfigMap from Azure App Configuration - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-app-configuration-quickstart
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
description: Learn how to configure the workload in Azure Kubernetes Service (AKS) with ConfigMap that is generated from Azure App Configuration.
author: RichardChen820
ms.author: junbchen
ms.topic: quickstart
ms.custom: devx-track-azurecli
ms.subservice: aks-developer
ms.date: 2024-10-10T00:00:00.0000000Z
locale: en-us
document_id: 0b6fa3c6-e38c-04d2-9685-1683742ce9f6
document_version_independent_id: d9785df6-7339-5f11-a268-43673055d874
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-app-configuration-quickstart.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/azure-app-configuration-quickstart
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-app-configuration-quickstart.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/80beb97b-18aa-44f8-9420-8f2a4cd448eb
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/8c09e0ef-0fde-4b6d-bf1b-b517e4db7f80
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 0fa76eea-24d0-4c64-484b-2a3b7fd7fc1c
---

# Quickstart Generate ConfigMap from Azure App Configuration - Azure Kubernetes Service | Microsoft Learn

You can externalize the configurations of your Azure Kubernetes Service (AKS) workloads and manage them in [Azure App Configuration](/en-us/azure/azure-app-configuration/overview). The [Azure App Configuration Kubernetes provider](https://mcr.microsoft.com/artifact/mar/azure-app-configuration/kubernetes-provider/about) runs as a container in your cluster. Key benefits include:

- **Seamless integration**: Pulls data from Azure App Configuration and Key Vault, making them accessible as ConfigMap and Secret without code changes in your workloads.
- **Dynamic update**: Built-in caching and refreshing capabilities for dynamic configuration, feature flagging, and automatic secret rotation.

The Azure App Configuration Kubernetes provider is available as an AKS extension. By following this document, you can easily install the extension and connect your AKS cluster with an App Configuration store using the Service Connector in the Azure portal. For information on setting up the provider using Helm, see the [Quickstart for Azure App Configuration Kubernetes provider](/en-us/azure/azure-app-configuration/quickstart-azure-kubernetes-service).

## Prerequisites

- An Azure Kubernetes Service (AKS) cluster. [Create an AKS cluster](/en-us/azure/aks/tutorial-kubernetes-deploy-cluster#create-a-kubernetes-cluster).
- A running workload in Azure Kubernetes Service (AKS) cluster. If you don't have one, you can [create a demo application running in AKS](/en-us/azure/azure-app-configuration/quickstart-azure-kubernetes-service#create-an-application-running-in-aks).

## Create a service connection to App Configuration

Create a service connection between your AKS cluster and your App Configuration store using Microsoft Entra Workload Identity.

1. In the [Azure portal](https://portal.azure.com), navigate to your AKS cluster resource.
2. Select **Settings** &gt; **Service Connector** &gt; **Create**.
3. On the **Basics** tab, configure the following settings:

    - **Kubernetes namespace**: Specify the namespace you'd like to create ConfigMap or Secret to.
    - **Service type**: Select **App Configuration**.
    - **Use App Configuration Extension on Kubernetes**: Check the box to use the [Azure App Configuration AKS extension](azure-app-configuration) for this connection. Azure App Configuration AKS extension will be installed to current cluster if it's not yet.
    - **Connection name**: Enter a connection name or use the default name.
    - **Subscription**: Select the subscription of your App Configuration store.
    - **App Configuration**: Select your App Configuration store. If you don't have one, click **Create new** to set one up.

    ![Screenshot showing create connection.](media/azure-app-configuration/create-connection.png)
4. Select **Next: Authentication**. On the **Authentication** tab, keep the default selection of **Workload Identity**, select a **User assigned managed identity** you want to use. If you don't have one, click **Create new** to set one up.
5. Select **Next: Networking** and use the default settings.
6. Select **Next: Review + create** and wait for the validation to pass.
7. Select **Create** to create the service connection.

Note

The Service Connector simplifies the installation of the Azure App Configuration AKS extension from the Azure portal. You can also install it without Service Connector using Azure CLI, Bicep, or an ARM template. For more information, see [Install Azure App Configuration AKS extension](azure-app-configuration).

## Generate ConfigMap from App Configuration

Update the service connection to create and deploy an `AzureAppConfigurationProvider` YAML resource in your AKS cluster. This resource generates a ConfigMap with data from your App Configuration store.

1. In the [Azure portal](https://portal.azure.com), navigate to your AKS cluster resource and select **Settings** &gt; **Service Connector**.
2. Select the newly created connection, select **Yaml snippet** in the top menu.
3. On the **AzureAppConfigurationProvider** tab, configure the following settings:

    - **Using configuration as**: Choose to consume the configuration as a **mounted file** or **environment variables**.
    - **Mounted file**: If selected, specify the **file type** and **file name**.
    - **Selector**: Set the **Key filter** and **Label filter** to load data from your App Configuration store.
4. A YAML is generated based on your input. Click **Apply** to add it to your AKS cluster. It will create a ConfigMap in your AKS cluster with data from your App Configuration store.

    ![Screenshot showing AzureAppConfigurationProvider.](media/azure-app-configuration/yaml-snippet-provider.png)
5. Click **Next**. On the **Workload** tab, configure the following settings:

    - **File mount path**: Specify the file mount path if the mounted file option was selected.
    - **Kubernetes Workload**: Select the workload where the generated ConfigMap will be injected.
    - Click **Apply** to update the workload.