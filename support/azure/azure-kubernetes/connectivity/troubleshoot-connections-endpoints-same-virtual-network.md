---
layout: Conceptual
title: Troubleshoot connections to endpoints in the same virtual network - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-connections-endpoints-same-virtual-network
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
description: Troubleshoot connections to endpoints in the same virtual network from an AKS cluster. Use this guide to quickly identify egress blockers and restore connectivity.
ms.date: 2024-10-23T00:00:00.0000000Z
ms.reviewer: chiragpa, rissing, v-leedennis, andbar
editor: v-jsitser
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity
locale: en-us
document_id: 80077a47-097f-11a9-2011-39958c2903c9
document_version_independent_id: 80077a47-097f-11a9-2011-39958c2903c9
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/troubleshoot-connections-endpoints-same-virtual-network.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/troubleshoot-connections-endpoints-same-virtual-network
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/troubleshoot-connections-endpoints-same-virtual-network.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 9f5887ba-86f0-e28e-0e73-829fd5fd9cd5
---

# Troubleshoot connections to endpoints in the same virtual network - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot connections to endpoints in the same virtual network from an Azure Kubernetes Service (AKS) cluster so you can identify and fix outbound connectivity issues faster.

## Troubleshooting checklist

The troubleshooting checklist covers connections to the following items:

- Virtual machines (VMs) or endpoints in the same subnet or a different subnet
- VMs or endpoints in a peered virtual network
- Private endpoints

### Step 1: Do basic troubleshooting

Make sure that you can connect to endpoints. For instructions, see [Basic troubleshooting of outbound AKS cluster connections](basic-troubleshooting-outbound-connections).

### Step 2: Check for private endpoints

If the connection goes through a private endpoint, follow the instructions in [Troubleshoot Azure Private Endpoint connectivity problems](/en-us/azure/private-link/troubleshoot-private-endpoint-connectivity).

### Step 3: Check for virtual network peering

If the connection uses virtual network peering, follow the instructions in [Troubleshoot a connectivity issue between two peered virtual networks](/en-us/azure/virtual-network/virtual-network-troubleshoot-peering-issues#troubleshoot-a-connectivity-issue-between-two-peered-virtual-networks).

### Step 4: Check whether the AKS network security group blocks traffic in the outbound scenario

To use AKS to check the network security groups (NSGs) and their associated rules, follow these steps:

1. In the [Azure portal](https://portal.azure.com), search for and select **Virtual machine scale sets**.
2. In the list of scale set instances, select the instance that you're using.
3. In the menu pane of your scale set instance, select **Networking**.

    The **Networking** page for the scale set instance appears. In the **Outbound port rules** tab, two sets of rules are displayed. These rule sets are based on the two NSGs that act on the scale set instance. The following table describes the rule sets.

    | NSG rule level | NSG rule name | Attached to | Notes |
    | --- | --- | --- | --- |
    | Subnet | *&lt;my-aks-nsg&gt;* | The *&lt;my-aks-subnet&gt;* subnet | This is a common arrangement if the AKS cluster uses a custom virtual network and a custom subnet. |
    | Network adapter | **aks-agentpool-***&lt;agentpool-number&gt;***-nsg** | The **aks-agentpool-***&lt;vm-scale-set-number&gt;***-vmss** network interface | This NSG is applied by the AKS cluster and managed by AKS. |

By default, the egress traffic is allowed on the NSGs. However, in some scenarios, the custom NSG that's associated with the AKS subnet might have a **Deny** rule that has a more urgent priority. This rule stops traffic to some endpoints.

AKS doesn't modify the egress rules in an NSG. If AKS uses a custom NSG, verify that it allows egress traffic for the endpoints on the correct port and protocol. To make sure that the AKS cluster functions as expected, verify that the egress for custom NSGs allows [Required outbound network rules for AKS clusters](/en-us/azure/aks/outbound-rules-control-egress).

Custom NSGs can directly affect the egress traffic by blocking the outbound rules. They can also affect egress traffic indirectly. For more information, see [A custom network security group blocks traffic](custom-nsg-blocks-traffic).