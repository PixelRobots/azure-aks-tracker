---
layout: Conceptual
title: 'Tutorial: Enable Telemetry and Monitoring for your Azure Linux with OS Guard (Preview) Cluster | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-monitor-os-guard-aks
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
description: In this Azure Linux tutorial, you learn how to enable telemetry and monitoring for your Azure Linux with OS Guard (preview) cluster.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 1be72998-9690-c000-e9e4-2f122fd530e4
document_version_independent_id: 51261623-cbb7-424d-5a41-679b0a422ae2
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-monitor-os-guard-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-monitor-os-guard-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-monitor-os-guard-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ea207779-486e-a786-f466-7552d922584b
---

# Tutorial: Enable Telemetry and Monitoring for your Azure Linux with OS Guard (Preview) Cluster | Microsoft Learn

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Note

Azure Linux with OS Guard (preview) is being replaced by Azure Container Linux (ACL).

Azure Container Linux is the long‑term, immutable, container‑optimized Linux operating system (OS) for Azure Kubernetes Service (AKS). It provides a secure, minimal, and operationally consistent host OS designed to run containerized workloads at scale.

For more information, see the [Azure Container Linux (ACL) overview](azure-container-linux-overview).

In this tutorial, part *four of five*, you learn how to:

- Enable Container Insights to monitor your existing cluster.
- Verify the agent is deployed successfully.
- Verify the solution is enabled.

In the next tutorial, you learn how to upgrade your Azure Linux nodes.

## Prerequisites

- In previous tutorials, you created and deployed an Azure Linux with OS Guard cluster. To complete this tutorial, you need an existing cluster. If you haven't completed this step and want to follow along, start with [Tutorial 1: Create a cluster with Azure Linux with OS Guard for AKS](tutorial-create-cluster-os-guard-aks).
- If you're connecting an existing AKS cluster to a Log Analytics workspace in another subscription, you need to register the `Microsoft.ContainerService` resource provider in the subscription with the Log Analytics workspace. For more information, see [Register resource provider](/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider).
- You need the latest version of Azure CLI. Use the [`az version`](/en-us/cli/azure/reference-index?#az-version) command to find the version. To upgrade to the latest version, use the [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade) command.

## Azure Linux with OS Guard considerations and limitations

Before you begin, review the following considerations and limitations for Azure Linux with OS Guard (preview):

- Kubernetes version 1.32.0 or higher is required for Azure Linux with OS Guard.
- All Azure Linux with OS Guard images have [Federal Information Process Standard (FIPS)](/en-us/azure/aks/enable-fips-nodes) and [Trusted Launch](/en-us/azure/aks/use-trusted-launch) enabled.
- Azure CLI and ARM templates are the only supported deployment methods for Azure Linux with OS Guard on AKS in preview. PowerShell and Terraform aren't supported.
- [Arm64](/en-us/azure/aks/use-arm64-vms) images aren't supported with Azure Linux with OS Guard on AKS in preview.
- `NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image) for Azure Linux with OS Guard on AKS. `Unmanaged` and `SecurityPatch` are incompatible with Azure Linux with OS Guard due to the immutable /usr directory.
- [Artifact Streaming](/en-us/azure/aks/artifact-streaming) isn't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Gen 1 virtual machines (VMs)](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.

## Connect to your cluster

Before enabling monitoring, it's important to ensure you're connected to the correct cluster. Get the credentials for your Azure Linux with OS Guard cluster and configure kubectl to use them using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

```azurecli
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

## Enable monitoring

You can enable monitoring for your Azure Linux with OS Guard cluster using a default Log Analytics workspace or by specifying a Log Analytics workspace. The following steps show you how to enable monitoring for your cluster using either method.

### Option 1: Use a default Log Analytics workspace

Use the following commands to check if the monitoring add-on is already enabled for your cluster. If it isn't, the command enables monitoring for your Azure Linux with OS Guard cluster using a default Log Analytics workspace in the default resource group of the AKS cluster subscription. If one doesn't already exist in the region, the default workspace created resembles the following format: *DefaultWorkspace-&lt; GUID &gt;-&lt; Region &gt;*.

```azurecli
# Check if monitoring addon is already enabled
MONITORING_ENABLED=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "addonProfiles.omsagent.enabled" -o tsv)

if [ "$MONITORING_ENABLED" != "true" ]; then
  az aks enable-addons --addons monitoring --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
fi
```

### Option 2: Specify a Log Analytics workspace

You can specify a Log Analytics workspace to enable monitoring of your Azure Linux with OS Guard cluster. The resource ID of the workspace is in the following format: `"/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"`.

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