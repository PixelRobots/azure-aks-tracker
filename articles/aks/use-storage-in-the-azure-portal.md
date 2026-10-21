---
layout: Conceptual
title: Create and manage storage for AKS clusters in the Azure portal - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-storage-in-the-azure-portal
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
description: In this article, you learn how to create and manage storage resources for Azure Kubernetes Service (AKS) clusters in the Azure portal.
author: sasper0ni
ms.author: mirandawu
ms.topic: how-to
ms.date: 2026-05-22T00:00:00.0000000Z
locale: en-us
document_id: 10962f16-ef25-0111-d4fb-2b4a96839282
document_version_independent_id: a6b45434-4f01-394c-d16a-9cd14aa814bb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-storage-in-the-azure-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/use-storage-in-the-azure-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-storage-in-the-azure-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 91e69949-c4e7-51ec-121f-5ec6b5e2d026
---

# Create and manage storage for AKS clusters in the Azure portal - Azure Kubernetes Service | Microsoft Learn

Kubernetes workloads require storage when they need to store and/or retrieve data that persists beyond the pod or node lifecycle. This article shows you how to create and manage storage for AKS clusters directly in the Azure portal.

For more information on how storage works in Kubernetes or AKS, you can visit the [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/) or review the [Storage options for applications in Azure Kubernetes Service (AKS)](concepts-storage).

## Prerequisites

- A running AKS cluster. If you don't have one, see [Create an AKS cluster](/en-us/azure/aks/learn/quick-kubernetes-deploy-portal?tabs=azure-cli).
- The Azure portal automatically installs any managed Container Storage Interface (CSI) drivers required during the deployment of your desired storage type. To confirm which CSI drivers are already installed on your cluster, go to the Azure portal and navigate to your AKS cluster resource. From the service menu, select **Storage**. On the **Drivers** tab, you can also manually enable new drivers and/or verify existing driver installations. For example:

    ![A screenshot of Azure portal Drivers tab showing CSI drivers enabled.](media/storage-portal/driver-configuration-in-portal.png)

## Create storage

To dynamically provision storage using Kubernetes resources, you must create a Persistent Volume Claim (PVC) that references either a custom or built-in storage class.

1. In the Azure portal, navigate to your AKS cluster resource.
2. From the service menu, under **Kubernetes resources**, select **Storage**.
3. Select **+ Create** &gt; **Storage**.

### Select storage type and/or create a storage class

Based on your workload or hardware requirements, select a storage type (Azure Blob, Azure File, or Azure Disk) which corresponds to the managed CSI driver that will provision your storage resource. These CSI drivers come with built-in storage classes that define properties such as SKU, protocol (when applicable), volume binding mode, and reclaim policy. You can choose to reference one of these to proceed or select **Create new** if you need to define your own custom set of properties.

You can view details of any newly created or built-in storage class by selecting it in the dropdown. For example:

![A screenshot showing an overview of Azure File built-in storage class.](media/storage-portal/storage-class-overview.png)

### Create a PVC

After you create or select a storage class, you can create a PVC that references that storage class to dynamically provision a storage resource.

1. Update the following fields under the **Persistent Volume Claim details** section:

    - Name
    - Namespace
    - Access mode
    - Storage size (`Gi`)
2. Select **Create**.

Tip

Shrinking persistent volumes currently isn't supported, so make sure to size your PVC accordingly. For certain Azure Disk SKUs, the size designated here might correspond to your storage's performance tier. For more information, see [Azure managed disk types](/en-us/azure/virtual-machines/disks-types).

### Use a PVC

To mount an existing PVC into a Kubernetes workload, you must reference the PVC in the workload’s `volumes` section and mount it into a container using `volumeMounts`.

The example YAML manifest in step 2 creates a pod that runs an NGINX image and mounts your storage resource at the */mnt/azure* path. For Windows Server containers, specify a `mountPath` using the Windows path convention, such as *'D:'*.

1. Navigate back to the **Storage** menu and select **+ Create** &gt; **Apply a YAML**.
2. Paste in the following YAML manifest, and replace the `claimName` placeholder value (`<pvc-name>`) with the name of your existing PVC:

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
            - mountPath: /mnt/azure
              name: volume
              readOnly: false
      volumes:
       - name: volume
         persistentVolumeClaim:
           claimName: <pvc-name> # replace this with your PVC name
    ```
3. To access and/or manage Kubernetes workload resources, navigate to **Kubernetes resources** &gt; **Workloads**.

## Manage storage resources

You can manage your existing storage resources (PVCs, PVs and storage classes) from the **Storage** menu. You can also view recent storage-related Kubernetes events and warnings and the cluster's total provisioned storage capacity in `Gi`. For example:

![A screenshot showing the AKS Storage menu in the Azure portal.](media/storage-portal/storage-manage-overview.png)

To expand a PVC, select it in the PVC grid and then select **Expand** from the toolbar menu. This selection opens the **Expand Persistent Volume Claim** page where you can enter a new size (as long as your PVC's underlying storage class supports volume expansion).

![A screenshot showing the UX to expand a PVC in the Azure portal.](media/storage-portal/expand-persistent-volume-claim.png)

## Frequently asked questions (FAQ)

### Is Persistent Volume (PV) creation supported?

Currently, the Azure portal only explicitly supports storage creation via dynamic provisioning (using storage classes and PVCs). To statically provision a PV, you can manually apply a YAML definition via **+ Create** &gt; **Apply a YAML** in the **Storage** menu.