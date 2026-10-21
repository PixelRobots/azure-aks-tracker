---
layout: Conceptual
title: Monitor Kubernetes audit events in AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-audit-events
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
ms.service: azure-kubernetes-service-hybrid
description: Learn how to create a diagnostic setting to access Kubernetes audit logs.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2024-02-26T00:00:00.0000000Z
ms.reviewer: guanghu
ms.custom: hyperconverged
locale: en-us
document_id: cd107433-297e-af87-85ec-0ef586813d75
document_version_independent_id: 1aef6ef1-5b07-2fc0-2c47-0b279c152fd9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-audit-events.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-audit-events
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-audit-events.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 6dc0f9b9-62d6-b721-dcad-65533d23e659
---

# Monitor Kubernetes audit events in AKS Hybrid and Edge | Microsoft Learn

> 
> Applies to: AKS on Azure Local

You can access Kubernetes audit logs in Kubernetes control plane logs. Control plane logs for AKS clusters are implemented as [resource logs](/en-us/azure/azure-monitor/essentials/resource-logs) in Azure Monitor. Resource logs aren't collected and stored until you create a diagnostic setting to route them to one or more locations. You typically send them to a Log Analytics workspace, which is where most of the data for Container Insights is stored.

## Create a diagnostic setting

Before you create the diagnostic setting, install the **Arc K8S** extension, which enables log collection from the AKS cluster.

Install the Arc K8S extension by running the following command:

```azurecli
az k8s-extension create -g <resouerce-group-name> -c <cluster-name> --cluster-type connectedClusters --extension-type Microsoft.AKSArc.AzureMonitor --name "aksarc-azuremonitor" --auto-upgrade true
```

After the extension installs successfully, follow the instructions in [Diagnostic settings in Azure Monitor](/en-us/azure/azure-monitor/essentials/diagnostic-settings#resource-logs) to create a diagnostic setting using the Azure portal, Azure CLI, or PowerShell. During this process, you can specify which categories of logs to collect. The categories for AKS are listed in the [Monitoring data reference](/en-us/azure/azure-monitor/logs/manage-logs-tables).

The example command is as follows:

```azurecli
az monitor diagnostic-settings create –-name <Diagnostics_Setting_Name> --resource <Cluster_Resource_ID> --logs "[{category:kube-audit,enabled:true},{category:kube-audit-admin,enabled:true},{category:kube-apiserver,enabled:true},{category:kube-controller-manager,enabled:true},{category:kube-scheduler,enabled:true},{category:cluster-autoscaler,enabled:true},{category:cloud-controller-manager,enabled:true},{category:guard,enabled:true},{category:csi-aksarcdisk-controller,enabled:true},{category:csi-aksarcsmb-controller,enabled:true},{category:csi-aksarcnfs-controller,enabled:true}]" --workspace <LA_Workspace_resource_ID>
```

[![Screenshot of portal blade showing diagnostic settings.](../../media/kubernetes-monitor-audit-events/diagnostic-settings.png)](../../media/kubernetes-monitor-audit-events/diagnostic-settings.png#lightbox)

AKS supports either [Azure diagnostics mode](/en-us/azure/azure-monitor/essentials/resource-logs#azure-diagnostics-mode) or [resource-specific mode](/en-us/azure/azure-monitor/essentials/resource-logs#resource-specific) for resource logs. The mode specifies the tables in the Log Analytics workspace to which the data is sent. Azure diagnostics mode sends all data to the [AzureDiagnostics table](/en-us/azure/azure-monitor/reference/tables/azurediagnostics), while resource-specific mode sends data to [ArcK8SAudit](/en-us/azure/azure-monitor/reference/tables/arck8saudit), [ArcK8SAuditAdmin](/en-us/azure/azure-monitor/reference/tables/arck8sauditadmin), and [ArcK8SControlPlane](/en-us/azure/azure-monitor/reference/tables/arck8scontrolplane), as shown in the log category table in the next section.

After you save the settings, it can take up to an hour to see the events in the Log Analytics workspace or other supported destination. You can write a KQL query to extract the insights based on the log categories you enabled.

## Delete and disable the diagnostics setting

You can delete the diagnostics setting using the Azure portal, PowerShell, or Azure CLI:

```azurecli
az monitor diagnostic-settings delete -name <diagnostics-setting-name> --resource <resource-name> -g <resource-group-name>
```

After you successfully delete the setting, you can then delete the extension using Azure CLI:

```azurecli
az k8s-extension delete -g <resouerce-group-name> -c <cluster-name> --cluster-type connectedClusters --name "hybridaks-observability"
```