---
layout: Conceptual
title: Process for restoring a Kubernetes cluster from a disaster | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/restore-aks-cluster
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
description: Learn how to restore Kubernetes clusters after a disaster.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2023-01-10T00:00:00.0000000Z
ms.reviewer: rbaziwane
ms.custom: windows-server
locale: en-us
document_id: b9e82294-f2a3-b011-cd07-e6f88c03d9d7
document_version_independent_id: 152a5502-1324-2493-c11b-d7107b401be4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/restore-aks-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/restore-aks-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/restore-aks-cluster.md
platformId: 13ca04e1-f7e7-d7f6-781b-80cf08e93bbc
---

# Process for restoring a Kubernetes cluster from a disaster | Microsoft Learn

> 
> Applies to: AKS on Windows Server

In AKS on Windows Server, the management cluster is deployed as a single standalone virtual machine (VM) per deployment, making it a single point of failure. It's important to note that a management cluster outage has no impact on applications running in the workload clusters. When the management cluster VM fails, the workload clusters (and workloads) continue running, but you can't perform day-2 operations. For example, you can't create new workload clusters, create or scale a node pool, or upgrade Kubernetes versions, until the VM is restored.

The management cluster is a VM that's tracked in Windows failover clustering. It's also resilient to host-level disruptions. In other words, during a host machine failure, Windows failover clustering restarts the VM on a healthy host machine. This article provides guidance on how to perform the following tasks:

- Restore the state of AKS on new hardware (could be a new site).
- Recover from corruption of the management cluster.

In either of these scenarios, you must recreate the management cluster and all the workload clusters.

## Restore the state of AKS on new hardware or a new site

Recovering the state of Kubernetes clusters requires that you have a management cluster available on new hardware or at the new location.

- AKS supports [backing up Kubernetes clusters](backup-workload-cluster) to Azure Blob Storage and MinIO using Velero. Microsoft recommends backing up Azure Storage because it provides 3 redundant copies of data in the primary storage region.
- Consider running the backup on a cron job to ensure available backups meet recovery point objectives.

### Prerequisites

Prepare the cold standby in advance of a disaster by creating a management cluster and an empty workload cluster. You need an empty workload cluster for each Kubernetes cluster you want to restore from backup. The following prerequisites are required:

- Set up and cluster physical host machines.
- Configure required storage:
    - For SMB: [Use Container Storage Interface (CSI) file drivers](/en-us/azure/aks/hybrid/container-storage-interface-files).
    - For local storage: [Use Container Storage Interface (CSI) disk drivers](/en-us/azure/aks/hybrid/container-storage-interface-disks#create-a-custom-storage-class-for-an-aks-on-azure-stack-hci-and-windows-server-disk).
- Workload cluster backups are available: [Back up, restore workload clusters using Velero](/en-us/azure/aks/hybrid/backup-workload-cluster#use-velero-to-create-a-workload-cluster-backup).
- An AKS management cluster is installed on new hardware, or you can install a new management cluster on new hardware using steps 1-5 of this article: [Use PowerShell to set up Kubernetes on Azure Local clusters](/en-us/azure/aks/hybrid/kubernetes-walkthrough-powershell).
- An empty workload cluster is required to restore the backups. See [Back up, restore workload clusters using Velero](/en-us/azure/aks/hybrid/backup-workload-cluster#use-velero-to-restore-a-workload-cluster).

## Recover from management cluster corruption

Recovering from a management cluster corruption requires uninstalling AKS and reinstalling the management cluster and all the workload clusters. Workload clusters can be restored into empty workload clusters from Velero backups.

The following prerequisites are required:

- Workload cluster backups: [Back up, restore workload clusters using Velero](/en-us/azure/aks/hybrid/backup-workload-cluster#use-velero-to-create-a-workload-cluster-backup).
- Backup of AKS configuration for previous networking, storage, and cluster settings. Cluster settings include sizes and counts of control plane, load balancer, and worker node VMs. For example, if your old cluster had 3 **Standard\_A2\_V2** control plane VMs, you must create 3 control plane VMs in the new environment.

To recover from management cluster corruption, perform the following steps:

- Uninstall AKS: [Uninstall-AksHci](/en-us/azure/aks/hybrid/reference/ps/uninstall-akshci).
- Install a new AKS management cluster using steps 1-5 of this article: [Use PowerShell to set up Kubernetes on AKS clusters](/en-us/azure/aks/hybrid/kubernetes-walkthrough-powershell).
- Create the workload cluster with required node pools using step 6 in this article. You need a separate workload cluster for each workload cluster you restore from backup.
- You can configure multiple control plane VMs and load balancer VMs during workload cluster creation using this article: [New-AksHciCluster for AKS](/en-us/azure/aks/hybrid/reference/ps/new-akshcicluster).
- Configure required storage:
    - For SMB: [Use Container Storage Interface (CSI) file drivers](/en-us/azure/aks/hybrid/container-storage-interface-files).
    - For local storage: [Use Container Storage Interface (CSI) disk drivers](/en-us/azure/aks/hybrid/container-storage-interface-disks#create-a-custom-storage-class-for-an-aks-on-azure-stack-hci-and-windows-server-disk).
- Restore all workload clusters from backup.

## FAQ

### What resiliency is built into the management cluster?

Each AKS deployment includes a management cluster that is a single standalone VM. For resiliency and high availability, AKS relies on windows failover clustering to recover the VM if a disruption occurs.

A management cluster outage has no impact on applications running in workload clusters. When the management cluster VM goes down, this impacts your ability to perform AKS Day 2 operations, such as create new workload clusters, create or scale node pools, upgrade Kubernetes versions, etc., until the VM is recovered. In cases where you're unable to recover from a management cluster failure, we recommend contacting Microsoft Support.

### What's included in a Velero backup?

| Filename | Content description |
| --- | --- |
| \*-csi-volumesnapshotclasses.json.gz | Files containing **csi** are the persistent volume snapshots. |
| \*-csi-volumesnapshotcontents.json.gz | Files containing **csi** are persistent volume snapshots. |
| \*-csi-volumesnapshots.json.gz | Files containing **csi** are the persistent volume snapshots. |
| \*-logs.gz | Log output of backup operation. Same data from running: `velero backup log <backupname>`. |
| \*-podvolumebackups.json.gz | Metadata about the pods and persistent volumes. |
| \*-resource-list.json.gz | Resources contained in a backup are listed in this file. |
| \*-volumesnapshots.json.gz | Metadata about the pods and persistent volumes. |
| \*.tar.gz | Metadata: namespace, number of pod replicas, memory, cpu. Same data as returned from: `kubectl get deployment`. |

### What's not included in Velero backups?

The Velero backup doesn't include the following items:

- Management cluster (AKS) configuration
- Control plane VM (API server) metadata
- Load balancer (HA Proxy) metadata
- Network settings
- Storage settings

### How do I back up the AKS configuration before a disaster?

To back up the management cluster configuration, open a PowerShell window and run the following command:

```powershell
Get-AksHciConfig | ConvertTo-Json 
```

### How do I make sure the workload cluster has the same configuration as before a disaster?

To back up the workload cluster configuration, open a PowerShell window and run the following command:

```powershell
Get-AksHciCluster -name <cluster name> | ConvertTo-Json 
```