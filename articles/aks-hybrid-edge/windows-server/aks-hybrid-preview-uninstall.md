---
layout: Conceptual
title: Before you begin - uninstall the AKS cluster provisioning preview | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/aks-hybrid-preview-uninstall
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
description: Learn how to uninstall the AKS cluster provisioning from Azure preview.
ms.topic: overview
ms.custom: devx-track-azurecli, windows-server
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: guanghu
ms.lastreviewed: 2024-01-30T00:00:00.0000000Z
locale: en-us
document_id: 8f22aaff-48bd-ba5b-d3c5-e823e101d31b
document_version_independent_id: 75088c32-6f03-73d0-8ba2-12a82d0a25c7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/aks-hybrid-preview-uninstall.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/aks-hybrid-preview-uninstall
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/aks-hybrid-preview-uninstall.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: 85bd0e11-de6f-d47e-45c6-1136ebeebf67
---

# Before you begin - uninstall the AKS cluster provisioning preview | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This step is only required if you installed the AKS cluster provisioning from Azure preview. The preview ended with the release of [AKS on Azure Local](../aks-overview). This article describes the steps to uninstall the preview bits before upgrading to AKS.

## Step 1: delete all preview AKS clusters and Azure vnets created using Az CLI

```azurecli
az akshybrid delete --resource-group <resource group name> --name <kubernetes cluster name>
az akshybrid vnet delete --resource-group <resource group name> --name <vnet name>
```

## Step 2: delete the custom location

```azurecli
az customlocation delete --name <custom location name> --resource-group <resource group name>
```

## Step 3: delete the cluster extension

```azurecli
az k8s-extension delete --resource-group <resource group name> --cluster-name <arc appliance name> --cluster-type appliances --name <aks extension name>
```

## Step 4: delete the Arc Resource Bridge

```azurecli
az arcappliance delete hci --config-file "<path to working directory>\hci-appliance.yaml"
```

## Step 5: delete the ArcHCI config files

```powershell
Remove-ArcHciAksConfigFiles -workDirectory <path to working directory>
```