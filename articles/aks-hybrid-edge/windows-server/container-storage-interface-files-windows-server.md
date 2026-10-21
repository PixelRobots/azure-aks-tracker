---
layout: Conceptual
title: Use Container Storage Interface (CSI) file drivers in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/container-storage-interface-files-windows-server
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
description: Learn how to use Container Storage Interface (CSI) drivers to manage files in AKS on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.custom: sfi-ropc-nochange, windows-server
locale: en-us
document_id: 52bc48a7-0103-8622-1e94-52c58e048bd4
document_version_independent_id: 93f6fb3c-a021-2167-80e0-2188f4c47c8a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/container-storage-interface-files-windows-server.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/container-storage-interface-files-windows-server
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/container-storage-interface-files-windows-server.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: c008f13e-8567-f1a5-7c39-1930bb591230
---

# Use Container Storage Interface (CSI) file drivers in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to use Container Storage Interface (CSI) drivers for files to mount a Server Message Block (SMB) or NFS shares when multiple nodes need concurrent access to the same storage volume in AKS on Windows Server.

## Overview of CSI in AKS on Windows Server

The Container Storage Interface (CSI) is a standard for exposing arbitrary block and file storage systems to containerized workloads on Kubernetes. By using CSI, AKS Hybrid and Edge can write, deploy, and iterate plug-ins to expose new storage systems. CSI can also improve existing ones in Kubernetes without having to touch the core Kubernetes code and then wait for its release cycles.

The disk and file CSI drivers used by AKS are [CSI specification](https://github.com/container-storage-interface/spec/blob/master/spec.md)-compliant drivers.

The CSI storage driver support on AKS allows you to use:

- AKS disks that you can use to create a Kubernetes *DataDisk* resource. These are mounted as *ReadWriteOnce*, so they're only available to a single pod at a time. For storage volumes that can be accessed by multiple pods simultaneously, use [AKS files](../local/hyperconverged/container-storage-interface-files).
- AKS files that you can use to mount an SMB or NFS share to pods. These are mounted as *ReadWriteMany*, so you can share data across multiple nodes and pods. They can also be mounted as *ReadWriteOnce* based on the PVC (persistent volume claim) specification.

## Use persistent volumes using ReadWriteMany CSI drivers

If multiple nodes need concurrent access to the same storage volumes in AKS, you can use CSI drivers for files to mount SMB or NFS shares as **ReadWriteMany**. You must provision the SMB or NFS shares in advance.

### Use SMB drivers

1. Make sure the SMB driver is deployed. Deploy the driver using the following [Install-AksHciCsiSmb](/en-us/azure/aks/aksarc/reference/ps/install-akshcicsismb) PowerShell command:

    ```powershell
    Install-AksHciCsiSmb -clusterName mycluster
    ```
2. Create Kubernetes secrets to store the credentials required to access SMB shares by running the following command:

    ```console
    kubectl create secret generic smbcreds --from-literal username=$username --from-literal password=$password --from-literal domain=$domain
    ```
3. Create a storage class using `kubectl` to create a new SMB storage class with the following manifest:

    ```yaml
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: smb-csi
    provisioner: smb.csi.akshci.com
    parameters:
       source: \\smb-server\share
       csi.storage.k8s.io/node-stage-secret-name: "smbcreds"
       csi.storage.k8s.io/node-stage-secret-namespace: "default"
    reclaimPolicy: Retain  # only Retain is supported
    volumeBindingMode: Immediate
    mountOptions:
      - dir_mode=0777
      - file_mode=0777
      - uid=1001
      - gid=1001
    ```

### Use NFS drivers

1. Deploy the driver using the following [Install-AksHciCsiSmb](/en-us/azure/aks/aksarc/reference/ps/install-akshcicsismb) PowerShell command:

    ```powershell
    Install-AksHciCsiNfs -clusterName mycluster
    ```
2. Create an NFS storage class using the following manifest:

    ```yaml
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: nfs-csi
    provisioner: nfs.csi.akshci.com
    parameters:
      server: nfs-server.default.svc.cluster.local # NFS server endpoint
      share: / # NFS share path
    reclaimPolicy: Retain
    volumeBindingMode: Immediate
    mountOptions:
      - hard
      - nfsvers=4.1
    ```

### To uninstall SMB or NFS drivers

Use the following PowerShell commands to uninstall either the SMB or NFS drivers:

```powershell
Uninstall-AksHciCsiSMB -clusterName <clustername>
Uninstall-AksHciCsiNFS -clusterName <clustername>
```