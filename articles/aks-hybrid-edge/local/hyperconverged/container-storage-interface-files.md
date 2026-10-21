---
layout: Conceptual
title: Use Container Storage Interface (CSI) file drivers in AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/container-storage-interface-files
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
description: Learn how to use Container Storage Interface (CSI) drivers to manage files in AKS.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: sfi-ropc-nochange, hyperconverged
locale: en-us
document_id: f0637fa6-057c-0fdb-8771-0963883c9b48
document_version_independent_id: 98a64f3e-5560-a3d1-4333-e48c393bda49
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/container-storage-interface-files.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/container-storage-interface-files
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/container-storage-interface-files.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: 5dfac7d6-ed4e-b9d5-bafb-61a4a1c3991b
---

# Use Container Storage Interface (CSI) file drivers in AKS Hybrid and Edge | Microsoft Learn

> 
> Applies to: AKS on Azure Local

This article describes how to use Container Storage Interface (CSI) drivers for files to mount a Server Message Block (SMB) or NFS shares when multiple nodes need concurrent access to the same storage volume in AKS Hybrid and Edge.

## Overview of CSI in AKS

The Container Storage Interface (CSI) is a standard for exposing arbitrary block and file storage systems to containerized workloads on Kubernetes. By using CSI, AKS Hybrid and Edge can write, deploy, and iterate plug-ins to expose new storage systems. CSI can also improve existing ones in Kubernetes without having to touch the core Kubernetes code and then wait for its release cycles.

The disk and file CSI drivers used by AKS are [CSI specification](https://github.com/container-storage-interface/spec/blob/master/spec.md)-compliant drivers.

The CSI storage driver support on AKS allows you to use:

- AKS disks that you can use to create a Kubernetes *DataDisk* resource. These are mounted as *ReadWriteOnce*, so they're only available to a single pod at a time. For storage volumes that can be accessed by multiple pods simultaneously, use [AKS files](container-storage-interface-files).
- AKS files that you can use to mount an SMB or NFS share to pods. These are mounted as *ReadWriteMany*, so you can share data across multiple nodes and pods. They can also be mounted as *ReadWriteOnce* based on the PVC (persistent volume claim) specification.

## Use persistent volumes using ReadWriteMany CSI drivers

If multiple nodes need concurrent access to the same storage volumes in AKS, you can use CSI drivers for files to mount SMB or NFS shares as **ReadWriteMany**. You must provision the SMB or NFS shares in advance.

### Use SMB drivers

1. Make sure the SMB driver is deployed. The SMB CSI driver is installed by default when you create a Kubernetes cluster using the `az aksarc create` command. If you create the AKS cluster using the Azure portal, an Azure Resource Manager (ARM) template, or Terraform, the SMB CSI driver is not installed by default. You must enable the SMB driver on the AKS cluster. The equivalent Azure CLI command to update an existing AKS cluster and enable SMB is:

    ```azurecli
    az aksarc update -n $aksclustername -g $resource_group --enable-smb-driver
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

1. Make sure the SMB driver is deployed. The SMB CSI driver is installed by default when you create a Kubernetes cluster using the `az aksarc create` command. If you create the AKS cluster using the Azure portal, an Azure Resource Manager (ARM) template, or Terraform, the SMB CSI driver is not installed by default. You must enable the SMB driver on the AKS cluster. The equivalent Azure CLI command to update an existing AKS cluster and enable SMB is:

    ```azurecli
    az aksarc update -n $aksclustername -g $resource_group --enable-nfs-driver
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

Use the following Azure CLI commands to uninstall either the SMB or NFS drivers:

```azurecli
az aksarc update -n $aksclustername -g $resource_group --disable-smb-driver
az aksarc update -n $aksclustername -g $resource_group --disable-nfs-driver
```