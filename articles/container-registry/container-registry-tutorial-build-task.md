---
layout: Conceptual
title: Tutorial - Build Container Image on Code Commit in Azure - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-build-task
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
description: Learn to configure Azure Container Registry tasks to trigger container image builds in the cloud on code commits to a Git repository.
ms.topic: tutorial
ms.date: 2023-10-31T00:00:00.0000000Z
ms.custom: mvc, devx-track-azurecli
locale: en-us
document_id: 5f246d4b-b6bc-3058-ebf8-f7964bdf28b9
document_version_independent_id: 6a0db8fa-aa31-258b-7fbe-21482c7f81c6
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-tutorial-build-task.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-tutorial-build-task
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-tutorial-build-task.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 3d657df0-46d2-fb89-6d9f-87c83a08f26d
---

# Tutorial - Build Container Image on Code Commit in Azure - Azure Container Registry | Microsoft Learn

In addition to a [quick task](container-registry-tutorial-quick-task), ACR Tasks supports automated Docker container image builds in the cloud when you commit source code to a Git repository. Supported Git contexts for ACR Tasks include public or private GitHub or Azure Repos.

Note

Currently, ACR Tasks doesn't support commit or pull request triggers in GitHub Enterprise repos.

In this tutorial, your ACR task builds and pushes a single container image specified in a Dockerfile when you commit source code to a Git repo. To create a [multi-step task](container-registry-tasks-multi-step) that uses a YAML file to define steps to build, push, and optionally test multiple containers on code commit, see [Tutorial: Run a multi-step container workflow in the cloud when you commit source code](container-registry-tutorial-multistep-task). For an overview of ACR Tasks, see [Automate OS and framework patching with ACR Tasks](container-registry-tasks-overview)

In this tutorial:

- Create a task
- Test the task
- View task status
- Trigger the task with a code commit

This tutorial assumes you've already completed the steps in the [previous tutorial](container-registry-tutorial-quick-task). If you haven't already done so, complete the steps in the [Prerequisites](container-registry-tutorial-quick-task#prerequisites) section of the previous tutorial before proceeding.

## Prerequisites

### Get sample code

This tutorial assumes you've already completed the steps in the [previous tutorial](container-registry-tutorial-quick-task), and have forked and cloned the sample repository. If you haven't already done so, complete the steps in the [Prerequisites](container-registry-tutorial-quick-task#prerequisites) section of the previous tutorial before proceeding.

### Container registry

You must have an Azure container registry in your Azure subscription to complete this tutorial. If you need a registry, see the [previous tutorial](container-registry-tutorial-quick-task), or [Quickstart: Create a container registry using the Azure CLI](container-registry-get-started-azure-cli).

### Create a GitHub personal access token

To trigger a task on a commit to a Git repository, ACR Tasks need a [personal access token (PAT)](container-registry-tasks-overview#personal-access-token) to access the repository. If you don't already have a PAT, follow these steps to generate one in GitHub:

1. Go to the [personal access token creation page on GitHub](https://github.com/settings/tokens/new).
2. Enter a short **description** for the token, for example, "ACR Tasks Demo"
3. Select scopes for ACR to access the repo. To access a public repo as in this tutorial, under **repo**, enable **repo:status** and **public\_repo**

    ![Screenshot of the Personal Access Token generation page in GitHub](includes/media/container-registry-task-tutorial-prereq/build-task-01-new-token.png)

    Note

    To generate a PAT to access a *private* repo, select the scope for full **repo** control.
4. Select the **Generate token** button (you may be asked to confirm your password)
5. Copy and save the generated token in a **secure location** (you use this token when you define a task in the following section)

    ![Screenshot of the generated Personal Access Token in GitHub](includes/media/container-registry-task-tutorial-prereq/build-task-02-generated-token.png)

### Prepare your environment for the Azure CLI

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

## Create the build task

Now that you've completed the steps required to enable ACR Tasks to read commit status and create webhooks in a repository, you can create a task that triggers a container image build on commits to the repo.

First, populate these shell environment variables with values appropriate for your environment. This step isn't strictly required, but makes executing the multiline Azure CLI commands in this tutorial a bit easier. If you don't populate these environment variables, you must manually replace each value wherever it appears in the example commands.

```console
ACR_NAME=<registry-name>        # The name of your Azure container registry
GIT_USER=<github-username>      # Your GitHub user account name
GIT_PAT=<personal-access-token> # The PAT you generated in the previous section
```

Now, create the task by executing the following [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create) command.

Note

The Dockerfile used in the following example depends on a public base container image from Docker Hub. To improve reliability when using public content, import and manage the image in a private Azure container registry, and update your Dockerfile to use your privately managed base image. [Learn more about working with public images](buffer-gate-public-content).

```azurecli
az acr task create \
    --registry $ACR_NAME \
    --name taskhelloworld \
    --image helloworld:{{.Run.ID}} \
    --context https://github.com/$GIT_USER/acr-build-helloworld-node.git#master \
    --file Dockerfile \
    --git-access-token $GIT_PAT
```

This task specifies that any time code is committed to the *main* branch in the repository specified by `--context`, ACR Tasks will build the container image from the code in that branch. The Dockerfile specified by `--file` from the repository root is used to build the image. The `--image` argument specifies a parameterized value of `{{.Run.ID}}` for the version portion of the image's tag, ensuring the built image correlates to a specific build, and is tagged uniquely.

Output from a successful [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create) command is similar to the following:

```output
{
  "agentConfiguration": {
    "cpu": 2
  },
  "creationDate": "2010-11-19T22:42:32.972298+00:00",
  "id": "/subscriptions/<Subscription ID>/resourceGroups/myregistry/providers/Microsoft.ContainerRegistry/registries/myregistry/tasks/taskhelloworld",
  "location": "westcentralus",
  "name": "taskhelloworld",
  "platform": {
    "architecture": "amd64",
    "os": "Linux",
    "variant": null
  },
  "provisioningState": "Succeeded",
  "resourceGroup": "myregistry",
  "status": "Enabled",
  "step": {
    "arguments": [],
    "baseImageDependencies": null,
    "contextPath": "https://github.com/gituser/acr-build-helloworld-node#main",
    "dockerFilePath": "Dockerfile",
    "imageNames": [
      "helloworld:{{.Run.ID}}"
    ],
    "isPushEnabled": true,
    "noCache": false,
    "type": "Docker"
  },
  "tags": null,
  "timeout": 3600,
  "trigger": {
    "baseImageTrigger": {
      "baseImageTriggerType": "Runtime",
      "name": "defaultBaseimageTriggerName",
      "status": "Enabled"
    },
    "sourceTriggers": [
      {
        "name": "defaultSourceTriggerName",
        "sourceRepository": {
          "branch": "main",
          "repositoryUrl": "https://github.com/gituser/acr-build-helloworld-node#main",
          "sourceControlAuthProperties": null,
          "sourceControlType": "GitHub"
        },
        "sourceTriggerEvents": [
          "commit"
        ],
        "status": "Enabled"
      }
    ]
  },
  "type": "Microsoft.ContainerRegistry/registries/tasks"
}
```

## Test the build task

You now have a task that defines your build. To test the build pipeline, trigger a build manually by executing the [az acr task run](/en-us/cli/azure/acr/task#az-acr-task-run) command:

```azurecli
az acr task run --registry $ACR_NAME --name taskhelloworld
```

By default, the `az acr task run` command streams the log output to your console when you execute the command. The output is condensed to show key steps.

```output
2023/11/19 22:51:00 Using acb_vol_9ee1f28c-4fd4-43c8-a651-f0ed027bbf0e as the home volume
2023/11/19 22:51:00 Setting up Docker configuration...
2023/11/19 22:51:02 Successfully set up Docker configuration
2023/11/19 22:51:02 Logging in to registry: myregistry.azurecr.io
2023/11/19 22:51:03 Successfully logged in
2023/11/19 22:51:03 Executing step: build
2023/11/19 22:51:03 Obtaining source code and scanning for dependencies...
2023/11/19 22:51:05 Successfully obtained source code and scanned for dependencies
Sending build context to Docker daemon  23.04kB
Step 1/5 : FROM node:15-alpine
[...]
Step 5/5 : CMD ["node", "/src/server.js"]
 ---> Running in 7382eea2a56a
Removing intermediate container 7382eea2a56a
 ---> e33cd684027b
Successfully built e33cd684027b
Successfully tagged myregistry.azurecr.io/helloworld:da2
2023/11/19 22:51:11 Executing step: push
2023/11/19 22:51:11 Pushing image: myregistry.azurecr.io/helloworld:da2, attempt 1
The push refers to repository [myregistry.azurecr.io/helloworld]
4a853682c993: Preparing
[...]
4a853682c993: Pushed
[...]
da2: digest: sha256:c24e62fd848544a5a87f06ea60109dbef9624d03b1124bfe03e1d2c11fd62419 size: 1366
2023/11/19 22:51:21 Successfully pushed image: myregistry.azurecr.io/helloworld:da2
2023/11/19 22:51:21 Step id: build marked as successful (elapsed time in seconds: 7.198937)
2023/11/19 22:51:21 Populating digests for step id: build...
2023/11/19 22:51:22 Successfully populated digests for step id: build
2023/11/19 22:51:22 Step id: push marked as successful (elapsed time in seconds: 10.180456)
The following dependencies were found:
- image:
    registry: myregistry.azurecr.io
    repository: helloworld
    tag: da2
    digest: sha256:c24e62fd848544a5a87f06ea60109dbef9624d03b1124bfe03e1d2c11fd62419
  runtime-dependency:
    registry: registry.hub.docker.com
    repository: library/node
    tag: 9-alpine
    digest: sha256:8dafc0968fb4d62834d9b826d85a8feecc69bd72cd51723c62c7db67c6dec6fa
  git:
    git-head-revision: 68cdf2a37cdae0873b8e2f1c4d80ca60541029bf

Run ID: ca6 was successful after 27s
```

## Trigger a build with a commit

Now that you've tested the task by manually running it, trigger it automatically with a source code change.

First, ensure you're in the directory containing your local clone of the [repository](https://github.com/Azure-Samples/acr-build-helloworld-node):

```console
cd acr-build-helloworld-node
```

Next, execute the following commands to create, commit, and push a new file to your fork of the repo on GitHub:

```console
echo "Hello World!" > hello.txt
git add hello.txt
git commit -m "Testing ACR Tasks"
git push origin main
```

You may be asked to provide your GitHub credentials when you execute the `git push` command. Provide your GitHub username, and enter the personal access token (PAT) that you created earlier for the password.

```azurecli
Username for 'https://github.com': <github-username>
Password for 'https://githubuser@github.com': <personal-access-token>
```

Once you've pushed a commit to your repository, the webhook created by ACR Tasks fires and kicks off a build in Azure Container Registry. Display the logs for the currently running task to verify and monitor the build progress:

```azurecli
az acr task logs --registry $ACR_NAME
```

Output is similar to the following, showing the currently executing (or last-executed) task:

```output
Showing logs of the last created run.
Run ID: ca7

[...]

Run ID: ca7 was successful after 38s
```

## List builds

To see a list of the task runs that ACR Tasks has completed for your registry, run the [az acr task list-runs](/en-us/cli/azure/acr/task#az-acr-task-list-runs) command:

```azurecli
az acr task list-runs --registry $ACR_NAME --output table
```

Output from the command should appear similar to the following. The runs that ACR Tasks has executed are displayed, and "Git Commit" appears in the TRIGGER column for the most recent task:

```output
RUN ID    TASK            PLATFORM    STATUS     TRIGGER    STARTED               DURATION
--------  --------------  ----------  ---------  ---------  --------------------  ----------
ca7       taskhelloworld  linux       Succeeded  Commit     2023-11-19T22:54:34Z  00:00:29
ca6       taskhelloworld  linux       Succeeded  Manual     2023-11-19T22:51:47Z  00:00:24
ca5                       linux       Succeeded  Manual     2023-11-19T22:23:42Z  00:00:23
```