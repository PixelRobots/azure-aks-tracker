---
layout: Conceptual
title: Troubleshoot the LinkedAuthorizationFailed error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/linkedauthorizationfailed-error
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
description: Fix the LinkedAuthorizationFailed error during AKS cluster creation or deployment by identifying missing permissions and applying role assignments now.
ms.date: 2026-07-21T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: rissing, chiragpa, erbookbi, v-leedennis, andraciobanu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 4ba5d2a5-f3db-1a2f-7676-85b348d30221
document_version_independent_id: 4ba5d2a5-f3db-1a2f-7676-85b348d30221
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/linkedauthorizationfailed-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/linkedauthorizationfailed-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/linkedauthorizationfailed-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 2a99e5aa-ce93-af1e-0cbc-f99d1d574688
---

# Troubleshoot the LinkedAuthorizationFailed error code - Azure | Microsoft Learn

## Summary

Use this article to troubleshoot the `LinkedAuthorizationFailed` error when you create or deploy an Azure Kubernetes Service (AKS) cluster. By following these steps, you can complete the operation successfully.

## Symptoms

When you try to create an AKS cluster, you receive the following error message:

> 
> Reconcile VNet failed.
> 
> Details: VNetReconciler retry failed:
> 
> Category: ClientError; SubCode: LinkedAuthorizationFailed;
> 
> Dependency: Microsoft.Network/virtualNetworks; OrginalError: Code="LinkedAuthorizationFailed"
> 
> Message="**The client 'aaaaaaaa-0000-1111-2222-bbbbbbbbbbbb' with object id '123456789-1234-1234-1234-1234567890987' has permission to perform action 'Microsoft.Network/virtualNetworks/write' on scope '/subscriptions/*&lt;subscription-id-guid&gt;*/resourceGroups/MC\_MyRG\_westeurope/providers/Microsoft.Network/virtualNetworks/aks-vnet'; however, it doesn't have permission to perform action 'Microsoft.Network/ddosProtectionPlans/join/action' on the linked scope(s) '/subscriptions/*&lt;subscription-id-guid&gt;*/resourcegroups/ddos-protection-plan-rg/providers/microsoft.network/ddosprotectionplans/upmddosprotectionplan'** or the linked scope(s) are invalid.";
> 
> AKSTeam: Networking, Retriable: false.

## Cause

A service principal doesn't have permission to use a resource that's required for cluster creation.

## Solution

Grant the service principal permissions to use the resource that's mentioned in the error message. The example output in the "Symptoms" section provides the following information.

| Item | Value |
| --- | --- |
| Service principal | aaaaaaaa-0000-1111-2222-bbbbbbbbbbbb |
| Resource | /subscriptions/*&lt;subscription-id-guid&gt;*/resourcegroups/ddos-protection-plan-rg/providers/microsoft.network/ddosprotectionplans/upmddosprotectionplan |
| Operation | Microsoft.Network/ddosProtectionPlans/join/action |

For more information about how to grant permissions to the service principal, see [Assign Azure roles using the Azure portal](/en-us/azure/role-based-access-control/role-assignments-portal).

## More information

- [General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)

If role assignments appear correct but cluster creation still fails, verify role assignment propagation, confirm permissions at the linked resource scope, inspect Activity Logs for authorization failures, and validate that the referenced resource still exists and is accessible from the target subscription and resource group. Review the exact operation shown in the error (for example, `Microsoft.Network/ddosProtectionPlans/join/action`) and confirm the identity has that permission on the linked resource.

If the required permission appears to be assigned but the deployment still fails with LinkedAuthorizationFailed, verify the identity and scope involved in the authorization check. Review the full error message to identify:

The client or object ID performing the operation. The linked resource scope referenced in the error. The specific action that is denied (for example, `Microsoft.Network/ddosProtectionPlans/join/action`).

Confirm that the identity used by the AKS deployment (service principal or managed identity) has the required role assignment on both the primary resource and any linked resources referenced in the error message. Also verify that the role assignment exists at the correct scope and that inherited permissions are effective. For complex scenarios involving resources in different resource groups or subscriptions, review Azure Activity Logs and role assignments to determine where authorization fails before retrying the cluster creation.