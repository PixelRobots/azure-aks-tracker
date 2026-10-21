---
layout: Conceptual
title: Deploy Windows .NET applications | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/deploy-windows-application
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
description: Learn how to deploy a Windows.NET application to your Kubernetes cluster using a custom image stored in Azure Container Registry in AKS on Windows Server.
author: davidsmatlak
ms.topic: tutorial
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: windows-server
locale: en-us
document_id: 876485f3-b092-1aad-5e1f-c05e338c1e12
document_version_independent_id: dff208a4-7dd4-b264-4549-23ce26640954
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/deploy-windows-application.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/deploy-windows-application
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/deploy-windows-application.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 0a2a8e66-ec68-10bf-b9b6-fb3bb739c04a
---

# Deploy Windows .NET applications | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This tutorial describes how to deploy an ASP.NET sample application in a Windows Server container to the Azure Kubernetes Service (AKS) cluster in AKS on Windows Server, then test and scale your application. You also learn how to join a Windows node to an Active Directory domain.

This tutorial assumes a basic understanding of Kubernetes concepts. For more information, see [Kubernetes core concepts for AKS on Windows Server](kubernetes-concepts).

## Before you begin

Make sure you met the following requirements:

- An [Azure Kubernetes Service cluster](kubernetes-walkthrough-powershell) with at least one Windows worker node up and running.
- A kubeconfig file to access the cluster.
- The [AksHci PowerShell module](kubernetes-walkthrough-powershell#install-the-akshci-powershell-module) is installed.

When you follow the procedures:

- Run the commands in a PowerShell administrator window.
- Ensure that OS-specific workloads land on the appropriate container host. If your Kubernetes cluster has a mixture of Linux and Windows worker nodes, you can use either node selectors or taints and tolerations. For more information, see [using node selectors and taints and tolerations](adapt-apps-mixed-os-clusters).

## Deploy the application

A Kubernetes manifest file defines a desired state for the cluster, such as which container images to run. In these procedures, a manifest is used to create all objects needed to run the ASP.NET sample application in a Windows Server container. This manifest includes a Kubernetes deployment for the ASP.NET sample application and an external Kubernetes service to access the application from the internet.

The ASP.NET sample application is provided as part of the .NET Framework samples and runs in a Windows Server container. AKS requires that Windows Server containers are based on images of Windows Server 2019.

The Kubernetes manifest file must also define a node selector to tell your cluster to run your ASP.NET sample application's pod on a node that can run Windows Server containers.

Create a file named `sample.yaml`, and copy/paste the following YAML definition:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample
  labels:
    app: sample
spec:
  replicas: 1
  template:
    metadata:
      name: sample
      labels:
        app: sample
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": windows
      containers:
      - name: sample
        image: mcr.microsoft.com/dotnet/framework/samples:aspnetapp
        resources:
          limits:
            cpu: 1
            memory: 800M
          requests:
            cpu: .1
            memory: 300M
        ports:
          - containerPort: 80
  selector:
    matchLabels:
      app: sample
---
apiVersion: v1
kind: Service
metadata:
  name: sample
spec:
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: 80
  selector:
    app: sample
```

Deploy the application using the `kubectl apply` command, and specify the name of your YAML manifest:

```powershell
kubectl apply -f sample.yaml
```

The following example output shows that the deployment and service were created successfully:

```output
deployment.apps/sample created
service/sample created
```

## Test the application

When the application runs, a Kubernetes service exposes the application front end to the internet. This process can take a few minutes to complete. Occasionally, the service can take longer than a few minutes to provision. Allow up to 10 minutes in these cases.

To monitor progress, use the `kubectl get service` command with the `--watch` argument:

```powershell
kubectl get service sample --watch
```

Initially, the **EXTERNAL-IP** for the **sample** service is shown as **pending**:

```output
NAME    TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
sample  LoadBalancer   10.0.37.27   <pending>     80:30572/TCP   6s
```

When the **EXTERNAL-IP** address changes from **pending** to an actual public IP address, use `CTRL-C` to stop the `kubectl` watch process. The following example output shows a valid public IP address assigned to the service:

```output
NAME    TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)        AGE
sample  LoadBalancer   10.0.37.27   52.179.23.131   80:30572/TCP   2m
```

To see the sample app in action, open a web browser to the external IP address of your service.

![Screenshot of the home page for the ASP.NET sample application for Windows deployed on an AKS cluster.](../media/deploy-windows-application/asp-net-sample-app.png)

If the connection times out when you try to load the page, verify whether the sample app is ready by running the `kubectl get pods --watch` command. Sometimes, the external IP address is available before the Windows container starts.

## Scale application pods

We created a single replica of the application front end. To see the number and state of pods in your cluster, use the `kubectl get` command as follows:

```powershell
kubectl get pods -n default
```

To change the number of pods in the **sample** deployment, use the `kubectl scale` command. The following example increases the number of front-end pods to 3:

```powershell
kubectl scale --replicas=3 deployment/sample
```

Run `kubectl get pods` again to verify that the pods were created. After a minute or so, the additional pods are available in your cluster:

```powershell
kubectl get pods -n default
```