---
layout: Conceptual
title: Azure policy guidance for AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/policy-guidance
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
description: Learn about best practices and guidance in using Azure policy in AKS on Windows Server.
ms.topic: best-practice
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.lastreviewed: 2023-05-03T00:00:00.0000000Z
ms.reviewer: sulahiri
ms.custom: windows-server
locale: en-us
document_id: 9c129809-6f8e-bb27-5e11-e9dfdfa628e7
document_version_independent_id: 50a4ee08-2456-87f6-def2-18a8cda2f0a6
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/policy-guidance.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/policy-guidance
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/policy-guidance.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/eea02214-631d-404a-92d1-5a3357c32a26
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f42c31d7-eed9-43b7-9757-54caffb53cdc
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: f814dd79-fedc-e9f8-6173-4d48c2a71c38
---

# Azure policy guidance for AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article provides guidance on applying Azure policies to management clusters and recommendations for deploying AKS on Windows Server.

## Best practices in using Azure policies

Azure policies are set at the subscription level. By default, the policies apply to both management and target/workload clusters.

### Different subscriptions for different environments

Before launching a policy in production, a best practice is to test it in a preproduction environment. Because policies are set at the subscription level, it's best to keep preproduction and production environments on separate subscriptions.

### Policy testing in audit mode

Before enforcing a policy in preproduction or production environments, verify its functionality in audit mode.

## Considerations for applying Azure policies to Kubernetes management clusters

You shouldn't enable enforcement mode for Azure policy on management clusters, because management clusters don't run customer workloads. Enforcing Azure policies can cause some pods not to start.

### Disable enforcement mode on management clusters

The management cluster and target cluster, being on the same subscription, inherit the same Azure policies by default. To prevent management clusters from running Azure policies in enforcement mode, place the management and target clusters in different resource groups and apply an exclusion policy to the management cluster resource group. For more information about exclusion policy application, see [Azure Policy exemption structure](/en-us/azure/governance/policy/concepts/exemption-structure).

### Monitor management clusters

Azure policies are primarily for declarative compliance validation, not behavior-based threat detection. If there's concern about the security posture of the management cluster, a threat monitoring tool to track suspicious activities should be evaluated.