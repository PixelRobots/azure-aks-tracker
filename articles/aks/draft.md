---
layout: Conceptual
title: Draft extension for Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/draft
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
description: How to install and use Draft on your Azure Kubernetes Service (AKS) cluster using the Draft extension.
author: schaffererin
ms.author: schaffererin
ms.topic: concept-article
ms.date: 2023-06-22T00:00:00.0000000Z
ms.subservice: aks-developer
ms.custom: devx-track-azurecli, build-spring-2022
locale: en-us
document_id: 40ea0c31-db2b-4b86-cb4d-57655e5653b3
document_version_independent_id: 71178c01-0a0d-0d53-cbbf-96447fec34e1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/draft.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azure-cli
toc_rel: toc.json
asset_id: aks/draft
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/draft.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9bdc1705-9b40-49d6-8377-caa0b71fda66
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/686ed158-d915-41e9-9760-efa46ba88f6d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: e96f2bb5-fd21-1f44-7adc-9b2748daa7c7
---

# Draft extension for Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn

[Draft](https://github.com/Azure/draft) is an open-source project that streamlines Kubernetes development by taking a non-containerized application and generating the Dockerfiles, Kubernetes manifests, Helm charts, Kustomize configurations, and other artifacts associated with a containerized application. Draft can also create a GitHub Action workflow file to quickly build and deploy applications onto any Kubernetes cluster.

## How it works

Draft has the following commands to help ease your development on Kubernetes:

- `draft create`: Creates the Dockerfile and the proper manifest files.
- `draft setup-gh`: Sets up your GitHub OIDC.
- `draft generate-workflow`: Generates the GitHub Action workflow file for deployment onto your cluster.
- `draft up`: Sets up your GitHub OIDC and generates a GitHub Action workflow file, combining the previous two commands.

## Prerequisites

- If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Install the latest version of the [Azure CLI](/en-us/cli/azure/install-azure-cli-windows) and the *aks-preview* extension.
- If you don't have one already, you need to create an [AKS cluster](tutorial-kubernetes-deploy-cluster) and an Azure Container Registry instance.

### Install the `aks-preview` Azure CLI extension

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

1. Install the `aks-preview` extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update the extension to make sure you have the latest version using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    az extension update --name aks-preview
    ```

## Create artifacts using `draft create`

You can use `draft create` to create Dockerfiles, Helm charts, Kubernetes manifests, or Kustomize files needed to deploy your application onto an AKS cluster.

- Create an artifact using the [`az aks draft create`](/en-us/cli/azure/aks/draft#az-aks-draft-create) command.

    ```azure
    az aks draft create
    ```

    - You can also run the command on a specific directory using the `--destination` flag, as shown in the following example:

        ```azure
        az aks draft create --destination /Workspaces/ContosoAir
        ```

## Set up GitHub OIDC using `draft setup-gh`

To use Draft, you have to register your application with GitHub using `draft setup-gh`. This step only needs to be done once per repository.

- Register your application with GitHub using the [`az aks draft setup-gh`](/en-us/cli/azure/aks/draft#az-aks-draft-setup-gh) command.

    ```azure
    az aks draft setup-gh
    ```

## Generate a GitHub Action workflow file for deployment using `draft generate-workflow`

After you create your artifacts and set up GitHub OIDC, you can use `draft generate-workflow` to generate a GitHub Action workflow file, creating an action that deploys your application onto your AKS cluster. Once your workflow file is generated, you must commit it into your repository in order to initiate the GitHub Action.

- Generate a GitHub Action workflow file using the [`az aks draft generate-workflow`](/en-us/cli/azure/aks/draft#az-aks-draft-generate-workflow) command.

    ```azure
    az aks draft generate-workflow
    ```

    - You can also run the command on a specific directory using the `--destination` flag, as shown in the following example:

        ```azure
        az aks draft generate-workflow --destination /Workspaces/ContosoAir
        ```

## Set up GitHub OpenID Connect (OIDC) and generate a GitHub Action workflow file using `draft up`

`draft up` is a single command to accomplish GitHub OIDC setup and generate a GitHub Action workflow file for deployment. It effectively combines the `draft setup-gh` and `draft generate-workflow` commands, meaning it's most commonly used when getting started in a new repository for the first time, and only needs to be run once. Subsequent updates to the GitHub Action workflow file can be made using `draft generate-workflow`.

- Set up GitHub OIDC and generate a GitHub Action workflow file using the [`az aks draft up`](/en-us/cli/azure/aks/draft#az-aks-draft-up) command.

    ```azure
    az aks draft up
    ```

    - You can also run the command on a specific directory using the `--destination` flag, as shown in the following example:

        ```azure
        az aks draft up --destination /Workspaces/ContosoAir
        ```

## Use Application Routing with Draft to make your application accessible over the internet

[Application Routing](app-routing) is the easiest way to get your web application up and running in Kubernetes securely. Application Routing removes the complexity of ingress controllers and certificate and DNS management, and it offers configuration for enterprises looking to bring their own. Application Routing offers a managed ingress controller based on nginx that you can use without restrictions and integrates out of the box with Open Service Mesh to secure intra-cluster communications.

- Set up Draft with Application Routing using the [`az aks draft update`](/en-us/cli/azure/aks/draft#az-aks-draft-update) and pass in the DNS name and Azure Key Vault-stored certificate when prompted.

    ```azure
    az aks draft update
    ```

    - You can also run the command on a specific directory using the `--destination` flag, as shown in the following example:

        ```azure
        az aks draft update --destination /Workspaces/ContosoAir
        ```