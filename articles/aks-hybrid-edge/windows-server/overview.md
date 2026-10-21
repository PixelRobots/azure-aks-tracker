---
layout: Conceptual
title: Overview of AKS on Windows Server | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/overview
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
description: Learn about AKS on Windows Server.
ms.topic: overview
ms.custom: linux-related-content, windows-server
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
locale: en-us
document_id: 2a3e7991-f532-62bd-37c5-66893d210fac
document_version_independent_id: 87ca5854-ebc7-a756-055a-043ff0af64e1
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/overview.md
platformId: 335b699a-5a7f-5269-a85b-1eaf104d4baa
---

# Overview of AKS on Windows Server | Microsoft Learn

> 
> Applies to: AKS on Windows Server

Azure Kubernetes Service (AKS) on Windows Server is an on-premises Kubernetes implementation of AKS. AKS on Windows Server automates running containerized applications at scale. AKS on Windows Server makes it quicker to get started hosting Linux and Windows containers in your datacenter.

To get started with on-premises Kubernetes using AKS, [set up AKS on Windows Server](setup).

Or, you can use AKS to orchestrate your cloud-based containers. See [Azure Kubernetes Service in Azure](/en-us/azure/aks/intro-kubernetes). If you're using Azure Stack Hub, see [AKS engine on Azure Stack Hub](/en-us/azure-stack/user/azure-stack-kubernetes-aks-engine-overview).

The following sections discuss some of the reasons to use AKS on Windows Server, then answer some common questions about the service and how to get started. For a background on containers, see [Windows and containers](/en-us/virtualization/windowscontainers/about/). For information about how Kubernetes works in AKS on Windows Server, see [Kubernetes core concepts](kubernetes-concepts). For more information about Kubernetes, see [the Kubernetes.io documentation](https://kubernetes.io).

## Why use AKS on Windows Server for containerized applications?

While you can manage a few containers manually by using Docker and Windows, apps often use five, 10, or even hundreds of containers. That's where the Kubernetes orchestrator comes in.

Kubernetes is an open-source orchestrator that automates container management at scale. AKS simplifies on-premises Kubernetes deployment by providing wizards you can use to set up Kubernetes and add-ons, and also to create Kubernetes clusters to host your workloads.

Some of the functionality AKS provides on Windows Server includes:

- Deploy containerized apps at scale to Kubernetes clusters running across the Windows Server cluster.
- Deploy and manage both Linux and Windows-based containerized apps.
- Scale up or down by adding or removing nodes to the Kubernetes cluster.
- Manage storage and networking on your Kubernetes cluster.
- Provide regular Kubernetes updates and security fixes for your Kubernetes deployment.
- Keep up-to-date with the latest available Kubernetes versions.
- Use popular Azure services for Kubernetes.

## Simplify setting up on-premises Kubernetes

AKS simplifies the process of setting up Kubernetes on Windows Server 2019/2022 Datacenter, and includes the following features:

- A Windows Admin Center wizard for setting up AKS and its dependencies.
- A Windows Admin Center wizard for creating Kubernetes clusters to run your containerized applications.
- PowerShell cmdlets for setting up Kubernetes and creating Kubernetes clusters, if you prefer to use a script for host setup and Kubernetes cluster creation.

View the following image to familiarize yourself with the deployment process:

[![GIF showing AKS deployment.](../media/overview/aks-hci-deployment.gif)](../media/overview/aks-hci-deployment.gif#lightbox)

## View and manage on-premises Kubernetes by using tools or the Azure portal

After you set up on-premises Kubernetes by using AKS and create a Kubernetes cluster, you can manage and monitor your Kubernetes infrastructure with the following options:

- **The Azure portal**: Manage applications deployed on top of Kubernetes clusters across your cloud and on-premises environments.You can also manage your Kubernetes clusters with other Azure services including:
    - Azure Monitor
    - Azure Policy
- **On-premises by using popular tools such as Kubectl**: Many open-source tools allow you to deploy applications to a Kubernetes cluster, manage cluster resources, troubleshoot, and view running applications. All of these tools work with Kubernetes clusters deployed with AKS on Windows Server.

## Run Linux and Windows containers

AKS fully supports both Linux-based and Windows-based containers. When you create a Kubernetes cluster on Windows Server, you can choose whether to create node pools (groups of identical Kubernetes cluster nodes) to run Linux containers, Windows containers, or both.

AKS creates the Linux and Windows nodes so that you don't have to directly manage the Linux or Windows operating systems.

## Secure your container infrastructure

AKS includes features that help secure your container infrastructure:

- **Hypervisor-based isolation for worker nodes**: Each Kubernetes cluster runs on its own dedicated and isolated set of virtual machines so that tenants can share the same physical infrastructure.
- **Microsoft-maintained Linux and Windows images for worker nodes**: Worker nodes run Linux and Windows virtual machine images created by Microsoft to adhere to security best practices. Microsoft also refreshes these images monthly with the latest security updates.

## What you need to get started

The following sections summarize what you need to run on-premises Kubernetes with AKS on Windows Server. For complete details on what you need before you install AKS on Windows Server, see [system requirements](system-requirements).

### On your Windows Admin Center system

Your machine running the Windows Admin Center gateway must be:

- Registered with Azure.
- In the same domain as the Windows Server 2019/2022 Datacenter cluster.

### On the Windows Server cluster or Windows Server 2019/2022 Datacenter failover cluster that hosts AKS

The Windows Server cluster or Windows Server 2019/2022 Datacenter failover cluster has the following requirements:

- A maximum of eight servers in the cluster.
- 1 TB of available capacity in the storage pool for AKS.
- At least 30 GB of available memory for running AKS VMs.
- All servers in the cluster must use the EN-US region and language selection.

## AKS on Windows Server functionality

The following sections describe some of the functionality that AKS provides:

### Native integration with Azure

With AKS, you can connect your Kubernetes clusters to Azure. Once connected, you can access your Kubernetes clusters running on-premises via the Azure portal, and deploy management services such as GitOps and Azure Policy. You can also deploy data services such as SQL Managed Instance and PostgreSQL Hyperscale. For more information, see the [Azure Arc overview](/en-us/azure/azure-arc/kubernetes/overview).

### Integrated logging and monitoring

Once you connect your cluster to Azure, you can use Azure Monitor for monitoring the health of your Kubernetes cluster and applications. Azure Monitor for containers gives you performance visibility by collecting memory and processor metrics from controllers, nodes, and containers. Metrics and container logs are automatically collected for you and are sent to the metrics database in Azure Monitor, while log data is sent to your Log Analytics workspace. For more information about Azure Monitor, see the [container insights overview](/en-us/azure/azure-monitor/containers/container-insights-overview).

### Automatically resize your Kubernetes node pools

To keep up with application demands, you might need to adjust the number and size of nodes that run your workloads. The cluster autoscaler component watches for pods in your cluster that can't be scheduled because of resource constraints. When it detects issues, it increases the number of nodes in a node pool to meet the application demand. It also regularly checks nodes for a lack of running pods and decreases the number of nodes as needed. This ability to automatically scale up or down the number of nodes in your Kubernetes cluster lets you run an efficient, cost-effective environment.

### Deploy and manage Windows-based containerized apps

AKS fully supports running both Linux-based and Windows-based containers. When you create a Kubernetes cluster on Windows Server, you can choose whether to create node pools (groups of identical Kubernetes cluster nodes) to run Linux containers, Windows containers, or both. AKS creates the Linux and Windows nodes so that you don't have to directly manage the Linux or Windows operating systems.

### Deploy GPU-enabled nodes

AKS supports deploying GPU-enabled node pools on top of NVIDIA Tesla T4 GPUs by using Discrete Device Assignment (DDA) mode, also known as *GPU Passthrough*. In this mode, one or more physical GPUs are dedicated to a single worker node with a GPU-enabled VM size, which gets full access to the entire GPU. This mode offers high level application compatibility as well as better performance. For more information about GPU-enabled node pools, see the [GPU documentation](../local/hyperconverged/deploy-gpu-node-pool).