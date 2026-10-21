---
layout: Conceptual
title: Handle AKS node upgrades with GitHub Actions - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/upgrade-github-actions
breadcrumb_path: /azure/breadcrumb/azure-aks/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/200/azure-kubernetes-service/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to schedule automatic node upgrades in Azure Kubernetes Service (AKS) using GitHub Actions.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.subservice: aks-upgrade
ms.date: 2023-10-05T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 05d6a981-857e-f309-6889-df7838d9abbc
document_version_independent_id: b5a0e92d-37e3-dda7-89c3-a215d7236998
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/upgrade-github-actions.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/upgrade-github-actions
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/upgrade-github-actions.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 17ec64a8-eb78-655d-5c96-48b47f16bffc
---

# Handle AKS node upgrades with GitHub Actions - Azure Kubernetes Service | Microsoft Learn

Security updates are a key part of maintaining your AKS cluster's security and compliance with the latest fixes for the underlying OS. These updates include OS security fixes or kernel updates. Some updates require a node reboot to complete the process.

This article shows you how you can automate the update process of AKS nodes using GitHub Actions and Azure CLI to create an update task based on `cron` that runs automatically.

Note

You can also perform node image upgrades automatically and schedule these upgrades using planned maintenance. For more information, see [Automatically upgrade node images](auto-upgrade-node-image).

## Before you begin

- This article assumes you have an existing AKS cluster. If you need an AKS cluster, create one using [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or [the Azure portal](learn/quick-kubernetes-deploy-portal).
- This article also assumes you have a [GitHub account](https://github.com) and a [profile repository](https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-your-github-profile/about-your-profile) to host your actions. If you don't have a repository, create one with the same name as your GitHub username.
- You need the Azure CLI version 2.0.59 or later installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Update nodes with `az aks upgrade`

The `az aks upgrade` command gives you a zero downtime way to apply updates. The command performs the following actions:

1. Applies the latest updates to all your cluster's nodes.
2. Cordons (makes the node unavailable for the scheduling of new workloads) and drains (moves the existent workloads to other node) traffic to the nodes.
3. Restarts the nodes.
4. Enables the updated nodes to receive traffic again.

AKS doesn't automatically restart your nodes if you update them using a different method.

Note

Running `az aks upgrade` with the `--node-image-only` flag only upgrades the node images. Running the command without the flag upgrades both the node images and the Kubernetes control plane version. For more information, see the [docs for managed upgrades on nodes](node-image-upgrade) and the [docs for cluster upgrades](upgrade-cluster).

All Kubernetes nodes run in a standard Windows or Linux-based Azure virtual machine (VM). The Linux-based VMs use an Ubuntu image with the OS configured to automatically check for updates every night.

When you use the `az aks upgrade` command, Azure CLI creates a surge of new nodes with the latest security and kernel updates. These new nodes are initially cordoned to prevent any apps from being scheduled to them until the update completes. After the update completes, Azure cordons and drains the older nodes and uncordons the new ones, transferring all the scheduled applications to the new nodes.

This process is better than updating Linux-based kernels manually because Linux requires a reboot when a new kernel update is installed. If you update the OS manually, you also need to reboot the VM, manually cordoning and draining all the apps.

## Create a timed GitHub Action

`cron` is a utility that allows you to run a set of commands, or *jobs*, on an automated schedule. To create a job to update your AKS nodes on an automated schedule, you need a repository to host your actions. GitHub Actions are usually configured in the same repository as your application, but you can use any repository.

1. Navigate to your repository on GitHub.
2. Select **Actions**.
3. Select **New workflow** &gt; **Set up a workflow yourself**.
4. Create a GitHub Action named *Upgrade cluster node images* with a schedule trigger to run every 15 days at 3am. Copy the following code into the YAML:

    ```yml
    name: Upgrade cluster node images
    on:
      schedule:
        - cron: '0 3 */15 * *'
    ```
5. Create a job named *upgrade-node* that runs on an Ubuntu agent and connects to your Azure CLI account to execute the node upgrade command. Copy the following code into the YAML under the `on` key:

    ```yml
    jobs:
      upgrade-node:
        runs-on: ubuntu-latest
    ```

## Set up the Azure CLI in the workflow

1. In the **Search Marketplace for Actions** bar, search for **Azure Login**.
2. Select **Azure Login**.

    ![Search results showing two lines, the first action is called 'Azure Login' and the second 'Azure Container Registry Login'](media/node-upgrade-github-actions/azure-login-search.png)
3. Under **Installation**, select a version, such as *v1.4.6*, and copy the installation code snippet.
4. Add the `steps` key and the following information from the installation code snippet to the YAML:

    ```yml
    name: Upgrade cluster node images
    on:
      schedule:
        - cron: '0 3 */15 * *'
    jobs:
      upgrade-node:
        runs-on: ubuntu-latest
        steps:
          - name: Azure Login
            uses: Azure/login@v1.4.6
            with:
              creds: ${{ secrets.AZURE_CREDENTIALS }}
    ```

## Create credentials for the Azure CLI

1. In a new browser window, create a new service principal using the [`az ad sp create-for-rbac`](/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac) command. Make sure you replace `*{subscriptionID}*` with your own subscription ID.

    Note

    This example creates the `Contributor` role at the *Subscription* scope. You can provide the role and scope that meets your needs. For more information, see [Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles) and [Azure RBAC scope levels](/en-us/azure/role-based-access-control/scope-overview#scope-format).

    ```azurecli
    az ad sp create-for-rbac --role Contributor --scopes /subscriptions/{subscriptionID} -o json
    ```

    Your output should be similar to the following example output:

    ```output
    {
      "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "displayName": "xxxxx-xxx-xxxx-xx-xx-xx-xx-xx",
      "password": "xxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    }
    ```
2. Copy the output and navigate to your GitHub repository.
3. Select **Settings** &gt; **Secrets and variables** &gt; **Actions** &gt; **New repository secret**.
4. For **Name**, enter `AZURE_CREDENTIALS`.
5. For **Secret**, copy in the contents of the output you received when you created the service principal.
6. Select **Add Secret**.

## Create the steps to execute the Azure CLI commands

1. Navigate to your window with the workflow YAML.
2. In the **Search Marketplace for Actions** bar, search for **Azure CLI Action**.
3. Select **Azure CLI Action**.

    ![Search result for 'Azure CLI Action' with first result being shown as made by Azure](media/node-upgrade-github-actions/azure-cli-action.png)
4. Under **Installation**, select a version, such as *v1.0.8*, and copy the installation code snippet.
5. Paste the contents of the action into the YAML below the `*Azure Login*` step, similar to the following example:

    ```yml
    name: Upgrade cluster node images
    on:
      schedule:
        - cron: '0 3 */15 * *'
    jobs:
      upgrade-node:
        runs-on: ubuntu-latest
        steps:
          - name: Azure Login
            uses: Azure/login@v1.4.6
            with:
              creds: ${{ secrets.AZURE_CREDENTIALS }}
          - name: Upgrade node images
            uses: Azure/cli@v1.0.8
            with:
              inlineScript: az aks upgrade --resource-group <resourceGroupName> --name <aksClusterName> --node-image-only --yes
    ```

    Tip

    You can decouple the `--resource-group` and `--name` parameters from the command by creating new repository secrets like you did for `AZURE_CREDENTIALS`.

    If you create secrets for these parameters, you need to replace the `<resourceGroupName>` and `<aksClusterName>` placeholders with their secret counterparts. For example, `${{secrets.RESOURCE_GROUP_NAME}}` and `${{secrets.AKS_CLUSTER_NAME}}`
6. Rename the YAML to `upgrade-node-images.yml`.
7. Select **Commit changes...**, add a commit message, and then select **Commit changes**.

## Run the GitHub Action manually

You can run the workflow manually in addition to the scheduled run by adding a new `on` trigger called `workflow_dispatch`.

Note

If you want to upgrade a single node pool instead of all node pools on the cluster, add the `--name` parameter to the `az aks nodepool upgrade` command to specify the node pool name. For example:

```azurecli
az aks nodepool upgrade --resource-group <resourceGroupName> --cluster-name <aksClusterName> --name <nodePoolName> --node-image-only
```

- Add the `workflow_dispatch` trigger under the `on` key:

    ```yml
    name: Upgrade cluster node images
    on:
      schedule:
        - cron: '0 3 */15 * *'
      workflow_dispatch:
    ```

    The YAML should look similar to the following example:

    ```yml
        name: Upgrade cluster node images
        on:
          schedule:
            - cron: '0 3 */15 * *'
          workflow_dispatch:
        jobs:
          upgrade-node:
            runs-on: ubuntu-latest
            steps:
              - name: Azure Login
                uses: Azure/login@v1.4.6
                with:
                  creds: ${{ secrets.AZURE_CREDENTIALS }}
              - name: Upgrade node images
                uses: Azure/cli@v1.0.8
                with:
                  inlineScript: az aks upgrade -g {resourceGroupName} -n {aksClusterName} --node-image-only --yes
              # Code for upgrading one or more node pools
    ```