---
layout: Conceptual
title: Use Container Storage Interface (CSI) Drivers on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/csi-storage-drivers
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn about and deploy the Container Storage Interface (CSI) drivers for Azure Disks, Azure Files, and Azure Blob storage on your Azure Kubernetes Service (AKS) cluster to enable flexible and efficient storage solutions for your containerized applications.
ms.topic: how-to
ms.date: 2026-08-03T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-storage
zone_pivot_groups: csi-storage-drivers
locale: en-us
document_id: 476cdb12-8fd7-c8ee-9569-0babf19c7359
document_version_independent_id: 9f0d22ad-c673-46bd-2130-034940824ce5
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/csi-storage-drivers.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/csi-storage-drivers
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/csi-storage-drivers.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/ea957f26-244e-4bd1-9b19-105f0a0a73d6
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/85dd85bb-c2e5-412e-96b2-f2765a3fe51c
platformId: 778f69ca-9ab5-c979-01dd-af7fcedb0e78
---

# Use Container Storage Interface (CSI) Drivers on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

The Container Storage Interface (CSI) is a standard for exposing arbitrary block and file storage systems to containerized workloads on Kubernetes. When using CSI, Azure Kubernetes Service (AKS) can write, deploy, and iterate plug-ins to expose new or improve existing storage systems in Kubernetes without having to touch the core Kubernetes code and wait for its release cycles.

The CSI storage driver support on AKS allows you to natively use **Azure Disks**, **Azure Files**, or **Azure Blob storage** as persistent storage for your applications running on AKS.

Tip

If you want a fully managed solution for block-level access to data, consider using [Azure Container Storage](/en-us/azure/storage/container-storage/container-storage-introduction) instead of CSI drivers. Azure Container Storage integrates with Kubernetes so you can dynamically provision persistent volumes for stateful applications on Kubernetes clusters.

::: zone pivot="azure-disks,azure-files"

Important

Starting with Kubernetes version 1.21, AKS uses CSI drivers by default and enables CSI migration. Existing persistent volumes that use the in-tree `kubernetes.io/azure-disk` and `kubernetes.io/azure-file` drivers continue to function through CSI migration. *In-tree drivers* are storage drivers that are part of the core Kubernetes code, whereas CSI drivers are plug-ins.

Starting with Kubernetes version 1.26, AKS no longer supports creating volumes using the in-tree drivers for Azure Disks and Azure Files. Migrate to the corresponding `disk.csi.azure.com` and `file.csi.azure.com` CSI drivers. To review the migration options for your storage classes, see [Migrate from in-tree to CSI drivers](csi-migrate-in-tree-volumes).

::: zone-end

::: zone pivot="azure-disks"

## About Azure Disks CSI driver

The Azure Disks CSI driver is a [CSI specification](https://github.com/container-storage-interface/spec/blob/master/spec.md)-compliant driver used by AKS to manage the lifecycle of Azure Disk resources. With the Azure Disks CSI driver, you can create a Kubernetes *DataDisk* resource. Disks can use Azure Premium Storage, backed by high-performance SSDs, or Azure Standard Storage, backed by regular HDDs or Standard SSDs. For most production and development workloads, use Premium Storage. Azure Disks are mounted as *ReadWriteOnce* and are only available to one node in AKS. For storage volumes that can be accessed by multiple nodes simultaneously, use Azure Files.

## Features of Azure Disks CSI driver

In addition to in-tree driver features, Azure Disks CSI driver supports the following features:

- Performance improvements during concurrent disk attach and detach operations.
    - In-tree drivers attach or detach disks in serial, while CSI drivers attach or detach disks in batch. There's significant improvement when there are multiple disks attaching to one node.
- Premium SSD v1 and v2.
    - `PremiumV2_LRS` only supports `None` caching mode.
- Zone-redundant storage (ZRS) disk support.
    - `Premium_ZRS`, `StandardSSD_ZRS` disk types are supported. ZRS disk could be scheduled on the zone or nonzone node, without the restriction that disk volume should be colocated in the same zone as a given node. For more information, including which regions are supported, see [Zone-redundant storage for managed disks](/en-us/azure/virtual-machines/disks-redundancy).
- Create [snapshots of persistent volumes](create-volume-azure-disk#volume-snapshot-class-parameters-for-azure-disks).
- Create [volume clones](create-volume-azure-disk#clone-volumes-with-azure-disks).
- [Resize persistent volumes without downtime](create-volume-azure-disk#resize-a-persistent-volume-without-downtime-with-azure-disks).

Note

Depending on the virtual machine (VM) SKU you're using, the Azure Disks CSI driver might have a per-node volume limit. For some powerful VMs (for example, 16 cores), the limit is *64 volumes per node*. To identify the limit per VM SKU, review the **Max data disks** column for each VM SKU offered. For a list of VM SKUs offered and their corresponding detailed capacity limits, see [General purpose virtual machine sizes](/en-us/azure/virtual-machines/sizes-general).

::: zone-end

::: zone pivot="azure-files"

## About Azure Files CSI driver

The Azure Files CSI driver is a [CSI specification](https://github.com/container-storage-interface/spec/blob/master/spec.md)-compliant driver used by AKS to manage the lifecycle of Azure file shares. With the Azure Files CSI driver, you can mount an SMB 3.0/3.1 share backed by an Azure storage account to pods. With Azure Files, you can share data across multiple nodes and pods. Azure Files can use Azure Standard storage backed by regular HDDs or Azure Premium storage backed by high-performance SSDs.

::: zone-end

::: zone pivot="azure-blob"

## About Azure Blob storage CSI driver

The Azure Blob storage CSI driver is a [CSI specification](https://github.com/container-storage-interface/spec/blob/master/spec.md)-compliant driver used by AKS to manage the lifecycle of Azure Blob storage. With the Azure Blob storage CSI driver, you can mount blob storage (or object storage) as a file system into a container or pod. Using blob storage enables your cluster to support applications that work with large unstructured datasets like log file data, images or documents, HPC, and others. Additionally, if you ingest data into [Azure Data Lake storage](/en-us/azure/storage/blobs/data-lake-storage-introduction), you can directly mount and use it in AKS without configuring another interim filesystem.

When you mount Azure Blob storage as a filesystem into a container or pod, it enables you to use blob storage with multiple applications that work massive amounts of unstructured data, such as:

- Log file data
- Images, documents, and streaming video or audio
- Disaster recovery data

Applications can access data on the object storage using BlobFuse or Network File System (NFS) 3.0 protocol. Before the introduction of the Azure Blob storage CSI driver, the only option was to manually install an unsupported driver to access blob storage from your application running on AKS.

## Features of Azure Blob storage CSI driver

The Azure Blob storage CSI driver provides the following features:

| Feature | Details |
| --- | --- |
| Built-in storage classes | `azureblob-fuse-premium` and `azureblob-nfs-premium` |
| Mount method | BlobFuse |
| Network protocol | Network File System (NFS) 3.0 |

::: zone-end

## Prerequisites

- You need the Azure CLI version 2.42 or later installed and configured. Find the version using the `az --version` command. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- If the open-source CSI storage driver is installed on your cluster, uninstall it before enabling the Azure storage CSI driver.

::: zone pivot="azure-blob"

- Follow the steps [here](https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/install-csi-driver-master.md#clean-up-blob-csi-driver) if you previously installed the [CSI Blob storage open-source driver](https://github.com/kubernetes-sigs/blob-csi-driver) to access Azure Blob storage from your cluster.

    Note

    If blobfuse-proxy isn't enabled during the installation of the open-source driver, the uninstallation of the open-source driver disrupts existing blobfuse mounts. However, NFS mounts remain unaffected.

::: zone-end

- To enforce the Azure Policy for AKS [policy definition](/en-us/azure/governance/policy/samples/built-in-policies#kubernetes)**Kubernetes clusters should use Container Storage Interface (CSI) driver `StorageClass`**, you need to enable the Azure Policy add-on on your cluster. To enable on an existing cluster, see [Learn Azure Policy for Kubernetes](/en-us/azure/governance/policy/concepts/policy-for-kubernetes).

## Disk encryption supported scenarios

CSI storage drivers support the following scenarios:

- [Encrypted managed disks with customer-managed keys](/en-us/azure/virtual-machines/disks-cross-tenant-customer-managed-keys) using Azure key vaults stored in a different Microsoft Entra tenant.
- Encrypt your Azure Storage disks hosting AKS operating system (OS) and application data with [customer-managed keys](azure-disk-customer-managed-keys).

::: zone pivot="azure-disks"

## Enable Azure Disks CSI storage driver on an existing AKS cluster

Enable the Azure Disks CSI driver on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-disk-driver` parameter. The following example enables the Azure Disks CSI driver on an existing cluster named *myAKSCluster* in the resource group *myResourceGroup*:

Note

You can enable the [snapshot controller](https://kubernetes-csi.github.io/docs/snapshot-controller.html) at the same time as the Azure Disks CSI driver, which allows you to create snapshots of your persistent volumes. To enable the snapshot controller, include the `--enable-snapshot-controller` parameter in the command.

```azurecli
az aks update --name myAKSCluster --resource-group myResourceGroup --enable-disk-driver
```

It takes a few minutes to enable the Azure Disks CSI driver. After the command finishes, you can verify that the driver is enabled by checking that `diskCSIDriver` is set to `true` in the output. For example:

```output
"storageProfile": {
    "diskCSIDriver": {
        "enabled": true
    },
```

::: zone-end

::: zone pivot="azure-files"

## Enable Azure Files CSI storage driver on an existing AKS cluster

Enable the Azure Files CSI driver on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-file-driver` parameter. The following example enables the Azure Files CSI driver on an existing cluster named *myAKSCluster* in the resource group *myResourceGroup*:

Note

You can enable the [snapshot controller](https://kubernetes-csi.github.io/docs/snapshot-controller.html) at the same time as the Azure Files CSI driver, which allows you to create snapshots of your persistent volumes. To enable the snapshot controller, include the `--enable-snapshot-controller` parameter in the command.

```azurecli
az aks update --name myAKSCluster --resource-group myResourceGroup --enable-file-driver
```

It takes a few minutes to enable the Azure Files CSI driver. After the command is completed, you can verify that the driver is enabled by checking that `fileCsiDriver` is set to `true` in the output. For example:

```output
"storageProfile": {
    "fileCsiDriver": {
        "enabled": true
    },
```

::: zone-end

::: zone pivot="azure-blob"

## Enable Azure Blob storage CSI storage driver on an existing AKS cluster

Enable the Azure Blob storage CSI driver on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-blob-driver` parameter. The following example enables the Azure Blob storage CSI driver on an existing cluster named *myAKSCluster* in the resource group *myResourceGroup*:

```azurecli
az aks update --name myAKSCluster --resource-group myResourceGroup --enable-blob-driver
```

It takes a few minutes to enable the Azure Blob storage CSI driver. After the command is completed, you can verify that the driver is enabled by checking that `blobCsiDriver` is set to `true` in the output. For example:

```output
"storageProfile": {
    "blobCsiDriver": {
        "enabled": true
    },
```

::: zone-end

::: zone pivot="azure-disks"

## Disable Azure Disks CSI storage driver on an existing AKS cluster

Disable the Azure Disks CSI driver on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-disk-driver` parameter. The following example disables the Azure Disks CSI driver on an existing cluster named *myAKSCluster* in the resource group *myResourceGroup*:

Note

You can disable the [snapshot controller](https://kubernetes-csi.github.io/docs/snapshot-controller.html) by including the `--disable-snapshot-controller` parameter in the command.

```azurecli
az aks update --name myAKSCluster --resource-group myResourceGroup --disable-disk-driver
```

::: zone-end

::: zone pivot="azure-files"

## Disable Azure Files CSI storage driver on an existing AKS cluster

Disable the Azure Files CSI driver on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-file-driver` parameter. The following example disables the Azure Files CSI driver on an existing cluster named *myAKSCluster* in the resource group *myResourceGroup*:

Note

You can disable the [snapshot controller](https://kubernetes-csi.github.io/docs/snapshot-controller.html) by including the `--disable-snapshot-controller` parameter in the command.

```azurecli
az aks update --name myAKSCluster --resource-group myResourceGroup --disable-file-driver
```

::: zone-end

::: zone pivot="azure-blob"

## Disable Azure Blob storage CSI storage driver on an existing AKS cluster

Disable the Azure Blob storage CSI driver on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-blob-driver` parameter. The following example disables the Azure Blob storage CSI driver on an existing cluster named *myAKSCluster* in the resource group *myResourceGroup*:

```azurecli
az aks update --name myAKSCluster --resource-group myResourceGroup --disable-blob-driver
```

::: zone-end

Note

We recommend deleting the corresponding PersistentVolumeClaim object instead of the PersistentVolume object when deleting a CSI volume. The external provisioner in the CSI driver reacts to the deletion of the PersistentVolumeClaim. Based on the PVC reclamation policy, the provisioner issues the DeleteVolume call against the CSI volume driver commands to delete the volume. The PersistentVolume object is then deleted.