---
layout: Conceptual
title: Local Path Provisioner on AKS Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-howto-use-storage-local-path
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
description: Learn how to use the Local Path Provisioner tool on AKS Edge Essentials.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-how-to, edge-essentials
locale: en-us
document_id: e50301c2-824b-a086-6e26-27bbcee45b37
document_version_independent_id: 3524c00f-f094-b22a-394f-000385587536
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-use-storage-local-path.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-howto-use-storage-local-path
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-use-storage-local-path.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c21d0a62-47cf-4452-bd24-e1ed14abbeda
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f43eaf81-15c1-41e2-95b2-89fb1560c563
platformId: 04deef6c-a2f0-ffc5-81ee-8eb674acf44a
---

# Local Path Provisioner on AKS Edge | Microsoft Learn

Applications running in Azure Kubernetes Service (AKS) Edge Essentials might need to store and retrieve data. Persistent storage solutions enable you to store application data that's external from the pod running your application. Persistent storage also enables you to maintain application data, even if the application's pod fails.

The [Local Path Provisioner tool](https://github.com/rancher/local-path-provisioner) provides a way for Kubernetes users to use the local storage in each node by enabling the ability to create persistent volume claims using local storage on the respective node.

This article describes how to set up Local Path Provisioner storage and deploy a sample container on your AKS Edge Essentials cluster. For more information, see the [official Local Path Provisioner documentation](https://github.com/rancher/local-path-provisioner/blob/master/README.md#usage).

## Step 1: install prerequisites

In an elevated PowerShell window, run the following cmdlet:

```powershell
kubectl apply -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/storage/local-path-provisioner/local-path-storage.yaml
```

Warning

[Local-Path-Provisioner](https://github.com/rancher/local-path-provisioner) and [Busybox](https://hub.docker.com/r/rancher/busybox) images are not maintained by Microsoft and are pulled from the [Rancher Labs](https://hub.docker.com/u/rancher) repository. The `Local-Path-Provisioner` and `BusyBox` are only available as a Linux container image.

Once deployment is finished, make sure that the **local-path** storage class is available on your node by running the following cmdlet:

```powershell
kubectl get StorageClass
```

If everything is correctly configured, you should see the following output:

```output
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  21h
```

## Step 2: create a Persistent Volume Claim (PVC)

The second step is to create a persistent volume claim (PVC). There are multiple configurations available, but this example creates a PVC with **ReadWriteOnce** access mode and requests **128MB** of storage. In an elevated PowerShell window, run the following cmdlet:

```powershell
kubectl apply -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/storage/local-path-provisioner/pvc.yaml
```

## Step 3: deploy sample pod and verify resources

This step deploys a sample pod that binds to the PVC defined in the previous step. To deploy the sample pod, in an elevated PowerShell window, run the following cmdlet:

```powershell
kubectl apply -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/storage/local-path-provisioner/pod.yaml
```

If everything is running and correctly attached, you should see output similar to the following. First, you should see that the PV has been created:

```output
PS C:\WINDOWS\system32> kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE
pvc-0f217d0e-1d07-4d9e-91da-6b83534180b9   128Mi      RWO            Delete           Bound    default/local-path-pvc   local-path              16s
```

Next, you should see the PVC has been bound:

```output
PS C:\WINDOWS\system32> kubectl get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
local-path-pvc   Bound    pvc-0f217d0e-1d07-4d9e-91da-6b83534180b9   128Mi      RWO            local-path     118s
```

Finally, you should see the sample pod running:

```output
PS C:\WINDOWS\system32> kubectl get pod
NAME          READY   STATUS    RESTARTS   AGE
volume-test   1/1     Running   0          2m24s
```

## Step 4: test persistent storage

A final test is to make sure that the storage is persistent, and that data will be maintained, even if the application's pod fails.

Start by writing something to the pod. In an elevated PowerShell window, run the following cmdlet:

```powershell
kubectl exec volume-test -- sh -c "echo Hello AKS Edge! > /data/test"
```

Now delete the pod to simulate a pod failing, or even a deployment being removed:

```powershell
kubectl delete -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/storage/local-path-provisioner/pod.yaml
```

Check that the pod was removed and then deploy the **volume-test** pod again:

```powershell
kubectl apply -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/storage/local-path-provisioner/pod.yaml
```

Finally, read the content of the file that was previously written. If everything runs successfully, you should see the **Hello AKS Edge!** message.

```output
kubectl exec volume-test -- sh -c "cat /data/test"
Hello AKS Edge!
```

## Step 5: clean up deployment

Once you're finished with Local Path Provisioner, go to PowerShell and clean up your workspace by running:

```powershell
kubectl delete -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/storage/local-path-provisioner/pod.yaml
kubectl delete -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/storage/local-path-provisioner/pvc.yaml
```