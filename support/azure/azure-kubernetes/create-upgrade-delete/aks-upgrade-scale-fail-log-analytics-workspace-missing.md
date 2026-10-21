---
layout: Conceptual
title: Unable to get log analytics workspace info - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/aks-upgrade-scale-fail-log-analytics-workspace-missing
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Provides solutions to an error that occurs when you upgrade or scale a Microsoft Azure Kubernetes Service cluster.
ms.date: 2024-09-11T00:00:00.0000000Z
ms.reviewer: chiragpa, cssakscic, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 019ac753-b964-6ee6-74f3-f5dae7779415
document_version_independent_id: 019ac753-b964-6ee6-74f3-f5dae7779415
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/aks-upgrade-scale-fail-log-analytics-workspace-missing.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/aks-upgrade-scale-fail-log-analytics-workspace-missing
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/aks-upgrade-scale-fail-log-analytics-workspace-missing.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 11e85dbe-337d-c203-2da7-cbfa317ace5f
---

# Unable to get log analytics workspace info - Azure | Microsoft Learn

## Summary

This article provides solutions to an "Unable to get log analytics workspace info" error that occurs when you upgrade or scale a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

When you start, upgrade, or scale an AKS cluster, you may see one of the following errors:

> 
> Failed to save container service '&lt;container service name&gt;'. Error: Unable to get log analytics workspace info. Resource ID: /subscriptions/&lt;WorkspaceSubscription&gt;/resourcegroups/defaultresourcegroup-weu/providers/microsoft.operationalinsights/workspaces/defaultworkspace-&lt;WorkspaceID&gt;-weu. Detail: operationalinsights.WorkspacesClient#GetSharedKeys: Failure responding to request: StatusCode=404 -- Original Error: autorest/azure: Service returned an error. Status=404 Code='ResourceGroupNotFound' Message='Resource group 'defaultresourcegroup-weu' could not be found.'

or

> 
> Error: Unable to retrieve log analytics workspace. If resource is intentionally deleted to stop monitoring, please also disable monitoring addon by following doc: https://aka.ms/aks-disable-monitoring-addon. If resource is deleted by mistake, please re-create it by following doc: https://aka.ms/new-log-analytics, and enable new workspace resource id by following doc: https://aka.ms/aks-enable-addons. Resource ID: /subscriptions/&lt;WorkspaceSubscription&gt;/resourcegroups/defaultresourcegroup-weu/providers/microsoft.operationalinsights/workspaces/defaultworkspace-&lt;WorkspaceID&gt;-weu. Detail: operationalinsights.WorkspacesClient#GetSharedKeys: Failure responding to request: StatusCode=404 -- Original Error: autorest/azure: Service returned an error. Status=404 Code='ResourceGroupNotFound' Message='Resource group 'defaultresourcegroup-weu' could not be found.'

This issue occurs if you delete the Log Analytics workspace or the resource group where the workspace is located without disabling monitoring on the AKS cluster.

To resolve this issue, use one of the following solutions.

## Solution 1: Recover the Log Analytics workspace

If it has been less than 14 days (the default soft-delete period) since the workspace was deleted, recover the workspace.

Note

- If it hasn't been 14 days, the workspace can't be recreated with the same name. Therefore, the recovery must be done because the AKS control plane finds the workspace based on the resource URI.
- If your workspace was deleted as part of a resource group delete operation, you must first re-create the resource group with the same name.
- To perform the workspace recovery, you must have the Contributor permissions to the subscription and resource group where the workspace is located, and the following information is also required:
    - Subscription ID
    - Resource Group name
    - Workspace name
    - Region

1. Get the workspace resource ID by running the Azure CLI command `az aks show -g <clusterRG> -n <clusterName>`.

    Here's an example output of the command:

    ```output
    root@AKS# az aks show -g aksrg -n testcluster1
    { "aadProfile": null,
    "addonProfiles": { 
        "httpapplicationrouting": {
            "config": {}, "enabled": false },
            "omsagent": {
               "config": {
                  "logAnalyticsWorkspaceResourceID": "/subscriptions/<WorkspaceSubscription>/resourceGroups/defaultresourcegroup-eus/providers/Microsoft.OperationalInsights/workspaces/defaultworkspace-<WorkspaceID>-eus"
                }, 
                "enabled": true
    ```
2. Re-create the workspace with the workspace resource ID by running the PowerShell cmdlet [New-AzOperationalInsightsWorkspace](/en-us/powershell/module/az.operationalinsights/New-AzOperationalInsightsWorkspace).
3. Run the upgrade or scale operation again.

## Solution 2: Disable monitoring on the AKS cluster

If it has been more than 14 days since the workspace was deleted, disable monitoring on the AKS cluster and then run the upgrade or scale operation again.

To disable monitoring on the AKS cluster, run the following command:

```azurecli
az aks disable-addons -a monitoring -g <clusterRG> -n <clusterName>
```

If the same error occurs while disabling the monitoring add-on, recreate the missing Log Analytics workspace and then run the upgrade or scale operation again.