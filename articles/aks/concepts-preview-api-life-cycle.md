---
layout: Conceptual
title: AKS Preview API life cycle - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-preview-api-life-cycle
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
description: Learn about the AKS preview API life cycle.
ms.custom: azure-kubernetes-service,innovation-engine
ms.topic: concept-article
ms.date: 2026-03-31T00:00:00.0000000Z
author: matthchr
ms.author: matthchr
locale: en-us
document_id: d66c7c38-fb68-7e0f-42d6-ceb4c1a70f7d
document_version_independent_id: df2e776b-93bd-360f-3ccd-581361f5045f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-preview-api-life-cycle.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-preview-api-life-cycle
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-preview-api-life-cycle.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 6490098d-bf8c-c2dd-8333-34447679941a
---

# AKS Preview API life cycle - Azure Kubernetes Service | Microsoft Learn

The Azure Kubernetes Service (AKS) preview APIs (APIs that end in `-preview`) have a lifespan of ~one year from their release date. This means that you can expect the 2023-01-02-preview API to be deprecated somewhere around January 1st, 2024.

We love when people try our preview features and give us feedback, so we encourage you to use the preview APIs and the tools built on them (such as the [AKS Preview CLI Extension](https://github.com/Azure/azure-cli-extensions/tree/main/src/aks-preview)).

After an API version is deprecated, it will no longer function! We recommend you routinely:

- Update your ARM/BICEP templates using preview API versions to use the latest version of the preview API.
- Update your AKS preview CLI extension to the latest version.
- Update any preview SDKs or other tools built on the preview API to the latest version.

You should perform these updates at a minimum every 6-9 months. If you fail to do so, you will be notified that you are using a soon-to-be deprecated API version as deprecation approaches.

## How to check what API versions you're using

If you're unsure what client or tool is using this API version, check the [activity logs](/en-us/azure/azure-monitor/essentials/activity-log) using the following command:

Set the API version you want to inspect for recent usage in the activity log. In this example, we are checking for the `2022-04-01-preview` API version.

```bash
export API_VERSION="2022-04-01-preview"
az monitor activity-log list --offset 30d --max-events 10000 --namespace microsoft.containerservice --query "[?eventName.value == 'EndRequest' && contains(not_null(httpRequest.uri,''), '$API_VERSION')]"
```

## How to update to a newer version of the API

- For Azure SDKs: use a newer API version by updating to a [newer version of the SDK](https://azure.github.io/azure-sdk/releases/latest/index.html?search=containerservice).
- For Azure CLI: Update the CLI itself and the aks-preview extension (if used) to the latest version by running `az upgrade` and `az extension update --name "aks-preview"`.
- For Terraform: Update to the latest version of the AzureRM Terraform module. To find out what version of the API a particular Terraform release is using, check the [Terraform release notes](/en-us/azure/developer/terraform/provider-version-history-azurerm) or git log [this file](https://github.com/hashicorp/terraform-provider-azurerm/blob/main/internal/services/containers/client/client.go).
- For other tools: Update the tool to the latest version.

## Upcoming deprecations

| API version | Announce Date | Deprecation Date |
| --- | --- | --- |
| 2023-10-02-preview | March 24, 2026 | July 1, 2026 |
| 2023-11-02-preview | March 24, 2026 | July 1, 2026 |
| 2024-01-02-preview | March 24, 2026 | July 1, 2026 |
| 2024-02-02-preview | March 24, 2026 | July 1, 2026 |
| 2024-03-02-preview | March 24, 2026 | July 1, 2026 |
| 2024-04-02-preview | March 24, 2026 | July 1, 2026 |
| 2024-05-02-preview | March 24, 2026 | July 1, 2026 |
| 2024-06-02-preview | March 24, 2026 | July 1, 2026 |
| 2024-07-02-preview | March 24, 2026 | July 1, 2026 |
| 2024-08-02-preview | March 24, 2026 | July 1, 2026 |
| 2024-09-02-preview | March 24, 2026 | July 1, 2026 |