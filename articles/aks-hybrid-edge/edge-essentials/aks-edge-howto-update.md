---
layout: Conceptual
title: AKS Edge Essentials update (online) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-howto-update
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
description: Learn how to update AKS Edge Essentials clusters.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-how-to, edge-essentials
locale: en-us
document_id: 0914389a-cb67-6ec8-0c95-427f75bc2d3e
document_version_independent_id: 4941afb0-0467-5393-17a7-a76ceb32d736
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-update.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-howto-update
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-howto-update.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/c21d0a62-47cf-4452-bd24-e1ed14abbeda
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f43eaf81-15c1-41e2-95b2-89fb1560c563
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
platformId: 76198583-a183-1d4f-a047-88abcb5f4557
---

# AKS Edge Essentials update (online) | Microsoft Learn

As newer versions of AKS Edge Essentials become available, you can update your AKS Edge Essentials clusters to take advantage of the latest features and security improvements. This article describes how to update and upgrade your AKS Edge Essentials devices when fixes and a new version are available.

The AKS Edge Essentials cluster is comprised of two main components that need to be updated. The first is the Mariner Linux VM. This virtual machine is installed as a part of the AKS Edge Essentials MSI, and has no package manager, so you can't manually update or change any of the VM components. Instead, the virtual machine is managed with Microsoft Update to automatically keep the components up to date. Second, the Kubernetes platform can be upgraded to stay in sync with the open-source version and the AKS service.

Microsoft Update reliably updates the AKS Edge Essentials virtual machine. The virtual machine uses the A/B update partition scheme, to make each update safe and enable a rollback to a previous version if anything goes wrong during the update process.

AKS Edge Essentials upgrades are sequential and you must upgrade to every version. To get to the latest version, you must either do a fresh installation using the latest available version, or apply all the previous servicing updates, up to the desired version.

## Step 1: configure the host machine to receive updates using Microsoft Update

To receive AKS Edge Essentials updates, configure the Windows host to receive updates for other Microsoft products. By default, Microsoft Update is enabled during AKS Edge Essentials installation. If custom configuration is needed after installation, you can turn this option on or off using the following steps:

1. Open **Settings** on the Windows host.
2. Select **Updates & Security**.
3. Select **Advanced options**.
4. Toggle the **Receive updates for other Microsoft products when you update Windows** button to **On**.

Microsoft Update in the Windows Update subsystem can now scan for an update for AKS Edge Essentials based on the Windows Update policy set on the machine. If you want to force the scan immediately, you can select **Check for updates**.

Important

Microsoft Update must be enabled on all machines in the cluster.

After the update is downloaded from either the cloud endpoint or a local WSUS server, it can be staged and installed on all the nodes on a machine.

## Step 2: update files on all nodes

On all nodes in your cluster, run `Start-AksEdgeUpdate` to install the MSI and other related files:

```powershell
Start-AksEdgeUpdate
```

## Step 3: update the primary control node

If you have more than one control node in your deployment, first update the primary control node using the following command:

```powershell
Start-AksEdgeControlPlaneUpdate -firstControlPlane $true
```

## Step 4: update the secondary control nodes

You can then update the other control nodes using the following command:

```powershell
Start-AksEdgeControlPlaneUpdate -firstControlPlane $false
```

## Step 5: update worker nodes

Update the worker nodes in your cluster by running the following command on each of the worker nodes:

```powershell
Start-AksEdgeWorkerNodeUpdate 
```

## Update using Windows Server Update Services (WSUS)

On-premises updates using WSUS is supported for AKS Edge Essentials updates. For more information about WSUS, see [Device Management Overview - WSUS](/en-us/windows/iot/iot-enterprise/device-management/device-management-overview#windows-server-update-services-wsus).

## Upgrade to newer versions

For a list of currently supported Kubernetes versions on both K3s and K8s, see the table in [Download AKS Edge Essentials](aks-edge-howto-setup-machine#download-aks-edge-essentials). As we continue to add support to newer versions, you can use over-the-air updates to the newer versions. To upgrade your clusters to newer versions, set the `Set-AksEdgeUpgrade` command to `true`:

```powershell
Set-AksEdgeUpgrade – AcceptUpgrade $true
```

You can then select **Check for Updates** to download and stage an update if applicable. Then, run the `Start-AksEdgeUpdate` to complete the update:

```powershell
Start-AksEdgeUpdate
```

This command then triggers the version upgrade.