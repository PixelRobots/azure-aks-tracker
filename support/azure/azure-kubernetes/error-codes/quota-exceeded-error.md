---
layout: Conceptual
title: Troubleshoot QuotaExceeded error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/quota-exceeded-error
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
description: Learn how to troubleshoot the QuotaExceeded error during AKS cluster upgrades, free required cores, and complete your upgrade successfully. Start now.
ms.date: 2026-10-08T00:00:00.0000000Z
ms.reviewer: chiragpa, v-leedennis, andbar
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: 98e939a5-1683-173d-2e59-30e869905a14
document_version_independent_id: 98e939a5-1683-173d-2e59-30e869905a14
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/quota-exceeded-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/quota-exceeded-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/quota-exceeded-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 3b211b9a-1de1-8ec8-1a5b-44b85d3cc9d2
---

# Troubleshoot QuotaExceeded error code - Azure | Microsoft Learn

## Summary

This article explains how to identify and resolve the `QuotaExceeded` error that can occur when you upgrade an Azure Kubernetes Service (AKS) cluster.

During an AKS upgrade, the process might temporarily require extra compute resources. If your subscription doesn't have enough quota for these resources, the upgrade fails and returns a `QuotaExceeded` error.

## Prerequisites

This article requires Azure CLI version 2.0.65 or later. To find the version number, run `az --version`. To install or upgrade Azure CLI, see [How to install the Azure CLI](/en-us/cli/azure/install-azure-cli).

For more information about the AKS upgrade process, see [Upgrade an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/upgrade-cluster).

## Symptoms

An AKS cluster or node pool upgrade fails, and you receive a `QuotaExceeded` error message similar to the following example.

> 
> Create or update VMSS &lt;AKS-VM/VMSS-resource-ID&gt; failed. Operation couldn't be completed because it results in exceeding approved &lt;SKU-family) Cores quota. Additional details - Deployment Model: Resource Manager, Location: `<region>`, Current Limit: A, Current Usage: B, Additional Required: C, (Minimum) New Limit Required: D.

The error message indicates that the AKS operation requires extra compute resources, but the subscription doesn't have enough available quota for the requested resources.

## Cause

During a node pool upgrade, AKS can temporarily create extra surge nodes to keep cluster capacity while upgrading existing nodes. The number of surge nodes depends on the [`maxSurge`](/en-us/azure/aks/upgrade-aks-node-pools-rolling#overview-of-rolling-upgrade-behavior) setting. These extra nodes need compute resources in the same subscription and region as the node pool.

Azure enforces vCPU quotas at the following two levels for each subscription and region:

- **Total Regional vCPUs** - The total number of virtual CPUs (vCPUs) that you can deploy across all virtual machine (VM) families in a region.
- **VM-family vCPUs** - The number of vCPUs you can deploy for a specific VM family in a region.

If the AKS operation needs more vCPUs than are available under either applicable quota, the operation can fail with a `QuotaExceeded` error.

For more information about surge nodes and the AKS upgrade process, see [Upgrade an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/upgrade-cluster).

## Solution

### Step 1: Identify the exceeded quota

Review the `QuotaExceeded` error message to identify the quota that prevented the operation from completing.

From the error message, identify the following information:

- **Location** - The Azure region where the quota was exceeded.
- **VM family** - The VM SKU family associated with the exceeded quota.
- **Current Limit** - The current quota limit for the identified VM family and region.
- **Current Usage** - The amount of the quota currently in use.
- **Additional Required** - The extra quota needed to complete the operation.
- **Minimum New Limit Required** - The minimum quota limit required for the operation to proceed.

Use this information to check the corresponding quota usage in the next step.

### Step 2: Check your current quota usage

Check the current compute quota usage in the region where the affected AKS node pool is deployed by running the following command in Azure CLI.

```azurecli
az vm list-usage --location <region> --output table
```

Replace `<region>` with the Azure region where the AKS cluster is deployed.

Review the output for the following information:

- **Total Regional vCPUs**.
- The **VM-family vCPU quota** that corresponds to the VM size used by the affected node pool.

In the [Azure portal](https://portal.azure.com), go to **Subscriptions**, select the subscription associated with the AKS cluster, and then select **Usage + quotas** under **Settings**. Filter the results by the region and VM family identified in the error message.

For more information about Azure vCPU quotas and how to check quota usage, see [Check vCPU quotas](/en-us/azure/virtual-machines/quotas).

Note

AKS uses surge nodes during rolling upgrades to maintain cluster capacity while existing nodes are being upgraded. The `maxSurge` value determines how many extra nodes can be created during the upgrade. A higher value can increase the temporary compute resources required to complete the upgrade.

If increasing the quota isn't immediately possible, consider whether a lower `maxSurge` value is appropriate for your workload and upgrade strategy.

Reducing `maxSurge` can reduce the number of extra nodes required at the same time, but it can also increase the time required to complete the upgrade. Consider your workload capacity and availability requirements before changing this setting.

For more information, see [How to customize node surge](/en-us/azure/aks/upgrade-aks-node-pools-rolling#configure-rolling-upgrade-settings).

### Step 3: Request a quota increase

If the required quota isn't available, request an increase for the applicable quota.

Depending on which quota is exhausted, you might have to request an increase for the following:

- The **Total Regional vCPUs** quota.
- The applicable **VM-family vCPU quota**.
- Both quotas, if neither has sufficient available quota.

To raise the limit or quota for your subscription, go to the [Azure portal](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/newsupportrequest) and file a **Service and subscription limits (quotas)** support ticket. In this case, you need to submit a support ticket to increase the quota for compute cores. The received error message should also contain a link that you can use to perform the quota increase.

For information about requesting a quota increase in the Azure portal, see [Quickstart: Increase quota in the Azure portal](/en-us/azure/quotas/quickstart-increase-quota-portal).

For information about VM-family vCPU quota increases, see [Per-VM quota requests](/en-us/azure/quotas/per-vm-quota-requests).

### Step 4: Re-initiate the upgrade

After the quota increase, you can re-initiate the upgrade operation by reconciling the AKS cluster or the AKS node pool, depending on whether the upgrade was initiated at the cluster or node pool level.

To reconcile the AKS cluster, use Azure CLI to run the following command.

```azurecli
az aks update -g MyResourceGroup -n MyManagedCluster
```

To reconcile the AKS node pool, use Azure CLI to run the following command.

```azurecli
az aks nodepool update -g MyResourceGroup -n nodepool1 --cluster-name MyManagedCluster
```

## References

- [Upgrade options and recommendations for AKS](/en-us/azure/aks/upgrade-cluster)
- [Azure subscription and service limits, quotas, and constraints](/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits)
- [Request a quota increase in the Azure portal](/en-us/azure/quotas/quickstart-increase-quota-portal)