---
layout: Conceptual
title: Memory saturation occurs after upgrade to Kubernetes 1.25 - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/aks-memory-saturation-after-upgrade
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
description: Resolve pod failures caused by memory saturation and out-of-memory errors after you upgrade an Azure Kubernetes Service (AKS) cluster to Kubernetes 1.25.x.
ms.date: 2025-05-06T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: aritraghosh, cssakscic, v-leedennis, momajed
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 683912a0-a492-bf97-f4ec-b4cf5bdf1d77
document_version_independent_id: 683912a0-a492-bf97-f4ec-b4cf5bdf1d77
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/aks-memory-saturation-after-upgrade.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/aks-memory-saturation-after-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/aks-memory-saturation-after-upgrade.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/7696cda6-0510-47f6-8302-71bb5d2e28cf
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/69c76c32-967e-4c65-b89a-74cc527db725
platformId: c4449281-323b-5cf5-30b4-e5d40b76599d
---

# Memory saturation occurs after upgrade to Kubernetes 1.25 - Azure | Microsoft Learn

## Summary

This article discusses how to fix pods that stop working because of memory saturation or out-of-memory (OOM) errors that occur after you upgrade a Microsoft Azure Kubernetes Service (AKS) cluster to Kubernetes 1.25.*x*.

## Symptoms

One or more of the following issues occur:

- Memory pressure on nodes
- Increased memory usage for apps when compared to their memory usage before the upgrade
- CPU throttling on nodes
- Pod failure because of OOM errors

Performance degradation can occur in apps that run in the following environments:

- Java Runtime Environment (JRE) (for [JRE versions that are earlier than version 11.0.18 or version 1.8.0 372](https://bugs.java.com/bugdatabase/view_bug?bug_id=8230305))
- .NET versions that are earlier than version 5.0
- [Node.js](https://github.com/nodejs/node/issues/47259)

Note

This list of environments in which performance degradation can occur isn't a comprehensive list. There might be other environments that experience memory saturation or OOM issues.

## Solution

Note

If you only experience increased memory usage and no other symptoms that are mentioned in the Symptoms section, no action is needed.

Beginning in the release of Kubernetes 1.25, the [cgroup version 2 API](https://kubernetes.io/blog/2022/08/31/cgroupv2-ga-1-25/) has reached general availability (GA). AKS now uses Ubuntu Linux version 22.04. By default, version 22.04 uses cgroup version 2 API. To make sure the cgroup version 2 API is available for use in other environments to prevent the memory saturation issue, follow this guidance:

- If you run Java applications, [upgrade to a Java version that supports cgroup version 2](https://kubernetes.io/blog/2022/08/31/cgroupv2-ga-1-25/#migrate-to-cgroup-v2) and follow the guidance in [Containerize your Java applications](/en-us/azure/developer/java/containers/overview). You might be able to update the base image in certain versions in which the fix has been backported. Use a version or framework that natively supports cgroup version 2. For Azure customers, Microsoft officially supports [Eclipse Temurin](https://adoptium.net/) binaries (Java 8) and [Microsoft Build of OpenJDK](https://www.microsoft.com/openjdk) binaries (Java 11+).
- Similarly, if you're using .NET, upgrade to [.NET version 5.0](https://devblogs.microsoft.com/dotnet/announcing-net-5-0/#containers) or a later version.
- If you see a higher eviction rate on the pods, [use higher limits and requests for the pods](/en-us/azure/aks/developer-best-practices-resource-management#define-pod-resource-requests-and-limits).
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

    - Use the DaemonSet cautiously. Test it in a lower environment before applying to production to ensure compatibility and avoid disruptions.
    - By default, the DaemonSet applies to all nodes in the cluster and reboots them to implement the `cgroup` change.
    - To control how the DaemonSet is applied, configure a `nodeSelector` to target specific nodes.

## Status

Microsoft is working with the Kubernetes community to resolve the issue. Track progress at [Azure/AKS Issue #3443](https://github.com/kubernetes/kubernetes/issues/118916).

As part of the resolution, the plan is to adjust the eviction thresholds or update [resource reservations](/en-us/azure/aks/concepts-clusters-workloads#resource-reservations), depending on the outcome of the fix.

## Reference

- [Node memory usage on cgroupv2 reported higher than cgroupv1](https://github.com/kubernetes/kubernetes/issues/118916) (GitHub issue)

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.