---
layout: Conceptual
title: Upgrade Node Images in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/upgrade-node-image
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
description: Learn how to upgrade node images in your Azure Kubernetes Service (AKS) cluster to leverage the latest features and ensure optimal performance and security for your containerized applications.
ms.topic: how-to
ms.custom: devx-track-azurecli, innovation-engine
ms.subservice: aks-upgrade
ms.date: 2026-08-03T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 5d934c4d-765a-1b8d-c7c8-d7458662a854
document_version_independent_id: f7febfdc-6d62-35ca-2e0f-bc22cd2e7214
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/upgrade-node-image.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/upgrade-node-image
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/upgrade-node-image.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: e46cce74-a8d5-b1cc-345d-853936dc3fb8
---

# Upgrade Node Images in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) regularly provides new [node images](node-images), so upgrade your node images frequently to use the latest AKS features. Linux node images are updated weekly, and Windows node images are updated monthly. The [AKS release notes](https://github.com/Azure/AKS/releases) include image upgrade announcements. It can take up to two weeks for these updates to roll out across all regions. See the [release tracker](release-tracker) for roll out status. You can also perform node image upgrades automatically and schedule them by using planned maintenance. For more information, see [Automatically upgrade node OS images](auto-upgrade-node-os-image).

AKS recommends [node OS auto-upgrade channels](auto-upgrade-node-os-image), which automatically upgrade your node images or apply security patches during your maintenance windows without changing the Kubernetes version. If you want to manually upgrade your node images, follow the instructions in this article. This article shows you how to upgrade AKS cluster node images and how to update node pool images without upgrading the Kubernetes version. For information on upgrading the Kubernetes version for your cluster, see [Upgrade an AKS cluster](upgrade-aks-control-plane).

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Note

Clusters that use Node Auto-Provisioning (NAP) automatically update node images when a new image is available. You can configure a maintenance window to control when NAP picks up a new image, but the window doesn't necessarily determine when existing nodes are disrupted. NAP's drift logic, Karpenter Node Disruption Budgets, and Pod Disruption Budgets control how and when disruption occurs. For more information, see [Node image updates for NAP](node-auto-provisioning-upgrade-image).

You can't downgrade a node image version (for example, *AKSUbuntu-2404* to *AKSUbuntu-2204*, or *AKSUbuntu-2404-202601.27.0* to *AKSUbuntu-2404-202601.13.0*).

## Prerequisites

- An existing AKS cluster and node pool.
- The [Azure CLI](/en-us/cli/azure/install-azure-cli) installed and signed in to your Azure account.
- Permission to retrieve cluster credentials and read and update the AKS cluster and node pools.
- A Bash shell. The commands in this article use Bash environment variable syntax.

Set environment variables for your resource group, cluster, and node pool names to use in the subsequent commands:

```bash
export AKS_RESOURCE_GROUP="<resource-group-name>"
export AKS_CLUSTER="<cluster-name>"
export AKS_NODEPOOL="<node-pool-name>"
```

## Connect to your AKS cluster

1. Connect to your AKS cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials \
        --resource-group $AKS_RESOURCE_GROUP \
        --name $AKS_CLUSTER
    ```

## Check for available node image upgrades

1. Check for available node image upgrades using the [`az aks nodepool get-upgrades`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-get-upgrades) command.

    ```azurecli
    az aks nodepool get-upgrades \
        --nodepool-name $AKS_NODEPOOL \
        --cluster-name $AKS_CLUSTER \
        --resource-group $AKS_RESOURCE_GROUP
    ```
2. In the output, find and make note of the `latestNodeImageVersion` value. This value is the latest node image version available for your node pool.
3. Check your current node image version to compare with the latest version using the [`az aks nodepool show`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-show) command.

    ```azurecli
    az aks nodepool show \
        --resource-group $AKS_RESOURCE_GROUP \
        --cluster-name $AKS_CLUSTER \
        --name $AKS_NODEPOOL \
        --query nodeImageVersion
    ```
4. If the `nodeImageVersion` value is different from the `latestNodeImageVersion`, you can upgrade your node image.

## Upgrade all node images in all node pools

1. Upgrade all node images in all node pools in your cluster using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command with the `--node-image-only` flag.

    ```azurecli
    az aks upgrade \
        --resource-group $AKS_RESOURCE_GROUP \
        --name $AKS_CLUSTER \
        --node-image-only \
        --yes
    ```
2. You can check the status of the node images using the `kubectl get nodes` command.

    Note

    This command might differ slightly depending on the shell you use. For more information on Windows and PowerShell environments, see the [Kubernetes JSONPath documentation](https://kubernetes.io/docs/reference/kubectl/jsonpath/). This command lists each node's name alongside the value of its `kubernetes.azure.com/node-image-version` label, which identifies the node's current image version.

    ```bash
    kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.kubernetes\.azure\.com\/node-image-version}{"\n"}{end}'
    ```
3. When the upgrade completes, use the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command to get the updated node pool details. The current node image is shown in the `nodeImageVersion` property.

    ```azurecli
    az aks show \
        --resource-group $AKS_RESOURCE_GROUP \
        --name $AKS_CLUSTER  \
        --query "agentPoolProfiles[].{Name:name, NodeImageVersion:nodeImageVersion}"
    ```

## Upgrade a specific node pool

1. Update the OS image of a node pool without doing a Kubernetes cluster upgrade using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command with the `--node-image-only` flag.

    ```azurecli
    az aks nodepool upgrade \
        --resource-group $AKS_RESOURCE_GROUP \
        --cluster-name $AKS_CLUSTER \
        --name $AKS_NODEPOOL \
        --node-image-only
    ```
2. You can check the status of the node images with the `kubectl get nodes` command.

    Note

    This command might differ slightly depending on the shell you use. For more information on Windows and PowerShell environments, see the [Kubernetes JSONPath documentation](https://kubernetes.io/docs/reference/kubectl/jsonpath/). This command lists each node's name alongside the value of its `kubernetes.azure.com/node-image-version` label, which identifies the node's current image version.

    ```bash
    kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.kubernetes\.azure\.com\/node-image-version}{"\n"}{end}'
    ```
3. When the upgrade completes, use the [`az aks nodepool show`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-show) command to get the updated node pool details. The current node image is shown in the `nodeImageVersion` property.

    ```azurecli
    az aks nodepool show \
        --resource-group $AKS_RESOURCE_GROUP \
        --cluster-name $AKS_CLUSTER \
        --name $AKS_NODEPOOL \
        --query nodeImageVersion
    ```

## Upgrade node images with node surge

This procedure upgrades the node image for a specific node pool, not all node pools in the cluster. By default, AKS uses one extra node to configure upgrades. To speed up the node image upgrade process, upgrade your node images by using a customizable node surge value.

1. Configure the number of surge nodes for the node pool using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with the `--max-surge` flag. This setting persists for subsequent upgrades.

    Note

    To learn more about the trade-offs of various `--max-surge` settings, see [Customize node surge upgrade](upgrade-aks-node-pools-rolling#customize-node-surge).

    ```azurecli
    az aks nodepool update \
        --resource-group $AKS_RESOURCE_GROUP \
        --cluster-name $AKS_CLUSTER \
        --name $AKS_NODEPOOL \
        --max-surge 33%
    ```
2. Upgrade the node image using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command with the `--node-image-only` flag.

    ```azurecli
    az aks nodepool upgrade \
        --resource-group $AKS_RESOURCE_GROUP \
        --cluster-name $AKS_CLUSTER \
        --name $AKS_NODEPOOL \
        --node-image-only
    ```
3. You can check the status of the node images with the `kubectl get nodes` command. This command lists each node's name alongside the value of its `kubernetes.azure.com/node-image-version` label, which identifies the node's current image version.

    ```bash
    kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.kubernetes\.azure\.com\/node-image-version}{"\n"}{end}'
    ```
4. Get the updated node pool details using the [`az aks nodepool show`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-show) command. The current node image is shown in the `nodeImageVersion` property.

    ```azurecli
    az aks nodepool show \
        --resource-group $AKS_RESOURCE_GROUP \
        --cluster-name $AKS_CLUSTER \
        --name $AKS_NODEPOOL \
        --query nodeImageVersion
    ```