---
layout: Conceptual
title: Best Practices for Windows Containers on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/windows-best-practices
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
description: Learn about best practices for running Windows containers in Azure Kubernetes Service (AKS).
ms.custom: linux-related-content, aks-windows
ms.author: schaffererin
author: schaffererin
ms.topic: best-practice
ms.date: 2026-07-13T00:00:00.0000000Z
locale: en-us
document_id: 3de6382e-fc65-1a1f-6d1a-c8565b17fb8f
document_version_independent_id: 7603e24c-99ca-a09e-fcb4-f2e983b023b6
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/windows-best-practices.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/windows-best-practices
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/windows-best-practices.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: 287bd0ce-5f40-97d7-d9d9-6e5dcfae9579
---

# Best Practices for Windows Containers on Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Important

Starting on **May 15, 2026**, AKS no longer supports Windows Server Annual Channel (Preview). AKS will no longer produce new Windows Server Annual Channel node images or provide security patches. You won't be able to create new node pools with Windows Server Annual Channel. On **May 15, 2027**, AKS will remove all existing Windows Server Annual Channel node images, which will cause scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, we recommend migrating to the [Long Term Servicing Channel (LTSC)](/en-us/azure/aks/upgrade-windows-os).

- Windows Server Annual Channel uses Windows Server 2022 base images, which will run on Windows Server 2022 and Windows Server 2025.
- If you're using [Host Process Containers (HPC)](use-windows-hpc) or running other privileged containers for administration purposes, you need to do extra testing.

For more information on this retirement, see the [Retirement GitHub issue](https://aka.ms/aks/windows-annual-channel-retirement). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

In AKS, you can create node pools that run Linux or Windows Server as the operating system (OS) on the nodes. Windows Server nodes can run native Windows container applications, such as .NET Framework. The Linux OS and Windows OS have different container support and configuration considerations. For more information, see [Windows container considerations in Kubernetes](windows-vs-linux-containers). To learn more about how various industries are using Windows containers on AKS, see [Windows AKS customer stories](windows-aks-customer-stories).

This article outlines best practices for running Windows containers on AKS.

## Create an AKS cluster with Linux and Windows node pools

When you create a new AKS cluster, the Azure platform creates a Linux node pool by default. This node pool contains system services needed for the cluster to function. Azure also creates and manages a control plane abstracted from the user, which means you aren't exposed to the underlying OS of the nodes hosting the main control plane components. We recommend that you run at least *two nodes* on the default Linux node pool to ensure the reliability and performance of your cluster. You can't delete the default Linux node pool unless you delete the entire cluster.

There are some cases where you should consider deploying a Linux node pool when planning to run Windows-based workloads on your AKS cluster, such as:

- If you want to run Linux and Windows workloads, you can deploy a Linux node pool and a Windows node pool in the same cluster.
- If you want to deploy infrastructure-related components based on Linux, such as NGINX, you need a Linux node pool alongside your Windows node pool. You can use control plane nodes for development and testing scenarios. For production workloads, we recommend that you deploy separate Linux node pools to ensure reliability and performance.

## Modernize existing applications with Windows on AKS

You might want to containerize existing applications and run them using Windows on AKS. Before starting the containerization process, it's important to understand the application architecture and dependencies. For more information, see [Containerize existing applications using Windows containers](/en-us/virtualization/windowscontainers/quick-start/lift-shift-to-containers).

## Windows OS version

> 
> **Best practice guidance**
> 
> Windows Server 2025 provides improved security and performance and is the recommended OS for Windows node pools on AKS.

AKS supports two options for the Windows Server operating system: Long Term Servicing Channel Releases (LTSC) and Windows Server Annual Channel for Containers.

1. AKS supports Long Term Servicing Channel Releases (LTSC), including Windows Server 2025 and Windows Server 2022. This channel is released every three years and is supported for five years. Customers using Long Term Support (LTS) should use Windows Server 2025.

    AKS uses Windows Server 2025 and Windows Server 2022 as the host OS version and only supports process isolation. AKS doesn't support container images built by other versions of Windows Server. For more information, see [Windows container version compatibility](/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility). Windows Server 2022 is the default OS for Kubernetes versions 1.25 to 1.35, and Windows Server 2025 is the default OS for Kubernetes version 1.36 and later.

    Important

    Starting on June 30, 2028, Azure Kubernetes Service (AKS) no longer supports Windows Server 2022 node pools. Windows Server 2022 isn't supported in Kubernetes version 1.37 and later. Starting on June 30, 2029, AKS will remove all existing node images for Windows Server 2022, meaning that scaling operations will fail. For more information on this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4168) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=ws2022-retirement-aks). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).
2. AKS supports [Windows Server Annual Channel for Containers](https://techcommunity.microsoft.com/t5/windows-server-news-and-best/windows-server-annual-channel-for-containers/ba-p/3866248) (preview). This channel is released annually and is supported for two years. This channel is beneficial for customers requiring increased innovation cycles and portability. The portability functionality enables the Windows Server 2022-based container image OS to run on newer versions of Windows Server host OS, such as the new annual channel release.

    Windows Annual Channel versions are based on the Kubernetes version of your node pool. To upgrade from one Annual Channel version to the next, [upgrade to a Kubernetes version](upgrade-aks-cluster) that supports the next Annual Channel version. For more information, see [Windows Server Annual Channel for Containers on AKS](windows-annual-channel).

    Important

    Starting on **May 15, 2026**, AKS no longer supports Windows Server Annual Channel (Preview). AKS will no longer produce new Windows Server Annual Channel node images or provide security patches. You won't be able to create new node pools with Windows Server Annual Channel. On **May 15, 2027**, AKS will remove all existing Windows Server Annual Channel node images, which will cause scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, we recommend migrating to the [Long Term Servicing Channel (LTSC)](/en-us/azure/aks/upgrade-windows-os).

    - Windows Server Annual Channel uses Windows Server 2022 base images, which will run on Windows Server 2022 and Windows Server 2025.
    - If you're using [Host Process Containers (HPC)](use-windows-hpc) or running other privileged containers for administration purposes, you need to do extra testing.

    For more information on this retirement, see the [Retirement GitHub issue](https://aka.ms/aks/windows-annual-channel-retirement). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Monitoring

> 
> **Best practice guidance**
> 
> Windows Exporter is installed on all Windows nodes in certain regions. To view regional rollout, see [AKS Github](https://github.com/Azure/AKS/issues/3465). With Managed Prometheus and Grafana, you can monitor default collectors included in Windows Exporter on AKS. For more information, see [default Prometheus metrics configured in Azure Monitor](/en-us/azure/azure-monitor/containers/prometheus-metrics-scrape-default).

Windows Exporter allows customers to see their metrics through Managed Prometheus or Prometheus OSS deployments and enjoy enhanced observability around their node and pod performance, health, and resource usage. These metrics are also visible with Managed Grafana.

- When enabling managed prometheus, add this required parameter for correct dashboard data presentation for Windows: `--enable-windows-recording-rules`.
- Grafana includes dashboards for showing Windows resources, such as:
    - Kubernetes / Compute Resources / Cluster (Windows)
    - Kubernetes / Compute Resources / Namespace (Windows)
    - Kubernetes / Compute Resources / Pod (Windows)
    - Kubernetes / USE Method / Cluster (Windows)
    - Kubernetes / USE Method / Node (Windows)

The default collectors included in Windows Exporter on AKS are: cpu, cpu\_info, cs, container, logical\_disk, memory, net, os, process, service, system, textfile. The metrics are exposed on port **19182** on the windows node. For more information on what metrics you can see using these collectors, please see [prometheus-community/windows_exporter](https://github.com/prometheus-community/windows_exporter#collectors).

## Networking

### Networking modes

> 
> **Best practice guidance**
> 
> AKS clusters with Windows node pools only support Azure Container Networking Interface (Azure CNI) and use it by default.

Windows doesn't support kubenet networking. AKS clusters with Windows node pools must use Azure CNI. For more information, see [Network concepts for applications in AKS](concepts-network).

Azure CNI offers two networking modes based on your workload requirements:

- [**Azure CNI Overlay**](azure-cni-overlay) is an overlay network similar to kubenet. The overlay network allows you to use virtual network (VNet) IPs for nodes and private address spaces for pods within those nodes that you can reuse across the cluster. Azure CNI Overlay is the **recommended networking mode**. It provides simplified network configuration and management and the best scalability in AKS networking.
- [**Azure CNI with Dynamic IP Allocation**](configure-azure-cni-dynamic-ip-allocation) requires extra planning and consideration for IP address management. This mode provides VNet IPs for nodes *and* pods. This configuration allows you direct access to pod IPs. However, it comes with increased complexity and reduced scalability.

To help you decide which networking mode to use, see [Choosing a network model](concepts-network-azure-cni-overlay#choose-a-network-model).

### Network policies

> 
> **Best practice guidance**
> 
> Use network policies to secure traffic between pods. Windows supports Azure Network Policy Manager and Calico Network Policy. For more information, see [Differences between Network Policy engines: Cilium, Azure NPM, and Calico](use-network-policies#differences-between-network-policy-engines-cilium-azure-npm-and-calico).

When managing traffic between pods, you should apply the principle of least privilege. The Network Policy feature in Kubernetes allows you to define and enforce ingress and egress traffic rules between the pods in your cluster. For more information, see [Secure traffic between pods using network policies in AKS](use-network-policies).

Windows pods on AKS clusters that use the Calico Network Policy enable Floating IP by default.

## Upgrades and updates

It's important to keep your Windows environment up-to-date to ensure your systems have the latest security updates, feature sets, and compliance requirements. In a Kubernetes environment like AKS, you need to maintain the Kubernetes version, Windows nodes, and Windows container images and pods.

### Kubernetes version upgrades

As a managed Kubernetes service, AKS provides the necessary tools to upgrade your cluster to the latest Kubernetes version. For more information, see [Upgrade an AKS cluster](upgrade-cluster).

### Windows node monthly updates

Windows nodes on AKS follow a monthly update schedule. Every month, AKS creates a new VHD with the latest available updates for Windows node pools. The VHD includes the host image, latest Nano Server image, latest Server Core image, and container. We recommend performing monthly updates to your Windows node pools to ensure your nodes have the latest security patches. For more information, see [Upgrade AKS node images](node-image-upgrade).

Note

Upgrades on Windows systems include both OS version upgrades and monthly node OS updates.

You can stay up to date with the availability of new monthly releases using the [AKS release tracker](https://releases.aks.azure.com/) and [AKS release notes](https://github.com/Azure/AKS/releases).

### Windows node OS version upgrades

Windows has a release cadence for new versions of the OS, including Windows Server 2025 and Windows Server 2022. When upgrading your Windows node OS version, ensure the Windows container image version matches the Windows container host version and the node pools have only one version of Windows Server.

To upgrade the Windows node OS version, you need to complete the following steps:

1. Create a new node pool with the new Windows Server version.
2. Deploy your workloads with the new Windows container images to the new node pool.
3. Decommission the old node pool.

For more information, see [Upgrade Windows Server workloads on AKS](upgrade-windows-2019-2022).