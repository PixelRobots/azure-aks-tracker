---
layout: Conceptual
title: Troubleshoot MOC unreachable errors during AKS on Azure Local cluster or node pool operations | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/infrastructure-operation-failures
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
description: Learn how to troubleshoot and recover from infrastructure errors when MOC is unreachable during AKS on Azure Local cluster or node pool creation or deletion.
ms.topic: troubleshooting
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: hyperconverged
locale: en-us
document_id: 68bf871f-529d-3e8f-73e9-7d6a4434f1bc
document_version_independent_id: 1e669a40-4396-6ff1-b438-13e09e9a11c7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/infrastructure-operation-failures.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/infrastructure-operation-failures
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/infrastructure-operation-failures.md
platformId: 8b29c045-85a9-0f74-8350-b7013fd51ded
---

# Troubleshoot MOC unreachable errors during AKS on Azure Local cluster or node pool operations | Microsoft Learn

This article describes how to identify and resolve a Microsoft On-premises Cloud (MOC) error. The "MOC is unreachable" error can occur when you try to create or delete a Microsoft Azure Kubernetes Service (AKS) cluster or node pool on Azure Local.

## Symptoms

When you try to create or delete an AKS cluster or node pool, you receive one of the following error messages:

```output
AksArc creation failed because MOC is unreachable. Read aka.ms/aksarc-moc-unreachable for more information. Detailed message: <detailed message>

AksArc cluster infrastructure deletion failed because MOC is unreachable. Read aka.ms/aksarc-moc-unreachable for more information. Detailed message: <detailed message>

AksArc nodepool infrastructure deletion failed because MOC is unreachable. Read aka.ms/aksarc-moc-unreachable for more information. Detailed message: <detailed message>

MOC deletion failed because it is unreachable. Read aka.ms/aksarc-moc-unreachable for more information. Detailed message: <detailed message>
```

## Cause

The Microsoft On-premises Cloud (MOC) service that manages the on-premises virtual machines and infrastructure for your AKS cluster is offline or unreachable. Because the operation can't reach MOC, the underlying infrastructure (virtual machines, networks, and disks) can't be created or cleaned up.

Important

Don't force-delete the Azure resource to work around this error. Force-deleting removes only the Azure Resource Manager (ARM) resource and leaves the on-premises virtual machines and infrastructure orphaned. You must restore MOC and retry the operation so the infrastructure is managed correctly.

## Possible causes and follow-ups

- The MOC cloud agent (`wssdcloudagent`) service isn't running, or multiple instances are running on the cluster.
- The MOC node agents (`wssdagent`) aren't installed or running on one or more nodes.
- MOC certificates or identity tokens are expired or corrupted.
- The MOC PowerShell configuration is corrupted or stuck in an **Updating** state.
- Azure Local nodes aren't in an **Active** state, or the node list is out of sync with the cluster.

## Use the `Support.AksArc` module to diagnose and remediate

The `Support.AksArc` module is a PowerShell-based tool that diagnoses and remediates common AKS on Azure Local issues, including MOC service failures. Run the module to detect why MOC is unreachable and apply the recommended remediation, then retry the operation.

For installation and usage steps, see [Support.AksArc diagnostic and remediation tool](support-module).

## Contact Microsoft Support

If the problem persists after restoring MOC, collect the [AKS cluster logs](get-on-demand-logs) before you [create a support request](aks-troubleshoot#open-a-support-request).