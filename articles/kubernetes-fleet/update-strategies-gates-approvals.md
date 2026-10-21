---
layout: Conceptual
title: Add approvals to Azure Kubernetes Fleet Manager Update Run Strategies | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/update-strategies-gates-approvals
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
description: Add approvals to Azure Kubernetes Fleet Manager Update Strategies.
ms.topic: how-to
ms.date: 2026-07-17T00:00:00.0000000Z
author: dvadas
ms.author: davidvadas
ms.service: azure-kubernetes-fleet-manager
zone_pivot_groups: azure-portal-azure-cli
locale: en-us
document_id: 2a8fa890-bcce-492c-31ee-6e2953cc89e8
document_version_independent_id: 84539160-1dd3-e74f-ea39-06f7f3a4a481
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/update-strategies-gates-approvals.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/update-strategies-gates-approvals
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/update-strategies-gates-approvals.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a02e0d19-6f1e-54a0-bff3-0b55b2ad29cb
---

# Add approvals to Azure Kubernetes Fleet Manager Update Run Strategies | Microsoft Learn

**Applies to:** ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Platform administrators often perform pre- and post-update checks when updating multiple clusters in an update run. These checks are to ensure that the clusters are ready to be updated, or that the update didn't adversely affect cluster operations.

Fleet Manager provides approval gates that allow platform administrators to either manually, or via automation, perform any checks required to allow the update run to proceed. For example, an approval gate between the test and production stages of an update run means health checks can be run on test clusters to make sure it's safe to proceed to production.

This article covers how to define approvals in update run and strategies, and how to approve them during update run execution.

## Prerequisites

- Read the [conceptual overview of Fleet updates](concepts-update-orchestration), which provides an explanation of update runs, stages, groups, and strategies referenced in this guide.
- You must have a Fleet resource with one or more member clusters. If not, follow the [quickstart](quickstart-create-fleet-and-members) to create a Fleet resource and join Azure Kubernetes Service (AKS) clusters as members.
- Set the following environment variables:

    ```bash
    export GROUP=<resource-group>
    export FLEET=<fleet-name>
    export CLUSTERID=<aks-cluster-resource-id>
    export STRATEGY=<strategy-name>
    ```
- If you're following the Azure CLI instructions in this article, you need Azure CLI version 2.70.0 or later installed. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- You also need the `fleet` Azure CLI extension version 1.6.0 or later, which you can install by running the following command:

    ```azurecli
    az extension add --name fleet
    ```

    Run the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command to update to the latest version of the extension released:

    ```azurecli
    az extension update --name fleet
    ```

## Configure approvals in update strategies

Approvals can be configured when creating an update strategy, or when creating an update run with **Stages** as the update sequence type.

Note

Approvals can’t be used with a **One-by-one** update sequence.

Approvals can be placed on any update stage or update group in an update strategy and can either be **before** or **after** the stage or group is executed. Here are some examples of how this functionality can be used:

- An approval before your production stage means that production stage updates don't start until approval is granted. The approval confirmation can be manual, or via automation.
- An approval after each group means you can run health checks over the clusters in each of those groups. The approval waits until a user confirms that applications are running correctly on the updated clusters.

## Configure stage and group approvals in an update strategy

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multi-cluster update** &gt; **Strategies**, then **Create**.
3. Enter a name for the strategy and then under **Update sequence** select **Create Stage**.
4. Enter a **Stage name** and then select **Set stage approvals**.

    [![Screenshot of the Azure portal pane for configuring approvals in a strategy. The create stage pane is shown.](media/update-orchestration/configure-stage-group-approvals.png)](media/update-orchestration/configure-stage-group-approvals.png#lightbox)
5. In the sidebar on the right, select whether you want **before stage** and/or **after stage** approvals.
6. Enter a **Name** for the approval. This name is shown when the update run is executing and can help provide context to the approver.
7. Select **Save** in the approvals sidebar.

    [![Screenshot of the Azure portal pane for configuring approvals in a strategy. The sidebar for entering approval names is shown.](media/update-orchestration/configure-approvals-sidebar.png)](media/update-orchestration/configure-approvals-sidebar.png#lightbox)
8. Approvals can also be configured on individual groups. To do so, under **Update groups** select **Set group approvals** for the group you want to add approvals for.
9. As previously described for stages, use the approvals sidebar to configure a before and/or after approval and its name.
10. Select **Save** in the approvals sidebar.
11. Select **Create**.

::: zone-end

::: zone pivot="azure-cli"

1. Create a JSON file to define the stages and groups for the update run. Here's an example file that defines approval gates in all positions (*example-stages.json*):

    ```json
    { 
        "stages": [ 
           { 
             "name": "stage-1", 
             "beforeGates": [ 
               { 
                 "displayName": "stage before gate", 
                 "type": "Approval" 
               } 
             ], 
             "afterGates": [ 
               { 
                 "displayName": "stage after gate", 
                 "type": "Approval" 
               } 
             ], 
             "groups": [ 
               { 
                 "name": "group-1", 
                 "beforeGates": [ 
                   { 
                     "displayName": "group before gate", 
                     "type": "Approval" 
                   } 
                 ], 
                 "afterGates": [ 
                   { 
                     "displayName": "group after gate", 
                     "type": "Approval" 
                   } 
                 ] 
               } 
             ] 
           } 
        ] 
    } 
    ```
2. Create a new update strategy using the [`az fleet updatestrategy create`](/en-us/cli/azure/fleet/updatestrategy#az-fleet-updatestrategy-create) command with the `--stages` flag set to the name of your JSON file.

    ```azurecli
    az fleet updatestrategy create \ 
     --resource-group $GROUP \ 
     --fleet-name $FLEET \ 
     --name $STRATEGY \ 
     --stages example-stages.json 
    ```

::: zone-end

For more information, read [the guide to creating update strategies](update-create-update-strategy)

Approvals can also be configured [when defining groups and stages within an update run](update-orchestration#update-clusters-using-groups-and-stages).

## Understanding approval states

Approvals are represented as **gates** that control the flow of the update run. The gate’s state indicates whether or not it's approved. The update run itself also maintains the status of the gate. Here's a list of all the gate states that can be seen in the update run:

- **Not Started**: Until the update run reaches a gate, it's shown as `NotStarted`.
- **Pending**: While a gate is waiting to be approved, it's in state `Pending`.
- **Skipped**: If a group or stage is skipped, then all gates within that group or stage automatically move to `Skipped` state.
- **Completed**: Once a gate is approved, it's shown as `Completed`.

## Granting approvals during an update run

Once an update run with a strategy containing approvals is started, the update run continues to execute until it reaches one of the configured approvals. At that point, the update run doesn't proceed further until you grant approval for it to do so.

Note

Update groups execute in parallel. As such, an approval for one group affects that group only and not any others. If you want to block multiple groups, then use a single stage approval or one group approval for each of them.

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multi-cluster update**.
3. Update runs that are waiting for approval are shown with **Pending approval** in the **State** column of the table.

    [![Screenshot of the Azure portal pane for multi-cluster updates. A table of update runs including some pending approval are shown.](media/update-orchestration/update-runs-pending-approvals.png)](media/update-orchestration/update-runs-pending-approvals.png#lightbox)
4. Select **Pending approval** for the update run where you want to grant approval.
5. In the sidebar on the right, observe the details of the pending approval.
6. Select the approvals you want to grant.
7. Select **Approve**.

    [![Screenshot of the Azure portal pane for pending approvals.](media/update-orchestration/update-run-approval-sidebar.png)](media/update-orchestration/update-run-approval-sidebar.png#lightbox)

::: zone-end

::: zone pivot="azure-cli"

1. Retrieve the update run status using the [`az fleet updaterun show`](/en-us/cli/azure/fleet/updaterun#az-fleet-updaterun-show) command.

    ```azurecli
    az fleet updaterun show \ 
     --resource-group $GROUP \ 
     --fleet-name $FLEET \ 
     --name <run-name> 
    ```
2. Under the `status` JSON object in the response, look for the stage or group where the approval was configured. Find the matching `beforeGates` or `afterGates` JSON object. In the example below:

    - The beforeGate with displayName `Do not start during business hours!` is in state **Pending**. It's waiting for approval.
    - The afterGate with displayName `Run health checks` is in state **NotStarted**. Because the update run isn't up to this gate yet, there's no linked `gateId`.

    ```json
    { 
      "status": { 
        "stages": [ 
          { 
            beforeGates": [ 
              { 
                "displayName": "Do not start during business hours!", 
                "gateId": "/subscriptions/<subscription id>/resourceGroups/<resource group>/providers/Microsoft.ContainerService/fleets/<fleet name>/gates/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e", 
                "status": { 
                  "completedTime": null, 
                  "error": null, 
                  "startTime": "2025-08-08T06:20:46.283255+00:00", 
                  "state": "Pending" 
                } 
              } 
            ], 
            "afterGates": [ 
              { 
                "displayName": "Run health checks", 
                "gateId": null, 
                "status": { 
                  "completedTime": null, 
                  "error": null, 
                  "startTime": null, 
                  "state": "NotStarted" 
                } 
              } 
            ], 
    
            ...      
          }
        ]
      }
    }
    ```
3. The output can be large, making it difficult to find the approval you want to grant. Using a tool like **jq** can make it easier to find the **beforeGate** or **afterGate** in the update run response. For example, to retrieve all stage gates that are awaiting approval use the following command:

    ```azurecli
    az fleet updaterun show \ 
     --resource-group $GROUP \ 
     --fleet-name $FLEET \ 
     --name <run-name> \ 
    | jq '.status.stages[] | .beforeGates + .afterGates | .[] | select(.status.state == "Pending")'
    ```

    Note

    The update run status doesn't include the gate type. If your strategy uses multiple gate types (for example, both approval and scheduled start gates), this command returns all pending gates regardless of type. To filter by gate type, use the [`az fleet gate list`](/en-us/cli/azure/fleet/gate#az-fleet-gate-list) command with `--gate-type Approval` as shown in the following example.
4. Once you find the gate that you want to approve, identify its `gateId`. Note down the last part of the gateId (after the final slash). For example, for the Pending approval in the prior example response use **aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e**.
5. Grant the approval by using the [`az fleet gate approve`](/en-us/cli/azure/fleet/gate#az-fleet-gate-approve) command. Use the identifier that you retrieved in the previous step as the argument to –name.

    ```azurecli
    az fleet gate approve \ 
     --resource-group $GROUP \ 
     --fleet-name $FLEET \ 
     --name aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e 
    ```

Alternatively, you can list all gates across all update runs in a fleet.

Note

The list response may be large as multiple approvals can be returned. It may be more difficult to find the gate that you want to approve this way.

1. Use the [`az fleet gate list`](/en-us/cli/azure/fleet/gate#az-fleet-gate-list) command, filtering for approval gates in **Pending** state.

    ```azurecli
    az fleet gate list \ 
     --resource-group $GROUP \ 
     --fleet-name $FLEET \ 
     --gate-type Approval \
     --state Pending 
    ```
2. As described previously in step 5, grant the approval by using the [`az fleet gate approve`](/en-us/cli/azure/fleet/gate#az-fleet-gate-approve) command. This time, use the name returned from the list command as the argument to –name.

    ```azurecli
    az fleet gate approve \ 
     --resource-group $GROUP \ 
     --fleet-name $FLEET \ 
     --name aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e 
    ```

::: zone-end

## Cleaning up

After your update run is complete, you may wish to clean up the gate resources that were created. Or if you see leftover approvals when listing all pending gates, then these steps can be used to remove them.

Note

Gates cannot be deleted directly. Instead, you must delete the update run associated with the gate. This automatically deletes **all** gates associated with the update run.

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multi-cluster update**.
3. Select the update run associated with the gate that you want to delete.
4. Select **Delete**.
5. In the sidebar on the right, confirm that the correct update run is shown and then select **Delete**.
6. In the popup, select **Delete**.

::: zone-end

::: zone pivot="azure-cli"

1. Identify the update run associated with the gate that you want to delete. The update run name can be found in the gate `target.updateRunProperties.name` field.
2. Delete the update run:

    ```azurecli
    az fleet updaterun delete \ 
     --resource-group $GROUP \ 
     --fleet-name $FLEET \ 
     --name <run-name> 
    ```
3. All gates associated with the update run are now deleted.

::: zone-end