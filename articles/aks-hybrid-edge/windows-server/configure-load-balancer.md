---
layout: Conceptual
title: Create and use load balancer with Azure Kubernetes Service in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/configure-load-balancer
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
description: Learn how to create and use load balancer with Azure Kubernetes Service (AKS) in AKS.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2024-01-30T00:00:00.0000000Z
ms.reviewer: rbaziwane
ms.custom: windows-server
locale: en-us
document_id: 465a50e2-a057-785c-dab5-db7b1c91b889
document_version_independent_id: a40ec056-4b13-f8ef-c345-60ab6e0b3860
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/configure-load-balancer.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/configure-load-balancer
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/configure-load-balancer.md
platformId: 2dab8e5c-118f-4f8a-4c33-680b34ee1149
---

# Create and use load balancer with Azure Kubernetes Service in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to configure **HAProxy** as your load balancer for a workload cluster in AKS. For custom load balancer integration, see [Create and use a custom load balancer](configure-custom-load-balancer).

In AKS, the load balancer is deployed as a virtual machine (VM) running Linux and **HAProxy + KeepAlive** to provide load balanced services for the workload clusters. AKS load balances requests to the Kubernetes API server, and manages traffic to application services.

## Before you begin

- Install [AKS](kubernetes-walkthrough-powershell), and provide a range of virtual IP addresses for the load balancer during the network configuration step.
- Make sure you have enough memory and storage to create a new virtual machine and have virtual IP addresses to assign to application services.

## Configure load balancer

To configure a load balancer, use [New-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/new-akshcicluster) to provision a new cluster as shown in the following example:

```powershell
New-AksHciCluster -name mycluster -loadBalancerVmSize Standard_A4_v2
```

This example creates a new workload cluster with a load balancer deployed as a virtual machine running HAProxy to manage traffic for your applications.