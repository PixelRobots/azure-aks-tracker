---
layout: Conceptual
title: Pods are created in the user namespaces - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/pods-created-user-namespaces
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: mosbahmajed
ms.author: momajed
ms.topic: troubleshooting-problem-resolution
description: Learn why AKS allows pods in user namespaces with system-critical priority classes, and use this guide to confirm your cluster isn't at risk.
ms.date: 2024-05-13T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: cssakscic, v-rekhanain, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: 38338d85-1100-d054-c678-d199b73c639f
document_version_independent_id: 38338d85-1100-d054-c678-d199b73c639f
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/pods-created-user-namespaces.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/pods-created-user-namespaces
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/pods-created-user-namespaces.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c8b1a640-8717-b6b1-aef2-2e5b56308b39
---

# Pods are created in the user namespaces - Azure | Microsoft Learn

## Summary

This article explains why AKS can create pods in user namespaces when system-critical priority classes are used, and clarifies why this behavior isn't a security risk.

## Symptoms

When you use the Azure Policy Add-on for AKS and try to create pods by adding the `system-cluster-critical` and `system-node-critical` priority class names in the pod manifests, AKS unexpectedly accepts these names and creates the pods in the user namespaces.

## Cause

This is expected behavior. The two system-critical priority classes, `system-cluster-critical` and `system-node-critical`, already exist in the system. Creating pods that have these priority class names in the pod manifests is allowed, even in user namespaces.

## Solution

No action is required. The ability to specify the `system-cluster-critical` and `system-node-critical` priority class names is user namespaces is intentional. This ability isn't a security risk by design.

If you have concerns about security, consider reviewing other aspects of your cluster's configuration to enhance security measures.

## Resources

- [Pod priority and preemption](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/)