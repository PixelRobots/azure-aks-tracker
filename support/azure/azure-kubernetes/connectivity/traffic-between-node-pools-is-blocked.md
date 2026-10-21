---
layout: Conceptual
title: Traffic between node pools is blocked by a custom NSG - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/traffic-between-node-pools-is-blocked
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
description: Resolve blocked traffic between node pools by a custom network security group (NSG) within an Azure Kubernetes Service (AKS) cluster.
ms.date: 2024-09-23T00:00:00.0000000Z
ms.reviewer: chiragpa, rissing, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity
locale: en-us
document_id: d0083f8c-3246-4f2c-0d96-9258561bf20c
document_version_independent_id: d0083f8c-3246-4f2c-0d96-9258561bf20c
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/traffic-between-node-pools-is-blocked.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/traffic-between-node-pools-is-blocked
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/traffic-between-node-pools-is-blocked.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 008cdbe1-e701-5447-5636-f46a9298594e
---

# Traffic between node pools is blocked by a custom NSG - Azure | Microsoft Learn

## Summary

This article discusses how to resolve a scenario in which a custom network security group (NSG) blocks traffic between node pools in a Microsoft Azure Kubernetes Service (AKS) cluster.

## Symptoms

The Domain Name System (DNS) resolution from pods of the User node pool fails.

## Background

In scenarios that involve multiple node pools, the pods in the `kube-system` namespace can be put on one node pool (the System node pool) while the application pods are put on a different node pool (the User node pool). In some scenarios, pods that communicate with one another can be in different node pools.

AKS lets customers have [node pools in different subnets](/en-us/azure/aks/use-multiple-node-pools#add-a-node-pool-with-a-unique-subnet). This feature means that customers can also associate different NSGs with each node pool's subnet.

## Cause 1: the NSG of a node pool blocks inbound traffic

Inbound access on the NSG of a node pool blocks traffic. For example, a custom NSG on the System node pool (that hosts the core DNS pods) blocks inbound traffic on User Datagram Protocol (UDP) port 53 from the subnet of the User node pool.

[![Screenshot of a custom NSG blocking inbound UDP 53 traffic between AKS user and system node pools.](media/traffic-between-node-pools-is-blocked/inbound-traffic-blocked.svg)](media/traffic-between-node-pools-is-blocked/inbound-traffic-blocked.svg#lightbox)

### Solution 1: configure the custom NSG to allow traffic between the node pools

Make sure that your custom NSG allows the required traffic between the node pools, specifically on UDP port 53. AKS won't update the custom NSG that's associated with subnets.

## Cause 2: outbound access on the NSG of a node pool blocks traffic

The NSG on another node pool blocks outbound access to the pod. For example, a custom NSG on the User node pool blocks outbound traffic on UDP port 53 to the System node pool.

[![Screenshot of a custom NSG blocking outbound UDP 53 traffic from an AKS user node pool to a system node pool.](media/traffic-between-node-pools-is-blocked/outbound-traffic-blocked.svg)](media/traffic-between-node-pools-is-blocked/outbound-traffic-blocked.svg#lightbox)

### Solution 2: configure the custom NSG to allow traffic between the node pools

See Solution 1: Configure the custom NSG to allow traffic between the node pools.

## Cause 3: TCP port 10250 is blocked

Another common scenario is that Transmission Control Protocol (TCP) port 10250 is blocked between the node pools.

In this situation, a user might receive an error message that resembles the following text:

```console
$ kubectl logs nginx-57cdfd6dd9-xb7hk
Error from server: Get https://<node>:10250/containerLogs/default/nginx-57cdfd6dd9-xb7hk/nginx: net/http: TLS handshake timeout
```

If the communication on TCP port 10250 is blocked, the connection to the Kubelet will be affected, and the logs won't be fetched.

### Solution 3: check for NSG rules that block TCP port 10250

Check whether any NSG rules block node-to-node communication on TCP port 10250.