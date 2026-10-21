---
layout: Conceptual
title: Configure alerting of Update Runs for Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-monitor-update-runs
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
description: See how to set up alerts for Azure Kubernetes Fleet Manager Update Runs using Azure Resource Graph and Azure Monitor.
ms.topic: how-to
ms.date: 2025-03-05T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
locale: en-us
document_id: ebbbd953-f333-3328-825f-f340587353df
document_version_independent_id: 0a563115-d8de-5bee-062d-fb6b1c03b631
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-monitor-update-runs.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-monitor-update-runs
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-monitor-update-runs.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d3928677-9b71-43a6-875f-004dc4f98b65
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/6bbc70ca-58b2-4c69-8249-28ec92c08029
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 261519df-ba9b-79ce-ee2a-12a24bb51165
---

# Configure alerting of Update Runs for Azure Kubernetes Fleet Manager | Microsoft Learn

Fleet administrators can monitor the status of long-running update runs by configuring alerts in Azure Monitor. Fleet update run resource changes are ingested into [Azure Resource Graph](/en-us/azure/governance/resource-graph/overview), allowing administrators to configure alerts and automations via Azure Monitor and Log Analytics.

Data about manual or auto-upgrade update runs are stored in Azure Resource Graph, giving administrators the opportunity to query based on Fleet name, [update run status](/en-us/rest/api/fleet/update-runs/get#updatestate), update stages, and cluster name.

Regardless of which Azure Subscription or Region your fleet's member clusters are located in, the update run data is always in the Azure Resource Graph of the Azure Subscription of the Fleet Manager resource.

In order to query your update run data, you need to use queries written using the [Kusto Query Language (KQL)](/en-us/kusto/query).

## Understand update run data in Azure Resource Graph

To learn how to work with Azure Resource Graph and Fleet update run data, let's use the Azure Resource Graph Explorer to query update run data.

1. Start by opening the [Azure Resource Graph Explorer](https://portal.azure.com/#view/HubsExtension/ArgQueryBlade) in the Azure portal.
2. Select **Table** and then expand **aksresources**. Fleet Manager's resources have the prefix `Microsoft.ContainerService/fleets`.

    [![Screenshot of the Azure Resource Graph Explorer with the aksresources Table expanded.](media/monitor-update-runs/monitor-update-run-azure-resource-graph-explorer.png)](media/monitor-update-runs/monitor-update-run-azure-resource-graph-explorer.png#lightbox)
3. In the **Table** pane, select **aksresources** to add it to the explorer query box.
4. Now select `Microsoft.ContainerService/fleets/updateruns`. Your explorer query box should look like the following KQL sample.

    ```kusto
    aksresources
    | where type == "microsoft.containerservice/fleets/updateruns"
    ```
5. Run the query to retrieve all update run data held in the Azure Resource Graph for the current Azure Subscription. Update run data is held as a JSON object in the `properties` field of the result. You can view a sample of this object later in this article.

### Filter to a Fleet Manager instance

When you build a Kusto query against Azure Resource Graph, you can use the following sample query as a guide on how to select only update runs associated with a particular Fleet Manager resource.

You can add a manual filter to your explorer query to select your Fleet Manager instance as follows.

1. In the explorer query add the additional where clause manually, replacing the `your-fleet-name` placeholder with the name of your Fleet Manager.

    ```kusto
    aksresources
    | where type == "microsoft.containerservice/fleets/updateruns"
    | where id contains ('Microsoft.ContainerService/fleets/your-fleet-name')
    ```
2. Run the query to see the result set only includes update runs for the specified Fleet Manager.

### Filter by update run status

Now that you know how to find update runs associated with your Fleet Manager you can add further filters so results are based on the state of the update run.

1. Update your explorer query by expanding the `Microsoft.ContainerService/fleets/updateruns` node, followed by `status` and `status`.
2. Select `state` so that the property is added to your explorer query.

    [![Screenshot of selecting a field in an update run in Azure Resource Graph Explorer to add it to the query.](media/monitor-update-runs/monitor-update-run-query-add-filter.png)](media/monitor-update-runs/monitor-update-run-query-add-filter.png#lightbox)

    Your explorer query should be similar to the following sample.

    ```kusto
    aksresources
    | where type == "microsoft.containerservice/fleets/updateruns"
    | where id contains ('Microsoft.ContainerService/fleets/your-fleet-name')
    | where properties['status']['status']['state'] == "INSERT_VALUE_HERE"
    ```
3. Replace the `INSERT_VALUE_HERE` placeholder with an appropriate [update run status](/en-us/rest/api/fleet/update-runs/get#updatestate) value. For example, to receive only failed update runs set this value to `Failed`.
4. Run the query and you receive only update runs for your Fleet Manager that have a matching status.

## Validate outcomes, not just lifecycle state

If you use `maxAllowedFailures`, don't rely on the update run, stage, or group state alone. `Completed` only means the configured failure threshold wasn't exceeded when Fleet Manager made its scheduling decisions. It doesn't guarantee a minimum success rate.

The `FailureCount` fields represent counts of failed member updates:

- **`UpdateRun.FailureCount`**: Total failed member updates across all stages and groups.
- **`Stage.FailureCount`**: Total failed member updates across all groups within the stage.
- **`Group.FailureCount`**: Total failed member updates within that group.

Always review these counts together with `members.status.state`, failure conditions, and member `message` values.

For example, suppose you roll out a node image update to a stage with 10 member clusters and configure `maxAllowedFailures` to `"20%"`. The stage might finish in `Completed` state with `FailureCount = 2`. In that case, use the following query to identify which two member clusters failed, review their failure messages, and decide whether the rollout outcome is acceptable or whether you need to retry or investigate further.

The following query expands the hierarchy so that you can validate actual rollout outcomes, not just lifecycle states:

```kusto
aksresources
| where type == "microsoft.containerservice/fleets/updateruns"
| where id contains ('Microsoft.ContainerService/fleets/your-fleet-name')
| extend parsedProps = parse_json(properties)
| mv-expand stages = parsedProps.status.stages
| mv-expand groups = stages.groups
| mv-expand members = groups.members
| project updateRun = tostring(id),
          runState = tostring(parsedProps.status.status.state),
          runFailureCount = toint(parsedProps.status.status.failureCount),
          stageName = tostring(stages.name),
          stageState = tostring(stages.status.state),
          stageFailureCount = toint(stages.status.failureCount),
          groupName = tostring(groups.name),
          groupState = tostring(groups.status.state),
          groupFailureCount = toint(groups.status.failureCount),
          memberName = tostring(members.name),
          memberState = tostring(members.status.state),
          memberMessage = tostring(members.message)
| order by updateRun asc, stageName asc, groupName asc, memberName asc
```

## Advanced filtering

Azure Resource Graph Explorer offers an easy way to start exploring data you have about update runs.

The following advanced Kusto query options make it easier to use further update run properties when building your alerts.

- [mv-expand](/en-us/kusto/query/mv-expand-operator) can be used to unpack the stages, groups, and member clusters in an update run record.
- [json_parse](/en-us/kusto/query/parse-json-function) can be used to make it easier to reference JSON objects without using nested arrays.

In the following sample query we can determine which member cluster in the `canary` group of the `prod` stage failed. If no cluster in this group/stage failed then no rows are returned.

```kusto
aksresources
| where type == "microsoft.containerservice/fleets/updateruns"
| where id contains ('Microsoft.ContainerService/fleets/your-fleet-name')
| extend parsedProperties = parse_json(properties)
| mv-expand stages = parsedProperties.status.stages
| mv-expand groups = stages.groups
| mv-expand members = groups.members
| where properties.status.status.state == "Failed"
| where stages.name == "prod" and groups.name == "canary" and members.status.state == "Failed"
| project stageName = stages.name, groupName = groups.name, memberName = members.name, memberState = members.status.state, memberStartTime = members.status.startTime
```

## Building alerts

Now that you understand the Azure Resource Graph data available you can use [Azure Monitor alert rules](/en-us/azure/azure-monitor/alerts/alerts-create-log-alert-rule) with log search to define when you wish to receive alerts.

1. Start by opening the [Azure Monitor blade](https://portal.azure.com/#view/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/%7E/overview) in the Azure portal.
2. Select **Alerts** in the left navigation, followed by **+ Create**, then **Alert rule**.

    [![Screenshot of the Alert rule option highlighted in the Create menu for Azure Monitor Alerts.](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-01.png)](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-01.png#lightbox)
3. On the **Create an alert rule** screen, select **+ Select scope** and in the **Select a resource** blade, navigate to your Fleet Manager resource by selecting the Azure Subscription and resource group it resides in.

    [![Screenshot showing the selecting of the scope to create a new alert rule.](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-02.png)](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-02.png#lightbox)
4. Select the **Condition** tab and in the **Signal name** select list, choose **Custom log search**. The **Logs** blade loads on the right of the screen.

    [![Screenshot showing the Condition tab loaded and custom log search selected in the signal name drop-down.](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-03.png)](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-03.png#lightbox)
5. In **Logs**, enter the Resource Graph query you want to use to trigger an alert. You might want one of these alert patterns:

    - Alert only on update runs whose final state is `Failed`.
    - Alert on update runs where failures occurred, even if the final state is `Completed`. A `Completed` state with `FailureCount > 0` usually means `maxAllowedFailures` was configured and the run stayed within that tolerance.

    The following sample catches both patterns.

    Note

    For Azure Monitor log search queries you must prefix the `aksresources` table with `arg("").`. The remaining syntax is unchanged from the queries used earlier in this article.

    ```kusto
    arg("").aksresources
    | where type == "microsoft.containerservice/fleets/updateruns"
    | where id contains ('Microsoft.ContainerService/fleets/your-fleet-name')
    | extend parsedProps = parse_json(properties)
    | extend state = tostring(parsedProps.status.status.state),
             failureCount = toint(parsedProps.status.status.failureCount)
    | where state == "Failed" or failureCount > 0
    | project id,
              state,
              failureCount,
              startTime = parsedProps.status.status.startTime
    ```
6. Once you're happy with the results being returned by the query, select **Continue Editing Alert** to close the **Logs** blade. The query is automatically inserted into the **Search query** box. You can continue to edit it here if you wish.

    [![Screenshot showing how the query text is automatically inserted into the Search query box for the Create alert rule screen.](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-04.png)](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-04.png#lightbox)
7. Scroll down until you see **Alert logic**, using the form field to define the criteria you wish to trigger the alert. It's recommended you use a **Static** Threshold, setting the value to **0**, and the **Operator** to **Greater than**. Adjust the frequency to suit your preferred time period.

    [![Screenshot showing how to set the Alert logic to Greater than 0 with a check every 5 minutes.](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-05.png)](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-05.png#lightbox)
8. Select **Next: Actions &gt;** or the **Actions** tab to define the actions to take when the alert logic is matched. You can select a range of channels and integration options which are covered in detail in the [Azure Monitor action groups documentation](/en-us/azure/azure-monitor/alerts/action-groups#create-an-action-group-in-the-azure-portal).
9. To save the alert rule, select the **Details** tab and choose an appropriate Azure Subscription and resources group. Set the details for the alert rule by choosing a **Severity**, providing an **alert rule name**, optional description, and then select the **Azure Region** to save the alert to. Finally, set the **Identity** you wish to use to run the log query.

    [![Screenshot showing how to save an Alert rule to a resource group while setting its alert level and name.](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-06.png)](media/monitor-update-runs/monitor-update-run-set-up-alert-rule-06.png#lightbox)
10. Select the **Tags** tab to add any tags you wish, before selecting **Review + create** to create the new alert rule.

The next time the alert rule is triggered, the selected alert groups will be activated and your chosen notifications and integrations will be invoked.

## Sample update run JSON properties result

The following sample represents the `properties` payload held in Azure Resource Graph for each update run. You can use this structure to inform how you build you alerting queries or dashboards.

```json
{
    "status": {
        "failureCount": 0,
        "status": {
            "state": "Pending",
            "startTime": "2025-03-05T13:17:18.277945575Z"
        },
        "nodeImageSelection": {
            "selectedNodeImageVersions": [
                {
                    "version": "AKSAzureLinux-V2gen2-202502.26.0"
                },
                {
                    "version": "AKSWindows-2022-containerd-20348.3207.250214"
                }
            ]
        },
        "stages": [
            {
                "failureCount": 0,
                "maxAllowedFailures": 0,
                "maxConcurrency": 50,
                "status": {
                    "state": "Pending",
                    "startTime": "2025-03-05T13:17:19.51815878Z"
                },
                "name": "prod",
                "groups": [
                    {
                        "failureCount": 0,
                        "maxAllowedFailures": 0,
                        "maxConcurrency": 1,
                        "status": {
                            "completedTime": "2025-03-05T13:48:59.049364234Z",
                            "state": "Completed",
                            "startTime": "2025-03-05T13:17:19.51815818Z"
                        },
                        "name": "canary",
                        "members": [
                            {
                                "clusterResourceId": "/subscriptions/a22dfd3c-4a99-4d5a-9e2f-70ba55d59fbe/resourceGroups/rg-contoso-demo-01/providers/Microsoft.ContainerService/managedClusters/consoto-web-01",
                                "status": {
                                    "completedTime": "2025-03-05T13:31:09.441388843Z",
                                    "state": "Completed",
                                    "startTime": "2025-03-05T13:17:19.51815698Z"
                                },
                                "name": "member-consoto-web-01",
                                "operationId": "b046b73e-8827-45a7-8696-d1da0815941b",
                                "message": "Skipped upgrade of following agent pool(s): current node image version \"AKSWindows-2022-containerd-20348.3207.250214\" of agent pool \"win\" is already at or ahead of target upgrade version \"AKSWindows-2022-containerd-20348.3207.250214\"."
                            },
                            {
                                "clusterResourceId": "/subscriptions/3a22dfd3c-4a99-4d5a-9e2f-70ba55d59fbe/resourceGroups/rg-contoso-demo-01/providers/Microsoft.ContainerService/managedClusters/consoto-web-02",
                                "status": {
                                    "completedTime": "2025-03-05T13:48:59.049364234Z",
                                    "state": "Completed",
                                    "startTime": "2025-03-05T13:31:09.495402941Z"
                                },
                                "name": "member-consoto-web-02",
                                "operationId": "759816e9-d924-4ff4-a992-97aac2a2dddb"
                            }
                        ]
                    },
                    {
                        "failureCount": 0,
                        "maxAllowedFailures": 0,
                        "maxConcurrency": 1,
                        "status": {
                            "state": "Pending",
                            "startTime": "2025-03-05T13:17:19.51826128Z"
                        },
                        "name": "apac",
                        "members": [
                            {
                                "clusterResourceId": "/subscriptions/fe691fe1-d1ce-43b9-869a-73c4a14cdafc/resourceGroups/rg-contoso-demo-02/providers/Microsoft.ContainerService/managedClusters/consoto-app-01",
                                "status": {
                                    "state": "Pending",
                                    "startTime": "2025-03-05T13:17:19.51826048Z",
                                    "error": {
                                        "message": "target upgrade node image version \"AKSAzureLinux-V2gen2-202502.26.0\" for agent pool pool is not available in region \"australiaeast\" \n",
                                        "code": "NodeImageVersionNotAvailable"
                                    }
                                },
                                "name": "member-consoto-app-01",
                                "message": "set member: member-consoto-app-01 to Pending due to failed validation err: target upgrade node image version \"AKSAzureLinux-V2gen2-202502.26.0\" for agent pool pool is not available in region \"australiaeast\" \n"
                            }
                        ]
                    },
                    {
                        "failureCount": 0,
                        "maxAllowedFailures": 0,
                        "maxConcurrency": 1,
                        "status": {
                            "state": "Pending",
                            "startTime": "2025-03-05T13:17:19.518346681Z"
                        },
                        "name": "europe",
                        "members": [
                            {
                                "clusterResourceId": "/subscriptions/fe691fe1-d1ce-43b9-869a-73c4a14cdafc/resourceGroups/rg-contoso-demo-03/providers/Microsoft.ContainerService/managedClusters/contoso-db-01",
                                "status": {
                                    "state": "Pending",
                                    "startTime": "2025-03-05T13:17:19.518345781Z",
                                    "error": {
                                        "message": "target upgrade node image version \"AKSAzureLinux-V2gen2-202502.26.0\" for agent pool pool is not available in region \"northeurope\" \n",
                                        "code": "NodeImageVersionNotAvailable"
                                    }
                                },
                                "name": "member-contoso-db-01",
                                "message": "set member: member-contoso-db-01 to Pending due to failed validation err: target upgrade node image version \"AKSAzureLinux-V2gen2-202502.26.0\" for agent pool pool is not available in region \"northeurope\" \n"
                            }
                        ]
                    }
                ]
            }
        ]
    },
    "provisioningState": "Succeeded",
    "managedClusterUpdate": {
        "nodeImageSelection": {
            "customNodeImageVersions": [
                {
                    "version": "AKSAzureLinux-V2-202502.26.0"
                },
                {
                    "version": "AKSWindows-23H2-gen2-25398.1425.250214"
                }
            ],
            "type": "Custom"
        },
        "upgrade": {
            "type": "NodeImageOnly"
        }
    },
    "updateStrategyId": "/subscriptions/00a3c596-fcb8-43ec-bf56-a2d19b4d3663/resourceGroups/flt-contoso-demo/providers/Microsoft.ContainerService/fleets/contoso-fleet-01/updateStrategies/safedeployment",
    "strategy": {
        "stages": [
            {
                "name": "prod",
                "afterStageWaitInSeconds": 0,
                "groups": [
                    {
                        "name": "canary"
                    },
                    {
                        "name": "apac"
                    },
                    {
                        "name": "europe"
                    }
                ]
            }
        ]
    }
}
```