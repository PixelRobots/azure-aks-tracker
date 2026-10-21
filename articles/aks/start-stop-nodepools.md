---
layout: Conceptual
title: Stop and start node pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/start-stop-nodepools
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
description: Learn how to stop and start, or restart, node pools in an AKS cluster using the Azure CLI to manage compute costs when workloads don't need to run.
ms.topic: how-to
ms.date: 2026-08-12T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: copilot-scenario-highlight, aks-reliability, aeo-round-2
locale: en-us
document_id: 9a4801df-2588-99a6-daa7-8936ee574ce2
document_version_independent_id: 0a32b55d-0df7-4b93-c2ed-688928c9ddeb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/start-stop-nodepools.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/start-stop-nodepools
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/start-stop-nodepools.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 51e7e545-f6a0-a261-82e8-7d1ecc205dd4
---

# Stop and start node pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

You might not need to continuously run your AKS workloads. For example, you might have a development cluster that has node pools running specific workloads. To optimize your compute costs, you can completely stop your node pools in your AKS cluster. When you need to run your workloads again, you can restart the node pools. This article shows you how to stop and start node pools in an AKS cluster using the Azure CLI.

## Features and limitations

- You can't stop system pools.
- Spot node pools are supported.
- Stopped node pools can be upgraded.
- To stop a node pool, the cluster and user node pool must be running, and the node pool `provisioningState` must be `Succeeded`.
- To start a node pool, the cluster must be running and the user node pool must be stopped.
- You can't stop node pools from clusters that use [node auto-provisioning (NAP)](node-autoprovision).

Tip

You can use Azure Copilot to stop and start your node pools in the Azure portal. For more information, see [Work with AKS clusters efficiently using Azure Copilot](/en-us/azure/copilot/work-aks-clusters#start-and-stop-node-pools).

## Before you begin

This article assumes you have an existing AKS cluster. If you need an AKS cluster, create one using the [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).

This article requires Azure CLI version 2.38.0 or later. Run `az --version` to find your installed version. For more information about installing or upgrading the Azure CLI, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).

## Stop a running AKS node pool using the Azure CLI

Before you stop a node pool, confirm that the cluster and user node pool are running, the node pool `provisioningState` is `Succeeded`, and the cluster doesn't use node auto-provisioning.

Warning

Stopping a node pool stops all virtual machines in the pool. Before you stop the pool, ensure its workloads can tolerate an interruption or can run on another node pool.

1. Stop a running AKS node pool using the [`az aks nodepool stop`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-stop) command.

    ```azurecli
    az aks nodepool stop --resource-group myResourceGroup --cluster-name myAKSCluster --nodepool-name testnodepool 
    ```
2. Verify your node pool stopped using the [`az aks nodepool show`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-show) command.

    ```azurecli
    az aks nodepool show --resource-group myResourceGroup --cluster-name myAKSCluster --nodepool-name testnodepool
    ```

    The following condensed example output shows the `powerState` as `Stopped`:

    ```output
    {
    [...]
     "osType": "Linux",
        "podSubnetId": null,
        "powerState": {
            "code": "Stopped"
            },
        "provisioningState": "Succeeded",
        "proximityPlacementGroupId": null,
    [...]
    }
    ```

    Note

    If the `provisioningState` shows `Stopping`, your node pool is still in the process of stopping.

    Note

    Stopping the node pool also stops the [Cluster Autoscaler](cluster-autoscaler-overview) for that node pool. Starting the node pool restarts its Cluster Autoscaler. Don't manually modify the number of virtual machine scale set instances in the pool while it's stopped. Directly modifying AKS-managed infrastructure resources is unsupported and can cause Cluster Autoscaler inconsistencies and operation failures. For more information, see [User customization of agent nodes](support-policies#user-customization-of-agent-nodes).

## Restart an AKS node pool using the Azure CLI

Before you start a node pool, confirm that the cluster is running and the user node pool is stopped.

1. Restart a stopped node pool using the [`az aks nodepool start`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-start) command.

    ```azurecli
    az aks nodepool start --resource-group myResourceGroup --cluster-name myAKSCluster --nodepool-name testnodepool 
    ```
2. Verify your node pool started using the [`az aks nodepool show`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-show) command.

    ```azurecli
    az aks nodepool show --resource-group myResourceGroup --cluster-name myAKSCluster --nodepool-name testnodepool
    ```

    The following condensed example output shows the `powerState` as `Running`:

    ```output
    {
    [...]
     "osType": "Linux",
        "podSubnetId": null,
        "powerState": {
            "code": "Running"
            },
        "provisioningState": "Succeeded",
        "proximityPlacementGroupId": null,
    [...]
    }
    ```

    Note

    If the `provisioningState` shows `Starting`, your node pool is still in the process of starting.