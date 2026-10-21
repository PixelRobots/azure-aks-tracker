---
layout: Conceptual
title: AKS Edge Essentials clusters and nodes | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-concept-clusters-nodes
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
description: Learn about clusters and nodes running on AKS Edge Essentials.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: concept-article
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-concept, edge-essentials
locale: en-us
document_id: c65d2fd6-03c4-7332-b00b-bae69b7982bb
document_version_independent_id: 3489893a-3377-f5e5-7d29-c722bc5b97cb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-concept-clusters-nodes.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-concept-clusters-nodes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-concept-clusters-nodes.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c21d0a62-47cf-4452-bd24-e1ed14abbeda
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f43eaf81-15c1-41e2-95b2-89fb1560c563
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: dd81d6ea-78bb-300b-d763-0b9460251835
---

# AKS Edge Essentials clusters and nodes | Microsoft Learn

This article describes how to create AKS Edge Essentials cluster deployments, nodes, and virtual machines.

## Virtual machine nodes

When you create an AKS Edge Essentials deployment, AKS Edge Essentials creates a virtual machine (VM) for each deployed node. AKS Edge Essentials manages the lifecycle, configuration, and updates of the VMs.

![Screenshot showing the the VMs in AKS Edge.](../media/aks-edge/aks-edge-vm.png)

Deployments can only create one Linux VM on a given host machine. This Linux VM can act as both the control plane node and as a worker node based on your deployment needs. This curated VM is based on [CBL-Mariner](https://github.com/microsoft/CBL-Mariner). CBL-Mariner is an internal Linux distribution for Microsoft's cloud infrastructure and edge products and services. CBL-Mariner is designed to provide a consistent platform for these devices and services and enhances Microsoft's ability to stay current on Linux updates. For more information, see [CBL-Mariner security](https://github.com/microsoft/CBL-Mariner/blob/2.0/SECURITY.md). The Linux virtual machine is built on a four-point comprehensive premise:

- Servicing updates
- Read-only root filesystem
- No package manager
- Reduced footprint

Running a Windows node is optional and you can create a Windows node if you need to deploy Windows containers. This node runs as a Windows virtual machine based on [Windows 10 IoT Enterprise LTSC 2019](/en-us/lifecycle/products/windows-10-iot-enterprise-ltsc-2019). The Windows VM brings all the security features and capabilities of Windows 10.

You can define the amount of CPU and memory resources that you want to allocate for each of the VMs. This static allocation enables you to control how resources are used and ensures that applications running on the host have the required resources.

Finally, AKS Edge Essentials doesn't offer dynamic creation of virtual machines. If a node VM goes down, you have to recreate it. That said, if you have a full deployment with multiple control plane nodes and worker nodes, if a VM goes down, Kubernetes moves workloads to an active node.

## Node types

When deploying AKS Edge Essentials nodes, you should specify the `-NodeType` parameter. This parameter indicates the types of workloads can run on this machine, and will tell AKS Edge Essentials to create the corresponding VM. The possible values are **Linux**, **Windows**, or **LinuxAndWindows**.

Important

Kubernetes control plane components are written in Linux, so the first node you deploy must include a Linux node.

## Cluster deployment options

After you set up your machines, you can deploy AKS Edge Essentials in the following configurations:

- **Single machine cluster**: Runs Kubernetes nodes on a single machine to create a single machine cluster. This deployment uses an internal network switch to enable communication across the nodes. This deployment supports only one Linux node and one Windows node, both running on a single machine.
- **Scalable cluster**: Lets you create a multi-node Kubernetes cluster that can be scaled across multiple machines.

![Diagram showing AKS Edge Essentials deployment scenarios.](../media/aks-edge/aks-edge-deployment-options.jpg)

Once you create your cluster, you can deploy your applications and connect your cluster to Arc, to enable Arc extensions such as Azure Monitor and Azure Policy. You can also choose to use GitOps to manage your deployments.