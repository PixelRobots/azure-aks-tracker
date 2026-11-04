---
layout: Conceptual
title: Error from server - error dialing backend - dial tcp message in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/error-from-server-error-dialing-backend-dial-tcp
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
description: Fix Error from server - error dialing backend - dial tcp message in AKS to restore kubectl logs, exec, and top access. Use this guide to quickly find and resolve the network block.
ms.date: 2026-11-02T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, v-leedennis, pihe, mariusbutuc, kaushika
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Connectivity
ai-usage: ai-assisted
locale: en-us
document_id: 03b2de19-c6a7-5ed3-f0ec-115a1abbcd28
document_version_independent_id: 03b2de19-c6a7-5ed3-f0ec-115a1abbcd28
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/error-from-server-error-dialing-backend-dial-tcp.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/error-from-server-error-dialing-backend-dial-tcp
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/error-from-server-error-dialing-backend-dial-tcp.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
platformId: 33b5fb87-f12c-ad26-b258-bca4f1288003
---

# Error from server - error dialing backend - dial tcp message in AKS - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot the "Error from server: error dialing backend: dial tcp" error in Azure Kubernetes Service (AKS) so you can restore `kubectl logs`, `exec`, and `top` access. The error indicates that the API server can't connect to an upstream component, like a Kubernetes service or kubelet, that certain operations require.

## Symptoms

You receive an "Error from server: error dialing backend: dial tcp" error message when you take one of the following actions:

- Use any of the `kubectl``logs`, `exec`, `attach`, `top`, or `port-forward` commands.
- Use third-party Kubernetes client tools to achieve the same functionality as the commands in the previous list item.

### Why the dial tcp error occurs

The Kubernetes API server has to forward API requests to an upstream component for several use cases. This error occurs if the API server can't establish a Transmission Control Protocol (TCP) connection to the upstream component. Examples of such upstream components include Kubernetes services that are inside the cluster and kubelet.

If the issue persists, a network blockage is likely the cause. To identify the responsible network configuration, determine the scope of the problem.

### Determine whether all `kubectl` subcommands fail

Try to run at least the `kubectl exec`, `kubectl logs <podname>`, and `kubectl top pods` commands. Use the following guidance to interpret the results.

- If only `kubectl logs <podname>` or `kubectl exec` fails, check whether the issue occurs by having pods on different nodes.
- If only `kubectl top pods` fails, check whether the issue occurs for pods on all nodes or only for pods on one node.

## Cause 1: Kubelet port 10250 is blocked

Pod-specific access issues, such as those that occur when you run `kubectl logs` and `kubectl exec`, happen if the API server can't reach the node on port 10250 to access the Kubelet API. A network security group (NSG) or firewall might block the connection.

To resolve the issue, check whether the NSG on the node subnet includes an inbound rule that blocks TCP port 10250.

## Cause 2: Specific service failure

Kubernetes accesses `svc/metrics-server` under the `kube-system` namespace to run `kubectl top` commands. In other scenarios, such as [admission webhooks](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/), the API server can reach other services. The error message can vary depending on the service failure pattern.

To troubleshoot the issue, check the error message to identify which service is affected. Review the status of the related pods, services, and endpoints.

## Cause 3: Konnectivity or tunnel failure

When you don't enable [API Server VNet Integration](/en-us/azure/aks/api-server-vnet-integration), AKS deploys a tunnel solution that proxies API server requests to in-cluster networking locations. Most AKS clusters use the Konnectivity solution. Konnectivity doesn't require you to open special ports on the API server. For more information, see [AKS required network rules](/en-us/azure/aks/outbound-rules-control-egress#azure-global-required-network-rules).

To resolve the issue, check whether the `konnectivity-agent` in the `kube-system` namespace is running and its containers are in a ready state. Try deleting the pods to see whether the connection recovers after the new pods are ready.

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.