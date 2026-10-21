---
layout: Conceptual
title: Troubleshoot common node auto-repair errors - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/node-auto-repair-errors
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
description: Learn common node auto-repair errors in AKS, find causes and fixes for NotReady nodes, and troubleshoot issues faster with actionable guidance.
ms.date: 2026-09-15T00:00:00.0000000Z
ms.reviewer: juliayin, aritraghosh, shmalfat, v-weizhu, shuyingqin
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance
ai-usage: ai-assisted
locale: en-us
document_id: 585ba7cc-fde0-658d-bb6f-81b9191a37a4
document_version_independent_id: 585ba7cc-fde0-658d-bb6f-81b9191a37a4
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/node-auto-repair-errors.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/node-auto-repair-errors
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/node-auto-repair-errors.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 7eaeb733-29b7-4b2a-f4df-bdb838ca12b4
---

# Troubleshoot common node auto-repair errors - Azure | Microsoft Learn

## Summary

When Azure Kubernetes Service (AKS) detects a node with a `NotReady` status for more than five minutes, it uses node auto-repair to try to restore the node. This article helps you troubleshoot common node auto-repair errors and understand why this best-effort service might not restore a node to a healthy state. For more information, see [node auto-repair process](/en-us/azure/aks/node-auto-repair).

During the node auto-repair process, AKS initiates `reboot`, `reimage`, and `redeploy` actions on your unhealthy node. Errors can occur for various reasons. You can discover error codes through [Kubernetes events](/en-us/azure/aks/events). Use Kubernetes events to monitor the status of your node and the auto-repair actions.

This article provides potential causes and solutions to common node auto-repair errors. It also outlines best practices for monitoring the node auto-repair process.

## Prerequisites

Check the following Kubernetes events to identify the type of node auto-repair error:

| Reason | Event message | Description |
| --- | --- | --- |
| NodeRebootError | Node auto-repair reboot action failed due to an operation failure: [error code here] | Emitted when there's an error with the `reboot` action. |
| NodeReimageError | Node auto-repair reimage action failed due to an operation failure: [error code here] | Emitted when there's an error with the `reimage` action. |
| NodeRedeployError | Node auto-repair redeploy action failed due to an operation failure: [error code here] | Emitted when there's an error with the `redeploy` action. |

Note

Because your node is already in an unhealthy state before the auto-repair process, in most cases, node auto-repair errors don't impact your cluster or applications. When you encounter node auto-repair errors, try to repair the node by following the instructions in [Basic troubleshooting of Node Not Ready failures](node-not-ready-basic-troubleshooting). If you can't restore it to a `Succeeded` status and see persistent errors reported by node auto-repair, contact [Azure support](https://ms.portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/overview?DMC=troubleshoot) for assistance.

## Common error codes

| Error code | Cause and solution |
| --- | --- |
| VMExtensionProvisioningError | One or more virtual machine (VM) extensions failed to provision on the VM. For more information about possible error types and troubleshooting steps, see [Troubleshoot the ERR_VHD_FILE_NOT_FOUND error code (124)](../create-upgrade-delete/error-code-vhdfilenotfound). To determine the exact VM extension provisioning error on your node, [view error details in the Azure portal](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues#view-resources-in-the-azure-portal). |
| InvalidParameter | This error occurs if the node auto-repair process tries to access a node that no longer exists. |
| scaleSetNameAndInstanceIDFromProviderID failed | This issue occurs when the node isn't provisioned correctly. |
| ManagedIdentityCredential authentication failed | This issue occurs when the node isn't initialized correctly. |
| VMRedeploymentFailed | This error occurs when you try to redeploy the node. In this case, your node pool might enter a failed state. For more information about potential causes and troubleshooting steps, see [Troubleshoot AKS upgrade, scaling, and failed-state errors](cluster-node-virtual-machine-failed-state#failed-operation-or-resource). |
| TooManyVMRedeploymentRequests | This error occurs when your cluster exceeds the limit for VM redeployment requests. `Redeploy` is one of the node auto-repair actions. This error means that the `redeploy` action can't repair your node. To troubleshoot the Node Not Ready issue, see [Basic troubleshooting of Node Not Ready failures](node-not-ready-basic-troubleshooting). |
| OutboundConnectivityNotEnabledOnVMSS | This error occurs when your node or overall Virtual Machine Scale Set doesn't have outbound access enabled. To resolve this issue, enable secure outbound access for your scale set by using a method that's best suited for your application. For more information, see ["OutboundConnectivityNotEnabledOnVM. No outbound connectivity configured for virtual machine."](../../virtual-machine-scale-sets/deploy/vmss-outbound-connectivity-not-enabled#solution) |

## Best practices for monitoring node auto-repair

- AKS stores Kubernetes events from the past hour by default. Enable [Container Insights](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable#enable-container-insights) so that you can store events for up to 90 days. You can also [query events and configure alerts](/en-us/azure/aks/events#automating-event-notifications) to quickly detect node auto-repair errors.
- Node auto-repair is a best-effort service. It doesn't guarantee that your node can be restored to a `Ready` status. Actively monitor and set alerts for Node Not Ready issues, and troubleshoot and resolve these issues yourself. For more information, see [basic troubleshooting of Node Not Ready issues](node-not-ready-basic-troubleshooting).