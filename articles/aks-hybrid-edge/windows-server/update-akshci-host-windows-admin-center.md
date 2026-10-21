---
layout: Conceptual
title: Update Azure Kubernetes Service host in AKS on Windows Server using Windows Admin Center | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/update-akshci-host-windows-admin-center
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
description: Learn about using Windows Admin Center to update the Azure Kubernetes Service host in AKS on Windows Server.
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: fasttrack-edit, windows-server
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: mikek
author: davidsmatlak
locale: en-us
document_id: 233d4e02-112d-a1fe-3c59-fb8f479da9c6
document_version_independent_id: 003dfc64-e005-1420-962d-bf06a1a21fe3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/update-akshci-host-windows-admin-center.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/update-akshci-host-windows-admin-center
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/update-akshci-host-windows-admin-center.md
platformId: 03efa87a-0c00-67ed-ba12-a1aa7f77f44c
---

# Update Azure Kubernetes Service host in AKS on Windows Server using Windows Admin Center | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to upgrade the Azure Kubernetes Service (AKS) host core system to the latest version in AKS on Windows Server.

## Overview of AKS host updates

Several types of updates can be made independently or in certain supported combinations:

- Update the AKS core system to the latest version.
- Update an AKS workload cluster to a new Kubernetes version.
- Update the container hosts of AKS workload clusters to a newer version of the operating system.
- Combined update of the operating system and Kubernetes version of AKS workload clusters.

To avoid outages and loss of AKS availability, rolling updates are performed.

When you bring a new node with a newer build into the cluster, resources move from the old node to the new node, and when the resources are successfully moved, the old node is decommissioned and removed from the cluster.

We recommend that you update workload clusters immediately after updating the AKS host to prevent running unsupported container host OS versions or Kubernetes versions in your workload clusters. If your workload clusters are on an old Kubernetes version, they are still supported, but you can't scale your cluster.

Note

Microsoft recommends upgrading your AKS clusters within 30 days of a new release. If you don't update within this window, you have up to 90 days from your last upgrade before internal certificates and tokens expire. Once the certificates and tokens expired the cluster is still functional; however, you must call Microsoft Support to upgrade. When you reboot the cluster after the 90-day period, it remains in a non-functional state. For more information about internal certificates and tokens, see the [overview of certificate management](certificates-overview).

## Update the AKS host

To update the AKS host using Windows Admin Center, follow these steps:

1. Update your Azure Kubernetes Service extension by navigating to **Settings** &gt; **Extensions** &gt; **Installed Extensions**, and then click **Update**. The latest available Azure Kubernetes Service extension version is 1.82.0. You don't need to complete this step if you enabled auto-update for your extensions. However, make sure that you installed version 1.82.0 of the AKS extension before proceeding to the next step.
2. On the **Host settings** page, select **Update AksHci PowerShell module to version x.x.x** under **Updates available**, and then click **Update now**.

    [![Screenshot showing the available AksHci PowerShell updates in AKS host settings.](../media/wac-upgrade/available-module-version.png)](../media/wac-upgrade/available-module-version.png#lightbox)
3. You can now go back to the Windows Admin Center **Connections** page and connect to your AKS cluster.
4. Select the **Azure Kubernetes Service** tool from the **Tools** list. When the tool loads, the **Overview** page is displayed.
5. Select **Updates** from the page list on the left side of the tool, and then select **Update now** to upgrade your AKS host.

Note

- The update might stall if you navigate away from the update window while it's in progress.
- During the update process, if you receive an error that says **Could not install updates**, the current deployment cannot be updated to the latest version. To work around this error, run `Get-AksHciUpdates` in PowerShell and review the recommendations provided in the output.