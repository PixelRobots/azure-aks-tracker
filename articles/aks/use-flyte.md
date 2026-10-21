---
layout: Conceptual
title: Build and deploy data and machine learning pipelines with Flyte on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-flyte
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
description: Learn about Flyte, an open-source platform for building and deploying data and machine learning pipelines on Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2024-06-06T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: aks-ai-ml
locale: en-us
document_id: ae4ff5a1-2dca-8807-3d3f-a48749b6ddea
document_version_independent_id: 83ff34af-218a-bb17-3ace-f8f58323dde2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-flyte.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-flyte
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-flyte.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 214cea04-3ad6-6494-63ef-3251838ce979
---

# Build and deploy data and machine learning pipelines with Flyte on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to use Flyte on Azure Kubernetes Service (AKS). Flyte is an open-source workflow orchestrator that unifies machine learning, data engineering, and data analytics stacks to help you build robust and reliable applications. When using Flyte as a Kubernetes-native workflow automation tool, you can focus on experimentation and providing business value without increasing your scope to infrastructure and resource management. Keep in mind that Flyte isn't officially supported by Microsoft, so use it at your own discretion.

For more information, see [Introduction to Flyte](https://www.union.ai/docs/flyte/user-guide/).

Important

Open-source software is mentioned throughout AKS documentation and samples. Software that you deploy is excluded from AKS service-level agreements, limited warranty, and Azure support. As you use open-source technology alongside AKS, consult the support options available from the respective communities and project maintainers to develop a plan.

Microsoft takes responsibility for building the open-source packages that we deploy on AKS. That responsibility includes having complete ownership of the build, scan, sign, validate, and hotfix process, along with control over the binaries in container images. For more information, see [Vulnerability management for AKS](concepts-vulnerability-management#aks-container-images) and [AKS support coverage](support-policies#aks-support-coverage).

## Flyte use cases

Flyte can be used for a variety of use cases, including:

- Deliver models for streamlined profit and loss financial calculations.
- Process petabytes of data to efficiently conduct 3D mapping of new areas.
- Quickly rollback to previous versions and minimize impact of bugs in your pipelines.

For more information, see [Flyte tutorials](https://www.union.ai/docs/flyte/tutorials/).

## Prerequisites

- An Azure subscription. If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
    - If you have multiple subscriptions, make sure you select the correct one using the `az account set --subscription <subscription-id>` command.
- The Azure CLI installed and configured. Check your version using the `az --version` command. If you need to install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- The Helm CLI installed and updated. Check your version using the `helm version` command. If you need to install or upgrade, see [Install Helm](https://helm.sh/docs/intro/install/).
- The `kubectl` CLI installed and updated. Install it locally using the `az aks install-cli` command or using [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- A local Docker development environment. For more information, see [Get Docker](https://docs.docker.com/get-docker/).
- `flytekit` and `flytectl` installed. For more information, see [Flyte installation](https://www.union.ai/docs/flyte/user-guide/getting-started/local-setup/).

Note

If you're using the Azure Cloud Shell, the Azure CLI, Helm, and kubectl are already installed.

### Set environment variables

- Set environment variables for use throughout the article. Replace the placeholder values with your own values.

    ```bash
    export RESOURCE_GROUP="<resource-group-name>"
    export LOCATION="<location>"
    export CLUSTER_NAME="<cluster-name>"
    export DNS_NAME_PREFIX="<dns-name-prefix>"
    ```

## Create an AKS cluster

1. Create an Azure resource group for the AKS cluster using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```
2. Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-azure-rbac`, `--enable-managed-identity`, `--enable-aad`, and `--dns-name-prefix` parameters.

    ```azurecli
    az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --enable-azure-rbac --enable-managed-identity --enable-aad --dns-name-prefix $DNS_NAME_PREFIX  --generate-ssh-keys
    ```

## Connect to your AKS cluster

- Configure `kubectl` to connect to your AKS cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```

## Add the Flyte Helm repository

- Add the Flyte Helm repository using the `helm repo add` command.

    ```bash
    helm repo add flyteorg https://flyteorg.github.io/flyte
    ```

## Find Flyte Helm charts

1. Search for Flyte Helm charts using the `helm search repo` command.

    ```bash
    helm search repo flyteorg
    ```

    The following example output shows some of the available Flyte Helm charts:

    ```output
    NAME                    CHART VERSION   APP VERSION     DESCRIPTION
    flyteorg/flyte          v1.12.0                         A Helm chart for Flyte Sandbox
    flyteorg/flyte-binary   v1.12.0         1.16.0          Chart for basic single Flyte executable deployment
    flyteorg/flyte-core     v1.12.0                         A Helm chart for Flyte core
    flyteorg/flyte-deps     v1.12.0                         A Helm chart for Flyte dependencies
    flyteorg/flyte-sandbox  0.1.0           1.16.1          A Helm chart for the Flyte local sandbox
    flyteorg/flyteagent     v0.1.10                         A Helm chart for Flyte Agent
    ```
2. Update the repository using the `helm repo update` command.

    ```bash
    helm repo update
    ```

## Deploy a Flyte chart on AKS

In this section, you deploy the flyte-binary Helm chart so you can begin building and deploying data and machine learning pipelines with Flyte on AKS. The flyte-binary chart is a basic single Flyte executable deployment.

1. Create a namespace for your Flyte deployment using the `kubectl create namespace` command.

    ```bash
    kubectl create namespace <namespace-name>
    ```
2. Install a Flyte Helm chart using the `helm install` command. In this example, we use the `flyte-binary` chart.

    ```bash
    helm install flyte-binary flyteorg/flyte-core --namespace <namespace-name>
    ```
3. Verify that the Flyte deployment is running using the `kubectl get services` command.

    ```bash
    kubectl get services --namespace <namespace-name> --output wide
    ```

    The following condensed example output shows the Flyte deployment:

    ```output
    NAME                            TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)          AGE
    flyteorg-flyte-binary-grpc      ClusterIP      xx.x.xx.xxx    <none>          81/TCP           1m
    flyteorg-flyte-binary-http      ClusterIP      xx.x.xx.xxx    <none>          80/TCP           1m
    flyteorg-flyte-binary-webhook   ClusterIP      xx.x.xx.xxx    <none>          80/TCP           1m
    ```