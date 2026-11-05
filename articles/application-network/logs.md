---
layout: Conceptual
title: Monitor Data Plane and Control Plane Logs in Azure Kubernetes Application Network (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-network/logs
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
learn_banner_products:
- azure
description: Learn how to enable and view data plane and control plane logs for Azure Kubernetes Application Network in Azure Monitor using Container Insights and diagnostic settings.
author: Kochhars
ms.author: kochhars
ms.service: azure-kubernetes-app-net
ms.topic: how-to
ms.date: 2026-10-30T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: bc374e5d-49c0-b077-de76-99c8691d8ebf
document_version_independent_id: ac24bc8c-3eb6-3c05-dc66-5a326afcff5b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/application-network/logs.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: application-network/logs
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-network/logs.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 67677c1e-a897-0c19-388b-4dceb1458a74
---

# Monitor Data Plane and Control Plane Logs in Azure Kubernetes Application Network (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Azure Kubernetes Application Network provides two types of logging that you can configure based on your monitoring and troubleshooting requirements: **data plane logs** and **control plane logs**.

- **Data plane logs**: Include logs from application workloads, `applink-system` namespace components, and Envoy proxy access logs.
- **Control plane logs**: Include Istiod logs from the Azure Kubernetes Application Network control plane components.

Configure data plane log collection and control plane diagnostic settings separately. If your AKS cluster already has Container Insights enabled, its existing collection settings apply. This article describes how to configure both log paths and view them in Azure Monitor.

## Set environment variables

- Set environment variables for your selected workflow using the following commands:

    ```bash
    export SUBSCRIPTION=<subscription-id>
    
    # Set if specifying an existing or creating a new Log Analytics workspace
    export LAW_NAME=<log-analytics-workspace-name>
    
    # Set for resource group, location, and AKS cluster name
    export AKS_RG=<aks-resource-group>
    export LOCATION=<location>
    export CLUSTER_NAME=<aks-cluster-name>
    
    # Set for Azure Kubernetes Application Network member resource group, name, and member name
    export APPNET_RG=<appnet-resource-group>
    export APPNET_NAME=<appnet-name>
    export APPNET_MEMBER_NAME=<appnet-member-name>
    ```

## Enable data plane logs

Data plane logs include logs from your workloads/applications and `applink-system` workloads (Ztunnel and Istio CNI). The Azure Container Insights add-on is the preferred way to enable and view logs for troubleshooting.

When enabling data plane logs, you have the option to specify an existing Log Analytics workspace, use the default workspace for your resource group, or create a new workspace.

### Create a new Log Analytics workspace

- If creating a new Log Analytics workspace, use the [`az monitor log-analytics workspace create`](/en-us/cli/azure/monitor/log-analytics/workspace#az-monitor-log-analytics-workspace-create) command:

    ```azurecli
    az monitor log-analytics workspace create \
        --resource-group $AKS_RG \
        --workspace-name $LAW_NAME \
        --location $LOCATION
    ```

### Enable Container Insights add-on on your AKS cluster

- Enable the Container Insights add-on for your Azure Kubernetes Application Network member cluster (optionally omitting the workspace ID) using the [`az aks enable-addons`](/en-us/cli/azure/aks#az-aks-enable-addons) command.

    ```azurecli
     az aks enable-addons \
      --addon monitoring \
      --name $CLUSTER_NAME \
      --resource-group $AKS_RG \
      --workspace-resource-id /subscriptions/$SUBSCRIPTION/resourcegroups/$AKS_RG/providers/microsoft.operationalinsights/workspaces/$LAW_NAME
    ```

### View logs

- View the logs by navigating to the Log Analytics workspace and running the following query:

    ```kusto
    ContainerLogV2
    | where TimeGenerated > ago(45m)
    | where PodNamespace == "applink-system"
    ```

### Envoy access logs

Use the [Telemetry API](https://istio.io/latest/docs/reference/config/telemetry/) as described in the following steps to enable Envoy access-log generation. Container Insights collects the proxy's standard output and sends it to your Log Analytics workspace, so collection must include the namespace where the proxy runs.

For HTTP request-level logs, traffic must pass through an Envoy waypoint or gateway. Traffic that only passes through ztunnel doesn't produce Envoy HTTP access logs. For waypoint deployment and enrollment steps, see [Traffic management use cases](traffic-management-use-cases#install-waypoint-and-mark-services-as-global).

Note

A namespace can have only one Telemetry default without a workload selector or `targetRefs`. If a default already exists, merge the access-logging configuration into that resource instead of creating another default. Namespace-specific or targeted access-logging settings override the corresponding mesh-wide settings.

1. To enable Envoy access logging for a namespace, apply the following example. For an application namespace other than `default`, replace `default` in both the command and `metadata.namespace`.

    ```bash
    cat <<EOF | kubectl apply -n default -f -
    apiVersion: telemetry.istio.io/v1
    kind: Telemetry
    metadata:
      name: namespace-access-logging
      namespace: default
    spec:
      accessLogging:
      - providers:
        - name: envoy
        disabled: false
    EOF
    ```
2. To set the mesh-wide default for Envoy access logging, apply the configuration to the mesh root namespace, `applink-system`, in each member cluster where you want the default. Set the namespace in both the command and `metadata.namespace`.

    Note

    Removing `metadata.namespace` doesn't create a mesh-wide policy.

    ```bash
    cat <<EOF | kubectl apply -n applink-system -f -
    apiVersion: telemetry.istio.io/v1
    kind: Telemetry
    metadata:
      name: mesh-access-logging
      namespace: applink-system
    spec:
      accessLogging:
      - providers:
        - name: envoy
        disabled: false
    EOF
    ```

    The namespace and mesh-wide examples configure defaults at different scopes. A namespace-specific setting takes precedence over the mesh-wide default.
3. Generate application traffic through the waypoint or gateway, then query its container output in the Log Analytics workspace used by Container Insights. Replace `default` with the namespace where the proxy runs. This query includes proxy component logs as well as access logs:

    ```kusto
    ContainerLogV2
    | where TimeGenerated > ago(45m)
    | where PodNamespace == "default"
    | where ContainerName == "istio-proxy"
    | project TimeGenerated, PodNamespace, PodName, LogMessage
    | order by TimeGenerated desc
    | take 10
    ```

### Enable control plane logs

To enable control plane logs, you create a diagnostic setting and send logs to the Log Analytics workspace.

1. Set an environment variable for your diagnostic setting name using the following command:

    ```bash
    export DS_NAME=<diagnostic-settings-name>
    ```
2. Create a diagnostic setting for your Azure Kubernetes Application Network member resource and specify the Log Analytics workspace as the destination using the [`az monitor diagnostic-settings create`](/en-us/cli/azure/monitor/diagnostic-settings#az-monitor-diagnostic-settings-create) command.

    ```azurecli
    az monitor diagnostic-settings create \
    --resource /subscriptions/$SUBSCRIPTION/resourceGroups/$APPNET_RG/providers/Microsoft.AppLink/appLinks/$APPNET_NAME/appLinkMembers/$APPNET_MEMBER_NAME \
    --workspace /subscriptions/$SUBSCRIPTION/resourcegroups/$AKS_RG/providers/microsoft.operationalinsights/workspaces/$LAW_NAME \
    --logs "[{category:istiod,enabled:true}]" \
    --name $DS_NAME
    ```
3. Once enabled, navigate to the Log Analytics workspace and run the following query:

    Note

    Replace the placeholders in the `appnetMemberResourceId` variable with your member's values. Log Analytics doesn't expand Bash environment variables. Resource ID filters use the case-insensitive `=~` operator.

    ```kusto
    let appnetMemberResourceId = "/subscriptions/<subscription-id>/resourceGroups/<appnet-resource-group>/providers/Microsoft.AppLink/appLinks/<appnet-name>/appLinkMembers/<appnet-member-name>";
    MeshControlPlane
    | where TimeGenerated > ago(1h)
    | where _ResourceId =~ appnetMemberResourceId
    ```

## Log tables and schema

The following tables contain Azure Kubernetes Application Network logs in your Log Analytics workspace:

| Log table | Description |
| --- | --- |
| `ContainerLogV2` | Contains your application/workload logs |
| `MeshControlPlane` | Contains Istiod logs |

### Schema

To find the `ContainerLogV2` schema, see [ContainerLogV2 columns](/en-us/azure/azure-monitor/reference/tables/containerlogv2#columns).

`MeshControlPlane` is a custom table with the following schema:

| # | Column name | Type |
| --- | --- | --- |
| 0 | TenantId | string |
| 1 | TimeGenerated | datetime |
| 2 | Category | string |
| 3 | Level | string |
| 4 | Message | string |
| 5 | Container | string |
| 6 | PodName | string |
| 7 | SourceSystem | string |
| 8 | Type | string |
| 9 | \_ResourceId | string |

## Sample queries

### Filter logs by AKS cluster resource ID

- Filter logs based on your AKS managed cluster resource ID in the `ContainerLogV2` table by using the following query. Replace the placeholders in the `aksClusterResourceId` variable with your cluster's values:

    ```kusto
    let aksClusterResourceId = "/subscriptions/<subscription-id>/resourceGroups/<aks-resource-group>/providers/Microsoft.ContainerService/managedClusters/<aks-cluster-name>";
    ContainerLogV2
    | where TimeGenerated > ago(45m)
    | where _ResourceId =~ aksClusterResourceId
    ```

### Filter logs by Azure Kubernetes Application Network member resource ID

- Filter logs based on your Azure Kubernetes Application Network member resource ID in the `MeshControlPlane` table for control plane logs by using the following query. Replace the placeholders in the `appnetMemberResourceId` variable with your member's values:

    ```kusto
    let appnetMemberResourceId = "/subscriptions/<subscription-id>/resourceGroups/<appnet-resource-group>/providers/Microsoft.AppLink/appLinks/<appnet-name>/appLinkMembers/<appnet-member-name>";
    MeshControlPlane
    | where TimeGenerated > ago(45m)
    | where Level =~ "ERROR"
    | where _ResourceId =~ appnetMemberResourceId
    ```

    The following screenshot shows an example of the Application Network Istiod errors in Azure Monitor Logs:

    [![Screenshot of example Application Network Istiod errors in Azure Monitor logs.](media/logs/mesh-control-plane-logs.png)](media/logs/mesh-control-plane-logs.png#lightbox)