---
layout: Conceptual
title: Deploy Azure Arc-enabled data services in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/deploy-arc-data-services
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
description: Learn how to deploy Azure Arc-enabled data services in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: rbaziwane
ms.custom: windows-server
locale: en-us
document_id: bebad710-944b-5c69-48da-88424c1ca2e5
document_version_independent_id: a8913f04-6718-2e54-3129-c5f177b88a87
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/deploy-arc-data-services.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/deploy-arc-data-services
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/deploy-arc-data-services.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: 163f4f72-01b5-ac1b-b12b-8478d281424f
---

# Deploy Azure Arc-enabled data services in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article provides a checklist of prerequisites you can follow to deploy Azure Arc-enabled data services on Azure Kubernetes Service (AKS) on Windows Server. You must install [AKS on Windows Server](kubernetes-walkthrough-powershell) before using the checklist.

## Prerequisites for AKS on Windows Server

- [Provision a workload cluster with only Linux node pools](/en-us/azure/aks/aksarc/use-node-pools).
- Configure storage [using the disk Container Storage Interface (CSI) drivers](../local/hyperconverged/container-storage-interface-disks#create-custom-storage-class-for-disks).

## Prerequisites for Azure Arc-enabled data services

- [Connect your clusters to Azure Arc for Kubernetes](connect-to-arc).

Confirm whether the custom location is enabled on your Kubernetes cluster by running the following command and checking for `customLocation: enabled: true`:

```console
helm get values azure-arc
```

If the custom location isn't enabled, run the following CLI command:

```azurecli
az connectedk8s enable-features -n <clusterName> -g <resourceGroupName> --features cluster-connect custom-locations
```

- [Create and manage custom locations on Azure Arc-enabled Kubernetes](/en-us/azure/azure-arc/kubernetes/custom-locations) (for direct connectivity mode only).