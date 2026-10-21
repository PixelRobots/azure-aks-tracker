---
layout: Conceptual
title: Abort an AKS long-running operation - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/manage-abort-operations
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
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to abort a long-running Azure resource operation on an Azure Kubernetes Service (AKS) managed cluster or node pool.
ms.topic: how-to
ms.date: 2026-08-06T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-nodes
ms.custom: devx-track-azurecli
locale: en-us
document_id: 000cbacb-da8b-cda6-432e-e36bbd61b363
document_version_independent_id: 9244fda7-d83a-6f9d-3c1c-87e261abd4f6
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/manage-abort-operations.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/manage-abort-operations
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/manage-abort-operations.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 1896d7c3-9708-4ff7-64aa-fe79ffb2b4ea
---

# Abort an AKS long-running operation - Azure Kubernetes Service | Microsoft Learn

Azure resource operations on an AKS managed cluster or node pool, such as create, upgrade, and scale operations, can take longer than expected. You can inspect the progress of these operations and abort the latest running operation to regain control of the managed cluster or node pool. The commands in this article don't inspect or terminate Kubernetes workload deployments or processes running inside pods.

Use the [`az aks operation show-latest`](/en-us/cli/azure/aks/operation#az-aks-operation-show-latest) command to show the status of the latest operation on a managed cluster:

```azurecli
az aks operation show-latest \
    --resource-group myResourceGroup \
    --name myCluster
```

The following output is an example:

```bash
{
  "endTime": null,
  "error": null,
  "id": "/subscriptions/<subscription-id>/resourcegroups/myResourceGroup/providers/Microsoft.ContainerService/managedClusters/contoso/operations/<operation-id>",
  "name": "<operation-id>",
  "operations": null,
  "percentComplete": 1.0,
  "resourceGroup": "myResourceGroup",
  "resourceId": null,
  "startTime": "2024-06-12T18:16:21+00:00",
  "status": "InProgress"
}
```

The output includes the following operation details:

- `percentComplete`: The reported completion percentage for the operation.
- `startTime`: The time when the operation started.
- `status`: The current operation status, such as `InProgress`.

Use the [`az aks operation show`](/en-us/cli/azure/aks/operation#az-aks-operation-show) command and the operation ID from the preceding output to show a specific operation:

```azurecli
az aks operation show \
    --resource-group myResourceGroup \
    --name myCluster \
    --operation-id "<operation-id>"
```

Allow operations to complete gracefully when possible. You can abort the latest operation before it reaches a terminal state if the operation is stuck or failing, or if you started it in error. The ability to abort the latest running operation is generally available through the [Azure REST API](/en-us/rest/api/azure/) and the [Azure CLI](/en-us/cli/azure/).

## Before you begin

- Azure CLI version 2.85.0 or later. Run `az --version` to find the version, and run `az upgrade` to upgrade the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The `aks-preview` extension, which provides the `az aks operation` commands. The extension installs automatically the first time you run an `az aks operation` command. To install it manually, run `az extension add --name aks-preview`. If the extension is already installed, update it with `az extension update --name aks-preview`.

## Abort a long-running operation on AKS

# [Azure CLI](#tab/azure-cli)
Use [`az aks nodepool operation-abort`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-operation-abort) to cancel the latest running operation on a node pool. Use [`az aks operation-abort`](/en-us/cli/azure/aks#az-aks-operation-abort) to cancel the latest running operation on a managed cluster.

The following example cancels an operation on a node pool in a specified cluster:

```azurecli
az aks nodepool operation-abort \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myNodePool
```

The following example cancels an operation on a specified cluster:

```azurecli
az aks operation-abort \
    --name myAKSCluster \
    --resource-group myResourceGroup
```

# [Azure REST API](#tab/azure-rest)
Use the Azure REST API to cancel the latest running operation on a node pool or managed cluster.

The following example cancels the latest running operation on a specified node pool:

```rest
POST https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ContainerService/managedclusters/{resourceName}/agentPools/{agentPoolName}/abort?api-version=2025-08-01
```

For more information, see [Agent Pools - Abort Latest Operation](/en-us/rest/api/aks/agent-pools/abort-latest-operation?view=rest-aks-2025-08-01&amp;preserve-view=true).

The following example cancels the latest running operation on a specified managed cluster:

```rest
POST https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ContainerService/managedclusters/{resourceName}/abort?api-version=2025-08-01
```

For more information, see [Managed Clusters - Abort Latest Operation](/en-us/rest/api/aks/managed-clusters/abort-latest-operation?view=rest-aks-2025-08-01&amp;preserve-view=true).

A successful cancel request returns `202 Accepted` when cancellation continues asynchronously or `204 No Content` when no response body is needed. If the original operation finishes before AKS can cancel it, the request returns `409 Conflict`.

---

After AKS accepts the cancel request, the operation progresses through the following statuses:

| Operation status | Meaning |
| --- | --- |
| `Canceling` | AKS is canceling the operation. |
| `Canceled` | AKS finished canceling the operation. |

Use the following command to check the latest managed cluster operation:

```azurecli
az aks operation show-latest \
    --resource-group myResourceGroup \
    --name myAKSCluster
```

To check the latest operation on a node pool, include the `--nodepool-name` parameter:

```azurecli
az aks operation show-latest \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --nodepool-name myNodePool
```

Canceling an operation doesn't by itself roll back changes that AKS applied before cancellation.