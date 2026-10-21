---
layout: Conceptual
title: AKS Cluster unhealthy after Kubernetes Upgrade | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/cluster-unhealthy-after-kubernetes-upgrade
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
description: Learn how to troubleshoot and mitigate an issue that causes AKS cluster to become unhealthy after Kubernetes upgrade
ms.topic: troubleshooting
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.lastreviewed: 2026-01-13T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: 5ad1f1bd-b4b7-55a3-b652-4735e1d0d2b0
document_version_independent_id: d3eb189c-2452-6bfd-ed66-4b4f136ee91d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/cluster-unhealthy-after-kubernetes-upgrade.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/cluster-unhealthy-after-kubernetes-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/cluster-unhealthy-after-kubernetes-upgrade.md
platformId: b4f2510b-b15d-4238-0fe2-1b387455e8e3
---

# AKS Cluster unhealthy after Kubernetes Upgrade | Microsoft Learn

After upgrading an AKS cluster to Kubernetes v1.31 or later, the cluster might enter a degraded or unhealthy state.

## Symptoms

The degraded or unhealthy state is observed when Azure Policy or Gatekeeper is enabled.

Cluster operations like reconciliation, upgrades, or certificate rotation might fail or behave unexpectedly.

## Cause

In Kubernetes v1.31 and later, certain update and reconciliation paths interact incorrectly with Azure Policy and Gatekeeper.

This issue occurs during upgrades or certificate reconciliation:

- Kubernetes version upgrades (for example, v1.30 to v1.31).
- Automated update mechanisms like the 45-day Workload Identity Federation (WLIF) certificate rotation.

When Azure Policy or Gatekeeper is enabled, these updates can cause the control plane to enter a degraded state.

## Affected configurations

- AKS clusters with Kubernetes version v1.31 and later.
- Azure Policy and/or Gatekeeper enabled.

## Workaround

Until a permanent fix is available, use one of the following mitigations.

### Option 1: Temporarily disable Azure Policy (recommended)

Disable Azure Policy on the affected cluster before you do the following tasks:

- Kubernetes version upgrades.
- Any operation that might trigger control plane updates, like certificate rotation.

Azure Policy can be re-enabled after the Kubernetes version is updated and the cluster returns to a healthy state.

### Option 2: Update Gatekeeper policies

If Gatekeeper is enabled, update the Gatekeeper constraint templates and policies to ensure compatibility with Kubernetes v1.31 behavior.

Note

This workaround might be customer-specific and might not apply in all environments.

## Resolution

This issue is currently under investigation, and a permanent fix is in progress.

Until the fix is fully validated and released, customers are advised to follow the recommended workarounds described in this article. This page is updated as more guidance becomes available.