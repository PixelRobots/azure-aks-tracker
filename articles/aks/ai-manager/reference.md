---
layout: Conceptual
title: AI Manager resource reference (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-manager/reference
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
description: Reference AI Manager resource paths, selected properties, scaling values, provisioning states, and endpoint details.
ai-usage: ai-assisted
author: asabbour
ms.author: asabbour
ms.topic: reference
ms.date: 2026-10-13T00:00:00.0000000Z
ms.custom: devx-track-azurecli
locale: en-us
document_id: 8d368fd7-52bd-fecf-a49d-ce22cd855041
document_version_independent_id: 3cb64068-756e-ddec-a301-6a2bc93e76cb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-manager/reference.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/ai-manager/reference
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-manager/reference.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 19dabfcf-f2dd-983b-2f8e-e773d2808749
---

# AI Manager resource reference (preview) - Azure Kubernetes Service | Microsoft Learn

This article lists ARM resource paths, properties, and defaults for AI Manager, namespace, and model deployment resources. It also lists provisioning states, runtime status fields, and the `az aimanager namespace list-accesskeys` output. These details apply to the AI Manager public-preview guides. The API version represented by the current generated types is `2026-09-02-preview`.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

For procedures, see [Deploy a model with AI Manager](quickstart), [Manage model deployments](manage-deployments), and [Choose a model and estimate deployment cost](estimate-cost). To inspect command options in your installed extension, run `az aimanager --help` or `az aimanager namespace modeldeployment --help`.

## AI Manager resource relationships

| Resource | ARM resource path | Scope |
| --- | --- | --- |
| AI Manager | `Microsoft.ContainerService/aiManagers/{aiManagerName}` | Resource group |
| Namespace | `Microsoft.ContainerService/aiManagers/{aiManagerName}/namespaces/{namespaceName}` | Child of an AI Manager |
| Model deployment | `Microsoft.ContainerService/aiManagers/{aiManagerName}/namespaces/{namespaceName}/modeldeployments/{deploymentName}` | Child of a namespace |
| AI model | `Microsoft.ContainerService/locations/{location}/aiModels/{modelName}` | Subscription and location |

An AI model (catalog model) isn't nested under an AI Manager or resource group. The readable `modelId` identifies a catalog model. Its ARM resource name, the `name` value, is different.

## AI Manager properties

| Property | Description and values | Default or mutability |
| --- | --- | --- |
| `location` | Required Azure location for the AI Manager. | Required when creating the resource. |
| `properties.deletePolicy` | Controls what happens to the underlying cluster resources when you delete the AI Manager. `Keep` retains those resources; `Delete` deletes both the underlying cluster resources and the AI Manager resource together. | Defaults to `Delete` when omitted. |
| `properties.provisioningState` | Read-only state of the last AI Manager operation. | Read-only. See Provisioning states. |
| `properties.managedResourceGroupName` | Read-only name of the managed resource group created by AI Manager to hold underlying infrastructure resources. | Read-only. |

## AI Manager namespace properties

| Property | Description |
| --- | --- |
| `properties.labels` | Optional map of labels applied to the Kubernetes namespace. |
| `properties.annotations` | Optional map of annotations applied to the Kubernetes namespace. |
| `properties.provisioningState` | Read-only state of the last namespace operation. See Provisioning states. |

## AI Manager model deployment properties

| Property | Description and values | Update behavior |
| --- | --- | --- |
| `properties.modelResourceId` | Full ARM resource ID of the catalog model used by the deployment. | Immutable after creation. Create a new deployment to use a different catalog model. |
| `properties.vmSize` | VM SKU used by the deployment. Choose a feasible plan from `az aimanager model calculate-cost`. | Immutable after creation. Create a new deployment to use a different VM size. |
| `properties.scale.manual.replicas` | Desired fixed replica count. | Change with `az aimanager namespace modeldeployment update --replicas`. |
| `properties.scale.autoscale.minReplicas` and `properties.scale.autoscale.maxReplicas` | Minimum and maximum replica counts for autoscaling. | Change with `--min-replicas` and `--max-replicas`. Don't combine these options with `--replicas`. |
| `properties.performanceMode` | Performance mode. Values are `Balanced` (default balance between latency and throughput), `Latency` (optimize for low request latency), and `Throughput` (optimize for aggregate throughput). | The CLI update command exposes `--performance-mode`. |
| `properties.status` | Read-only runtime status. | Read-only. See Runtime status. |

The CLI update command exposes scaling and performance mode options. To change a deployment's catalog model or VM size, create a new model deployment.

## Select an AI Manager model from the catalog

Before using the catalog, [register the AI Manager preview feature](quickstart#register-the-ai-manager-preview-feature). Run [`az aimanager model list`](/en-us/cli/azure/aimanager/model#az-aimanager-model-list) for the subscription and location where you plan to deploy. Choose a catalog model by its readable `modelId`. Use its matching `name` value as the ARM resource name for the cost calculator and when building the deployment's `modelResourceId`.

```azurecli
az aimanager model list \
  --subscription "<subscription-id>" \
  --location "<location>" \
  --output table
```

For model selection and cost planning, see [Choose a model and estimate deployment cost](estimate-cost).

## Provisioning states

The AI Manager, namespace, and model deployment resources use these provisioning state values:

| State | Description |
| --- | --- |
| `Creating` | The resource is being created. |
| `Updating` | The resource is being updated. |
| `Deleting` | The resource is being deleted. |
| `Succeeded` | The last operation completed successfully. |
| `Failed` | The last operation failed. |
| `Canceled` | The last operation was canceled. |

## Runtime status

`properties.status` is read-only. Each field in the following table is under that path, for example `properties.status.currentReplicas`. Current model deployment API types include these fields:

| Field | Description |
| --- | --- |
| `endpoint` | Serving endpoint of the model deployment, reported by the runtime. Full path: `properties.status.endpoint`. |
| `currentReplicas` | Number of ready replicas currently serving traffic. |
| `desiredReplicas` | Desired replica count reported by the controller. For manual scaling, this matches `properties.scale.manual.replicas`; for autoscaling, it is the current target derived by the autoscaler. |
| `engine` and `engineVersion` | Inference engine name and version. |
| `maxModelLen` | Maximum model context length, in tokens, configured for the deployment. |
| `quantization` | Quantization level applied to the model weights. |
| `peakTokensPerMinute` | Peak tokens per minute measured by a live stress test. |
| `estimatedProvisionTimeSeconds` | Estimated total time, in seconds, for the deployment to become ready, including VM provisioning, image and model-weight pulls, and engine warm-up. |

Separately from `properties.status`, the `az aimanager namespace list-accesskeys` command returns the following namespace access information:

| Field | Description |
| --- | --- |
| `endpoint` | In the `list-accesskeys` output, the OpenAI-compatible base URL for the namespace inference endpoint. Use it as returned by the command. |
| `primaryKey` and `secondaryKey` | API keys for the endpoint. Treat both values as secrets. |
| `lastRotatedAt` | UTC timestamp of the last key rotation. Absent until a rotation occurs. |