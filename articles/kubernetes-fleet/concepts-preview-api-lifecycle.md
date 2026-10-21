---
layout: Conceptual
title: Azure Kubernetes Fleet Manager Preview API lifecycle | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-preview-api-lifecycle
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
learn_banner_products:
- azure
description: Learn about the Azure Kubernetes Fleet Manager preview API lifecycle.
ms.date: 2026-03-09T00:00:00.0000000Z
ms.topic: concept-article
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
locale: en-us
document_id: d98d4f40-6d13-140e-daf1-0cbfaf950f79
document_version_independent_id: c163c62d-8bfc-ab23-b55f-cd37b2f88e1b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-preview-api-lifecycle.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-preview-api-lifecycle
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-preview-api-lifecycle.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/4e834929-0ce1-4c1d-9c81-fcb14721edfb
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/75670257-a3f0-4627-9981-8046f99219e6
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 3b2098a8-af8f-fc73-78aa-7524d81cc15a
---

# Azure Kubernetes Fleet Manager Preview API lifecycle | Microsoft Learn

The Azure Kubernetes Fleet Manager preview Azure Resource Manager (ARM) REST APIs (APIs that end in `-preview`) have a lifespan of approximately one year from their release date. This means that you can expect the 2024-05-02-preview API to be deprecated around May 3, 2025.

We love when people try our preview features and give us feedback, so we encourage you to use the preview APIs and the tools built on them.

After an API version is deprecated, it will no longer function. We recommend you routinely:

- Update your ARM/Bicep/Terraform templates using preview API versions to use the latest compatible version of the API.
- Update any preview SDKs or other tools built on the preview API to the latest version.

You should perform these updates at a minimum every 6-9 months. If you fail to do so, you'll be notified that you're using a soon-to-be deprecated API version as deprecation approaches.

This article covers Azure Kubernetes Fleet Manager API deprecations. For Azure Kubernetes Service (AKS) API deprecations, see [AKS preview API lifecycle](/en-us/azure/aks/concepts-preview-api-life-cycle).

## Upcoming API deprecations

| API version | Announce Date | Deprecation Date |
| --- | --- | --- |
| 2025-04-01-preview | TBC | TBC |
| 2024-05-02-preview | TBC | TBC |
| 2024-02-02-preview | TBC | TBC |

## Completed API deprecations

| API version | Announce Date | Deprecation Date |
| --- | --- | --- |
| 2023-08-15-preview | December 16, 2024 | April 14, 2025 |
| 2023-06-15-preview | December 16, 2024 | April 14, 2025 |
| 2023-03-15-preview | December 16, 2024 | April 14, 2025 |
| 2022-09-02-preview | December 16, 2024 | April 14, 2025 |
| 2022-07-02-preview | December 16, 2024 | April 14, 2025 |
| 2022-06-02-preview | December 16, 2024 | April 14, 2025 |

## How to check API versions in use

If you're unsure what client or tool is using a specific API version, check the [activity logs](/en-us/azure/azure-monitor/essentials/activity-log) using the following command. Update the `API_VERSION` with the version you want to check for.

```azurecli
API_VERSION="2024-05-02-preview"
az monitor activity-log list \
    --offset 30d \
    --max-events 10000 \
    --namespace microsoft.containerservice.fleets \
    --query "[?eventName.value == 'EndRequest' && contains(not_null(httpRequest.uri,''), '${API_VERSION}')]"
```

## How to check API versions used in templates

# [Bicep templates](#tab/bicep-templates)
In Bicep templates, look at the version of the resource which appears at the end of the resource type (`@2024-05-02-preview`).

```bicep
resource symbolicname 'Microsoft.ContainerService/fleets@2024-05-02-preview' = {
    ...
}
```

# [ARM templates](#tab/arm-templates)
In ARM templates, check the `apiVersion` property.

```json
{
  "type": "Microsoft.ContainerService/fleets",
  "apiVersion": "2024-05-02-preview",
  ...
}
```

# [Terraform templates](#tab/terraform-templates)
In Terraform, check the value of the `type` property which defines the resource type and API version (`@2024-05-02-preview`).

```json
resource "azapi_resource" "symbolicname" {
  type = "Microsoft.ContainerService/fleets@2024-05-02-preview"
  ...
}
```

---

## How to update tools and SDKs

Important

The Azure CLI and `fleet` extension **must** be updated to the latest version by using `az upgrade` and `az extension update --name fleet`.

- For Azure SDKs: Use a newer API version by updating to a [newer version of the SDK](https://azure.github.io/azure-sdk/releases/latest/index.html?search=containerservicefleet).
- For Terraform: Update to the latest version of the AzureRM Terraform module. To find out what version of the API a particular Terraform release is using, check the [Terraform release notes](/en-us/azure/developer/terraform/provider-version-history-azurerm) or git log [this file](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/internal/services/containers/client/client.go).
- For other tools: Update the tool to the latest version.