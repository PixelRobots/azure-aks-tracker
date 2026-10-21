---
layout: Conceptual
title: Azure policy failure alert shows an empty list of affected resources - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/policy-failure-alert-show-empty-list-of-affected-resources
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Learn how to troubleshoot an Azure policy failure alert that shows an empty affected resources list in AKS, and take the next step to resolve persistent alerts.
ms.date: 2024-04-12T00:00:00.0000000Z
ms.reviewer: momajed, cssakscic
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: d4af87df-b7ae-ef4c-93a4-655031d60755
document_version_independent_id: d4af87df-b7ae-ef4c-93a4-655031d60755
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/policy-failure-alert-show-empty-list-of-affected-resources.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/policy-failure-alert-show-empty-list-of-affected-resources
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/policy-failure-alert-show-empty-list-of-affected-resources.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/eea02214-631d-404a-92d1-5a3357c32a26
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/f42c31d7-eed9-43b7-9757-54caffb53cdc
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 92b89cf0-9916-8e5a-8da3-d3d65a864853
---

# Azure policy failure alert shows an empty list of affected resources - Azure | Microsoft Learn

## Summary

This article provides a solution to an issue where a policy failure alert shows an empty list of affected resources when you use the Azure Policy Add-on for Azure Kubernetes Service (AKS).

## Symptoms

When an Azure policy deployed in an AKS cluster fails, the policy failure alert incorrectly displays an empty list of affected resources in the Azure portal.

## Cause

This issue might be caused by a delay or Graph API issue. This issue can occur even if the policy violation has been resolved.

## Resolution

If you suspect the alert is erroneous and the policy violation has been mitigated, wait for some time to allow for potential updates and synchronizations. In most cases, the issue can be resolved automatically when the system updates the alert status.

However, if the alert persists for more than a week or you believe the alert is inaccurate, we recommend opening a support case with Azure Support. Provide details about the specific policy, the related alert, error messages, or any relevant information. The Azure Support team will assist in investigating and resolving the issue.