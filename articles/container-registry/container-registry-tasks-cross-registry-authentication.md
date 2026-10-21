---
layout: Conceptual
title: Cross-Registry Authentication from ACR Task - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-cross-registry-authentication
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
description: Configure an Azure Container Registry Task (ACR Task) to access another private Azure container registry using a managed identity for Azure resources.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 9c6d984d-0f22-197d-ed81-fa400a9a912a
document_version_independent_id: ebd56c05-a9c6-5c22-de67-6ea4e429f37f
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-tasks-cross-registry-authentication.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-tasks-cross-registry-authentication
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-tasks-cross-registry-authentication.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 12570715-f5ad-da40-fa74-c2cc69d3137e
---

# Cross-Registry Authentication from ACR Task - Azure Container Registry | Microsoft Learn

In an [ACR task](container-registry-tasks-overview), you can [enable a managed identity for Azure resources](container-registry-tasks-authentication-managed-identity). The task can use the identity to access other Azure resources, without needing to provide or manage credentials.

In this article, you learn how to enable a managed identity in a task to pull an image from a registry different from the one used to run the task.

To create the Azure resources, this article requires that you run the Azure CLI version 2.0.68 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Scenario overview

The example task pulls a base image from another Azure container registry to build and push an application image. To pull the base image, you configure the task with a managed identity and assign appropriate permissions to it.

This example shows steps using either a user-assigned or system-assigned managed identity. Your choice of identity depends on your organization's needs.

In a real-world scenario, an organization might maintain a set of base images used by all development teams to build their applications. These base images are stored in a corporate registry, with each development team having only pull rights.

## Prerequisites

For this article, you need two Azure container registries:

- You use the first registry to create and execute ACR tasks. In this article, this registry is named *myregistry*.
- The second registry hosts a base image used for the task to build an image. In this article, the second registry is named *mybaseregistry*.

Replace with your own registry names in later steps.

If you don't already have the needed Azure container registries, see [Quickstart: Create a private container registry using the Azure CLI](container-registry-get-started-azure-cli). You don't need to push images to the registry yet.

## Prepare base registry

For demonstration purposes, as a one-time operation, run [az acr import][az-acr-import] to import a public Node.js image from Docker Hub to your base registry. In practice, another team or process in the organization might maintain images in the base registry.

```azurecli
az acr import --name mybaseregistry \
  --source docker.io/library/node:15-alpine \
  --image baseimages/node:15-alpine 
```

## Define task steps in YAML file

The steps for this example [multi-step task](container-registry-tasks-multi-step) are defined in a [YAML file](container-registry-tasks-reference-yaml). Create a file named `helloworldtask.yaml` in your local working directory and paste the following contents. Update the value of `REGISTRY_NAME` in the build step with the server name of your base registry.

```yml
version: v1.1.0
steps:
# Replace mybaseregistry with the name of your registry containing the base image
  - build: -t $Registry/hello-world:$ID  https://github.com/Azure-Samples/acr-build-helloworld-node.git#main -f Dockerfile-app --build-arg REGISTRY_NAME=mybaseregistry.azurecr.io
  - push: ["$Registry/hello-world:$ID"]
```

The build step uses the `Dockerfile-app` file in the [Azure-Samples/acr-build-helloworld-node](https://github.com/Azure-Samples/acr-build-helloworld-node.git) repo to build an image. The `--build-arg` references the base registry to pull the base image. When successfully built, the image is pushed to the registry used to run the task.

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

Create the task *helloworldtask* by executing the following [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create) command. The task runs without a source code context, and the command references the file `helloworldtask.yaml` in the working directory. The `--assign-identity` parameter passes the resource ID of the user-assigned identity.

```azurecli
az acr task create \
  --registry myregistry \
  --name helloworldtask \
  --context /dev/null \
  --file helloworldtask.yaml \
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

### Give identity pull permissions to the base registry

In this section, give the managed identity permissions to pull from the base registry, *mybaseregistry*.

Use the [az acr show](/en-us/cli/azure/acr#az-acr-show) command to get the resource ID of the base registry and store it in a variable:

```azurecli
baseregID=$(az acr show --name mybaseregistry --query id --output tsv)
```

Use the [az role assignment create](/en-us/cli/azure/role/assignment#az-role-assignment-create) command to assign the identity the correct role to the base registry. This role assignment grants permissions to only pull images from the registry.

The correct role to use in the role assignment depends on whether the registry is [ABAC-enabled or not](container-registry-rbac-abac-repository-permissions).

```azurecli
ROLE="Container Registry Repository Reader" # For ABAC-enabled registries. For non-ABAC registries, use AcrPull.
az role assignment create \
  --assignee $principalID \
  --scope $baseregID \
  --role "$ROLE"
```

Proceed to Add target registry credentials to task.

## Option 2: Create task with system-assigned identity

The steps in this section create a task and enable a system-assigned identity. If you want to enable a user-assigned identity instead, see Option 1: Create task with user-assigned identity.

### Create task

Create the task *helloworldtask* by executing the following [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create) command. The task runs without a source code context, and the command references the file `helloworldtask.yaml` in the working directory. The `--assign-identity` parameter with no value enables the system-assigned identity on the task.

```azurecli
az acr task create \
  --registry myregistry \
  --name helloworldtask \
  --context /dev/null \
  --file helloworldtask.yaml \
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

### Give identity pull permissions to the base registry

In this section, give the managed identity permissions to pull from the base registry, *mybaseregistry*.

Use the [az acr show](/en-us/cli/azure/acr#az-acr-show) command to get the resource ID of the base registry and store it in a variable:

```azurecli
baseregID=$(az acr show --name mybaseregistry --query id --output tsv)
```

Use the [az role assignment create](/en-us/cli/azure/role/assignment#az-role-assignment-create) command to assign the identity the correct role to the base registry. This role assignment grants permissions to only pull images from the registry.

The correct role to use in the role assignment depends on whether the registry is [ABAC-enabled or not](container-registry-rbac-abac-repository-permissions).

```azurecli
ROLE="Container Registry Repository Reader" # For ABAC-enabled registries. For non-ABAC registries, use AcrPull.
az role assignment create \
  --assignee $principalID \
  --scope $baseregID \
  --role "$ROLE"
```

## Add target registry credentials to task

Now use the [az acr task credential add](/en-us/cli/azure/acr/task/credential#az-acr-task-credential-add) command to enable the task to authenticate with the base registry using the identity's credentials. Run the command corresponding to the type of managed identity you enabled in the task. If you enabled a user-assigned identity, pass `--use-identity` with the client ID of the identity. If you enabled a system-assigned identity, pass `--use-identity [system]`.

```azurecli
# Add credentials for user-assigned identity to the task
az acr task credential add \
  --name helloworldtask \
  --registry myregistry \
  --login-server mybaseregistry.azurecr.io \
  --use-identity $clientID

# Add credentials for system-assigned identity to the task
az acr task credential add \
  --name helloworldtask \
  --registry myregistry \
  --login-server mybaseregistry.azurecr.io \
  --use-identity [system]
```

## Manually run the task

To verify that the task in which you enabled a managed identity runs successfully, manually trigger the task with the [az acr task run](/en-us/cli/azure/acr/task#az-acr-task-run) command.

```azurecli
az acr task run \
  --name helloworldtask \
  --registry myregistry
```

If the task runs successfully, output is similar to:

```
Queued a run with ID: cf10
Waiting for an agent...
2023/06/14 22:47:32 Using acb_vol_dbfbe232-fd76-4ca3-bd4a-687e84cb4ce2 as the home volume
2023/06/14 22:47:39 Creating Docker network: acb_default_network, driver: 'bridge'
2023/06/14 22:47:40 Successfully set up Docker network: acb_default_network
2023/06/14 22:47:40 Setting up Docker configuration...
2023/06/14 22:47:41 Successfully set up Docker configuration
2023/06/14 22:47:41 Logging in to registry: myregistry.azurecr.io
2023/06/14 22:47:42 Successfully logged into myregistry.azurecr.io
2023/06/14 22:47:42 Logging in to registry: mybaseregistry.azurecr.io
2023/06/14 22:47:43 Successfully logged into mybaseregistry.azurecr.io
2023/06/14 22:47:43 Executing step ID: acb_step_0. Timeout(sec): 600, Working directory: '', Network: 'acb_default_network'
2023/06/14 22:47:43 Scanning for dependencies...
2023/06/14 22:47:45 Successfully scanned dependencies
2023/06/14 22:47:45 Launching container with name: acb_step_0
Sending build context to Docker daemon   25.6kB
Step 1/6 : ARG REGISTRY_NAME
Step 2/6 : FROM ${REGISTRY_NAME}/baseimages/node:15-alpine
15-alpine: Pulling from baseimages/node
[...]
Successfully built 41b49a112663
Successfully tagged myregistry.azurecr.io/hello-world:cf10
2023/06/14 22:47:56 Successfully executed container: acb_step_0
2023/06/14 22:47:56 Executing step ID: acb_step_1. Timeout(sec): 600, Working directory: '', Network: 'acb_default_network'
2023/06/14 22:47:56 Pushing image: myregistry.azurecr.io/hello-world:cf10, attempt 1
The push refers to repository [myregistry.azurecr.io/hello-world]
[...]
2023/06/14 22:48:00 Step ID: acb_step_1 marked as successful (elapsed time in seconds: 2.517011)
2023/06/14 22:48:00 The following dependencies were found:
2023/06/14 22:48:00
- image:
    registry: myregistry.azurecr.io
    repository: hello-world
    tag: cf10
    digest: sha256:611cf6e3ae3cb99b23fadcd89fa144e18aa1b1c9171ad4a0da4b62b31b4e38d1
  runtime-dependency:
    registry: mybaseregistry.azurecr.io
    repository: baseimages/node
    tag: 15-alpine
    digest: sha256:e8e92cffd464fce3be9a3eefd1b65dc9cbe2484da31c11e813a4effc6105c00f
  git:
    git-head-revision: 0f988779c97fe0bfc7f2f74b88531617f4421643

Run ID: cf10 was successful after 32s
```

Run the [az acr repository show-tags](/en-us/cli/azure/acr/repository#az-acr-repository-show-tags) command to verify that the image built and was successfully pushed to *myregistry*:

```azurecli
az acr repository show-tags --name myregistry --repository hello-world --output tsv
```

Example output:

```console
cf10
```