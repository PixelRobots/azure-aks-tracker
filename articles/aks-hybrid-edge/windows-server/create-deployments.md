---
layout: Conceptual
title: Create deployments in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/create-deployments
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
description: Learn how to create deployments in Azure Kubernetes Service (AKS) on Windows Server.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-03-04T00:00:00.0000000Z
ms.reviewer: EkeleAsonye
ms.custom: windows-server
locale: en-us
document_id: ff5d81a8-1907-aeef-bcab-8152801f7db3
document_version_independent_id: 3ba41107-37ea-56b6-ad6c-a296e5cdf66d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/create-deployments.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/create-deployments
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/create-deployments.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: f01da2c5-92df-332d-c822-9f9f552a2cda
---

# Create deployments in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article provides an overview of Kubernetes deployments, and describes how to create and update these deployments in AKS on Windows Server.

## Kubernetes deployments overview

A *deployment* refers to a Kubernetes object that manages the performance and specifies the desired behavior of a pod. It specifies the application's life cycle, including the pods assigned to the application. A deployment provides a way to communicate your desired state for your application, and the controller works on changing the present state into your desired state.

Deployments automate the process to launch pod instances and ensure they run as defined across all nodes within the cluster. Administrators and IT professionals use deployments to communicate what they want from an application, and then Kubernetes takes all the necessary steps to create the desired state of the application.

While deployments define how your applications run, they do not guarantee where your applications are located within your cluster. For example, if your application requires an instance of a pod on every node, you want to use a DaemonSet. For stateful applications, a StatefulSet provides unique network identifiers, persistent storage, and ordered deployment/scaling.

The Kubernetes deployment object lets you:

- Deploy a replica set or a pod.
- Scale the number of instances of an application up or down.
- Update every running instance of an application.
- Roll back all running instances of an application to another version.
- Pause or continue a deployment.

For more information, see [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

## Create a deployment

To create a deployment, you can use the `kubectl apply` or `kubectl create` commands. Since the required number of pods is maintained and monitored, they're running and available after the deployment is created. If a pod fails, Kubernetes immediately rolls out a replica of the pod to take its place in the cluster.

The following example describes the features of a deployment manifest file in YAML format:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx
          name: nginx
          ports:
            - containerPort: 80
```

To view the deployment, the replica set, and the pods, run the following command:

```powershell
kubectl get deployment, replicaset, pod
```

## Update a deployment

The main advantage of deployments is the ability to automatically update your Kubernetes program. Without deployments, you would have to manually end all old pods, start new pod versions, and run a check to see if there are any problems when creating pods. You can run `kubectl describe deployment` to see the order in which the pods were brought up and removed.

Deployments automate the update process, as you simply update the pod template or the desired state. The deployment alters the program state in the background with actions, such as creating new pods or allocating more resources, until the chosen update is in place.

If there are problems in the deployment, Kubernetes automatically rolls back to the previous version. You can also explicitly roll back to a specific version using the `kubectl rollout undo` command, or you can use the `kubectl rollout pause` to temporarily halt a deployment.

## Strategies for updating deployments

Kubernetes provides several deployment strategies so you can update in various ways to suit the needs of your environment. The three most common update strategies are:

- **Rolling update**: This update is a gradual process that allows you to update your Kubernetes system with only a minor effect on performance and no downtime. It minimizes downtime at the cost of update speed.
- **Recreation**: This strategy is an all-or-nothing process that allows you to update all aspects of the system at once with a brief downtime period. It updates quickly but causes downtime.
- **Canary**: This strategy is a partial update process that allows you to test your new program version on real users without a commitment to a full rollout. It quickly updates for a select few users with a full rollout later.