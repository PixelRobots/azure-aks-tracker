---
layout: Conceptual
title: AKS cluster creation fails on Azure Local 2511 or 2512 after upgrade from 2510 | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/cluster-create-fails-after-azure-local-upgrade
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
description: Learn how to troubleshoot and resolve an issue where new AKS cluster creation fails after upgrading Azure Local from version 2510 to 2511 or 2512.
ms.topic: troubleshooting
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.lastreviewed: 2026-01-26T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: 989f4a17-d8f8-699a-1ce7-c9c3b5c95aee
document_version_independent_id: 2f06c341-1e2c-4c46-a0f8-46a703f527c3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/cluster-create-fails-after-azure-local-upgrade.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/cluster-create-fails-after-azure-local-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/cluster-create-fails-after-azure-local-upgrade.md
platformId: 7b9e3f13-19db-ad00-860f-e07d7bdd31bf
---

# AKS cluster creation fails on Azure Local 2511 or 2512 after upgrade from 2510 | Microsoft Learn

After you upgrade Azure Local from version 2510 to 2511 or 2512, new AKS cluster creation fails while existing clusters and other operations continue to work normally.

## Overview

AKS Hybrid and Edge on Azure Local supports cluster lifecycle operations including creation, upgrade, and management. When Azure Local is upgraded from version 2510 to 2511 or 2512, a configuration issue with the `HybridAksExtension` prevents new AKS cluster creation. This issue doesn't affect existing AKS clusters or fresh installations of Azure Local 2511 or 2512.

## Symptoms

After upgrading Azure Local from version 2510 to 2511 or 2512, you might observe the following issue when attempting to create new AKS clusters:

- Cluster creation fails with a timeout error:

    ```output
    "message": "Error: Timed out waiting for the operation to complete. Detailed message: AKSAddonsReady: Warning: AddonNotReady: ProviderCSIDriver: AddOn not ready.\n: Timed out CorrelationId: "
    ```
- Failure consistently reproduces only on systems upgraded from 2510.
- No failures observed in host upgrade or existing cluster upgrades.

## Cause

This issue occurs due to a problem with the HybridAksExtension in Azure Local 2511 or 2512. When you upgrade from version 2510 to 2511 or 2512, the system enters a state that prevents new cluster creation. However, existing clusters and other operations continue to work normally.

## Scope and impact

This section describes the upgrade scenarios affected by this issue and the impact on customer environments.

### Affected scenarios

- Azure Local upgraded from version 2510 to 2511.
- Azure Local upgraded from version 2510 to 2512.
- Attempting new AKS cluster creation after the upgrade.

| Azure Local upgrade path | AKS cluster creation result |
| --- | --- |
| Upgrade 2510 → 2511 | ❌ Failure |
| Upgrade 2510 → 2512 | ❌ Failure |

### Customer impact

- Customers upgrading Azure Local from 2510 to 2511 or 2512 are blocked from creating new AKS clusters.
- Production risk for customers planning post-upgrade cluster expansion.
- Upgrade path continues to work, masking the issue until cluster creation is attempted.

## Confirm the issue

Check if your environment is affected by verifying the HybridAksExtension version.

### Step 1: Check extension version

Run the following commands to check the HybridAksExtension version:

```powershell
az login --use-device-code --tenant <Azure tenant ID>
az account set -s <subscription ID>
$res=get-archcimgmt
az k8s-extension show -g $res.HybridaksExtension.resourceGroup -c $res.ResourceBridge.name --cluster-type appliances --name hybridaksextension
```

### Step 2: Verify issue applicability

You're affected by this issue if the following items apply:

- HybridAksExtension version is 4.0.X (versions prior to 4.0.92).
- Azure Local was upgraded from version 2510 to 2511 or 2512.
- You're attempting to create a new AKS cluster.

## Workaround

To resolve the cluster creation issue, update the HybridAksExtension to the latest version using the following PowerShell commands.

### Update HybridAksExtension to latest version

Run the following PowerShell commands to update the HybridAksExtension to the latest patch version:

```powershell
Install-Module -Name Support.AksArc
Import-Module Support.AksArc
Invoke-SupportAksArcRemediation_HotFix_2511_2512CreateCluster
```

This command updates the extension to version 4.0.92 or later, which resolves the cluster creation issue.

### Verify the fix

After running the remediation commands, verify that the extension is updated:

```powershell
az login --use-device-code --tenant <Azure tenant ID>
az account set -s <subscription ID>
$res=get-archcimgmt
az k8s-extension show -g $res.HybridaksExtension.resourceGroup -c $res.ResourceBridge.name --cluster-type appliances --name hybridaksextension
```

Confirm that the HybridAksExtension version is 4.0.92 or later.

## Resolution

This issue is currently under investigation, and a permanent fix is in progress.

Until the fix is fully validated and released, customers are advised to follow the recommended workaround described in this article. This page is updated as more guidance becomes available.