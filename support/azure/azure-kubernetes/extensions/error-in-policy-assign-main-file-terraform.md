---
layout: Conceptual
title: Error in policy assignments Main.tf file of Terraform - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/error-in-policy-assign-main-file-terraform
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
description: Resolve the Terraform Policy definition not found error in policy assignments by adding the correct depends_on order in Main.tf. Use this fix now.
ms.date: 2024-03-27T00:00:00.0000000Z
ms.reviewer: chiragpa, andbar, haitch, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons, devx-track-terraform
locale: en-us
document_id: 52147648-ea3a-6b64-be93-0b0eb6bcdbb3
document_version_independent_id: 52147648-ea3a-6b64-be93-0b0eb6bcdbb3
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/error-in-policy-assign-main-file-terraform.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/error-in-policy-assign-main-file-terraform
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/error-in-policy-assign-main-file-terraform.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 50f3dad1-8406-a41f-e96c-a71999657b76
---

# Error in policy assignments Main.tf file of Terraform - Azure | Microsoft Learn

## Summary

This article provides a solution to the "Policy definition not found" error that you encounter during policy assignments when you use the Terraform tool.

## Symptoms

When you try to run the following policy assignments that are configured in the *Main.tf* file of the Terraform tool, you receive the "Policy definition not found" error message:

```
resource "azurerm_policy_assignment" "kubernetes" {
  name                 = "kubernetes"
  scope                = <scope>
  policy_definition_id = <policy_definition_id>
  description          = "Assignment of the Kubernetes to subscription."
  display_name         = "Kubernetes-custom-initiative-test01"
}
```

## Cause

The error occurs if the policy assignment references the policy initiative definition that's provided for the `policy_definition_id` argument. However, the `azurerm_policy_set_definition` module might be delayed or not found before the policy assignment is created.

## Solution

In your Terraform configuration, include a `depends_on` parameter within the policy assignment resource, as shown the following example. This value makes sure that the policy assignment is generated only after the creation of the policy set definition.

```
resource "azurerm_policy_assignment" "kubernetes" {
  name                 = "kubernetes"
  scope                = <scope>
  policy_definition_id = <policy_definition_id>
  description          = "Assignment of the Kubernetes to subscription."
  display_name         = "Kubernetes-custom-initiative-test01"
  depends_on = [azurerm_policy_definition.policies]
}
```

For more information, see [the depends_on Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on).

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.