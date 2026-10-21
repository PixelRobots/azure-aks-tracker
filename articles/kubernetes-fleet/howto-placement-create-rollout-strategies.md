---
layout: Conceptual
title: Define reusable Kubernetes resource placement rollout strategies using Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-placement-create-rollout-strategies
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
learn_banner_products:
- azure
description: Learn how to create and manage reusable Azure Kubernetes Fleet Manager resource placement staged update strategies to control rollout sequence, approvals, and pauses across member clusters.
ms.topic: how-to
ms.date: 2026-07-28T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
zone_pivot_groups: azure-portal-azure-cli
locale: en-us
document_id: fe002d89-ccde-63b0-8495-65bb4f600417
document_version_independent_id: ea07b9b8-8e97-79c6-0e78-1cb93d04a5ea
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-placement-create-rollout-strategies.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-placement-create-rollout-strategies
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-placement-create-rollout-strategies.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: dc93937d-e31b-cb6b-06a2-9e20010ef012
---

# Define reusable Kubernetes resource placement rollout strategies using Azure Kubernetes Fleet Manager | Microsoft Learn

**Applies to:** ✔️ Fleet Manager with hub cluster

Platform administrators can control how Azure Kubernetes Fleet Manager rolls out resource placement updates to Fleet-managed clusters by defining staged update strategies made up of stages and groups. Within each stage and group, they can configure approvals and timed pauses to enforce governance and reduce rollout risk. Because the strategy is defined as a reusable resource, you can manage it independently from individual update runs and apply it consistently across different placements.

This article explains how to create and manage Azure Kubernetes Fleet Manager resource placement staged update strategies by using groups and stages.

You can complete the steps in this article using either the Azure portal or the Azure CLI.

Note

You can use Fleet Manager's resource placement with AKS and Azure Arc-enabled Kubernetes clusters.

## Before you begin

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Read the [conceptual overview of resource placement](concepts-resource-placement) to understand the concepts and terminology used in this article.
- You need a Fleet Manager with a hub cluster and member clusters. If you don't have one, see [Create an Azure Kubernetes Fleet Manager resource and join member clusters by using the Azure CLI](quickstart-create-fleet-and-members). You must label member clusters appropriately.
- You need access to the Kubernetes API of the hub cluster. If you don't have access, see [Access the Kubernetes API for an Azure Kubernetes Fleet Manager hub cluster](access-fleet-hub-cluster-kubernetes-api).

## Create a staged update strategy

For this article, create a cluster-scoped rollout strategy that consists of two stages - staging and canary. There's a one-hour wait time after the staging stage, with a before-stage approval for canary.

Creating namespace-scoped strategies (`StagedUpdateStrategy`) for use with namespace-scope placement (`ResourcePlacement`) is a similar experience, except you must select the hub cluster namespace from which the staged resources are distributed.

::: zone pivot="azure-cli"

1. Set the following environment variables for your subscription ID, resource group, and Kubernetes Fleet resource:

    ```bash
    export SUBSCRIPTION_ID=<subscription-id>
    export GROUP=<resource-group-name>
    export FLEET=<fleet-name>
    ```
2. Set the default Azure subscription by using the [`az account set`](/en-us/cli/azure/account#az-account-set) command:

    ```azurecli
    az account set \
        --subscription ${SUBSCRIPTION_ID}
    ```
3. Get the kubeconfig file of the Kubernetes Fleet hub cluster by using the [`az fleet get-credentials`](/en-us/cli/azure/fleet#az-fleet-get-credentials) command:

    ```azurecli
    az fleet get-credentials \
        --resource-group ${GROUP} \
        --name ${FLEET}
    ```

    Your output should look similar to the following.

    ```output
    Merged "hub" as current context in /home/fleet/.kube/config
    ```

    Note

    If you receive an error of type `InvalidHubOperation` with the message indicating the fleet is hubless, add a hub cluster. For further information, see [upgrade hub cluster type](upgrade-hub-cluster-type).
4. Save the following YAML as `crp-two-stages-strategy.yaml`.

    ```yaml
    apiVersion: placement.kubernetes-fleet.io/v1
    kind: ClusterStagedUpdateStrategy
    metadata:
      name: two-stages-strategy
    spec:
      stages:
        - name: staging
          labelSelector:
            matchLabels:
              environment: staging
          afterStageTasks:
            - type: TimedWait
              waitTime: 1h
        - name: canary
          labelSelector:
            matchLabels:
              environment: canary
          beforeStageTasks:
            - type: Approval
    ```
5. Apply the placement manifest to the Fleet Manager hub cluster.

    ```bash
    kubectl apply -f crp-two-stages-strategy.yaml
    ```
6. Check the status of the strategy resource.

    ```bash
    kubectl get clusterstagedupdatestrategy two-stages-strategy
    ```

    Your output should look similar to the following.

    ```output
    NAME                  AGE
    two-stages-strategy   47m
    ```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, go to your Fleet Manager.
2. On the service menu, under **Fleet Resources**, select **Resource placements** &gt; **Staged rollout strategies**, and then select **Create**.

    Note

    If you don't see **Fleet Resources**, your Fleet Manager doesn't have a hub cluster. For further information on how to add one, see [upgrade hub cluster type](upgrade-hub-cluster-type).
3. Enter a name for the strategy.
4. Select the **Strategy scope**, choosing either **Cluster-scoped** or **Namespace-scoped**.

    - For **Namespace-scoped**, select the existing **Namespace** on the Fleet Manager hub cluster where the Kubernetes resources to distribute are staged.
5. Select **Create Stage** and enter:

    - **Stage name** - name the stage - it must be unique across all stage names in the strategy.
    - **(Optional) Stage approvals** - select this option if you want to wait for an approval before this stage starts or after it completes.
    - **(Optional) Wait after stage** - select this option if you want to define a pause before moving to the next stage.
    - **(Optional) Wait duration** - select a predefined duration, or enter a custom value in seconds.
    - **Cluster label selector** - choose an existing member cluster label to use to select clusters for this stage.
    - **(Optional) Cluster ordering label** - choose an existing member cluster label to use to order the clusters within the stage.
    - **(Optional) Stage concurrency** - set how many clusters should be updated concurrently in the current stage.

    [![A screenshot of the Azure portal showing a new stage being added to an Azure Kubernetes Fleet Manager placement staged rollout strategy.](media/howto-placement-strategies/fleet-placement-create-strategy-add-stage.png)](media/howto-placement-strategies/fleet-placement-create-strategy-add-stage.png#lightbox)

    Note

    The maximum number of stages in each strategy is **31**.
6. Repeat until you add all stages to the strategy. Select **Create** to create the strategy.

    [![A screenshot of the Azure portal showing an Azure Kubernetes Fleet Manager placement staged rollout strategy with two stages that is pending creation.](media/howto-placement-strategies/fleet-placement-create-strategy-pending-create.png)](media/howto-placement-strategies/fleet-placement-create-strategy-pending-create.png#lightbox)
7. The page refreshes and the list displays the newly created strategy.

    [![A screenshot of the Azure portal showing a list of Azure Kubernetes Fleet Manager placement staged rollout strategies.](media/howto-placement-strategies/fleet-placement-create-strategy-list-view.png)](media/howto-placement-strategies/fleet-placement-create-strategy-list-view.png#lightbox)

::: zone-end