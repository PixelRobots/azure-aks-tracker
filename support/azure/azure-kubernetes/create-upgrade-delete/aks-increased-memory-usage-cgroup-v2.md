---
layout: Conceptual
title: Increased memory usage reported in Kubernetes 1.25 or later versions - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/aks-increased-memory-usage-cgroup-v2
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
description: Resolve an increase in memory usage that's reported after you upgrade an Azure Kubernetes Service (AKS) cluster to Kubernetes 1.25.x.
ms.date: 2025-03-03T00:00:00.0000000Z
editor: momajed
ms.reviewer: aritraghosh, cssakscic, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 0e24be95-bfe1-5c82-242e-711a24a73cf4
document_version_independent_id: 0e24be95-bfe1-5c82-242e-711a24a73cf4
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/aks-increased-memory-usage-cgroup-v2.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/aks-increased-memory-usage-cgroup-v2
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/aks-increased-memory-usage-cgroup-v2.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: b94b11b0-f244-a6f7-f12a-68d5396ac9f2
---

# Increased memory usage reported in Kubernetes 1.25 or later versions - Azure | Microsoft Learn

## Summary

This article discusses how to resolve an *increased reported memory usage* issue in Microsoft Azure Kubernetes 1.25 or a later version.

## Symptoms

You experience one or more of the following symptoms:

- Pods report increased memory usage after you upgrade a Microsoft Azure Kubernetes Service (AKS) cluster to Kubernetes 1.25 or a later version.
- A node reports memory usage that's greater than in earlier versions of Kubernetes when you run the [kubectl top node](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-node-em-) command.
- Increased pod evictions and memory pressure occur within a node.

## Cause

This increase is caused by a change in memory accounting within version 2 of the Linux control group (`cgroup`) API. [Cgroup v2](https://kubernetes.io/docs/concepts/architecture/cgroups/) is now the default `cgroup` version for Kubernetes 1.25 on AKS.

Note

This issue is distinct from the memory saturation in nodes that's caused by applications or frameworks that aren't aware of `cgroup` v2. For more information, see [Memory saturation occurs in pods after cluster upgrade to Kubernetes 1.25](aks-memory-saturation-after-upgrade).

## Solution

- If you observe frequent memory pressure on the nodes, upgrade your subscription to increase the amount of memory that's available to your virtual machines (VMs).
- If you see a higher eviction rate on the pods, [use higher limits and requests for pods](/en-us/azure/aks/developer-best-practices-resource-management#define-pod-resource-requests-and-limits).
- `cgroup` v2 uses a different API than `cgroup` v1. If there are any applications that directly access the `cgroup` file system, update them to later versions that support `cgroup` v2. For example:

    - **Third-party monitoring and security agents**:

        Some monitoring and security agents depend on the `cgroup` file system. Update these agents to versions that support `cgroup` v2.
    - **Java applications**:

        Use versions that fully support `cgroup` v2:

        - OpenJDK/HotSpot: `jdk8u372`, `11.0.16`, `15`, and later versions.
        - IBM Semeru Runtimes: `8.0.382.0`, `11.0.20.0`, `17.0.8.0`, and later versions.
        - IBM Java: `8.0.8.6` and later versions.
    - **uber-go/automaxprocs**: If you're using the `uber-go/automaxprocs` package, ensure the version is `v1.5.1` or later.
- An alternative temporary solution is to revert the `cgroup` version on your nodes by using the DaemonSet. For more information, see [Revert to cgroup v1 DaemonSet](https://github.com/Azure/AKS/blob/master/examples/cgroups/revert-cgroup-v1.yaml).

Important

- Use the DaemonSet cautiously. Test it in a lower environment before applying to production to ensure compatibility and prevent disruptions.
- By default, the DaemonSet applies to all nodes in the cluster and reboots them to implement the `cgroup` change.
- To control how the DaemonSet is applied, configure a `nodeSelector` to target specific nodes.

Note

If you experience only an increase in memory use without any of the other symptoms that are mentioned in the "Symptoms" section, you don't have to take any action.

## Status

We're actively working with the Kubernetes community to resolve the underlying issue. Progress on this effort can be tracked at [Azure/AKS Issue #3443](https://github.com/kubernetes/kubernetes/issues/118916).

As part of the resolution, we plan to adjust the eviction thresholds or update [resource reservations](/en-us/azure/aks/concepts-clusters-workloads#resource-reservations), depending on the outcome of the fix.

## Reference

- [Node memory usage on cgroupv2 reported higher than cgroupv1](https://github.com/kubernetes/kubernetes/issues/118916) (GitHub issue)

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.