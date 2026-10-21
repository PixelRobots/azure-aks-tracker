---
layout: Conceptual
title: Update Kubernetes and node images across multiple clusters using Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/update-orchestration
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
description: Learn how to orchestrate updates across multiple clusters using Azure Kubernetes Fleet Manager.
ms.topic: how-to
ms.date: 2026-08-21T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.custom:
- devx-track-azurecli
- ignite-2023
- build-2024
zone_pivot_groups: azure-portal-azure-cli
locale: en-us
document_id: c0c5ff7c-0f50-86e0-0634-47766897fc5a
document_version_independent_id: 7b46ea52-b4a6-f0d6-e81e-f41ac7e33a9f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/update-orchestration.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/update-orchestration
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/update-orchestration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 5a550862-6286-aa74-d5b9-1e2c462c90b9
---

# Update Kubernetes and node images across multiple clusters using Azure Kubernetes Fleet Manager | Microsoft Learn

**Applies to:** ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Platform admins managing large number of clusters often have problems with staging the updates of multiple clusters (for example, upgrading node OS image or Kubernetes versions) in a safe and predictable way. To address this challenge, Azure Kubernetes Fleet Manager (Fleet) allows you to orchestrate updates across multiple clusters using update runs.

Update runs consist of stages, groups, and strategies and can be applied manually for one-time updates, or automatically, for ongoing regular updates using auto-upgrade profiles. All update runs (manual or automated) honor member cluster maintenance windows.

This guide covers how to configure and manually execute update runs.

## Prerequisites

- Read the [conceptual overview of this feature](concepts-update-orchestration), which provides an explanation of update strategies, runs, stages, and groups referenced in this guide.
- You must have a Fleet resource with one or more member clusters. If not, follow the [quickstart](quickstart-create-fleet-and-members) to create a Fleet resource and join Azure Kubernetes Service (AKS) clusters as members.
- Set the following environment variables:

    ```bash
    export GROUP=<resource-group>
    export FLEET=<fleet-name>
    ```
- If you're following the Azure CLI instructions in this article, you need Azure CLI version 2.58.0 or later installed. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- You also need the `fleet` Azure CLI extension, which you can install by running the following command:

    ```azurecli
    az extension add --name fleet
    ```

    Run the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command to update to the latest version of the extension released:

    ```azurecli
    az extension update --name fleet
    ```

## Defining the cluster upgrade sequence

Update run supports two options for the cluster upgrade sequence:

- **One by one**: If you don't care about controlling the cluster upgrade sequence, `one-by-one` provides a simple approach to upgrade all member clusters of the fleet in sequence one at a time.
- **Control sequence of clusters using update groups and stages**: If you want to control the cluster upgrade sequence, you can structure member clusters in update groups and update stages. You can store this sequence as a template in the form of an [update strategy](update-create-update-strategy). You can create update runs later using the update strategies instead of defining the sequence every time you need to create an update run.

Note

- **Planned maintenance windows:** Update runs honor the [planned maintenance windows](/en-us/azure/aks/planned-maintenance) that you set at the AKS cluster level. See [planned maintenance across multiple member clusters](concepts-update-orchestration#planned-maintenance-windows) for details.
- **AKS platform-initiated upgrades:** If a member cluster stays on an unsupported Kubernetes version after the platform support grace period, AKS can upgrade it directly, outside Fleet Manager's update-run sequence and the cluster's maintenance window. See [AKS platform-initiated upgrades](concepts-update-orchestration#aks-platform-initiated-upgrades) for ways to keep member clusters under Fleet orchestration.

## Update all clusters one by one

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multi-cluster update** &gt; **Create a run**.
3. Enter a name for the update run, and then select **One by one** for the upgrade type.

    [![Screenshot of the Azure portal pane for creating update runs that update clusters one by one in Azure Kubernetes Fleet Manager.](media/update-orchestration/update-run-one-by-one.png)](media/update-orchestration/update-run-one-by-one.png#lightbox)
4. Select one of the following options for the **Upgrade scope**:

    - Kubernetes version for both control plane and node pools
    - Kubernetes version for only control plane of the cluster
    - Node image version only
5. Select one of the following options for the **Node image**:

    - **Latest image**: Updates every AKS cluster in the update run to the latest image available for that cluster in its region.
    - **Consistent image**: As it's possible for an update run to have AKS clusters across multiple regions where the latest available node images can be different (check [release tracker](/en-us/azure/aks/release-tracker) for more information). The update run picks the **latest common** image across all these regions to achieve consistency.

    Important

    Node image versions are only valid for 90 days from their original publish date. If the target node image version selected by an update run exceeds the 90-day window by the time a member cluster is upgraded, the upgrade for that member cluster might fail.

    [![Screenshot of the Azure portal pane for creating update runs. The upgrade scope section is shown.](media/update-orchestration/upgrade-scope.png)](media/update-orchestration/upgrade-scope.png#lightbox)
6. Select **Create** to create the update run.

::: zone-end

::: zone pivot="azure-cli"

1. Create an update run using the [`az fleet updaterun create`](/en-us/cli/azure/fleet/updaterun#az-fleet-updaterun-create) command with your chosen values for the `--upgrade-type` and `--node-image-selection` flags. The following command creates an update run that upgrades the Kubernetes version for both control plane and node pools and uses the latest node image available for each cluster in its region.

    The `--upgrade-type` flag supports the following values:

    - `Full` upgrades Kubernetes version for control plane and node pools along with the node images.
    - `ControlPlaneOnly` only upgrades the Kubernetes version for the control plane of the cluster.
    - `NodeImageOnly` only upgrades the node images.

    The `--node-image-selection` flag supports the following values:

    - `Latest`: Updates every AKS cluster in the update run to the latest image available for that cluster in its region.
    - `Consistent`: As it's possible for an update run to have AKS clusters across multiple regions where the latest available node images can be different (check [release tracker](/en-us/azure/aks/release-tracker) for more information). The update run picks the **latest common** image across all these regions to achieve consistency.

    ```azurecli
    az fleet updaterun create \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name run-1 \
     --upgrade-type Full \
     --kubernetes-version 1.26.0 \
     --node-image-selection Latest
    ```
2. Start the update run using the [`az fleet updaterun start`](/en-us/cli/azure/fleet/updaterun#az-fleet-updaterun-start) command.

    ```azurecli
    az fleet updaterun start \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name run-1
    ```

When creating an update run, you have the ability to control the scope of the update run. The `--upgrade-type` flag supports the following values:

- `ControlPlaneOnly` only upgrades the Kubernetes version for the control plane of the cluster.
- `Full` upgrades Kubernetes version for control plane and node pools along with the node images.
- `NodeImageOnly` only upgrades the node images.

Also, `--node-image-selection` flag supports the following values:

- **Latest**: Updates every AKS cluster in the update run to the latest image available for that cluster in its region.
- **Consistent**: As it's possible for an update run to have AKS clusters across multiple regions where the latest available node images can be different (check [release tracker](/en-us/azure/aks/release-tracker) for more information). The update run picks the **latest common** image across all these regions to achieve consistency.

Important

Node image versions are only valid for 90 days from their original publish date. If the target node image version selected by an update run exceeds the 90-day window by the time a member cluster is upgraded, the upgrade for that member cluster might fail.

**Starting an update run**:

To start update runs, run the following command:

```azurecli
az fleet updaterun start \
 --resource-group $GROUP \
 --fleet-name $FLEET \
 --name <run-name>
```

::: zone-end

## Update clusters using groups and stages

You can define an update run using update stages to sequentially order the application of updates to different update groups. For example, a first update stage might update test environment member clusters, and a second update stage would then update production environment member clusters. You can also specify what approvals are required before or after each stage, and a wait time between the update stages. You can store this sequence as a template in the form of an [update strategy](update-create-update-strategy).

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multi-cluster update** &gt; **Create a run**.
3. Enter a name for the update run, and then select **Stages** for the update sequence type.

    [![Screenshot of the Azure portal page for choosing stages mode within update run.](media/update-orchestration/update-run-stages-inline.png)](media/update-orchestration/update-run-stages-lightbox.png#lightbox)
4. Select **Create stage**, and then enter a name for the stage and set approvals and a wait time between stages if desired.

    [![Screenshot of the Azure portal page for creating a stage and defining wait time.](media/update-orchestration/create-stage-basics-inline.png)](media/update-orchestration/create-stage-basics.png#lightbox)
5. Select the update groups that you want to include in this stage. You can also specify the order of the update groups if you want to update them in a specific sequence. When you're done, select **Create**.

    [![Screenshot of the Azure portal page for stage creation that shows the selection of upgrade groups.](media/update-orchestration/create-stage-choose-groups-inline.png)](media/update-orchestration/create-stage-choose-groups.png#lightbox)
6. Select one of the following options for the **Upgrade scope**:

    - Kubernetes version for both control plane and node pools
    - Kubernetes version for only control plane of the cluster
    - Node image version only
7. Select one of the following options for the **Node image**:

    - **Latest image**: Updates every AKS cluster in the update run to the latest image available for that cluster in its region.
    - **Consistent image**: As it's possible for an update run to have AKS clusters across multiple regions where the latest available node images can be different (check [release tracker](/en-us/azure/aks/release-tracker) for more information). The update run picks the **latest common** image across all these regions to achieve consistency.

    [![Screenshot of the Azure portal pane for creating update runs. The upgrade scope section is shown.](media/update-orchestration/upgrade-scope.png)](media/update-orchestration/upgrade-scope.png#lightbox)
8. Select **Create** to create the update run.

    Specifying stages and their order every time when creating an update run can get repetitive and cumbersome. Update strategies simplify this process by allowing you to store templates for update runs. For more information, see update strategy creation and usage.
9. In the **Multi-cluster update** menu, select the update run, and then select **Start**.

::: zone-end

::: zone pivot="azure-cli"

1. Create a JSON file to define the stages and groups for the update run. Here's an example of input from the stages file (*example-stages.json*):

    ```json
    {
        "stages": [
            {
                "name": "stage1",
                "maxAllowedFailures": "2",
                "groups": [
                    {
                        "name": "group-1a"
                    },
                    {
                        "name": "group-1b"
                    },
                    {
                        "name": "group-1c"
                    }
                ],
                "afterStageWaitInSeconds": 3600
            },
            {
                "name": "stage2",
                "groups": [
                    {
                        "name": "group-2a",
                        "maxAllowedFailures": "1"
                    },
                    {
                        "name": "group-2b"
                    },
                    {
                        "name": "group-2c"
                    }
                ]
            }
        ]
    }
    ```

    Note

    The optional `maxAllowedFailures` field controls how many member cluster upgrade failures are tolerated at the stage or group level before the segment is marked as failed. When unset or `"0"`, any single failure stops the update run.

    This setting evaluates only failure count, not success rate. As a result, a group can reach `Completed` even if some or all members failed, as long as the configured threshold wasn't exceeded. After the run finishes, always review `FailureCount`, member statuses, and failure messages.

    Values can be a fixed integer (for example, `"2"`) or a percentage (for example, `"25%"`). For more information, see [Maximum allowed failures (preview)](concepts-update-orchestration#maximum-allowed-failures-preview).
2. Create an update run using the [`az fleet updaterun create`](/en-us/cli/azure/fleet/updaterun#az-fleet-updaterun-create) command with the `--stages` flag set to the name of your JSON file and your chosen values for the `--upgrade-type` and `--node-image-selection` flags. The following command creates an update run that upgrades the Kubernetes version for both control plane and node pools and uses the latest node image available for each cluster in its region.

    The `--upgrade-type` flag supports the following values:

    - `Full` upgrades Kubernetes version for control plane and node pools along with the node images.
    - `ControlPlaneOnly` only upgrades the Kubernetes version for the control plane of the cluster.
    - `NodeImageOnly` only upgrades the node images.

    The `--node-image-selection` flag supports the following values:

    - `Latest`: Updates every AKS cluster in the update run to the latest image available for that cluster in its region.
    - `Consistent`: As it's possible for an update run to have AKS clusters across multiple regions where the latest available node images can be different (check [release tracker](/en-us/azure/aks/release-tracker) for more information). The update run picks the **latest common** image across all these regions to achieve consistency.

    ```azurecli
    az fleet updaterun create \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name run-1 \
     --upgrade-type Full \
     --kubernetes-version 1.26.0 \
     --node-image-selection Latest \
     --stages example-stages.json
    ```
3. Start the update run using the [`az fleet updaterun start`](/en-us/cli/azure/fleet/updaterun#az-fleet-updaterun-start) command.

    ```azurecli
    az fleet updaterun start \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name run-1
    ```

::: zone-end

## Create an update run using update strategies

Creating an update run requires you to specify the stages, groups, order each time. Update strategies simplify this process by allowing you to store templates for update runs.

Note

It's possible to create multiple update runs with unique names from the same update strategy.

You can create an update strategy using one of the following methods:

- [Create a new update strategy and then reference it when creating an update run](update-create-update-strategy).
- Save an update strategy while creating an update run using the Azure portal.

### Save an update strategy while creating an update run

- Save an update strategy while creating an update run in the Azure portal:

    [![A screenshot of the Azure portal showing update run stages being saved as an update strategy.](media/update-orchestration/update-strategy-creation-from-run-inline.png)](media/update-orchestration/update-strategy-creation-from-run-lightbox.png#lightbox)

### Manage an update run

The following sections explain how to manage an update run using the Azure portal and Azure CLI.

::: zone pivot="azure-portal"

- On the **Multi-cluster update** page of the fleet resource, you can **Start** an update run that's either in **Not started** or **Failed** state:

    [![A screenshot of the Azure portal showing how to start an update run in the 'Not started' state.](media/update-orchestration/run-start.png)](media/update-orchestration/run-start.png#lightbox)
- On the **Multi-cluster update** page of the fleet resource, you can **Stop** a currently **Running** or **Pending** update run:

    [![A screenshot of the Azure portal showing how to stop an update run in the 'Running' state.](media/update-orchestration/run-stop.png)](media/update-orchestration/run-stop.png#lightbox)
- Within any update run in the **Not Started**, **Failed**, or **Running** state, you can select any **Stage** and **Skip** the upgrade:

    [![A screenshot of the Azure portal showing how to skip upgrade for a specific stage in an update run.](media/update-orchestration/skip-stage.png)](media/update-orchestration/skip-stage.png#lightbox)

    You can similarly skip the upgrade at the update group or member cluster level too.

::: zone-end

::: zone pivot="azure-cli"

- You can **Start** an update run that's either in **Not started** or **Failed** state using the [`az fleet updaterun start`](/en-us/cli/azure/fleet/updaterun#az-fleet-updaterun-start) command:

    ```azurecli
    az fleet updaterun start \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name <run-name>
    ```
- You can **Stop** a currently **Running** update run using the [`az fleet updaterun stop`](/en-us/cli/azure/fleet/updaterun#az-fleet-updaterun-stop) command:

    ```azurecli
    az fleet updaterun stop \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name <run-name>
    ```
- You can skip update stages or groups by specifying them in the `--targets` flag using the [`az fleet updaterun skip`](/en-us/cli/azure/fleet/updaterun#az-fleet-updaterun-skip) command:

    ```azurecli
    az fleet updaterun skip \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name <run-name> \
     --targets Group:my-group-name Stage:my-stage-name
    ```

    For more information, see [conceptual overview on the update run states and skip behavior](concepts-update-orchestration#update-run-states) on runs/stages/groups.

::: zone-end

## Automate update runs using auto-upgrade profiles

Auto-upgrade profiles are used to automatically execute update runs across member clusters when new Kubernetes or node image versions are made available.

For more information on configuring auto-upgrade profiles, see [automate upgrades of Kubernetes and node images using Azure Kubernetes Fleet Manager](update-automation).

## Generate an update run from an auto-upgrade profile

When you create an auto-upgrade profile, your clusters can be on various versions of Kubernetes or node image. Depending on your selected auto-upgrade channel, it might be some time before a new version release triggers auto-upgrade to create and execute an update run.

Auto-upgrade allows you to generate a new update run at any time using the [`az fleet autoupgradeprofile generate-update-run`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-generate-update-run) command. The resulting update run is based on the current AKS-published Kubernetes or node image version.

```azurecli
az fleet autoupgradeprofile generate-update-run \
    --resource-group $GROUP \
    --fleet-name $FLEET \
    --name $AUTOUPGRADEPROFILE
```

The generated update run isn't automatically started, allowing you to review it. If you're satisfied with the generated update run, you can start and manage it by following the steps in manage an update run.

Note

When you manually generate an update run from an auto-upgrade profile, the resulting update run might already exist. This situation happens because the name of the update run is based on the auto-upgrade profile's upgrade specification, which only changes when properties such as the node image or Kubernetes version change. In this scenario, the existing update run isn't modified.