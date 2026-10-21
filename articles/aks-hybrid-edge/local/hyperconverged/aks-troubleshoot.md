---
layout: Conceptual
title: Troubleshoot issues in AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/aks-troubleshoot
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
description: Learn how to troubleshoot various Kubernetes issues in AKS Hybrid and Edge.
ms.topic: how-to
author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2025-07-29T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: hyperconverged
locale: en-us
document_id: 8f785619-cffa-0b7c-1484-ea58b6974640
document_version_independent_id: 6bb82b76-ea90-7a92-9756-72d108f8f851
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/aks-troubleshoot.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/aks-troubleshoot
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/aks-troubleshoot.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 91a4e77e-fbba-12cc-5e0a-60a0c4bea48c
---

# Troubleshoot issues in AKS Hybrid and Edge | Microsoft Learn

This section describes how to find solutions for Kubernetes issues you might encounter when using AKS Hybrid and Edge.

## Open a support request

To open a support request, see the [Get support](help-support) article for information about how to use the Azure portal to get support or open a support request for AKS.

## Guides to diagnose and troubleshoot Kubernetes CRUD failures

| AKS operation | Issue |
| --- | --- |
| General network validation errors | [Troubleshoot network validation errors](network-validation-errors) |
| Create validation | [Control plane configuration validation errors](control-plane-validation-errors) |
| Create validation | [K8sVersionValidation error](cluster-k8s-version) |
| Create validation | [KubeAPIServer unreachable error](kube-api-server-unreachable) |
| Network configuration issues | [Use diagnostic checker](aks-arc-diagnostic-checker) |
| Kubernetes steady state | [Resolve issues due to out-of-band deletion of storage volumes](delete-storage-volume) |
| Kubernetes steady state | [Repeated Entra authentication prompts when running kubectl with Kubernetes RBAC](entra-prompts) |
| Network validation | [Network validation error due to .local domain](network-validation-error-local) |
| Network validation | [Troubleshoot BGP with FRR in AKS environments](connectivity-troubleshoot) |
| Disable Windows node pools | [Disable Windows node pools](disable-windows-nodepool) |
| Azure Arc resource bridge deleted or recovered | [Impact to clusters when Arc resource bridge is deleted or recovered](azure-arc-resource-bridge-deleted-recovered) |