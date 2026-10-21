---
layout: Conceptual
title: A public IP address/subnet/network security group in use can't be deleted - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/publicipaddr-inusesubnet-netsecgrp-error
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
description: Resolve AKS cluster deletion errors when public IP addresses, subnets, or network security groups are in use. Follow steps to delete the cluster successfully.
ms.date: 2024-12-04T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: rissing, chiragpa, edneto, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 41c5765a-a723-f024-8a12-01984ecd782b
document_version_independent_id: 41c5765a-a723-f024-8a12-01984ecd782b
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/publicipaddr-inusesubnet-netsecgrp-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/publicipaddr-inusesubnet-netsecgrp-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/publicipaddr-inusesubnet-netsecgrp-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: eab9f90e-38bc-ed64-d70d-6b053fa63db7
---

# A public IP address/subnet/network security group in use can't be deleted - Azure | Microsoft Learn

## Summary

This article explains how to resolve AKS cluster deletion errors such as `PublicIPAddressCannotBeDeleted`, `InUseSubnetCannotBeDeleted`, and `InUseNetworkSecurityGroupCannotBeDeleted` so you can delete the cluster successfully.

## Symptoms

When you try to delete an AKS cluster, you receive one of the following error messages:

- For the `PublicIPAddressCannotBeDeleted` error code:

> 
> {
> 
> message: "Public IP address ...../providers/Microsoft.Network/publicIPAddresses/ can not be deleted since it is still allocated to resource ...../providers/Microsoft.Network/loadBalancers/kubernetes/frontendIPConfigurations/..... . In order to delete the public IP, disassociate/detach the Public IP address from the resource."
> 
> }
- For the `InUseSubnetCannotBeDeleted` error code:

> 
> {
> 
> message: "Subnet aks-subnet is in use by …../Microsoft.Network/networkInterfaces/|providers|Microsoft.Compute|virtualMachineScaleSets|vmss|virtualMachines|1|networkInterfaces|aks-worker-vmss/ipConfigurations/ipconfig1 and cannot be deleted. In order to delete the subnet, delete all the resources within the subnet."
> 
> }

    or

> 
> {
> 
> message: "Subnet aks-subnet is in use by ..../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/.../subnets/.../serviceAssociationLinks/AppServiceLink and cannot be deleted. In order to delete the subnet, delete all the resources within the subnet. See aka.ms/deletesubnet."
> 
> }
- For the `InUseNetworkSecurityGroupCannotBeDeleted` error code:

> 
> {
> 
> message: "Network security group …../Microsoft.Network/networkSecurityGroups/test cannot be deleted because it is in use by the following resources: ...../Microsoft.Network/virtualNetworks/test/subnets/test. In order to delete the Network security group, remove the association with the resource(s)."
> 
> }

## Cause

The AKS cluster is associated with a subnet, network security group (NSG), or specific public IP address that's currently being used. This association prevents you from deleting the cluster.

## Solution

- Remove all public IP addresses that are associated with Azure Load Balancer and the resource that's used by the subnet. For more information, see [View, modify settings for, or delete a public IP address](/en-us/azure/virtual-network/ip-services/virtual-network-public-ip-address#view-modify-settings-for-or-delete-a-public-ip-address).
- In the load balancer, remove the rules for **Load Balance rules**, **Health probes**, and **Backend pools**.
- For the NSG and subnet, remove all associated rules. For more information, see [Associate or dissociate a network security group to or from a subnet or network interface](/en-us/azure/virtual-network/manage-network-security-group#associate-or-dissociate-a-network-security-group-to-or-from-a-subnet-or-network-interface).
- If you're using an App Service plan with a subnet connected to the AKS cluster's VNET, you have to remove the associated App Service plan and its internal resources (such as Function App and SQL Azure database) and then retry deleting the AKS cluster.