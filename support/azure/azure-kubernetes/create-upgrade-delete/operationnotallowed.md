---
layout: Conceptual
title: Cluster pending operation (OperationNotAllowed) errors - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/operationnotallowed
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: axelgMS
ms.author: axelg
ms.topic: troubleshooting
description: Learn to resolve OperationNotAllowed errors that occur when you try to start, upgrade, or scale an Azure Kubernetes Service (AKS) cluster.
ms.date: 2024-02-23T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: chiragpa, jpalma, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 6208f517-6437-119c-790d-e3c30486ccfe
document_version_independent_id: 6208f517-6437-119c-790d-e3c30486ccfe
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/operationnotallowed.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/operationnotallowed
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/operationnotallowed.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 152b10a4-84cf-4dfe-a086-b431c1287bc1
---

# Cluster pending operation (OperationNotAllowed) errors - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot OperationNotAllowed errors that occur when you try to start, upgrade, or scale a Microsoft Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli)

## Symptoms

You experience multiple symptoms that include one of the following error messages:

> 
> Operation is not allowed: Another operation (&lt;operation-name&gt;) is in progress, please wait for it to finish before starting a new operation. See https://aka.ms/aks-pending-operation for more details

Or, if it's an operation on an agent pool:

> 
> Operation is not allowed: Another agentpool operation (&lt;operation-name&gt;) is in progress, please wait for it to finish before starting a new operation. See https://aka.ms/aks-pending-operation for more details

Or:

> 
> Managed Cluster operation is not allowed: Another operation (&lt;operation-name&gt;) is in progress on agent pool (&lt;agent-pool-name&gt;), please wait for it to finish before starting a new operation. See https://aka.ms/aks-pending-operation for more details

## Cause

Some operations take time to run. Those operations block other operations if they aren't finished.

## Solution 1: Wait until the operation finishes

In the following example, if you start a cluster from one client while the cluster is being updated from another client, the "OperationNotAllowed" error occurs.

```azurecli
az aks start  -n <myAKSCluster> -g <myResourceGroup>

(OperationNotAllowed) managed cluster is in Provisioning State(Updating) and Power State(Running), starting cannot be performed The previous operation started at '2024-02-21T13:33:55Z' and elapsed time is: '00:00:00' (RFC3339 format)
Code: OperationNotAllowed
Message: managed cluster is in Provisioning State(Starting) and Power State(Running), starting cannot be performed The previous operation started at '2024-02-21T13:33:55Z' and elapsed time is: '00:00:00' (RFC3339 format)
```

To resolve such issue, you can wait until the blocking operation finishes, or try aborting the long running operation by using the [az aks operation-abort](/en-us/azure/aks/manage-abort-operations) command.

## Solution 2: Ensure you don't perform two similar operations in a row

If you execute an operation on a cluster that's already in the desired state, the "OperationNotAllowed" error occurs.

For example, if a cluster is already stopped, executing another stop operation triggers this error:

```azurecli
az aks stop -n <myAKSCluster> -g <myResourceGroup>

(OperationNotAllowed) managed cluster is not currently running, stopping cannot be performed; The stop operation started at '2024-02-13T15:01:15Z' and elapsed time is: '7 days and 01:16:37' (RFC3339 format)
Code: OperationNotAllowed
Message: managed cluster is not currently running, stopping cannot be performed; The stop operation started at '2024-02-13T15:01:15Z' and elapsed time is: '7 days and 01:16:37' (RFC3339 format)
```

To resolve such issue, start the cluster before attempting to stop it again.

## Solution 3: Get the current cluster status before you try an operation

You can also determine the current status of the cluster before you try an operation. To help diagnose the issue, run the following [az aks show](/en-us/cli/azure/aks#az-aks-show) command to retrieve detailed status about the cluster.

```azurecli
az aks show --resource-group <myResourceGroup> --name <myAKSCluster> --output table
```

Then, use the following table to take the appropriate action based on the command results. (See the `ProvisioningState` column in the `az aks show` command output table.)

| Command result | Action |
| --- | --- |
| Cluster is actively updating | Wait until the operation finishes. |
| Cluster update failed | Locate the reason for the failure in the activity logs. |
| Cluster update succeeded | Retry the start, scale, or other previously failed operation. |

## Solution 4: Retry the operation

There are scenarios where an operation fails because of a transient issue, and is left with an inconsistent state.

In the following example, a deletion was issued on the node pool &lt;agentpool&gt; but that deletion isn't completed yet. Once a deletion started, no other operation can be made on the resource. That's why the scale operation fails with the "OperationNotAllowed" error.

```output
{
"code": "OperationNotAllowed",
"details": null,
"message": "Unable to perform 'Scaling' operation on 'agentpool' since deletion was issued on 'agentpool'. The only allowed operation is deletion once deletion has started. The delete operation started at '2024-01-09T04:29:12Z' and elapsed time is: '00:30:28' (RFC3339 format)",
"subcode": ""
}
```

To resolve such issue, wait for the deletion to finish. If it's not finished after a few hours, retry that deletion later.