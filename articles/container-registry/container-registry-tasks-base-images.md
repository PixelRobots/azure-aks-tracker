---
layout: Conceptual
title: Base Image Updates - Azure Container Registry Tasks - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-base-images
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
description: Learn about base images for application container images, and about how a base image update can trigger an Azure Container Registry task.
ms.topic: how-to
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: e0236053-cc8e-d48c-d16a-85e6c270b4ac
document_version_independent_id: 885b4e81-a7ab-5fb5-9e55-10ef41ca5450
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-tasks-base-images.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-tasks-base-images
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-tasks-base-images.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 82d6ccfd-600f-9fa8-5485-0046e47419c4
---

# Base Image Updates - Azure Container Registry Tasks - Azure Container Registry | Microsoft Learn

This article provides background information about updates to an application's base image and how these updates can trigger an Azure Container Registry task.

## What are base images?

Dockerfiles defining most container images specify a parent image from which the image is based, often referred to as its *base image*. Base images typically contain the operating system, for example [Alpine Linux](https://hub.docker.com/_/alpine/) or Windows Nano Server, on which the rest of the container's layers are applied. They might also include application frameworks such as [Node.js](https://hub.docker.com/_/node/) or [.NET Core](https://hub.docker.com/r/microsoft/dotnet). These base images are themselves typically based on public upstream images. Several of your application images might share a common base image.

A base image is often updated by the image maintainer to include new features or improvements to the OS or framework in the image. Security patches are another common cause for a base image update. When these upstream updates occur, you must also update your base images to include the critical fix. Each application image must then also be rebuilt to include these upstream fixes now included in your base image.

In some cases, such as a private development team, a base image might specify more than OS or framework. For example, a base image could be a shared service component image that needs to be tracked. Members of a team might need to track this base image for testing, or need to regularly update the image when developing application images.

## Maintain copies of base images

For any content in your registries that depends on base content maintained in a public registry such as Docker Hub, we recommend that you copy the content to an Azure container registry or another private registry. Then, ensure that you build your application images by referencing the private base images. Azure Container Registry provides an [image import](container-registry-import-images) capability to easily copy content from public registries or other Azure container registries. The next section describes using ACR Tasks to track base image updates when building application updates. You can track base image updates in your own Azure container registries and optionally in upstream public registries.

## Track base image updates

ACR Tasks includes the ability to automatically build images for you when a container's base image is updated. You can use this ability to maintain and update copies of public base images in your Azure container registries, and then to rebuild application images that depend on base images.

ACR Tasks dynamically discovers base image dependencies when it builds a container image. As a result, it can detect when an application image's base image is updated. With one pre-configured build task, ACR Tasks can automatically rebuild every application image that references the base image. With this automatic detection and rebuilding, ACR Tasks saves you the time and effort normally required to manually track and update each and every application image referencing your updated base image.

## Base image locations

For image builds from a Dockerfile, an ACR task detects dependencies on base images in the following locations:

- The same Azure container registry where the task runs
- Another private Azure container registry in the same or a different region
- A public repo in Docker Hub
- A public repo in Microsoft Container Registry

If the base image specified in the `FROM` statement resides in one of these locations, the ACR task adds a hook to ensure the image is rebuilt anytime its base is updated.

## Base image notifications

The time between when a base image is updated and when the dependent task is triggered depends on the base image location:

- **Base images from a public repo in Docker Hub or MCR** - For base images in public repositories, an ACR task checks for image updates at a random interval of between 10 and 60 minutes. Dependent tasks are run accordingly.
- **Base images from an Azure container registry** - For base images in Azure container registries, an ACR task immediately triggers a run when its base image is updated. The base image may be in the same ACR where the task runs or in a different ACR in any region.

## Additional considerations

- **Base images for application images** - Currently, an ACR task only tracks base image updates for application (*runtime*) images. It doesn't track base image updates for intermediate (*buildtime*) images used in multi-stage Dockerfiles.
- **Enabled by default** - When you create an ACR task with the [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create) command, by default the task is *enabled* for trigger by a base image update. That is, the `base-image-trigger-enabled` property is set to True. If you want to disable this behavior in a task, update the property to False. For example, run the following [az acr task update](/en-us/cli/azure/acr/task#az-acr-task-update) command:

    ```azurecli
    az acr task update --registry myregistry --name mytask --base-image-trigger-enabled False
    ```
- **Trigger to track dependencies** - To enable an ACR task to determine and track a container image's dependencies -- which include its base image -- you must first trigger the task to build the image **at least once**. For example, trigger the task manually using the [az acr task run](/en-us/cli/azure/acr/task#az-acr-task-run) command.
- **Stable tag for base image** - To trigger a task on base image update, the base image must have a *stable* tag, such as `node:9-alpine`. This tagging is typical for a base image that is updated with OS and framework patches to a latest stable release. If the base image is updated with a new version tag, it does not trigger a task. For more information about image tagging, see the [best practices guidance](container-registry-image-tag-version).
- **Other task triggers** - In a task triggered by base image updates, you can also enable triggers based on [source code commit](container-registry-tutorial-build-task) or [a schedule](container-registry-tasks-scheduled). A base image update can also trigger a [multi-step task](container-registry-tasks-multi-step).