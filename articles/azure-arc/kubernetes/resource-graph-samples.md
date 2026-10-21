---
layout: Conceptual
title: Azure Resource Graph sample queries for Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/resource-graph-samples
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
description: Sample Azure Resource Graph queries for Azure Arc-enabled Kubernetes showing use of resource types and tables to access Azure Arc-enabled Kubernetes related resources and properties.
ms.date: 2025-05-14T00:00:00.0000000Z
ms.topic: sample
ms.custom:
- subject-resourcegraph-sample
- devx-track-azurepowershell
- devx-track-azurecli
- build-2025
locale: en-us
document_id: 51051436-7488-820e-5118-002ed9c34eac
document_version_independent_id: e919e7b2-0f4d-fd28-af70-ec8a1b968de6
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/resource-graph-samples.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: azure-arc/kubernetes/resource-graph-samples
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/resource-graph-samples.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/d3928677-9b71-43a6-875f-004dc4f98b65
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/6bbc70ca-58b2-4c69-8249-28ec92c08029
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 9e0ade48-4b5f-d136-338e-09f290e02e1f
---

# Azure Resource Graph sample queries for Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

[Azure Resource Graph](/en-us/azure/governance/resource-graph/overview) is an Azure service that lets you query at scale, helping you effectively govern your environment. Queries are created using Kusto Query Language (KQL). For more information, see [Understanding the Azure Resource Graph query language](/en-us/azure/governance/resource-graph/concepts/query-language).

This page provides a list of sample Azure Resource Graph queries for Azure Arc-enabled Kubernetes. You can run these queries through Azure PowerShell or Azure CLI, or in the Azure portal using the Resource Graph Explorer. Feel free to modify the queries to suit your needs.

Tip

You can use Microsoft Copilot in Azure to author Azure Resource Graph queries using natural language. For more information, see [Get resource information using Microsoft Copilot in Azure](/en-us/azure/copilot/get-information-resource-graph).

## Sample queries

### List all Azure Arc-enabled Kubernetes resources

Returns a list of each Azure Arc-enabled Kubernetes cluster and relevant metadata for each cluster.

```kusto
Resources
| project id, subscriptionId, location, type, properties.agentVersion, properties.kubernetesVersion, properties.distribution, properties.infrastructure, properties.totalNodeCount, properties.totalCoreCount
| where type =~ 'Microsoft.Kubernetes/connectedClusters'
```

# [Azure CLI](#tab/azure-cli)
```azurecli
az graph query -q "Resources | project id, subscriptionId, location, type, properties.agentVersion, properties.kubernetesVersion, properties.distribution, properties.infrastructure, properties.totalNodeCount, properties.totalCoreCount | where type =~ 'Microsoft.Kubernetes/connectedClusters'"
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
Search-AzGraph -Query "Resources | project id, subscriptionId, location, type, properties.agentVersion, properties.kubernetesVersion, properties.distribution, properties.infrastructure, properties.totalNodeCount, properties.totalCoreCount | where type =~ 'Microsoft.Kubernetes/connectedClusters'"
```

# [Portal](#tab/azure-portal)
- Azure portal: [portal.azure.com](https://portal.azure.com/#blade/HubsExtension/ArgQueryBlade/query/Resources%0a%7c%20project%20id%2c%20subscriptionId%2c%20location%2c%20type%2c%20properties.agentVersion%2c%20properties.kubernetesVersion%2c%20properties.distribution%2c%20properties.infrastructure%2c%20properties.totalNodeCount%2c%20properties.totalCoreCount%0a%7c%20where%20type%20%3d%7e%20%27Microsoft.Kubernetes%2fconnectedClusters%27)
- Azure Government portal: [portal.azure.us](https://portal.azure.us/#blade/HubsExtension/ArgQueryBlade/query/Resources%0a%7c%20project%20id%2c%20subscriptionId%2c%20location%2c%20type%2c%20properties.agentVersion%2c%20properties.kubernetesVersion%2c%20properties.distribution%2c%20properties.infrastructure%2c%20properties.totalNodeCount%2c%20properties.totalCoreCount%0a%7c%20where%20type%20%3d%7e%20%27Microsoft.Kubernetes%2fconnectedClusters%27)
- Azure operated by 21Vianet portal: [portal.azure.cn](https://portal.azure.cn/#blade/HubsExtension/ArgQueryBlade/query/Resources%0a%7c%20project%20id%2c%20subscriptionId%2c%20location%2c%20type%2c%20properties.agentVersion%2c%20properties.kubernetesVersion%2c%20properties.distribution%2c%20properties.infrastructure%2c%20properties.totalNodeCount%2c%20properties.totalCoreCount%0a%7c%20where%20type%20%3d%7e%20%27Microsoft.Kubernetes%2fconnectedClusters%27)

---

### List all Azure Arc-enabled Kubernetes clusters with Azure Monitor extension

Returns the connected cluster ID of each Azure Arc-enabled Kubernetes cluster that has the Azure Monitor extension installed.

```kusto
KubernetesConfigurationResources
| where type == 'microsoft.kubernetesconfiguration/extensions'
| where properties.ExtensionType  == 'microsoft.azuremonitor.containers'
| parse id with connectedClusterId '/providers/Microsoft.KubernetesConfiguration/Extensions' *
| project connectedClusterId
```

# [Azure CLI](#tab/azure-cli)
```azurecli
az graph query -q "KubernetesConfigurationResources | where type == 'microsoft.kubernetesconfiguration/extensions' | where properties.ExtensionType == 'microsoft.azuremonitor.containers' | parse id with connectedClusterId '/providers/Microsoft.KubernetesConfiguration/Extensions' * | project connectedClusterId"
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
Search-AzGraph -Query "KubernetesConfigurationResources | where type == 'microsoft.kubernetesconfiguration/extensions' | where properties.ExtensionType == 'microsoft.azuremonitor.containers' | parse id with connectedClusterId '/providers/Microsoft.KubernetesConfiguration/Extensions' * | project connectedClusterId"
```

# [Portal](#tab/azure-portal)
- Azure portal: [portal.azure.com](https://portal.azure.com/#blade/HubsExtension/ArgQueryBlade/query/KubernetesConfigurationResources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2fextensions%27%0a%7c%20where%20properties.ExtensionType%20%20%3d%3d%20%27microsoft.azuremonitor.containers%27%0a%7c%20parse%20id%20with%20connectedClusterId%20%27%2fproviders%2fMicrosoft.KubernetesConfiguration%2fExtensions%27%20*%0a%7c%20project%20connectedClusterId)
- Azure Government portal: [portal.azure.us](https://portal.azure.us/#blade/HubsExtension/ArgQueryBlade/query/KubernetesConfigurationResources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2fextensions%27%0a%7c%20where%20properties.ExtensionType%20%20%3d%3d%20%27microsoft.azuremonitor.containers%27%0a%7c%20parse%20id%20with%20connectedClusterId%20%27%2fproviders%2fMicrosoft.KubernetesConfiguration%2fExtensions%27%20*%0a%7c%20project%20connectedClusterId)
- Microsoft Azure operated by 21Vianet portal: [portal.azure.cn](https://portal.azure.cn/#blade/HubsExtension/ArgQueryBlade/query/KubernetesConfigurationResources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2fextensions%27%0a%7c%20where%20properties.ExtensionType%20%20%3d%3d%20%27microsoft.azuremonitor.containers%27%0a%7c%20parse%20id%20with%20connectedClusterId%20%27%2fproviders%2fMicrosoft.KubernetesConfiguration%2fExtensions%27%20*%0a%7c%20project%20connectedClusterId)

---

### List all Azure Arc-enabled Kubernetes clusters without Azure Monitor extension

Returns the connected cluster ID of each Azure Arc-enabled Kubernetes cluster that is missing the Azure Monitor extension.

```kusto
Resources
| where type =~ 'Microsoft.Kubernetes/connectedClusters' | extend connectedClusterId = tolower(id) | project connectedClusterId
| join kind = leftouter
  (KubernetesConfigurationResources
  | where type == 'microsoft.kubernetesconfiguration/extensions'
  | where properties.ExtensionType  == 'microsoft.azuremonitor.containers'
  | parse tolower(id) with connectedClusterId '/providers/microsoft.kubernetesconfiguration/extensions' *
  | project connectedClusterId
)  on connectedClusterId
| where connectedClusterId1 == ''
| project connectedClusterId
```

# [Azure CLI](#tab/azure-cli)
```azurecli
az graph query -q "Resources | where type =~ 'Microsoft.Kubernetes/connectedClusters' | extend connectedClusterId = tolower(id) | project connectedClusterId | join kind = leftouter (KubernetesConfigurationResources | where type == 'microsoft.kubernetesconfiguration/extensions' | where properties.ExtensionType == 'microsoft.azuremonitor.containers' | parse tolower(id) with connectedClusterId '/providers/microsoft.kubernetesconfiguration/extensions' * | project connectedClusterId ) on connectedClusterId | where connectedClusterId1 == '' | project connectedClusterId"
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
Search-AzGraph -Query "Resources | where type =~ 'Microsoft.Kubernetes/connectedClusters' | extend connectedClusterId = tolower(id) | project connectedClusterId | join kind = leftouter (KubernetesConfigurationResources | where type == 'microsoft.kubernetesconfiguration/extensions' | where properties.ExtensionType == 'microsoft.azuremonitor.containers' | parse tolower(id) with connectedClusterId '/providers/microsoft.kubernetesconfiguration/extensions' * | project connectedClusterId ) on connectedClusterId | where connectedClusterId1 == '' | project connectedClusterId"
```

# [Portal](#tab/azure-portal)
- Azure portal: [portal.azure.com](https://portal.azure.com/#blade/HubsExtension/ArgQueryBlade/query/Resources%0a%7c%20where%20type%20%3d%7e%20%27Microsoft.Kubernetes%2fconnectedClusters%27%20%7c%20extend%20connectedClusterId%20%3d%20tolower%28id%29%20%7c%20project%20connectedClusterId%20%0a%7c%20join%20kind%20%3d%20leftouter%0a%09%28KubernetesConfigurationResources%0a%09%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2fextensions%27%0a%09%7c%20where%20properties.ExtensionType%20%20%3d%3d%20%27microsoft.azuremonitor.containers%27%0a%09%7c%20parse%20tolower%28id%29%20with%20connectedClusterId%20%27%2fproviders%2fmicrosoft.kubernetesconfiguration%2fextensions%27%20*%0a%09%7c%20project%20connectedClusterId%0a%29%20%20on%20connectedClusterId%0a%7c%20where%20connectedClusterId1%20%3d%3d%20%27%27%0a%7c%20project%20connectedClusterId)
- Azure Government portal: [portal.azure.us](https://portal.azure.us/#blade/HubsExtension/ArgQueryBlade/query/Resources%0a%7c%20where%20type%20%3d%7e%20%27Microsoft.Kubernetes%2fconnectedClusters%27%20%7c%20extend%20connectedClusterId%20%3d%20tolower%28id%29%20%7c%20project%20connectedClusterId%20%0a%7c%20join%20kind%20%3d%20leftouter%0a%09%28KubernetesConfigurationResources%0a%09%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2fextensions%27%0a%09%7c%20where%20properties.ExtensionType%20%20%3d%3d%20%27microsoft.azuremonitor.containers%27%0a%09%7c%20parse%20tolower%28id%29%20with%20connectedClusterId%20%27%2fproviders%2fmicrosoft.kubernetesconfiguration%2fextensions%27%20*%0a%09%7c%20project%20connectedClusterId%0a%29%20%20on%20connectedClusterId%0a%7c%20where%20connectedClusterId1%20%3d%3d%20%27%27%0a%7c%20project%20connectedClusterId)
- Azure operated by 21Vianet portal: [portal.azure.cn](https://portal.azure.cn/#blade/HubsExtension/ArgQueryBlade/query/Resources%0a%7c%20where%20type%20%3d%7e%20%27Microsoft.Kubernetes%2fconnectedClusters%27%20%7c%20extend%20connectedClusterId%20%3d%20tolower%28id%29%20%7c%20project%20connectedClusterId%20%0a%7c%20join%20kind%20%3d%20leftouter%0a%09%28KubernetesConfigurationResources%0a%09%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2fextensions%27%0a%09%7c%20where%20properties.ExtensionType%20%20%3d%3d%20%27microsoft.azuremonitor.containers%27%0a%09%7c%20parse%20tolower%28id%29%20with%20connectedClusterId%20%27%2fproviders%2fmicrosoft.kubernetesconfiguration%2fextensions%27%20*%0a%09%7c%20project%20connectedClusterId%0a%29%20%20on%20connectedClusterId%0a%7c%20where%20connectedClusterId1%20%3d%3d%20%27%27%0a%7c%20project%20connectedClusterId)

---

### List all clusters that contain a Flux configuration

Returns the `connectedCluster` and `managedCluster` IDs for clusters that contain at least one `fluxConfiguration`.

```kusto
resources
| where type =~ 'Microsoft.Kubernetes/connectedClusters' or type =~ 'Microsoft.ContainerService/managedClusters' | extend clusterId = tolower(id) | project clusterId
| join
( kubernetesconfigurationresources
| where type == 'microsoft.kubernetesconfiguration/fluxconfigurations'
| parse tolower(id) with clusterId '/providers/microsoft.kubernetesconfiguration/fluxconfigurations' *
| project clusterId
) on clusterId
| project clusterId
```

# [Azure CLI](#tab/azure-cli)
```azurecli
az graph query -q "resources | where type =~ 'Microsoft.Kubernetes/connectedClusters' or type =~ 'Microsoft.ContainerService/managedClusters' | extend clusterId = tolower(id) | project clusterId | join ( kubernetesconfigurationresources | where type == 'microsoft.kubernetesconfiguration/fluxconfigurations' | parse tolower(id) with clusterId '/providers/microsoft.kubernetesconfiguration/fluxconfigurations' * | project clusterId ) on clusterId | project clusterId"
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
Search-AzGraph -Query "resources | where type =~ 'Microsoft.Kubernetes/connectedClusters' or type =~ 'Microsoft.ContainerService/managedClusters' | extend clusterId = tolower(id) | project clusterId | join ( kubernetesconfigurationresources | where type == 'microsoft.kubernetesconfiguration/fluxconfigurations' | parse tolower(id) with clusterId '/providers/microsoft.kubernetesconfiguration/fluxconfigurations' * | project clusterId ) on clusterId | project clusterId"
```

# [Portal](#tab/azure-portal)
- Azure portal: [portal.azure.com](https://portal.azure.com/#blade/HubsExtension/ArgQueryBlade/query/resources%0a%7c%20where%20type%20%3d%7e%20%27Microsoft.Kubernetes%2fconnectedClusters%27%20or%20type%20%3d%7e%20%27Microsoft.ContainerService%2fmanagedClusters%27%20%7c%20extend%20clusterId%20%3d%20tolower%28id%29%20%7c%20project%20clusterId%0a%7c%20join%0a%28%20kubernetesconfigurationresources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2ffluxconfigurations%27%0a%7c%20parse%20tolower%28id%29%20with%20clusterId%20%27%2fproviders%2fmicrosoft.kubernetesconfiguration%2ffluxconfigurations%27%20*%0a%7c%20project%20clusterId%0a%29%20on%20clusterId%0a%7c%20project%20clusterId)
- Azure Government portal: [portal.azure.us](https://portal.azure.us/#blade/HubsExtension/ArgQueryBlade/query/resources%0a%7c%20where%20type%20%3d%7e%20%27Microsoft.Kubernetes%2fconnectedClusters%27%20or%20type%20%3d%7e%20%27Microsoft.ContainerService%2fmanagedClusters%27%20%7c%20extend%20clusterId%20%3d%20tolower%28id%29%20%7c%20project%20clusterId%0a%7c%20join%0a%28%20kubernetesconfigurationresources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2ffluxconfigurations%27%0a%7c%20parse%20tolower%28id%29%20with%20clusterId%20%27%2fproviders%2fmicrosoft.kubernetesconfiguration%2ffluxconfigurations%27%20*%0a%7c%20project%20clusterId%0a%29%20on%20clusterId%0a%7c%20project%20clusterId)
- Azure operated by 21Vianet portal: [portal.azure.cn](https://portal.azure.cn/#blade/HubsExtension/ArgQueryBlade/query/resources%0a%7c%20where%20type%20%3d%7e%20%27Microsoft.Kubernetes%2fconnectedClusters%27%20or%20type%20%3d%7e%20%27Microsoft.ContainerService%2fmanagedClusters%27%20%7c%20extend%20clusterId%20%3d%20tolower%28id%29%20%7c%20project%20clusterId%0a%7c%20join%0a%28%20kubernetesconfigurationresources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2ffluxconfigurations%27%0a%7c%20parse%20tolower%28id%29%20with%20clusterId%20%27%2fproviders%2fmicrosoft.kubernetesconfiguration%2ffluxconfigurations%27%20*%0a%7c%20project%20clusterId%0a%29%20on%20clusterId%0a%7c%20project%20clusterId)

---

### List all Flux configurations in a noncompliant state

Returns the `fluxConfiguration` IDs of configurations that are failing to sync resources on the cluster.

```kusto
kubernetesconfigurationresources
| where type == 'microsoft.kubernetesconfiguration/fluxconfigurations'
| where properties.complianceState == 'Non-Compliant'
| project id
```

# [Azure CLI](#tab/azure-cli)
```azurecli
az graph query -q "kubernetesconfigurationresources | where type == 'microsoft.kubernetesconfiguration/fluxconfigurations' | where properties.complianceState == 'Non-Compliant' | project id"
```

# [Azure PowerShell](#tab/azure-powershell)
```azurepowershell
Search-AzGraph -Query "kubernetesconfigurationresources | where type == 'microsoft.kubernetesconfiguration/fluxconfigurations' | where properties.complianceState == 'Non-Compliant' | project id"
```

# [Portal](#tab/azure-portal)
- Azure portal: [portal.azure.com](https://portal.azure.com/#blade/HubsExtension/ArgQueryBlade/query/kubernetesconfigurationresources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2ffluxconfigurations%27%0a%7c%20where%20properties.complianceState%20%3d%3d%20%27Non-Compliant%27%0a%7c%20project%20id)
- Azure Government portal: [portal.azure.us](https://portal.azure.us/#blade/HubsExtension/ArgQueryBlade/query/kubernetesconfigurationresources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2ffluxconfigurations%27%0a%7c%20where%20properties.complianceState%20%3d%3d%20%27Non-Compliant%27%0a%7c%20project%20id)
- Azure operated by 21Vianet portal: [portal.azure.cn](https://portal.azure.cn/#blade/HubsExtension/ArgQueryBlade/query/kubernetesconfigurationresources%0a%7c%20where%20type%20%3d%3d%20%27microsoft.kubernetesconfiguration%2ffluxconfigurations%27%0a%7c%20where%20properties.complianceState%20%3d%3d%20%27Non-Compliant%27%0a%7c%20project%20id)

---