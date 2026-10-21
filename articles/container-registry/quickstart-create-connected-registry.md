---
layout: Conceptual
title: Create a connected registry for your Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/quickstart-create-connected-registry
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
description: Use Azure CLI commands or Azure portal to create a connected Azure container registry resource that can synchronize images and other artifacts with the cloud registry.
ms.topic: how-to
ms.date: 2026-01-23T00:00:00.0000000Z
ms.custom: mode-api, devx-track-azurecli
ms.devlang: azurecli
locale: en-us
document_id: 3f714de4-f50c-6151-d851-1d515443f069
document_version_independent_id: d4643786-60fe-85de-00be-0ad588af79e0
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/quickstart-create-connected-registry.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/quickstart-create-connected-registry
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/quickstart-create-connected-registry.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 57b6effe-40e4-f4da-3740-8439bec4593e
---

# Create a connected registry for your Azure Container Registry - Azure Container Registry | Microsoft Learn

This article shows how to use the Azure CLI or Azure portal to create a [connected registry](intro-connected-registry) resource in Azure. The [connected registry feature of Azure Container Registry](intro-connected-registry) allows you to deploy a registry remotely or on your premises and synchronize images and other artifacts with a cloud-based Azure container registry.

In this article, you create two connected registry resources for an existing cloud registry: one that supports read and write (artifact pull and push) functionality, and one that supports read-only functionality.

After creating a connected registry, you [can deploy and use it on your on-premises or remote infrastructure](quickstart-connected-registry-arc-cli).

## Prerequisites

You must have an Azure Container registry in the [**Premium** SKU (pricing plan)](container-registry-skus) to use the connected registry feature. If you don't already have a container registry, [create one](container-registry-get-started-portal), being sure to select **Premium** for **Pricing plan**.

Even if you use the Azure portal to create your connected registry resource, these steps use Azure CLI to import images to the container registry.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

## Enable the dedicated data endpoint for the cloud registry

Enable the [dedicated data endpoint](container-registry-firewall-rules#enable-dedicated-data-endpoints) for the Azure container registry in the cloud. This step is necessary to allow the connected registry to communicate with the cloud registry.

# [Azure portal](#tab/azure-portal)
1. In the [Azure portal](https://portal.azure.com), go to your container registry.
2. In the service menu, under **Settings**, select **Networking**.
3. In the **Public access** section, select the **Enable dedicated data endpoint** checkbox.
4. Select **Save**.

# [Azure CLI](#tab/azure-cli)
Use the [az acr update](/en-us/cli/azure/acr#az-acr-update) command:

```azurecli
# Set the REGISTRY_NAME environment variable to identify the existing cloud registry
REGISTRY_NAME=<container-registry-name>

az acr update --name $REGISTRY_NAME \
  --data-endpoint-enabled
```

---

## Import images to your cloud registry

Next, import the following container images to your cloud registry. Skip this step if you already imported these images.

Use the [`az acr import`](/en-us/cli/azure/acr#az-acr-import) command to import the connected registry image into your private registry:

```azurecli
# Use the REGISTRY_NAME variable in the following Azure CLI commands to identify the registry
REGISTRY_NAME=<container-registry-name>

az acr import \
  --name $REGISTRY_NAME \
  --source mcr.microsoft.com/acr/connected-registry:1.0.0
```

For testing the connected registry, import the `hello-world` image. This repository will be synchronized to the connected registry and pulled by the connected registry clients.

```azurecli
az acr import \
  --name $REGISTRY_NAME \
  --source mcr.microsoft.com/hello-world:1.1.2
```

## Create a connected registry resource for read and write functionality

Follow these steps to create a connected registry in [ReadWrite mode](intro-connected-registry#modes) that is linked to your cloud registry.

# [Azure portal](#tab/azure-portal)
1. In the [Azure portal](https://portal.azure.com), go to your container registry.
2. In the service menu, under **Services**, select **Connected registries**.
3. Select **Create**.
4. Enter or select the values in the following table, and select **Save**.

    | Item | Description |
    | --- | --- |
    | Parent | Select **No parent** for a connected registry linked directly to the cloud registry. |
    | Mode | Select **ReadWrite**. |
    | Name | The connected registry name must start with a letter and contain only alphanumeric characters. It must be 5 to 40 characters long and unique in the hierarchy for this Azure container registry. |
    | Logging properties | Keep the default settings. |
    | Sync properties | Keep the default settings. Because there's no synchronization schedule defined by default, the repositories synchronize between the cloud registry and the connected registry without interruptions. |
    | Repositories | Select or enter the names of the repositories you imported in the previous step. The specified repositories synchronize between the cloud registry and the connected registry once deployed. |

![Screenshot of the options to create a connected registry in ReadWrite mode.](media/quickstart-connected-registry-portal/create-readwrite-connected-registry.png)

# [Azure CLI](#tab/azure-cli)
Use the [az acr connected-registry create](/en-us/cli/azure/acr/connected-registry#az-acr-connected-registry-create) command to create a connected registry with read-write functionality.

```azurecli
# Set the CONNECTED_REGISTRY_READ environment variable to provide a name for the connected registry with read-write functionality
CONNECTED_REGISTRY_RW=<connected-registry-name>
az acr connected-registry create --registry $REGISTRY_NAME \
  --name $CONNECTED_REGISTRY_RW \
  --repository "hello-world" "acr/connected-registry" \
  --mode ReadWrite
```

This command creates a connected registry resource using the value stored in *$CONNECTED\_REGISTRY\_RW* and links it to the cloud registry that you specified earlier for *$REGISTRY\_NAME*.

- The specified repositories synchronize between the parent registry and the connected registry.
- The resource is created in the [ReadWrite mode](intro-connected-registry#modes), which enables push and pull functionality.
- The repositories synchronize between the parent registry and the connected registry without interruptions because there's no synchronization schedule defined for this connected registry.

---

## Create a connected registry resource for read-only functionality

Next, create a connected registry in [ReadOnly mode](intro-connected-registry#modes) whose parent is the connected registry you created in the previous section. This connected registry enables read-only (artifact pull) functionality once deployed.

# [Azure portal](#tab/azure-portal)
1. In **Connected registries**, select **Create** again.
2. Repeat the steps to create a connected registry, with the following changes to the values in the previous table:

    | Item | Description |
    | --- | --- |
    | Parent | Select the connected registry you created previously. |
    | Mode | Select **ReadOnly**. |
3. Select **Save**.

# [Azure CLI](#tab/azure-cli)
Use the [az acr connected-registry create](/en-us/cli/azure/acr/connected-registry#az-acr-connected-registry-create) command to create a connected registry with read-only functionality.

```azurecli
# Set the CONNECTED_REGISTRY_READ environment variable to provide a name for the connected registry with read-only functionality
CONNECTED_REGISTRY_RO=<connected-registry-name>
az acr connected-registry create --registry $REGISTRY_NAME \
  --parent $CONNECTED_REGISTRY_RW \
  --name $CONNECTED_REGISTRY_RO \
  --repository "hello-world" "acr/connected-registry" \
  --mode ReadOnly
```

This command creates a connected registry resource named with the value stored in *$CONNECTED\_REGISTRY\_RO* and links it to the same cloud registry that you specified earlier for *$REGISTRY\_NAME*.

- The specified repositories synchronize between the *$CONNECTED\_REGISTRY\_RW* parent connected registry that you created in the previous step and the new connected registry.
- The resource is created in the [ReadOnly mode](intro-connected-registry#modes), which enables read-only (artifact pull) functionality.
- The repositories synchronize between the parent registry and the connected registry without interruptions because there's no synchronization schedule defined for this connected registry.

---

## Verify that the resources are created

After you create the connected registry resources, verify that they exist and view their properties.

# [Azure portal](#tab/azure-portal)
Select a connected registry in the portal to view its properties, such as its connection status (**Offline**, **Online**, or **Unhealthy**) and whether it activated (deployed on-premises). In the following example, the connected registry isn't deployed yet, so the connection state is **Offline**.

![Screenshot of a connected registry showing its connection status and other properties.](media/quickstart-connected-registry-portal/connected-registry-properties.png)

From this view, you can select **Connection string** to generate a connection string, which contains configuration settings used for deploying a connected registry and synchronizing content with a parent registry. You can also optionally generate passwords for the [sync token](overview-connected-registry-access#sync-token).

# [Azure CLI](#tab/azure-cli)
Use the connected registry [az acr connected-registry list](/en-us/cli/azure/acr/connected-registry#az-acr-connected-registry-list) command to verify that the resources are created.

```azurecli
az acr connected-registry list \
  --registry $REGISTRY_NAME \
  --output table
```

You see a response similar to the example below. Because the connected registries aren't yet deployed, the connection state of `Offline` indicates that they're currently disconnected from the cloud.

```
NAME                 MODE        CONNECTION STATE    PARENT               LOGIN SERVER    LAST SYNC (UTC)
-------------------  --------    ------------------  -------------------  --------------  -----------------
myconnectedregrw    ReadWrite    Offline
myconnectedregro    ReadOnly     Offline             myconnectedregrw
```

---

## Configure the connected registry sync schedule and window

The steps in this article create connected registries without a defined synchronization schedule and window. To define a specific schedule after you create your registry, use the `az acr connected-registry update` command to set a schedule. Use CRON expressions to define the sync schedule and the ISO 8601 duration format for the sync window.

For example, the following command configures the connected registry to schedule a daily sync at 12:00 PM UTC with a 4 hour synchronization window (PT4H):

```azurecli
az acr connected-registry update --registry myacrregistry \ 
--name myconnectedregistry \ 
--sync-schedule "0 12 * * *" \
--sync-window PT4H
```

This example command configures the connected registry will sync every minute with the cloud registry:

```azurecli
az acr connected-registry update --registry myacrregistry \ 
--name myconnectedregistry \ 
--sync-schedule "* * * * *"    
```

You can also enter values for **Schedule** and **Sync window** in the **Sync properties** section of the connected registry in the Azure portal.