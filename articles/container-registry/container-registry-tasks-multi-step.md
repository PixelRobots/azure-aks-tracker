---
layout: Conceptual
title: Multi-Step Task to Build, Test & Patch Image - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-multi-step
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
description: Introduction to multi-step tasks in ACR Tasks, providing workflows for building, testing, and patching container images in the cloud.
ms.topic: how-to
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 68343916-56f4-39ad-20f4-8dea8eacb9c2
document_version_independent_id: d56f0b27-77c8-a586-e67b-69a9c6f7aab0
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-tasks-multi-step.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-tasks-multi-step
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-tasks-multi-step.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 2bdbf15f-e0ae-8001-dcf6-e802adbe36ad
---

# Multi-Step Task to Build, Test & Patch Image - Azure Container Registry | Microsoft Learn

Multi-step tasks extend the single image build-and-push capability of ACR Tasks with multi-step, multi-container-based workflows. Use multi-step tasks to build and push several images, in series or in parallel. Then run those images as commands within a single task run. Each step defines a container image build or push operation, and can also define the execution of a container. Each step in a multi-step task uses a container as its execution environment.

Important

If you previously created tasks during the preview with the `az acr build-task` command, those tasks need to be re-created using the [az acr task](/en-us/cli/azure/acr/task) command.

For example, you can run a task with steps that automate the following logic:

1. Build a web application image
2. Run the web application container
3. Build a web application test image
4. Run the web application test container which performs tests against the running application container
5. If the tests pass, build a Helm chart archive package
6. Perform a `helm upgrade` using the new Helm chart archive package

All steps are performed within Azure, offloading the work to Azure's compute resources and freeing you from infrastructure management. Besides your Azure container registry, you pay only for the resources you use. For information on pricing, see the **Container Build** section in [Azure Container Registry pricing](https://azure.microsoft.com/pricing/details/container-registry/).

## Common task scenarios

Multi-step tasks enable scenarios like the following logic:

- Build, tag, and push one or more container images, in series or in parallel.
- Run and capture unit test and code coverage results.
- Run and capture functional tests. ACR Tasks supports running more than one container, executing a series of requests between them.
- Perform task-based execution, including pre/post steps of a container image build.
- Deploy one or more containers with your favorite deployment engine to your target environment.

## Multi-step task definition

A multi-step task in ACR Tasks is defined as a series of steps within a YAML file. Each step can specify dependencies on the successful completion of one or more previous steps. The following task step types are available:

- [`build`](container-registry-tasks-reference-yaml#build): Build one or more container images using familiar `docker build` syntax, in series or in parallel.
- [`push`](container-registry-tasks-reference-yaml#push): Push built images to a container registry. Private registries like Azure Container Registry are supported, as is the public Docker Hub.
- [`cmd`](container-registry-tasks-reference-yaml#cmd): Run a container, such that it can operate as a function within the context of the running task. You can pass parameters to the container's `[ENTRYPOINT]`, and specify properties like env, detach, and other familiar `docker run` parameters. The `cmd` step type enables unit and functional testing, with concurrent container execution.

The following snippets show how to combine these task step types. Multi-step tasks can be as simple as building a single image from a Dockerfile and pushing to your registry, with a YAML file similar to:

```yml
version: v1.1.0
steps:
  - build: -t $Registry/hello-world:$ID .
  - push: ["$Registry/hello-world:$ID"]
```

Or more complex, such as this fictitious multi-step definition which includes steps for build, test, helm package, and helm deploy (container registry and Helm repository configuration not shown):

```yml
version: v1.1.0
steps:
  - id: build-web
    build: -t $Registry/hello-world:$ID .
    when: ["-"]
  - id: build-tests
    build: -t $Registry/hello-world-tests ./funcTests
    when: ["-"]
  - id: push
    push: ["$Registry/helloworld:$ID"]
    when: ["build-web", "build-tests"]
  - id: hello-world-web
    cmd: $Registry/helloworld:$ID
  - id: funcTests
    cmd: $Registry/helloworld:$ID
    env: ["host=helloworld:80"]
  - cmd: $Registry/functions/helm package --app-version $ID -d ./helm ./helm/helloworld/
  - cmd: $Registry/functions/helm upgrade helloworld ./helm/helloworld/ --reuse-values --set helloworld.image=$Registry/helloworld:$ID
```

See [task examples](container-registry-tasks-samples) for multi-step task YAML files and Dockerfiles for several scenarios.

## Run a sample task

Tasks support both manual execution, called a "quick run," and automated execution on Git commit or base image update.

To run a task, you first define the task's steps in a YAML file, then execute the Azure CLI command [az acr run](/en-us/cli/azure/acr#az-acr-run).

Here's an example Azure CLI command that runs a task using a sample task YAML file. Its steps build and then push an image. Update `\<acrName\>` with the name of your own Azure container registry before running the command.

```azurecli
az acr run --registry <acrName> -f build-push-hello-world.yaml https://github.com/Azure-Samples/acr-tasks.git
```

When you run the task, the output should show the progress of each step defined in the YAML file. In the following output, the steps appear as `acb_step_0` and `acb_step_1`.

```azurecli
az acr run --registry myregistry -f build-push-hello-world.yaml https://github.com/Azure-Samples/acr-tasks.git
```

```output
Sending context to registry: myregistry...
Queued a run with ID: yd14
Waiting for an agent...
2023/09/12 20:08:44 Using acb_vol_0467fe58-f6ab-4dbd-a022-1bb487366941 as the home volume
2023/09/12 20:08:44 Creating Docker network: acb_default_network
2023/09/12 20:08:44 Successfully set up Docker network: acb_default_network
2023/09/12 20:08:44 Setting up Docker configuration...
2023/09/12 20:08:45 Successfully set up Docker configuration
2023/09/12 20:08:45 Logging in to registry: myregistry.azurecr-test.io
2023/09/12 20:08:46 Successfully logged in
2023/09/12 20:08:46 Executing step: acb_step_0
2023/09/12 20:08:46 Obtaining source code and scanning for dependencies...
2023/09/12 20:08:47 Successfully obtained source code and scanned for dependencies
Sending build context to Docker daemon  109.6kB
Step 1/1 : FROM hello-world
 ---> 4ab4c602aa5e
Successfully built 4ab4c602aa5e
Successfully tagged myregistry.azurecr-test.io/hello-world:yd14
2023/09/12 20:08:48 Executing step: acb_step_1
2023/09/12 20:08:48 Pushing image: myregistry.azurecr-test.io/hello-world:yd14, attempt 1
The push refers to repository [myregistry.azurecr-test.io/hello-world]
428c97da766c: Preparing
428c97da766c: Layer already exists
yd14: digest: sha256:1a6fd470b9ce10849be79e99529a88371dff60c60aab424c077007f6979b4812 size: 524
2023/09/12 20:08:55 Successfully pushed image: myregistry.azurecr-test.io/hello-world:yd14
2023/09/12 20:08:55 Step id: acb_step_0 marked as successful (elapsed time in seconds: 2.035049)
2023/09/12 20:08:55 Populating digests for step id: acb_step_0...
2023/09/12 20:08:57 Successfully populated digests for step id: acb_step_0
2023/09/12 20:08:57 Step id: acb_step_1 marked as successful (elapsed time in seconds: 6.832391)
The following dependencies were found:
- image:
    registry: myregistry.azurecr-test.io
    repository: hello-world
    tag: yd14
    digest: sha256:1a6fd470b9ce10849be79e99529a88371dff60c60aab424c077007f6979b4812
  runtime-dependency:
    registry: registry.hub.docker.com
    repository: library/hello-world
    tag: latest
    digest: sha256:0add3ace90ecb4adbf7777e9aacf18357296e799f81cabc9fde470971e499788
  git: {}

Run ID: yd14 was successful after 19s
```

For more information about automated builds on Git commit or base image update, see the [Automate image builds](container-registry-tutorial-build-task) and [Base image update builds](container-registry-tutorial-base-image-update) tutorial articles.