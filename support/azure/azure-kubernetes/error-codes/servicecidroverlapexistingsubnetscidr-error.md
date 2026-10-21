---
layout: Conceptual
title: Troubleshoot ServiceCidrOverlapExistingSubnetsCidr Error Code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/servicecidroverlapexistingsubnetscidr-error
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
description: Learn how to resolve the ServiceCidrOverlapExistingSubnetsCidr error that occurs when you try to upgrade an Azure Kubernetes Service (AKS) cluster.
ms.date: 2026-09-25T00:00:00.0000000Z
ms.reviewer: cssakscic, v-leedennis, andraciobanu, jotavar
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: 656cdfc1-8792-4dc5-aa7b-fc54173408a5
document_version_independent_id: 656cdfc1-8792-4dc5-aa7b-fc54173408a5
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/servicecidroverlapexistingsubnetscidr-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/servicecidroverlapexistingsubnetscidr-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/servicecidroverlapexistingsubnetscidr-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
platformId: d89443f0-a966-68f0-b420-c908fd2c366c
---

# Troubleshoot ServiceCidrOverlapExistingSubnetsCidr Error Code - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the "ServiceCidrOverlapExistingSubnetsCidr" error that might occur when you try to [upgrade a Microsoft Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/upgrade-aks-cluster). Use these solutions to fix the service CIDR and subnet overlap so that your cluster upgrade can finish.

## Symptoms

An AKS cluster upgrade operation fails and displays the following error message:

> 
> (ServiceCidrOverlapExistingSubnetsCidr) The specified service CIDR &lt;service-cidr-1&gt; is conflicted with an existing subnet CIDR &lt;subnet-cidr-2&gt; Code: ServiceCidrOverlapExistingSubnetsCidr Message: The specified service CIDR &lt;service-cidr-1&gt; is conflicted with an existing subnet CIDR &lt;subnet-cidr-2&gt; Target: networkProfile.serviceCIDR

## Cause

The service address range of a cluster is the set of virtual IP addresses that Kubernetes assigns to internal services in the cluster. You define this range when you create the cluster. The range shouldn't overlap with the cluster's virtual network or any other network that you can route from the cluster. For more information, see [Deployment parameters](/en-us/azure/aks/azure-cni-overview#deployment-parameters).

Before AKS starts an upgrade operation, it checks the cluster's virtual network for any existing subnet Classless Inter-Domain Routing (CIDR) address spaces that overlap with the cluster's service CIDR. If the check finds any subnet overlap, the operation generates the "ServiceCidrOverlapExistingSubnetsCidr" error.

To resolve this issue, use one of the following solutions.

Before applying the solutions, use Azure PowerShell to run the following discovery commands.

```azurepowershell

az aks show \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --query "{serviceCIDR:networkProfile.serviceCidr,subnets:agentPoolProfiles[].vnetSubnetId}" \
  --output json

  az network vnet subnet list \
  --resource-group <vnet-resource-group> \
  --vnet-name <vnet-name> \
  --query "[].{name:name,addressPrefix:addressPrefix,addressPrefixes:addressPrefixes}" \
  --output table

```

Confirm any overlap while considering the following:

- Clarify whether AKS validates only subnets in the cluster virtual network or also peered and routable networks.
- Cover multiple node pools and virtual networks with multiple address spaces.
- Verify that a subnet has no connected resources before deletion.
- Explain that changing a subnet prefix can require removing or migrating attached resources.
- Add migration considerations for workloads, persistent data, identities, Domain Name System (DNS), ingress, and downtime before recommending redeployment.

## Solution 1: Remove the overlapping subnet

Note

Use this solution if no resources are attached to the subnet.

Follow these steps to remove the overlapping subnet:

1. Delete the subnet. To delete the subnet, follow the steps in [Delete a subnet](/en-us/azure/virtual-network/virtual-network-manage-subnet#delete-a-subnet).
2. Retry the AKS cluster upgrade operation.

## Solution 2: Adjust the overlapping subnet address range

Note

Use this solution if it's acceptable to change the subnet's address range.

Follow these steps to adjust the overlapping subnet address range:

1. Change the subnet's address range. To change the address range, follow the steps in [Change subnet settings](/en-us/azure/virtual-network/virtual-network-manage-subnet#change-subnet-settings).
2. Retry the AKS cluster upgrade operation.

## Solution 3: Redeploy the cluster with a different service CIDR

Note

Use this solution if it's not acceptable or not possible to remove the overlapping subnet or adjust its configuration. You can't change the cluster's service CIDR after cluster creation.

Review the [deployment parameters](/en-us/azure/aks/azure-cni-overview#deployment-parameters) and redeploy your cluster by using a different service CIDR.

Use Azure PowerShell to validate the post-change configuration.

Run the following commands.

```azurepowershell

az aks upgrade \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --kubernetes-version <version>

kubectl get nodes
kubectl get pods --all-namespaces
kubectl get services --all-namespaces

```