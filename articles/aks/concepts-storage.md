---
layout: Conceptual
title: Concepts - Storage in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-storage
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
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn about storage in Azure Kubernetes Service (AKS), including volumes, persistent volumes, storage classes, and claims.
ms.topic: concept-article
ms.date: 2026-07-30T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-storage
locale: en-us
document_id: 2996be04-d539-a2a0-2381-9fceaca9291a
document_version_independent_id: 8fe6f5b0-4123-ed84-6e53-40befc3a07c7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-storage.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-storage
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-storage.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 69dfa67f-7362-c3fc-29e8-7b882114a64a
---

# Concepts - Storage in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Applications running in Azure Kubernetes Service (AKS) might need to store and retrieve data. While some application workloads can use local, fast storage on unneeded, emptied nodes, others require storage that persists on more regular data volumes within the Azure platform.

Multiple pods might need to:

- Share the same data volumes.
- Reattach data volumes if the pod is rescheduled on a different node.

You also might need to collect and store sensitive data or application configuration information into pods.

This article introduces the core concepts that provide storage to your applications in AKS:

- Volumes
- Persistent volumes
- Storage classes
- Persistent volume claims

![Diagram of storage options for applications in an Azure Kubernetes Service (AKS) cluster.](media/concepts-storage/aks-storage-concept.png)

## Default OS disk sizing in AKS

### Ephemeral OS disks

If you select a virtual machine (VM) SKU that supports Ephemeral OS disks but don't specify an OS disk size, AKS by default provisions an Ephemeral OS disk with a size that scales according to the total temp storage of the VM SKU so long as the temp is *at least 128 GiB*. For example, the `Standard_D8ds_v5` SKU with a temp disk size of 300 GiB receives a 300 GiB Ephemeral OS disk by default if the disk parameters are unspecified.

If you want to use the temp storage of the VM SKU, you need to specify the OS disk size during deployment, otherwise it's consumed by default.

Important

Default Ephemeral OS disk sizing is only used on new clusters or node pools where Ephemeral OS disks are supported and a default OS disk size isn't specified. The default OS disk size might impact the performance or cost of your cluster. You can't change the OS disk size after cluster or node pool creation. This default Ephemeral sizing affects clusters or node pools created in March 2025 or later.

### Managed OS disks

When you create a new cluster or add a new node pool to an existing cluster, the number for vCPUs determines the OS disk size by default. The number of vCPUs is based on the VM SKU. The following table lists the default OS disk size for each VM SKU:

| VM SKU cores (vCPUs) | Default OS disk tier | Provisioned IOPS | Provisioned throughput (Mbps) |
| --- | --- | --- | --- |
| 1 - 7 | P10/128G | 500 | 100 |
| 8 - 15 | P15/256G | 1100 | 125 |
| 16 - 63 | P20/512G | 2300 | 150 |
| 64+ | P30/1024G | 5000 | 200 |

Important

Default Managed OS disk sizing is only used on new clusters or node pools when Ephemeral OS disks aren't supported and a default OS disk size isn't specified. The default OS disk size might impact the performance or cost of your cluster. You can't change the OS disk size after cluster or node pool creation. We recommend a minimum disk size of 512 G if Ephemeral OS disks can't be used. This default managed sizing affects clusters or node pools created in July 2022 or later.

## Ephemeral OS disks in AKS

By default, Azure automatically replicates the operating system disk for a virtual machine to Azure Storage to avoid data loss when the VM is relocated to another host. However, since containers aren't designed to have local state persisted, this behavior offers limited value while providing some drawbacks. These drawbacks include, but aren't limited to, slower node provisioning and higher read/write latency.

By contrast, Ephemeral OS disks are stored only on the host machine, just like a temporary disk. With this configuration, you get lower read/write latency with faster node scaling and cluster upgrades. Therefore, we strongly **recommend using Ephemeral OS disks whenever possible**.

Note

When you don't explicitly request [Azure managed disks](/en-us/azure/virtual-machines/managed-disks-overview) for the OS, AKS defaults to ephemeral OS if possible for a given node pool configuration.

You can find size requirements and recommendations for ephemeral OS disks in the [Azure VM documentation](/en-us/azure/virtual-machines/ephemeral-os-disks). Keep the following considerations in mind when using ephemeral OS disks:

The latest generation of VM series doesn't have a dedicated cache, only temporary storage. For example, if you selected the [Standard_E2bds_v5](/en-us/azure/virtual-machines/ebdsv5-ebsv5-series#ebdsv5-series) VM size with the default OS disk size of 100 GiB, it supports ephemeral OS disks, but only has 75 GiB of temporary storage. This configuration defaults to managed OS disks if you don't explicitly specify it. If you do request an ephemeral OS disk, you receive a validation error.

- If you request the same [Standard_E2bds_v5](/en-us/azure/virtual-machines/ebdsv5-ebsv5-series#ebdsv5-series) VM size with a 60 GiB OS disk, this configuration defaults to ephemeral OS disks. The requested size of 60 GiB is smaller than the maximum temporary storage of 75 GiB.
- If you select the [Standard_E4bds_v5](/en-us/azure/virtual-machines/ebdsv5-ebsv5-series#ebdsv5-series) SKU with a 100 GiB OS disk, this VM size supports ephemeral OS and has 150 GiB of temporary storage. If you don't specify the OS disk type, Azure provisions an ephemeral OS disk to the node pool by default.

Previous generation VMs and retired sizes have dedicated cache space in addition to temp disk space. However, the cache disk space is used when evaluating ephemeral placement instead of temporary storage.

### Customer-managed keys

You can manage encryption for your ephemeral OS disk with your own keys on an AKS cluster. For more information, see [Use Customer Managed key with Azure disk on AKS](azure-disk-customer-managed-keys).

## Ephemeral NVMe data disks

Ephemeral NVMe data disks provide high-performance, low-latency storage directly attached to the physical host of your Azure VM. These disks are ideal for workloads that require fast, temporary storage (non-persistent, host-attached storage that is lost if the VM is deallocated) for intermediate data processing, such as caching, scratch space, or high-throughput analytics.

Ephemeral NVMe data disks were initially available only on Azure VM L-series, E-series, and GPU VMs. With the introduction of Azure VM v6 and v7 generations, support for ephemeral NVMe data disks has expanded to a wider range of VM sizes, including D-series, F-series, H-series, and more. NVMe disks deliver higher IOPS and throughput compared to traditional HDD or SSD options. However, data stored on these disks is temporary and will be lost if the VM is deallocated or redeployed.

To simplify management and provisioning of ephemeral NVMe data disks in AKS, use [Azure Container Storage](/en-us/azure/storage/container-storage/container-storage-introduction). Azure Container Storage can automatically detect and orchestrate NVMe data disks, allowing you to create and manage persistent volumes for your Kubernetes workloads with minimal configuration. This approach is recommended for scenarios where high-performance, temporary storage is required, such as:

- High-speed caching layers, such as datasets and checkpoints for AI training, or model files used for AI inference
- High-performance, self-hosted databases that include built-in replication and backup features
- Data-intensive analytics and processing pipelines that require fast, temporary storage
- Temporary scratch space for batch jobs

Important

Ephemeral NVMe data disks aren't suitable for storing critical or persistent data. Ensure your application can tolerate data loss and that important data is stored on persistent volumes backed by Azure Disk, Azure Files, or other durable storage options.

For more information on using Azure Container Storage with ephemeral NVMe data disks, see [Use Azure Container Storage with AKS](/en-us/azure/storage/container-storage/use-container-storage-with-local-disk).

## Volumes

Kubernetes typically treats individual pods as ephemeral, disposable resources. Applications have different approaches available to them for using and persisting data. A *volume* represents a way to store, retrieve, and persist data across pods and through the application lifecycle.

Traditional volumes are created as Kubernetes resources backed by Azure Storage. You can manually create data volumes to be assigned to pods directly or have Kubernetes automatically create them. Data volumes can use: [Azure Disk](/en-us/azure/virtual-machines/disks-types), [Azure Files](/en-us/azure/storage/files/storage-files-planning), [Azure NetApp Files](/en-us/azure/azure-netapp-files/azure-netapp-files-service-levels), or [Azure Blobs](/en-us/azure/storage/common/storage-account-overview).

Note

Depending on the VM SKU you're using, the Azure Disk CSI driver might have a per-node volume limit. For some high performance VMs (for example, 16 cores), the limit is 64 volumes per node. To identify the limit per VM SKU, review the **Max data disks** column for each VM SKU offered. For a list of VM SKUs offered and their corresponding detailed capacity limits, see [General purpose virtual machine sizes](/en-us/azure/virtual-machines/sizes-general).

To help determine best fit for your workload between Azure Files and Azure NetApp Files, review the information provided in the article [Azure Files and Azure NetApp Files comparison](/en-us/azure/storage/files/storage-files-netapp-comparison).

### Azure Disk

Use [Azure Disk](azure-disk-csi) to create a Kubernetes *DataDisk* resource. Disks types include:

- Premium SSDs (recommended for most workloads)
- Ultra Disks
- Standard SSDs
- Standard HDDs

Tip

For most production and development workloads, use Premium SSDs.

Because an Azure Disk is mounted as *ReadWriteOnce*, it's only available to a single node. For storage volumes accessible by pods on multiple nodes simultaneously, use Azure Files.

### Azure Files

Use [Azure Files](azure-files-csi) to mount a Server Message Block (SMB) version 3.1.1 share or Network File System (NFS) version 4.1 share. Azure Files let you share data across multiple nodes and pods and can use:

- Azure Premium storage backed by high-performance SSDs
- Azure Standard storage backed by regular HDDs

### Azure NetApp Files

Use Azure NetApp Files to provision high-performance NFS or SMB volumes for AKS workloads. Choose from five service levels based on your workload's throughput and performance requirements:

- Elastic Storage (preview)
- Flexible Storage
- Standard Storage
- Premium Storage
- Ultra Storage

### Azure Blob Storage

Use [Azure Blob Storage](azure-blob-csi) to create a blob storage container and mount it using the NFS v3.0 protocol or BlobFuse.

### Volume types

Kubernetes volumes represent more than just a traditional disk for storing and retrieving information. Kubernetes volumes can also be used as a way to inject data into a pod for use by its containers.

Common volume types in Kubernetes include:

#### emptyDir

Commonly used as temporary space for a pod. All containers within a pod can access the data on the volume. Data written to this volume type persists only for the lifespan of the pod. Once you delete the pod, the volume is deleted. This volume typically uses the underlying local node disk storage, though it can also exist only in the node's memory.

#### secret

You can use *secret* volumes to inject sensitive data into pods, such as passwords.

1. Create a secret using the Kubernetes API.
2. Define your pod or deployment and request a specific secret.
    - Secrets are only provided to nodes with a scheduled pod that requires them.
    - The secret is stored in *tmpfs*, not written to disk.
3. When you delete the last pod on a node requiring a secret, the secret is deleted from the node's tmpfs.
    - Secrets are stored within a given namespace and are only accessed by pods within the same namespace.

#### configMap

You can use *configMap* to inject key-value pair properties into pods, such as application configuration information. Define application configuration information as a Kubernetes resource, easily updated and applied to new instances of pods as they're deployed.

Like using a secret:

1. Create a ConfigMap using the Kubernetes API.
2. Request the ConfigMap when you define a pod or deployment.
    - ConfigMaps are stored within a given namespace and are only accessed by pods within the same namespace.

## Persistent volumes

Volumes defined and created as part of the pod lifecycle only exist until you delete the pod. Pods often expect their storage to remain if a pod is rescheduled on a different host during a maintenance event, especially in StatefulSets. A *persistent volume* (PV) is a storage resource created and managed by the Kubernetes API that can exist beyond the lifetime of an individual pod.

You can use the following Azure Storage services to provide the persistent volume:

- [Azure Disk](create-volume-azure-disk)
- [Azure Files](create-volume-azure-files)
- [Azure Container Storage](/en-us/azure/storage/container-storage/container-storage-introduction)

As noted in the Volumes section, the choice between Azure Disks and Azure Files typically depends on the need for concurrent access (Azure Files supports multiple nodes simultaneously; Azure Disk supports single node only) or the required performance tier.

![Diagram of persistent volumes in an Azure Kubernetes Service (AKS) cluster.](media/concepts-storage/aks-storage-persistent-volume.png)

A cluster administrator can *statically* create a persistent volume, or a volume can be created *dynamically* by the Kubernetes API server. If a pod is scheduled and requests storage that is currently unavailable, Kubernetes can create the underlying Azure Disk or File storage and attach it to the pod. Dynamic provisioning uses a *storage class* to identify what type of resource needs to be created.

Important

Persistent volumes can't be shared by Windows and Linux pods due to differences in file system support between the two operating systems.

If you want a fully managed solution for block-level access to data, consider using [Azure Container Storage](/en-us/azure/storage/container-storage/container-storage-introduction). Azure Container Storage integrates with Kubernetes, so you can dynamically and automatically provision persistent volumes. Supported backing storage depends on the major version. Azure Container Storage version 2 supports local NVMe disks and Azure Elastic SAN. Version 1 supports Azure Disks, ephemeral disks (local NVMe and temporary SSD), and Azure Elastic SAN.

## Storage classes

To specify different tiers of storage, such as premium or standard, you can create a *storage class*.

A storage class also defines a *reclaim policy*. When you delete the persistent volume, the reclaim policy controls the behavior of the underlying Azure Storage resource. The underlying resource can either be deleted or kept for use with a future pod.

For clusters using [Azure Container Storage](/en-us/azure/storage/container-storage/container-storage-introduction), the storage classes depend on the major version and backing storage. Version 2 uses `local-csi` for local NVMe disks and `azuresan-csi` for Azure Elastic SAN. Version 1 creates a storage class named `acstor-<storage-pool-name>` and an internal storage class.

For clusters using [Container Storage Interface (CSI) drivers](csi-storage-drivers), the following extra storage classes are created:

| Storage class | Description |
| --- | --- |
| `managed-csi` | Uses Azure Standard SSD locally redundant storage (LRS) to create a managed disk. The reclaim policy ensures that the underlying Azure Disk is deleted when the persistent volume used is deleted. The storage class also configures the persistent volumes to be expandable. You can edit the persistent volume claim to specify the new size. Effective starting with Kubernetes version 1.29, in Azure Kubernetes Service (AKS) clusters deployed across multiple availability zones, this storage class utilizes Azure Standard SSD zone-redundant storage (ZRS) to create managed disks. |
| `managed-csi-premium` | Uses Azure Premium locally redundant storage (LRS) to create a managed disk. The reclaim policy again ensures that the underlying Azure Disk is deleted when the persistent volume used is deleted. Similarly, this storage class allows for persistent volumes to be expanded. Effective starting with Kubernetes version 1.29, in Azure Kubernetes Service (AKS) clusters deployed across multiple availability zones, this storage class utilizes Azure Premium zone-redundant storage (ZRS) to create managed disks. |
| `managed-csi-premium-v2` | Uses Azure Premium SSD v2 locally redundant storage (LRS) to create a managed disk. The reclaim policy again ensures that the underlying Azure Disk is deleted when the persistent volume used is deleted. This storage class is available starting with Kubernetes version 1.35. |
| `azurefile-csi` | Uses Azure Standard storage to create an Azure file share. The reclaim policy ensures that the underlying Azure file share is deleted when the persistent volume used is deleted. |
| `azurefile-csi-premium` | Uses Azure Premium storage to create an Azure file share. The reclaim policy ensures that the underlying Azure file share is deleted when the persistent volume used is deleted. |
| `azureblob-nfs-premium` | Uses Azure Premium storage to create an Azure Blob storage container and connect using the NFS v3 protocol. The reclaim policy ensures that the underlying Azure Blob storage container is deleted when the persistent volume used is deleted. |
| `azureblob-fuse-premium` | Uses Azure Premium storage to create an Azure Blob storage container and connect using BlobFuse. The reclaim policy ensures that the underlying Azure Blob storage container is deleted when the persistent volume used is deleted. |

Unless you specify a storage class for a persistent volume, the default storage class is used. Ensure volumes use the appropriate storage you need when requesting persistent volumes.

Important

Starting with Kubernetes version 1.21, AKS uses CSI drivers by default, and CSI migration is enabled. While existing in-tree persistent volumes continue to function, starting with version 1.26, AKS will no longer support volumes created using in-tree driver and storage provisioned for files and disks.

The `default` class will be the same as `managed-csi`.

Effective starting with Kubernetes version 1.29, when you deploy Azure Kubernetes Service (AKS) clusters across multiple availability zones, AKS now utilizes zone-redundant storage (ZRS) to create managed disks within built-in storage classes. ZRS ensures synchronous replication of your Azure managed disks across multiple Azure availability zones in your chosen region. This redundancy strategy enhances the resilience of your applications and safeguards your data against datacenter failures.

However, it's important to note that zone-redundant storage (ZRS) comes at a higher cost compared to locally redundant storage (LRS). If cost optimization is a priority, you can create a new storage class with the `skuname` parameter set to LRS. You can then use the new storage class in your Persistent Volume Claim (PVC).

You can create a storage class for other needs using `kubectl`. The following example uses premium managed disks and specifies that the underlying Azure Disk should be *retained* when you delete the persistent volume claim:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-premium-retain
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_ZRS
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

This manifest uses `disk.csi.azure.com` as the Azure Disk CSI provisioner and `Premium_ZRS` as the `skuName` for a zone-redundant Premium SSD. The `Retain` reclaim policy preserves the underlying disk after its persistent volume claim is deleted, and `WaitForFirstConsumer` delays volume binding and provisioning until a pod that uses the claim is created so that the disk is provisioned according to the pod's scheduling constraints.

Note

AKS reconciles the default storage classes and will overwrite any changes you make to those storage classes.

For more information about storage classes, see [StorageClass in Kubernetes](https://kubernetes.io/docs/concepts/storage/storage-classes/).

## Persistent volume claims

A persistent volume claim (PVC) requests storage of a particular storage class, access mode, and size. The Kubernetes API server can dynamically provision the underlying Azure Storage resource if no existing resource can fulfill the claim based on the defined storage class.

The pod definition includes the volume mount once the volume has been connected to the pod.

![Diagram of persistent volume claims in an Azure Kubernetes Service (AKS) cluster.](media/concepts-storage/aks-storage-persistent-volume-claim.png)

Once an available storage resource has been assigned to the pod requesting storage, the persistent volume is *bound* to a persistent volume claim. Persistent volumes are mapped to claims in a 1:1 mapping.

The following example YAML manifest shows a persistent volume claim that uses the *managed-premium-retain* storage class and requests an Azure Disk that is *5 Gi* in size:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-managed-disk
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: managed-premium-retain
  resources:
    requests:
      storage: 5Gi
```

This claim uses the `ReadWriteOnce` access mode, which allows the volume to be mounted as read-write by a single node at a time, and sets the `storage` request to `5Gi` (5 GiB) as an example size. Adjust the `storage` value to match your workload requirements.

When you create a pod definition, you also specify:

- The persistent volume claim to request the desired storage.
- The *volume mount* for your applications to read and write data.

The following example YAML manifest shows how the previous persistent volume claim can be used to mount a volume at */mnt/azure*:

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: nginx
spec:
  containers:
    - name: myfrontend
      image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
      volumeMounts:
      - mountPath: "/mnt/azure"
        name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: azure-managed-disk
```

For mounting a volume in a Windows container, specify the drive letter and path. For example:

```yaml
...      
      volumeMounts:
      - mountPath: "d:"
        name: volume
      - mountPath: 'c:\k'
        name: k-dir
...
```