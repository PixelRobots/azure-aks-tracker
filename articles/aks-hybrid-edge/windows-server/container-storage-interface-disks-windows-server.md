---
layout: Conceptual
title: Use Container Storage Interface (CSI) disk drivers in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/container-storage-interface-disks-windows-server
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
description: Learn how to use Container Storage Interface (CSI) drivers to manage disks in AKS Hybrid and Edge on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.custom: windows-server
locale: en-us
document_id: 43cb448b-60c9-652c-5c8a-8aecea3b2e7f
document_version_independent_id: a2f16bf8-91b2-49e7-31fe-2c2b8eca694d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/container-storage-interface-disks-windows-server.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/container-storage-interface-disks-windows-server
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/container-storage-interface-disks-windows-server.md
platformId: fab3fd98-9ac3-9778-4008-c414bd7c1524
---

# Use Container Storage Interface (CSI) disk drivers in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to use Container Storage Interface (CSI) built-in storage classes to dynamically create disk persistent volumes and create custom storage classes in AKS Hybrid and Edge.

## Overview of CSI in AKS on Windows Server

The Container Storage Interface (CSI) is a standard for exposing arbitrary block and file storage systems to containerized workloads on Kubernetes. By using CSI, AKS Hybrid and Edge can write, deploy, and iterate plug-ins to expose new storage systems. CSI can also improve existing ones in Kubernetes without having to touch the core Kubernetes code and then wait for its release cycles.

The disk and file CSI drivers used by AKS are [CSI specification](https://github.com/container-storage-interface/spec/blob/master/spec.md)-compliant drivers.

The CSI storage driver support on AKS allows you to use:

- AKS disks that you can use to create a Kubernetes *DataDisk* resource. These are mounted as *ReadWriteOnce*, so they're only available to a single pod at a time. For storage volumes that can be accessed by multiple pods simultaneously, use [AKS files](../local/hyperconverged/container-storage-interface-files).
- AKS files that you can use to mount an SMB or NFS share to pods. These are mounted as *ReadWriteMany*, so you can share data across multiple nodes and pods. They can also be mounted as *ReadWriteOnce* based on the PVC (persistent volume claim) specification.

## Dynamically create disk persistent volumes using built-in storage class

A *storage class* is used to define how a unit of storage is dynamically created with a persistent volume. For more information about how to use storage classes, see [Kubernetes storage classes](https://kubernetes.io/docs/concepts/storage/storage-classes/).

In AKS, the default storage class uses CSI to create VHDX-backed volumes. The reclaim policy ensures that the underlying VHDX is deleted when the persistent volume that used it is deleted. The storage class also configures the persistent volumes to be expandable; you just need to edit the persistent volume claim with the new size.

To use this storage class, create a [Persistent Volume Claim (PVC)](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) and a respective pod that references and uses it. A PVC is used to automatically provision storage based on a storage class. A PVC can use one of the pre-created storage classes or a user-defined storage class to create a VHDX of the desired size. When you create a pod definition, the PVC is specified to request the desired storage.

## Create custom storage class for disks

The default storage class is suitable for most common scenarios. However, in some cases, you may want to create your own storage class that stores PVs at a particular location mapped to a specific performance tier.

If you have Linux workloads (pods), you must create a custom storage class with the parameter `fsType: ext4`. This requirement applies to Kubernetes versions 1.19 and 1.20 or later. The following example shows a custom storage class definition with `fsType` parameter defined:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aks-hci-disk-custom
parameters:
  blocksize: "33554432"
  container: SqlStorageContainer
  dynamic: "true"
  group: clustergroup-summertime
  hostname: TESTPATCHING-91.sys-sqlsvr.local
  logicalsectorsize: "4096"
  physicalsectorsize: "4096"
  port: "55000"
  fsType: ext4
provisioner: disk.csi.akshci.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
```

If you create a custom storage class, you can specify the location in which you want to store PVs. If the underlying infrastructure is Azure Local, this new location could be a volume that's backed by high-performing SSDs/NVMe, or a cost-optimized volume backed by HDDs.

Creating a custom storage class is a two-step process:

1. Create a new storage container using the following [New-AksHciStorageContainer](/en-us/azure/aks/aksarc/reference/ps/new-akshcistoragecontainer) PowerShell command:

    ```powershell
    New-AksHciStorageContainer -Name <e.g. customStorageContainer> -Path <shared storage path>
    ```

    Check whether the new storage container is created by running the following [Get-AksHciStorageContainer](/en-us/azure/aks/aksarc/reference/ps/get-akshcistoragecontainer) PowerShell command:

    ```powershell
    Get-AksHciStorageContainer -Name "customStorageContainer"
    ```
2. Create a new custom storage class using the new storage path.

    1. Create a file named **sc-aks-hci-disk-custom.yaml**, and then copy the manifest from the following YAML file. The storage class is the same as the default storage class except with the new `container`. Use the `storage container name` created in the previous step for `container`. For `group` and `hostname`, query the default storage class by running `kubectl get storageclass default -o yaml`, and then use the values that are specified:

        ```yaml
        kind: StorageClass
        apiVersion: storage.k8s.io/v1
        metadata:
         name: aks-hci-disk-custom
        provisioner: disk.csi.akshci.com
        parameters:
         blocksize: "33554432"
         container: <storage container name>
         dynamic: "true"
         group: <e.g clustergroup-akshci> # same as the default storageclass
         hostname: <e.g. ca-a858c18c.ntprod.contoso.com> # same as the default storageclass
         logicalsectorsize: "4096"
         physicalsectorsize: "4096"
         port: "55000"
         fsType: ext4 # refer to the note above to determine when to include this parameter
        allowVolumeExpansion: true
        reclaimPolicy: Delete
        volumeBindingMode: Immediate
        ```
    2. Create the storage class with the [kubectl apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply/) command and specify your **sc-aks-hci-disk-custom.yaml** file:

        ```azurecli
        $ kubectl apply -f sc-aks-hci-disk-custom.yaml
        storageclass.storage.k8s.io/aks-hci-disk-custom created
        ```