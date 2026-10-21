---
layout: Conceptual
title: File share mounting failures for Azure Files - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/file-share-mount-failures-azure-files
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
description: Troubleshoot Azure Files file share mounting failures on Azure Kubernetes Service (AKS) clusters and restore storage access by following these steps.
ms.date: 2024-10-23T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, jaewonpark, v-leedennis
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Storage
locale: en-us
document_id: 03e3fcaf-32b4-ea22-3490-fb3ed4bc4bff
document_version_independent_id: 03e3fcaf-32b4-ea22-3490-fb3ed4bc4bff
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/storage/file-share-mount-failures-azure-files.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/storage/file-share-mount-failures-azure-files
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/storage/file-share-mount-failures-azure-files.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/01a89bec-e73f-4ce0-a00a-ae34ad62e5fe
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/50038ab9-5431-4515-9dfc-c24291ef4fce
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 63f0ccc9-230b-fe50-8890-12fa1aa735f9
---

# File share mounting failures for Azure Files - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot file share mounting failures for Azure Files so that you can set up storage successfully on your Microsoft Azure Kubernetes Service (AKS) clusters.

## Cause

Your storage account key changed. This problem can cause a range of errors. The following pod error is typical:

```
Error: failed to generate container "56907e9807c6f4203c3aace8c5a6e3a75832cf07d3080a3869d355114657b54f" spec: failed to generate spec: failed to stat "/var/lib/kubelet/pods/xxxxxxxx-9fe6-46d7-b12e-339951b8d2f5/volumes/kubernetes.io~csi/pvc-xxxxxxxx-3b70-498c-b357-3488e1c1f429/mount": stat /var/lib/kubelet/pods/xxxxxxxx-9fe6-46d7-b12e-339951b8d2f5/volumes/kubernetes.io~csi/pvc-xxxxxxxx-3b70-498c-b357-3488e1c1f429/mount: host is down
```

## Solution

Manually update the `azurestorageaccountkey` field in an Azure file secret to add your base64-encoded storage account key. To make this update, follow these steps:

1. Encode your storage account key in base64 by running the following command:

```console
echo <storage-account-key> | base64
```

1. [Update your Azure secret file](https://kubernetes.io/docs/concepts/configuration/secret/#editing-a-secret) by running the `kubectl edit secret` command to open the secret file in your default text editor:

```console
kubectl edit secret azure-storage-account-<storage-account-name>-secret
```

1. Change the `azurestorageaccountkey` field to use the new base64-encoded storage account key, and then save the file.
2. Ensure proper unmount and recovery by using one of the following options. Redeploying pods alone often fails to fix the issue if an existing mount with a stale account key is reused.

**Option 1: Cordon the node (single pod or node scenario)**

1. Cordon the current node where the pod is running:

```console
kubectl cordon <node-name>
```

1. Force the pod to restart on a different node:

```console
kubectl delete pod <pod-name>
```

The new pod mounts the file share by using the updated credential.

**Option 2: Scale replicas (recommended for Deployment or StatefulSet scenarios)**

1. Scale replicas down to 0:

```console
kubectl scale deployment <deployment-name> --replicas=0
```

1. Wait 3-5 minutes for the account key cache to expire.
2. Scale replicas back to the original count:

```console
kubectl scale deployment <deployment-name> --replicas=<original-count>
```

The new pods mount the file share by using the updated credentials.

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.