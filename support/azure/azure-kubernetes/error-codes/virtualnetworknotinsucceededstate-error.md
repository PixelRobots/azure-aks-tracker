---
layout: Conceptual
title: Troubleshoot the VirtualNetworkNotInSucceededState error code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/virtualnetworknotinsucceededstate-error
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
description: Troubleshoot the VirtualNetworkNotInSucceededState error in AKS. Learn why your cluster or node pool deployment fails and how to fix it quickly.
ms.date: 2025-08-07T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: v-liuamson
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 3d9d32dd-3d20-462b-87e2-603813123d44
document_version_independent_id: 3d9d32dd-3d20-462b-87e2-603813123d44
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/virtualnetworknotinsucceededstate-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/virtualnetworknotinsucceededstate-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/virtualnetworknotinsucceededstate-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
platformId: 072b82f1-e053-03c9-6eb9-a2271d3adb5e
---

# Troubleshoot the VirtualNetworkNotInSucceededState error code - Azure | Microsoft Learn

## Summary

## Symptoms

When you create, upgrade, or scale an Azure Kubernetes Service (AKS) cluster or node pool, the deployment fails and returns an error message that resembles the following message:

*Status=400 Code="VirtualNetworkNotInSucceededState"*

*Message="Set virtual network ownership failed. Subscription: &lt;SUBSCRIPTION&gt;; resource group: &lt;RESOURCE GROUP&gt;; virtual network name: &lt;VNET NAME&gt;. autorest/azure: Service returned an error. Status=400 Code="VirtualNetworkNotInSucceededState" Message="Virtual network /subscriptions/&lt;SUBSCRIPTION&gt;/resourceGroups/&lt;RESOURCE GROUP&gt;/providers/Microsoft.Network/virtualNetworks/&lt;VNET&gt; is in Updating state. It needs to be in Succeeded state in order to set resource ownership.*

## Cause

AKS can set ownership on a virtual network only if the `provisioningState` of the VNet is **Succeeded**. The request fails if the VNet is in the **Updating**, **Deleting**, or **Failed** state. Common causes for this condition include:

- Another create, update, or delete operation is still running on the VNet.
- A previous network operation failed and left the VNet in the **Failed** state.
- Multiple parallel cluster or node pool deployments are trying to modify the same VNet at the same time.

## Resolution

Check the current provisioning state of the VNet:

```dotnetcli
az network vnet show -g \<resource-group\> -n \<vnet-name\> \--query \"provisioningState\" -o tsv
```

If the command returns **Succeeded**, the VNet is fully set up and ready for use, and you can retry your AKS operation. If it returns any other value, the VNet might be in a failed or pending state that requires manual intervention. For more guidance, follow the troubleshooting steps in [Troubleshoot Azure Microsoft.Network failed provisioning state](/en-us/azure/networking/troubleshoot-failed-state).