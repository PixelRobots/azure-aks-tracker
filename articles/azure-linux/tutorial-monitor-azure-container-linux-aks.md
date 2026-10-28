---
layout: Conceptual
title: 'Tutorial: Enable Telemetry and Monitoring for your Azure Container Linux (ACL) Cluster | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-monitor-azure-container-linux-aks
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
description: In this Azure Linux tutorial, you learn how to enable telemetry and monitoring for your Azure Container Linux (ACL) cluster.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: ba9e925d-d49a-45a1-9332-cb77b9b8e553
document_version_independent_id: 4eac99c6-dd95-a534-5a47-6bdf3fc8fbff
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-monitor-azure-container-linux-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-monitor-azure-container-linux-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-monitor-azure-container-linux-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a5b76493-f3b2-5ad7-8975-38a42f26a800
---

# Tutorial: Enable Telemetry and Monitoring for your Azure Container Linux (ACL) Cluster | Microsoft Learn

In this tutorial, part *four of five*, you learn how to:

- Enable Container Insights to monitor your existing cluster.
- Verify the agent is deployed successfully.
- Verify the solution is enabled.

The commands in this tutorial use the environment variables set in [Tutorial 1: Create a cluster with ACL for AKS](tutorial-create-cluster-azure-container-linux-aks).

In the next tutorial, you learn how to upgrade your ACL nodes.

## Prerequisites

- In previous tutorials, you created and deployed an ACL cluster. To complete this tutorial, you need an existing cluster. If you haven't completed this step and want to follow along, start with [Tutorial 1: Create a cluster with ACL for AKS](tutorial-create-cluster-azure-container-linux-aks).
- If you're connecting an existing AKS cluster to a Log Analytics workspace in another subscription, you need to register the `Microsoft.ContainerService` resource provider in the subscription with the Log Analytics workspace. For more information, see [Register resource provider](/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider).
- Azure Container Linux requires Azure CLI version 2.86.0 or higher. Use the [`az version`](/en-us/cli/azure/reference-index?#az-version) command to find the version. To upgrade to the latest version, use the [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade) command.

## Azure Container Linux (ACL) considerations and limitations

Before you begin, review the following considerations and limitations for ACL:

- ACL is generally available starting AKS v1.34.
- ACL requires [Trusted Launch](/en-us/azure/aks/use-trusted-launch) with Secure Boot and vTPM. Non-Trusted Launch variants aren't available.
- ACL on Arm64 requires Cobalt-based (v6) SKUs to enable Trusted Launch compatibility.
- `NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image). `Unmanaged` and `SecurityPatch` are incompatible with ACL due to the immutable `/usr` directory.
- [Artifact Streaming](/en-us/azure/aks/artifact-streaming) isn't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Generation 1 VMs](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.

## Connect to your cluster

Before enabling monitoring, it's important to ensure you're connected to the correct cluster. Get the credentials for your ACL cluster and configure kubectl to use them using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

```azurecli
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

## Enable monitoring

You can enable monitoring for your ACL cluster using a default Log Analytics workspace or by specifying a Log Analytics workspace. The following steps show you how to enable monitoring for your cluster using either method.

### Option 1: Use a default Log Analytics workspace

Use the following commands to check if the monitoring add-on is already enabled for your cluster. If it isn't, the command enables monitoring for your ACL cluster using a default Log Analytics workspace in the default resource group of the AKS cluster subscription. If one doesn't already exist in the region, the default workspace created resembles the following format: *DefaultWorkspace-&lt; GUID &gt;-&lt; Region &gt;*.

```bash
# Check if monitoring addon is already enabled
MONITORING_ENABLED=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "addonProfiles.omsagent.enabled" -o tsv)

if [ "$MONITORING_ENABLED" != "true" ]; then
  az aks enable-addons --addons monitoring --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
fi
```

### Option 2: Specify a Log Analytics workspace

You can specify a Log Analytics workspace to enable monitoring of your ACL cluster. The resource ID of the workspace is in the following format: `"/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"`.

Enable monitoring with a specified workspace using the [`az aks enable-addons`](/en-us/cli/azure/aks#az_aks_enable_addons) command. Replace `<workspace-resource-id>` with the resource ID of your Log Analytics workspace.

```azurecli
az aks enable-addons --addons monitoring --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --workspace-resource-id <workspace-resource-id>
```

## Verify agent and solution deployment

1. Verify the agent is deployed successfully using the following command:

    ```bash
    kubectl get ds ama-logs --namespace=kube-system
    ```

    Example output:

    ```output
    NAME       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
    ama-logs   3         3         3       3            3           <none>          3m22s
    ```
2. Verify deployment of the solution using the following command:

    ```bash
    kubectl get deployment ama-logs-rs -n=kube-system
    ```

    Example output:

    ```output
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