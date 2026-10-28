---
layout: Conceptual
title: 'Tutorial: Enable Telemetry and Monitoring for your Azure Linux Container Host Cluster | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-monitor-azure-linux-aks
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
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
manager: kumud
description: In this Azure Linux tutorial, you learn how to enable telemetry and monitoring for your Azure Linux Container Host cluster.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: c109d036-3c3a-b0ee-136e-599e0831459e
document_version_independent_id: 33cd37b8-b5eb-e7e4-0392-90c266bb53b3
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-monitor-azure-linux-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-monitor-azure-linux-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-monitor-azure-linux-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 15e9a464-3440-fac7-6c0e-2cab37bbd24d
---

# Tutorial: Enable Telemetry and Monitoring for your Azure Linux Container Host Cluster | Microsoft Learn

In this tutorial, part *four of five*, you learn how to:

- Enable Container Insights to monitor your existing cluster.
- Verify the agent is deployed successfully.
- Verify the solution is enabled.

The commands in this tutorial use the environment variables set in [Tutorial 1: Create a cluster with the Azure Linux Container Host for AKS](tutorial-create-cluster-azure-linux-aks).

In the next and last tutorial, you learn how to upgrade your Azure Linux nodes.

## Prerequisites

- In previous tutorials, you created and deployed an Azure Linux Container Host cluster. To complete this tutorial, you need an existing cluster. If you haven't done this step and would like to follow along, start with [Tutorial 1: Create a cluster with the Azure Linux Container Host for AKS](tutorial-create-cluster-azure-linux-aks).
- If you're connecting an existing AKS cluster to a Log Analytics workspace in another subscription, the Microsoft.ContainerService resource provider must be registered in the subscription with the Log Analytics workspace. For more information, see [Register resource provider](/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider).
- You need the latest version of Azure CLI. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Connect to your cluster

Before enabling monitoring, it's important to ensure you're connected to the correct cluster. Get the credentials for your Azure Linux Container Host cluster and configure kubectl to use them using the [`az aks get-credentials`](/en-us/cli/azure/aks#az_aks_get_credentials) command.

```azurecli
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

## Enable monitoring

You can enable monitoring for your Azure Linux Container Host cluster using a default Log Analytics workspace or by specifying a Log Analytics workspace. The following steps show you how to enable monitoring for your cluster using either method.

### Option 1: Use a default Log Analytics workspace

Use the following commands to check if the monitoring add-on is already enabled for your cluster. If it isn't, the command enables monitoring for your Azure Linux Container Host cluster using a default Log Analytics workspace in the default resource group of the AKS cluster subscription. If one doesn't already exist in the region, the default workspace created resembles the following format: *DefaultWorkspace-&lt; GUID &gt;-&lt; Region &gt;*.

```bash
# Check if monitoring addon is already enabled
MONITORING_ENABLED=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "addonProfiles.omsagent.enabled" -o tsv)

if [ "$MONITORING_ENABLED" != "true" ]; then
  az aks enable-addons --addons monitoring --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
fi
```

### Option 2: Specify a Log Analytics workspace

You can specify a Log Analytics workspace to enable monitoring of your Azure Linux Container Host cluster. The resource ID of the workspace is in the following format: `"/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"`.

Enable monitoring with a specified workspace using the [`az aks enable-addons`](/en-us/cli/azure/aks#az_aks_enable_addons) command. Replace `<workspace-resource-id>` with the resource ID of your Log Analytics workspace.

```azurecli
az aks enable-addons -addons monitoring --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --workspace-resource-id <workspace-resource-id>
```

## Verify agent and solution deployment

1. Verify the agent is deployed successfully using the following command:

    ```bash
    kubectl get ds ama-logs --namespace=kube-system
    ```

    Example output:

    ```output
    User@aksuser:~$ kubectl get ds ama-logs --namespace=kube-system
    NAME       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
    ama-logs   3         3         3       3            3           <none>          3m22s
    ```
2. Verify deployment of the solution using the following command:

    ```bash
    kubectl get deployment ama-logs-rs -n=kube-system
    ```

    Example output:

    ```text
    User@aksuser:~$ kubectl get deployment ama-logs-rs -n=kube-system
    NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE    AGE
    ama-logs-rs    1         1         1            1            3h
    ```

## Verify solution configuration

Get the configuration of the solution using the [`az aks show`](/en-us/cli/azure/aks#az_aks_show) command. With this command, you can check if the solution is enabled, what the Log Analytics workspace resource ID is, and get summary information about the cluster.

```azurecli
az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "addonProfiles.omsagent"
```

After a few minutes, the command completes and returns JSON-formatted information about the solution. The results of the command should show the monitoring add-on profile and resemble the following example output:

```JSON
{
  "config": {
    "logAnalyticsWorkspaceResourceID": "/subscriptions/xxxxx/resourceGroups/xxxxx/providers/Microsoft.OperationalInsights/workspaces/xxxxx"
  },
  "enabled": true
}
```