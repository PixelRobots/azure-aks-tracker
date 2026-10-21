---
layout: Conceptual
title: AKS on Azure Local issues after deleting storage volumes | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/delete-storage-volume
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
description: Learn how to mitigate issues after deleting storage volumes.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: troubleshooting
ms.date: 2026-09-01T00:00:00.0000000Z
ms.reviewer: guanghu
ms.lastreviewed: 2025-07-18T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: af4f1c38-ae4b-f0f7-9487-3f68b13761a0
document_version_independent_id: 14fe7688-d47d-0ccb-8b11-87661ec70274
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/delete-storage-volume.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/delete-storage-volume
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/delete-storage-volume.md
platformId: 7c15aa38-08a8-0071-811a-2de6d05052a3
---

# AKS on Azure Local issues after deleting storage volumes | Microsoft Learn

This article describes how to mitigate cluster issues if a storage volume is deleted.

## Symptoms

AKS workload data is stored on Azure Local storage volumes, including the AKS node disks and persistent volumes of data disks. If the storage volume is accidentally deleted, the AKS cluster doesn't work properly, as its data is removed as well.

## Workaround

If the storage volume is accidentally deleted, you can mitigate the issue by recreating the storage path using the Azure CLI. For more information, see [Create storage path for Azure Local](/en-us/azure/azure-local/manage/create-storage-path). For example:

```azurecli
$storagepathname="<Storage path name>"
$path="<Path on the disk to cluster shared volume>"
$subscription="<Subscription ID>"
$resource_group="<Resource group name>"
$customLocName="<Custom location of your Azure Local>"
$customLocationID="/subscriptions/<Subscription ID>/resourceGroups/$resource_group/providers/Microsoft.ExtendedLocation/customLocations/$customLocName"
$location="<Azure region where the system is deployed>"

az stack-hci-vm storagepath create --resource-group $resource_group --custom-location $customLocationID --name $storagepathname --path $path
az stack-hci-vm storagepath update --resource-group $resource_group --custom-location $customLocationID --name $storagepathname --location $location
```

Once the storage path is recreated, the [MOC service](../../windows-server/concepts-node-networking#microsoft-on-premises-cloud-service) automatically re-downloads the required **MocGalleryImages**.