---
layout: Conceptual
title: 'Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using the Azure Developer CLI - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-azd
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
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to quickly deploy a Kubernetes cluster and deploy an application in Azure Kubernetes Service (AKS) using the Azure Developer CLI.
ms.author: schaffererin
author: schaffererin
ms.topic: quickstart
ms.date: 2024-03-21T00:00:00.0000000Z
ms.custom: H1Hack27Feb2017, mvc, devcenter, seo-javascript-september2019, seo-javascript-october2019, seo-python-october2019, contperf-fy21q1, mode-api, devx-track-extended-azdevcli, aks-getting-started
locale: en-us
document_id: d88900ed-f717-eb5b-a988-0be3d2212114
document_version_independent_id: d9a3b9e2-1006-6f94-65c5-0a58469815a7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/learn/quick-kubernetes-deploy-azd.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/learn/quick-kubernetes-deploy-azd
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/learn/quick-kubernetes-deploy-azd.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 6219e2bf-ac2d-41f1-e980-40b5b2e386e1
---

# Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using the Azure Developer CLI - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) is a managed Kubernetes service that lets you quickly deploy and manage clusters. In this quickstart, you learn to:

- Download and install the Azure Developer CLI (`azd`).
- Clone applications from an Azure Developer CLI template (`azd` template).
- Deploy an AKS cluster using the Azure Developer CLI (`azd`).
- Run a sample multi-container application with a group of microservices that simulates a retail app.
- Delete and clean up containers made from the `azd` template.

Note

To get started with quickly provisioning an AKS cluster, this article includes steps to deploy a cluster with default settings for evaluation purposes only. Before deploying a production-ready cluster, we recommend that you familiarize yourself with our [baseline reference architecture](/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json) to consider how it aligns with your business requirements.

## Before you begin

This quickstart assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for Azure Kubernetes Service (AKS)](../concepts-clusters-workloads).

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- For ease of use, run this sample on Bash or PowerShell in the [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Quickstart for Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).
- To use `azd` locally, install version 1.6.1 or later of the [Azure Developer CLI](/en-us/azure/developer/azure-developer-cli/install-azd).

    - If you're using the [Azure Cloud Shell](/en-us/azure/cloud-shell/overview), the latest version of `azd` is already installed.

## Review application code

You can review the application code in the [Azure-Samples/aks-store-demo GitHub repository](https://github.com/Azure-Samples/aks-store-demo).

The quickstart application includes the following Kubernetes deployments and services:

[![Diagram that shows the Azure Store sample architecture.](media/quick-kubernetes-deploy-portal/aks-store-architecture.png)](media/quick-kubernetes-deploy-portal/aks-store-architecture.png#lightbox)

- **Store front**: Web application for customers to view products and place orders.
- **Product service**: Shows product information.
- **Order service**: Places orders.
- **Rabbit MQ**: Message queue for an order queue.

Note

We don't recommend running stateful containers, such as Rabbit MQ, without persistent storage for production use. These are used here for simplicity, but we recommend using managed services instead, such as Azure Cosmos DB or Azure Service Bus.

## Clone the Azure Developer CLI template

1. Clone the AKS store demo template from the **Azure-Samples** repository using the [`azd init`](/en-us/azure/developer/azure-developer-cli/reference#azd-init) command with the `--template` parameter.

    ```azdeveloper
    azd init --template Azure-Samples/aks-store-demo
    ```
2. Enter an environment name for your project that uses only alphanumeric characters and hyphens, such as *aks-azdqs-1*.

    ```output
    Enter a new environment name: aks-azdqs-1
    ```

## Sign in to your Azure Cloud account

The `azd` template contains all the code needed to create the services, but you need to sign in to your Azure account in order to host the application on AKS.

1. Sign in to your account using the [`azd auth login`](/en-us/azure/developer/azure-developer-cli/reference#azd-auth-login) command.

    ```azdeveloper
    azd auth login
    ```
2. Copy the device code that appears in the output and press enter to sign in.

    ```output
    Start by copying the next code: XXXXXXXXX
    Then press enter and continue to log in from your browser...
    ```

    Important

    If you're using an out-of-network virtual machine or GitHub Codespace, certain Azure security policies cause conflicts when used to sign in with `azd auth login`. If you run into an issue here, you can follow the azd auth workaround provided below, which involves using a `curl` request to the localhost URL you were redirected to after running [`azd auth login`][az-auth-login].
3. Authenticate with your credentials on your organization's sign in page.
4. Confirm that it's you trying to connect from the Azure CLI.
5. Verify the message "Device code authentication completed. Logged in to Azure." appears in your original terminal.

    ```output
    Waiting for you to complete authentication in the browser...
    Device code authentication completed.
    Logged in to Azure.
    ```

### azd auth workaround

This workaround requires you to have the [Azure CLI](/en-us/cli/azure/install-azure-cli) installed.

1. Open a terminal window and log in with the Azure CLI using the [`az login`](/en-us/cli/azure/#az-login) command with the `--scope` parameter set to `https://graph.microsoft.com/.default`.

    ```azurecli
    az login --scope https://graph.microsoft.com/.default
    ```

    You should be redirected to an authentication page in a new tab to create a browser access token, as shown in the following example:

    ```output
    https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize?clientid=<your_client_id>.
    ```
2. Copy the localhost URL of the webpage you received after attempting to sign in with `azd auth login`.
3. In a new terminal window, use the following `curl` request to log in. Make sure you replace the `<localhost>` placeholder with the localhost URL you copied in the previous step.

    ```console
    curl <localhost>
    ```

    A successful login outputs an HTML webpage, as shown in the following example:

    ```output
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8" />
        <meta http-equiv="refresh" content="60;url=https://docs.microsoft.com/cli/azure/">
        <title>Login successfully</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
    
            code {
                font-family: Consolas, 'Liberation Mono', Menlo, Courier, monospace;
                display: inline-block;
                background-color: rgb(242, 242, 242);
                padding: 12px 16px;
                margin: 8px 0px;
            }
        </style>
    </head>
    <body>
        <h3>You have logged into Microsoft Azure!</h3>
        <p>You can close this window, or we will redirect you to the <a href="https://docs.microsoft.com/cli/azure/">Azure CLI documentation</a> in 1 minute.</p>
        <h3>Announcements</h3>
        <p>[Windows only] Azure CLI is collecting feedback on using the <a href="https://learn.microsoft.com/windows/uwp/security/web-account-manager">Web Account Manager</a> (WAM) broker for the login experience.</p>
        <p>You may opt-in to use WAM by running the following commands:</p>
        <code>
            az config set core.allow_broker=true<br>
            az account clear<br>
            az login
        </code>
    </body>
    </html>
    ```
4. Close the current terminal and open the original terminal. You should see a JSON list of your subscriptions.
5. Copy the `id` field of the subscription you want to use.
6. Set your subscription using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription <subscription_id>
    ```

## Create and deploy resources for your cluster

`azd` runs all the hooks inside of the [`azd-hooks` folder](https://github.com/Azure-Samples/aks-store-demo/tree/main/azd-hooks) to preregister, provision, and deploy the application services.

The `azd` template for this quickstart creates a new resource group with an AKS cluster and an Azure key vault. The key vault stores client secrets and runs the services in the `pets` namespace

1. Create all the application resources using the [`azd up`](/en-us/azure/developer/azure-developer-cli/reference#azd-up) command.

    ```azdeveloper
    azd up
    ```
2. Select an Azure subscription for your billing usage.

    ```output
    ? Select an Azure Subscription to use:  [Use arrows to move, type to filter]
    > 1. My Azure Subscription (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
    ```
3. Select a region to deploy your application to.

    ```output
    Select an Azure location to use:  [Use arrows to move, type to filter]
      1.  (South America) Brazil Southeast (brazilsoutheast)
      2.  (US) Central US (centralus)
      3.  (US) East US (eastus)
    > 43. (US) East US 2 (eastus2)
      4.  (US) East US STG (eastusstg)
      5.  (US) North Central US (northcentralus)
      6.  (US) South Central US (southcentralus)
    ```

    `azd` automatically runs the preprovisioning and postprovisioning commands to create the resources for your application. This process can take a few minutes to complete. Once complete, you should see an output similar to the following example:

    ```output
    SUCCESS: Your workflow to provision and deploy to Azure completed in 9 minutes 40 seconds.
    ```

## Test the application

When the application runs, a Kubernetes service exposes the application front end to the internet. This process can take a few minutes to complete. To manage a Kubernetes cluster, use the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/). `kubectl` is already installed during `azd up`.

1. Set your namespace as the demo namespace `pets` using the [`kubectl set-context`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#config-set-context) command.

    ```console
    kubectl config set-context --current --namespace=pets
    ```
2. Check the status of the deployed pods using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. Make sure all pods are `Running` before proceeding.

    ```console
    kubectl get pods
    ```
3. Check for a public IP address for the store-front application and monitor progress using the [`kubectl get service`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `--watch` argument.

    ```console
    kubectl get service store-front --watch
    ```

    The **EXTERNAL-IP** output for the `store-front` service initially shows as *pending*:

    ```output
    NAME          TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
    store-front   LoadBalancer   10.0.100.10   <pending>     80:30025/TCP   4h4m
    ```
4. Once the **EXTERNAL-IP** address changes from *pending* to an actual public IP address, use `CTRL-C` to stop the `kubectl` watch process.

    The following sample output shows a valid public IP address assigned to the service:

    ```output
    NAME          TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
    store-front   LoadBalancer   10.0.100.10   20.62.159.19   80:30025/TCP   4h5m
    ```
5. Open a web browser to the external IP address of your service to see the Azure Store app in action.

    [![Screenshot of AKS Store sample application.](media/quick-kubernetes-deploy-cli/aks-store-application.png)](media/quick-kubernetes-deploy-cli/aks-store-application.png#lightbox)

## Delete the cluster

Once you're finished with the quickstart, clean up unnecessary resources to avoid Azure charges.

1. Delete all the resources created in the quickstart using the [`azd down`](/en-us/azure/developer/azure-developer-cli/reference#azd-down) command.

    ```azdeveloper
    azd down
    ```
2. Confirm your decision to remove all used resources from your subscription by typing `y` and pressing `Enter`.

    ```output
    ? Total resources to delete: 14, are you sure you want to continue? (y/N)
    ```
3. Allow purge to reuse the quickstart variables if applicable by typing `y` and pressing `Enter`.

    ```output
    [Warning]: These resources have soft delete enabled allowing them to be recovered for a period or time after deletion. During this period, their names may not be reused. In the future, you can use the argument --purge to skip this confirmation.
    
    ? Would you like to permanently delete these resources instead, allowing their names to be reused? (y/N)
    ```

    Once the resources are deleted, you should see an output similar to the following example:

    ```output
    SUCCESS: Your application was removed from Azure in 14 minutes 30 seconds.
    ```

Note

This sample application is for demo purposes and doesn't represent all the best practices for Kubernetes applications. For guidance on creating full solutions with AKS for production, see [AKS solution guidance](/en-us/azure/architecture/reference-architectures/containers/aks-start-here?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json).