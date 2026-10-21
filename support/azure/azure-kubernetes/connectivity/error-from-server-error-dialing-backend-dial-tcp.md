---
layout: Conceptual
title: Error from server - error dialing backend - dial tcp message - Azure | Microsoft Learn
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
ms.date: 2025-03-05T00:00:00.0000000Z
ms.reviewer: chiragpa, nickoman, v-leedennis, pihe, mariusbutuc
ms.service: azure-kubernetes-service
keywords: 
ms.custom: sap:Connectivity
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
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/a3955c7b-f5ee-420d-aff5-d7119738f38b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/b31948f4-2f38-404b-ac93-c3c8c5b3ae33
platformId: 33b5fb87-f12c-ad26-b258-bca4f1288003
---

# Error from server - error dialing backend - dial tcp message - Azure | Microsoft Learn

## Summary

This article explains how to troubleshoot the "Error from server: error dialing backend: dial tcp" error message that you might receive when you use `kubectl` commands or other tools to connect to the API server. This error message indicates that the API server is having trouble connecting to an upstream component, like a Kubernetes service or kubelet, which is required for certain operations.

## Symptoms

You receive an "Error from server: error dialing backend: dial tcp" error message when you take one of the following actions:

- Use any of the `kubectl``logs`, `exec`, `attach`, `top`, or `port-forward` commands.
- Use third-party Kubernetes client tools to achieve the same functionality as the commands in the previous list item.

### Why the error occurs

The Kubernetes API server has to forward API requests to an upstream component for several use cases. This error occurs if the API server can't establish a Transmission Control Protocol (TCP) connection to the upstream component. Example of such upstream components includes kubernetes services that are inside the cluster and kubelet.

If the issue persists, a network blockage is likely the cause. To identify the responsible network configuration, first determine the scope of the problem.

### Narrowing down: Are all `kubectl` subcommands failing?

Try to run at least the `kubectl exec`, `kubectl logs <podname>`, and `kubectl top pods` commands.

If only `kubectl logs <podname>` or `kubectl exec` fails, check whether the issue occurs by having pods on different nodes.

If only `kubectl top pods` fails, check whether the issue occurs for pods on all nodes or only for pods on one node.

## Cause 1: kubelet port (node:10250) blocked

Pod-specific access issues, such as those that are experienced by running `kubectl logs` and `kubectl exec`, occur if the API server can't reach the node on port 10250 to access the Kubelet API. These issues can be caused by a connection that's blocked by a Network Security Group (NSG) or firewall.

To resolve the issue, check whether the NSG on the node subnet includes an inbound rule that might block TCP port 10250.

## Cause 2: specific service failure

Kubernetes accesses `svc/metrics-server` under the `kube-system` namespace for running kubectl top commands. There are other scenarios, such as [admission webhooks](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/), in which the API server can also reach other services. It's important to note that, depending on the service failure pattern, the error message can vary.

To troubleshoot the issue, check the error message to identify which service is affected and review the status of the related pods, services, and endpoints.

## Cause 3: Konnectivity or tunnel failure

When [API Server VNet Integration](/en-us/azure/aks/api-server-vnet-integration) isn't enabled, AKS deploys a tunnel solution that proxies API server requests to in-cluster networking locations. Most AKS clusters use the Konnectivity solution. Konnectivity doesn't require that you open special ports on the API server. For more information, see [AKS required network rules](/en-us/azure/aks/outbound-rules-control-egress#azure-global-required-network-rules).

To resolve the issue, check whether the `konnectivity-agent` in the `kube-system` namespace is running and its containers are in a ready state. Try to delete the pods to see whether the connection recovers after the new pods are ready.

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.