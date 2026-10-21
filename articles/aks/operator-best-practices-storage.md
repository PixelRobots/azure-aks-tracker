---
layout: Conceptual
title: Best practices for storage and backup - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-storage
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
description: Learn the cluster operator best practices for storage, data encryption, and backups in Azure Kubernetes Service (AKS)
ms.topic: best-practice
ms.subservice: aks-storage
ms.date: 2023-04-28T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 9d4b5464-f029-81c0-32ed-1693adc990f7
document_version_independent_id: 9458467b-f0a6-5d60-099b-42ac15808fc2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/operator-best-practices-storage.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/operator-best-practices-storage
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/operator-best-practices-storage.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/01a89bec-e73f-4ce0-a00a-ae34ad62e5fe
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/50038ab9-5431-4515-9dfc-c24291ef4fce
platformId: 3c55e150-04ac-8ffc-7e80-321d23e4af61
---

# Best practices for storage and backup - Azure Kubernetes Service | Microsoft Learn

As you create and manage clusters in Azure Kubernetes Service (AKS), your applications often need storage. Make sure you understand pod performance needs and access methods so that you can select the best storage for your application. The AKS node size may impact your storage choices. Plan for ways to back up and test the restore process for attached storage.

This best practices article focuses on storage considerations for cluster operators. In this article, you learn:

- What types of storage are available.
- How to correctly size AKS nodes for storage performance.
- Differences between dynamic and static provisioning of volumes.
- Ways to back up and secure your data volumes.

## Choose the appropriate storage type

> 
> **Best practice guidance**
> 
> Understand the needs of your application to pick the right storage. Use high performance, SSD-backed storage for production workloads. Plan for network-based storage when you need multiple concurrent connections.

Applications often require different types and speeds of storage. Determine the most appropriate storage type by asking the following questions.

- Do your applications need storage that connects to individual pods?
- Do your applications need storage shared across multiple pods?
- Is the storage for read-only access to data?
- Will the storage be used to write large amounts of structured data?

The following table outlines the available storage types and their capabilities:

| Use case | Volume plugin | Read/write once | Read-only many | Read/write many | Windows Server container support |
| --- | --- | --- | --- | --- | --- |
| Shared configuration | Azure Files | Yes | Yes | Yes | Yes |
| Structured app data | Azure Disks | Yes | No | No | Yes |
| Unstructured data, file system operations | [BlobFuse](https://github.com/Azure/azure-storage-fuse) | Yes | Yes | Yes | No |

AKS provides two primary types of secure storage for volumes backed by Azure Disks or Azure Files. Both use the default Azure Storage Service Encryption (SSE) that encrypts data at rest. Disks cannot be encrypted using Azure Disk Encryption at the AKS node level. With Azure Files shares, there is no limit as to how many can be mounted on a node.

Both Azure Files and Azure Disks are available in Standard and Premium performance tiers:

- *Premium*disks
    - Backed by high-performance solid-state disks (SSDs).
    - Recommended for all production workloads.
- *Standard*disks
    - Backed by regular spinning disks (HDDs).
    - Good for archival or infrequently accessed data.

While the default storage tier for the Azure Disk CSI driver is Premium SSD, your custom StorageClass can use Premium SSD, Standard SSD, or Standard HDD.

Understand the application performance needs and access patterns to choose the appropriate storage tier. For more information about Managed Disks sizes and performance tiers, see [Azure Managed Disks overview](/en-us/azure/virtual-machines/managed-disks-overview).

### Create and use storage classes to define application needs

Define the type of storage you want using Kubernetes *storage classes*. The storage class is then referenced in the pod or deployment specification. Storage class definitions work together to create the appropriate storage and connect it to pods.

For more information, see [Storage classes in AKS](concepts-storage#storage-classes).

## Size the nodes for storage needs

> 
> **Best practice guidance**
> 
> Each node size supports a maximum number of disks. Different node sizes also provide different amounts of local storage and network bandwidth. Plan appropriately for your application demands to deploy the right size of nodes.

AKS nodes run as various Azure VM types and sizes. Each VM size provides:

- A different amount of core resources such as CPU and memory.
- A maximum number of disks that can be attached.

Storage performance also varies between VM sizes for the maximum local and attached disk IOPS (input/output operations per second).

If your applications require Azure Disks as their storage solution, strategize an appropriate node VM size. Storage capabilities and CPU and memory amounts play a major role when deciding on a VM size.

For example, while both the *Standard\_B2ms* and *Standard\_DS2\_v2* VM sizes include a similar amount of CPU and memory resources, their potential storage performance is different:

| Node type and size | vCPU | Memory (GiB) | Max data disks | Max uncached disk IOPS | Max uncached throughput (MBps) |
| --- | --- | --- | --- | --- | --- |
| Standard\_B2ms | 2 | 8 | 4 | 1,920 | 22.5 |
| Standard\_DS2\_v2 | 2 | 7 | 8 | 6,400 | 96 |

In this example, the *Standard\_DS2\_v2* offers twice as many attached disks, and three to four times the amount of IOPS and disk throughput. If you only compared core compute resources and compared costs, you might have chosen the *Standard\_B2ms* VM size with poor storage performance and limitations.

Work with your application development team to understand their storage capacity and performance needs. Choose the appropriate VM size for the AKS nodes to meet or exceed their performance needs. Regularly baseline applications to adjust VM size as needed.

Note

By default, disk size and performance for managed disks is assigned according to the selected VM SKU and vCPU count. Default OS disk sizing is only used on new clusters or node pools when Ephemeral OS disks are not supported and a default OS disk size is not specified. For more information, see [Default OS disk sizing](cluster-configuration#default-os-disk-sizing).

For more information about available VM sizes, see [Sizes for Linux virtual machines in Azure](/en-us/azure/virtual-machines/sizes).

### Consider ephemeral NVMe data disks for maximum performance

> 
> **Best practice guidance**
> 
> Consider ephemeral NVMe data disks when you need the highest storage throughput and IOPS, and your workload can tolerate the temporary nature of local node storage. Ephemeral NVMe data disks provide low-latency, host-attached storage that delivers the highest IOPS and throughput available in Azure. NVMe disks are available on L-series, E-series, and GPU VMs, with expanding support for the newer Azure VM v6 and v7 families such as the D-series, F-series, H-series.

NVMe-backed storage enhances workloads that demand high-speed caching, temporary storage, or transient data processing. It eliminates the reliance on high-performance remote disks, which typically require the largest and most costly VM configurations to achieve optimal performance.

Common scenarios that benefit from ephemeral NVMe data disks include:

- AI training or inference pipelines that stage large datasets or checkpoints between iterations
- High-performance databases or streaming engines that maintain replicas or logs across pods
- Batch analytics jobs that require temporary scratch space or shuffle storage

Because NVMe data is tied to the node instance, plan for pod disruption budgets and ensure your application can quickly rebuild from durable storage or replication. Data placed on these disks is lost whenever a node is deallocated, reimaged, or fails.

For further recommendations on ephemeral NVMe data disks, see [Best practices for ephemeral NVMe data disks in Azure Kubernetes Service (AKS)](best-practices-storage-nvme). To expose NVMe capacity to pods, use [Azure Container Storage](/en-us/azure/storage/container-storage/container-storage-introduction), which will can orchestrate and create ephemeral **or** persistent volumes backed by local NVMe disks. For implementation guidance, see [Use Azure Container Storage with AKS](/en-us/azure/storage/container-storage/container-storage-aks-quickstart).

Important

Use NVMe data disks only for workloads that can tolerate data loss and recover quickly. Keep business-critical data on durable storage such as Azure Disk or Azure Files.

## Dynamically provision volumes

> 
> **Best practice guidance**
> 
> To reduce management overhead and enable scaling, avoid statically create and assign persistent volumes. Use dynamic provisioning. In your storage classes, define the appropriate reclaim policy to minimize unneeded storage costs once pods are deleted.

To attach storage to pods, use persistent volumes. Persistent volumes can be created manually or dynamically. Creating persistent volumes manually adds management overhead and limits your ability to scale. Instead, provision persistent volume dynamically to simplify storage management and allow your applications to grow and scale as needed.

![Diagram of persistent volume claims in an Azure Kubernetes Services (AKS) cluster.](media/concepts-storage/aks-storage-persistent-volume-claim.png)

A persistent volume claim (PVC) lets you dynamically create storage as needed. Underlying Azure disks are created as pods request them. In the pod definition, request a volume to be created and attached to a designated mount path.

For the concepts on how to dynamically create and use volumes, see [Persistent Volumes Claims](concepts-storage#persistent-volume-claims).

To see these volumes in action, see how to dynamically create and use a persistent volume with [Azure Disks](azure-disk-csi) or [Azure Files](azure-files-csi).

As part of your storage class definitions, set the appropriate *reclaimPolicy*. This reclaimPolicy controls the behavior of the underlying Azure storage resource when the pod is deleted. The underlying storage resource can either be deleted or retained for future pod use. Set the reclaimPolicy to *retain* or *delete*.

Understand your application needs, and implement regular checks for retained storage to minimize the amount of unused and billed storage.

For more information about storage class options, see [storage reclaim policies](concepts-storage#storage-classes).

## Secure and back up your data

> 
> **Best practice guidance**
> 
> Back up your data using an appropriate tool for your storage type, such as Velero or Azure Backup. Verify the integrity and security of those backups.

When your applications store and consume data persisted on disks or in files, you need to take regular backups or snapshots of that data. Azure Disks can use built-in snapshot technologies. Your applications may need to flush writes-to-disk before you perform the snapshot operation. [Velero](https://github.com/heptio/velero) can back up persistent volumes along with additional cluster resources and configurations. If you can't [remove state from your applications](operator-best-practices-multi-region#remove-service-state-from-inside-containers), back up the data from persistent volumes and regularly test the restore operations to verify data integrity and the processes required.

Understand the limitations of the different approaches to data backups and if you need to quiesce your data prior to snapshot. Data backups don't necessarily let you restore your application environment of cluster deployment. For more information about those scenarios, see [Best practices for business continuity and disaster recovery in AKS](operator-best-practices-multi-region).