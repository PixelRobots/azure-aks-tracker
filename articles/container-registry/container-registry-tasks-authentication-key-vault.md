---
layout: Conceptual
title: External Authentication from Azure Container Registry Task - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-authentication-key-vault
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
description: Configure an ACR Task to read Docker Hub credentials stored in an Azure key vault using a managed identity for Azure resources.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 6148535d-c60a-fa0b-50ae-42ae1af1b710
document_version_independent_id: 22db460f-f08f-c919-516c-53da75a192a0
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-tasks-authentication-key-vault.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: container-registry/container-registry-tasks-authentication-key-vault
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-tasks-authentication-key-vault.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f834bf37-1243-202f-1ade-4cb33878fa12
---

# External Authentication from Azure Container Registry Task - Azure Container Registry | Microsoft Learn

In an [ACR task](container-registry-tasks-overview), you can [enable a managed identity for Azure resources](container-registry-tasks-authentication-managed-identity). The task can use the identity to access other Azure resources, without needing to provide or manage credentials.

In this article, you learn how to enable a managed identity in a task that accesses secrets stored in an Azure key vault.

To create the Azure resources, this article requires that you run the Azure CLI version 2.0.68 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Scenario overview

The example task reads Docker Hub credentials stored in an Azure key vault. The credentials are for a Docker Hub account with write (push) permissions to a private Docker Hub repository. To read the credentials, you configure the task with a managed identity and assign appropriate permissions to it. The task associated with the identity builds an image, and signs into Docker Hub to push the image to the private repo.

This example shows steps using either a user-assigned or system-assigned managed identity. Your choice of identity depends on your organization's needs.

In a real-world scenario, a company might publish images to a private repo in Docker Hub as part of a build process.

## Prerequisites

You need an Azure container registry in which you run the task. In this article, this registry is named *myregistry*. Replace with your own registry name in later steps.

If you don't already have an Azure container registry, see [Quickstart: Create a private container registry using the Azure CLI](container-registry-get-started-azure-cli). You don't need to push images to the registry yet.

You also need a private repository in Docker Hub, and a Docker Hub account with permissions to write to the repo. In this example, this repo is named *hubuser/hubrepo*.

## Create a key vault and store secrets

First, if you need to, create a resource group named *myResourceGroup* in the *eastus* location with the following [az group create](/en-us/cli/azure/group?#az-group-create) command:

```azurecli
az group create --name myResourceGroup --location eastus
```

Use the [az keyvault create](/en-us/cli/azure/keyvault?#az-keyvault-create) command to create a key vault. Be sure to specify a unique key vault name.

```azurecli
az keyvault create --name mykeyvault --resource-group myResourceGroup --location eastus
```

Store the required Docker Hub credentials in the key vault using the [az keyvault secret set](/en-us/cli/azure/keyvault/secret#az-keyvault-secret-set) command. In these commands, the values are passed in environment variables:

```azurecli
# Store Docker Hub user name
az keyvault secret set \
  --name UserName \
  --value $USERNAME \
  --vault-name mykeyvault

# Store Docker Hub password
az keyvault secret set \
  --name Password \
  --value $PASSWORD \
  --vault-name mykeyvault
```

In a real-world scenario, secrets would likely be set and maintained in a separate process.

## Define task steps in YAML file

The steps for this example task are defined in a [YAML file](container-registry-tasks-reference-yaml). Create a file named `dockerhubtask.yaml` in a local working directory and paste the following contents. Be sure to replace the key vault name in the file with the name of your key vault.

```yml
version: v1.1.0
# Replace mykeyvault with the name of your key vault
secrets:
  - id: username
    keyvault: https://mykeyvault.vault.azure.net/secrets/UserName
  - id: password
    keyvault: https://mykeyvault.vault.azure.net/secrets/Password
steps:
# Log in to Docker Hub
  - cmd: bash echo '{{.Secrets.password}}' | docker login --username '{{.Secrets.username}}' --password-stdin 
# Build image
  - build: -t {{.Values.PrivateRepo}}:$ID https://github.com/Azure-Samples/acr-tasks.git -f hello-world.dockerfile
# Push image to private repo in Docker Hub
  - push:
    - {{.Values.PrivateRepo}}:$ID
```

The task steps do the following:

- Manage secret credentials to authenticate with Docker Hub.
- Authenticate with Docker Hub by passing the secrets to the `docker login` command.
- Build an image using a sample Dockerfile in the [Azure-Samples/acr-tasks](https://github.com/Azure-Samples/acr-tasks.git) repo.
- Push the image to the private Docker Hub repository.

## Option 1: Create task with user-assigned identity

The steps in this section create a task and enable a user-assigned identity. If you want to enable a system-assigned identity instead, see Option 2: Create task with system-assigned identity.

### Create a user-assigned identity

Create an identity named `myACRTasksId` in your subscription using the [az identity create](/en-us/cli/azure/identity#az-identity-create) command. You can use the same resource group you used previously to create a container registry, or a different one.

```azurecli
az identity create \
  --resource-group myResourceGroup \
  --name myACRTasksId
```

To configure the user-assigned identity in the following steps, use the [az identity show](/en-us/cli/azure/identity#az-identity-show) command to store the identity's resource ID, principal ID, and client ID in variables.

```azurecli
# Get resource ID of the user-assigned identity
resourceID=$(az identity show \
  --resource-group myResourceGroup \
  --name myACRTasksId \
  --query id --output tsv)

# Get principal ID of the task's user-assigned identity
principalID=$(az identity show \
  --resource-group myResourceGroup \
  --name myACRTasksId \
  --query principalId --output tsv)

# Get client ID of the user-assigned identity
clientID=$(az identity show \
  --resource-group myResourceGroup \
  --name myACRTasksId \
  --query clientId --output tsv)
```

### Create task

Create the task *dockerhubtask* by executing the following [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create) command. The task runs without a source code context, and the command references the file `dockerhubtask.yaml` in the working directory. The `--assign-identity` parameter passes the resource ID of the user-assigned identity.

```azurecli
az acr task create \
  --name dockerhubtask \
  --registry myregistry \
  --context /dev/null \
  --file dockerhubtask.yaml \
  --assign-identity $resourceID
```

In the command output, the `identity` section shows the identity of type `UserAssigned` is set in the task:

```console
[...]
"identity": {
    "principalId": null,
    "tenantId": null,
    "type": "UserAssigned",
    "userAssignedIdentities": {
      "/subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourcegroups/myResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myACRTasksId": {
        "clientId": "00001111-aaaa-2222-bbbb-3333cccc4444",
        "principalId": "aaaaaaaa-bbbb-cccc-1111-222222222222"
      }
    }
  },
[...]
```

### Grant identity access to key vault

Run the following [az keyvault set-policy](/en-us/cli/azure/keyvault#az-keyvault-set-policy) command to set an access policy on the key vault. The following example allows the identity to read secrets from the key vault.

```azurecli
az keyvault set-policy --name mykeyvault \
  --resource-group myResourceGroup \
  --object-id $principalID \
  --secret-permissions get
```

Proceed to Manually run the task.

## Option 2: Create task with system-assigned identity

The steps in this section create a task and enable a system-assigned identity. If you want to enable a user-assigned identity instead, see Option 1: Create task with user-assigned identity.

### Create task

Create the task *dockerhubtask* by executing the following [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create) command. The task runs without a source code context, and the command references the file `dockerhubtask.yaml` in the working directory. The `--assign-identity` parameter with no value enables the system-assigned identity on the task.

```azurecli
az acr task create \
  --name dockerhubtask \
  --registry myregistry \
  --context /dev/null \
  --file dockerhubtask.yaml \
  --assign-identity 
```

In the command output, the `identity` section shows an identity of type `SystemAssigned` is set in the task. The `principalId` is the principal ID of the task identity:

```console
[...]
  "identity": {
    "principalId": "aaaaaaaa-bbbb-cccc-1111-222222222222",
    "tenantId": "aaaabbbb-0000-cccc-1111-dddd2222eeee",
    "type": "SystemAssigned",
    "userAssignedIdentities": null
  },
  "location": "eastus",
[...]
```

Use the [az acr task show](/en-us/cli/azure/acr/task#az-acr-task-show) command to store the principalId in a variable, to use in later commands. Substitute the name of your task and your registry in the following command:

```azurecli
principalID=$(az acr task show \
  --name <task_name> --registry <registry_name> \
  --query identity.principalId --output tsv)
```

### Grant identity access to key vault

Run the following [az keyvault set-policy](/en-us/cli/azure/keyvault#az-keyvault-set-policy) command to set an access policy on the key vault. The following example allows the identity to read secrets from the key vault.

```azurecli
az keyvault set-policy --name mykeyvault \
  --resource-group myResourceGroup \
  --object-id $principalID \
  --secret-permissions get
```

## Manually run the task

To verify that the task in which you enabled a managed identity runs successfully, manually trigger the task with the [az acr task run](/en-us/cli/azure/acr/task#az-acr-task-run) command. The `--set` parameter is used to pass the private repo name to the task. In this example, the placeholder repo name is *hubuser/hubrepo*.

```azurecli
az acr task run --name dockerhubtask --registry myregistry --set PrivateRepo=hubuser/hubrepo
```

When the task runs successfully, output shows successful authentication to Docker Hub, and the image is successfully built and pushed to the private repo:

```console
Queued a run with ID: cf24
Waiting for an agent...
2023/06/20 18:05:55 Using acb_vol_b1edae11-30de-4f2b-a9c7-7d743e811101 as the home volume
2023/06/20 18:05:58 Creating Docker network: acb_default_network, driver: 'bridge'
2023/06/20 18:05:58 Successfully set up Docker network: acb_default_network
2023/06/20 18:05:58 Setting up Docker configuration...
2023/06/20 18:05:59 Successfully set up Docker configuration
2023/06/20 18:05:59 Logging in to registry: myregistry.azurecr.io
2023/06/20 18:06:00 Successfully logged into myregistry.azurecr.io
2023/06/20 18:06:00 Executing step ID: acb_step_0. Timeout(sec): 600, Working directory: '', Network: 'acb_default_network'
2023/06/20 18:06:00 Launching container with name: acb_step_0
[...]
Login Succeeded
2023/06/20 18:06:02 Successfully executed container: acb_step_0
2023/06/20 18:06:02 Executing step ID: acb_step_1. Timeout(sec): 600, Working directory: '', Network: 'acb_default_network'
2023/06/20 18:06:02 Scanning for dependencies...
2023/06/20 18:06:04 Successfully scanned dependencies
2023/06/20 18:06:04 Launching container with name: acb_step_1
Sending build context to Docker daemon    129kB
[...]
2023/06/20 18:06:07 Successfully pushed image: hubuser/hubrepo:cf24
2023/06/20 18:06:07 Step ID: acb_step_0 marked as successful (elapsed time in seconds: 2.064353)
2023/06/20 18:06:07 Step ID: acb_step_1 marked as successful (elapsed time in seconds: 2.594061)
2023/06/20 18:06:07 Populating digests for step ID: acb_step_1...
2023/06/20 18:06:09 Successfully populated digests for step ID: acb_step_1
2023/06/20 18:06:09 Step ID: acb_step_2 marked as successful (elapsed time in seconds: 2.743923)
2023/06/20 18:06:09 The following dependencies were found:
2023/06/20 18:06:09
- image:
    registry: registry.hub.docker.com
    repository: hubuser/hubrepo
    tag: cf24
    digest: sha256:92c7f9c92844bbbb5d0a101b22f7c2a7949e40f8ea90c8b3bc396879d95e899a
  runtime-dependency:
    registry: registry.hub.docker.com
    repository: library/hello-world
    tag: latest
    digest: sha256:0e11c388b664df8a27a901dce21eb89f11d8292f7fca1b3e3c4321bf7897bffe
  git:
    git-head-revision: b0ffa6043dd893a4c75644c5fed384c82ebb5f9e

Run ID: cf24 was successful after 15s
```

To confirm the image is pushed, check for the tag (`cf24` in this example) in the private Docker Hub repo.