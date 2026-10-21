---
layout: Conceptual
title: Known issues - custom kubelet configuration on AKS Windows nodes - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/known-issues-custom-kubelet-configuration
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
description: Learn about known issues that affect custom kubelet configuration on Windows nodes in an Azure Kubernetes Service (AKS) cluster.
ms.date: 2023-04-28T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: allyford, abelch, jpalma, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: d58e6c8a-3785-bb2b-9fdd-8ff218dd85e4
document_version_independent_id: d58e6c8a-3785-bb2b-9fdd-8ff218dd85e4
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/known-issues-custom-kubelet-configuration.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/known-issues-custom-kubelet-configuration
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/known-issues-custom-kubelet-configuration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 70c5ceb6-458f-b4ca-d7b7-363153079d18
---

# Known issues - custom kubelet configuration on AKS Windows nodes - Azure | Microsoft Learn

## Summary

This article discusses known issues that affect custom kubelet configurations on Microsoft Windows nodes in the Azure Kubernetes Service (AKS). For more information about this feature, see [Customize node configuration for AKS node pools](/en-us/azure/aks/custom-node-configuration).

## Log sizes exceed the specified maximum during aggressive log writing

On a Windows virtual machine (VM), log sizes grow beyond the value of the `container-log-max-size` setting if a container is writing to the log aggressively. During heavy log writing periods, the log file grows too quickly for [log rotation](https://kubernetes.io/docs/concepts/cluster-administration/logging/#log-rotation) to occur before the `container-log-max-size` setting limit is exceeded.

If several pods are aggressively writing to the log, the log size can grow to dozens of gibibytes (GiBs) before the log is rotated (compressed and replaced), even if the maximum size is only in the dozens of mebibytes (MiBs).

For more information, see Kubernetes [GitHub issue 110630](https://github.com/kubernetes/kubernetes/issues/110630), "Kubelet does not respect `container-log-max-size` on time, during heavy log writes from container."

#### Affected versions

The excessive log size issue applies to all versions of Kubernetes.

## Kubelet log file compression fails

On a Windows VM, when the kubelet tries to compress a log file into a `.gz` archive format, it stops responding during the final step of the process (trying to rename the archive before it closes the file).

For more information, see Kubernetes [GitHub issue 111548](https://github.com/kubernetes/kubernetes/issues/111548), "Kubelet log compression fails on Windows."

#### Affected versions

The kubelet log file compression issue applies to all versions of Kubernetes that are older than version `1.23`. It applies also to certain early versions of Kubernetes `1.23` and `1.24`, as shown in the following table. The log file compression issue is fixed for Kubernetes version `1.25.0` (in Kubernetes [GitHub pull request 111549](https://github.com/kubernetes/kubernetes/pull/111549)) and all subsequent versions of Kubernetes.

| Kubernetes*x*.*y*version | Versions that the known issue applies to | GitHub fix pull request number on Kubernetes |
| --- | --- | --- |
| `1.24` | All versions before `1.24.7` | [112482](https://github.com/kubernetes/kubernetes/pull/112482) |
| `1.23` | All versions before `1.23.13` | [112483](https://github.com/kubernetes/kubernetes/pull/112483) |

For more information, see the [January 29, 2023 release](https://github.com/Azure/AKS/releases/tag/2023-01-29) of the AKS changelog.

## Custom OS configurations fail

#### Symptoms

A custom OS configuration doesn't get applied.

#### Cause

This issue occurs if you try to apply the custom OS configuration on a Windows node pool. Currently, OS configurations aren't supported on Windows node pools. These configurations work only on Linux node pools.

#### Workaround

Apply the custom OS configuration at the cluster level or node pool level for a Linux node pool. To check whether the custom node configuration is in use, see [Confirm settings have been applied](/en-us/azure/aks/custom-node-configuration#confirm-settings-have-been-applied).