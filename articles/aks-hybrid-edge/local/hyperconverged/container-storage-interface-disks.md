---
layout: Conceptual
title: Use Container Storage Interface (CSI) disk drivers in AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/container-storage-interface-disks
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
description: Learn how to use Container Storage Interface (CSI) drivers to manage disks in AKS Hybrid and Edge.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.custom: hyperconverged
locale: en-us
document_id: 56b1fa7d-291d-354c-1729-3857b11c2cd0
document_version_independent_id: 91aebae0-54f6-9643-5527-4e930929ec8c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/container-storage-interface-disks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/container-storage-interface-disks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/container-storage-interface-disks.md
platformId: 21cf5707-0db7-9bfa-a61a-73281b6364a2
---

# Use Container Storage Interface (CSI) disk drivers in AKS Hybrid and Edge | Microsoft Learn

> 
> Applies to: AKS on Azure Local

This article describes how to use Container Storage Interface (CSI) built-in storage classes to dynamically create disk persistent volumes and create custom storage classes in AKS Hybrid and Edge.

## Overview of CSI in AKS Hybrid and Edge

The Container Storage Interface (CSI) is a standard for exposing arbitrary block and file storage systems to containerized workloads on Kubernetes. By using CSI, AKS Hybrid and Edge can write, deploy, and iterate plug-ins to expose new storage systems. CSI can also improve existing ones in Kubernetes without having to touch the core Kubernetes code and then wait for its release cycles.

The disk and file CSI drivers used by AKS are [CSI specification](https://github.com/container-storage-interface/spec/blob/master/spec.md)-compliant drivers.

The CSI storage driver support on AKS allows you to use:

- AKS disks that you can use to create a Kubernetes *DataDisk* resource. These are mounted as *ReadWriteOnce*, so they're only available to a single pod at a time. For storage volumes that can be accessed by multiple pods simultaneously, use [AKS files](container-storage-interface-files).
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

1. Create a new storage path using the `stack-hci-vm storagepath` cmdlets to create, show, and list the storage paths on your Azure Local cluster. For more information about storage path creation, see [storage path](/en-us/azure/azure-local/manage/create-storage-path).

    For `$path`, create a storage path named `$storagepathname`; for example, **C:\ClusterStorage\test-storagepath**:

    ```azurecli
    az stack-hci-vm storagepath create --resource-group $resource_group --custom-location $customLocationID --name $storagepathname --path $path
    ```

    Get the storage path resource ID:

    ```azurecli
    $storagepathID = az stack-hci-vm storagepath show --name $storagepathname --resource-group $resource_group --query "id" -o tsv 
    ```
2. Create a new custom storage class using the new storage path.

    1. Create a file named **sc-aks-hci-disk-custom.yaml**, and then copy the manifest from the following YAML file. The storage class is the same as the default storage class except with the new `container`. Use the `storage path ID` created in the previous step for `container`. For `group` and `hostname`, query the default storage class by running `kubectl get storageclass default -o yaml`, and then use the values that are specified:

        ```yaml
        kind: StorageClass
        apiVersion: storage.k8s.io/v1
        metadata:
         name: aks-hci-disk-custom
        provisioner: disk.csi.akshci.com
        parameters:
         blocksize: "33554432"
         container: <storage path ID>
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