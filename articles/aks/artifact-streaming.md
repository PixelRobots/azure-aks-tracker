---
layout: Conceptual
title: Reduce Time to Deployment with Artifact Streaming on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/artifact-streaming
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
description: Learn how to enable Artifact Streaming on Azure Kubernetes Service (AKS) to reduce time to deployment and idle compute time.
author: allyford
ms.author: allyford
ms.custom: devx-track-azurecli
ms.topic: how-to
ms.date: 2026-08-05T00:00:00.0000000Z
ms.subservice: aks-nodes
locale: en-us
document_id: 7860af15-751c-b6b4-4159-bec0876ed807
document_version_independent_id: 06da3fac-2635-696c-d503-4bf0ef16f91c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/artifact-streaming.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/artifact-streaming
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/artifact-streaming.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/2d774b87-7dcb-40bf-a0b9-5a7a9efff0d1
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/89dc5f37-0e4e-4b05-ad87-5fcd2b941a8a
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: a8f390c6-80c7-f7bd-3652-4304bbe774a1
---

# Reduce Time to Deployment with Artifact Streaming on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Large container images can increase image pull time and delay workload deployment. [Artifact Streaming](artifact-streaming-overview) allows you to stream container images from Azure Container Registry (ACR) to Azure Kubernetes Service (AKS). AKS only pulls the necessary layers for initial pod startup, reducing the time it takes to deploy your workloads.

This article describes how to enable and disable the Artifact Streaming feature on your AKS node pools to stream artifacts from ACR.

## Prerequisites

- An Azure subscription. If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/free).
- Enable Artifact Streaming on ACR.
- Azure CLI version 2.87.0 or later. Run `az --version` to find your version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- This feature requires Kubernetes version 1.25 or later. To check your AKS cluster version, see [Check for available AKS cluster upgrades](upgrade-cluster).
- An existing AKS cluster with ACR integration. If you don't have one, you can create one using [Authenticate with ACR from AKS](cluster-container-registry-integration).
- The [Azure Kubernetes Service Contributor Role](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-service-contributor-role) is required to modify node pool configurations.

## Limitations

- Only images with Linux AMD64 architecture are supported.
- Windows-based container images and ARM64 images aren't supported.
- Only the AMD64 architecture is supported for multi-architecture images.
- Ubuntu based node pools in AKS must use Ubuntu version 20.04 or higher.
- Only Premium SKU ACR registries are supported.
- CMK (Customer-Managed Keys) registries aren't supported.
- Kubernetes `regcred`, such as `imagePullSecrets`, isn't supported. Image pulls from ACR using [non-Entra scope-mapped token credentials](/en-us/azure/container-registry/container-registry-token-based-repository-permissions) or [ACR admin user credentials](/en-us/azure/container-registry/container-registry-authentication?tabs=azure-cli#admin-account) default to non-Artifact Streaming pulls, even if the node pool and image are enabled for streaming.
- Artifact Streaming only supports image pulls by tag. Artifact Streaming works by resolving image pulls by tag to a streaming variant of the image. If image pulls are done by digest, you can't use Artifact Streaming.

## Enable Artifact Streaming on ACR

1. Create an Azure resource group to hold your ACR instance using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name myStreamingTest --location westus
    ```
2. Create a new Premium SKU ACR using the [`az acr create`](/en-us/cli/azure/acr#az-acr-create) command with the `--sku Premium` flag.

    ```azurecli
    az acr create --resource-group myStreamingTest --name mystreamingtest --sku Premium
    ```
3. Configure the default ACR instance for your subscription using the [`az configure`](/en-us/cli/azure#az-configure) command.

    ```azurecli
    az configure --defaults acr="mystreamingtest"
    ```
4. Push or import an image to the registry using the [`az acr import`](/en-us/cli/azure/acr#az-acr-import) command.

    ```azurecli
    az acr import --source docker.io/jupyter/all-spark-notebook --repository jupyter/all-spark-notebook
    ```
5. Create a streaming artifact from the image using the [`az acr artifact-streaming create`](/en-us/cli/azure/acr/artifact-streaming#az-acr-artifact-streaming-create) command.

    ```azurecli
    az acr artifact-streaming create --image jupyter/all-spark-notebook:latest
    ```
6. Verify the generated Artifact Streaming using the [`az acr manifest list-referrers`](/en-us/cli/azure/acr/manifest#az-acr-manifest-list-referrers) command.

    ```azurecli
    az acr manifest list-referrers --name jupyter/all-spark-notebook:latest
    ```

## Enable Artifact Streaming on AKS

You can enable Artifact Streaming on new or existing node pools in your AKS cluster with ACR integration.

Note

If you don't have a Premium tier ACR integrated with your AKS cluster, you can't use Artifact Streaming on AKS.

Note

Clusters with [Node Auto Provisioning (NAP)](node-auto-provisioning) enabled can enable artifact streaming by using the `spec.artifactStreaming.enabled` field of the [AKSNodeClass CRD](node-auto-provisioning-aksnodeclass). Set this field to `true` to enable artifact streaming for any new or existing NAP-managed nodes associated with this AKSNodeClass CRD.

### Enable Artifact Streaming on a new node pool

Create a new AKS node pool with Artifact Streaming enabled using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--enable-artifact-streaming` flag.

```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myNodePool \
    --enable-artifact-streaming
```

### Enable Artifact Streaming on an existing node pool

Enable Artifact Streaming on an existing AKS node pool using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with the `--enable-artifact-streaming` flag.

```azurecli
az aks nodepool update \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myNodePool \
    --enable-artifact-streaming
```

## Disable Artifact Streaming on an existing node pool

Disable Artifact Streaming on an existing AKS node pool using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with the `--disable-artifact-streaming` flag.

```azurecli
az aks nodepool update \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myNodePool \
    --disable-artifact-streaming
```

## Check Artifact Streaming enablement status

Check if Artifact Streaming is enabled on an AKS node pool using the [`az aks nodepool show`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-show) command with the `--query` flag set to `artifactStreamingProfile`.

```azurecli
az aks nodepool show \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myNodePool \
    --query artifactStreamingProfile
```

In the output, check the `Enabled` field. `true` means Artifact Streaming is enabled, and `false` means Artifact Streaming is disabled.