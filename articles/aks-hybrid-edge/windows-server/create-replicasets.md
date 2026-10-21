---
layout: Conceptual
title: Create a ReplicaSet in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/create-replicasets
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
description: Learn how to create a ReplicaSet in Azure Kubernetes Service (AKS) on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: EkeleAsonye
ms.custom: windows-server
locale: en-us
document_id: 36f2ffc5-e485-63e7-c594-7fffd5286e2f
document_version_independent_id: e287526e-1f50-3784-9940-c8f6852fb6d9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/create-replicasets.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/create-replicasets
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/create-replicasets.md
platformId: 8c5682fb-1ff5-644e-bdea-d00abc56bb56
---

# Create a ReplicaSet in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to create, scale, and delete *ReplicaSets* in AKS on Windows Server. ReplicaSets are used to ensure that a stable set of replica pods are running at any given time.

## Overview of ReplicaSets

A ReplicaSet is a process that runs multiple instances of a pod and keeps the specified number of pods constant. It makes sure that a stable set of replica pods is running at any given time, which guarantees an available specified number of identical pods.

When a pod fails, a ReplicaSet brings up a new instance of the pod and scales up when the running instances reach a specified number. Conversely, it scales down or deletes pods when an instance with the same label is created.

## Create a ReplicaSet

Use the `kubectl create` and `kubectl apply` commands to create ReplicaSets. The following example creates a ReplicaSet using a YAML file:

```powershell
kubectl apply –f nginx_replicaset.yaml
```

The features of a ReplicaSet configuration file are shown in YAML format:

```yaml
apiVersion: apps/v1  
kind: ReplicaSet  
metadata: 
      name: web
      labels: 
         env: dev
         role: web
spec:  
   replicas: 4
   selector: 
       matchlabels: 
       role: web
        template:
           metadata:
       labels:
           role: web
spec:  
      containers:  
           -name: nginx  
           image: nginx
```

After you create a ReplicaSet, you can view the status by running the following command:

```powershell
kubectl get rs
```

You can remove, but not delete, a pod that a ReplicaSet manages by changing its label using the `kubectl edit` command. For example, if you run `kubectl edit pods 7677-69h5b`, you can change the pod label once the configuration file opens.

## Scale a ReplicaSet

There are two ways to change the number of pods that a ReplicaSet manages.

- Edit the controller's configuration using the following command:

    ```powershell
    kubectl edit rs <ReplicaSet_NAME>
    ```
- Directly increase or decrease the number using the following command:

```powershell
kubectl scale –replicas=2 rs <ReplicaSet_NAME>
```

When you edit a manifest file, you can replace your existing configuration with the updated one:

```powershell
kubectl replace –f nginx_replicaset.yaml
```

Then, to view the status of your ReplicaSet, run `kubectl get rs <ReplicaSet_NAME>`.

Autoscaling is also an option with ReplicaSets using `kubectl autoscale rs web –max=5`. You can use autoscaling to adapt the number of pods according to the CPU load of a node.

## Delete a ReplicaSet

As with other Kubernetes objects, such as DaemonSets, you can delete ReplicaSets using the `kubectl delete` command. For example, you can use the following commands:

- To delete a ReplicaSet using the ReplicaSet name, run the following command:

    ```powershell
    kubectl delete rs <ReplicaSet_NAME>
    ```
- To delete a ReplicaSet using its filename, run the following command:

    ```powershell
    kubectl delete –f nginx_replicaset.yaml
    ```
- The preceding commands delete the ReplicaSet and all the pods that it manages. If you want to delete only the ReplicaSet resource, and keep the pods without an owner, you need to manually delete them. To manually delete a ReplicaSet, run the following command:

    ```powershell
    kubectl delete rs <ReplicaSet_NAME> --cascade=false
    ```