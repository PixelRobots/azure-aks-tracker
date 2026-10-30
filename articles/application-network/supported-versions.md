---
layout: Conceptual
title: Azure Kubernetes Application Network Supported Versions (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-network/supported-versions
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
description: Learn about the supported versions of Azure Kubernetes Application Network, their compatible AKS versions, and how to check available versions in your region.
author: Kochhars
ms.author: kochhars
ms.service: azure-kubernetes-app-net
ms.topic: concept-article
ms.date: 2026-10-29T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 5ee4cde3-8843-f566-a708-d7cde6e00904
document_version_independent_id: 304fc12c-192f-27f9-5d8c-f1606677fe3b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/application-network/supported-versions.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: application-network/supported-versions
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-network/supported-versions.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: de7550bd-90c2-251c-4d4f-7af1eb0fb5ef
---

# Azure Kubernetes Application Network Supported Versions (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Azure Kubernetes Application Network releases minor versions roughly once a quarter. Minor version releases include new features, improvements, and component updates. Each minor version has a specific Istio minor version built in, though consecutive Application Network versions might share the same Istio version. Patch releases include fixes for bugs and security vulnerabilities.

This article lists Application Network versions, their support lifecycle, and their compatible Azure Kubernetes Service (AKS) versions.

## Supported Application Network versions and compatible AKS versions

The following table lists Azure Kubernetes Application Network versions, their corresponding Istio versions, end-of-life information, compatible AKS versions, and fully managed release channels. Recently retired versions remain in the table for reference and are no longer supported. Version availability and release-channel mappings vary by region and AKS version. Check available versions in your region before onboarding or planning an upgrade.

| Application Network version | Istio version | End of life | Compatible AKS versions | Fully managed release channel |
| --- | --- | --- | --- | --- |
| 1.1 (retired) | 1.26 | April 2026 | 1.30, 1.31, 1.32, 1.33, 1.34 | None |
| 1.2 (retired) | 1.27 | May 2026 | 1.30, 1.31, 1.32, 1.33, 1.34, 1.35 | None |
| 1.3 (retired) | 1.28 | Sept 2026 | 1.30, 1.31, 1.32, 1.33, 1.34, 1.35 | None |
| 1.4 | 1.29 | Not confirmed | 1.31, 1.32, 1.33, 1.34, 1.35, 1.36 | None |
| 1.5 | 1.30 | ~Dec 2026 (expected) | 1.32, 1.33, 1.34, 1.35, 1.36 | `Stable` |
| 1.6 | 1.31 | Not confirmed | 1.32, 1.33, 1.34, 1.35, 1.36 | `Rapid` |

End-of-life dates marked *expected* are estimates of *earliest possible* retirement, not confirmed dates.

`SelfManaged` mode offers two or three supported Application Network versions at a time. An individual member might have fewer compatible versions available, depending on its AKS version and region.

`FullyManaged` mode uses the `Rapid` and `Stable` release channels instead of selecting a version directly. The channels offer two supported versions when they target different versions, or one when they target the same version. A channel is available to a member only if its target version is compatible with the member's AKS version.

Important

Application Network doesn't manage upgrades of your AKS cluster. To remain in support, select a compatible version during onboarding and upgrade it regularly to maintain compatibility with Application Network. Compatibility with Application Network doesn't extend the AKS version's support lifecycle. Refer to the [AKS Kubernetes release calendar](../aks/supported-kubernetes-versions#aks-kubernetes-release-calendar-and-upcoming-versions) for AKS version end-of-life dates.

## List available versions in your region

- List the available versions in your region using the [`az appnet list-versions`](/en-us/cli/azure/appnet#az-appnet-list-versions) command.

    ```azurecli
    az appnet list-versions --location $LOCATION -o table
    ```

    You can also use the [`az appnet list-versions`](/en-us/cli/azure/appnet#az-appnet-list-versions) command to check which version each release channel corresponds to for Azure Kubernetes Application Network members enrolled in [`FullyManaged` upgrade mode](upgrades#fully-managed-mode).