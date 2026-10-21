---
layout: Conceptual
title: Troubleshoot the LoadBalancerInUseByVirtualMachineScaleSet or NetworkSecurityGroupInUseByVirtualMachineScaleSet error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/load-balancer-or-nsg-in-use-by-vm-scale-set
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
description: Learn how to troubleshoot the LoadBalancerInUseByVirtualMachineScaleSet or NetworkSecurityGroupInUseByVirtualMachineScaleSet error when you try to delete an Azure Kubernetes Service (AKS) cluster.
ms.date: 2024-11-21T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: rissing, chiragpa, edneto, jaewonpark, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 405b16e9-495d-c82c-342a-cdb5de28b9c3
document_version_independent_id: 405b16e9-495d-c82c-342a-cdb5de28b9c3
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/load-balancer-or-nsg-in-use-by-vm-scale-set.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/load-balancer-or-nsg-in-use-by-vm-scale-set
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/load-balancer-or-nsg-in-use-by-vm-scale-set.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/96f6b0a2-2fd7-4de1-936d-89ad6e0eb7cc
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/ef8b0a5a-ba0a-4ec0-8636-48246ccd954f
platformId: 72275e1c-665c-ffff-156b-b4c90e9955d9
---

# Troubleshoot the LoadBalancerInUseByVirtualMachineScaleSet or NetworkSecurityGroupInUseByVirtualMachineScaleSet error code - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `LoadBalancerInUseByVirtualMachineScaleSet` or `NetworkSecurityGroupInUseByVirtualMachineScaleSet` error that occurs when you try to delete a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

When you try to delete an AKS cluster, you receive the following error message for `LoadBalancerInUseByVirtualMachineScaleSet`:

> 
> internalErrorCode: "LoadBalancerInUseByVirtualMachineScaleSet"
> 
> StatusCode=409
> 
> {
> 
> "Cannot delete load balancer .../Microsoft.Network/loadBalancers/kubernetes since its child resources aksOutboundBackendPool, kubernetes are in use by virtual machine scale set .../Microsoft.Compute/virtualMachineScaleSets/aks-worker-test-vmss"
> 
> }

Or, you receive the following error message for `NetworkSecurityGroupInUseByVirtualMachineScaleSet`:

> 
> internalErrorCode: "NetworkSecurityGroupInUseByVirtualMachineScaleSet"
> 
> StatusCode=409
> 
> {
> 
> "Cannot delete network security group .../Microsoft.Network/networkSecurityGroups/aks-agentpool since it is in use by virtual machine scale set .../Microsoft.Compute/virtualMachineScaleSets/aks-vmss"
> 
> }

## Cause

You tried to delete an AKS cluster while the virtual machine scale set was still using the associated public IP address or network security group (NSG).

## Solution

To fix this issue, use one of the following methods:

- Remove all public IP addresses that are associated with Azure Load Balancer. For more information, see [View, modify settings for, or delete a public IP address](/en-us/azure/virtual-network/ip-services/virtual-network-public-ip-address#view-modify-settings-for-or-delete-a-public-ip-address).
- Dissociate the NSG that's used by the subnet. For more information, see [Associate or dissociate a network security group](/en-us/azure/virtual-network/virtual-network-network-interface#associate-or-dissociate-a-network-security-group).