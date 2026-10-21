---
layout: Conceptual
title: Schedule Azure Container Registry (ACR) Tasks - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-scheduled
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
description: Learn how to schedule Azure Container Registry (ACR) tasks using timer triggers. This tutorial covers setting up and managing scheduled tasks efficiently.
ms.topic: tutorial
ms.custom: devx-track-azurecli
ms.date: 2023-10-31T00:00:00.0000000Z
locale: en-us
document_id: 7e863c45-bc89-0762-7bc1-525c122cf6ec
document_version_independent_id: 3937ce4a-4428-bcfc-7ea7-760705947409
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-tasks-scheduled.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-tasks-scheduled
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-tasks-scheduled.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/8b896464-3b7d-4e1f-84b0-9bb45aeb5f64
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/b1d2d671-9549-46e8-918c-24349120dbf5
platformId: 6383088f-f62d-1242-1d2a-a0f0531e9d93
---

# Schedule Azure Container Registry (ACR) Tasks - Azure Container Registry | Microsoft Learn

This tutorial shows you how to run an [ACR Task](container-registry-tasks-overview) on a schedule. Schedule a task by setting up one or more *timer triggers*. Timer triggers can be used alone, or in combination with other task triggers.

In this tutorial, learn about scheduling tasks and:

- Create a task with a timer trigger
- Manage timer triggers

Scheduling a task is useful for scenarios like the following:

- Run a container workload for scheduled maintenance operations. For example, run a containerized app to remove unneeded images from your registry.
- Run a set of tests on a production image during the workday as part of your live-site monitoring.

## Prerequisites

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

## About scheduling a task

- **Trigger with cron expression** - The timer trigger for a task uses a *cron expression*. The expression is a string with five fields specifying the minute, hour, day, month, and day of week to trigger the task. Frequencies of up to once per minute are supported.

    For example, the expression `"0 12 * * Mon-Fri"` triggers a task at noon UTC on each weekday. See details later in this article.
- **Multiple timer triggers** - Adding multiple timers to a task is allowed, as long as the schedules differ.

    - Specify multiple timer triggers when you create the task, or add them later.
    - Optionally name the triggers for easier management, or ACR Tasks will provide default trigger names.
    - If timer schedules overlap at a time, ACR Tasks triggers the task at the scheduled time for each timer.
- **Other task triggers** - In a timer-triggered task, you can also enable triggers based on [source code commit](container-registry-tutorial-build-task) or [base image updates](container-registry-tutorial-base-image-update). Like other ACR tasks, you can also [manually run](/en-us/cli/azure/acr/task#az-acr-task-run) a scheduled task.

## Create a task with a timer trigger

### Task command

First, populate the following shell environment variable with a value appropriate for your environment. This step isn't strictly required, but makes executing the multiline Azure CLI commands in this tutorial a bit easier. If you don't populate the environment variable, you must manually replace each value wherever it appears in the example commands.

[![](../reusable-content/ce-skilling/azure/media/cloud-shell/launch-cloud-shell-button.png)](https://shell.azure.com)

```console
ACR_NAME=<registry-name>        # The name of your Azure container registry
```

When you create a task with the [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create) command, you can optionally add a timer trigger. Add the `--schedule` parameter and pass a cron expression for the timer.

As a simple example, the following task triggers running the `hello-world` image from Microsoft Container Registry every day at 21:00 UTC. The task runs without a source code context.

```azurecli
az acr task create \
  --name timertask \
  --registry $ACR_NAME \
  --cmd mcr.microsoft.com/hello-world \
  --schedule "0 21 * * *" \
  --context /dev/null
```

Run the [az acr task show](/en-us/cli/azure/acr/task#az-acr-task-show) command to see that the timer trigger is configured. By default, the base image update trigger is also enabled.

```azurecli
az acr task show --name timertask --registry $ACR_NAME --output table
```

```output
NAME      PLATFORM    STATUS    SOURCE REPOSITORY       TRIGGERS
--------  ----------  --------  -------------------     -----------------
timertask linux       Enabled                           BASE_IMAGE, TIMER
```

Also, a simple example, of the task running with source code context. The following task triggers running the `hello-world` image from Microsoft Container Registry every day at 21:00 UTC.

Follow the [Prerequisites](container-registry-tutorial-quick-task#prerequisites) to build the source code context and then create a scheduled task with context.

```azurecli
az acr task create \
  --name timertask \
  --registry $ACR_NAME \
  --context https://github.com/$GIT_USER/acr-build-helloworld-node.git#master \
  --file Dockerfile \
  --image timertask:{{.Run.ID}} \
  --git-access-token $GIT_PAT \
  --schedule "0 21 * * *"
```

Run the [az acr task show](/en-us/cli/azure/acr/task#az-acr-task-show) command to see that the timer trigger is configured. By default, the base image update trigger is also enabled.

```azurecli
az acr task show --name timertask --registry $ACR_NAME --output table
```

Run the [az acr task run](/en-us/cli/azure/acr/task#az-acr-task-run) command to trigger the task manually.

```azurecli
az acr task run --name timertask --registry $ACR_NAME
```

## Trigger the task

Trigger the task manually with [az acr task run](/en-us/cli/azure/acr/task#az-acr-task-run) to ensure that it is set up properly:

```azurecli
az acr task run --name timertask --registry $ACR_NAME
```

If the container runs successfully, the output is similar to the following. The output is condensed to show key steps

```output
Queued a run with ID: cf2a
Waiting for an agent...
2023/11/20 21:03:36 Using acb_vol_2ca23c46-a9ac-4224-b0c6-9fde44eb42d2 as the home volume
2023/11/20 21:03:36 Creating Docker network: acb_default_network, driver: 'bridge'
[...]
2023/11/20 21:03:38 Launching container with name: acb_step_0

Hello from Docker!
This message shows that your installation appears to be working correctly.
[...]
```

After the scheduled time, run the [az acr task list-runs](/en-us/cli/azure/acr/task#az-acr-task-list-runs) command to verify that the timer triggered the task as expected:

```azurecli
az acr task list-runs --name timertask --registry $ACR_NAME --output table
```

When the timer is successful, output is similar to the following:

```output
RUN ID    TASK       PLATFORM    STATUS     TRIGGER    STARTED               DURATION
--------  ---------  ----------  ---------  ---------  --------------------  ----------
ca15      timertask  linux       Succeeded  Timer      2023-11-20T21:00:23Z  00:00:06
ca14      timertask  linux       Succeeded  Manual     2023-11-20T20:53:35Z  00:00:06
```

## Manage timer triggers

Use the [az acr task timer](/en-us/cli/azure/acr/task/timer) commands to manage the timer triggers for an ACR task.

### Add or update a timer trigger

After a task is created, optionally add a timer trigger by using the [az acr task timer add](/en-us/cli/azure/acr/task/timer#az-acr-task-timer-add) command. The following example adds a timer trigger name *timer2* to *timertask* created previously. This timer triggers the task every day at 10:30 UTC.

```azurecli
az acr task timer add \
  --name timertask \
  --registry $ACR_NAME \
  --timer-name timer2 \
  --schedule "30 10 * * *"
```

Update the schedule of an existing trigger, or change its status, by using the [az acr task timer update](/en-us/cli/azure/acr/task/timer#az-acr-task-timer-update) command. For example, update the trigger named *timer2* to trigger the task at 11:30 UTC:

```azurecli
az acr task timer update \
  --name timertask \
  --registry $ACR_NAME \
  --timer-name timer2 \
  --schedule "30 11 * * *"
```

### List timer triggers

The [az acr task timer list](/en-us/cli/azure/acr/task/timer#az-acr-task-timer-list) command shows the timer triggers set up for a task:

```azurecli
az acr task timer list --name timertask --registry $ACR_NAME
```

Example output:

```JSON
[
  {
    "name": "timer2",
    "schedule": "30 11 * * *",
    "status": "Enabled"
  },
  {
    "name": "t1",
    "schedule": "0 21 * * *",
    "status": "Enabled"
  }
]
```

### Remove a timer trigger

Use the [az acr task timer remove](/en-us/cli/azure/acr/task/timer#az-acr-task-timer-remove) command to remove a timer trigger from a task. The following example removes the *timer2* trigger from *timertask*:

```azurecli
az acr task timer remove \
  --name timertask \
  --registry $ACR_NAME \
  --timer-name timer2
```

## Cron expressions

ACR Tasks uses the [NCronTab](https://github.com/atifaziz/NCrontab) library to interpret cron expressions. Supported expressions in ACR Tasks have five required fields separated by white space:

`{minute} {hour} {day} {month} {day-of-week}`

The time zone used with the cron expressions is Coordinated Universal Time (UTC). Hours are in 24-hour format.

Note

ACR Tasks does not support the `{second}` or `{year}` field in cron expressions. If you copy a cron expression used in another system, be sure to remove those fields, if they are used.

Each field can have one of the following types of values:

| Type | Example | When triggered |
| --- | --- | --- |
| A specific value | `"5 * * * *"` | every hour at 5 minutes past the hour |
| All values (`*`) | `"* 5 * * *"` | every minute of the hour beginning 5:00 UTC (60 times a day) |
| A range (`-` operator) | `"0 1-3 * * *"` | 3 times per day, at 1:00, 2:00, and 3:00 UTC |
| A set of values (`,` operator) | `"20,30,40 * * * *"` | 3 times per hour, at 20 minutes, 30 minutes, and 40 minutes past the hour |
| An interval value (`/` operator) | `"*/10 * * * *"` | 6 times per hour, at 10 minutes, 20 minutes, and so on, past the hour |

To specify months or days you can use numeric values, names, or abbreviations of names:

- For days, the numeric values are 0 to 6, where 0 starts with Sunday.
- Names are in English. For example: `Monday`, `January`.
- Names are case-insensitive.
- Names can be abbreviated. We recommend using three letters for abbreviations. For example: `Mon`, `Jan`.

### Cron examples

| Example | When triggered |
| --- | --- |
| `"*/5 * * * *"` | once every five minutes |
| `"0 * * * *"` | once at the top of every hour |
| `"0 */2 * * *"` | once every two hours |
| `"0 9-17 * * *"` | once every hour from 9:00 to 17:00 UTC |
| `"30 9 * * *"` | at 9:30 UTC every day |
| `"30 9 * * 1-5"` | at 9:30 UTC every weekday |
| `"30 9 * Jan Mon"` | at 9:30 UTC every Monday in January |

## Clean up resources

To remove all resources you've created in this tutorial series, including the container registry or registries, container instance, key vault, and service principal, issue the following commands:

```azurecli
az group delete --resource-group $RES_GROUP
az ad sp delete --id http://$ACR_NAME-pull
```