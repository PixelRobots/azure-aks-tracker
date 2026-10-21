---
layout: Conceptual
title: Configure Continuous Patching in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/how-to-continuous-patching
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
description: Learn how to configure continuous patching in Azure Container Registry.
ms.topic: how-to
ms.date: 2025-03-27T00:00:00.0000000Z
locale: en-us
document_id: 1641abc1-342d-63c1-e600-6c601c337c89
document_version_independent_id: 5d0b5d09-39ee-479a-04e0-f4b98bbe458b
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/how-to-continuous-patching.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/how-to-continuous-patching
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/how-to-continuous-patching.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: ee891bc0-d1d5-84fc-a612-5f8608a60487
---

# Configure Continuous Patching in Azure Container Registry - Azure Container Registry | Microsoft Learn

In this article, you learn how to install, enable, and configure continuous patching. Continuous patching when enabled for a container registry will automatically detect and remediate OS (operating system) level vulnerabilities for container images.

## Prerequisites

- You can use the Azure Cloud Shell or a local installation of the Azure CLI with a minimum version of 2.15.0 or later.
- You have an existing Resource Group with an Azure Container Registry (ACR).
- You have an Azure Container Registry with ACR Tasks enabled (ACR Tasks isn't supported in the free tier of ACR).

Run the following command to install the CLI extension:

```azurecli
    az extension add -n acrcssc
```

## Enable the continuous patching workflow

1. Log in to Azure CLI with az login.

    ```azurecli
    az login
    ```
2. Log in to ACR.

    ```azurecli
    az acr login -n <myRegistry>
    ```
3. Run the following command to create a file named `continuouspatching.json`.

    ```azurecli
    cat <<EOF > continuouspatching.json
    {
        "version": "v1",
        "tag-convention" : "<incremental|floating>",
        "repositories": [{
            "repository": "<Repository Name>",
            "tags": ["<comma-separated-tags>"],   
            "enabled": <true|false>
        }] 
    }
    EOF
    ```

    The schema ingests specific repositories and tags in an array format. Each variable is defined here:

    - `version` allows the ACR team to track what schema version you're on. Don't change this variable unless instructed to.
    - `tag-convention` is an optional field. Allowed values are "incremental" or "floating" - refer to [Key Concepts of Continuous Patching](key-concept-continuous-patching) for more information.
    - `repositories` is an array that consists detailed repository and tag information:

        - `repository` refers to repository name
        - `tags` is an array of tags separated by commas. The wildcard `*` can be used to signify all tags within that repository.
        - `enabled` is a Boolean value of true or false determining if the specified repo is enabled or not.

    The example below shows a configuration for a customer who wants to patch all tags (use the \* symbol) within the repository `python`, and to patch specifically the `jammy-20240111` and `jammy-20240125` tags in the repository `ubuntu`.

    ```json
    {
    "version": "v1",
    "tag-convention" : "incremental",
    "repositories": [{
            "repository": "python",
            "tags": ["*"],
            "enabled": true
        },
        {
            "repository": "ubuntu",
            "tags": ["jammy-20240111", "jammy-20240125"],
         "enabled": true, 
        }]
    }
    ```
4. After creating your configuration file, execute a dry run to verify the intended artifacts are selected by the JSON criteria. The dry run requires a parameter called `schedule`, which specifies how often your continuous patching cycle runs. The schedule flag is measured in days, with a minimum value of one day, and a maximum value of 30 days. For example, if you want an image to be patched everyday, you would specify schedule as `1d`, or 1 day. If you want a weekly patch (once a week), you would fill schedule as `7d`, or 7 days.

    ```azurecli
    az acr supply-chain workflow create -r myRegistry -g myResourceGroup -t continuouspatchv1 --config ./continuouspatching.json --schedule 1d --dry-run   
    ```

    The `--dry-run` flag outputs all specified artifacts by the JSON file configuration. Verify that the right artifacts are selected. With the sample ubuntu configuration, the following results should be displayed as output:

    ```azurecli
    Ubuntu: jammy-20240111
    Ubuntu: jammy-20240125
    ```
5. Once satisfied with the dry-run results, run the `create` command again without the `--dry-run` flag to create your continuous patching workflow.

    Note

    The `--schedule` parameter follows a fixed-day multiplier starting from day 1 of the month. This means:

    - If you specify `--schedule 7d` and run the command on the 3rd, the next scheduled run will be on the 7th—because 7 is the first multiple of 7 (days) after the 3rd, counting from day 1 of the month.
    - If `--schedule` is 3d and today is the 7th, then the next scheduled run lands on the 9th—since 9 is the next multiple of 3 that follows 7.
    - If you add the flag `--run-immediately`, you trigger an immediate patch run. The subsequent scheduled run will still be aligned to the nearest day multiple from the first of the month, based on your `--schedule` value.
    - The schedule counter **resets** every month. Regardless of the designated schedule, your workflow will run on the first of every month, then follow the specified schedule value for the remainder of the month. If my patching runs on January 28, and my schedule is 7d, my next patch will run on February first, then eighth, and continue following the 7 days.

    ```azurecli
    az acr supply-chain workflow create -r myRegistry -g myResourceGroup -t continuouspatchv1 --config ./continuouspatching.json --schedule 1d --run-immediately
    ```

    Upon a successful command (whether or not you include `--run-immediately`), you see a success message confirming that your workflow tasks are queued. You also see an output parameter indicating when the next run of your workflow is scheduled, so you can track exactly when patching will occur again.

## Use Azure portal to view workflow tasks

1. Once the workflow succeeds, go to the Azure portal to view your running tasks. In the service menu, under **Services**, select **Repositories**. You should see a new repository named `csscpolicies/patchpolicy`. This repository hosts the JSON configuration artifact that is continuously referenced for continuous patching.
2. Next, under **Services**, select **Tasks**. You should see three new tasks:

    - `cssc-trigger-workflow` - this task scans the configuration file and calls the scan task on each respective image.
    - `cssc-scan-image` - this task scans the image for operating system vulnerabilities. This task triggers the patching task only if operating system vulnerabilities were found.
    - `cssc-patch-image` - this task patches the image.

    These tasks work in conjunction to execute your continuous patching workflow.
3. To see specific task runs, select **Runs**. Here you can view status information on whether the task succeeded or failed, along with viewing a debug log.

[![Screenshot that shows tasks run for continuous patching.](media/continuous-patching-media/portal-runs-1.png)](media/continuous-patching-media/portal-runs-1.png#lightbox)

## Use CLI to view workflow tasks

You can also run the following CLI show command to see more details on each task and the general workflow. The command outputs the schedule, creation date, and system data such as last modified date.

For example:

```azurecli
az acr supply-chain workflow show -r myRegistry -g myResourceGroup -t continuouspatchv1 
```

To see all required and optional flags, use the help command:

```azurecli
az acr supply-chain workflow show --help
```

## Update the continuous patching workflow

To make edits to your continuous patching workflow, use the update command. You can update your schedule or JSON config schema with the update CLI command directly. For example:

```azurecli
az acr supply-chain workflow update -r myRegistry -g myResourceGroup -t continuouspatchv1 --config ./continuouspatching.json --schedule 1d
```

To update your schedule, run the previous command with a new input for schedule. To update your JSON configuration, we recommend making changes to the file, running a dry-run, and then running the update command.

## Delete the continuous patching workflow

To delete the continuous patching workflow, run the following CLI command:

```azurecli
az acr supply-chain workflow delete -r myregistry -g myresourcegroup -t continuouspatchv1
```

Once a workflow is successfully deleted, the repository "csscpolicies/patchpolicy” will be automatically deleted. The three tasks that run your workflow will be deleted as well, along with any currently queued runs.

## Troubleshoot continuous patching

Review these tips to troubleshoot problems you may encounter with continuous patching.

### List Running Tasks

To get important debugging information, use the following command to list the most recently executed continuous patching tasks:

```azurecli
az acr supply-chain workflow list -r <registryname> -g <resourcegroup> [--run-status <failed || successful || running>] -t continuouspatchv1
```

A successful result will return the following information:

- Image name and tag
- Workflow type
- Scan status
- Last scan date and time (if status failed, date would be left blank)
- Scan task ID (for further debugging)
- Patch Status
- Last patch date and time (if status failed, date would be left blank)
- Patched image name + tag
- Patch task ID (for further debugging)

Use [--run-status] to return all task statuses that match the specified filter. For example, if you specify `--run-status failed`, only images which have failed their patching will be listed.

### Cancel running tasks

Certain scenarios may require you to cancel tasks which are currently running or waiting to run. For example, you might see a misconfiguration you’d prefer to fix right away, rather than waiting for the patch tasks to complete.

To cancel running tasks, use the following CLI command:

```azurecli
az acr supply-chain workflow cancel-run -r <registryname> -g <resourcegroup> --type <continuouspatchv1>
```

This command cancels all continuous patching tasks with a status of `Running`, `Queued`, or `Started` for the current schedule. For example, if you cancel tasks on a daily schedule (`--schedule 1d`), tasks in those states are canceled for that day, then scheduled again for the next day. If your schedule is weekly, canceled tasks appear again the following week.

### Find failed tasks

Use the task list command to output all failed tasks. Specifying the `cssc-patch` command is best for failure.

For example, this command returns the top 10 failed patch tasks:

```azurecli
az acr task list-runs -r <registryname> -n cssc-patch-image --run-status Failed --top 10
```

To investigate a specific failure, note the `runID` that's returned from this command and run:

```azurecli
az acr task logs -r <registryname> --run-id <run-id>
```

### Cancel misconfigured workflow

Cancel queued tasks with the cancel command:

```azurecli
az acr supply-chain workflow cancel-run -r <registryname> -g <resourcegroup> --type <continuouspatchv1>
```