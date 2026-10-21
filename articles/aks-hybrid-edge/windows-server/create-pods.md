---
layout: Conceptual
title: Create and delete pods in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/create-pods
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
description: Learn how to create and delete pods in Azure Kubernetes Service (AKS) on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: windows-server
locale: en-us
document_id: 82b240da-2804-08e7-93d4-3eb4254aaff4
document_version_independent_id: f885792e-bfad-a2e8-2606-f41d953e7f5a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/create-pods.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/create-pods
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/create-pods.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: 7868fa0c-f67f-3e41-68ce-6f1ac3c60b89
---

# Create and delete pods in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

Kubernetes uses pods to run an instance of your application. This article describes how to create and delete pods when managing your workloads in AKS on Windows Server.

A pod represents a single instance of an application. Each pod has one or more containers deployed together on a single host. A pod is the smallest unit of execution in Kubernetes. An internal IP address and port are assigned to a pod, through which containers within the pod can share a common storage and network. Like a service, volume, and namespace, a pod is a basic Kubernetes object. Pods run on nodes and have a definite lifecycle, during which they run until their containers are removed.

## Create a pod

Before you create a pod, you must [set up an AKS host and create AKS clusters using Windows PowerShell](kubernetes-walkthrough-powershell). You can also use Windows Admin Center to [set up the host](setup) and [create the clusters](create-kubernetes-cluster).

To make sure you are connected to the Kubernetes cluster, run the following command:

```powershell
kubectl get nodes
```

To create a pod, run the following command. In this example, a pod is created using an nginx image:

```powershell
kubectl run nginx --image=nginx --restart=Never
```

When you set the parameter `-restart=Never`, Kubernetes creates a single pod instead of creating a deployment.

To see the status of your pod, run the following command:

```powershell
kubectl get pods
```

To view the entire configuration of the pod, run the following command:

```powershell
kubectl describe pod nginx
```

## Delete a pod

To delete a pod you created, run the following command:

```powershell
kubectl delete pod
```

## Example pod configuration

The following YAML example describes the features of a pod, and shows how it's the smallest unit of Kubernetes that can be defined, deployed, and managed:

```yaml
apiVersion: v1
kind: Pod
metadata:
      labels:
         app: nginx
      name: nginx
      namespace: calico-demo
spec:
      containers:
      - name: nginx
         image: nginx:1.8
         ports:
         - containerPort: 80
      nodeSelector:
          beta.kubernetes.io/os: linux
```