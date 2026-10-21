---
layout: Conceptual
title: Use cluster labels in AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/cluster-labels
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn how to use labels in Kubernetes clusters in AKS Hybrid and Edge.
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.lastreviewed: 2024-08-01T00:00:00.0000000Z
ms.reviewer: guanghu
ms.custom: hyperconverged
locale: en-us
document_id: fc650c9f-1af3-fe4c-d075-4ae3620db941
document_version_independent_id: d5c5b253-1c1b-7521-c5af-480a32427213
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/cluster-labels.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/cluster-labels
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/cluster-labels.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: 71e19fa6-b26c-78e7-4d5e-76a9fda3152c
---

# Use cluster labels in AKS Hybrid and Edge | Microsoft Learn

> 
> Applies to: AKS on Azure Local

If you have multiple node pools, you might want to add a label during node pool creation. Kubernetes labels handle the scheduling rules for nodes.

This article describes how to use labels in a Kubernetes cluster on AKS Hybrid and Edge.

## Create a Kubernetes cluster with a label

1. Create a Kubernetes cluster with a label using the [`az aksarc create`](/en-us/cli/azure/aksarc#az-aksarc-create) command and specify the `--node-labels` parameter to set your labels. Labels must be a key/value pair and have [valid syntax](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set).

    ```azurecli
    az aksarc create --resource-group myResourceGroup --name myAKSCluster --node-count 2 --nodepool-labels dept=IT
    ```
2. Verify that the labels were set using the `kubectl get nodes --show-labels` command:

    ```powershell
    kubectl get nodes --show-labels | grep -e "dept=IT"
    ```

## Create a node pool with a label

1. Create a node pool with a label using the [`az aksarc nodepool add`](/en-us/cli/azure/aksarc/nodepool#az-aksarc-nodepool-add) command and specify a name for the `--name` parameters and labels for the `--labels` parameter. Labels must be a key/value pair and have [valid syntax](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set).

    The following example creates a node pool named `labelnp` with the label `dept=HR`:

    ```azurecli
    az aksarc nodepool add --resource-group myResourceGroup --cluster-name myAKSCluster --name labelnp --node-count 1 --labels dept=HR –no-wait
    ```

    The following example output from the [`az aksarc nodepool list`](/en-us/cli/azure/aksarc/nodepool#az-aksarc-nodepool-list) command shows the `labelnp` node pool creates nodes with the specified `nodeLabels`:

    ```json
    [
      {
        ...
        "count": 1,
        ...
        "name": "labelnp",
        "orchestratorVersion": "1.15.7",
        ...
        "provisioningState": "Creating",
        ...
        "nodeLabels":  {
          "costcenter": "5000",
          "dept": "HR"
        },
        ...
      },
     ...
    ]
    ```
2. Verify the labels were set using the `kubectl get nodes --show-labels` command:

    ```powershell
    kubectl get nodes --show-labels | grep -e "dept=HR"
    ```

## Update labels on existing node pools

1. Update a label on an existing node pool using the [az aksarc nodepool update](/en-us/cli/azure/aksarc/nodepool#az-aksarc-nodepool-update) command. Updating labels on existing node pools overwrites the old labels with the new labels. Labels must be key/value pairs and [have a valid syntax](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set).

    ```azurecli
    az aksarc nodepool update --resource-group myResourceGroup --cluster-name myAKSCluster --name labelnp --labels dept=ACCT costcenter=6000 --no-wait
    ```
2. Verify the labels were set using the `kubectl get nodes --show-labels` command.

    ```powershell
    kubectl get nodes --show-labels | grep -e "costcenter=6000" -e "dept=ACCT"
    ```

## Unavailable labels

AKS Hybrid and Edge follows the same rules as AKS:

- You can't change the reserved system label. If you attempt to do so, an error is returned.
- The Kubernetes and AKS reserved prefixes can't be used for any node.

For more information, see [Unavailable labels](/en-us/azure/aks/use-labels#unavailable-labels) in the AKS documentation.