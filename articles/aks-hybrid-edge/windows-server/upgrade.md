---
layout: Conceptual
title: Upgrade Kubernetes version of Azure Kubernetes Service (AKS) workload clusters in AKS on Windows Server using PowerShell | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/upgrade
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
description: Learn how to upgrade the Kubernetes version of Azure Kubernetes Service (AKS) workload clusters in AKS on Windows Server using PowerShell.
ms.topic: upgrade-and-migration-article
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.custom: windows-server
locale: en-us
document_id: 5c85470a-81bc-64e6-b3cb-8ee5850a4c0a
document_version_independent_id: 7c6ae6cb-ac14-3b30-ad4c-f07a85063097
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/upgrade.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/upgrade.md
platformId: 0b83ac91-c543-e9b2-fe9c-196e888c8063
---

# Upgrade Kubernetes version of Azure Kubernetes Service (AKS) workload clusters in AKS on Windows Server using PowerShell | Microsoft Learn

> 
> Applies to: AKS on Windows Server

Two types of updates are available for an Azure Kubernetes Service (AKS) workload cluster in AKS on Windows Server:

- Upgrade the Kubernetes version of an AKS cluster.
- Upgrade the operating system version of an AKS cluster without updating the Kubernetes version.

Note

You can also use Windows Admin Center to [upgrade AKS workload clusters](upgrade-kubernetes).

We recommend updating an AKS workload cluster at least once every 60 days. New Kubernetes version updates are available every 30 days. To avoid outages in workload availability, rolling updates are performed. When you bring a new node with a newer build into the cluster, resources move from the old node to the new node. When the resources are successfully moved, the old node is decommissioned and removed from the cluster.

Important

Updating the Azure Kubernetes Service on the AKS host is the first step in any update flow and must be initiated before running [`Update-AksHciCluster`](/en-us/azure/aks/aksarc/reference/ps/update-akshcicluster). For information about updating the AKS host, see [Update the AKS host](update-akshci-host-powershell).

## Get available Kubernetes versions

Use the `Get-AksHciKubernetesVersion` command to check for supported Kubernetes versions:

```powershell
Get-AksHciKubernetesVersion
```

Sample output:

```output
OrchestratorType OrchestratorVersion OS      IsPreview
---------------- ------------------- --      ---------
Kubernetes       v1.18.14            Linux       False
Kubernetes       v1.18.17            Linux       False
Kubernetes       v1.19.7             Linux       False
Kubernetes       v1.19.9             Linux       False
Kubernetes       v1.20.2             Linux       False
Kubernetes       v1.20.5             Linux       False
Kubernetes       v1.18.14            Windows     False
Kubernetes       v1.18.17            Windows     False
Kubernetes       v1.19.7             Windows     False
Kubernetes       v1.19.9             Windows     False
Kubernetes       v1.20.2             Windows     False
Kubernetes       v1.20.5             Windows     False
```

## Get available workload cluster updates

The following example assumes that the workload cluster `myCluster` is currently on Kubernetes version 1.19.7:

```powershell
Get-AksHciClusterUpdates -name myCluster
```

```output
details                                                     kubernetesversion operatingsystemversion
-------                                                     ----------------- ----------------------
This is a patch kubernetes upgrade. (i.e v1.1.X  to v1.1.Y) v1.19.9           @{mariner=April 2021; windows=April 2021}
This is a minor kubernetes upgrade. (i.e v1.X.1 to v1.Y.1)  v1.20.5           @{mariner=April 2021; windows=April 2021}
```

As you can see from this output, you can either perform a patch update to v1.19.9 or a minor update to v1.20.5.

## Upgrade Kubernetes version of a workload cluster using PowerShell

Use the [Update-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/update-akshcicluster) PowerShell command to perform a Kubernetes minor update. This command also updates the operating system version of your container host OS:

```powershell
Update-AksHciCluster -name myCluster -kubernetesVersion v1.20.5
```

## Update container OS version without updating Kubernetes

If you upload a workload cluster to a newer version of the operating system without changing the Kubernetes version, it doesn't work unless the new OS version does not require a different Kubernetes version. Run the [Update-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/update-akshcicluster) command and specify the `operatingSystem` parameter to update the container hosts of AKS workload clusters to a newer version of the operating system. The following example assumes that the workload cluster `myCluster` currently has an operating system version that's more than 30 days old:

```powershell
Update-AksHciCluster -name myCluster -operatingSystem
```