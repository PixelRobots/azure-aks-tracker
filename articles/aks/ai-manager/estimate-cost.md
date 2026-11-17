---
layout: Conceptual
title: Choose a model and estimate deployment cost with AI Manager (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-manager/estimate-cost
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
description: Find a catalog model for your location, compare feasible GPU plans, and review the cost estimate before deployment.
ai-usage: ai-assisted
author: asabbour
ms.author: asabbour
ms.topic: how-to
ms.date: 2026-10-13T00:00:00.0000000Z
ms.custom: devx-track-azurecli
locale: en-us
document_id: c35ee405-7234-c271-8e3c-4f149629e171
document_version_independent_id: e41ad072-452c-f0b4-ae8b-e98569fde904
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-manager/estimate-cost.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/ai-manager/estimate-cost
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-manager/estimate-cost.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
platformId: 8408db4e-3065-310e-a61d-3926a73a6c64
---

# Choose a model and estimate deployment cost with AI Manager (preview) - Azure Kubernetes Service | Microsoft Learn

Before you create a model deployment, choose a catalog model that's available to your subscription and location. Run [`az aimanager model list`](/en-us/cli/azure/aimanager/model#az-aimanager-model-list) to find models, and run [`az aimanager model calculate-cost`](/en-us/cli/azure/aimanager/model#az-aimanager-model-calculate-cost) to compare feasible GPU plans and estimate VM cost.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Before you begin

- An Azure subscription and a location supported during preview. Use the same location for model listing, cost calculation, and deployment. Before listing models, [register the AI Manager preview feature](quickstart#register-the-ai-manager-preview-feature).
- Azure CLI with access to the AI Manager CLI extension for the public preview.
- Permission to read model catalog entries and calculate costs. The **Azure AIManager Model User** role provides these permissions at the subscription scope or another applicable parent scope.

## List available models

1. Sign in to Azure and select the subscription where you have the **Azure AIManager Model User** role.

    ```azurecli
    az login
    az account set --subscription "<subscription-id>"
    ```
2. List the catalog models available in the selected location.

    ```azurecli
    az aimanager model list \
      --subscription "<subscription-id>" \
      --location "<supported-region>" \
      --output table
    ```

    The table shows each model's `Name`, `ModelId`, and `Description`. If the table is empty, check the location and your **Azure AIManager Model User** role assignment.
3. Choose a catalog model by its readable `ModelId`. The matching `Name` value is the model's ARM resource name. Use it for the cost calculator and for the ARM resource ID that you use to create a deployment. The `ModelId` isn't the ARM resource name.

## Compare GPU plans and estimates

1. Calculate plans for the selected model. Set `<resource-name>` to the `Name` value that you chose in List available models.

    ```azurecli
    az aimanager model calculate-cost \
      --subscription "<subscription-id>" \
      --location "<supported-region>" \
      --name "<resource-name>" \
      --output table
    ```

    The table lists one plan per row. Feasible plans are listed first, from cheapest to most expensive.
2. Compare the plans. Select a plan where `Feasible` is `True`, and record its `VmSize`. The table includes the following columns:

    | Column | Meaning |
    | --- | --- |
    | `VmSize` | The VM size for the plan. Record this value for a feasible plan. |
    | `Feasible` | Whether you can deploy the model with this plan. Select a plan where the value is `True`. |
    | `VmsPerReplica` | The number of VMs that one model replica requires. |
    | `VmHourlyPrice` | The hourly retail price for one VM. A value of `0` means that no price is available. |
    | `TotalHourlyPrice` | The hourly price for one model replica, which is `VmHourlyPrice` multiplied by `VmsPerReplica`. |
    | `MaxAvailableReplicas` | The number of replicas that your current quota allows for this VM size. |
    | `Quantization` | The quantization applied to the model weights for this plan. |
    | `InfeasibilityReason` | For an infeasible plan, the reason code. See the following table. |

To estimate hourly VM cost for a fixed replica count, multiply `TotalHourlyPrice` by the number of replicas. With autoscaling, the actual hourly VM cost varies with the replica count. The calculator doesn't provide a complete estimate of every Azure charge associated with an AI Manager deployment. To see when prices were captured, run the command with `--output json` and check each plan's `priceAsOf` value.

The `InfeasibilityReason` column shows one of the following codes. For the full explanation, run the command with `--output json` and check each plan's `infeasibilityReason.message` value.

| Code | Meaning |
| --- | --- |
| `InsufficientQuota` | The subscription doesn't have enough quota for the plan. Request quota for the required VM family and location before you deploy. |
| `RegionUnavailable` | The VM size isn't available in the selected location. Choose another feasible plan or supported location. |
| `InefficientDeployment` | The plan's estimated serving performance is below the acceptable threshold for this model. Choose another plan or model. |

## Use the selected plan

Use the model's ARM resource name and the selected `vmSize` when you create a model deployment. For an end-to-end example, see [Deploy a model with AI Manager](quickstart).