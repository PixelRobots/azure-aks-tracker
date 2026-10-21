---
layout: Conceptual
title: Enable Ultra Disk support on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-ultra-disks
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
description: Learn how to enable and configure Ultra Disks in an Azure Kubernetes Service (AKS) cluster
ms.topic: how-to
ms.subservice: aks-storage
ms.date: 2025-10-08T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 555684aa-d076-3dd3-263f-6da068933a0c
document_version_independent_id: 1367daee-43e7-5267-2822-b5e6c06b9bb4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-ultra-disks.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-ultra-disks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-ultra-disks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: b9ee27d0-6fd5-2dab-0547-cb1d2e85468d
---

# Enable Ultra Disk support on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

[Azure Ultra Disks](/en-us/azure/virtual-machines/disks-types#ultra-disks) offer high throughput, high IOPS, and consistent low latency disk storage for your stateful applications. One major benefit of Ultra Disks is the ability to dynamically change the performance of the SSD along with your workloads without the need to restart your agent nodes. Ultra Disks are suited for data-intensive workloads.

This article describes how to configure a new or existing AKS cluster to use Azure Ultra Disks.

## Before you begin

This feature can only be set at cluster creation or when creating a node pool.

### Limitations

- Azure Ultra Disks require node pools deployed in availability zones and regions that support these disks, and are only supported by specific virtual machine (VM) series. Review the corresponding table under the [Ultra Disk limitations](/en-us/azure/virtual-machines/disks-types#ultra-disk-limitations) section for more information.
- Ultra Disks can't be used with some features and functionality, such as availability sets or Azure Disk Encryption. Review the [Ultra Disk limitations](/en-us/azure/virtual-machines/disks-types#ultra-disk-limitations) for the latest information.

## Create a cluster that can use Ultra Disks

Create a resource group for the cluster.

```azurecli
az group create --name MyResourceGroup --location westus2
```

Create an AKS cluster that's able to use Azure Ultra Disks with the following CLI commands. Use the `--enable-ultra-ssd` parameter to set the `EnableUltraSSD` feature.

```azurecli
az aks create \
  --resource-group MyResourceGroup \
  --name myAKSCluster \
  --location westus2 \
  --node-vm-size Standard_D2s_v3 \
  --zones 1 \
  --node-count 2 \
  --enable-ultra-ssd \
  --generate-ssh-keys
```

If you want to create a cluster without Ultra Disk support, you can do so by omitting the `--enable-ultra-ssd` parameter.

After a successful cluster deployment, run the following command that sets the context to your new cluster.

```azurecli
az aks get-credentials --resource-group MyResourceGroup --name myAKSCluster
```

## Enable Ultra Disks on an existing cluster

You can enable Ultra Disks on an existing cluster by adding a new node pool to your cluster that supports Ultra Disks. Configure a new node pool to use Ultra Disks by using the `--enable-ultra-ssd` parameter with the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command.

If you want to create new node pools without support for Ultra Disks, you can do so by excluding the `--enable-ultra-ssd` parameter.

## Use Ultra Disks dynamically with a storage class

To use Ultra Disks in your deployments or stateful sets, you can use a [storage class for dynamic provisioning](azure-disk-csi).

### Create the storage class

A storage class is used to define how a unit of storage is dynamically created with a persistent volume. For more information on Kubernetes storage classes, see [Kubernetes storage classes](https://kubernetes.io/docs/concepts/storage/storage-classes/). In this example, you create a storage class that references Ultra Disks.

1. Create a file named `azure-ultra-disk-sc.yaml` and copy in the following manifest:

    ```yaml
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: ultra-disk-sc
    provisioner: disk.csi.azure.com # replace with "kubernetes.io/azure-disk" if aks version is less than 1.21
    volumeBindingMode: WaitForFirstConsumer # optional, but recommended if you want to wait until the pod that will use this disk is created
    parameters:
      skuname: UltraSSD_LRS
      kind: managed
      cachingMode: None
      diskIopsReadWrite: "2000"  # minimum value: 2 IOPS/GiB
      diskMbpsReadWrite: "320"   # minimum value: 0.032/GiB
    ```
2. Create the storage class using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify your `azure-ultra-disk-sc.yaml` file.

    ```bash
    kubectl apply -f azure-ultra-disk-sc.yaml
    ```

    Your output should resemble the following example output:

    ```console
    storageclass.storage.k8s.io/ultra-disk-sc created
    ```

## Create a persistent volume claim

A persistent volume claim (PVC) is used to automatically provision storage based on a storage class. In this case, a PVC can use the previously created storage class to create an Ultra Disk.

1. Create a file named `azure-ultra-disk-pvc.yaml` and copy in the following manifest:

    ```yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: ultra-disk
    spec:
      accessModes:
      - ReadWriteOnce
      storageClassName: ultra-disk-sc
      resources:
        requests:
          storage: 1000Gi
    ```

    The claim requests a disk named `ultra-disk` that is `1000 GB` in size with `ReadWriteOnce` access. The `ultra-disk-sc` storage class is specified as the storage class.
2. Create the persistent volume claim using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify your `azure-ultra-disk-pvc.yaml` file.

    ```bash
    kubectl apply -f azure-ultra-disk-pvc.yaml
    ```

    Your output should resemble the following example output:

    ```console
    persistentvolumeclaim/ultra-disk created
    ```

## Use the persistent volume

After the persistent volume claim is created and the disk successfully provisioned, a pod can be created with access to the disk. The following manifest creates a basic NGINX pod that uses the persistent volume claim named `ultra-disk` to mount the Azure disk at the path `/mnt/azure`.

1. Create a file named `nginx-ultra.yaml` and copy in the following manifest:

    ```yaml
    kind: Pod
    apiVersion: v1
    metadata:
      name: nginx-ultra
    spec:
      containers:
      - name: nginx-ultra
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
      volumes:
        - name: volume
          persistentVolumeClaim:
            claimName: ultra-disk
    ```
2. Create the pod using [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command and specify your `nginx-ultra.yaml` file.

    ```console
    kubectl apply -f nginx-ultra.yaml
    ```

    Your output should resemble the following example output:

    ```console
    pod/nginx-ultra created
    ```

    You now have a running pod with your Azure disk mounted in the `/mnt/azure` directory.
3. See your configuration details using the `kubectl describe pod` command and specify your `nginx-ultra.yaml` file.

    ```bash
    kubectl describe pod nginx-ultra
    ```

    Your output should resemble the following example output:

    ```console
    [...]
    Volumes:
      volume:
        Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
        ClaimName:  ultra-disk
        ReadOnly:   false
      kube-api-access-sszt8:
        Type:                    Projected (a volume that contains injected data from multiple sources)
        TokenExpirationSeconds:  3607
    [...]
    Events:
      Type    Reason                  Age   From                     Message
      ----    ------                  ----  ----                     -------
      Normal  Scheduled               29s   default-scheduler        Successfully assigned default/nginx-ultra to aks-nodepool1-13380798-vmss000001
      Normal  SuccessfulAttachVolume  9s    attachdetach-controller  AttachVolume.Attach succeeded for volume "pvc-a6a6a6a6-bbbb-cccc-dddd-e7e7e7e7e7e7"
    ```