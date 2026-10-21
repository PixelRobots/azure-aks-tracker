---
layout: Conceptual
title: Build a Container Image On-Demand in Azure - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-quickstart-task-cli
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
description: Use Azure Container Registry commands to quickly build, push, and run a Docker container image on-demand, in the Azure cloud.
ms.topic: quickstart
ms.date: 2026-02-27T00:00:00.0000000Z
ms.custom: devx-track-azurecli, mode-other
locale: en-us
document_id: 4f357648-1ce0-04eb-fab1-add2e2bce02e
document_version_independent_id: 982ac987-43f5-7fdd-6853-a7fe823040cc
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-quickstart-task-cli.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: container-registry/container-registry-quickstart-task-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-quickstart-task-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 1695c0e0-9e85-9bfa-0946-35cf03589f42
---

# Build a Container Image On-Demand in Azure - Azure Container Registry | Microsoft Learn

In this quickstart, you use [Azure Container Registry Tasks](container-registry-tasks-overview) commands to quickly build, push, and run a Docker container image natively within Azure, without a local Docker installation. ACR Tasks is a suite of features within Azure Container Registry to help you manage and modify container images across the container lifecycle. This example shows how to offload your "inner-loop" container image development cycle to the cloud with on-demand builds using a local Dockerfile.

After completing this quickstart, explore more advanced features of ACR Tasks by using the [tutorials](container-registry-tutorial-quick-task). ACR Tasks can automate image builds based on code commits or base image updates, or test multiple containers, in parallel, among other scenarios.

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

## Prerequisites

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

## Create a resource group

If you don't already have a container registry, first create a resource group with the [az group create](/en-us/cli/azure/group#azgroupcreate) command. An Azure resource group is a logical container into which you deploy and manage Azure resources.

The following example creates a resource group named *myResourceGroup* in the *eastus* location.

```azurecli
az group create --name myResourceGroup --location eastus
```

## Create a container registry

Create a container registry by using the [az acr create](/en-us/cli/azure/acr#az-acrcreate) command. The registry name must be unique within Azure, and contain 5-50 alphanumeric characters. In the following example, *mycontainerregistry008* is used. Update this value to a unique value.

```azurecli
az acr create --resource-group myResourceGroup \
  --name mycontainerregistry008 --sku Basic
```

This example creates a *Basic* registry, a cost-optimized option for developers learning about Azure Container Registry. For details on available service tiers, see [Azure Container Registry SKU features and limits](container-registry-skus).

## Build and push image from a Dockerfile

Now use Azure Container Registry to build and push an image. First, create a local working directory. Then create a Dockerfile named *Dockerfile* with the single line: `FROM mcr.microsoft.com/hello-world`. This line is a simple example that builds a Linux container image from the `hello-world` image hosted at Microsoft Container Registry. You can create your own standard Dockerfile and build images for other platforms. If you're working at a bash shell, create the Dockerfile by using the following command:

```bash
echo "FROM mcr.microsoft.com/hello-world" > Dockerfile
```

Run the [az acr build](/en-us/cli/azure/acr#az-acrbuild) command. It builds the image and, after the image is successfully built, pushes it to your registry. The following example builds and pushes the `sample/hello-world:v1` image. The `.` at the end of the command sets the location of the Dockerfile, in this case the current directory.

```azurecli
az acr build --image sample/hello-world:v1 \
  --registry mycontainerregistry008 \
  --file Dockerfile . 
```

Note

If you use an [ABAC-enabled source registry](container-registry-rbac-abac-repository-permissions), you must pass the caller's identity as the identity that the `build` uses to authenticate with the registry. Pass the identity by using the `--source-acr-auth-id [caller]` flag when running `az acr build`.

For more information, see [effects of enabling ABAC on ACR Tasks, Quick Tasks, Quick Builds, and Quick Runs](container-registry-rbac-abac-repository-permissions#effects-of-enabling-abac-on-acr-tasks-quick-tasks-quick-builds-and-quick-runs).

Output from a successful build and push is similar to the following:

```console
Packing source code into tar to upload...
Uploading archived source code from '/tmp/build_archive_b0bc1e5d361b44f0833xxxx41b78c24e.tar.gz'...
Sending context (1.856 KiB) to registry: mycontainerregistry008...
Queued a build with ID: ca8
Waiting for agent...
2023/03/18 21:56:57 Using acb_vol_4c7ffa31-c862-4be3-xxxx-ab8e615c55c4 as the home volume
2023/03/18 21:56:57 Setting up Docker configuration...
2023/03/18 21:56:58 Successfully set up Docker configuration
2023/03/18 21:56:58 Logging in to registry: mycontainerregistry008.azurecr.io
2023/03/18 21:56:59 Successfully logged into mycontainerregistry008.azurecr.io
2023/03/18 21:56:59 Executing step ID: build. Working directory: '', Network: ''
2023/03/18 21:56:59 Obtaining source code and scanning for dependencies...
2023/03/18 21:57:00 Successfully obtained source code and scanned for dependencies
2023/03/18 21:57:00 Launching container with name: build
Sending build context to Docker daemon  13.82kB
Step 1/1 : FROM mcr.microsoft.com/hello-world
latest: Pulling from hello-world
Digest: sha256:2557e3c07ed1e38f26e389462d03ed943586fxxxx21577a99efb77324b0fe535
Successfully built fce289e99eb9
Successfully tagged mycontainerregistry008.azurecr.io/sample/hello-world:v1
2023/03/18 21:57:01 Successfully executed container: build
2023/03/18 21:57:01 Executing step ID: push. Working directory: '', Network: ''
2023/03/18 21:57:01 Pushing image: mycontainerregistry008.azurecr.io/sample/hello-world:v1, attempt 1
The push refers to repository [mycontainerregistry008.azurecr.io/sample/hello-world]
af0b15c8625b: Preparing
af0b15c8625b: Layer already exists
v1: digest: sha256:92c7f9c92844bbbb5d0a101b22f7c2a7949e40f8ea90c8b3bc396879d95e899a size: 524
2023/03/18 21:57:03 Successfully pushed image: mycontainerregistry008.azurecr.io/sample/hello-world:v1
2023/03/18 21:57:03 Step ID: build marked as successful (elapsed time in seconds: 2.543040)
2023/03/18 21:57:03 Populating digests for step ID: build...
2023/03/18 21:57:05 Successfully populated digests for step ID: build
2023/03/18 21:57:05 Step ID: push marked as successful (elapsed time in seconds: 1.473581)
2023/03/18 21:57:05 The following dependencies were found:
2023/03/18 21:57:05
- image:
    registry: mycontainerregistry008.azurecr.io
    repository: sample/hello-world
    tag: v1
    digest: sha256:92c7f9c92844bbbb5d0a101b22f7c2a7949e40f8ea90c8b3bc396879d95e899a
  runtime-dependency:
    registry: registry.hub.docker.com
    repository: library/hello-world
    tag: v1
    digest: sha256:2557e3c07ed1e38f26e389462d03ed943586f744621577a99efb77324b0fe535
  git: {}

Run ID: ca8 was successful after 10s
```

## Run the image

Now run the image you built and pushed to your registry. Use [az acr run](/en-us/cli/azure/acr#azacrrun) to run the container command. In your container development workflow, this step might be a validation step before you deploy the image, or you could include the command in a [multi-step YAML file](container-registry-tasks-multi-step).

The following example uses `$Registry` to specify the endpoint of the registry where you run the command:

```azurecli
az acr run --registry mycontainerregistry008 \
  --cmd '$Registry/sample/hello-world:v1' /dev/null
```

Note

If you're using an [ABAC-enabled source registry](container-registry-rbac-abac-repository-permissions), you must pass the caller's identity as the identity that the `run` command uses to authenticate with the registry. Pass the identity by using the `--source-acr-auth-id [caller]` flag when running `az acr run`.

For more information, see [effects of enabling ABAC on ACR Tasks, Quick Tasks, Quick Builds, and Quick Runs](container-registry-rbac-abac-repository-permissions#effects-of-enabling-abac-on-acr-tasks-quick-tasks-quick-builds-and-quick-runs).

The `cmd` parameter in this example runs the container in its default configuration, but `cmd` supports additional `docker run` parameters or even other `docker` commands.

Output is similar to the following:

```console
Packing source code into tar to upload...
Uploading archived source code from '/tmp/run_archive_ebf74da7fcb04683867b129e2ccad5e1.tar.gz'...
Sending context (1.855 KiB) to registry: mycontainerre...
Queued a run with ID: cab
Waiting for an agent...
2023/03/19 19:01:53 Using acb_vol_60e9a538-b466-475f-9565-80c5b93eaa15 as the home volume
2023/03/19 19:01:53 Creating Docker network: acb_default_network, driver: 'bridge'
2023/03/19 19:01:53 Successfully set up Docker network: acb_default_network
2023/03/19 19:01:53 Setting up Docker configuration...
2023/03/19 19:01:54 Successfully set up Docker configuration
2023/03/19 19:01:54 Logging in to registry: mycontainerregistry008.azurecr.io
2023/03/19 19:01:55 Successfully logged into mycontainerregistry008.azurecr.io
2023/03/19 19:01:55 Executing step ID: acb_step_0. Working directory: '', Network: 'acb_default_network'
2023/03/19 19:01:55 Launching container with name: acb_step_0

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

2023/03/19 19:01:56 Successfully executed container: acb_step_0
2023/03/19 19:01:56 Step ID: acb_step_0 marked as successful (elapsed time in seconds: 0.843801)

Run ID: cab was successful after 6s
```

## Clean up resources

When you no longer need the resources, use the [az group delete](/en-us/cli/azure/group#azgroupdelete) command to remove the resource group, the container registry, and the container images stored in the registry.

```azurecli
az group delete --name myResourceGroup
```