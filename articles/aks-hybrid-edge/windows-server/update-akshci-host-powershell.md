---
layout: Conceptual
title: Upgrade the AKS host in AKS on Windows Server using PowerShell | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/windows-server/update-akshci-host-powershell
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
description: Learn about using PowerShell to upgrade the AKS host in AKS on Windows Server.
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2022-01-14T00:00:00.0000000Z
ms.reviewer: mikek
ms.custom: windows-server
author: davidsmatlak
locale: en-us
document_id: aaad4ded-8055-1766-d93a-4eaeeeaefcb8
document_version_independent_id: 7f97a725-a7ea-5ea0-6b69-399e78fc3d5e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/windows-server/update-akshci-host-powershell.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/windows-server/update-akshci-host-powershell
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/windows-server/update-akshci-host-powershell.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/fc3f72c2-fb6f-4cea-95ee-b444e52254ee
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f12cf087-582d-48ac-a085-0c19adf1e391
platformId: dc5999ae-f44f-1222-f738-1918802aa3cb
---

# Upgrade the AKS host in AKS on Windows Server using PowerShell | Microsoft Learn

> 
> Applies to: AKS on Windows Server

This article describes how to update the Azure Kubernetes Service host in AKS on Windows Server.

## Overview of AKS host updates

Updates to the AKS host always include the latest available version. Although you can update the host independently of workload cluster updates, you must always update the host before updating a workload cluster.

To avoid outages and loss of AKS availability, rolling updates are performed. When you bring a new node with a newer build into the cluster, resources move from the old node to the new node. When you successfully remove the resources, the old node is decommissioned and removed from the cluster.

Note

Microsoft recommends upgrading your AKS clusters within 30 days of a new release. If you don't update within this window, you have up to 90 days from your last upgrade before internal certificates and tokens expire. Once the certificates and tokens expire, the cluster is still functional; however, you must call Microsoft Support to upgrade. When you reboot the cluster after the 90-day period, it remains in a non-functional state. For more information about internal certificates and tokens, see the [overview of certificate management](certificates-overview).

## Update the AKS host

The first step in any update flow is to run the [Update-AksHci](/en-us/azure/aks/aksarc/reference/ps/update-akshci) command to update the AKS host. `Update-AksHci` takes no arguments and always updates the management cluster to the latest version. You must initiate this step before running [Update-AksHciCluster](/en-us/azure/aks/aksarc/reference/ps/update-akshcicluster) to update the Kubernetes cluster to a new version.

Important

The update command only works if you have installed the GA release or later. It does not work for earlier releases. This update command updates the AKS host and the on-premises Microsoft-operated cloud platform. This command does not update any existing AKS workload clusters. New AKS workload clusters created after updating the AKS host might differ from existing AKS workload clusters in their OS version and Kubernetes version.

We recommend updating AKS workload clusters immediately after updating the AKS host to get the newest OS versions and recent fixes. If a workload cluster is on an unsupported Kubernetes version in the next version of AKS, the upgrade fails.

## Example flow for updating an AKS host

### Update the PowerShell modules

Make sure you always have the latest PowerShell modules installed on the AKS nodes by running the following command on all the physical nodes in your AKS deployment.

Important

You should close all open PowerShell windows and then open a fresh session to run the update command. If you don't close all PowerShell windows, there might be modules that are in use and can't be updated.

```powershell
Update-Module -Name AksHci -Force -AcceptLicense
```

### Get the current AKS version

```powershell
Get-AksHciVersion                    
```

```output
1.0.0.10517
```

### Get the available AKS updates

```powershell
Get-AksHciUpdates
```

The output shows the available versions to which this AKS host can be updated:

```output
1.0.2.10723
```

#### Versioning

Using version 1.0.2.10723 as an example, the following table shows how version numbers are constructed for AKS releases.

| Value | Meaning |
| --- | --- |
| 1 | Major version: +1 for each release with a large breaking change. |
| 0 | Minor version: +1 for each release after the latest major version with a major functionality change. |
| 2 | Feature & patch updates: +1 for each regular (typically monthly) release after the latest major version. |
| 1 | Build type: Always 1 for public-facing builds. |
| 0723 | Build creation date: Build creation date in mmdd format. |

### Initiate the AKS update

```powershell
Update-AksHci
```

### Verify the AKS host was updated

```powershell
Get-AksHciVersion
```

The output shows the updated version of AKS on the AKS host:

```output
1.0.2.10723
```