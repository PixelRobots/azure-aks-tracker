---
layout: Conceptual
title: Validate MongoDB resiliency during an Azure Kubernetes Service (AKS) node pool upgrade - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/upgrade-mongodb-cluster
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
description: In this article, you learn how to test resiliency of MongoDB cluster on Azure Kubernetes Service (AKS) during node pool upgrade.
ms.topic: how-to
ms.date: 2025-01-07T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: stateful-workloads, aks-data-messaging
locale: en-us
document_id: 0a5bdd7b-c2f3-caf5-e3cd-829f92094189
document_version_independent_id: f52ff09f-e852-bf17-447e-2b4c514cf504
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/upgrade-mongodb-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/upgrade-mongodb-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/upgrade-mongodb-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 9ed10a1d-7d86-5011-dee5-6f409984ce5f
---

# Validate MongoDB resiliency during an Azure Kubernetes Service (AKS) node pool upgrade - Azure Kubernetes Service | Microsoft Learn

Using the same MongoDB cluster on Azure Kubernetes Service (AKS) that you deployed in the previous article with Locust running, you can validate the resiliency of the MongoDB cluster during an AKS node pool upgrade.

## Upgrade the AKS cluster

In this scenario, you upgrade the AKS cluster to a newer version. Upgrading the cluster makes it unavailable for a short period of time.

1. Get the current AKS cluster version using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --query kubernetesVersion
    ```

    Example output:

    ```output
    "1.30"
    ```
2. [Check the available versions for the AKS cluster](/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#check-for-available-aks-cluster-upgrades) using the [`az aks get-upgrades`](/en-us/cli/azure/aks#az-aks-get-upgrades) command and decide which version you want to upgrade to.

    ```azurecli
    az aks get-upgrades --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --output table
    ```

    Example output:

    ```output
    Name     ResourceGroup                     MasterVersion    Upgrades
    -------  --------------------------------  ---------------  --------------
    default  myResourceGroup-rg-australiaeast  1.30.6           1.31.1, 1.31.2
    ```
3. List the node pools in the AKS cluster using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command.

    ```azurecli
    az aks nodepool list --resource-group $MY_RESOURCE_GROUP_NAME --cluster-name $MY_CLUSTER_NAME --output table
    ```

    Example output:

    ```output
    Name        OsType    KubernetesVersion    VmSize           Count    MaxPods    ProvisioningState    Mode
    ----------  --------  -------------------  ---------------  -------  ---------  -------------------  ------
    systempool  Linux     1.30                 Standard_DS4_v2  1        30         Succeeded            System
    mongodbpool Linux     1.30                 Standard_DS4_v2  3        30         Succeeded            User
    ```
4. Once you decide your target Kubernetes version, you need to first upgrade the AKS control plane using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command. In this example, we upgrade to Kubernetes version 1.31.1.

    ```azurecli
    az aks upgrade --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_CLUSTER_NAME --kubernetes-version 1.31.1 --control-plane-only --yes
    ```

    [![Screenshot of a web page showing the Locust test dashboard when upgrading control plane.](media/upgrade-mongodb-cluster/locust-upgrade-control-plane.png)](media/upgrade-mongodb-cluster/locust-upgrade-control-plane.png#lightbox)
5. Upgrade the `mongodbpool` node pool to the newer version using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command. Make sure that Locust from the previous article is still running so you can validate the resiliency of the MongoDB cluster during the AKS node pool upgrade.

    ```azurecli
    az aks nodepool upgrade --resource-group $MY_RESOURCE_GROUP_NAME --cluster-name $MY_CLUSTER_NAME --name mongodbpool --kubernetes-version 1.31.1 --yes
    ```

    This command takes some time to complete. During this time, nodes of the AKS cluster become unavailable as they are upgraded to the newer version. However, the MongoDB cluster continues to serve the requests without any interruption.
6. Verify that the MongoDB cluster continues to serve requests by checking the Locust dashboard and the Mongo Express dashboard.

    [![Screenshot of a web page showing the Locust test dashboard when cluster is being upgraded.](media/upgrade-mongodb-cluster/locust-upgrade-continued.png)](media/upgrade-mongodb-cluster/locust-upgrade-continued.png#lightbox)
7. After the upgrade is complete, you can verify the Kubernetes version of the `mongodbpool` node pool using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command.

    ```azurecli
    az aks nodepool list --resource-group $MY_RESOURCE_GROUP_NAME --cluster-name $MY_CLUSTER_NAME --output table
    ```

    Example output:

    ```output
    Name        OsType    KubernetesVersion    VmSize           Count    MaxPods    ProvisioningState    Mode
    ----------  --------  -------------------  ---------------  -------  ---------  -------------------  ------
    systempool  Linux     1.30                 Standard_DS4_v2  1        30         Succeeded            System
    mongodbpool Linux     1.31.1               Standard_DS4_v2  3        30         Succeeded            User
    ```