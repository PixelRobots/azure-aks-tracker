---
layout: Conceptual
title: Virtual Machine (VM) Sizes, Generations, and Features for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-virtual-machine-sizes
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
description: Learn about VM fundamentals on AKS, like different VM sizes, generations, features, how to check for available VM sizes, why some VM sizes might not be available, and what happens when a VM size retires.
ms.topic: overview
ms.subservice: aks-nodes
ms.date: 2025-08-05T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 975d2551-e1a9-41f5-2aad-de3ce3c0f69b
document_version_independent_id: ebb2a7ce-1f2d-87e4-11b9-0fe55d354355
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-virtual-machine-sizes.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/aks-virtual-machine-sizes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-virtual-machine-sizes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
platformId: 1e6c4f57-e447-8ae5-76e0-273252ddb96d
---

# Virtual Machine (VM) Sizes, Generations, and Features for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) supports various virtual machine (VM) sizes, generations, and features to accommodate different workloads and performance requirements. This article provides an overview of available VM sizes and generations for AKS, how to check for available VM sizes in your region, reasons why certain VM sizes might not be available, and what happens when a VM size retires.

## VM support on AKS

Azure supports both Generation 1 (Gen 1) and [Generation 2 (Gen 2) virtual machines (VMs)](/en-us/azure/virtual-machines/generation-2). With some [exceptions](/en-us/windows-server/virtualization/hyper-v/plan/should-i-create-a-generation-1-or-2-virtual-machine-in-hyper-v), we generally recommend migrating to Generation 2 VMs to take advantage of the newest features and functionalities in Azure VMs.

The VM size and operating system (OS) you select when creating an AKS node pool determines the VM generation and [node image](node-images) used. Check the [list of supported sizes](/en-us/azure/virtual-machines/generation-2#generation-2-vm-sizes) to see if your SKU supports or requires Gen 2.

### Limitations

There are some limitations to take into account when choosing a VM generation and/or OS:

- Trusted Launch can only be enabled on VM sizes that support Gen 2.
- Confidential VM sizes always use Gen 2 on AKS.
- Arm64 VM sizes always use Gen 2 on AKS.
- Windows Server 2019 node pools don't support Gen 2 VM sizes.
- Windows Server 2022 node pools require use of a custom header to use Gen 2.

To use Gen 2 VMs on AKS, see Use Gen 2 VMs.

## Available VM features

AKS supports various VM features that enhance security, performance, and functionality. Some key features include:

- [**Node autoprovisioning (NAP)**](node-autoprovision) uses pending pod resource requirements to decide the optimal VM configuration to run your workloads efficiently and cost-effectively.
- [**Virtual Machines node pools**](virtual-machines-node-pools) provide a better experience for dynamic workloads and high availability requirements. Virtual Machines node pools enable you to set up multiple similar-family VMs in a single node pool. Your workloads are automatically scheduled on the available resources you configure.

## Supported VM sizes

For in-depth information about VM sizes available in Azure, see [Azure VM sizes](/en-us/azure/virtual-machines/sizes/overview?tabs=breakdownseries%2Cgeneralsizelist%2Ccomputesizelist%2Cmemorysizelist%2Cstoragesizelist%2Cgpusizelist%2Cfpgasizelist%2Chpcsizelist). To view supported Gen 2 VM sizes, see [Generation 2 VM sizes](/en-us/azure/virtual-machines/generation-2).

AKS also supports the following VM types and features:

- [Confidential VMs (CVMs)](use-cvm)
- [Arm-based processor (Arm64) VMs](use-arm64-vms)
- [GPU-optimized VMs](/en-us/azure/virtual-machines/sizes/overview?tabs=breakdownseries%2Cgeneralsizelist%2Ccomputesizelist%2Cmemorysizelist%2Cstoragesizelist%2Cgpusizelist%2Cfpgasizelist%2Chpcsizelist#gpu-accelerated)
- [Trusted Launch](use-trusted-launch)
- [Federal Information Processing Standards (FIPS)](enable-fips-nodes)

### Default behavior for supported VM sizes

There are three scenarios when creating a node pool with a supported VM size:

- If the VM size supports only Gen 1, the default behavior for both Linux and Windows node pools is to use the Gen 1 node image.
- If the VM size supports only Gen 2, the default behavior for both Linux and Windows node pools is to use the Gen 2 node image. Windows Server 2022 node pools require a custom header to use a VM size that only supports Gen 2. For more information, see [Create a Windows node pool with a Gen 2 VM](generation-2-vms#create-a-node-pool-with-a-gen-2-vm).
- If the VM size supports both Gen 1 and Gen 2, the default behavior for both Linux and Windows (in Windows Server 2025+) nodes pools is to use the Gen 2 node image. To use the Gen 2 node image for Windows Server 2022, see [Create a Windows node pool with a Gen 2 VM](generation-2-vms#create-a-node-pool-with-a-gen-2-vm).

## Check available VM sizes

Check available VM sizes using the [`az vm list-skus`](/en-us/cli/azure/vm#az-vm-list-skus) command.

```azurecli
az vm list-skus --location <your-location> --output table
```

## Why certain VM sizes might not be available

There are several reasons why certain VM sizes might not be available, including:

- **Quota limits**: All Azure services set default limits and quotas for resources and features. For more information, see the following resources:

    - [Quotas and regional limits for Azure Kubernetes Service (AKS)](quotas-skus-regions)
    - [Check your quota usage](/en-us/azure/virtual-machines/quotas)
    - [Request a quota increase through an Azure support request](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/newsupportrequest) (for **Issue type**, select **Quota**)

    Note

    - For ***user node pools***, VM sizes with *fewer than two vCPUs and two GBs of memory (RAM)* might not be used by default.
    - For ***system node pools***, VM sizes with *fewer than two vCPUs and four GBs of memory (RAM)* might not be used by default. To ensure that you can reliably schedule the required `kube-system` pods and your applications, we recommend that you **do not use any [B series VMs](/en-us/azure/virtual-machines/sizes/general-purpose/bv1-series) or [Av1 series VMs](/en-us/azure/virtual-machines/sizes/retirement/av1-series-retirement)**.
- **VM sizes in preview**: VM sizes in preview might not be available to you if you haven't registered the preview flag for the VM size.
- **Blocked by AKS**: Some VM sizes might not be available by default in AKS. These sizes might require extra testing or validation to ensure compatibility with AKS. If you need a specific VM size that isn't available to you, you can [submit a GitHub issue request](https://github.com/Azure/AKS/issues).

Make sure you understand which features your workloads need and choose a VM size that meets those requirements. Later VM versions typically have better performance and improved features. For example, Gen 2 VMs have increased security and performance benefits over Gen 1 VMs.

## What happens when a VM size retires?

When a VM size or series reaches its retirement date, the VM is deallocated. VM deallocation causes your AKS node pools to break. To check the retirement status of a VM size, see [Retired Azure VM size series](/en-us/azure/virtual-machines/sizes/retirement/retired-sizes-list) or perform a search in [Azure Updates](https://azure.microsoft.com/updates). To check the VM size of your node pools, use the [`az aks nodepool list`][az-aks-nodepool-list] command and query for the `vmSize` property:

```azurecli
az aks nodepool list --resource-group <your-resource-group> --cluster-name <your-cluster-name> --query "[].{Name:name, VMSize:vmSize}" --output table
```

If you're using a VM size that's retiring/retired, we recommend migrating your node pools to a supported VM size to prevent any potential disruption to your service. Currently, AKS *doesn't support* transitioning to a new VM size within the same node pool.

## Migrate node pools to a supported VM size

Once you determine the appropriate node pools to take action on, you can [resize your node pools](resize-node-pool). During the resizing process, a new node pool is created and workloads are migrated to the new node pool.

For more information on migrating to a new VM size, see the following resources:

- Migrate from Gen 1 to Gen 2 VMs
- [General-purpose sizes migration guide](/en-us/azure/virtual-machines/migration/sizes/d-ds-dv2-dsv2-ls-series-migration-guide)
- [Storage-optimized sizes migration guide](/en-us/azure/virtual-machines/migration/sizes/d-ds-dv2-dsv2-ls-series-migration-guide)
- [GPU-accelerated sizes migration guide](/en-us/azure/virtual-machines/migration/sizes/n-series-migration)
- [Azure Dedicated Host SKU migration guide](/en-us/azure/virtual-machines/migration/dedicated-host-migration-guide)

## Gen 2 VMs on AKS

Gen 2 VMs are generally Azure's newer offerings and have exclusive features over Gen 1 VMs like increased memory, improved CPU performance, support for NVMe disks, and support for [Trusted Launch](use-trusted-launch).

While we generally recommend running Gen 2 VMs, you should make sure that the generation you choose supports your requirements. To learn more about the differences between generations, and when one might make more sense than the other, see [Should I create a Gen 1 or 2 VM in Hyper-V?](/en-us/windows-server/virtualization/hyper-v/plan/should-i-create-a-generation-1-or-2-virtual-machine-in-hyper-v)

To use Gen 2 VMs on AKS, see [Use generation 2 VMs on AKS](generation-2-vms).