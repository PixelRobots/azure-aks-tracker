---
layout: Conceptual
title: Deploy an application | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-howto-deploy-app
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
description: Describes how to deploy a containerized application to a Kubernetes cluster.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-how-to, linux-related-content, edge-essentials
locale: en-us
document_id: b22fbcd4-833c-2cca-1fde-a38376c3c5ed
document_version_independent_id: 60968918-c358-24a7-35cd-575d91f232f0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-deploy-app.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-howto-deploy-app
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-deploy-app.md
platformId: 6c1e7805-d375-76a1-9477-0ca676023691
---

# Deploy an application | Microsoft Learn

This article describes how to deploy a containerized application on your Kubernetes cluster.

## Prerequisites

To get started, set up your [single machine Kubernetes](aks-edge-howto-single-node-deployment) or [full Kubernetes](aks-edge-howto-multi-node-deployment) cluster.

## Deploy a sample Linux application

### Step 1: update the manifest file

This article uses a sample application that is a simple voting app consisting of a front and back end, which is based on Microsoft's **azure-vote-front** image. The container image for this application is hosted on Azure Container Registry (ACR). See [linux-sample.yaml](https://github.com/Azure/AKS-Edge/blob/main/samples/others/linux-sample.yaml) in the GitHub repo package for the deployment manifest. In the YAML, we specified a `nodeSelector` tag as **Linux**.

### Step 2: deploy the application

To deploy your application, use the [kubectl apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command. This command parses the manifest file and creates the defined Kubernetes objects. Specify the YAML manifest file, as shown in the following example:

```bash
kubectl apply -f  https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/others/linux-sample.yaml
```

### Step 3: verify the pods

Wait a few minutes for the pods to be in the **running** state:

```bash
kubectl get pods -o wide
```

[![Screenshot showing Linux pods running.](../media/aks-edge/linux-pods-running.png)](../media/aks-edge/linux-pods-running.png#lightbox)

### Step 4: verify the services

To monitor progress, use the [kubectl get services](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command with the `--watch` parameter:

```bash
kubectl get services
```

[![Screenshot showing Linux services running.](../media/aks-edge/linux-services-running.png)](../media/aks-edge/linux-services-running.png#lightbox)

Initially, the `EXTERNAL-IP` for the `azure-vote-front` service is shown as `pending`. When the `EXTERNAL-IP` address changes from `pending` to an actual public IP address, you can use the IP address assigned to the service.

Important

On single machine clusters, if you deployed your Kubernetes cluster without specifying a `-ServiceIPRangeSize`, you will not have allocated IPs for your workload services and you won't have an external IP address. In this case, find the IP address of your Linux VM (`Get-AksEdgeNodeAddr`):

```powershell
Get-AksEdgeNodeAddr -NodeType Linux
```

You can now append the external port to the VM's IP address (for example, **192.168.1.12:30432**).

### Step 5: test your application

To see the application in action, open a web browser to the external IP address of your service:

[![Screenshot showing Linux apps that are running.](../media/aks-edge/linux-app-up.png)](../media/aks-edge/linux-app-up.png#lightbox)

If the application doesn't load, it might be due to an authorization problem with your image registry. To view the status of your containers, use the `kubectl get pods` command. If the container images can't be retrieved, see [Authenticate with Azure Container Registry from Azure Kubernetes Service](/en-us/azure/aks/cluster-container-registry-integration?bc=/azure/container-registry/breadcrumb/toc.json&amp;toc=/azure/container-registry/toc.json).

### Step 6: remove application

To clean up, delete all resources using the following command:

```bash
kubectl delete -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/others/linux-sample.yaml
```

## Deploy a sample Windows application to your cluster

This example runs a sample ASP.NET application based on [Microsoft's sample image](https://hub.docker.com/_/microsoft-dotnet-samples/). See [win-sample.yaml](https://github.com/Azure/AKS-Edge/blob/main/samples/others/win-sample.yaml). The YAML specifies the `nodeSelector` tag as **Windows**.

### Step 1: deploy the application by specifying the name of your YAML manifest

Make sure you are in the directory of the YAML in a PowerShell window, then run the following command:

```powershell
kubectl apply -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/others/win-sample.yaml
```

### Step 2: verify that the sample pod is running

It might take a while for the pod to reach the running status, depending on your internet connection. The ASP.NET image is large:

```powershell
kubectl get pods -o wide
```

[![Screenshot showing Windows pods running.](../media/aks-edge/win-pods-running.png)](../media/aks-edge/win-pods-running.png#lightbox)

### Step 3: verify that the sample service is running

```powershell
kubectl get services
```

[![Screenshot showing Windows services running.](../media/aks-edge/win-svc-running.png)](../media/aks-edge/win-svc-running.png#lightbox)

Since this sample is deployed as a service of type **NodePort**, you can retrieve the IP address of the Kubernetes node on which the application is running, then append the port of the **NodePort**. Get the IP of the Kubernetes node using the following `Get-AksEdgeNodeAddr`command:

```powershell
Get-AksEdgeNodeAddr -NodeType Windows
```

[![Screesnhot showing Windows cluster information.](../media/aks-edge/win-cluster-info.png)](../media/aks-edge/win-cluster-info.png#lightbox)

### Step 4: verify your running Windows sample

Open a web browser and locate the **NodePort** to access your service:

[![Screenshot showing Windows app running.](../media/aks-edge/win-app-up.png)](../media/aks-edge/win-app-up.png#lightbox)

### Step 5: clean up

To clean up, delete all resources using the following command:

```powershell
kubectl delete -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/others/win-sample.yaml
```

## Deploying your own applications

The previous steps showed how you can deploy our sample applications. To deploy your own application, do the following:

- Package your application into a container image, and then upload the image to Azure Container Registry or in a container registry of your choice. Review these steps to [create a container image of your application](/en-us/azure/aks/aksarc/tutorial-kubernetes-prepare-application).
- AKS Edge Essentials enables mixed-OS clusters. Ensure your pods get scheduled on nodes with the corresponding OS. Add `nodeSelector` to your deployment files. This option tells Kubernetes to run your pods on nodes of a particular operating system (OS). If your cluster is single-OS, then you can skip this step; but for best practice, label each deployment file with node selectors:

    ```yaml
    nodeSelector:
        "kubernetes.io/os": linux
    ```

    ```yaml
    nodeSelector:
        "kubernetes.io/os": windows
    ```