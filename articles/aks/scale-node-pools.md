---
layout: Conceptual
title: Scale Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/scale-node-pools
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
description: Learn how to manually and automatically scale node pools in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2023-07-19T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-nodes
locale: en-us
document_id: cb26992c-540d-2750-1a63-c4ed067ad742
document_version_independent_id: 43b99352-8f50-1a0d-83bd-8feb07532eef
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/scale-node-pools.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/scale-node-pools
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/scale-node-pools.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ff8f3a28-1b33-faea-a48a-eb43f9794096
---

# Scale Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

As your application workload demands change, you might need to scale the number of nodes in a node pool in Azure Kubernetes Service (AKS). In this article, you learn how to manually and automatically scale node pools in AKS.

## Prerequisites for AKS node pool scaling

- An existing AKS cluster with at least one node pool. If you need to create one, see [Create an AKS cluster with node pools](create-node-pools).
- You need the Azure CLI version 2.2.0 or later installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Scale a node pool manually

1. Scale the number of nodes in a node pool using the [`az aks nodepool scale`][az-aks-nodepool-scale] command. The `--node-count` flag specifies the desired number of nodes in the node pool. In this example, the node pool is scaled to five nodes.

    ```azurecli
    az aks nodepool scale \
        --resource-group <resource-group-name> \
        --cluster-name <cluster-name> \
        --name <node-pool-name> \
        --node-count 5 \
        --no-wait
    ```
2. Check the status of your node pools using the [`az aks nodepool list`][az-aks-nodepool-list] command.

    ```azurecli
    az aks nodepool list --resource-group <resource-group-name> --cluster-name <cluster-name>
    ```

    The following example output shows the node pool is in the *Scaling* state with a new count of five nodes:

    ```output
    [
      {
        ...
        "count": 5,
        ...
        "name": "<node-pool-name>",
        "orchestratorVersion": "1.15.7",
        ...
        "provisioningState": "Scaling",
        ...
        "vmSize": "Standard_DS2_v2",
        ...
      },
      {
        ...
        "count": 2,
        ...
        "name": "<node-pool-name-2>",
        "orchestratorVersion": "1.15.7",
        ...
        "provisioningState": "Succeeded",
        ...
        "vmSize": "Standard_DS2_v2",
        ...
      }
    ]
    ```

    It takes a few minutes for the scale operation to complete. After the scale operation is complete, the node pool's `provisioningState` changes to *Succeeded*.

## Scale a node pool automatically with the cluster autoscaler

You can use the [cluster autoscaler](cluster-autoscaler-overview) with multiple node pools, and you can enable it on individual node pools and pass unique autoscaling rules to them.

- Enable the cluster autoscaler on an existing node pool using the [`az aks nodepool update`][az-aks-nodepool-update] command with the `--update-cluster-autoscaler` flag. The `--min-count` and `--max-count` flags specify the minimum and maximum number of nodes in the node pool. In this example, the cluster autoscaler is enabled with a minimum count of one node and a maximum count of five nodes:

    ```azurecli
    az aks nodepool update \
      --resource-group <resource-group-name> \
      --cluster-name <cluster-name> \
      --name <node-pool-name> \
      --update-cluster-autoscaler \
      --min-count 1 \
      --max-count 5
    ```

Note

If you want to disable the cluster autoscaler on a node pool, use the [`az aks nodepool update`][az-aks-nodepool-update] command with the `--disable-cluster-autoscaler` flag instead of `--update-cluster-autoscaler`.

## Next steps: Manage node pools in AKS

To learn more about managing node pools in AKS, see [Manage node pools in Azure Kubernetes Service (AKS)](manage-node-pools).