---
layout: Conceptual
title: Managed Gateway API Installation Troubleshooting - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/managed-gateway-api
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: nshankar13
ms.author: nshankar
ms.topic: troubleshooting
description: Use this guide for Managed Gateway API installation troubleshooting in AKS to validate CRD channels, annotations, and upgrades, then fix issues quickly.
ms.date: 2025-08-26T00:00:00.0000000Z
ms.reviewer: jkatariya
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: f8a964b6-6f8f-7b0f-4381-53531a9368ed
document_version_independent_id: f8a964b6-6f8f-7b0f-4381-53531a9368ed
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/managed-gateway-api.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/managed-gateway-api
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/managed-gateway-api.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 565bda70-4755-9be4-443b-fc554511ca02
---

# Managed Gateway API Installation Troubleshooting - Azure | Microsoft Learn

## Summary

The [Managed Gateway API installation](/en-us/azure/aks/managed-gateway-api) for Azure Kubernetes Service (AKS) enables users to opt in to a managed installation of the [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/) Custom Resource Definitions (CRDs).

## Step 1: Verify existing Gateway API CRD channel and bundle version

If you already installed the Gateway API CRDs before you enabled the Managed Gateway API installation, make sure that the Gateway API CRD [bundle version is compatible with your cluster's Kubernetes version](/en-us/azure/aks/managed-gateway-api#gateway-api-bundle-version-and-aks-kubernetes-version-mapping) and that you have only CRDs installed for the `standard` channel. Before you enable the Managed Gateway API installation, also verify that the self-managed CRDs in the existing installation have the following annotations:

- `gateway.networking.k8s.io/bundle-version`
- `gateway.networking.k8s.io/channel`

You might continue to experience issues that affect installing the Managed Gateway CRDs despite having the correct bundle version and Kubernetes version and only `standard` channel CRDs. In this case, we recommend that you disable the Managed Gateway API installation, uninstall all the self-managed CRDs, and re-enable the Managed Gateway API CRDs.

## Step 2: Make sure that managed CRDs have expected annotations

When AKS successfully installs fresh managed Gateway API CRDs, or takes ownership of pre-existing user-managed installations of the CRDs, the following annotations should appear on the CRD objects:

- `app.kubernetes.io/managed-by: aks`
- `app.kubernetes.io/part-of: <hash>`
- `eno.azure.io/replace: true`

If these annotations are missing, it's possible that an issue affects the Managed Gateway API CRD provisioning. Make sure that no conflicts exist in pre-existing installations of the Gateway API CRDs. Then, try to uninstall and reinstall the Managed Gateway CRDs to determine whether the expected annotations are successfully added.

## Step 3: Inspect Managed Gateway API CRD version after AKS upgrades

If you upgrade your AKS cluster to a new minor version after you install the Managed Gateway API CRDs, the CRDs are automatically upgraded to the [new supported Gateway API bundle version for that Kubernetes version](/en-us/azure/aks/managed-gateway-api#gateway-api-bundle-version-and-aks-kubernetes-version-mapping). You should verify that the Gateway API CRD bundle version is updated accordingly based on the value of the `gateway.networking.k8s.io/bundle-version` annotation. If it's not, try to uninstall and reinstall the Managed Gateway CRDs to see whether the bundle version is updated to the newer version.