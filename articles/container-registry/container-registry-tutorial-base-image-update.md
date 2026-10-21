---
layout: Conceptual
title: Tutorial- Trigger Image Build on Base Image Update in Azure - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-base-image-update
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
description: Learn to configure an Azure Container Registry Task to trigger container image builds when a base image is updated.
ms.topic: tutorial
ms.date: 2023-10-31T00:00:00.0000000Z
ms.custom: mvc, devx-track-azurecli
locale: en-us
document_id: b4afe907-4a5f-1f3e-b044-6f96068b3c1f
document_version_independent_id: 718454ef-3a3e-c256-44cc-3778cefca397
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-tutorial-base-image-update.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-tutorial-base-image-update
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-tutorial-base-image-update.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: dd5b6d43-9536-4aa1-89cd-66baeac11972
---

# Tutorial- Trigger Image Build on Base Image Update in Azure - Azure Container Registry | Microsoft Learn

[ACR Tasks](container-registry-tasks-overview) supports automated container image builds when a container's [base image is updated](container-registry-tasks-base-images), such as when you patch the OS or application framework in one of your base images.

In this tutorial, you learn how to create an ACR task that triggers a build in the cloud when a container's base image is pushed to the same registry. You can also try a tutorial to create an ACR task that triggers an image build when a base image is pushed to [another Azure container registry](container-registry-tutorial-private-base-image-update).

In this tutorial:

- Build the base image
- Create an application image in the same registry to track the base image
- Update the base image to trigger an application image task
- Display the triggered task
- Verify updated application image

## Prerequisites

### Complete the previous tutorials

This tutorial assumes you've already configured your environment and completed the steps in the first two tutorials in the series, in which you:

- Create Azure container registry
- Fork sample repository
- Clone sample repository
- Create GitHub personal access token

If you haven't already done so, complete the following tutorials before proceeding:

[Build container images in the cloud with Azure Container Registry Tasks](container-registry-tutorial-quick-task)

[Automate container image builds with Azure Container Registry Tasks](container-registry-tutorial-build-task)

### Configure the environment

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- This article requires version 2.0.46 or later of the Azure CLI. If using Azure Cloud Shell, the latest version is already installed.

Populate these shell environment variables with values appropriate for your environment. This step isn't strictly required, but makes executing the multiline Azure CLI commands in this tutorial a bit easier. If you don't populate these environment variables, you must manually replace each value wherever it appears in the example commands.

```console
ACR_NAME=<registry-name>        # The name of your Azure container registry
GIT_USER=<github-username>      # Your GitHub user account name
GIT_PAT=<personal-access-token> # The PAT you generated in the second tutorial
```

### Base image update scenario

This tutorial walks you through a base image update scenario in which a base image and an application image are maintained in a single registry.

The [code sample](https://github.com/Azure-Samples/acr-build-helloworld-node) includes two Dockerfiles: an application image, and an image it specifies as its base. In the following sections, you create an ACR task that automatically triggers a build of the application image when a new version of the base image is pushed to the same container registry.

- [Dockerfile-app](https://github.com/Azure-Samples/acr-build-helloworld-node/blob/main/Dockerfile-app): A small Node.js web application that renders a static web page displaying the Node.js version on which it's based. The version string is simulated: it displays the contents of an environment variable, `NODE_VERSION`, that's defined in the base image.
- [Dockerfile-base](https://github.com/Azure-Samples/acr-build-helloworld-node/blob/main/Dockerfile-base): The image that `Dockerfile-app` specifies as its base. It is itself based on a [Node](https://hub.docker.com/_/node/) image, and includes the `NODE_VERSION` environment variable.

In the following sections, you create a task, update the `NODE_VERSION` value in the base image Dockerfile, then use ACR Tasks to build the base image. When the ACR task pushes the new base image to your registry, it automatically triggers a build of the application image. Optionally, you run the application container image locally to see the different version strings in the built images.

In this tutorial, your ACR task builds and pushes an application container image specified in a Dockerfile. ACR Tasks can also run [multi-step tasks](container-registry-tasks-multi-step), using a YAML file to define steps to build, push, and optionally test multiple containers.

## Build the base image

Start by building the base image with an ACR Tasks *quick task*, using [az acr build](/en-us/cli/azure/acr#az-acr-build). As discussed in the [first tutorial](container-registry-tutorial-quick-task) in the series, this process not only builds the image, but pushes it to your container registry if the build is successful.

```azurecli
az acr build --registry $ACR_NAME --image baseimages/node:15-alpine --file Dockerfile-base .
```

## Create a task

Next, create a task with [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create):

```azurecli
az acr task create \
    --registry $ACR_NAME \
    --name baseexample1 \
    --image helloworld:{{.Run.ID}} \
    --arg REGISTRY_NAME=$ACR_NAME.azurecr.io \
    --context https://github.com/$GIT_USER/acr-build-helloworld-node.git#main \
    --file Dockerfile-app \
    --git-access-token $GIT_PAT
```

This task is similar to the task created in the [previous tutorial](container-registry-tutorial-build-task). It instructs ACR Tasks to trigger an image build when commits are pushed to the repository specified by `--context`. While the Dockerfile used to build the image in the previous tutorial specifies a public base image (`FROM node:15-alpine`), the Dockerfile in this task, [Dockerfile-app](https://github.com/Azure-Samples/acr-build-helloworld-node/blob/main/Dockerfile-app), specifies a base image in the same registry:

```dockerfile
FROM ${REGISTRY_NAME}/baseimages/node:15-alpine
```

This configuration makes it easy to simulate a framework patch in the base image later in this tutorial.

## Build the application container

Use [az acr task run](/en-us/cli/azure/acr/task#az-acr-task-run) to manually trigger the task and build the application image. This step is needed so that the task tracks the application image's dependency on the base image.

```azurecli
az acr task run --registry $ACR_NAME --name baseexample1
```

Once the task has completed, take note of the **Run ID** (for example, "da6") if you wish to complete the following optional step.

### Optional: Run application container locally

If you're working locally (not in the Cloud Shell), and you have Docker installed, run the container to see the application rendered in a web browser before you rebuild its base image. If you're using the Cloud Shell, skip this section (Cloud Shell does not support `az acr login` or `docker run`).

First, authenticate to your container registry with [az acr login](/en-us/cli/azure/acr#az-acr-login):

```azurecli
az acr login --name $ACR_NAME
```

Now, run the container locally with `docker run`. Replace **&lt;run-id&gt;** with the Run ID found in the output from the previous step (for example, "da6"). This example names the container `myapp` and includes the `--rm` parameter to remove the container when you stop it.

```bash
docker run -d -p 8080:80 --name myapp --rm $ACR_NAME.azurecr.io/helloworld:<run-id>
```

Navigate to `http://localhost:8080` in your browser, and you should see the Node.js version number rendered in the web page, similar to the following. In a later step, you bump the version by adding an "a" to the version string.

![Screenshot of sample application in browser](media/container-registry-tutorial-base-image-update/base-update-01.png)

To stop and remove the container, run the following command:

```bash
docker stop myapp
```

## List the builds

Next, list the task runs that ACR Tasks has completed for your registry using the [az acr task list-runs](/en-us/cli/azure/acr) command:

```azurecli
az acr task list-runs --registry $ACR_NAME --output table
```

If you completed the previous tutorial (and didn't delete the registry), you should see output similar to the following. Take note of the number of task runs, and the latest RUN ID, so you can compare the output after you update the base image in the next section.

```output
RUN ID    TASK            PLATFORM    STATUS     TRIGGER    STARTED               DURATION
--------  --------------  ----------  ---------  ---------  --------------------  ----------
cax       baseexample1    linux       Succeeded  Manual     2023-11-20T23:33:12Z  00:00:30
caw       taskhelloworld  linux       Succeeded  Commit     2023-11-20T23:16:07Z  00:00:29
cav       example2        linux       Succeeded  Commit     2023-11-20T23:16:07Z  00:00:55
cau       example1        linux       Succeeded  Commit     2023-11-20T23:16:07Z  00:00:40
cat       taskhelloworld  linux       Succeeded  Manual     2023-11-20T23:07:29Z  00:00:27
```

## Update the base image

Here you simulate a framework patch in the base image. Edit **Dockerfile-base**, and add an "a" after the version number defined in `NODE_VERSION`:

```dockerfile
ENV NODE_VERSION 15.2.1a
```

Run a quick task to build the modified base image. Take note of the **Run ID** in the output.

```azurecli
az acr build --registry $ACR_NAME --image baseimages/node:15-alpine --file Dockerfile-base .
```

Once the build is complete and the ACR task has pushed the new base image to your registry, it triggers a build of the application image. It may take few moments for the task you created earlier to trigger the application image build, as it must detect the newly built and pushed base image.

## List updated build

Now that you've updated the base image, list your task runs again to compare to the earlier list. If at first the output doesn't differ, periodically run the command to see the new task run appear in the list.

```azurecli
az acr task list-runs --registry $ACR_NAME --output table
```

Output is similar to the following. The TRIGGER for the last-executed build should be "Image Update", indicating that the task was kicked off by your quick task of the base image.

```output
Run ID    TASK            PLATFORM    STATUS     TRIGGER       STARTED               DURATION
--------  --------------  ----------  ---------  ------------  --------------------  ----------
ca11      baseexample1    linux       Succeeded  Image Update  2023-11-20T23:38:24Z  00:00:34
ca10      taskhelloworld  linux       Succeeded  Image Update  2023-11-20T23:38:24Z  00:00:24
cay                       linux       Succeeded  Manual        2023-11-20T23:38:08Z  00:00:22
cax       baseexample1    linux       Succeeded  Manual        2023-11-20T23:33:12Z  00:00:30
caw       taskhelloworld  linux       Succeeded  Commit        2023-11-20T23:16:07Z  00:00:29
cav       example2        linux       Succeeded  Commit        2023-11-20T23:16:07Z  00:00:55
cau       example1        linux       Succeeded  Commit        2023-11-20T23:16:07Z  00:00:40
cat       taskhelloworld  linux       Succeeded  Manual        2023-11-20T23:07:29Z  00:00:27
```

If you'd like to perform the following optional step of running the newly built container to see the updated version number, take note of the **RUN ID** value for the Image Update-triggered build (in the preceding output, it's "ca11").

### Optional: Run newly built image

If you're working locally (not in the Cloud Shell), and you have Docker installed, run the new application image once its build has completed. Replace `<run-id>` with the RUN ID you obtained in the previous step. If you're using the Cloud Shell, skip this section (Cloud Shell does not support `docker run`).

```bash
docker run -d -p 8081:80 --name updatedapp --rm $ACR_NAME.azurecr.io/helloworld:<run-id>
```

Navigate to http://localhost:8081 in your browser, and you should see the updated Node.js version number (with the "a") in the web page:

![Screenshot of updated sample application in browser](media/container-registry-tutorial-base-image-update/base-update-02.png)

What's important to note is that you updated your **base** image with a new version number, but the last-built **application** image displays the new version. ACR Tasks picked up your change to the base image, and rebuilt your application image automatically.

To stop and remove the container, run the following command:

```bash
docker stop updatedapp
```