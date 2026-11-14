---
layout: Conceptual
title: Resolve InvalidLoadBalancerProfileAllocatedOutboundPorts error code in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-invalidloadbalancerprofileallocatedoutboundports
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
description: Learn how to fix the InvalidLoadBalancerProfileAllocatedOutboundPorts error when you create or update an AKS cluster. Follow these steps to resolve it.
ms.date: 2026-11-13T00:00:00.0000000Z
ms.reviewer: jotavar, v-weizhu, kaushika
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: e86c7922-1ffd-f29c-5d79-ec682a0edea4
document_version_independent_id: e86c7922-1ffd-f29c-5d79-ec682a0edea4
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/error-code-invalidloadbalancerprofileallocatedoutboundports.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/error-code-invalidloadbalancerprofileallocatedoutboundports
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/error-code-invalidloadbalancerprofileallocatedoutboundports.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: f718ecb4-d466-cacf-1472-7b47b7826727
---

# Resolve InvalidLoadBalancerProfileAllocatedOutboundPorts error code in AKS - Azure | Microsoft Learn

## Summary

This article helps you identify and resolve the "InvalidLoadBalancerProfileAllocatedOutboundPorts" error that occurs when you create or update an Azure Kubernetes Service (AKS) cluster. Adjust the node count, outbound IP addresses, or SNAT ports per node to restore a feasible configuration.

## Prerequisites

Ensure you have [Azure CLI](/en-us/cli/azure/install-azure-cli), version 2.53.0 or a later version installed. To find your installed version, run the `az --version` command.

## Symptoms

An AKS cluster create or update operation fails and returns the following error message.

> 
> Code: InvalidLoadBalancerProfileAllocatedOutboundPorts Message: Load balancer profile allocated ports 8000 is not in an allowable range given the number of nodes and IPs provisioned. Total node count 9 requires 72000 ports but only 64000 ports are available given 1 outbound public IPs. Refer to `https://aka.ms/aks/slb-ports` for more details.

## Cause

In clusters with outbound type `LoadBalancer`, the traffic originating from cluster nodes (including traffic from applications running in pods) egresses via the AKS-managed load balancer, which relies on Source Network Address Translation (SNAT) ports to establish these outbound connections.

By default, each cluster is assigned one outbound frontend IP address that allows for a total of 64,000 SNAT ports, and each worker node in the cluster is allocated a share of these ports. For example, if a cluster has 50 nodes or fewer, each worker node is allocated 1,024 ports. In some scenarios where applications running in a cluster require establishing large numbers of outbound connections, the default number of available SNAT ports may be insufficient, which leads to SNAT port exhaustion.

To solve the SNAT port exhaustion issue, use one or both of the following methods:

- Change the number of outbound frontend IP addresses. Each IP address provides an additional 64,000 SNAT ports.
- Change the number of SNAT ports assigned to each worker node.

The "InvalidLoadBalancerProfileAllocatedOutboundPorts" error occurs when the specified node count, the number of outbound frontend IP addresses, and the number of allocated ports per node don't constitute a feasible configuration.

## Solution

To resolve the "InvalidLoadBalancerProfileAllocatedOutboundPorts" error, follow these steps:

1. Use the following formula to check if the desired configuration is feasible.

    ```code
    64,000 ports per IP / <outbound ports per node> * <number of outbound IPs> = <maximum number of nodes in the cluster>
    ```

    Note

    When performing this check, consider node surges that happen during cluster upgrades and other operations. AKS defaults to one buffer node for upgrade operations, but you can modify this number by using the [maxSurge](/en-us/azure/aks/upgrade-aks-cluster#customize-node-surge-upgrade) parameter.
2. Change the cluster's node count, the number of outbound frontend IP addresses, or the number of SNAT ports per node.

For more information about how to configure the allocated outbound ports and examples and calculations of the number of ports you might need, see [Configure the allocated outbound ports](/en-us/azure/aks/load-balancer-standard#configure-the-allocated-outbound-ports).

## References

- [Use Source Network Address Translation (SNAT) for outbound connections](/en-us/azure/load-balancer/load-balancer-outbound-connections)