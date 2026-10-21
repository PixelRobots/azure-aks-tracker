---
layout: Conceptual
title: TCP 10250 I/O timeout errors when connecting to a node's Kubelet for log retrieval - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/tcp-timeouts-dial-tcp-nodeip-10250-io-timeout
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
description: Fix TCP 10250 i/o timeout errors when running kubectl logs in AKS. Follow these troubleshooting steps to restore log access quickly.
ms.date: 2024-09-19T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, v-leedennis
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Connectivity, innovation-engine
locale: en-us
document_id: 610dc140-ec2b-5414-680e-c98bf7959f34
document_version_independent_id: 610dc140-ec2b-5414-680e-c98bf7959f34
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/tcp-timeouts-dial-tcp-nodeip-10250-io-timeout.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/tcp-timeouts-dial-tcp-nodeip-10250-io-timeout
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/tcp-timeouts-dial-tcp-nodeip-10250-io-timeout.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 94242453-495e-76fa-f7a4-ecefc24f358b
---

# TCP 10250 I/O timeout errors when connecting to a node's Kubelet for log retrieval - Azure | Microsoft Learn

## Summary

A TCP 10250 i/o timeout in kubectl logs is often caused by blocked internal traffic between cluster nodes. Use this article to verify whether [network security groups](/en-us/azure/aks/concepts-security#azure-network-security-groups) (NSGs) are blocking required node subnet traffic and restore log retrieval.

## Connect to the AKS cluster

First, connect to your Azure Kubernetes Service (AKS) cluster by running the following command:

```bash
export RESOURCE_GROUP=<your-resource-group>
export CLUSTER_NAME=<your-cluster-name>

az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

## Symptoms

Tunnel functionalities, such as `kubectl logs` and code execution, work only for pods that are hosted on nodes on which tunnel service pods are deployed. Pods on other nodes that have no tunnel service pods cannot reach to the tunnel. When viewing the logs of these pods, you receive the following error message:

```bash
kubectl logs $POD_NAME
```

Results:

```output
Error from server: Get "https://aks-agentpool-xxxxxxxxx-vmssxxxxxxxxx:10250/containerLogs/vsm-mba-prod/mba-api-app-xxxxxxxxxx/technosvc": dial tcp <IP-Address>:10250: i/o timeout
```

## Solution

To resolve this issue, allow traffic on port 10250 as described in this [article](tunnel-connectivity-issues).