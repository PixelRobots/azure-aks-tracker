---
layout: Conceptual
title: Manage model deployments with AI Manager (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-manager/manage-deployments
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
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Check a model deployment's status, change its scaling settings, or delete the deployment.
ai-usage: ai-assisted
author: asabbour
ms.author: asabbour
ms.topic: how-to
ms.date: 2026-10-13T00:00:00.0000000Z
ms.custom: devx-track-azurecli
locale: en-us
document_id: 1b26b134-63b2-603b-3106-5878cdd8f1c9
document_version_independent_id: d3f59ae8-d188-8efd-5b76-2bd979951da8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-manager/manage-deployments.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/ai-manager/manage-deployments
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-manager/manage-deployments.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 1a6024d2-dc7f-5447-516d-5958f04c49ae
---

# Manage model deployments with AI Manager (preview) - Azure Kubernetes Service | Microsoft Learn

Use the Azure CLI to inspect a model deployment, update its replica settings, or delete that deployment without deleting its namespace or AI Manager.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Before you begin

- An AI Manager with a namespace and model deployment.
- Azure CLI with access to the AI Manager CLI extension for the public preview.
- The **Azure AIManager Contributor** role at the model deployment, namespace, or AI Manager scope. To list deployments, assign the role at the namespace or a parent scope. At deployment scope, use `show` with the deployment name.

Set variables for your existing resources:

```bash
export RESOURCE_GROUP="<resource-group>"
export MANAGER_NAME="<ai-manager-name>"
export NAMESPACE_NAME="<namespace-name>"
export DEPLOYMENT_NAME="<deployment-name>"
```

## Check a model deployment

1. List the model deployments in a namespace. The table shows each deployment's provisioning state, replica counts as current/desired, model ID, and endpoint. This command requires the role at the namespace scope or a parent scope.

    ```azurecli
    az aimanager namespace modeldeployment list \
      --resource-group "$RESOURCE_GROUP" \
      --aimanager "$MANAGER_NAME" \
      --namespace "$NAMESPACE_NAME" \
      --output table
    ```
2. Show one model deployment, including its endpoint and runtime status, by using its name. This command also works when the role is assigned at the deployment scope.

    ```azurecli
    az aimanager namespace modeldeployment show \
      --resource-group "$RESOURCE_GROUP" \
      --aimanager "$MANAGER_NAME" \
      --namespace "$NAMESPACE_NAME" \
      --name "$DEPLOYMENT_NAME" \
      --output json
    ```

Wait until `provisioningState` is `Succeeded`. If the state is `Failed` or `Canceled`, stop checking. Inspect the full resource from the show command before you retry. For the full list of states, see [Provisioning states](reference#provisioning-states). For the meanings of runtime status fields, see the [AI Manager resource reference](reference).

## Change scaling settings

Use the variables that you set in Before you begin.

The [`az aimanager namespace modeldeployment update`](/en-us/cli/azure/aimanager/namespace/modeldeployment#az-aimanager-namespace-modeldeployment-update) command supports either a fixed replica count or an autoscale range. It also exposes a performance mode option.

| Option | Purpose | Notes |
| --- | --- | --- |
| `--replicas` | Sets a fixed replica count. | Don't combine with `--min-replicas` or `--max-replicas`. |
| `--min-replicas` | Sets the minimum replica count for autoscaling. | Provide together with `--max-replicas`. |
| `--max-replicas` | Sets the maximum replica count for autoscaling. | Provide together with `--min-replicas`. |
| `--performance-mode` | Sets the performance mode: `Balanced`, `Latency`, or `Throughput`. | For the meaning of each mode, see the [AI Manager resource reference](reference). |

The update command changes scaling and performance mode only. To use a different catalog model or VM size, create a new model deployment.

To set a fixed replica count, run:

```azurecli
az aimanager namespace modeldeployment update \
  --resource-group "$RESOURCE_GROUP" \
  --aimanager "$MANAGER_NAME" \
  --namespace "$NAMESPACE_NAME" \
  --name "$DEPLOYMENT_NAME" \
  --replicas 2
```

To set an autoscale range, provide both its minimum and maximum:

```azurecli
az aimanager namespace modeldeployment update \
  --resource-group "$RESOURCE_GROUP" \
  --aimanager "$MANAGER_NAME" \
  --namespace "$NAMESPACE_NAME" \
  --name "$DEPLOYMENT_NAME" \
  --min-replicas 1 \
  --max-replicas 3
```

After the update completes, run `az aimanager namespace modeldeployment show` again. For manual scaling, `desiredReplicas` reflects the replica count that you requested; for autoscaling, it reflects the autoscaler’s current target. The `currentReplicas` field reports the number of ready replicas. For a fixed replica count, confirm that `desiredReplicas` matches the requested count and that `currentReplicas` matches `desiredReplicas`. For autoscaling, check that the configured minimum and maximum replica counts match the requested range.

## Delete a model deployment

Use the variables that you set in Before you begin.

1. Check the resource group, AI Manager, namespace, and model deployment name before you delete the model deployment.
2. Delete only the model deployment.

    ```azurecli
    az aimanager namespace modeldeployment delete \
      --resource-group "$RESOURCE_GROUP" \
      --aimanager "$MANAGER_NAME" \
      --namespace "$NAMESPACE_NAME" \
      --name "$DEPLOYMENT_NAME" \
      --yes
    ```

This command targets the model deployment. It doesn't delete the namespace or AI Manager. To confirm the deletion, run the list command from Check a model deployment, which requires access to list deployments at the namespace or a parent scope. If your access is limited to the model deployment, ask an operator with namespace-level list access to perform this check. While the deletion is in progress, the state can show `Deleting`. When it finishes, the deployment no longer appears in the output.