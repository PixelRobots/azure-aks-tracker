---
layout: Conceptual
title: Validate Valkey Resiliency During an Azure Kubernetes Service (AKS) Node Pool Upgrade - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/upgrade-valkey-aks-nodepool
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
description: In this article, you learn how to validate the resiliency of the Valkey cluster on Azure Kubernetes during a node pool upgrade.
ms.topic: how-to
ms.date: 2025-09-15T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: stateful-workloads, aks-data-messaging
locale: en-us
document_id: 29afc12b-8df3-98ce-55ae-32b484e97670
document_version_independent_id: 718a7c01-3dd7-50ea-c760-728f50976cff
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/upgrade-valkey-aks-nodepool.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/upgrade-valkey-aks-nodepool
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/upgrade-valkey-aks-nodepool.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: d537c87f-f320-7513-d842-fa57f8c1737e
---

# Validate Valkey Resiliency During an Azure Kubernetes Service (AKS) Node Pool Upgrade - Azure Kubernetes Service | Microsoft Learn

Using the same [Valkey cluster on Azure Kubernetes Service (AKS) that you deployed with Locust](validate-valkey-cluster), you can validate the resiliency of the Valkey cluster during an AKS node pool upgrade. This process helps validate that Valkey maintains resiliency during AKS node pool upgrades. Monitoring with Locust ensures visibility into request handling and shard availability, allowing you to confidently manage upgrades with minimal service disruption.

## Upgrade the AKS cluster

1. List [the available versions for the AKS cluster](/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#check-for-available-aks-cluster-upgrades) and identify the target version you're upgrading to using the [`az aks get-upgrades`](/en-us/cli/azure/aks#az-aks-get-upgrades) command.

    ```azurecli
    az aks get-upgrades --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --output table
    ```
2. Upgrade the AKS control plane using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command. In this example, the target version is 1.33.0.

    ```azurecli
    az aks upgrade --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --control-plane-only --kubernetes-version 1.33.0
    ```

## Verify Locust client status

- Verify the [Locust client started in the previous article](validate-valkey-cluster) is still running. The Locust dashboard will show the impact of the AKS node pool upgrade on the Valkey cluster.

## Upgrade the Valkey node pool

1. Upgrade the Valkey node pool using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command.

    ```azurecli
    az aks nodepool upgrade \
        --resource-group $MY_RESOURCE_GROUP_NAME \
        --cluster-name $MY_CLUSTER_NAME \
        --kubernetes-version 1.33.0 \
        --name valkey
    ```
2. While the upgrade process is running, you can monitor the Locust dashboard to see the status of the client requests. The dashboard should look similar to the following screenshot:

    ![Screenshot of a web page showing the Locust test dashboard during the AKS upgrade.](media/valkey-stateful-workload/aks-upgrade-impact-valkey-cluster.png)

    The dashboard shows that Locust is running with 100 users making 50 requests per second. During the upgrade process, a primary pod is evicted four times. You can see the shard isn't available for a few seconds, but the Valkey cluster can still respond to requests for the other shards.