---
layout: Conceptual
title: Statically provision Azure Managed Lustre volumes for AKS - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-managed-lustre-static-provisioning
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
description: Learn how to connect an existing Azure Managed Lustre file system to workloads in Azure Kubernetes Service.
ms.topic: how-to
ms.subservice: aks-storage
ms.date: 2026-11-10T00:00:00.0000000Z
author: wolfgang-desalvador
ms.author: wdesalvador
locale: en-us
document_id: 329ca919-ca03-86c6-c37e-75c41d38bce6
document_version_independent_id: 059e0f02-a041-2e9f-9b2f-9a043de4cf57
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-managed-lustre-static-provisioning.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/azure-managed-lustre-static-provisioning
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-managed-lustre-static-provisioning.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ae365aa9-5e19-49e1-95cb-6d0af6f19080
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/06cefb7d-f6d5-4371-a867-a6339677d3ad
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 57a36616-3210-be84-6006-37e574c4eac5
---

# Statically provision Azure Managed Lustre volumes for AKS - Azure Kubernetes Service | Microsoft Learn

Static provisioning connects an existing Azure Managed Lustre file system to your Azure Kubernetes Service (AKS) cluster. In this example, a storage class identifies the existing file system and the driver creates a Kubernetes persistent volume (PV) for your persistent volume claim (PVC). It doesn't create a new Azure Managed Lustre file system.

To create a new file system through Kubernetes instead, see [Dynamic provisioning](azure-managed-lustre-dynamic-provisioning).

## Before you begin

- Complete [Install the Azure Managed Lustre CSI driver](azure-managed-lustre-install), including the verification steps for your chosen installation method. Don't install a second driver if one is already installed.
- Have an existing Azure Managed Lustre file system with network connectivity from AKS. If needed, [create a file system](/en-us/azure/azure-managed-lustre/create-file-system-portal).
- Copy the Lustre Management Service (MGS) IP address from the file system's **Client connection** page in the Azure portal.
- Configure `kubectl` for your cluster. Create the example PVC and pod in the same namespace.

## Create a storage class

Create a file named `azure-managed-lustre-storage-class.yaml`. Replace `<MGS_IP_ADDRESS>` with the MGS IP address of your Azure Managed Lustre file system.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurelustre-static
provisioner: azurelustre.csi.azure.com
parameters:
  mgs-ip-address: <MGS_IP_ADDRESS>
reclaimPolicy: Retain
volumeBindingMode: Immediate
mountOptions:
  - noatime
  - flock
```

Apply the storage class:

```bash
kubectl apply -f azure-managed-lustre-storage-class.yaml
```

## Create a persistent volume claim

Create a file named `azure-managed-lustre-pvc.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurelustre-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurelustre-static
  resources:
    requests:
      storage: 4Ti
```

The requested capacity doesn't resize the existing Azure Managed Lustre file system.

Apply the claim and check its status:

```bash
kubectl apply -f azure-managed-lustre-pvc.yaml
kubectl get pvc azurelustre-pvc
```

Wait until the claim reaches the `Bound` state before continuing. To inspect provisioning events, run `kubectl describe pvc azurelustre-pvc`.

## Mount and verify the volume

Create a file named `azure-managed-lustre-pod.yaml`. Run the example on a supported node pool with the driver installed.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: azurelustre-test
spec:
  containers:
    - name: writer
      image: ubuntu:24.04
      command:
        - /bin/sh
        - -c
        - while true; do date >> /mnt/lustre/outfile; sleep 5; done
      volumeMounts:
        - name: lustre
          mountPath: /mnt/lustre
  volumes:
    - name: lustre
      persistentVolumeClaim:
        claimName: azurelustre-pvc
```

Apply the pod and wait for it to become ready:

```bash
kubectl apply -f azure-managed-lustre-pod.yaml
kubectl wait --for=condition=Ready pod/azurelustre-test --timeout=10m
```

Verify that the file system is mounted and the pod is writing to it:

```bash
kubectl exec azurelustre-test -- df -h /mnt/lustre
kubectl exec azurelustre-test -- tail /mnt/lustre/outfile
```

## Clean up the example

Find the PV name in the claim's `VOLUME` column before deleting the claim:

```bash
kubectl get pvc azurelustre-pvc -o wide
```

Stop the test pod and let its volume unmount. Then delete the claim, its retained PV, and the storage class. Replace `<PV_NAME>` with the name you recorded:

```bash
kubectl delete pod azurelustre-test
kubectl delete pvc azurelustre-pvc
kubectl delete pv <PV_NAME>
kubectl delete storageclass azurelustre-static
```

The storage class uses `Retain`, so deleting the claim alone leaves the PV behind. These commands remove the example's Kubernetes resources, not the Azure Managed Lustre file system or its data. They don't uninstall the driver.

## Troubleshooting

- **Network connectivity problems**: Verify virtual network peering or subnet configuration using the [network planning guide](azure-managed-lustre-network-planning).
- **Incorrect configuration**: Check the MGS IP address in the storage class.
- **Pod scheduling issues**: Confirm that the workload uses a supported node pool and review the pod events.
- **Network setup permission issues**: Verify that the AKS control-plane identity has appropriate permissions on the AKS subnet. Static provisioning doesn't require the CSI controller to create an Azure Managed Lustre file system.

For common driver issues, see [CSI driver troubleshooting](azure-managed-lustre-overview#troubleshooting). For version-specific diagnostics, see the [upstream v0.7.0 troubleshooting guide](https://github.com/kubernetes-sigs/azurelustre-csi-driver/blob/v0.7.0/docs/csi-debug.md). For file system deployment issues, see [Azure Managed Lustre troubleshooting](/en-us/azure/azure-managed-lustre/troubleshoot-deployment).