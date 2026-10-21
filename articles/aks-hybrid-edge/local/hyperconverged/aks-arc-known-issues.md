---
layout: Conceptual
title: Troubleshoot known issues in AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/aks-arc-known-issues
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
ms.service: azure-kubernetes-service-hybrid
description: Learn about known issues and workarounds in AKS Hybrid and Edge.
ms.topic: how-to
author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2026-02-11T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: fd9abd5d-36cb-ee3f-63e9-3732db9551a9
document_version_independent_id: 06ff5d6c-7d98-40b4-181b-603e6a5f0798
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/aks-arc-known-issues.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/aks-arc-known-issues
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/aks-arc-known-issues.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
platformId: 85c47f8b-c125-6ae1-07f8-489d76f74cbe
---

# Troubleshoot known issues in AKS Hybrid and Edge | Microsoft Learn

This article identifies known issues and their workarounds in AKS. These release notes are continuously updated, and as you discover issues that require a workaround, add them here.

If you encounter an issue that isn't listed here, [open a support request](help-support).

Important

AKS on Azure Local is supported only when the underlying Azure Local instance is within its six-month support window. If your Azure Local version falls out of support, update to a supported version before troubleshooting further. For details, see [End of support for Azure Local versions](/en-us/azure/azure-local/release-information-23h2#end-of-support-for-azure-local-versions) and [AKS on Azure Local support policies](aks-on-azure-local-support-policy#azure-local-version-support-window).

## Known issues

The following section describes known issues for AKS Hybrid and Edge:

| AKS CRUD operation | Issue | Fix status |
| --- | --- | --- |
| AKS cluster upgrade | [Cluster with Azure Policy or Gatekeeper unhealthy after upgrade](cluster-unhealthy-after-kubernetes-upgrade) | Active |
| AKS cluster create | [Cluster create fails after Azure Local update from 2510](cluster-create-fails-after-azure-local-upgrade) | Active |
| AKS cluster create | [Can't create AKS cluster with GPU-enabled default node pool](gpu-enabled-cluster-issue) | Active |
| AKS cluster delete | [Deleted AKS cluster still visible on Azure portal](deleted-cluster-visible) | Active |