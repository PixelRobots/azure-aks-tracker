---
layout: Conceptual
title: Troubleshoot Azure disk volume mount errors in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/fail-to-mount-azure-disk-volume
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
description: Troubleshoot Azure disk volume mount errors in AKS, identify common causes, and apply fixes to restore pod startup. Start resolving issues now.
ms.date: 2026-11-16T00:00:00.0000000Z
ms.reviewer: chiragpa, akscsscic, v-weizhu, ookour, fabioluisf
ms.service: azure-kubernetes-service
ms.custom: sap:Storage
ai-usage: ai-assisted
locale: en-us
document_id: 2435eba9-2265-38ac-a05d-bb598f097ad9
document_version_independent_id: 2435eba9-2265-38ac-a05d-bb598f097ad9
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/storage/fail-to-mount-azure-disk-volume.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/storage/fail-to-mount-azure-disk-volume
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/storage/fail-to-mount-azure-disk-volume.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 4649772f-809f-314b-f4b3-de968df5fda3
---

# Troubleshoot Azure disk volume mount errors in AKS - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot Azure disk volume mount errors in Azure Kubernetes Service (AKS). It describes common error messages, their causes, and solutions so that your pods can start successfully.

## Symptoms

You're trying to deploy a Kubernetes resource, such as a Deployment or a StatefulSet, in an Azure Kubernetes Service (AKS) environment. The deployment creates a pod that should mount a PersistentVolumeClaim (PVC) that references an Azure disk.

However, the pod stays in the **ContainerCreating** status. When you run the `kubectl describe pods` command, you might see one of the following errors that cause the mounting operation to fail:

- Disk cannot be attached to the VM because it isn't in the same zone as the VM
- Client '&lt;client-ID&gt;' with object ID '&lt;object-ID&gt;' doesn't have authorization to perform action over scope '&lt;disk name&gt;' or scope is invalid
- Volume is already used by pod
- StorageAccountType UltraSSD_LRS can be used only when additionalCapabilities.ultraSSDEnabled is set
- ApplyFSGroup failed for vol
- Node(s) exceed max volume count
- UNEXPECTED INCONSISTENCY; RUN fsck MANUALLY

See the following sections for error details, possible causes, and solutions.

## Disk cannot be attached to the VM because it isn't in the same zone as the VM

Here are the details of this error:

```output
AttachVolume.Attach failed for volume "<disk/PV name>": 
rpc error: 
code = Unknown 
desc = Attach volume "/subscriptions/<subscription-ID>/resourceGroups/<disk-resource-group>/providers/Microsoft.Compute/disks/<disk/PV name>" to instance "<AKS node name>" failed with Retriable: false, RetryAfter: 0s, HTTPStatusCode: 400, 
RawError: 
{
      "error": 
    {
"code": "BadRequest",
"message": "Disk /subscriptions/<subscription-ID>/resourceGroups/<disk-resource-group>/providers/Microsoft.Compute/disks/<disk/PV name > cannot be attached to the VM because it is not in the same zone as the VM. VM zone: 'X'. Disk zone: 'Y'. "
  }
}
```

### Cause: disk and node hosting pod are in different zones

In AKS, the default and other built-in storage classes for Azure disks use [locally redundant storage (LRS)](/en-us/azure/storage/common/storage-redundancy#locally-redundant-storage). These disks are deployed in [availability zones](/en-us/azure/aks/availability-zones). If you use the node pool in AKS together with availability zones, and the pod is scheduled on a node that's in another availability zone that's different from the disk, you might experience this error.

To resolve this error, use one of the following solutions.

### Solution 1: ensure disk and node hosting the pod are in the same zone

To make sure that the disk and node that host the pod are in the same availability zone, use [node affinity](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/).

Refer to the following script as an example:

```yml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: topology.disk.csi.azure.com/zone
        operator: In
        values:
        - <region>-Y
```

&lt;region&gt; is the region of the AKS cluster. `Y` represents the availability zone of the disk (for example, westeurope-3).

### Solution 2: use zone-redundant storage (ZRS) disks

[ZRS](/en-us/azure/storage/common/storage-redundancy#zone-redundant-storage) disk volumes can be scheduled on all zone and non-zone agent nodes. For more information, see [Azure disk availability zone support](/en-us/azure/aks/availability-zones#azure-disk-availability-zone-support).

To use a ZRS disk, create a storage class by using `Premium_ZRS` or `StandardSSD_ZRS`, and then deploy the PersistentVolumeClaim (PVC) that references the storage.

For more information about parameters, see [Driver Parameters](/en-us/azure/aks/azure-csi-files-storage-provision#storage-class-parameters-for-dynamic-persistentvolumes)

### Solution 3: Use Azure Files

You can mount [Azure Files](/en-us/azure/storage/files/storage-files-introduction) throughout the network by using NFS or SMB. Azure Files isn't associated with availability zones.

For more information, see the following articles:

- [Dynamically create Azure Files share](/en-us/azure/aks/azure-csi-files-storage-provision#dynamically-provision-a-volume)
- [Manually create Azure Files share](/en-us/azure/aks/azure-csi-files-storage-provision#statically-provision-a-volume)

## Client '&lt;client-ID&gt;' with object ID '&lt;object-ID&gt;' doesn't have authorization to perform action over scope '&lt;disk name&gt;' or scope is invalid

Here are details about this error:

```output
AttachVolume.Attach failed for volume "pv-azuredisk": 
rpc error: code = NotFound 
desc = Volume not found, failed with error: Retriable: false, RetryAfter: 0s, HTTPStatusCode: 403, 
RawError: 
{
"error":
{"code":"AuthorizationFailed",
"message":"The client '<client-ID>' with object id '<object-ID>' does not have authorization to perform action 'Microsoft.Compute/disks/read' over scope '/subscriptions/<subscription-ID>/resourceGroups/<disk-resource-group>/providers/Microsoft.Compute/disks/<disk name>' or the scope is invalid. If access was recently granted, please refresh your credentials."
}
}
```

### Cause: AKS identity doesn't have required authorization over disk

The AKS cluster identity doesn't have the required authorization over the Azure disk. This issue occurs if you create the disk in a resource group other than the infrastructure resource group of the AKS cluster.

### Solution: create role assignment that includes required authorization

Create a role assignment that includes the authorization required per the error. Use a [Contributor](/en-us/azure/role-based-access-control/built-in-roles/general#contributor) role. If you want to use another built-in role, see [Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles).

To assign a Contributor role, use one of the following methods:

- [Use the az role assignment create command](/en-us/azure/role-based-access-control/role-assignments-cli#step-4-assign-role)

    Here's an example:

    ```azurecli
    az role assignment create --assignee <AKS-identity-ID> --role "Contributor" --scope /subscriptions/<subscription-ID>/resourceGroups/<disk-resource-group>/providers/Microsoft.Compute/disks/<disk name>
    ```
- Use the Azure portal

    Refer to detailed steps that are introduced in [Assign Azure roles using the Azure portal](/en-us/azure/role-based-access-control/role-assignments-portal) to assign a Contributor role. If you assign the Contributor role to a managed identity, use the [control plane identity](/en-us/azure/aks/use-managed-identity) to manage Azure disks.

## Volume is already used by pod

Here are the details of this error:

> 
> Multi-Attach error for volume "&lt;PV/disk-name&gt;" Volume is already used by pod(s) &lt;pod-name&gt;

### Cause 1: disk is mounted to multiple pods hosted on different nodes

An Azure disk can be mounted only as [ReadWriteOnce](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes). This makes it available to one node in AKS. That condition means that it can be attached to only one node and mounted to only a pod that's hosted by that node. If you mount the same disk to a pod on another node, you experience this error because the disk is already attached to a node.

### Solution 1: Ensure disk isn't mounted by multiple pods hosted on different nodes

To resolve this error, see [Multi-Attach error](https://github.com/andyzhangx/demo/blob/master/issues/azuredisk-issues.md#25-multi-attach-error).

To share a PersistentVolume across multiple nodes, use [Azure Files](/en-us/azure/aks/azure-csi-files-storage-provision).

### Cause 2: Force reboot the node without deleting the pod

If you forcibly reboot or stop a node running a pod with an Azure Disk mounted without going through the pod deletion process, the scheduler reschedules the pod to another node after a certain period of time. However, after the scheduler reschedules the pod to another node, the pod might temporarily fail to start due to a multi-attach error.

### Solution 2: Typically resolves automatically within 2–3 minutes

This issue is temporary and typically resolves within a few minutes without requiring any additional action. Once the issue is resolved, the pod starts successfully.

This issue occurs because you forcibly rebooted the node while the Azure Disk was still mounted to the previous node and wasn't detached. To prevent this error and delays in pod startup, follow the pod deletion procedure before rebooting or stopping the node.

## StorageAccountType UltraSSD\_LRS can be used only when additionalCapabilities.ultraSSDEnabled is set

Here are the details of this error:

```output
AttachVolume.Attach failed for volume "<Disk/PV name>" : 
rpc error: 
code = Unknown 
desc = Attach volume "/subscriptions/<subscription-ID>/resourceGroups/<disk-resource-group>/providers/Microsoft.Compute/disks/<disk/PV name>" to instance "<AKS node name>" failed with Retriable: false, RetryAfter: 0s, HTTPStatusCode: 400, RawError:
{
  "error": 
{"code": "InvalidParameter",
"message": "StorageAccountType UltraSSD_LRS can be used only when additionalCapabilities.ultraSSDEnabled is set.",
"target": "managedDisk.storageAccountType"
}
}
```

### Cause: ultra disk is attached to node pool with ultra disks disabled

This error indicates that an [ultra disk](/en-us/azure/virtual-machines/disks-enable-ultra-ssd) is trying to attach to a node pool by having ultra disks disabled. By default, AKS node pools have ultra disks disabled.

### Solution: create a node pool that can use ultra disks

To use ultra disks on AKS, create a node pool that has ultra disks support by using the `--enable-ultra-ssd` flag. For more information, see [Use Azure ultra disks on Azure Kubernetes Service](/en-us/azure/aks/use-ultra-disks).

## ApplyFSGroup failed for vol

Here are the details of this error:

> 
> MountVolume.SetUp failed for volume '&lt;PV/disk-name&gt;': applyFSGroup failed for vol /subscriptions/&lt;subscriptionID&gt;/resourceGroups/&lt;infra/disk-resource-group&gt;/providers/Microsoft.Compute/disks/&lt;PV/disk-name&gt;: […]: input/output error

### Cause: Changing ownership and permissions for large volume takes too much time

This error might occur if the volume already contains many files and the `securityContext` uses `fsGroup`. When a volume contains many files and directories, changing the group ID takes too much time. The Kubernetes official documentation [Configure volume permission and ownership change policy for Pods](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods) mentions this situation:

"By default, Kubernetes recursively changes ownership and permissions for the contents of each volume to match the `fsGroup` specified in a Pod's `securityContext` when that volume is mounted. For large volumes, checking and changing ownership and permissions can take a long time, slowing Pod startup. You can use the `fsGroupChangePolicy` field inside a `securityContext` to control the way that Kubernetes checks and manages ownership and permissions for a volume."

### Solution: Set fsGroupChangePolicy field to OnRootMismatch

To resolve this error, set `fsGroupChangePolicy: "OnRootMismatch"` in the `securityContext` of a Deployment, a StatefulSet, or a pod.

OnRootMismatch: Change permissions and ownership only if permission and ownership of the root directory don't match the expected permissions of the volume. This setting helps shorten the time it takes to change ownership and permission of a volume.

For more information, see [Configure volume permission and ownership change policy for Pods](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods).

## Node(s) exceed max volume count

Here are the details of this error:

```output
Events:
Type   Reason      Age  From        Message
----   ------      ---- ----        -------
Warning FailedScheduling 25s  default-scheduler 0/8 nodes are available: 8 node(s) exceed max volume count. preemption: 0/8 nodes are available: 8 No preemption victims found for incoming pod..
```

### Cause: Maximum disk limit is reached

The node reached its maximum disk capacity. In AKS, the number of disks per node depends on the VM size that you configure for the node pool.

### Solution

To resolve the issue, use one of the following methods:

- Add a new node pool with a VM size that supports a higher disk limit.
- Scale the node pool.
- Delete existing disks from the node.

Also, ensure that the number of disks per node doesn't exceed the [Kubernetes default limits](https://kubernetes.io/docs/concepts/storage/storage-limits/#kubernetes-default-limits).

## UNEXPECTED INCONSISTENCY; RUN fsck MANUALLY

Here are the details of this error:

```output
MountVolume.MountDevice failed for volume "<PV name>" : rpc error: code = Internal desc = could not format /dev/disk/azure/scsi1/lun<LUN>(lun: <LUN>), and mount it at /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/<hash>/globalmount, failed with failed to run fsck on disk /dev/disk/azure/scsi1/lun<LUN> with error: 'fsck' found errors on device /dev/disk/azure/scsi1/lun<LUN> with options [-a] but could not correct them output: fsck from util-linux <version>
/dev/<device>: UNEXPECTED INCONSISTENCY; RUN fsck MANUALLY.
    (i.e., without -a or -p options)
 (exit status 4)
```

### Cause: file system damage that automatic repair can't fix

Before the Azure Disk CSI driver mounts an existing ext3 or ext4 file system, it runs `fsck -a` against the device. This automatic mode fixes only minor problems. If the file system has more serious damage, such as corrupted inode tables or journal metadata, `fsck` exits with status 4 and the driver doesn't mount the volume. The pod remains in the **ContainerCreating** status.

Common reasons for file system damage include an unclean node shutdown or crash, a node that's forcibly deleted while the disk is in use, and underlying storage or application-level corruption.

Note

The driver doesn't run `fsck` before it mounts an XFS volume, so this specific error is associated with ext3 and ext4 file systems.

### Diagnose the issue

1. Confirm the error in the pod events.

    ```bash
    kubectl describe pod <pod name> -n <namespace>
    ```
2. Optionally, search the Azure Disk CSI driver logs on the node for more detail. Find the `csi-azuredisk-node` pod that runs on the same node as your pod, and then filter its logs.

    ```bash
    kubectl get pods -n kube-system -l app=csi-azuredisk-node -o wide
    kubectl logs -n kube-system <csi-azuredisk-node pod name> -c azuredisk | grep -i -E "fsck|inconsisten|errors"
    ```

    You might see messages such as `contains a file system with errors, check forced` or `Resize inode not valid`.

### Solution: repair the file system manually

Important

**Always keep a backup of your data.** Repairing a file system is a best-effort operation and can't guarantee that your data is recovered. `fsck` can delete damaged files, truncate them, or move them to the `lost+found` directory. Some data might be lost permanently.

Before you run any repair command, [create a snapshot of the disk](/en-us/azure/virtual-machines/snapshot-copy-managed-disk) (or restore from your regular backup) so that you can go back to the original state if the repair doesn't give the expected result.

Even the automatic `fsck -a` check that the driver runs can modify the disk. Don't run repair commands on a disk that has no backup or snapshot.

Important

Run the read-only check (`fsck.ext4 -n`) first, and review its output before you run the repair command. Ensure that no node or pod is using the disk while the repair is running.

1. Scale down or delete the workload so that no pod uses the persistent volume claim (PVC). Ensure that the disk is detached from the node.
2. Run a temporary privileged pod that uses the same disk as a raw block device. In the following example, `<disk resource ID>` is the `volumeHandle` of the persistent volume (PV):

    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-fsck-repair
    spec:
      capacity:
        storage: <disk size>
      accessModes:
        - ReadWriteOnce
      volumeMode: Block
      persistentVolumeReclaimPolicy: Retain
      storageClassName: ""
      csi:
        driver: disk.csi.azure.com
        volumeHandle: <disk resource ID>
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: pvc-fsck-repair
    spec:
      accessModes:
        - ReadWriteOnce
      volumeMode: Block
      storageClassName: ""
      volumeName: pv-fsck-repair
      resources:
        requests:
          storage: <disk size>
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: fsck-repair
    spec:
      containers:
      - name: repair
        image: ubuntu:22.04
        command: ["sleep", "infinity"]
        securityContext:
          privileged: true
        volumeDevices:
        - name: disk
          devicePath: /dev/repair-disk
      volumes:
      - name: disk
        persistentVolumeClaim:
          claimName: pvc-fsck-repair
    ```

    Warning

    The `devicePath` value (`/dev/repair-disk`) is the name of the device **inside the pod**. Kubernetes maps your disk to that name, and it's the only path that you should use in the following commands. Other disks of the node, including the operating system disk, are also visible in `/dev` of this pod (for example, `/dev/sda` and `/dev/sdc`). Never run `fsck` against them. Choose a `devicePath` that doesn't exist in the pod, and confirm the disk before you repair it (see the next step).
3. Confirm that `/dev/repair-disk` is the disk that you want to repair. Compare its size with the size of the disk in Azure:

    ```bash
    kubectl exec fsck-repair -- lsblk /dev/repair-disk
    ```

    The output is similar to the following example:

    ```output
    NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
    sdc    8:32   0   4G  0 disk
    ```

    The output shows the kernel name of the disk (for example, `sdc`) and its size, which must match the size of the disk in Azure. The kernel name can differ from `/dev/repair-disk`.
4. Install the file system tools and check the file system without changing it:

    ```bash
    kubectl exec fsck-repair -- sh -c "apt-get update && apt-get install -y e2fsprogs"
    kubectl exec fsck-repair -- fsck.ext4 -n /dev/repair-disk
    ```

    If the file system is damaged, the output ends with `WARNING: Filesystem still has errors`.
5. Repair the file system:

    ```bash
    kubectl exec fsck-repair -- fsck.ext4 -y -f /dev/repair-disk
    ```

    The output ends with `FILE SYSTEM WAS MODIFIED`.
6. Verify that the file system is clean:

    ```bash
    kubectl exec fsck-repair -- fsck.ext4 -a /dev/repair-disk
    ```

    The output is similar to `/dev/repair-disk: clean, <n> files, <n> blocks`, and the exit code is `0`.
7. Delete the temporary pod, PVC, and PV. Because the reclaim policy is `Retain`, the disk isn't deleted:

    ```bash
    kubectl delete pod fsck-repair
    kubectl delete pvc pvc-fsck-repair
    kubectl delete pv pv-fsck-repair
    ```
8. Redeploy your workload. The pod should mount the volume and reach the **Running** status.

### Prevention

- **Always back up your data.** Take regular [snapshots](/en-us/azure/aks/azure-disk-csi#create-a-volume-snapshot) or use a backup solution for every persistent volume that holds important data, and test that you can restore from them. Disk redundancy doesn't protect you from file system corruption.
- Avoid forcibly deleting nodes or virtual machine instances that have attached disks. Cordon and drain the node first.

## More information

For more Azure Disk known issues, see [Azure disk plugin known issues](https://github.com/andyzhangx/demo/blob/master/issues/azuredisk-issues.md).