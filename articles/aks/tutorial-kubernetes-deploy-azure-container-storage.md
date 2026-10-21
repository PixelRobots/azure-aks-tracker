---
layout: Conceptual
title: Kubernetes on Azure tutorial - Use Azure Container Storage - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-azure-container-storage
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
description: In this Azure Kubernetes Service (AKS) tutorial, you learn how to deploy Azure Container Storage on an AKS cluster and create volumes.
ms.topic: tutorial
ms.date: 2026-06-23T00:00:00.0000000Z
author: khdownie
ms.author: kendownie
ms.custom: mvc, devx-track-azurecli
locale: en-us
document_id: 55348666-de61-fb50-07c3-aee1a6c7a19c
document_version_independent_id: ba600525-3f7f-e6a8-fe9a-18cb6953ba88
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/tutorial-kubernetes-deploy-azure-container-storage.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/tutorial-kubernetes-deploy-azure-container-storage
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/tutorial-kubernetes-deploy-azure-container-storage.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: d1f4dac8-3d3d-db73-0134-36404b66662d
---

# Kubernetes on Azure tutorial - Use Azure Container Storage - Azure Kubernetes Service | Microsoft Learn

This tutorial introduces Azure Container Storage and demonstrates how to deploy and manage container-native storage for applications running on Azure Kubernetes Service (AKS). If you don't want to deploy Azure Container Storage now, you can skip this tutorial and proceed directly to [Deploy an application in AKS](tutorial-kubernetes-deploy-application). You won't need Azure Container Storage for the basic storefront application in this tutorial series.

Azure Container Storage simplifies the management of stateful applications in Kubernetes by offering container-native storage tailored to a variety of workloads, including databases, analytics platforms, and high-performance applications.

Important

This tutorial only applies to AKS Standard clusters. If you chose AKS Automatic in the [previous tutorial](tutorial-kubernetes-deploy-cluster), skip this tutorial and continue to [Deploy an application in AKS](tutorial-kubernetes-deploy-application).

By the end of this tutorial, you will:

- Understand how Azure Container Storage supports diverse workloads in Kubernetes.
- Deploy Azure Container Storage on your AKS cluster.
- Create a generic ephemeral volume.

## Before you begin

In previous tutorials, you created a container image, uploaded it to an ACR instance, and created an AKS cluster. Start with [Tutorial 1 - Prepare application for AKS](tutorial-kubernetes-prepare-app) to follow along.

This tutorial creates billable resources and requires permissions to update AKS cluster settings and install extensions. Use an identity with at least **Contributor** access to the resource group that contains your AKS cluster.

- Confirm that your target region is supported by reviewing the [Azure Container Storage regional availability](/en-us/azure/storage/container-storage/container-storage-introduction#regional-availability).
- Install the latest version of the [Azure CLI](/en-us/cli/azure/install-azure-cli) (2.83.0 or later), then sign in with `az login`. Don't use Azure Cloud Shell, because `az upgrade` isn't available.
- Install the Kubernetes command-line client, `kubectl`. You can install it locally by running `az aks install-cli`. For other installation options, see [Install kubectl](/en-us/azure/aks/learn/quick-kubernetes-deploy-cli?tabs=azure-cli#install-kubectl).

Important

This tutorial applies to [Azure Container Storage (version 2.x.x)](/en-us/azure/storage/container-storage/container-storage-introduction), which supports local NVMe disk and Azure Elastic SAN as backing storage types. This tutorial uses local NVMe and creates a generic ephemeral volume. To use local NVMe, your VM SKU must support local NVMe data disks, such as [storage-optimized](/en-us/azure/virtual-machines/sizes/overview#storage-optimized) or [GPU-accelerated](/en-us/azure/virtual-machines/sizes/overview#gpu-accelerated) VMs.

If you'd prefer to use Azure Elastic SAN, see [Use Azure Container Storage with Azure Elastic SAN](/en-us/azure/storage/container-storage/use-container-storage-with-elastic-san).

## Install the Kubernetes extension

Add or upgrade to the latest version of `k8s-extension` by running the following command.

```azurecli
az extension add --upgrade --name k8s-extension
```

Verify that the extension is available before continuing:

```azurecli
az extension show --name k8s-extension --query version --output tsv
```

## Enable Azure Container Storage on your AKS cluster

Run the following command to enable Azure Container Storage on an existing AKS cluster using local NVMe. Azure Container Storage installs the latest available version and updates itself automatically. Manual version selection isn't supported.

```azurecli
az aks update -n myAKSCluster -g myResourceGroup --enable-azure-container-storage ephemeralDisk
```

If this command fails with an authorization error, run `az account show` to verify the active subscription and confirm that your identity has permission to update the AKS cluster.

The deployment can take up to five minutes. When it completes, the AKS cluster has Azure Container Storage installed and the components for local NVMe storage type deployed. It also creates the default `local-csi` storage class.

## Connect to the cluster and verify status

If you're not already connected to your cluster from the previous tutorial, run the following commands. If you're already connected, you can skip this section.

1. Download the cluster credentials and configure the Kubernetes CLI to use them. By default, credentials are stored in `~/.kube/config`. Provide a different path by using the `--file` argument if needed.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```

    Continue after the command reports that context entries were merged into `~/.kube/config`.
2. Verify the connection by listing the cluster nodes.

    ```azurecli
    kubectl get nodes
    ```
3. Make sure all nodes report a status of `Ready`.

## Verify the storage class

Run the following command to verify that the storage class is created:

```azurecli
kubectl get storageclass local-csi
```

You should see output similar to:

```output
NAME        PROVISIONER               RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-csi   localdisk.csi.acstor.io   Delete          WaitForFirstConsumer   true                   10s
```

## Deploy a pod with generic ephemeral volume

Create a pod using [Fio](https://github.com/axboe/fio) (Flexible I/O Tester) for benchmarking and workload simulation that uses a generic ephemeral volume.

1. Create a YAML manifest file named `fiopod.yaml`. For example, run `code fiopod.yaml`.
2. Paste in the following code and save the file.

    ```yml
    kind: Pod
    apiVersion: v1
    metadata:
      name: fiopod
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
        - name: fio
          image: mayadata/fio
          args: ["sleep", "1000000"]
          volumeMounts:
            - mountPath: "/volume"
              name: ephemeralvolume
      volumes:
        - name: ephemeralvolume
          ephemeral:
            volumeClaimTemplate:
              spec:
                volumeMode: Filesystem
                accessModes: ["ReadWriteOnce"]
                storageClassName: local-csi
                resources:
                  requests:
                    storage: 10Gi
    ```
3. Apply the YAML manifest file to deploy the pod.

    ```azurecli
    kubectl apply -f fiopod.yaml
    ```

## Verify the deployment and run benchmarks

Check that the pod is running:

```azurecli
kubectl get pod fiopod
```

You should see the pod in the Running state. Once running, you can execute a Fio benchmark test:

```azurecli
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/volume/test --direct=1 --rw=randrw --ioengine=libaio --bs=4k --iodepth=16 --numjobs=8 --time_based --runtime=60
```

You've now deployed a pod that's using local NVMe as its storage, and you can use it for your Kubernetes workloads.

To learn more about Azure Container Storage, see [What is Azure Container Storage?](/en-us/azure/storage/container-storage/container-storage-introduction)

## Clean up resources

You won't need Azure Container Storage for the rest of this tutorial series, so we recommend deleting it now to avoid incurring unnecessary Azure charges.

1. Delete the pod.

    ```azurecli
    kubectl delete pod fiopod
    ```
2. Delete the generic ephemeral volume.

    ```azurecli
    kubectl delete pv ephemeralvolume
    ```

    If this command returns `NotFound`, continue. Generic ephemeral volumes are deleted automatically when the pod is deleted.
3. Delete the extension instance.

    ```azurecli
    az aks update -n myAKSCluster -g myResourceGroup --disable-azure-container-storage
    ```