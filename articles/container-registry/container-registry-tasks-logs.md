---
layout: Conceptual
title: View Task Run Logs - Azure Container Registry Tasks - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-logs
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
description: Learn to view and manage run logs from Azure Container Registry (ACR) Tasks for efficient monitoring and troubleshooting of your container workflows.
ms.topic: how-to
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 10e6eb4c-dc4f-2e5a-0e97-7b19b3d857a9
document_version_independent_id: b527c997-7134-333c-5558-e9c1a268bbdd
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-tasks-logs.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-tasks-logs
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-tasks-logs.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/2d774b87-7dcb-40bf-a0b9-5a7a9efff0d1
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/89dc5f37-0e4e-4b05-ad87-5fcd2b941a8a
platformId: f7625262-c988-a7dd-c77b-f7861668f45b
---

# View Task Run Logs - Azure Container Registry Tasks - Azure Container Registry | Microsoft Learn

Each task run in [Azure Container Registry tasks](container-registry-tasks-overview) generates log output that you can inspect to determine whether the task steps ran successfully.

This article explains how to view and manage task run logs.

## View streamed logs

When you trigger a task manually, log output is streamed directly to the console. For example, when you trigger a task manually by using the [az acr build](/en-us/cli/azure/acr#az-acr-build), [az acr run](/en-us/cli/azure/acr#az-acr-run), or [az acr task run](/en-us/cli/azure/acr/task#az-acr-task-run) command, you see log output streamed to the console.

The following sample [az acr run](/en-us/cli/azure/acr#az-acr-run) command manually triggers a task that runs a container pulled from the same registry:

```azurecli
az acr run --registry mycontainerregistry1220 \
  --cmd '$Registry/samples/hello-world:v1' /dev/null
```

Streamed log:

```console
Queued a run with ID: cf4
Waiting for an agent...
2023/03/09 20:30:10 Alias support enabled for version >= 1.1.0, please see https://aka.ms/acr/tasks/task-aliases for more information.
2023/03/09 20:30:10 Creating Docker network: acb_default_network, driver: 'bridge'
2023/03/09 20:30:10 Successfully set up Docker network: acb_default_network
2023/03/09 20:30:10 Setting up Docker configuration...
2023/03/09 20:30:11 Successfully set up Docker configuration
2023/03/09 20:30:11 Logging in to registry: mycontainerregistry1220azurecr.io
2023/03/09 20:30:12 Successfully logged into mycontainerregistry1220azurecr.io
2023/03/09 20:30:12 Executing step ID: acb_step_0. Timeout(sec): 600, Working directory: '', Network: 'acb_default_network'
2023/03/09 20:30:12 Launching container with name: acb_step_0
Unable to find image 'mycontainerregistry1220azurecr.io/samples/hello-world:v1' locally
v1: Pulling from samples/hello-world
Digest: sha256:92c7f9c92844bbbb5d0a101b22f7c2a7949e40f8ea90c8b3bc396879d95e888a
Status: Downloaded newer image for mycontainerregistry1220azurecr.io/samples/hello-world:v1

Hello from Docker!
This message shows that your installation appears to be working correctly.
[...]

2023/03/09 20:30:13 Successfully executed container: acb_step_0
2023/03/09 20:30:13 Step ID: acb_step_0 marked as successful (elapsed time in seconds: 1.180081)

Run ID: cf4 was successful after 5s
```

## View stored logs

Azure Container Registry stores run logs for all tasks. You can view stored run logs in the Azure portal. Or, use the [az acr task logs](/en-us/cli/azure/acr/task#az-acr-task-logs) command to view a selected log. By default, logs are retained for 30 days.

If a task is automatically triggered, for example by a source code update, accessing the stored logs is the *only* way to view the run logs. Automatic task triggers include source code commits or pull requests, base image updates, and timer triggers.

To view run logs in the portal:

1. Navigate to your container registry.
2. In **Services**, select **Tasks** &gt; **Runs**.
3. Select a **Run Id** to view the run status and run logs. The log contains the same information as a streamed log, if one is generated.

![View task run login portal](media/container-registry-tasks-logs/portal-task-run-logs.png)

To view a log using the Azure CLI, run [az acr task logs](/en-us/cli/azure/acr/task#az-acr-task-logs) and specify a run ID, a task name, specific image created by a build task. If a task name is specified, the command shows the log for the last created run.

The following example outputs the log for the run with ID *cf4*:

```azurecli
az acr task logs --registry mycontainerregistry1220 \
  --run-id cf4
```

## Alternative log storage

You might want to store task run logs on a local file system or use an alternative archiving solution such as Azure Storage.

For example, create a local *tasklogs* directory, and redirect the output of [az acr task logs](/en-us/cli/azure/acr/task#az-acr-task-logs) to a local file:

```azurecli
mkdir ~/tasklogs

az acr task logs --registry mycontainerregistry1220 \
  --run-id cf4 > ~/tasklogs/cf4.log
```

You can also save local log files to Azure Storage. For example, use the [Azure CLI](/en-us/azure/storage/blobs/storage-quickstart-blobs-cli), the [Azure portal](/en-us/azure/storage/blobs/storage-quickstart-blobs-portal), or other methods to upload files to a storage account.