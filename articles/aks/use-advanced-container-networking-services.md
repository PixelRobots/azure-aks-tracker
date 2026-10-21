---
layout: Conceptual
title: Enable Advanced Container Networking Services on Azure Kubernetes Service (AKS) Clusters - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-advanced-container-networking-services
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to set up Advanced Container Networking Services on your Azure Kubernetes Service (AKS) clusters to enhance network observability and security for your containerized applications.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2024-05-28T00:00:00.0000000Z
zone_pivot_groups: use-advanced-container-networking-services
locale: en-us
document_id: b8e2f298-4899-10c0-f4b9-239de4cc0cf1
document_version_independent_id: dee5cfe4-2f2d-5bb1-7c88-80ca875fc559
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-advanced-container-networking-services.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-advanced-container-networking-services
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-advanced-container-networking-services.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 5f25781f-ab70-4fc2-c9aa-beb7bf88cbee
---

# Enable Advanced Container Networking Services on Azure Kubernetes Service (AKS) Clusters - Azure Kubernetes Service | Microsoft Learn

This article describes how to enable and disable Advanced Container Networking Services, including [Container Network Observability](advanced-container-networking-services-overview#container-network-observability) and [Container Network Security](advanced-container-networking-services-overview#container-network-security), on your AKS clusters.

## Prerequisites

- An Azure account with an active subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Azure CLI version 2.79.0 or higher. Find your version using the `az --version` command. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Clusters that have the Cilium data plane support *Container Network Observability* and *Container Network Security* in Kubernetes version 1.29 and later.

## Set environment variables

The examples in this article use the following environment variables:

| Variable | Description | Example value |
| --- | --- | --- |
| `RESOURCE_GROUP` | Name of the Azure resource group | `myResourceGroup` |
| `LOCATION` | Azure region for resources | `eastus` |
| `CLUSTER_NAME` | Name of the AKS cluster | `myAKSCluster` |

**All commands in this article assume these environment variables are set**. Make sure to replace the example values with your own values.

## Create a resource group

- Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```

## Create a new AKS cluster with Advanced Container Networking Services

Note

Fully qualified domain name (FQDN) filtering policies are enabled with `--enable-acns` by default. If you want to enable Layer 7 and FQDN policies, set `--acns-advanced-networkpolicies` to `L7`.

::: zone pivot="cilium"

- Create an AKS cluster with Advanced Container Networking Services and Cilium using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-acns` and `--network-dataplane cilium` flags.

    ```azurecli
    az aks create \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --network-plugin azure \
        --network-plugin-mode overlay \
        --network-dataplane cilium \
        --enable-acns
    ```

::: zone-end

::: zone pivot="non-cilium"

Important

The [Container Network Security](advanced-container-networking-services-overview#container-network-security) feature isn't available for non-Cilium clusters.

- Create an AKS cluster with Advanced Container Networking Services using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-acns` flag.

    ```azurecli
    az aks create \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --network-plugin azure \
        --network-plugin-mode overlay \
        --enable-acns
    ```

::: zone-end

## Enable Advanced Container Networking Services on an existing cluster

::: zone pivot="cilium"

- Enable Advanced Container Networking Services on an existing AKS cluster with Cilium using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-acns` flag.

    ```azurecli
    az aks update \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --enable-acns
    ```

::: zone-end

::: zone pivot="non-cilium"

- Enable Advanced Container Networking Services on an existing AKS cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-acns` flag.

    ```azurecli
    az aks update \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --enable-acns
    ```

::: zone-end

## Disable Advanced Container Networking Services on an AKS cluster

- Disable Advanced Container Networking Services on an existing AKS cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-acns` flag.

    ```azurecli
    az aks update \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --disable-acns
    ```

## Disable Container Network Observability on an AKS cluster

::: zone pivot="cilium"

- Disable the Container Network Observability feature without affecting other Advanced Container Networking Services features using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-acns-observability` flag.

    ```azurecli
    az aks update \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --enable-acns \
        --disable-acns-observability 
    ```

::: zone-end

::: zone pivot="non-cilium"

Container Network Observability is the only feature available for non-Cilium clusters, so you can disable it only by disabling the entire Advanced Container Networking Services suite.

- Disable the Container Network Observability feature on an existing AKS cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-acns` flag.

    ```azurecli
    az aks update \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --disable-acns 
    ```

::: zone-end

::: zone pivot="cilium"

## Disable Container Network Security on an AKS cluster

- Disable the Container Network Security feature without affecting other Advanced Container Networking Services features using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-acns-security` flag.

    ```azurecli
    az aks update \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --enable-acns \
        --disable-acns-security
    ```

::: zone-end