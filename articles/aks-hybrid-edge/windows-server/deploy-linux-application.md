---
layout: Conceptual
title: Deploy a Linux app in AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/deploy-linux-application
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
description: Learn how to deploy a multi-container Linux app to your Kubernetes cluster in AKS on Windows Server using a custom image stored in Azure Container Registry.
author: davidsmatlak
ms.topic: how-to
ms.custom: linux-related-content, windows-server
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-06-27T00:00:00.0000000Z
ms.reviewer: srikantsarwa
locale: en-us
document_id: 45e944cb-d822-13be-6378-62e4d76ea213
document_version_independent_id: f9c559ac-bec5-eaee-969a-63c0bb2a14a2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/deploy-linux-application.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/deploy-linux-application
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/deploy-linux-application.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 5d2a7b38-e6bd-189f-db94-3a9e1a78accd
---

# Deploy a Linux app in AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This guide describes how to deploy a multi-container app that includes a web front-end and a Redis database instance on your Kubernetes cluster in AKS on Windows Server. You also learn how to test and scale your app.

This how-to guide assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts](kubernetes-concepts).

## Before you begin

Verify that you have the following prerequisites:

- An AKS cluster with at least one Linux worker node that is up and running.
- A kubeconfig file to access the cluster.
- The **AksHci** PowerShell module is installed. For more information, see [Install-AksHci](/en-us/azure/aks/hybrid/reference/ps/install-akshci).

When you perform the procedures:

- Run the commands in a PowerShell window opened with administrative privileges.
- Ensure that OS-specific workloads land on the appropriate container host. If your Kubernetes cluster has a mixture of Linux and Windows worker nodes, you can either use node selectors or taints and tolerations. For more information, see [using node selectors and taints and tolerations](adapt-apps-mixed-os-clusters).

Note

Deploying a target cluster that shares a network with another target cluster can lead to load balancer IP address conflicts. IP address conflicts can happen if you deploy two workloads that use different ports in target clusters sharing the same `AksHciClusterNetwork` object. Because of the way the IP addresses and port mappings are allocated inside HA Proxy, it can lead to assignment of duplicate IP addresses. If this occurs, one or both workloads can encounter random network connectivity issues until you re-deploy your workloads. When you re-deploy your workloads, you can either use the same port, which assigns a service IP address to each workload, or you can re-deploy your workloads on target clusters that use different `AksHciClusterNetwork` objects.

## Deploy the app

A Kubernetes manifest file defines a desired state for the cluster, such as which container images to run. This tutorial uses a manifest to create all objects needed to run the [Azure vote app](https://github.com/Azure-Samples/azure-voting-app-redis). This manifest includes two Kubernetes deployments: one for the sample Azure Vote Python apps, and the other for a Redis instance. Two Kubernetes services are also created: an internal service for the Redis instance, and an external service to access the Azure Vote app from the internet.

Create a file named **azure-vote.yaml** and copy/paste the following YAML definition:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: redis
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: <path to image>/azure-vote-front:v1
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 80
        env:
        - name: REDIS
          value: "azure-vote-back"
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front
```

Deploy the app using the `kubectl apply` command, and specify the name of your YAML manifest:

```powershell
kubectl apply -f azure-vote.yaml
```

The following example output shows deployments and services that were created successfully:

```output
deployment "azure-vote-back" created
service "azure-vote-back" created
deployment "azure-vote-front" created
service "azure-vote-front" created
```

## Test the app

When the app runs, a Kubernetes service exposes the app front-end to the internet. This process can take a few minutes to complete.

To monitor progress, use the `kubectl get service` command with the `--watch` argument:

```powershell
kubectl get service azure-vote-front --watch
```

Initially, the **EXTERNAL-IP** for the **azure-vote-front** service is shown as **pending**:

```output
NAME               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
azure-vote-front   LoadBalancer   10.0.37.27      <pending>     80:30572/TCP   22m
```

When the **EXTERNAL-IP** address changes from **pending** to an actual public IP address, use **CTRL-C** to stop the `kubectl` watch process. The following example output shows a valid public IP address assigned to the service:

```output
NAME               TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)        AGE
azure-vote-front   LoadBalancer   10.0.37.27   52.179.23.131   80:30572/TCP   24m
```

To see the Azure Vote app in action, open a web browser to the external IP address of your service.

![Screenshot of the home page of the Azure Voting App application, deployed on a Kubernetes cluster in Azure.](../media/deploy-linux-application/azure-vote.png)

## Scale application pods

We created a single replica of the Azure Voting App front-end and Redis instance. To see the number and state of pods in your cluster, use the `kubectl get` command:

```powershell
kubectl get pods -n default
```

The following example output shows one front-end pod and one back-end pod:

```output
NAME                                READY     STATUS    RESTARTS   AGE
azure-vote-back-6bdcb87f89-g2pqg    1/1       Running   0          25m
azure-vote-front-84c8bf64fc-cdq86   1/1       Running   0          25m
```

To change the number of pods in the **azure-vote-front** deployment, use the `kubectl scale` command. The following example increases the number of front-end pods to 5:

```powershell
kubectl scale --replicas=5 deployment/azure-vote-front
```

Run `kubectl get pods` again to verify that additional pods were created. After a minute or so, the additional pods are available in your cluster:

```powershell
kubectl get pods -n default
```

```output
Name                                READY   STATUS    RESTARTS   AGE
azure-vote-back-6bdcb87f89-g2pqg    1/1     Running   0          31m
azure-vote-front-84c8bf64fc-cdq86   1/1     Running   0          31m
azure-vote-front-84c8bf64fc-56h64   1/1     Running   0          80s
azure-vote-front-84c8bf64fc-djkp8   1/1     Running   0          80s
azure-vote-front-84c8bf64fc-jmmvs   1/1     Running   0          80s
azure-vote-front-84c8bf64fc-znc6z   1/1     Running   0          80s
```