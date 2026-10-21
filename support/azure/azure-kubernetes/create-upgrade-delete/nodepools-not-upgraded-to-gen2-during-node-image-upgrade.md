---
layout: Conceptual
title: Windows Node Pools Not Upgraded to Gen2 During Cluster Node Image Upgrade - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/nodepools-not-upgraded-to-gen2-during-node-image-upgrade
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
description: Troubleshoot an issue that prevents Windows Server node pools from upgrading automatically to Gen2 when a cluster node image is upgraded in Azure Kubernetes Service.
ms.date: 2025-04-17T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: chiragpa, cssakscic, momajed
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or node pool)
locale: en-us
document_id: 0e68749f-2ea6-ceab-85c2-8e54b8fe127b
document_version_independent_id: 0e68749f-2ea6-ceab-85c2-8e54b8fe127b
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/nodepools-not-upgraded-to-gen2-during-node-image-upgrade.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/nodepools-not-upgraded-to-gen2-during-node-image-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/nodepools-not-upgraded-to-gen2-during-node-image-upgrade.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 0cb69245-ea55-31ac-f995-3b57c909af6a
---

# Windows Node Pools Not Upgraded to Gen2 During Cluster Node Image Upgrade - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot a scenario in which Windows Server node pools don't get upgraded automatically from Gen1 to Gen2 virtual machines (VMs) when a cluster node image is upgraded in Microsoft Azure Kubernetes Service (AKS).

Note

This scenario doesn't apply to Gen2 VMs on Linux node pools.

## Prerequisites

- Azure CLI version 2.0.81 or later. See [Install Azure CLI](/en-us/cli/azure/install-azure-cli) for installation instructions.

## Symptoms

Existing Windows Server node pools don't get upgraded from Gen1 to Gen2 when you [upgrade the node image](/en-us/azure/aks/node-image-upgrade) by using one of the following methods in Azure CLI:

- An entire cluster upgrade (by using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command)
- A specific node pool upgrade (by using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command)

## Cause

### Cause 1: Existing node pools aren't automatically upgraded to Gen2 VMs

By design, a node image upgrade doesn't support updating or upgrading existing node pools. The `az aks upgrade` and `az aks nodepool upgrade` commands upgrade only the node image (to a later node image version). These commands don't upgrade the corresponding VM generation.

### Cause 2: Cluster upgrade to Kubernetes version 1.25 or a later version upgrades only the OS

When you upgrade your cluster to Kubernetes version 1.25 or a later version, only the operating system (OS) is upgraded (to Windows Server 2022). Existing node pools aren't affected. The associated Azure Virtual Machine Scale Sets contain VMs that have the same Gen1 VM.

### Cause 3: Cluster upgraded and new node pool created by using Windows Server 2022 without specifying a valid VM size

After you upgrade the cluster to Kubernetes version 1.25 or a later version, you specify Windows Server 2022 as the OS to use on the node pool's VMs. However, the VMs don't use a Gen2 node image reference for one of the following reasons:

- You don't specify a VM size, and the default VM size in the region doesn't support Gen2 VMs.
- You specify a Gen1-only VM size.

When you upgrade the default OS from Windows Server 2019 (`Windows2019`) to Windows Server 2022 (`Windows2022`), the existing node pools aren't automatically upgraded to a different VM generation.

## Solution

Upgrade the cluster, and then create a new Windows Server node pool that supports [Gen2 VM sizes](/en-us/azure/virtual-machines/generation-2) on that cluster according to the following guidelines.

| Kubernetes cluster upgrade version | Cluster creation guidelines |
| --- | --- |
| 1.25 or a later version | When you run the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command to create a cluster, set the `--node-vm-size` parameter to a [Gen2 VM size](/en-us/azure/virtual-machines/generation-2). |
| Any version earlier than 1.25 | When you run the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command to create a cluster, set the `--os-sku` parameter value to `Windows2022`, and set the `--node-vm-size` parameter value to a [Gen2 VM size](/en-us/azure/virtual-machines/generation-2). |

Note

If you specify a Gen2 VM size and set the operating system as Windows Server 2019, you receive an `ErrorCode_Windows2019NotSupportedWithGen2VM` error code that's accompanied by the following error message:

> 
> &lt;virtual-machine-size&gt; is a Gen 2-only VM. Windows2019 does not support Gen 2 VMs. However, you can select a Gen 1 VM size or set os\_sku to 2022.

To avoid this problem, choose one of the following options when you create the cluster:

- Pick a Gen1 VM size to use together with Windows Server 2019.
- Set the operating system SKU to **Windows Server 2022** to use together with your Gen2 VM.
- Before you create a new node pool, verify that the VM size supports Gen2 VMs in your region. To do this, run `az vm list-sizes --location <region> --query "[?contains(name, 'v2')].name" --output table`.
- To verify the current and available node image versions, run the following commands:

    - To check the current version: `az aks nodepool show --resource-group <resource-group> --cluster-name <cluster-name> --name <nodepool-name> --query nodeImageVersion`
    - To check the latest available version: `az aks nodepool get-upgrades --resource-group <resource-group> --cluster-name <cluster-name> --nodepool-name <nodepool-name> --query latestNodeImageVersion`