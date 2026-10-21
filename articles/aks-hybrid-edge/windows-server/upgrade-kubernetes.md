---
layout: Conceptual
title: Upgrade the Kubernetes version of Azure Kubernetes Service workload clusters with Windows Admin Center | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/upgrade-kubernetes
breadcrumb_path: /azure/breadcrumb/azure-aks/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/200/azure-kubernetes-service/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn how to upgrade the Kubernetes version of AKS workload clusters in AKS on Windows Server.
ms.topic: upgrade-and-migration-article
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: windows-server
locale: en-us
document_id: cf9f67a9-8bbe-c341-fcb7-93660b3fdbb8
document_version_independent_id: 4d1d5b4e-3f9e-9e05-db61-03b9c33a5cd7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/upgrade-kubernetes.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/upgrade-kubernetes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/upgrade-kubernetes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: b975b5ae-d71a-d318-492c-dcdf3ed0b9a9
---

# Upgrade the Kubernetes version of Azure Kubernetes Service workload clusters with Windows Admin Center | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to upgrade an Azure Kubernetes Service (AKS) workload cluster to a new Kubernetes version in AKS on Windows Server. You should [update the AKS hosts](update-akshci-host-windows-admin-center) to a new version of the operating system before updating the Kubernetes version.

Note

You can also use PowerShell to [upgrade AKS workload clusters](upgrade).

We recommend updating an AKS workload cluster in AKS at least once every 60 days. New updates are available every 30 days. To avoid outages in workload availability, rolling updates are performed.

When you bring a new node with a newer build into the cluster, resources move from the old node to the new node, and when the resources are successfully moved, the old node is decommissioned and removed from the cluster.

## Upgrade the Kubernetes version

To upgrade the Kubernetes version of an AKS workload cluster with Windows Admin Center, follow these steps:

1. On the Windows Admin Center **Connections** page, connect to your management cluster.
2. Select **Azure Kubernetes Service** from the **Tools** list. When the tool loads, the **Overview** page is displayed.
3. Select the workload cluster you want to upgrade.
4. Select **Settings** under Kubernetes clusters to navigate to the **Settings** page.

    [![Screenshot showing the Settings option for Kubernetes clusters in Windows Admin Center.](../media/wac-kubernetes-upgrade/kubernetes-upgrade-settings.png)](../media/wac-kubernetes-upgrade/kubernetes-upgrade-settings.png#lightbox)
5. Select **Update now** to upgrade your workload cluster's Kubernetes version.

    [![Screenshot showing the Update Now button on the Host Settings page in Windows Admin Center.](../media/wac-kubernetes-upgrade/kubernetes-cluster-update-now.png)](../media/wac-kubernetes-upgrade/kubernetes-cluster-update-now.png#lightbox)

The following update scenarios are not supported in Windows Admin Center, but you can [use PowerShell](upgrade) to perform them:

- Windows Admin Center doesn't support skipping a patch update. You can only update a workload cluster to the next available patch version, even when a minor update is available.
- Windows Admin Center doesn't support upgrading the OS image of the Kubernetes cluster without updating the Kubernetes version.