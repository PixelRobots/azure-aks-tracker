---
layout: Conceptual
title: Troubleshoot Node Not Ready failures followed by recoveries in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/node-not-ready-then-recovers
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
description: Learn how to troubleshoot AKS Node Not Ready events that recover, identify root causes, and apply preventive actions to avoid repeat outages. Start now.
ms.date: 2026-10-27T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, momajed, v-leedennis, novictor, kaushika
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance
ai-usage: ai-assisted
locale: en-us
document_id: 80a9294c-a6e6-8d32-bb82-32766e0d7f11
document_version_independent_id: 80a9294c-a6e6-8d32-bb82-32766e0d7f11
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/node-not-ready-then-recovers.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/node-not-ready-then-recovers
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/node-not-ready-then-recovers.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: fcbd8f68-d1fd-a839-2e2c-cb497c56609e
---

# Troubleshoot Node Not Ready failures followed by recoveries in AKS - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot **Node Not Ready** failures in Azure Kubernetes Service (AKS) clusters that recover on their own, so you can find root causes and prevent repeat outages. When a node enters a **NotReady** state, it disrupts the application's functionality and causes it to stop responding. Typically, the node recovers automatically after a short period. However, to prevent recurring problems and maintain a stable environment, you need to understand the underlying causes so you can implement effective resolutions.

## Cause

The following scenarios can cause a **NotReady** state:

- The unavailability of the API server. This condition causes the readiness probe to fail. This failure prevents the pod from being attached to the service so that traffic is no longer forwarded to the pod instance.
- Virtual machine (VM) host faults. To determine whether VM host faults occurred, check the following information sources:
    - [AKS diagnostics](/en-us/azure/aks/concepts-diagnostics)
    - [Azure status](https://status.azure.com/)
    - Azure notifications (for any recent outages or maintenance periods)

## Resolution

To resolve this issue, follow these steps:

1. Run `kubectl describe node <node-name>` to review detailed information about the node's status. Look for any error messages or warnings that might indicate the root cause of the problem.
2. Check the API server availability by running the `kubectl get apiservices` command. Make sure that the readiness probe is correctly configured in the deployment YAML file.
3. Verify the node's network configuration to make sure that there are no connectivity problems.
4. Check the node's resource usage, like CPU, memory, and disk, to identify potential constraints. For more information, see [Monitor your Kubernetes cluster performance with Container insights](/en-us/azure/azure-monitor/containers/container-insights-analyze#view-performance-directly-from-a-cluster).

For further steps, see [Basic troubleshooting of Node Not Ready failures](node-not-ready-basic-troubleshooting).

## Prevention

To prevent this issue, take one or more of the following actions:

- Ensure that you pay for your service tier.
- Reduce the number of `watch` and `get` requests to the API server.