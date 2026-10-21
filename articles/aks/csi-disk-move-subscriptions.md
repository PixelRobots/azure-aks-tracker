---
layout: Conceptual
title: Move Azure Disk persistent volumes to another AKS cluster in the same or a different subscription - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/csi-disk-move-subscriptions
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
description: Learn how to move a persistent volume between Azure Kubernetes Service clusters in the same subscription or a different subscription.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.subservice: aks-storage
ms.date: 2024-04-08T00:00:00.0000000Z
locale: en-us
document_id: bfcbe5f0-1a9e-dadb-5b89-2680897f60c8
document_version_independent_id: e416ee6a-717e-64a9-4df3-dcba6e658253
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/csi-disk-move-subscriptions.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/csi-disk-move-subscriptions
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/csi-disk-move-subscriptions.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 8b2e689b-b5e3-66cd-2d05-5ca9046bb48a
---

# Move Azure Disk persistent volumes to another AKS cluster in the same or a different subscription - Azure Kubernetes Service | Microsoft Learn

This article describes how to safely move Azure Disk persistent volumes from one Azure Kubernetes Service (AKS) cluster to another in the same subscription or in a different subscription. The target subscription must be in the same region.

The sequence of steps to complete this move are:

- To avoid data loss, confirm that the Azure Disk resource state on the source AKS cluster isn't in an **Attached** state.
- Move the Azure Disk resource to the target resource group in the same subscription or a different subscription.
- Validate that the Azure Disk resource move succeeded.
- Create the persistent volume (PV) and the persistent volume claim (PVC) and then mount the moved disk as a volume on a pod on the target cluster.

## Before you begin

- Make sure you have Azure CLI version 2.0.59 or later installed and configured. To find the version, run `az --version`. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Review details and requirements about moving resources between different regions in [Move resources to a new resource group or subscription](/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription). Be sure to review the [checklist before moving resources](/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription#checklist-before-moving-resources) in that article.
- The source cluster must have one or more persistent volumes with an Azure Disk attached.
- You must have an AKS cluster in the target subscription.

## Validate disk volume state

It's important to avoid risk of data corruption, inconsistencies, or data loss while working with persistent volumes. To mitigate these risks during the migration or move process, you must first verify that the disk volume is unattached by performing the following steps.

1. Identify the node resource group hosting the Azure managed disks using the [`az aks show`](/en-us/cli/azure/disk#az-disk-show) command and add the `--query nodeResourceGroup` parameter.

    ```azurecli
    az aks show --resource-group myResourceGroup --name myAKSCluster --query nodeResourceGroup -o tsv
    ```

    The output of the command resembles the following example:

    ```output
    MC_myResourceGroup_myAKSCluster_eastus
    ```
2. List the managed disks using the [`az disk list`](/en-us/cli/azure/disk#az-disk-list) command. Reference the resource group returned in the previous step.

    ```azurecli
    az disk list --resource-group MC_myResourceGroup_myAKSCluster_eastus
    ```

    Review the list and note which disk volumes you plan to move to the other cluster. Also validate the disk state by looking for the `diskState` property. The output of the command is a condensed example.

    ```output
    {
    "LastOwnershipUpdateTime": "2023-04-25T15:09:19.5439836+00:00",
    "creationData": {
      "createOption": "Empty",
      "logicalSectorSize": 4096
    },
    "diskIOPSReadOnly": 3000,
    "diskIOPSReadWrite": 4000,
    "diskMBpsReadOnly": 125,
    "diskMBpsReadWrite": 1000,
    "diskSizeBytes": 1073741824000,
    "diskSizeGB": 1000,
    "diskState": "Unattached",
    ```

    Note

    Note the value of the `resourceGroup` field for each disk that you want to move from the output above. This resource group is the node resource group, not the cluster resource group. You'll need the name of this resource group in order to move the disks.
3. If `diskState` shows `Attached`, first determine whether any workloads are still accessing the volume and stop them. After a period of time, disk state returns state `Unattached` and can then be moved.

## Move the persistent volume

To move the persistent volume or volumes to another AKS cluster, follow the steps described in [Move Azure resources to a new resource group or subscription](/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription). You can use the [Azure portal](/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription#use-the-portal), [Azure PowerShell](/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription#use-azure-powershell), or use the [Azure CLI](/en-us/azure/azure-resource-manager/management/move-resource-group-and-subscription#use-azure-cli) to perform the migration.

During this process, you reference:

- The name or resource ID of the source node resource group hosting the Azure managed disks. You can find the name of the node resource group by navigating to the **Disks** dashboard in the Azure portal and noting the associated resource group for your disk.
- The name or resource ID of the destination resource group to move the managed disks to.
- The name or resource ID of the managed disks resources.

Note

Because of the dependencies between resource providers, this operation can take up to four hours to complete.

## Verify that the disk volume has been moved

After moving the disk volume to the target cluster resource group, validate the resource in the resource group list using the [`az disk list`](/en-us/cli/azure/disk#az-disk-list) command. Reference the destination resource group where the resources were moved. In this example, the disks were moved to a resource group named *MC\_myResourceGroup\_myAKSCluster\_eastus*.

```azurecli
  az disk list --resource-group MC_myResourceGroup_myAKSCluster_eastus
```

## Mount the moved disk as a volume

To mount the moved disk volume, create a static persistent volume with the resource ID copied in the previous steps, the persistent volume claim, and in this example, a simple pod.

1. Create a *pv-azuredisk.yaml* file with a persistent volume. Update the *volumeHandle* field with the disk resource ID from the previous step.

    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-azuredisk
    spec:
      capacity:
        storage: 10Gi
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      storageClassName: managed-csi
      csi:
        driver: disk.csi.azure.com
        readOnly: false
        volumeHandle: /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MC_rg_azure_aks-pvc-target_eastus/providers/Microsoft.Compute/disks/pvc-aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e
        volumeAttributes:
          fsType: ext4
    ```
2. Create a *pvc-azuredisk.yaml* file with a *PersistentVolumeClaim* that uses the *PersistentVolume*.

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
          storage: 10Gi
      volumeName: pv-azuredisk
      storageClassName: managed-csi
    ```
3. Create the *PersistentVolume* and *PersistentVolumeClaim* using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and reference the two YAML files you created.

    ```bash
    kubectl apply -f pv-azuredisk.yaml
    kubectl apply -f pvc-azuredisk.yaml
    ```
4. Verify your *PersistentVolumeClaim* is created and bound to the *PersistentVolume* using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get pvc pvc-azuredisk
    ```

    The output of the command resembles the following example:

    ```output
    NAME            STATUS   VOLUME         CAPACITY    ACCESS MODES   STORAGECLASS   AGE
    pvc-azuredisk   Bound    pv-azuredisk   20Gi        RWO                           5s
    ```
5. To reference your *PersistentVolumeClaim*, create a *azure-disk-pod.yaml* file. In the example manifest, the name of the pod is *mypod*.

    ```yml
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
6. Apply the configuration and mount the volume using the [kubectl apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```bash
    kubectl apply -f azure-disk-pod.yaml
    ```
7. Check the pod status and the data migrated with the volume mounted inside the pod filesystem on `/mnt/azure`. First, get the pod status using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get pods
    ```

    The output of the command resembles the following example:

    ```output
    NAME    READY   STATUS    RESTARTS   AGE
    mypod   1/1     Running   0          4m1s
    ```

    Verify the data inside the mounted volume `/mnt/azure` using the [`kubectl exec`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec) command.

    ```bash
    kubectl exec -it mypod -- ls -l /mnt/azure/
    ```

    The output of the command resembles the following example:

    ```output
    total 28
    -rw-r--r--    1 root     root       0 Jan 11 10:09 file-created-in-source-aks
    ```