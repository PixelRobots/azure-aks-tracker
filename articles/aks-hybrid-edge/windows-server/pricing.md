---
layout: Conceptual
title: Azure Kubernetes Service (AKS) on Windows Server pricing details | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/pricing
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
description: Learn about detailed pricing information for AKS on Windows Server.
ms.topic: concept-article
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.lastreviewed: 2023-05-31T00:00:00.0000000Z
ms.custom: windows-server
locale: en-us
document_id: 875821e2-2152-3b09-e0da-9f1018ddb7c7
document_version_independent_id: ba4169d2-5fca-18cd-ce54-3a84eda7717e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/pricing.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/pricing
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/pricing.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: 84351ea8-241c-0915-df45-9c0e9daa76f2
---

# Azure Kubernetes Service (AKS) on Windows Server pricing details | Microsoft Learn

> 
> Applies to: AKS on Windows Server

Azure Kubernetes Service (AKS) on Windows Server is a subscription-based Kubernetes offering that you can run on Windows Server Hyper-V clusters. You can download and install AKS on your existing hardware either in your own on-premises data center or on the edge. The pricing is based on usage and requires an Azure subscription, which you can get for free. The billing unit is a virtual core or vCPU. All initial AKS deployments include a free 60-day evaluation period. After the evaluation period, a pay-as-you-go rate per vCPU (of running worker nodes) per day applies.

Important

Starting in June 2023, the 60-day evaluation period is a one-time benefit per subscription. After the evaluation period, a pay-as-you-go rate per vCPU applies. The evaluation period no longer resets when you reinstall AKS on Windows Server. This change aligns with our existing pricing guidelines and helps us continue providing high-quality services.

## Pricing details

Azure pricing for running workloads on AKS on Windows Server is based on US currency list pricing with:

- Pay-as-you-go pricing
- D-series general purpose VM sizes (D2s v4, D4s V4, and D8s V4)
- Standard HDD
- No uptime SLA (included in the support level)

In addition, AKS pricing is based on the US currency list pricing with no discounts applied. The monthly price estimates are based on 730 hours of usage.

For detailed pricing information, see the [AKS pricing details](https://azure.microsoft.com/pricing/details/azure-stack/aks-hci/#overview) page. The list price for AKS includes the following features:

- Kubernetes control plane and load balancer nodes:

    - No charge for Arc-enabled AKS management cluster usage.
    - No charge for workload cluster control plane and load balancer nodes.
- Linux (CBL-Mariner) container hosts:

    - Pricing doesn't include Windows container hosts as they are licensed separately through regular licensing channels.
    - Windows Server Standard: Unlimited Windows containers and two Hyper-V containers.
    - Windows Server Datacenter: Unlimited Windows and Hyper-V containers.
- Azure Arc-enabled Kubernetes at no extra charge and the following items:

    - **Inventory, grouping, and tagging** in Azure.
    - **Deployment of apps and configurations with GitOps**: Included at no extra charge (normally, the initial six vCPUs are free, and then afterwards, the charged per vCPU per month).
    - **Azure Policy for Kubernetes**: Included at no extra charge (normally, the charge per vCPU per cluster for each month).
- If you enable hyper-threading on the physical computer, this feature reduces the measured vCPU count by 50 percent.

Note

Running Windows Server containers on AKS requires a Windows Server license. You can acquire the license separately through regular licensing channels, or you can add it to the cost of running a Windows virtual machine on Azure. For users with Windows Server Software Assurance, [Azure Hybrid Benefits](azure-hybrid-benefit-22h2) might apply, thus reducing or eliminating the Windows Server license fees.

## Impact of hyper-threading on pricing for AKS

If you enable hyper-threading on your physical computer, AKS also enables hyper-threading on the worker nodes. When you enable hyper-threading, it effectively halves the number of virtual cores needed in each worker node.

[![Screenshot showing how pricing for AKS is affected by hyper-threading.](../media/pricing/hyper-thread-hyperv-manager.png)](../media/pricing/hyper-thread-hyperv-manager.png#lightbox)