---
layout: Conceptual
title: Quick Task Run with Template - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-task-run-template
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
description: Queue an ACR task run to build an image using an Azure Resource Manager template in Azure Container Registry.
ms.topic: how-to
ms.custom: devx-track-azurecli, devx-track-arm-template
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 1c25cfb5-6ec8-950b-ed53-4ead95f4cc7d
document_version_independent_id: f57ad639-def7-e4d8-125d-6f5d57c403ff
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-task-run-template.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-task-run-template
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-task-run-template.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
platformId: 65fc2f49-0ac0-de92-44f1-39ce379a42aa
---

# Quick Task Run with Template - Azure Container Registry | Microsoft Learn

[ACR Tasks](container-registry-tasks-overview) is a suite of features within Azure Container Registry to help you manage and modify container images across the container lifecycle.

This article shows Azure Resource Manager template examples to queue a quick task run, similar to one you can create manually using the [az acr build](/en-us/cli/azure/acr#az-acr-build) command.

A Resource Manager template to queue a task run is useful in automation scenarios and extends the functionality of `az acr build`. For example:

- Use a template to create a container registry and immediately queue a task run to build and push a container image
- Create or enable additional resources you can use in a quick task run, such as a managed identity for Azure resources

## Limitations

- You must specify a remote context such as a GitHub repo as the [source location](container-registry-tasks-overview#context-locations) for your task run. You can't use a local source context.
- For task runs using a managed identity, only a *user-assigned* managed identity is permitted.

## Prerequisites

- **GitHub account** - Create an account on https://github.com if you don't already have one.
- **Fork sample repository** - For the task examples shown here, use the GitHub UI to fork the following sample repository into your GitHub account: https://github.com/Azure-Samples/acr-build-helloworld-node. This repo contains sample Dockerfiles and source code to build small container images.

## Example: Create registry and queue task run

This example uses a [sample template](https://github.com/Azure/acr/tree/master/docs/tasks/run-as-deployment/quickdockerbuild) to create a container registry and queue a task run that builds and pushes an image.

### Template parameters

For this example, provide values for the following template parameters:

| Parameter | Value |
| --- | --- |
| registryName | Unique name of registry that's created |
| repository | Target repository for build task |
| taskRunName | Name of task run, which specifies image tag |
| sourceLocation | Remote context for the build task, for example, https://github.com/Azure-Samples/acr-build-helloworld-node. The Dockerfile in the repo root builds a container image for a small Node.js web app. If desired, use your fork of the repo as the build context. |

### Deploy the template

Deploy the template with the [az deployment group create](/en-us/cli/azure/deployment/group#az-deployment-group-create) command. This example builds and pushes the *helloworld-node:testrun* image to a registry named *mycontainerregistry*.

Note

The Dockerfile used in the following example depends on a public base container image from Docker Hub. To improve reliability when using public content, import and manage the image in a private Azure container registry, and update your Dockerfile to use your privately managed base image. [Learn more about working with public images](buffer-gate-public-content).

```azurecli
az deployment group create \
  --resource-group myResourceGroup \
  --template-uri https://raw.githubusercontent.com/Azure/acr/master/docs/tasks/run-as-deployment/quickdockerbuild/azuredeploy.json \
  --parameters \
    registryName=mycontainerregistry \
    repository=helloworld-node \
    taskRunName=testrun \
    sourceLocation=https://github.com/Azure-Samples/acr-build-helloworld-node.git#main
```

The previous command passes the parameters on the command line. If desired, pass them in a [parameters file](/en-us/azure/azure-resource-manager/templates/parameter-files).

### Verify deployment

After the deployment completes successfully, verify the image is built by running [az acr repository show-tags](/en-us/cli/azure/acr/repository#az-acr-repository-show-tags):

```azurecli
az acr repository show-tags \
  --name mycontainerregistry \
  --repository helloworld-node --output table
```

Output:

```console
Result
--------
testrun
```

### View run log

To view details about the task run, view the run log.

First, get the run ID with [az acr task list-runs](/en-us/cli/azure/acr/task#az-acr-task-list-runs)

```azurecli
az acr task list-runs \
  --registry mycontainerregistry --output table
```

Output is similar to:

```console
RUN ID    TASK    PLATFORM    STATUS     TRIGGER    STARTED               DURATION
--------  ------  ----------  ---------  ---------  --------------------  ----------
ca1               linux       Succeeded  Manual     2023-03-23T17:54:28Z  00:00:48
```

Run [az acr task logs](/en-us/cli/azure/acr/task#az-acr-task-logs) to view task run logs for the run ID, in this case *ca1*:

```azurecli
az acr task logs \
  --registry mycontainerregistry \
  --run-id ca1
```

The output shows the task run log.

You can also view the task run log in the Azure portal.

1. Navigate to your container registry
2. Under **Services**, select **Tasks** &gt; **Runs**.
3. Select the run ID, in this case *ca1*.

The portal shows the task run log.

## Example: Task run with managed identity

Use a [sample template](https://github.com/Azure/acr/tree/master/docs/tasks/run-as-deployment/quickdockerbuildwithidentity) to queue a task run that enables a user-assigned managed identity. During the task run, the identity authenticates to pull an image from another Azure container registry.

This scenario is similar to [Cross-registry authentication in an ACR task using an Azure-managed identity](container-registry-tasks-cross-registry-authentication). For example, an organization might maintain a centralized registry with base images accessed by multiple development teams.

### Prepare base registry

For demonstration purposes, create a separate container registry as your base registry, and push a Node.js base image pulled from Docker Hub.

1. Create a second container registry, for example *mybaseregistry*, to store base images.
2. Pull the `node:9-alpine` image from Docker Hub, tag it for your base registry, and push it to the base registry:

```azurecli
docker pull node:9-alpine
docker tag node:9-alpine mybaseregistry.azurecr.io/baseimages/node:9-alpine
az acr login -n mybaseregistry
docker push mybaseregistry.azurecr.io/baseimages/node:9-alpine
```

### Create new Dockerfile

Create a Dockerfile that pulls the base image from your base registry. Perform the following steps in your local fork of the GitHub repo, for example, `https://github.com/myGitHubID/acr-build-helloworld-node.git`.

1. In the GitHub UI, select **Create new file**.
2. Name your file *Dockerfile-test* and paste the following contents. Substitute your registry name for *mybaseregistry*. 

    ```
    FROM mybaseregistry.azurecr.io/baseimages/node:9-alpine
    COPY . /src
    RUN cd /src && npm install
    EXPOSE 80
    CMD ["node", "/src/server.js"]
    ```
3. Select **Commit new file**.

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

### Give identity pull permissions to the base registry

Give the managed identity permissions to pull from the base registry, *mybaseregistry*.

Use the [az acr show](/en-us/cli/azure/acr#az-acr-show) command to get the resource ID of the base registry and store it in a variable:

```azurecli
baseregID=$(az acr show \
  --name mybaseregistry \
  --query id --output tsv)
```

Use the [az role assignment create](/en-us/cli/azure/role/assignment#az-role-assignment-create) command to assign the identity the correct role to the base registry. This role assignment will grant permissions only to pull images from the registry. The role to use in the role assignment depends on whether your registry is [ABAC-enabled or not](container-registry-rbac-abac-repository-permissions).

```azurecli
ROLE="Container Registry Repository Reader" # For ABAC-enabled registries. For non-ABAC registries, use AcrPull.
az role assignment create \
  --assignee $principalID \
  --scope $baseregID \
  --role "$ROLE"
```

### Template parameters

For this example, provide values for the following template parameters:

| Parameter | Value |
| --- | --- |
| registryName | Name of registry where image is built |
| repository | Target repository for build task |
| taskRunName | Name of task run, which specifies image tag |
| userAssignedIdentity | Resource ID of user-assigned identity enabled in the task |
| customRegistryIdentity | Client ID of user-assigned identity enabled in the task, used to authenticate with custom registry |
| customRegistry | Login server name of the custom registry accessed in the task, for example, *mybaseregistry.azurecr.io* |
| sourceLocation | Remote context for the build task, for example, *[https://github.com/\](https://github.com/%5C)&lt;your-GitHub-ID&gt;/acr-build-helloworld-node.* |
| dockerFilePath | Path to the Dockerfile at the remote context, used to build the image. |

### Deploy the template

Deploy the template with the [az deployment group create](/en-us/cli/azure/deployment/group#az-deployment-group-create) command. This example builds and pushes the *helloworld-node:testrun* image to a registry named *mycontainerregistry*. The base image is pulled from *mybaseregistry.azurecr.io*.

```azurecli
az deployment group create \
  --resource-group myResourceGroup \
  --template-uri https://raw.githubusercontent.com/Azure/acr/master/docs/tasks/run-as-deployment/quickdockerbuildwithidentity/azuredeploy.json \
  --parameters \
    registryName=mycontainerregistry \
    repository=helloworld-node \
    taskRunName=basetask \
    userAssignedIdentity=$resourceID \
    customRegistryIdentity=$clientID \
    sourceLocation=https://github.com/<your-GitHub-ID>/acr-build-helloworld-node.git#main \
    dockerFilePath=Dockerfile-test \
    customRegistry=mybaseregistry.azurecr.io
```

The previous command passes the parameters on the command line. If desired, pass them in a [parameters file](/en-us/azure/azure-resource-manager/templates/parameter-files).

### Verify deployment

After the deployment completes successfully, verify the image is built by running [az acr repository show-tags](/en-us/cli/azure/acr/repository#az-acr-repository-show-tags):

```azurecli
az acr repository show-tags \
  --name mycontainerregistry \
  --repository helloworld-node --output table
```

Output:

```console
Result
--------
basetask
```

### View run log

To view the run log, see steps in the preceding section.