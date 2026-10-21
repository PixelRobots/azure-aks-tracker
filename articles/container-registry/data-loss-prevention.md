---
layout: Conceptual
title: Disable Artifact Export in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/data-loss-prevention
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
description: Learn how to set a registry property to prevent data exfiltration from a Premium Azure container registry by disabling artifact export.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: fed21449-3720-69a0-19bd-4c091db9762e
document_version_independent_id: 64262ae1-87be-123d-ec87-3a5a76f52a32
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/data-loss-prevention.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/data-loss-prevention
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/data-loss-prevention.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 53ee5e37-210a-0abd-b8f9-06222cc4b993
---

# Disable Artifact Export in Azure Container Registry - Azure Container Registry | Microsoft Learn

To prevent registry users in an organization from maliciously or accidentally leaking artifacts outside a virtual network, you can configure the registry's *export policy* to disable exports.

Export policy is a property introduced in API version **2021-06-01-preview** for Premium container registries. The `exportPolicy` property, when its status is set to `disabled`, blocks export of artifacts from a network-restricted registry when a user attempts to:

- [Import](container-registry-import-images) the registry's artifacts to another Azure container registry
- Create a registry [export pipeline](container-registry-transfer-arm-template) to transfer artifacts to another container registry

Note

Disabling export of artifacts does not prevent authorized users' access to the registry within the virtual network to pull artifacts or perform other data-plane operations. To audit this use, we recommend that you configure diagnostic settings to [monitor](monitor-service) registry operations.

## Prerequisites

- A Premium container registry configured with a [private endpoint](container-registry-private-endpoints).

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

## Other requirements to disable exports

- **Disable public network access** - To disable export of artifacts, public access to the registry must also be disabled (the registry's `publicNetworkAccess` property must be set to `disabled`). You can disable public network access to the registry before disabling export or disable it at the same time.

    By disabling access to the registry's public endpoint, you ensure that registry operations are permitted only within the virtual network. Public access to the registry to pull artifacts and perform other operations is prohibited.
- **Remove export pipelines** - Before setting the registry's `exportPolicy` status to `disabled`, delete any existing export pipelines configured on the registry. If a pipeline is configured, you can't change the `exportPolicy` status.

## Disable exportPolicy for an existing registry

When you create a registry, the `exportPolicy` status is set to `enabled` by default, which permits artifacts to be exported. You can update the status to `disabled` using an ARM template or the `az resource update` command.

### ARM template

Include the following JSON to update the `exportPolicy` status and set the `publicNetworkAccess` property to `disabled`. Learn more about [deploying resources with ARM templates](/en-us/azure/azure-resource-manager/templates/deploy-cli).

```json
{
[...]
"resources": [
    {
    "type": "Microsoft.ContainerRegistry/registries",
    "apiVersion": "2021-06-01-preview",
    "name": "myregistry",
    [...]
    "properties": {
      "publicNetworkAccess": "disabled",
      "policies": {
        "exportPolicy": {
          "status": "disabled"
         }
      }
      }
    }
]
[...]
}
```

### Azure CLI

Run [az resource update](/en-us/cli/azure/resource/#az-resource-update) to set the `exportPolicy` status in an existing registry to `disabled`. Substitute the names of your registry and resource group.

As shown in this example, when disabling the `exportPolicy` property, also set the `publicNetworkAccess` property to `disabled`.

```azurecli
az resource update --resource-group myResourceGroup \
    --name myregistry \
    --resource-type "Microsoft.ContainerRegistry/registries" \
    --api-version "2021-06-01-preview" \
    --set "properties.policies.exportPolicy.status=disabled" \
    --set "properties.publicNetworkAccess=disabled"  
```

The output shows that the export policy status is disabled.

```json
{
  "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.ContainerRegistry/registries/myregistry",
  "identity": null,
  "kind": null,
  "location": "centralus",
  "managedBy": null,
  "name": "myregistry",
  "plan": null,
  "properties": {
    [...]
    "policies": {
      "exportPolicy": {
        "status": "disabled"
      },
      "quarantinePolicy": {
        "status": "disabled"
      },
      "retentionPolicy": {
        "days": 7,
        "lastUpdatedTime": "2023-07-20T23:20:30.9985256+00:00",
        "status": "disabled"
      },
      "trustPolicy": {
        "status": "disabled",
        "type": "Notary"
      },
    "privateEndpointConnections": [],
    "provisioningState": "Succeeded",
    "publicNetworkAccess": "Disabled",
    "zoneRedundancy": "Disabled"
[...]
}
```

## Enable exportPolicy

After disabling the `exportPolicy` status in a registry, you can re-enable it at any time using an ARM template or the `az resource update` command.

### ARM template

Include the following JSON to update the `exportPolicy` status to `enabled`. Learn more about [deploying resources with ARM templates](/en-us/azure/azure-resource-manager/templates/deploy-cli)

```json
{
[...]
"resources": [
    {
    "type": "Microsoft.ContainerRegistry/registries",
    "apiVersion": "2021-06-01-preview",
    "name": "myregistry",
    [...]
    "properties": {
     "policies": {
        "exportPolicy": {
          "status": "enabled"
         }
      }
      }
    }
]
[...]
}
```

### Azure CLI

Run [az resource update](/en-us/cli/azure/resource/#az-resource-update) to set the `exportPolicy` status to `enabled`. Substitute the names of your registry and resource group.

```azurecli
az resource update --resource-group myResourceGroup \
    --name myregistry \
    --resource-type "Microsoft.ContainerRegistry/registries" \
    --api-version "2021-06-01-preview" \
    --set "properties.policies.exportPolicy.status=enabled"
```