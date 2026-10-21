---
layout: Conceptual
title: Troubleshooting overview for Azure Kubernetes Service on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/troubleshoot-overview
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
description: An overview for troubleshooting issues encountered when using Azure Kubernetes Service on Windows Server.
author: davidsmatlak
ms.topic: troubleshooting
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2026-07-27T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: windows-server
locale: en-us
document_id: 322ba70c-74df-a0cf-3cd1-4f1a798d61c4
document_version_independent_id: e8a739ce-745b-4bdd-9bee-b524c0c58e82
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/troubleshoot-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/troubleshoot-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/troubleshoot-overview.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: f3558cda-4218-d7cd-813d-dd28701e9a25
---

# Troubleshooting overview for Azure Kubernetes Service on Windows Server | Microsoft Learn

This overview describes how to find solutions for issues you encounter when using Azure Kubernetes Service (AKS) on Windows Server. Known issues and errors topics are organized by functional area. You can use the links provided in this topic to find the solutions and workarounds to resolve them.

For some troubleshooting operations, you might need to use a secure SSH connection to access Windows or Linux worker nodes. An SSH connection provides secure access to the nodes for maintenance, log collection, and troubleshooting. For more information, see [Connect with SSH to Windows or Linux worker nodes for maintenance and troubleshooting](ssh-connection).

## View logs to troubleshoot an issue

Logs are an important method to collect and review data from many sources that can provide insights into your environment for troubleshooting purposes. AKS on Windows Server includes [PowerShell cmdlets to collect and view logs](/en-us/azure/aks/aksarc/view-logs), and you can also [collect and review kubelet logs](/en-us/azure/aks/aksarc/get-kubelet-logs).

Note

If you can't resolve the problem, [open a support issue](../local/hyperconverged/help-support).