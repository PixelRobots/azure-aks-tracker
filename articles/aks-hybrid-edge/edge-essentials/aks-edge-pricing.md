---
layout: Conceptual
title: About AKS Edge Essentials pricing | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-pricing
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
description: Learn about AKS Edge Essentials pricing details.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: overview
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-overview, edge-essentials
locale: en-us
document_id: 0a5360ae-a3a8-9c88-fd51-b94db43ecdb1
document_version_independent_id: 11b65e48-b309-5ddd-d61a-d3ffc9256a1c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-pricing.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-pricing
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-pricing.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c21d0a62-47cf-4452-bd24-e1ed14abbeda
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f43eaf81-15c1-41e2-95b2-89fb1560c563
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: af819e8f-21ee-01a2-bdbe-a3b8e811ada3
---

# About AKS Edge Essentials pricing | Microsoft Learn

AKS Edge Essentials can be licensed via one of the following options:

- Azure subscription-based model
- Volume licensing model (available from April 2023)

You can [review the details of each of the approaches](aks-edge-licensing). This article focuses on the Azure subscription-based approach. You can run the AKS Edge Essentials subscription-based Kubernetes offering on Windows Pro, Windows Enterprise, Windows IoT Enterprise, or Windows Server-based devices. You can download and install AKS Edge Essentials on your existing or new hardware that will be deployed on the edge. The pricing is based on usage and requires an Azure subscription, which you can obtain for free.

The billing unit model is based on a device, which can be a physical or virtual device on which AKS Edge Essentials is installed. After you install AKS Edge Essentials on your device and connect your cluster to Azure Arc, a per-device per-month rate is applied. The snapshot of usage is reported during the following month on a date that's one day prior to the date the Azure Arc-enabled Kubernetes cluster was created. For example, if the Azure Arc-enabled Kubernetes cluster was created on March 6 with AKS Edge Essentials, the number of devices included in this cluster is captured and submitted for billing on April 5. If you have one device in your cluster when the usage is posted on April 5, you'll be billed for one device usage for this Azure Arc-enabled Kubernetes cluster resource by AKS Edge Essentials.

## Pricing details

AKS Edge Essentials pricing is based on the US currency list pricing with no discounts applied.

For detailed pricing information, see the [AKS Edge Essentials pricing details page](https://aka.ms/AKSEdgeEssentialsPricing). The list price for AKS Edge Essentials includes the following components:

- A Microsoft-managed, lightweight, CNCF-conformant K8S and K3S distribution.
- License to use one Microsoft-managed Linux (CBL-Mariner) VM container host for use with Linux containers on AKS Edge Essentials.
- Azure Arc-enabled Kubernetes at no extra charge and the following items:
    - Inventory, grouping, and tagging in Azure.
    - Deployment of apps and configuration with GitOps: included at no extra charge (normally, the initial six vCPUs are free, and then afterwards, the charge is per vCPU per month).

When you run the Azure Arc-enabled Kubernetes clusters on the following products, the Kubernetes configuration capability (deployment of apps and configurations with GitOps) is included at no extra charge:

- Windows 11 Enterprise
- Windows 11 Enterprise N
- Windows 11 IoT Enterprise
- Windows 11 Pro
- Windows 10 Enterprise
- Windows 10 Enterprise N
- Windows 10 Enterprise LTSC
- Windows 10 Enterprise N LTSC
- Windows 10 IoT Enterprise
- Windows 10 IoT Enterprise LTSC
- Windows 10 Pro
- Windows Server 2022
- Windows Server 2022 Datacenter
- Windows Server 2022 Standard
- Windows Server 2019
- Windows Server 2019 Datacenter
- Windows Server 2019 Standard