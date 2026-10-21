---
layout: Conceptual
title: Pull Images from a Connected Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/pull-images-from-connected-registry
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
description: Learn how to use Azure Container Registry CLI commands to configure a client token and pull images from a connected registry.
ms.topic: quickstart
ms.date: 2025-05-20T00:00:00.0000000Z
ms.custom: mode-other, devx-track-azurecli
ms.devlang: azurecli
locale: en-us
document_id: ea9fc7f0-e196-05e4-0d66-6df30b3ca497
document_version_independent_id: 18a928e0-60fc-0c27-7c8d-16b57ffc3bf2
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/pull-images-from-connected-registry.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/pull-images-from-connected-registry
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/pull-images-from-connected-registry.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/cdc80360-921e-4b45-947f-2719acf06f23
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/539badf0-028a-4e3e-bda6-770b2552b4d8
platformId: a02199ec-a21b-e0e1-6673-73bc60ec27dd
---

# Pull Images from a Connected Registry - Azure Container Registry | Microsoft Learn

To pull images from a [connected registry](intro-connected-registry), configure a [client token](overview-connected-registry-access#client-tokens) and pass the token credentials to access registry content.

## Prerequisites

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- Connected registry resource in Azure. For deployment steps, see [Quickstart: Create a connected registry using the Azure CLI](quickstart-connected-registry-cli). In the commands in this article, the connected registry name is stored in the environment variable *$CONNECTED\_REGISTRY\_RW*.

## Create a scope map

Use the [az acr scope-map create](/en-us/cli/azure/acr/token/#az-acr-token-create) command to create a scope map for read access to the `hello-world` repository:

```azurecli
# Use the REGISTRY_NAME variable in the following Azure CLI commands to identify the registry
REGISTRY_NAME=<container-registry-name>

az acr scope-map create \
  --name hello-world-scopemap \
  --registry $REGISTRY_NAME \
  --repository hello-world content/read \
  --description "Scope map for the connected registry."
```

## Create a client token

Use the [az acr token create](/en-us/cli/azure/acr/token/#az-acr-token-create) command to create a client token and associate it with the newly created scope map:

```azurecli
az acr token create \
  --name myconnectedregistry-client-token \
  --registry $REGISTRY_NAME \
  --scope-map hello-world-scopemap
```

This command returns details about the newly generated token, including passwords.

Important

Make sure that you save the generated passwords. These passwords are one-time passwords and can't be retrieved. You can generate new passwords using the [az acr token credential generate](/en-us/cli/azure/acr/token/credential#az-acr-token-credential-generate) command.

## Update the connected registry with the client token

Use the az acr connected-registry update command to update the connected registry with the newly created client token.

```azurecli
az acr connected-registry update \
  --name $CONNECTED_REGISTRY_RW \
  --registry $REGISTRY_NAME \
  --add-client-token myconnectedregistry-client-token
```

## Pull an image from the connected registry

From a machine with access to connected registry on-premises device, use the following example command to sign into the connected registry, using the client token credentials. For best practices to manage login credentials, see the [docker login](https://docs.docker.com/engine/reference/commandline/login/) command reference.

Caution

If you set up your connected registry as an insecure registry, update the insecure registries list in the Docker daemon configuration to include the IP address or FQDN (Fully Qualified Domain Name) and port of your connected registry on your device. This configuration should only be used for testing purposes. For more information, see [Test an insecure registry](https://docs.docker.com/registry/insecure/).

```
docker login --username myconnectedregistry-client-token \
  --password <token_password> <IP_address_or_FQDN_of_connected_registry>:<port>
```

Then, use the following command to pull the `hello-world` image:

```
docker pull <IP_address_or_FQDN_of_connected_registry>:<port>/hello-world
```