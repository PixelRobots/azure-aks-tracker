---
layout: Conceptual
title: Recommended and useful mountOptions settings on Azure Files - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/mountoptions-settings-azure-files
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
description: Learn recommended mountOptions settings for Azure Files storage classes in AKS to improve performance and reliability, and use them to optimize your deployments.
ms.date: 2026-07-24T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Storage
locale: en-us
document_id: 58fc33f5-1b13-a2df-5eb6-a1b82cab873a
document_version_independent_id: 58fc33f5-1b13-a2df-5eb6-a1b82cab873a
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/storage/mountoptions-settings-azure-files.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/storage/mountoptions-settings-azure-files
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/storage/mountoptions-settings-azure-files.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/01a89bec-e73f-4ce0-a00a-ae34ad62e5fe
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/50038ab9-5431-4515-9dfc-c24291ef4fce
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 421462e7-53f1-2f03-2003-5678024d07ef
---

# Recommended and useful mountOptions settings on Azure Files - Azure | Microsoft Learn

## Summary

This article explains the recommended mountOptions settings for Azure Files storage classes. Use these settings to provision Kubernetes storage with better performance and reliability.

## Recommended settings

Use the following `mountOptions` settings for Server Message Block (SMB) and Network File System (NFS) shares:

- **SMB shares**

    ```yaml
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: azurefile-csi
    provisioner: file.csi.azure.com
    allowVolumeExpansion: true
    parameters:
      skuName: Premium_LRS  # available values: Premium_LRS, Premium_ZRS, Standard_LRS, Standard_GRS, Standard_ZRS, Standard_RAGRS, Standard_RAGZRS
    reclaimPolicy: Delete
    volumeBindingMode: Immediate
    mountOptions:
      - dir_mode=0777  # modify this permission if you want to enhance the security
      - file_mode=0777 # modify this permission if you want to enhance the security
      - mfsymlinks    # support symbolic links
      - cache=strict  # https://linux.die.net/man/8/mount.cifs
      - nosharesock  # reduces probability of reconnect race
      - actimeo=30  # reduces latency for metadata-heavy workload
      - nobrl  # disable sending byte range lock requests to the server and for applications which have challenges with posix locks
    ```

These permissions can grant broader permissions than applications require. Consider using a least-privilege approach first, like the following examples:

- `dir_mode=0755`, `file_mode=0755`, `uid=1000`, and `gid=1000`.
- `dir_mode=0777`, `file_mode=0777`, `uid=0`, `gid=0` might be more appropriate when applications require root or broader access.
- **NFS shares**

    ```yaml
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: azurefile-csi-nfs
    provisioner: file.csi.azure.com
    parameters:
      protocol: nfs
      skuName: Premium_LRS     # available values: Premium_LRS, Premium_ZRS
    reclaimPolicy: Delete
    volumeBindingMode: Immediate
    allowVolumeExpansion: true
    mountOptions:
      - nconnect=4  # improves performance by enabling multiple connections to share
      - noresvport  # improves availability
      - actimeo=30  # reduces latency for metadata-heavy workloads
    ```

For more information on `rsize` and `wsize` options for NFS, see [Optimize read and write size options](/en-us/azure/aks/create-volume-azure-files#optimize-read-and-write-size-options).

The `actimeo` and `nconnect` options are analyzed in depth in the following Microsoft documentation:

- [Recommended mount options](/en-us/azure/storage/files/nfs-large-directories#recommended-mount-options)
- [NFS nconnect](/en-us/azure/storage/files/nfs-performance#nfs-nconnect)

Note

The location for configuring mount options (`mountOptions`) depends on whether you provision dynamic or static persistent volumes. If you [dynamically provision a volume](/en-us/azure/aks/azure-csi-files-storage-provision#dynamically-provision-a-volume) by using a storage class, specify the mount options on the storage class object (`kind: StorageClass`). If you [statically provision a volume](/en-us/azure/aks/azure-csi-files-storage-provision#statically-provision-a-volume), specify the mount options on the `PersistentVolume` object (`kind: PersistentVolume`). If you [mount the file share as an inline volume](/en-us/azure/aks/azure-csi-files-storage-provision#mount-file-share-as-an-inline-volume), specify the mount options on the `Pod` object (`kind: Pod`).

## References

For Azure Files best practices, see [Provision Azure Files storage](/en-us/azure/aks/azure-csi-files-storage-provision#best-practices).