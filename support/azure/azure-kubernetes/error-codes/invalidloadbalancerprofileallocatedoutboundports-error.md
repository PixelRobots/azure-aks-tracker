---
layout: Conceptual
title: InvalidLoadBalancerProfileAllocatedOutboundPorts Error Code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/invalidloadbalancerprofileallocatedoutboundports-error
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
description: Learn how to fix the InvalidLoadBalancerProfileAllocatedOutboundPorts error during AKS cluster create or update operations. Use the steps now.
ms.date: 2024-05-06T00:00:00.0000000Z
ms.reviewer: jotavar, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 5edc1daf-3097-ccd7-8784-35ec5780eda4
document_version_independent_id: 5edc1daf-3097-ccd7-8784-35ec5780eda4
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/invalidloadbalancerprofileallocatedoutboundports-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/invalidloadbalancerprofileallocatedoutboundports-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/invalidloadbalancerprofileallocatedoutboundports-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: 68d1d9e0-73cd-759f-b17f-22150f498240
---

# InvalidLoadBalancerProfileAllocatedOutboundPorts Error Code - Azure | Microsoft Learn

## Summary

Learn how to identify and resolve the "InvalidLoadBalancerProfileAllocatedOutboundPorts" error code so you can create or update an AKS cluster successfully.

## Prerequisites

[Azure CLI](/en-us/cli/azure/install-azure-cli), version 2.53.0 or a later version. To find your installed version, run the `az --version` command.

## Symptoms

An AKS cluster create or update operation fails and returns the following error message:

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

1. Use the following formula to check if the desired configuration is feasible:

    ```code
    64,000 ports per IP / <outbound ports per node> * <number of outbound IPs> = <maximum number of nodes in the cluster>
    ```

    Note

    When performing this check, make sure you consider node surges that happen during cluster upgrades and other operations. AKS defaults to one buffer node for upgrade operations, but this number can be modified using the [maxSurge](/en-us/azure/aks/upgrade-aks-cluster#customize-node-surge-upgrade) parameter.
2. Change the cluster's node count, the number of outbound frontend IP addresses, or the number of SNAT ports per node.

    For more information about how to configure the allocated outbound ports and examples and calculations of the number of ports you might need, see [Configure the allocated outbound ports](/en-us/azure/aks/load-balancer-standard#configure-the-allocated-outbound-ports).

## Reference

[Use Source Network Address Translation (SNAT) for outbound connections](/en-us/azure/load-balancer/load-balancer-outbound-connections)