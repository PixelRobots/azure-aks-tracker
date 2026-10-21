---
layout: Conceptual
title: Troubleshoot Pods Remain in a Pending State Scenario - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-pods-remain-pending-state-scenario
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
description: This article helps you troubleshoot a scenario in which pods remain in a pending state.
ms.date: 2026-01-12T00:00:00.0000000Z
ms.editor: v-jsitser
ms.reviewer: chiragpa, rorylen, v-ryanberg
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: df9f54f8-dd1b-2c50-2486-228c42ba4d72
document_version_independent_id: df9f54f8-dd1b-2c50-2486-228c42ba4d72
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-pods-remain-pending-state-scenario.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/troubleshoot-pods-remain-pending-state-scenario
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-pods-remain-pending-state-scenario.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: e4f4a18f-d9ed-c3c9-debf-0fe62432b47f
---

# Troubleshoot Pods Remain in a Pending State Scenario - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot a scenario in which pods remain in the **Pending** state.

## Symptoms

You run `kubectl describe pod` for a pod, and the pod remains in the **Pending** state. When this issue occurs, the **Event** section displays **pod didn't trigger scale-up (it wouldn't fit if a new node is added)**. Additionally, the cluster-autoscaler doesn’t scale up the node count.

## Cause

These symptoms indicate one or more of the following situations:

- Even if the cluster-autoscaler adds a node, the pod can’t be put onto the new node. This condition occurs because the pod's resource requests exceed the maximum resources that are available on the node.
- The node is missing a resource that the pod requires (such as a Graphics Processing Unit (GPU)).
- The pod has affinity or topology constraints, and the new nodes don’t meet these requirements.

## Resolution

Review the pod resource request configuration (for example CPU, memory, or GPU), and compare it with the node size. To make sure that pod placement can occur, you might have to adjust the node size or type, or adjust the resource request configuration for the pod.

If you rule out a resource constraint, make sure that affinity or taints aren't preventing scheduling.