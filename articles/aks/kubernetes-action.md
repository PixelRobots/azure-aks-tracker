---
layout: Conceptual
title: Build, test, and deploy containers to Azure Kubernetes Service (AKS) using GitHub Actions - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kubernetes-action
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
description: Learn how to use GitHub Actions to build, test, and deploy containers to Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2023-09-12T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: github-actions-azure
ms.subservice: aks-developer
locale: en-us
document_id: 0ef60168-63c2-94b3-259d-c079076cb76c
document_version_independent_id: 3fc98a61-0ed4-5c01-e322-025943afa3fd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kubernetes-action.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/kubernetes-action
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kubernetes-action.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: aaf66f2d-2ff3-c270-954f-3ca504fc604b
---

# Build, test, and deploy containers to Azure Kubernetes Service (AKS) using GitHub Actions - Azure Kubernetes Service | Microsoft Learn

[GitHub Actions](https://docs.github.com/en/actions) gives you the flexibility to build an automated software development lifecycle workflow. You can use multiple Kubernetes actions to deploy to containers from Azure Container Registry (ACR) to Azure Kubernetes Service (AKS) with GitHub Actions.

## Prerequisites

- An Azure account with an active subscription. If you don't have one, [create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- A GitHub account. If you don't have one, [sign up for free](https://github.com/join).
    - When using GitHub Actions, you need to configure the integration between Azure and your GitHub repository. To configure the integration, see [Use GitHub Actions to connect to Azure](/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Clinux).
- An existing AKS cluster with an attached ACR. If you don't have one, see [Authenticate with ACR from AKS](cluster-container-registry-integration).

## GitHub Actions for AKS

With GiHub Actions, you can automate your software development workflows from within GitHub. For more information, see [GitHub Actions for Azure](/en-us/azure/developer/github/github-actions).

The following table lists the available actions for AKS:

| Name | Description | More details |
| --- | --- | --- |
| `azure/aks-set-context` | Set the target AKS cluster context for other actions to use or run any kubectl commands. | [azure/aks-set-context](https://github.com/Azure/aks-set-context) |
| `azure/k8s-set-context` | Set the target Kubernetes cluster context for other actions to use or run any kubectl commands. | [azure/k8s-set-context](https://github.com/Azure/k8s-set-context) |
| `azure/k8s-bake` | Bake manifest file to use for deployments using Helm, kustomize, or kompose. | [azure/k8s-bake](https://github.com/Azure/k8s-bake) |
| `azure/k8s-create-secret` | Create a generic secret or docker-registry secret in the Kubernetes cluster. | [azure/k8s-create-secret](https://github.com/Azure/k8s-create-secret) |
| `azure/k8s-deploy` | Deploy manifests to Kubernetes clusters. | [azure/k8s-deploy](https://github.com/Azure/k8s-deploy) |
| `azure/k8s-lint` | Validate/lint your manifest files. | [azure/k8s-lint](https://github.com/Azure/k8s-lint) |
| `azure/setup-helm` | Install a specific version of Helm binary on the runner. | [azure/setup-helm](https://github.com/Azure/setup-helm) |
| `azure/setup-kubectl` | Install a specific version of kubectl on the runner. | [azure/setup-kubectl](https://github.com/Azure/setup-kubectl) |
| `azure/k8s-artifact-substitute` | Update the tag or digest for container images. | [azure/k8s-artifact-substitute](https://github.com/Azure/k8s-artifact-substitute) |
| `azure/aks-create-action` | Create an AKS cluster using Terraform. | [azure/aks-create-action](https://github.com/Azure/aks-create-action) |
| `azure/aks-github-runner` | Set up self-hosted agents for GitHub Actions. | [azure/aks-github-runner](https://github.com/Azure/aks-github-runner) |
| `azure/acr-build` | Build containers using ACR. | [azure/acr-build](https://github.com/Azure/acr-build) |

## Use GitHub Actions with AKS

As an example, you can use GitHub Actions to deploy an application to your AKS cluster every time a change is pushed to your GitHub repository. This example uses the [Azure Vote](https://github.com/Azure-Samples/azure-voting-app-redis) application.

Note

This example uses a service principal for authentication with your ACR and AKS cluster. Alternatively, you can configure Open ID Connect (OIDC) and update the `azure/login` action to use OIDC. For more information, see [Set up Azure Login with OpenID Connect authentication](/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Clinux#use-the-azure-login-action-with-openid-connect).

### Fork and update the repository

1. Navigate to the [Azure Vote](https://github.com/Azure-Samples/azure-voting-app-redis) repository and select **Fork**.
2. Update the `azure-vote-all-in-one-redis.yaml` to use your ACR for the `azure-vote-front` image. Replace `<registryName>` with the name of your registry.

    ```yaml
    ...
          containers:
          - name: azure-vote-front
            image: <registryName>.azurecr.io/azuredocs/azure-vote-front:v1
    ...
    ```
3. Commit the updated `azure-vote-all-in-one-redis.yaml` to your repository.

### Create secrets

1. Create a service principal to access your resource group with the `Contributor` role using the [`az ad sp create-for-rbac`](/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac) command. Replace `<SUBSCRIPTION_ID>` with the subscription ID of your Azure account and `<RESOURCE_GROUP>` with the name of the resource group containing your ACR.

    ```azurecli
    az ad sp create-for-rbac \
        --name "ghActionAzureVote" \
        --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP> \
        --role Contributor \
        --json-auth
    ```

    Your output should look similar to the following example output:

    ```output
    {
      "clientId": <clientId>,
      "clientSecret": <clientSecret>,
      "subscriptionId": <subscriptionId>,
      "tenantId": <tenantId>,
      ...
    }
    ```
2. Navigate to your GitHub repository settings and select **Security** &gt; **Secrets and variables** &gt; **Actions**.
3. For each secret, select **New Repository Secret** and enter the name and value of the secret.

    | Secret name | Secret value |
    | --- | --- |
    | AZURE\_CREDENTIALS | The entire JSON output from the `az ad sp create-for-rbac` command. |
    | service\_principal | The value of `<clientId>`. |
    | service\_principal\_password | The value of `<clientSecret>`. |
    | subscription | The value of `<subscriptionId>`. |
    | tenant | The value of `<tenantId>`. |
    | registry | The name of your registry. |
    | repository | azuredocs |
    | resource\_group | The name of your resource group. |
    | cluster\_name | The name of your cluster. |

For more information about creating secrets, see [Encrypted Secrets](https://docs.github.com/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository).

### Create actions file

1. In your repository, create a `.github/workflows/main.yml` and paste in the following contents:

    ```yaml
    name: build_deploy_aks
    on:
      push:
        paths:
          - "azure-vote/**"
    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - name: Checkout source code 
            uses: actions/checkout@v3
          - name: ACR build
            id: build-push-acr
            uses: azure/acr-build@v1
            with:
              service_principal: ${{ secrets.service_principal }}
              service_principal_password: ${{ secrets.service_principal_password }}
              tenant: ${{ secrets.tenant }}
              registry: ${{ secrets.registry }}
              repository: ${{ secrets.repository }}
              image:  azure-vote-front
              folder: azure-vote
              branch: master
              tag: ${{ github.sha }}
          - name: Azure login
            id: login
            uses: azure/login@v1.4.3
            with:
              creds: ${{ secrets.AZURE_CREDENTIALS }}
          - name: Set AKS context
            id: set-context
            uses: azure/aks-set-context@v3
            with:
              resource-group: '${{ secrets.resource_group }}' 
              cluster-name: '${{ secrets.cluster_name }}'
          - name: Setup kubectl
            id: install-kubectl
            uses: azure/setup-kubectl@v3
          - name: Deploy to AKS
            id: deploy-aks
            uses: Azure/k8s-deploy@v4
            with:
              namespace: 'default'
              manifests: |
                 azure-vote-all-in-one-redis.yaml
              images: '${{ secrets.registry }}.azurecr.io/${{ secrets.repository }}/azure-vote-front:${{ github.sha }}'
              pull-images: false 
    ```

    The `on` section contains the event that triggers the action. In the example file, the action triggers when a change is pushed to the `azure-vote` directory.

    The `steps` section contains each distinct action:

    1. *Checkout source code* uses the [GitHub Actions Checkout Action](https://github.com/actions/checkout) to clone the repository.
    2. *ACR build* uses the [Azure Container Registry Build Action](https://github.com/Azure/acr-build) to build the image and upload it to your registry.
    3. *Azure login* uses the [Azure Login Action](https://github.com/Azure/login) to sign in to your Azure account.
    4. *Set AKS context* uses the [Azure AKS Set Context Action](https://github.com/Azure/aks-set-context) to set the context for your AKS cluster.
    5. *Setup kubectl* uses the [Azure AKS Setup Kubectl Action](https://github.com/Azure/setup-kubectl) to install kubectl on your runner.
    6. *Deploy to AKS* uses the [Azure Kubernetes Deploy Action](https://github.com/Azure/k8s-deploy) to deploy the application to your Kubernetes cluster.
2. Commit the `.github/workflows/main.yml` file to your repository.
3. To confirm the action is working, update the `azure-vote/azure-vote/config_file.cfg` with the following contents:

    ```cfg
    # UI Configurations
    TITLE = 'Azure Voting App'
    VOTE1VALUE = 'Fish'
    VOTE2VALUE = 'Dogs'
    SHOWHOST = 'false'
    ```
4. Commit the updated `azure-vote/azure-vote/config_file.cfg` to your repository.
5. In your repository, select **Actions** and confirm a workflow is running. Then, confirm the workflow has a green checkmark and the updated application is deployed to your cluster.