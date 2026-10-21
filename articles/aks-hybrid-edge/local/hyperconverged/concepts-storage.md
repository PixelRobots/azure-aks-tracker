---
layout: Conceptual
title: Concepts - Storage options for applications in AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/concepts-storage
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
description: Storage options for applications in AKS Hybrid and Edge.
author: davidsmatlak
ms.topic: concept-article
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: hyperconverged
locale: en-us
document_id: ed2b2002-9c4b-aa03-89eb-791d78b5b77f
document_version_independent_id: e589f9be-2501-648d-3a34-7a2b0ac9c08c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/concepts-storage.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/concepts-storage
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/concepts-storage.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: 8225d336-5022-3c22-476d-06996aafebea
---

# Concepts - Storage options for applications in AKS Hybrid and Edge | Microsoft Learn

> 
> Applies to: AKS on Azure Local

Applications that run in AKS deployments using Azure Kubernetes Service Hybrid and Edge might need to store and retrieve data. For some application workloads, the data can use local, fast storage on an unneeded node when the pods are deleted (Kubernetes uses *pods* to run an instance of an application).

Other workloads might require storage that persists on more regular data volumes. Multiple pods might need to share the same data volumes, or reattach data volumes if the pod is rescheduled on a different node. Also, you might need a storage option if the pods contain sensitive data or application configuration information.

[![Architectural storage image showing a cluster master and node.](../../media/concepts-storage/storage-architecture.png)](../../media/concepts-storage/storage-architecture.png#lightbox)

This article introduces the core concepts that provide storage to your applications in AKS, including:

- Volumes
- Persistent volumes
- Storage classes
- Persistent volume claims (PVC)

## Volumes

Applications often need to be able to store and retrieve data. As Kubernetes typically treats individual pods as temporary, disposable resources, different approaches are available for applications to use and persist data. A volume represents a way to store, retrieve, and persist data across pods and through the application lifecycle.

In Kubernetes, volumes can represent more than just a traditional on which information is stored and retrieved. Kubernetes volumes can also be used as a way to insert data into a pod for containers to use. Some common Kubernetes volume types include:

- **emptyDir** - This volume is commonly used as temporary space for a pod. All containers within a pod can access the data on the volume. Data written to this volume type persists only for the lifespan of the pod - when the pod is deleted, the volume is deleted. This volume typically uses the underlying local node disk storage, although it can also exist solely in the node's memory.
- **secret** - This volume is used to include sensitive data, such as passwords, into pods. First, you create a secret using the Kubernetes API. When you define your pod or deployment, you can request a specific secret. Secrets are only provided to nodes with a scheduled pod that requires it, and the secret is stored in **tmpfs**, not written to disk. When the last pod on a node that requires a secret is deleted, the secret is deleted from the node's **tmpfs**. Secrets are stored within a given namespace and can only be accessed by pods within the same namespace.
- **configMap** - This volume type is used to inject key-value pair properties into pods, such as application configuration information. Instead of defining application configuration information within a container image, you can define it as a Kubernetes resource that can be easily updated and applied to new instances of pods as they are deployed. Similar to using a secret, you first create a **ConfigMap** using the Kubernetes API. This **ConfigMap** can then be requested when you define a pod or deployment. **ConfigMaps** are stored within a given namespace and can only be accessed by pods within the same namespace.

## Persistent volumes

Volumes that are defined and created as part of the pod lifecycle only exist until the pod is deleted. Pods often expect their storage to remain if a pod is rescheduled on a different host during a maintenance event, especially in StatefulSets. A persistent volume is a storage resource created and managed by the Kubernetes API that can exist beyond the lifetime of an individual pod.

You can use AKS disk volumes backed by VHDX that are mounted as **ReadWriteOnce** and are accessible to a single node at a time. Or, you can use AKS file volumes backed by SMB or NFS file shares. These are mounted as **ReadWriteMany** and are available to multiple nodes concurrently.

A cluster administrator can statically create a persistent volume, or the volume can be dynamically created by the Kubernetes API server. If a pod is scheduled and requests storage that is not currently available, Kubernetes can create the underlying VHDX file and then attach it to the pod. Dynamic provisioning uses a **StorageClass** to identify what type of storage needs to be created.

## Storage classes

To define different tiers (and location) of storage you can create a **StorageClass**. The **StorageClass** also defines the **reclaimPolicy**. This **reclaimPolicy** controls the behavior of the underlying storage resource when the pod is deleted and the persistent volume might no longer be required. The underlying storage resource can be deleted or retained for use with a future pod.

In AKS, the **default** storage class is automatically created and uses CSV to create VHDX-backed volumes. The reclaim policy ensures that the underlying VHDX is deleted when the persistent volume that used it is deleted. The storage class also configures the persistent volumes to be expandable, so you just need to edit the persistent volume claim with the new size.

If no **StorageClass** is specified for a persistent volume, the default **StorageClass** is used. When requesting persistent volumes, make sure they use the appropriate storage. You can create a **StorageClass** for additional needs.

## Persistent volume claims

A **PersistentVolumeClaim** requests either **ReadWriteOnce** or **ReadWriteMany** storage of a particular **StorageClass** and size. The Kubernetes API server can dynamically provision the underlying storage resource in AKS if there is no existing resource to fulfill the claim based on the defined **StorageClass**. The pod definition includes the volume mount once the volume has been connected to the pod.

A **PersistentVolume** is bound to a **PersistentVolumeClaim** once an available storage resource is assigned to the pod requesting it. There is a 1:1 mapping of persistent volumes to claims.

The following example YAML manifest shows a persistent volume claim that uses the default **StorageClass** and requests a 5Gi disk:

```yaml
apiVersion: v1 
kind: PersistentVolumeClaim 
metadata: 
  name: aks-hci-vhdx 
spec: 
  accessModes: 
  - ReadWriteOnce 
  storageClassName: default 
  resources: 
    requests: 
      storage: 5Gi 
```

When you create a pod definition, you specify the persistent volume claim to request the desired storage. You also then specify the `volumeMount` for your applications to read and write data. The following example YAML manifest shows how the previous persistent volume claim can be used to mount a volume at `/mnt/aks-hci`:

```yaml
kind: Pod 
apiVersion: v1 
metadata: 
  name: nginx 
spec: 
  containers: 
    - name: myfrontend 
      image: k8s.gcr.io/nginx 
      volumeMounts: 
      - mountPath: "/mnt/aks-hci" 
        name: volume
  nodeSelector:
      kubernetes.io/os: linux
  volumes: 
    - name: volume 
      persistentVolumeClaim: 
        claimName: aks-hci-vhdx 
```

The following example shows how to mount a volume in a Windows container and specify the drive letter and path:

```yaml
volumeMounts: 
        - mountPath: "d:" 
          name: volume 
        - mountPath: "c:\k" 
          name: k-dir 
```

## Secure pod access to mounted volumes

For your applications to run correctly, pods should run as a defined user or group and not as *root*. The `securityContext` for a pod or container lets you define settings such as *fsGroup* to assume the appropriate permissions on the mounted volumes.

**fsGroup** is a field within the `securityContext` of a Kubernetes pod specification. It defines a supplemental group ID that Kubernetes assigns to all processes in the pod, and recursively to the files in mounted volumes. This ensures that the pod has the correct group-level access to shared storage volumes.

When a volume is mounted, Kubernetes changes the ownership of the volume's contents to match the **fsGroup** value. This is particularly useful when containers run as non-root users and need write access to shared volumes.

The following example YAML shows the **fsgroup** value:

```yaml
securityContext:
  fsGroup: 2000
```

In this example, all files in mounted volumes are accessible by GID 2000.