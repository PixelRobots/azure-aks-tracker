---
layout: Conceptual
title: Create and Manage Persistent Volumes with Azure Disks in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/create-volume-azure-disk
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
description: Learn how to create and manage persistent volumes using Azure Disks with the Container Storage Interface (CSI) driver in Azure Kubernetes Service (AKS) to provide scalable and reliable storage for your containerized applications.
ms.topic: how-to
ms.subservice: aks-storage
ms.date: 2026-10-16T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: 4aa6f369-8a4a-7945-7fd6-d98478dd9d41
document_version_independent_id: ace14cf5-2007-1659-5231-1f2a8e0c0b3d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/create-volume-azure-disk.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/create-volume-azure-disk
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/create-volume-azure-disk.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c887e555-37e6-1324-a522-9400084fcdfd
---

# Create and Manage Persistent Volumes with Azure Disks in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to dynamically and statically create persistent volumes (PVs) with Azure Disks for use by a single pod in an Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- Azure CLI version 2.0.59 or later installed and configured. Find the version using the `az --version` command. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The [Azure Disks CSI driver](csi-storage-drivers) enabled on your AKS cluster.
- The Azure Disks CSI driver has a per-node volume limit. The volume count changes based on the size of the node/node pool. You can determine the number of volumes that can be allocated per node using the `kubectl get` command. For example:

    ```bash
    kubectl get CSINode <node-name> -o yaml
    ```

    If the per-node volume limit is an issue for your workload, consider using [Azure Container Storage](/en-us/azure/storage/container-storage/container-storage-introduction) for persistent volumes instead of CSI drivers.

## Built-in storage classes for dynamic PVs with Azure Disks

Storage classes define how a unit of storage is dynamically created with a persistent volume.

Each AKS cluster includes built-in storage classes that are configured to work with Azure Disks:

- The *default* storage class provisions a [Standard SSD](/en-us/azure/virtual-machines/disks-types#standard-ssds)Azure Disk.
    - [Standard SSDs](/en-us/azure/virtual-machines/disks-types#standard-ssds) back Standard storage and deliver cost-effective storage while still delivering reliable performance.
- The *managed-csi-premium* storage class provisions a [Premium SSD](/en-us/azure/virtual-machines/disks-types#premium-ssds)Azure Disk.
    - SSD-based high-performance, low-latency disks back [Premium SSDs](/en-us/azure/virtual-machines/disks-types#premium-ssds). They're ideal for virtual machines (VMs) running production workloads. When you use the Azure Disk CSI driver on AKS, you can also use the `managed-csi` storage class that is backed by [Standard SSD](/en-us/azure/virtual-machines/disks-types#standard-ssds)[locally redundant storage (LRS)](/en-us/azure/virtual-machines/disks-redundancy).
- Effective starting with Kubernetes version 1.35: The *managed-csi-premium-v2* storage class provisions a [Premium SSD v2](/en-us/azure/virtual-machines/disks-types#premium-ssd-v2)Azure Disk.
    - [Premium SSD v2](/en-us/azure/virtual-machines/disks-types#premium-ssd-v2) is designed for I/O-intensive enterprise workloads that require sub-millisecond disk latencies and high IOPS and throughput at a low cost. It's ideal for a broad range of workloads such as SQL Server, Oracle, MariaDB, SAP, Cassandra, MongoDB, big data and analytics, and gaming. The built-in `managed-csi-premium-v2` storage class provisions disks as [locally redundant storage (LRS)](/en-us/azure/virtual-machines/disks-redundancy). Premium SSD v2 has [region and zone availability requirements](/en-us/azure/virtual-machines/disks-types#premium-ssd-v2); verify that your node pool zones support Premium SSD v2 before using this storage class.
- Effective starting with Kubernetes version 1.29: When you deploy AKS clusters across one or multiple availability zones, AKS uses [zone-redundant storage (ZRS)](/en-us/azure/virtual-machines/disks-redundancy) to create managed disks within built-in storage classes (excluding `managed-csi-premium-v2`, which provisions LRS disks).
    - [ZRS](/en-us/azure/virtual-machines/disks-redundancy)ensures synchronous replication of your Azure managed disks across multiple Azure availability zones in your chosen region. This redundancy strategy enhances the resilience of your applications and safeguards your data against datacenter failures.
        - However, it's important to note that [ZRS](/en-us/azure/virtual-machines/disks-redundancy) comes at a higher cost compared to [locally redundant storage (LRS)](/en-us/azure/virtual-machines/disks-redundancy). If cost optimization is a priority, you can create a new storage class with the LRS SKU name parameter and use it in your PVC.

Reducing the size of a PVC isn't supported due to the risk of data loss. You can edit an existing storage class using the `kubectl edit sc` command, or you can create your own custom storage class.

Note

Persistent volume claims are specified in GiB, but Azure managed disks are billed by SKU for a specific size. These SKUs range from 32 GiB for S4 or P4 disks to 32 TiB for S80 or P80 disks (in preview). The throughput and IOPS performance of a Premium SSD depends on both the SKU and the instance size of the nodes in the AKS cluster. For more information, see [Pricing and performance of managed disks](https://azure.microsoft.com/pricing/details/managed-disks/).

View the precreated storage classes using the [`kubectl get sc`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. The following example shows the precreated storage classes available within an AKS cluster:

```bash
kubectl get sc
```

Your output should resemble the following example output, which includes the `default`, `managed-csi-premium`, and (on AKS version 1.35 or later) `managed-csi-premium-v2` storage classes that are precreated for Azure Disks:

```output
NAME                  PROVISIONER               AGE
default (default)        disk.csi.azure.com        1h
managed-csi-premium      disk.csi.azure.com        1h
managed-csi-premium-v2   disk.csi.azure.com        1h
```

## Create custom storage classes for dynamic PVs with Azure Disks

The default storage classes are suitable for most scenarios. In some cases, you might want to have your own storage class customized with your own parameters. For example, you might want to change the `volumeBindingMode` class.

You can use a `volumeBindingMode: Immediate` class that guarantees it occurs immediately once the PVC is created. When your node pools are topology constrained, for example when using availability zones, PVs would be bound or provisioned without knowledge of the pod's scheduling requirements.

To address this scenario, you can use `volumeBindingMode: WaitForFirstConsumer`, which delays the binding and provisioning of a PV until a pod that uses the PVC is created. This way, the PV conforms and is provisioned in the availability zone (or other topology) specified by the pod's scheduling constraints. The default storage classes use `volumeBindingMode: WaitForFirstConsumer` class.

1. Create a file named `sc-azuredisk-csi-waitforfirstconsumer.yaml` and paste in the following YAML manifest. The storage class is the same as our `managed-csi` storage class, but with a different `volumeBindingMode` class.

    ```yaml
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: azuredisk-csi-waitforfirstconsumer
    provisioner: disk.csi.azure.com
    parameters:
      skuName: StandardSSD_LRS
    allowVolumeExpansion: true
    reclaimPolicy: Delete
    volumeBindingMode: WaitForFirstConsumer
    ```
2. Create the storage class using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify your `sc-azuredisk-csi-waitforfirstconsumer.yaml` file:

    ```bash
    kubectl apply -f sc-azuredisk-csi-waitforfirstconsumer.yaml
    ```

    Your output should resemble the following example output:

    ```output
    storageclass.storage.k8s.io/azuredisk-csi-waitforfirstconsumer created
    ```

## Storage class parameters for dynamic PVs with Azure Disks

The following table includes parameters you can use to define a custom storage class for your dynamic persistent volume claims (PVCs) with Azure Disks:

| Name | Meaning | Available values | Required | Default value |
| --- | --- | --- | --- | --- |
| `skuName` | Azure Disks storage account type (alias: `storageAccountType`). `PremiumV2_LRS` and `UltraSSD_LRS` support instant access for incremental snapshot restores. | `Standard_LRS`, `Premium_LRS`, `StandardSSD_LRS`, `PremiumV2_LRS`, `UltraSSD_LRS`, `Premium_ZRS`, `StandardSSD_ZRS` | No | `StandardSSD_LRS` |
| `fsType` | Filesystem type | `ext4`, `ext3`, `ext2`, `xfs`, `btrfs` for Linux `ntfs` for Windows | No | `ext4` for Linux `ntfs` for Windows |
| `cachingMode` | [Azure Data Disk Host Cache Setting](/en-us/azure/virtual-machines/windows/premium-storage-performance#disk-caching) (PremiumV2\_LRS and UltraSSD\_LRS only support `None` caching mode) | `None`, `ReadOnly`, `ReadWrite` | No | `ReadOnly` |
| `resourceGroup` | Specify the resource group for the Azure Disks | Existing resource group name | No | If empty, driver uses the same resource group name as current AKS cluster |
| `DiskIOPSReadWrite` | [Ultra Disk](/en-us/azure/virtual-machines/linux/disks-ultra-ssd) or [Premium SSD v2](/en-us/azure/virtual-machines/disks-types#premium-ssd-v2) IOPS capability (minimum: 2 IOPS/GiB) | 100~160000 | No | `500` |
| `DiskMBpsReadWrite` | [Ultra Disk](/en-us/azure/virtual-machines/linux/disks-ultra-ssd) or [Premium SSD v2](/en-us/azure/virtual-machines/disks-types#premium-ssd-v2) throughput capability (minimum: 0.032/GiB) | 1~2000 | No | `100` |
| `LogicalSectorSize` | Logical sector size in bytes for Ultra Disk. | `512`, `4096` | No | `4096` |
| `tags` | Azure Disk [tags](/en-us/azure/azure-resource-manager/management/tag-resources) | Tag format: `key1=val1,key2=val2` | No | "" |
| `diskEncryptionSetID` | Resource ID of the disk encryption set to use for [enabling encryption at rest](/en-us/azure/virtual-machines/windows/disk-encryption) | format: `/subscriptions/{subs-id}/resourceGroups/{rg-name}/providers/Microsoft.Compute/diskEncryptionSets/{diskEncryptionSet-name}` | No | "" |
| `diskEncryptionType` | Encryption type of the disk encryption set. | `EncryptionAtRestWithCustomerKey` (by default), `EncryptionAtRestWithPlatformAndCustomerKeys` | No | `EncryptionAtRestWithCustomerKey` |
| `writeAcceleratorEnabled` | [Write accelerator on Azure Disks](/en-us/azure/virtual-machines/windows/how-to-enable-write-accelerator) | `true`, `false` | No | "" |
| `networkAccessPolicy` | `NetworkAccessPolicy` property to prevent generation of the SAS URI for a disk or a snapshot. | `AllowAll`, `DenyAll`, `AllowPrivate` | No | `DenyAll` |
| `publicNetworkAccess` | Enable or disable public access to the underlying data of a disk over the internet, even when the `networkAccessPolicy` is set to `AllowAll`. | `Enabled`, `Disabled` | No | `Disabled` |
| `diskAccessID` | Azure resource ID of the DiskAccess resource to use private endpoints on disks |  | No | `` |
| `enableBursting` | [Enable on-demand bursting](/en-us/azure/virtual-machines/disk-bursting) beyond the provisioned performance target of the disk. On-demand bursting should only be applied to Premium disk and when the disk size &gt; 512 GB. Ultra and shared disk isn't supported. Bursting is disabled by default. | `true`, `false` | No | `false` |
| `userAgent` | User agent used for [customer usage attribution](/en-us/azure/marketplace/azure-partner-customer-usage-attribution) |  | No | Generated user agent format: `driverName/driverVersion compiler/version (OS-ARCH)` |
| `subscriptionID` | Specify Azure subscription ID where the Azure Disks is created. If not empty, `resourceGroup` must be provided. | Azure subscription ID | No |  |
| --- | **The following parameters are only for v2** | --- | --- | --- |
| `maxShares` | The total number of shared disk mounts allowed for the disk. Setting the value to 2 or more enables attachment replicas. | Supported values depend on the disk size. See [Share an Azure managed disk](/en-us/azure/virtual-machines/disks-shared) for supported values. | No | 1 |
| `maxMountReplicaCount` | The number of replicas attachments to maintain. | This value must be in the range `[0..(maxShares - 1)]` | No | If `accessMode` is `ReadWriteMany`, the default is `0`. Otherwise, the default is `maxShares - 1` |

Important

The `tags` storage class parameter is applied to the managed disk when the Azure Disk CSI driver provisions the volume. After the persistent volume is created, the `PersistentVolume` spec is immutable, so editing or patching the PV to change tags or other volume attributes fails. Updating the storage class later affects only newly provisioned volumes.

To update tags on an existing volume, change them on the underlying managed disk in Azure. This operation doesn't interrupt existing mounts, pods, or data access, and updated Azure tags aren't synchronized back to the Kubernetes PV YAML or metadata. For example:

```azurecli
az disk update \
    --name myManagedDisk \
    --resource-group MC_myResourceGroup_myAKSCluster_eastus \
    --set tags.abc=ABC123
```

## Create a PVC with Azure Disks

A PVC automatically provisions storage based on a storage class. In this case, a PVC can use one of the precreated storage classes to create a Standard or Premium Azure managed disk.

1. Create a file named `azure-pvc.yaml` and paste in the following manifest. The claim requests a disk named `azure-managed-disk` that's *10 GB* in size with *ReadWriteOnce* access. The *managed-csi* storage class is specified as the storage class.

    ```yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: azure-managed-disk
    spec:
      accessModes:
        - ReadWriteOnce
      storageClassName: managed-csi
      resources:
        requests:
          storage: 10Gi
    ```

    Tip

    To create a disk that uses premium storage, use `storageClassName: managed-csi-premium` rather than *managed-csi*. On AKS version 1.35 or later, you can also use `storageClassName: managed-csi-premium-v2` to provision a [Premium SSD v2](/en-us/azure/virtual-machines/disks-types#premium-ssd-v2) disk.
2. Create the PVC using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify your *azure-pvc.yaml* file:

    ```bash
    kubectl apply -f azure-pvc.yaml
    ```

    Your output should resemble the following example output:

    ```output
    persistentvolumeclaim/azure-managed-disk created
    ```
3. Verify the PV is ready to be used by a pod using the `kubectl describe pvc` command:

    ```bash
    kubectl describe pvc azure-managed-disk
    ```

    Your output should resemble the following example output, which shows the PV is in a *Pending* state:

    ```output
    Name:            azure-managed-disk
    Namespace:       default
    StorageClass:    managed-csi
    Status:          Pending
    [...]
    ```

## Create a pod that uses a PVC with Azure Disks

1. Create a file named `azure-pvc-disk.yaml` and paste in the following manifest. This manifest creates a basic NGINX pod that uses the persistent volume claim named *azure-managed-disk* to mount the Azure Disk at the path `/mnt/azure`. (For Windows Server containers, specify a `mountPath` using the Windows path convention, such as *'D:'*).

    ```yaml
    kind: Pod
    apiVersion: v1
    metadata:
      name: mypod
    spec:
      containers:
        - name: mypod
          image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 250m
              memory: 256Mi
          volumeMounts:
            - mountPath: "/mnt/azure"
              name: volume
              readOnly: false
      volumes:
        - name: volume
          persistentVolumeClaim:
            claimName: azure-managed-disk
    ```
2. Create the pod using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f azure-pvc-disk.yaml
    ```

    Your output should resemble the following example output:

    ```output
    pod/mypod created
    ```
3. You now have a running pod with your Azure Disk mounted in the `/mnt/azure` directory. Check the pod configuration using the [`kubectl describe`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command.

    ```bash
    kubectl describe pod mypod
    ```

    Your output should resemble the following example output, which shows the volume named *volume* is using the PVC named *azure-managed-disk*:

    ```output
    [...]
    Volumes:
    volume:
        Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
        ClaimName:  azure-managed-disk
        ReadOnly:   false
        default-token-smm2n:
        Type:        Secret (a volume populated by a Secret)
        SecretName:  default-token-smm2n
        Optional:    false
    [...]
    Events:
    Type    Reason                 Age   From                               Message
    ----    ------                 ----  ----                               -------
    Normal  Scheduled              2m    default-scheduler                  Successfully assigned mypod to aks-nodepool1-12345678-9
    Normal  SuccessfulMountVolume  2m    kubelet, aks-nodepool1-12345678-9  MountVolume.SetUp succeeded for volume "default-token-smm2n"
    Normal  SuccessfulMountVolume  1m    kubelet, aks-nodepool1-12345678-9  MountVolume.SetUp succeeded for volume "pvc-abc0d123-4e5f-67g8-901h-ijk23l45m678"
    [...]
    ```

## Volume snapshot class parameters for Azure Disks

The Azure Disks CSI driver supports creating [snapshots of persistent volumes](https://kubernetes-csi.github.io/docs/snapshot-restore-feature.html). As part of this capability, the driver can perform either *full* or [*incremental*](/en-us/azure/virtual-machines/disks-incremental-snapshots) snapshots depending on the value set in the `incremental` parameter.

The following table provides details for the parameters you can use to define a custom volume snapshot class for your volume snapshots with Azure Disks:

| Name | Meaning | Available values | Required | Default value |
| --- | --- | --- | --- | --- |
| `resourceGroup` | Resource group for storing snapshots | EXISTING RESOURCE GROUP | No | If not specified, snapshot will be stored in the same resource group as source Azure Disks |
| `incremental` | Take full or [incremental](/en-us/azure/virtual-machines/disks-incremental-snapshots) snapshots | `true`, `false` | No | `true` |
| `tags` | Azure Disks [tags](/en-us/azure/azure-resource-manager/management/tag-resources) | Tag format: 'key1=val1,key2=val2' | No | "" |
| `userAgent` | User agent used for [customer usage attribution](/en-us/azure/marketplace/azure-partner-customer-usage-attribution) |  | No | Generated user agent formatted `driverName/driverVersion compiler/version (OS-ARCH)` |
| `subscriptionID` | Specify Azure subscription ID where Azure Disks will be created | Azure subscription ID | No | If not empty, `resourceGroup` must be provided, `incremental` must set as `false` |

## Create a volume snapshot from a PVC with Azure Disks

Note

Before proceeding, ensure that the application isn't writing data to the source disk.

1. Create a [volume snapshot class](https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/deploy/example/snapshot/storageclass-azuredisk-snapshot.yaml) using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/storageclass-azuredisk-snapshot.yaml
    ```

    Your output should resemble the following example output:

    ```output
    volumesnapshotclass.snapshot.storage.k8s.io/csi-azuredisk-vsc created
    ```
2. Create a [volume snapshot](https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/deploy/example/snapshot/azuredisk-volume-snapshot.yaml) from the dynamic PVC you created earlier in this tutorial using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/azuredisk-volume-snapshot.yaml
    ```

    Your output should resemble the following example output:

    ```output
    volumesnapshot.snapshot.storage.k8s.io/azuredisk-volume-snapshot created
    ```
3. Verify the volume snapshot was created successfully using the `kubectl describe` command:

    ```bash
    kubectl describe volumesnapshot azuredisk-volume-snapshot
    ```

    Your output should resemble the following example output, which shows the volume snapshot is ready to be used:

    ```output
    Name:         azuredisk-volume-snapshot
    Namespace:    default
    Labels:       <none>
    Annotations:  API Version:  snapshot.storage.k8s.io/v1
    Kind:         VolumeSnapshot
    Metadata:
      Creation Timestamp:  2020-08-27T05:27:58Z
      Finalizers:
        snapshot.storage.kubernetes.io/volumesnapshot-as-source-protection
        snapshot.storage.kubernetes.io/volumesnapshot-bound-protection
      Generation:        1
      Resource Version:  714582
      Self Link:         /apis/snapshot.storage.k8s.io/v1/namespaces/default/volumesnapshots/azuredisk-volume-snapshot
      UID:               00aa00aa-bb11-cc22-dd33-44ee44ee44ee
    Spec:
      Source:
        Persistent Volume Claim Name:  pvc-azuredisk
      Volume Snapshot Class Name:      csi-azuredisk-vsc
    Status:
      Bound Volume Snapshot Content Name:  snapcontent-00aa00aa-bb11-cc22-dd33-44ee44ee44ee
      Creation Time:                       2020-08-31T05:27:59Z
      Ready To Use:                        true
      Restore Size:                        10Gi
    Events:                                <none>
    ```

## Create a new PVC based on a volume snapshot with Azure Disks

You can create a new PVC based on a volume snapshot. In this section, we use the snapshot from the Create a volume snapshot from a PVC with Azure Disks section and create a [new PVC](https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/deploy/example/snapshot/pvc-azuredisk-snapshot-restored.yaml) and a [new pod](https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/deploy/example/snapshot/nginx-pod-restored-snapshot.yaml) to consume it.

1. Create the PVC and pod using the following [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) commands:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/pvc-azuredisk-snapshot-restored.yaml
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/nginx-pod-restored-snapshot.yaml
    ```

    Your output should resemble the following example output:

    ```output
    persistentvolumeclaim/pvc-azuredisk-snapshot-restored created
    pod/nginx-restored created
    ```
2. Validate it's the same PVC created before by checking the contents of the volume using the `kubectl exec` command to execute the `ls` command within the pod:

    ```bash
    kubectl exec nginx-restored -- ls /mnt/azuredisk
    ```

    Your output should resemble the following example output, which shows the same content as the original PVC, including the `test.txt` file that was created in the original PVC:

    ```output
    lost+found
    outfile
    test.txt
    ```

## Clone volumes with Azure Disks

A cloned volume is defined as a duplicate of an existing Kubernetes volume. For more information on cloning volumes in Kubernetes, see the conceptual documentation for [volume cloning](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#volume-cloning).

The CSI driver for Azure Disks supports volume cloning. To demonstrate, create a [cloned volume](https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/deploy/example/cloning/nginx-pod-restored-cloning.yaml) of the dynamic PVC you created earlier in this tutorial and [a new pod to consume it](https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/deploy/example/cloning/nginx-pod-restored-cloning.yaml).

1. Create the cloned PVC and pod using the following [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) commands:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/cloning/pvc-azuredisk-cloning.yaml
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/cloning/nginx-pod-restored-cloning.yaml
    ```

    Your output should resemble the following example output:

    ```output
    persistentvolumeclaim/pvc-azuredisk-cloning created
    pod/nginx-restored-cloning created
    ```
2. Verify the cloned volume has the same content as the original volume by checking the contents of the volume using the `kubectl exec` command to execute the `ls` command within the pod:

    ```bash
    kubectl exec nginx-restored-cloning -- ls /mnt/azuredisk
    ```

    Your output should resemble the following example output, which shows the same content as the original PVC, including the `test.txt` file that was created in the original PVC:

    ```output
    lost+found
    outfile
    test.txt
    ```

## Resize a persistent volume without downtime with Azure Disks

Note

Shrinking persistent volumes is currently not supported. Trying to patch an existing PVC with a smaller size than the current one leads to the following error message:

`The persistentVolumeClaim "pvc-azuredisk" is invalid: spec.resources.requests.storage: Forbidden: field can not be less than previous value.`

Important

You can expand a persistent volume without downtime for volumes up to 4 TiB. To expand a **Standard HDD**, **Standard SSD**, or **Premium SSD** volume beyond 4 TiB, you must unmount the disk and detach it from the AKS node. Before you update the `PersistentVolumeClaim` (PVC), scale the workload down to zero replicas to ensure the volume is detached.

This limitation doesn't apply to **Premium SSD v2** or **Ultra Disk** volumes, which support online expansion beyond 4 TiB.

For more information, see [Expand an Azure managed disk](/en-us/azure/virtual-machines/linux/expand-disks?tabs=ubuntu#expand-an-azure-managed-disk).

You can request a larger volume for a PVC by editing the PVC object to specify a larger size. This change triggers the expansion of the underlying volume that backs the PV. A new PV is never created to satisfy the claim. Instead, an existing volume is resized.

In AKS, the built-in `managed-csi` storage class already supports expansion, so you can use the dynamic PVC you created earlier in this tutorial. The PVC requested a 10-Gi persistent volume.

1. Check the current size of the volume using the `kubectl exec` command to execute the `df -h` command within the pod:

    ```bash
    kubectl exec -it nginx-azuredisk -- df -h /mnt/azuredisk
    ```

    Your output should resemble the following example output, which shows the current size of the volume is 10 Gi:

    ```output
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sdc        9.8G   42M  9.8G   1% /mnt/azuredisk
    ```
2. Expand the PVC by increasing the `spec.resources.requests.storage` field using the `kubectl patch` command. In this example, we increase the size of the PVC to 15 Gi:

    ```bash
    kubectl patch pvc pvc-azuredisk --type merge --patch '{"spec": {"resources": {"requests": {"storage": "15Gi"}}}}'
    ```

    Your output should resemble the following example output:

    ```output
    persistentvolumeclaim/pvc-azuredisk patched
    ```
3. Check the PV to confirm the new size is reflected in the PV using the `kubectl get pv` command:

    ```bash
    kubectl get pv
    ```

    Your output should resemble the following example output, which shows the PV has been resized to 15 Gi:

    ```output
    NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                     STORAGECLASS   REASON   AGE
    pvc-a0a0a0a0-bbbb-cccc-dddd-e1e1e1e1e1e1   15Gi       RWO            Delete           Bound    default/pvc-azuredisk                     managed-csi             2d2h
    (...)
    ```
4. After a few minutes, check the PVC to confirm the new size is reflected in the PVC using the `kubectl get pvc` command:

    ```bash
    kubectl get pvc pvc-azuredisk
    ```

    Your output should resemble the following example output, which shows the PVC has been resized to 15 Gi:

    ```output
    NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    pvc-azuredisk   Bound    pvc-a0a0a0a0-bbbb-cccc-dddd-e1e1e1e1e1e1   15Gi       RWO            managed-csi    2d2h
    ```
5. Confirm the size of the disk in the pod has been updated to the new size using the `kubectl exec` command to execute the `df -h` command within the pod:

    ```bash
    kubectl exec -it nginx-azuredisk -- df -h /mnt/azuredisk
    ```

    Your output should resemble the following example output, which shows the size of the volume has been updated to 15 Gi:

    ```output
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sdc         15G   46M   15G   1% /mnt/azuredisk
    ```

## On-demand bursting for Premium SSDs with Azure Disks

The on-demand disk bursting model allows disk bursts whenever its needs exceed its current capacity. This model generates extra charges anytime the disk bursts. On-demand bursting is only available for Premium SSDs larger than 512 GiB. For more information on Premium SSDs provisioned IOPS and throughput per disk, see [Premium SSD size](/en-us/azure/virtual-machines/disks-types#premium-ssds). Alternatively, credit-based bursting is where the disk will burst only if it has burst credits accumulated in its credit bucket. Credit-based bursting doesn't generate extra charges when the disk bursts. Credit-based bursting is only available for Premium SSDs 512 GiB and smaller, and Standard SSDs 1024 GiB and smaller. For more information on on-demand bursting, see [On-demand bursting](/en-us/azure/virtual-machines/disk-bursting#on-demand-bursting).

Important

The default `managed-csi-premium` storage class has on-demand bursting disabled and uses credit-based bursting. Any Premium SSD dynamically created by a persistent volume claim based on the default `managed-csi-premium` storage class also has on-demand bursting disabled.

To create a Premium SSD persistent volume with [on-demand bursting](/en-us/azure/virtual-machines/disk-bursting#on-demand-bursting) enabled, you can create a new storage class with the [enableBursting](https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/driver-parameters.md) parameter set to `true` as shown in the following YAML template. For more information on enabling on-demand bursting, see [On-demand bursting](/en-us/azure/virtual-machines/disk-bursting#on-demand-bursting). For more information on building your own storage class with on-demand bursting enabled, see [Create a Burstable Managed CSI Premium Storage Class](https://github.com/Azure-Samples/burstable-managed-csi-premium).

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: burstable-managed-csi-premium
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_LRS
  enableBursting: "true"
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

## Use Azure Disks with Windows containers

The Azure Disk CSI driver supports Windows nodes and containers. If you want to use Windows containers, follow the [Windows containers quickstart](learn/quick-kubernetes-deploy-cli) to add a Windows node pool. After you have a Windows node pool, you can use the built-in storage classes like `managed-csi`.

1. Deploy an example [Windows-based stateful set](https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/deploy/example/windows/statefulset.yaml) that saves timestamps into the file `data.txt` using the following [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/windows/statefulset.yaml
    ```

    Your output should resemble the following example output:

    ```output
    statefulset.apps/busybox-azuredisk created
    ```
2. Validate the content of the file `data.txt` in the pod using the `kubectl exec` command to execute the `type` command within the pod:

    ```bash
    kubectl exec -it statefulset-azuredisk-win-0 -- powershell -c "type c:/mnt/azuredisk/data.txt"
    ```

    Your output should resemble the following example output, which shows the timestamps that are being saved into the file `data.txt`:

    ```output
    2020-08-27 08:13:41Z
    2020-08-27 08:13:42Z
    2020-08-27 08:13:44Z
    (...)
    ```

## Create a static PV with Azure Disks

The following sections provide instructions for creating a static PV with Azure Disks. A static PV is a persistent volume that an administrator creates manually. This PV is available for use by pods in the cluster. To use a static PV, you create a PVC that references the PV, and then create a pod that references the PVC.

### Storage class parameters for static PVs with Azure Disks

The following table includes parameters you can use to define a custom storage class for your static PVCs with Azure Disks:

| Name | Meaning | Available values | Required | Default value |
| --- | --- | --- | --- | --- |
| `volumeHandle` | Azure disk URI | `/subscriptions/{sub-id}/resourceGroups/{group-name}/providers/microsoft.compute/disks/{disk-id}` | Yes | N/A |
| `volumeAttributes.fsType` | Filesystem type | `ext4`, `ext3`, `ext2`, `xfs`, `btrfs` for Linux `ntfs` for Windows | No | `ext4` for Linux `ntfs` for Windows |
| `volumeAttributes.partition` | Partition number of the existing disk (only supported on Linux) | `1`, `2`, `3` | No | Empty (no partition) Make sure partition format is: `-part1` |
| `volumeAttributes.cachingMode` | [Disk host cache setting](/en-us/azure/virtual-machines/windows/premium-storage-performance#disk-caching) | `None`, `ReadOnly`, `ReadWrite` | No | `ReadOnly` |

### Create an Azure disk

When you create an Azure disk for use with AKS, you can create the disk resource in the node resource group. This approach allows the AKS cluster to access and manage the disk resource. If you instead create the disk in a separate resource group, you must grant the AKS managed identity for your cluster the `Contributor` role to the disk's resource group.

1. Identify the node resource group name using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command with the `--query nodeResourceGroup` parameter.

    ```azurecli
    az aks show --resource-group myResourceGroup --name myAKSCluster --query nodeResourceGroup -o tsv
    ```

    Your output should resemble the following example output, which shows the node resource group name for the AKS cluster:

    ```output
    MC_myResourceGroup_myAKSCluster_eastus
    ```
2. Create a disk using the [`az disk create`](/en-us/cli/azure/disk#az-disk-create) command. Specify the node resource group name and a name for the disk resource, such as *myAKSDisk*. The following example creates a 20 GiB disk and outputs the ID of the disk after it's created. If you need to create a disk for use with Windows Server containers, add the `--os-type windows` parameter to correctly format the disk.

    ```azurecli
    az disk create \
      --resource-group MC_myResourceGroup_myAKSCluster_eastus \
      --name myAKSDisk \
      --size-gb 20 \
      --query id --output tsv
    ```

    Note

    Azure Disks are billed by SKU for a specific size. These SKUs range from 32 GiB for S4 or P4 disks to 32 TiB for S80 or P80 disks (in preview). The throughput and IOPS performance of a Premium managed disk depends on both the SKU and the instance size of the nodes in the AKS cluster. See [Pricing and Performance of Managed Disks](https://azure.microsoft.com/pricing/details/managed-disks/).

    Your output should resemble the following example output, which shows the resource ID of the disk that was created:

    ```output
    /subscriptions/<subscriptionID>/resourceGroups/MC_myResourceGroup_myAKSCluster_eastus/providers/Microsoft.Compute/disks/myAKSDisk
    ```

### Create a PV and PVC that reference the Azure disk

1. Create a *pv-azuredisk.yaml* file with a PV using the following example manifest. Update `volumeHandle` with disk resource ID from the previous step. For Windows Server containers, specify *ntfs* for the parameter `fsType`.

    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      annotations:
        pv.kubernetes.io/provisioned-by: disk.csi.azure.com
      name: pv-azuredisk
    spec:
      capacity:
        storage: 20Gi
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      storageClassName: managed-csi
      csi:
        driver: disk.csi.azure.com
        volumeHandle: /subscriptions/<subscriptionID>/resourceGroups/MC_myResourceGroup_myAKSCluster_eastus/providers/Microsoft.Compute/disks/myAKSDisk
        volumeAttributes:
          fsType: ext4
    ```

    As noted in Create an Azure disk, if the disk for the `volumeHandle` was created in a separate resource group, you need to grant the AKS cluster's managed identity the `Contributor` role to the disk's resource group.
2. Create a *pvc-azuredisk.yaml* file with a PVC that uses the PV using the following example manifest:

    ```yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: pvc-azuredisk
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 20Gi
      volumeName: pv-azuredisk
      storageClassName: managed-csi
    ```
3. Create the PV and PVC using the following [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) commands:

    ```bash
    kubectl apply -f pv-azuredisk.yaml
    kubectl apply -f pvc-azuredisk.yaml
    ```
4. Verify your PVC was successfully created and bound to the PV using the `kubectl get pvc` command:

    ```bash
    kubectl get pvc pvc-azuredisk
    ```

    Your output should resemble the following example output, which shows the PVC is in a *Bound* state:

    ```output
    NAME            STATUS   VOLUME         CAPACITY    ACCESS MODES   STORAGECLASS   AGE
    pvc-azuredisk   Bound    pv-azuredisk   20Gi        RWO                           5s
    ```

### Create a pod that uses the PVC with Azure Disks

1. Create an *azure-disk-pod.yaml* file to reference your PVC using the following example manifest. (For Windows Server containers, specify a `mountPath` using the Windows path convention, such as *'D:'*).

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: mypod
    spec:
      nodeSelector:
        kubernetes.io/os: linux
      containers:
      - image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
        name: mypod
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        volumeMounts:
          - name: azure
            mountPath: /mnt/azure
      volumes:
        - name: azure
          persistentVolumeClaim:
            claimName: pvc-azuredisk
    ```
2. Apply the configuration and mount the volume using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f azure-disk-pod.yaml
    ```

## Clean up resources

- Remove the resources you created in this tutorial using the following [`kubectl delete`][kubectl-delete] commands:

    ```bash
    # Remove the pod
    kubectl delete -f azure-pvc-disk.yaml
    
    # Remove the persistent volume claim
    kubectl delete -f azure-pvc.yaml
    ```