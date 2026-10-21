---
layout: Conceptual
title: Troubleshoot Azure Kubernetes Service cost analysis add-on issues - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/aks-cost-analysis-add-on-issues
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
description: Troubleshoot AKS cost analysis add-on errors during cluster creation or updates, and follow fixes to restore functionality quickly. Get started now.
ms.date: 2026-09-25T00:00:00.0000000Z
ms.reviewer: pram, chiragpa, joharder, cssakscic, dafell, v-leedennis, v-weizhu, addobres, kaysieyu
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons, references_regions, innovation-engine
ai-usage: ai-assisted
locale: en-us
document_id: cf33148a-6d18-babc-62f8-0feb1ec209f7
document_version_independent_id: cf33148a-6d18-babc-62f8-0feb1ec209f7
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/aks-cost-analysis-add-on-issues.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/aks-cost-analysis-add-on-issues
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/aks-cost-analysis-add-on-issues.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f20cedfe-1961-eebd-0225-93a5a5e5c8ea
---

# Troubleshoot Azure Kubernetes Service cost analysis add-on issues - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot problems that you might experience when you enable the Azure Kubernetes Service (AKS) cost analysis add-on during cluster creation or a cluster update.

## Prerequisites

Ensure you have [Azure CLI](/en-us/cli/azure/install-azure-cli) installed.

Define environment variables for resource group and cluster name:

```
export RESOURCE_GROUP="<your-resource-group>" 
export AKS_CLUSTER="<your-aks-cluster>"
```

## Symptoms

After you create or update an AKS cluster, you receive an error message. The following table lists possible error codes and their causes.

| Error code | Cause |
| --- | --- |
| `InvalidDiskCSISettingForCostAnalysis` | Cause 1: Azure Disk CSI driver is disabled |
| `InvalidManagedIdentitySettingForCostAnalysis` | Cause 2: Managed identity is disabled |
| `CostAnalysisNotEnabledInRegion` | Cause 3: The add-on is unavailable in your region |
| `InvalidManagedClusterSKUForFeature` | Cause 4: The add-on is unavailable on the free pricing tier |
| Pod `OOMKilled` | Cause 5: The cost-analysis-agent pod gets the OOMKilled error |
| Pod `Pending` | Cause 6:The cost-analysis-agent pod is stuck in the Pending state |
| Pod `Running` but not Ready | Cause 7:The cost-analysis-agent pod is running but not all containers are ready |

## Cause 1: Azure Disk CSI driver is disabled

You can't enable the Cost Analysis add-on on a cluster in which the [Azure Disk Container Storage Interface (CSI) driver](/en-us/azure/aks/azure-disk-csi) is disabled.

### Solution: Update the cluster to enable the Azure Disk CSI driver

Run the [az aks update](/en-us/cli/azure/aks#az-aks-update) command, and specify the `--enable-disk-driver` parameter. This parameter enables the Azure Disk CSI driver in AKS.

First, define the environment variables for your resource group and AKS cluster (See Prerequisites).

Use Azure CLI to run the following command.

```azurecli
az aks update --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --enable-disk-driver
```

For more information, see [CSI drivers on AKS](/en-us/azure/aks/csi-storage-drivers).

## Cause 2: Managed identity is disabled

You can enable the cost analysis add-on only on a cluster that has a system-assigned or user-assigned managed identity.

### Solution: Update the cluster to enable managed identity

Run the [az aks update](/en-us/cli/azure/aks#az-aks-update) command, and specify the `--enable-managed-identity` parameter.

Use Azure CLI to run the following command.

```azurecli
az aks update --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --enable-managed-identity
```

For more information, see [Use a managed identity in AKS](/en-us/azure/aks/use-managed-identity).

Important

AKS supports both managed identities (system-assigned or user-assigned) and [Microsoft Entra Workload ID](/en-us/azure/aks/workload-identity-overview?tabs=dotnet). Microsoft recommends Microsoft Entra Workload ID for Kubernetes workload authentication

[Microsoft Entra pod-managed identity (AAD Pod Identity)](/en-us/azure/aks/use-azure-ad-pod-identity?tabs=azurecni) is deprecated, and the open-source project has been archived. Microsoft recommends migrating workloads to Microsoft Entra Workload ID.

## Cause 3: The add-on is unavailable in your region

The cost analysis add-on isn't currently enabled in your region.

Note

The AKS Cost Analysis add-on is currently unavailable in the following regions:

- `usnateast`
- `usnatwest`
- `usseceast`
- `ussecwest`

## Cause 4: The add-on is unavailable on the free pricing tier

You can't enable the cost analysis add-on on AKS clusters that are on the free pricing tier.

### Solution: Update the cluster to use the Standard or Premium pricing tier

Upgrade the AKS cluster to the Standard or Premium pricing tier. To do this, run the following [az aks update](/en-us/cli/azure/aks#az-aks-update) command that specifies the `--tier` parameter. Set the `--tier` parameter to either `standard` or `premium` (the following example sets it to `standard`).

Use Azure CLI to run the following command.

```azurecli
az aks update --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --tier standard
```

For more information, see [Free and Standard pricing tiers for AKS cluster management](/en-us/azure/aks/free-standard-pricing-tiers).

## Cause 5: The cost-analysis-agent pod gets the OOMKilled error

The current memory limit for the `cost-analysis-agent` pod is set to 4 GB.

The pod's usage depends on the number of deployed containers, which can be roughly 200 MB plus 0.5 MB per container. The current memory limit supports approximately 7000 containers per cluster.

When the pod's usage exceeds the allocated 4 GB limit, large clusters may experience the `OOMKilled` error.

### Solution: Disable the add-on

Currently, customizing or manually increasing memory limits for the add-on isn't supported. To resolve this issue, disable the add-on.

## Cause 6: The cost-analysis-agent pod is stuck in the Pending state

If the pod is stuck in the Pending state with the FailedScheduling error, the nodes in the cluster have exhausted memory capacity.

### Solution: Ensure there's sufficient allocatable memory

The current memory request of the `cost-analysis-agent` pod is set to 500 MB. Ensure that there's sufficient allocatable memory for the pod to be scheduled

## Cause 7: The cost-analysis-agent pod is running but not all containers are ready

The `cost-analysis-agent` pod is scheduled and shows a `Running` status, but never becomes fully ready (for example, `2/3`). One container repeatedly restarts and fails its readiness or liveness probes, while the remaining containers stay healthy. `kubectl describe pod` shows a termination reason of `Error` with a nonzero exit code. If the termination reason is `OOMKilled`, see Cause 5: The cost-analysis-agent pod gets the OOMKilled error. 

### Solution: Collect logs from the previous container instance

Because the container restarts continuously, current logs often show only a fresh startup sequence and might not contain the original failure. Retrieve logs from the terminated container instance.

Use a command-line interface (CLI) tool to run the following command. 

```bash
kubectl logs <cost-analysis-pod-name> \
-n kube-system \
-c <container-name> \
--previous
```

 Review the logs for errors related to startup, health probes, authentication, or communication with Azure services.