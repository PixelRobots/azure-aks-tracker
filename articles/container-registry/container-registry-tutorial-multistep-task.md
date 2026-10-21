---
layout: Conceptual
title: Tutorial - Configure Multi-Step ACR Tasks - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-multistep-task
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
description: Learn how to configure an Azure Container Registry Task to trigger a multi-step workflow to build, run, and push container images on code commit.
ms.topic: tutorial
ms.date: 2023-10-31T00:00:00.0000000Z
ms.custom: mvc, devx-track-azurecli
locale: en-us
document_id: f372f56b-d34e-8980-0cb2-e0b6d3aed2eb
document_version_independent_id: c62dfd8b-1140-48db-90c7-1dc4edf7ac29
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-tutorial-multistep-task.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: container-registry/container-registry-tutorial-multistep-task
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-tutorial-multistep-task.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: d5723cfb-0621-279b-fb08-5a8bd18f2f8a
---

# Tutorial - Configure Multi-Step ACR Tasks - Azure Container Registry | Microsoft Learn

In addition to a [quick task](container-registry-tutorial-quick-task), ACR Tasks supports multi-step, multi-container-based workflows that can automatically trigger when you commit source code to a Git repository.

In this tutorial, you learn how to use example YAML files to define multi-step tasks that build, run, and push one or more container images to a registry when you commit source code. To create a task that only automates a single image build on code commit, see [Tutorial: Automate container image builds in the cloud when you commit source code](container-registry-tutorial-build-task). For an overview of ACR Tasks, see [Automate OS and framework patching with ACR Tasks](container-registry-tasks-overview),

In this tutorial:

- Define a multi-step task using a YAML file
- Create a task
- Optionally add credentials to the task to enable access to another registry
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

## Create a multi-step task

Now that you've completed the steps required to enable ACR Tasks to read commit status and create webhooks in a repository, create a multi-step task that triggers building, running, and pushing a container image.

### YAML file

You define the steps for a multi-step task in a [YAML file](container-registry-tasks-reference-yaml). The first example multi-step task for this tutorial is defined in the file `taskmulti.yaml`, which is in the root of the GitHub repo that you cloned:

```yml
version: v1.1.0
steps:
# Build target image
- build: -t {{.Run.Registry}}/hello-world:{{.Run.ID}} -f Dockerfile .
# Run image 
- cmd: -t {{.Run.Registry}}/hello-world:{{.Run.ID}}
  id: test
  detach: true
  ports: ["8080:80"]
- cmd: docker stop test
# Push image
- push:
  - {{.Run.Registry}}/hello-world:{{.Run.ID}}
```

This multi-step task does the following:

1. Runs a `build` step to build an image from the Dockerfile in the working directory. The image targets the `Run.Registry`, the registry where the task is run, and is tagged with a unique ACR Tasks run ID.
2. Runs a `cmd` step to run the image in a temporary container. This example starts a long-running container in the background and returns the container ID, then stops the container. In a real-world scenario, you might include steps to test the running container to ensure it runs correctly.
3. In a `push` step, pushes the image that was built to the run registry.

### Task command

First, populate these shell environment variables with values appropriate for your environment. This step isn't strictly required, but makes executing the multiline Azure CLI commands in this tutorial a bit easier. If you don't populate these environment variables, you must manually replace each value wherever it appears in the example commands.

```console
ACR_NAME=<registry-name>        # The name of your Azure container registry
GIT_USER=<github-username>      # Your GitHub user account name
GIT_PAT=<personal-access-token> # The PAT you generated in the previous section
```

Now, create the task by executing the following [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create) command:

```azurecli
az acr task create \
    --registry $ACR_NAME \
    --name example1 \
    --context https://github.com/$GIT_USER/acr-build-helloworld-node.git#main \
    --file taskmulti.yaml \
    --git-access-token $GIT_PAT
```

This task specifies that any time code is committed to the *main* branch in the repository specified by `--context`, ACR Tasks will run the multi-step task from the code in that branch. The YAML file specified by `--file` from the repository root defines the steps.

Output from a successful [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create) command is similar to the following:

```output
{
  "agentConfiguration": {
    "cpu": 2
  },
  "creationDate": "2023-11-20T03:14:31.763887+00:00",
  "credentials": null,
  "id": "/subscriptions/<Subscription ID>/resourceGroups/myregistry/providers/Microsoft.ContainerRegistry/registries/myregistry/tasks/taskmulti",
  "location": "westus",
  "name": "example1",
  "platform": {
    "architecture": "amd64",
    "os": "linux",
    "variant": null
  },
  "provisioningState": "Succeeded",
  "resourceGroup": "myresourcegroup",
  "status": "Enabled",
  "step": {
    "baseImageDependencies": null,
    "contextAccessToken": null,
    "contextPath": "https://github.com/gituser/acr-build-helloworld-node.git#main",
    "taskFilePath": "taskmulti.yaml",
    "type": "FileTask",
    "values": [],
    "valuesFilePath": null
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
          "repositoryUrl": "https://github.com/gituser/acr-build-helloworld-node.git#main",
          "sourceControlAuthProperties": null,
          "sourceControlType": "Github"
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

## Test the multi-step workflow

To test the multi-step task, trigger it manually by executing the [az acr task run](/en-us/cli/azure/acr/task#az-acr-task-run) command:

```azurecli
az acr task run --registry $ACR_NAME --name example1
```

By default, the `az acr task run` command streams the log output to your console when you execute the command. The output shows the progress of running each of the task steps. The output below is condensed to show key steps.

```output
Queued a run with ID: cab
Waiting for an agent...
2023/11/20 00:03:31 Downloading source code...
2023/11/20 00:03:33 Finished downloading source code
2023/11/20 00:03:33 Using acb_vol_cfe6bd55-3076-4215-8091-6a81aec3d1b1 as the home volume
2023/11/20 00:03:33 Creating Docker network: acb_default_network, driver: 'bridge'
2023/11/20 00:03:34 Successfully set up Docker network: acb_default_network
2023/11/20 00:03:34 Setting up Docker configuration...
2023/11/20 00:03:34 Successfully set up Docker configuration
2023/11/20 00:03:34 Logging in to registry: myregistry.azurecr.io
2023/11/20 00:03:35 Successfully logged into myregistry.azurecr.io
2023/11/20 00:03:35 Executing step ID: acb_step_0. Working directory: '', Network: 'acb_default_network'
2023/11/20 00:03:35 Scanning for dependencies...
2023/11/20 00:03:36 Successfully scanned dependencies
2023/11/20 00:03:36 Launching container with name: acb_step_0
Sending build context to Docker daemon  24.06kB
[...]
Successfully built f669bfd170af
Successfully tagged myregistry.azurecr.io/hello-world:cf19
2023/11/20 00:03:43 Successfully executed container: acb_step_0
2023/11/20 00:03:43 Executing step ID: acb_step_1. Working directory: '', Network: 'acb_default_network'
2023/11/20 00:03:43 Launching container with name: acb_step_1
279b1cb6e092b64c8517c5506fcb45494cd5a0bd10a6beca3ba97f25c5d940cd
2023/11/20 00:03:44 Successfully executed container: acb_step_1
2023/11/20 00:03:44 Executing step ID: acb_step_2. Working directory: '', Network: 'acb_default_network'
2023/11/20 00:03:44 Pushing image: myregistry.azurecr.io/hello-world:cf19, attempt 1
[...]
2023/11/20 00:03:46 Successfully pushed image: myregistry.azurecr.io/hello-world:cf19
2023/11/20 00:03:46 Step ID: acb_step_0 marked as successful (elapsed time in seconds: 7.425169)
2023/11/20 00:03:46 Populating digests for step ID: acb_step_0...
2023/11/20 00:03:47 Successfully populated digests for step ID: acb_step_0
2023/11/20 00:03:47 Step ID: acb_step_1 marked as successful (elapsed time in seconds: 0.827129)
2023/11/20 00:03:47 Step ID: acb_step_2 marked as successful (elapsed time in seconds: 2.112113)
2023/11/20 00:03:47 The following dependencies were found:
2023/11/20 00:03:47
- image:
    registry: myregistry.azurecr.io
    repository: hello-world
    tag: cf19
    digest: sha256:6b981a8ca8596e840228c974c929db05c0727d8630465de536be74104693467a
  runtime-dependency:
    registry: registry.hub.docker.com
    repository: library/node
    tag: 15-alpine
    digest: sha256:8dafc0968fb4d62834d9b826d85a8feecc69bd72cd51723c62c7db67c6dec6fa
  git:
    git-head-revision: 1a3065388a0238e52865db1c8f3e97492a43444c

Run ID: cab was successful after 18s
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

Once you've pushed a commit to your repository, the webhook created by ACR Tasks fires and kicks off the task in Azure Container Registry. Display the logs for the currently running task to verify and monitor the build progress:

```azurecli
az acr task logs --registry $ACR_NAME
```

Output is similar to the following, showing the currently executing (or last-executed) task:

```output
Showing logs of the last created run.
Run ID: cad

[...]

Run ID: cad was successful after 37s
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
cad       example1        linux       Succeeded  Commit     2023-11-20T00:22:15Z  00:00:35
cac       taskhelloworld  linux       Succeeded  Commit     2023-11-20T00:22:15Z  00:00:22
cab       example1        linux       Succeeded  Manual     2023-11-20T00:18:36Z  00:00:47
```

## Create a multi-registry multi-step task

ACR Tasks by default has permissions to push or pull images from the registry where the task runs. You might want to run a multi-step task that targets one or more registries in addition to the run registry. For example, you might need to build images in one registry, and store images with different tags in a second registry that is accessed by a production system. This example shows you how to create such a task and provide credentials for another registry.

If you don't already have a second registry, create one for this example. If you need a registry, see the [previous tutorial](container-registry-tutorial-quick-task), or [Quickstart: Create a container registry using the Azure CLI](container-registry-get-started-azure-cli).

To create the task, you need the name of the registry login server, which is of the form *mycontainerregistrydate.azurecr.io* (all lowercase). In this example, you use the second registry to store images tagged by build date.

### YAML file

The second example multi-step task for this tutorial is defined in the file `taskmulti-multiregistry.yaml`, which is in the root of the GitHub repo that you cloned:

```yml
version: v1.1.0
steps:
# Build target images
- build: -t {{.Run.Registry}}/hello-world:{{.Run.ID}} -f Dockerfile .
- build: -t {{.Values.regDate}}/hello-world:{{.Run.Date}} -f Dockerfile .
# Run image 
- cmd: -t {{.Run.Registry}}/hello-world:{{.Run.ID}}
  id: test
  detach: true
  ports: ["8080:80"]
- cmd: docker stop test
# Push images
- push:
  - {{.Run.Registry}}/hello-world:{{.Run.ID}}
  - {{.Values.regDate}}/hello-world:{{.Run.Date}}
```

This multi-step task does the following:

1. Runs two `build`steps to build images from the Dockerfile in the working directory:
    - The first targets the `Run.Registry`, the registry where the task is run, and is tagged with the ACR Tasks run ID.
    - The second targets the registry identified by the value of `regDate`, which you set when you create the task (or provide through an external `values.yaml` file passed to `az acr task create`). This image is tagged with the run date.
2. Runs a `cmd` step to run one of the built containers. This example starts a long-running container in the background and returns the container ID, then stops the container. In a real-world scenario, you might test a running container to ensure it runs correctly.
3. In a `push` step, pushes the images that were built, the first to the run registry, the second to the registry identified by `regDate`.

### Task command

Using the shell environment variables defined previously, create the task by executing the following [az acr task create](/en-us/cli/azure/acr/task#az-acr-task-create) command. Substitute the name of your registry for *mycontainerregistrydate*.

```azurecli
az acr task create \
    --registry $ACR_NAME \
    --name example2 \
    --context https://github.com/$GIT_USER/acr-build-helloworld-node.git#main \
    --file taskmulti-multiregistry.yaml \
    --git-access-token $GIT_PAT \
    --set regDate=mycontainerregistrydate.azurecr.io
```

### Add task credential

To push images to the registry identified by the value of `regDate`, use the [az acr task credential add](/en-us/cli/azure/acr/task/credential#az-acr-task-credential-add) command to add login credentials for that registry to the task.

For this example, we recommend that you create a [service principal](container-registry-auth-service-principal) with permissions to push images to the registry. To grant push permissions, assign the `Container Registry Repository Writer` role for registries enabled for Microsoft Entra attribute-based access control (ABAC) for managing [Microsoft Entra-based repository permissions](container-registry-rbac-abac-repository-permissions). Otherwise, for non-ABAC registries, assign the `AcrPush` role.

To create the service principal, use the following script:

```azurecli
#!/bin/bash
# This script requires Azure CLI version 2.25.0 or later. Check version with `az --version`.

# Modify for your environment.
# ACR_NAME: The name of your Azure Container Registry
# SERVICE_PRINCIPAL_NAME: Must be unique within your AD tenant
ACR_NAME=$containerRegistry
SERVICE_PRINCIPAL_NAME=$servicePrincipal

# Obtain the full registry ID
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query "id" --output tsv)
# echo $registryId

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
echo "Service principal ID: $USER_NAME"
echo "Service principal password: $PASSWORD"
```

Pass the service principal application ID and password in the following `az acr task credential add` command. Be sure to update the login server name *mycontainerregistrydate* with the name of your second registry:

```azurecli
az acr task credential add --name example2 \
    --registry $ACR_NAME \
    --login-server mycontainerregistrydate.azurecr.io \
    --username <service-principal-application-id> \
    --password <service-principal-password>
```

The CLI returns the name of the registry login server you added.

### Test the multi-step workflow

As in the preceding example, to test the multi-step task, trigger it manually by executing the [az acr task run](/en-us/cli/azure/acr/task#az-acr-task-run) command. To trigger the task with a commit to the Git repository, see the section Trigger a build with a commit.

```azurecli
az acr task run --registry $ACR_NAME --name example2
```

By default, the `az acr task run` command streams the log output to your console when you execute the command. As before, the output shows the progress of running each of the task steps. The output is condensed to show key steps.

Output:

```output
Queued a run with ID: cf1g
Waiting for an agent...
2023/11/20 04:33:39 Downloading source code...
2023/11/20 04:33:41 Finished downloading source code
2023/11/20 04:33:42 Using acb_vol_4569b017-29fe-42bd-83b2-25c45a8ac807 as the home volume
2023/11/20 04:33:42 Creating Docker network: acb_default_network, driver: 'bridge'
2023/11/20 04:33:43 Successfully set up Docker network: acb_default_network
2023/11/20 04:33:43 Setting up Docker configuration...
2023/11/20 04:33:44 Successfully set up Docker configuration
2023/11/20 04:33:44 Logging in to registry: mycontainerregistry.azurecr.io
2023/11/20 04:33:45 Successfully logged into mycontainerregistry.azurecr.io
2023/11/20 04:33:45 Logging in to registry: mycontainerregistrydate.azurecr.io
2023/11/20 04:33:47 Successfully logged into mycontainerregistrydate.azurecr.io
2023/11/20 04:33:47 Executing step ID: acb_step_0. Working directory: '', Network: 'acb_default_network'
2023/11/20 04:33:47 Scanning for dependencies...
2023/11/20 04:33:47 Successfully scanned dependencies
2023/11/20 04:33:47 Launching container with name: acb_step_0
Sending build context to Docker daemon  25.09kB
[...]
Successfully tagged mycontainerregistry.azurecr.io/hello-world:cf1g
2023/11/20 04:33:55 Successfully executed container: acb_step_0
2023/11/20 04:33:55 Executing step ID: acb_step_1. Working directory: '', Network: 'acb_default_network'
2023/11/20 04:33:55 Scanning for dependencies...
2023/11/20 04:33:56 Successfully scanned dependencies
2023/11/20 04:33:56 Launching container with name: acb_step_1
Sending build context to Docker daemon  25.09kB
[...]
Successfully tagged mycontainerregistrydate.azurecr.io/hello-world:20230503-043342z
2023/11/20 04:33:57 Successfully executed container: acb_step_1
2023/11/20 04:33:57 Executing step ID: acb_step_2. Working directory: '', Network: 'acb_default_network'
2023/11/20 04:33:57 Launching container with name: acb_step_2
721437ff674051b6be63cbcd2fa8eb085eacbf38d7d632f1a079320133182101
2023/11/20 04:33:58 Successfully executed container: acb_step_2
2023/11/20 04:33:58 Executing step ID: acb_step_3. Working directory: '', Network: 'acb_default_network'
2023/11/20 04:33:58 Launching container with name: acb_step_3
test
2023/11/20 04:34:09 Successfully executed container: acb_step_3
2023/11/20 04:34:09 Executing step ID: acb_step_4. Working directory: '', Network: 'acb_default_network'
2023/11/20 04:34:09 Pushing image: mycontainerregistry.azurecr.io/hello-world:cf1g, attempt 1
The push refers to repository [mycontainerregistry.azurecr.io/hello-world]
[...]
2023/11/20 04:34:12 Successfully pushed image: mycontainerregistry.azurecr.io/hello-world:cf1g
2023/11/20 04:34:12 Pushing image: mycontainerregistrydate.azurecr.io/hello-world:20230503-043342z, attempt 1
The push refers to repository [mycontainerregistrydate.azurecr.io/hello-world]
[...]
2023/11/20 04:34:19 Successfully pushed image: mycontainerregistrydate.azurecr.io/hello-world:20230503-043342z
2023/11/20 04:34:19 Step ID: acb_step_0 marked as successful (elapsed time in seconds: 8.125744)
2023/11/20 04:34:19 Populating digests for step ID: acb_step_0...
2023/11/20 04:34:21 Successfully populated digests for step ID: acb_step_0
2023/11/20 04:34:21 Step ID: acb_step_1 marked as successful (elapsed time in seconds: 2.009281)
2023/11/20 04:34:21 Populating digests for step ID: acb_step_1...
2023/11/20 04:34:23 Successfully populated digests for step ID: acb_step_1
2023/11/20 04:34:23 Step ID: acb_step_2 marked as successful (elapsed time in seconds: 0.795440)
2023/11/20 04:34:23 Step ID: acb_step_3 marked as successful (elapsed time in seconds: 11.446775)
2023/11/20 04:34:23 Step ID: acb_step_4 marked as successful (elapsed time in seconds: 9.734973)
2023/11/20 04:34:23 The following dependencies were found:
2023/11/20 04:34:23
- image:
    registry: mycontainerregistry.azurecr.io
    repository: hello-world
    tag: cf1g
    digest: sha256:75354e9edb995e8661438bad9913deed87a185fddd0193811f916d684b71a5d2
  runtime-dependency:
    registry: registry.hub.docker.com
    repository: library/node
    tag: 15-alpine
    digest: sha256:8dafc0968fb4d62834d9b826d85a8feecc69bd72cd51723c62c7db67c6dec6fa
  git:
    git-head-revision: 9d9023473c46a5e2c315681b11eb4552ef0faccc
- image:
    registry: mycontainerregistrydate.azurecr.io
    repository: hello-world
    tag: 20230503-043342z
    digest: sha256:75354e9edb995e8661438bad9913deed87a185fddd0193811f916d684b71a5d2
  runtime-dependency:
    registry: registry.hub.docker.com
    repository: library/node
    tag: 15-alpine
    digest: sha256:8dafc0968fb4d62834d9b826d85a8feecc69bd72cd51723c62c7db67c6dec6fa
  git:
    git-head-revision: 9d9023473c46a5e2c315681b11eb4552ef0faccc

Run ID: cf1g was successful after 46s
```