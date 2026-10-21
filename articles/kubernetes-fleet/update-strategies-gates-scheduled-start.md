---
layout: Conceptual
title: Use scheduled start gates in Azure Kubernetes Fleet Manager Update Run Strategies | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/update-strategies-gates-scheduled-start
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
learn_banner_products:
- azure
description: Learn how to schedule the day and time a group or stage starts updating in Azure Kubernetes Fleet Manager update strategies.
ms.topic: how-to
ms.date: 2026-07-17T00:00:00.0000000Z
author: JunyuQian
ms.author: junyuqian
ms.service: azure-kubernetes-fleet-manager
locale: en-us
document_id: 09c26d9b-de1e-0564-1677-508c2eb66e72
document_version_independent_id: e6107983-80cb-eac5-2bda-387a60a9342a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/update-strategies-gates-scheduled-start.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/update-strategies-gates-scheduled-start
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/update-strategies-gates-scheduled-start.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 6e2cdeb8-5b8c-13c0-9726-d3f68a334632
---

# Use scheduled start gates in Azure Kubernetes Fleet Manager Update Run Strategies | Microsoft Learn

Platform administrators often need to ensure that cluster updates only start at specific days and times. For example, choose times when teams are available to monitor or when user traffic is at its lowest.

Fleet Manager provides scheduled start gates that platform administrators can use to delay the progression of an update run until a specified day and time. For example, you can place a scheduled start gate before the production stage of an update strategy. This gate ensures that production clusters don't begin updating until the scheduled time, even if earlier stages complete ahead of schedule.

This article covers how to define scheduled start gates in update strategies, and how they complete during update run execution.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

## Prerequisites

- Read the [conceptual overview of Fleet updates](concepts-update-orchestration), which provides an explanation of update runs, stages, groups, and strategies referenced in this guide.
- You must have a Fleet resource with one or more member clusters. If you don't have a Fleet resource, follow the [quickstart](quickstart-create-fleet-and-members) to create a Fleet resource and join Azure Kubernetes Service (AKS) clusters as members.
- Set the following environment variables:

    ```bash
    export GROUP=<resource-group>
    export FLEET=<fleet-name>
    export CLUSTERID=<aks-cluster-resource-id>
    export STRATEGY=<strategy-name>
    ```
- If you're following the Azure CLI instructions in this article, you need the latest Azure CLI installed. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- You also need the `fleet` Azure CLI extension. To install it, run the following command:

    ```azurecli
    az extension add --name fleet
    ```

    Run the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command to update to the latest version of the extension released:

    ```azurecli
    az extension update --name fleet
    ```

## Configure scheduled start gates in update strategies

You can configure scheduled start gates when creating an update strategy or when creating an update run with **Stages** as the update sequence type.

Keep the following points in mind when configuring scheduled start gates:

- You can't use scheduled start gates with a **One-by-one** update sequence.
- To control when all groups in a stage start, configure the scheduled start gate at the stage level instead of the group level. A group-level scheduled start gate only affects that specific group.
- You can only place scheduled start gates **before** a stage or group. Unlike approval gates, they **can't** be placed as after-gates.

Here are some examples of how you can use this functionality:

- A scheduled start gate before your production stage ensures updates don't start until Sunday at 8:00 PM, avoiding potential disruptions during business hours.
- A scheduled start gate before a group lets you stagger executions, for example, upgrading European clusters at 9:00 AM GMT and US clusters at 9:00 AM PST.

Note

If individual AKS clusters also have [planned maintenance windows](/en-us/azure/aks/planned-maintenance) configured, those windows are still honored. A cluster doesn't start its upgrade until both the scheduled start gate completes and the cluster's own planned maintenance window allows it.

## Configure stage and group scheduled starts in an update strategy

1. Create a JSON file to define the stages and groups for the update strategy. Here's an example file that defines scheduled start gates on stages and groups (*example-stages.json*):

    ```json
    {
        "stages": [
           {
             "name": "stage-1",
             "beforeGates": [
               {
                 "displayName": "wait until Wednesday 2am",
                 "type": "ScheduledStart",
                 "scheduledStartConfiguration": {
                   "startDay": "Wednesday",
                   "startTime": "02:00",
                   "utcOffset": "+00:00"
                 }
               }
             ],
             "groups": [
               {
                 "name": "group-1",
                 "beforeGates": [
                   {
                     "displayName": "wait until Thursday 10am PST",
                     "type": "ScheduledStart",
                     "scheduledStartConfiguration": {
                       "startDay": "Thursday",
                       "startTime": "10:00",
                       "utcOffset": "-08:00"
                     }
                   }
                 ]
               }
             ]
           }
        ]
    }
    ```

    The `scheduledStartConfiguration` object requires three fields:

    | Field | Description | Format |
    | --- | --- | --- |
    | `startDay` | The day of the week for the scheduled start. | `Sunday`, `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, or `Saturday` |
    | `startTime` | The local time of day for the scheduled start. | 24-hour `HH:MM` format (for example, `02:00`, `14:30`) |
    | `utcOffset` | The UTC offset for the scheduled time. | `+HH:MM` or `-HH:MM` format, ranging from `-14:00` to `+14:00` |
2. Create a new update strategy using the [`az fleet updatestrategy create`](/en-us/cli/azure/fleet/updatestrategy#az-fleet-updatestrategy-create) command with the `--stages` flag set to the name of your JSON file.

    ```azurecli
    az fleet updatestrategy create \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name $STRATEGY \
     --stages example-stages.json
    ```

Note

When the update run reaches a scheduled start gate, the system computes the next occurrence of the specified day and time. For example, if the gate specifies `Wednesday 02:00 UTC` and the update run reaches it on Monday, the gate waits until Wednesday at 02:00 UTC. If it reaches the gate on Wednesday at 03:00 UTC (already past), it waits until the following Wednesday.

## Understanding scheduled start gate states

Scheduled start gates are represented as **gates** that control the flow of the update run. The gate's state indicates whether the scheduled time is reached. The update run itself also maintains the status of the gate. Here's a list of all the gate states that you can see in the update run:

- **Not Started**: Until the update run reaches a gate, it shows as `NotStarted`.
- **Pending**: While a gate is waiting for its scheduled time, it's in state `Pending`. The gate also has an `absoluteStartTime` property that shows the exact UTC completion time.
- **Skipped**: If you skip a group or stage, all gates in that group or stage automatically move to the `Skipped` state.
- **Completed**: A gate moves to `Completed` either automatically when the scheduled time is reached, or manually when a user patches the gate's state to `Completed`.

## Manually complete a scheduled start gate during an update run

If you want to proceed with the update ahead of schedule, you can manually complete a scheduled start gate before the scheduled time by setting its state to `Completed`.

1. Retrieve the update run status by using the [`az fleet updaterun show`](/en-us/cli/azure/fleet/updaterun#az-fleet-updaterun-show) command.

    ```azurecli
    az fleet updaterun show \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name <run-name>
    ```
2. Under the `status` JSON object in the response, look for the stage or group where you configured the scheduled start gate. Find the matching `beforeGates` JSON object. In the following example, the beforeGate with `displayName``wait until Wednesday 2am` is in state **Pending** - it's waiting for the scheduled time.

    ```json
    {
      "status": {
        "stages": [
          {
            "beforeGates": [
              {
                "displayName": "wait until Wednesday 2am",
                "gateId": "/subscriptions/<subscription id>/resourceGroups/<resource group>/providers/Microsoft.ContainerService/fleets/<fleet name>/gates/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e",
                "status": {
                  "completedTime": null,
                  "error": null,
                  "startTime": "2025-08-08T06:20:46.283255+00:00",
                  "state": "Pending"
                }
              }
            ],
            ...
          }
        ]
      }
    }
    ```
3. The output can be large, making it difficult to find the gate you're looking for. Using a tool like **jq** can make it easier to find pending scheduled start gates. For example, to retrieve all stage gates that are currently waiting:

    ```azurecli
    az fleet updaterun show \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name <run-name> \
    | jq '.status.stages[] | .beforeGates | .[] | select(.status.state == "Pending")'
    ```
4. Once you find the gate you want to manually complete, identify its `gateId`. Note the last part of the gateId (after the final slash). For example, for the **Pending** gate in the prior example response use `aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e`.
5. Complete the gate early by using the [`az fleet gate update`](/en-us/cli/azure/fleet/gate#az-fleet-gate-update) command with the gate name from the previous step.

    ```azurecli
    az fleet gate update \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --gate-name aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e \
     --state Completed
    ```

Alternatively, you can list all scheduled start gates across all update runs in a fleet.

1. Use the [`az fleet gate list`](/en-us/cli/azure/fleet/gate#az-fleet-gate-list) command, filtering for gates by type and state.

    ```azurecli
    az fleet gate list \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --gate-type ScheduledStart \
     --state Pending
    ```
2. As described previously, complete the gate early by using the `az fleet gate update` command with the gate name returned from the list command.

    ```azurecli
    az fleet gate update \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --gate-name aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e \
     --state Completed
    ```

## Cleaning up

After your update run finishes, you might want to clean up the gate resources that you created. If you see leftover scheduled start gates when listing all pending gates, use these steps to remove them.

Note

You can't delete gates directly. Instead, you must delete the update run associated with the gate. This action automatically deletes **all** gates associated with the update run.

1. Identify the update run associated with the gate that you want to delete. Find the update run name in the gate `target.updateRunProperties.name` field.
2. Delete the update run:

    ```azurecli
    az fleet updaterun delete \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name <run-name>
    ```
3. All gates associated with the update run are now deleted.