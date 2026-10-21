---
layout: Conceptual
title: Troubleshoot AKS upgrade errors because of version skew, incompatibility, or lack of support - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/aks-upgrade-blocked
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
description: Learn how to troubleshoot AKS upgrade errors caused by unsupported Kubernetes versions or node pool skew, and follow steps to upgrade successfully.
ms.date: 2026-09-29T00:00:00.0000000Z
ms.reviewer: dandshi
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: d18bf359-229c-21a8-a7bd-f78c8ca1a57f
document_version_independent_id: d18bf359-229c-21a8-a7bd-f78c8ca1a57f
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/aks-upgrade-blocked.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/aks-upgrade-blocked
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/aks-upgrade-blocked.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 334f2471-21b3-4402-1e21-677487b732b2
---

# Troubleshoot AKS upgrade errors because of version skew, incompatibility, or lack of support - Azure | Microsoft Learn

## Summary

Use this guide when an Azure Kubernetes Service (AKS) upgrade fails because of an unsupported Kubernetes version, a disallowed upgrade path, or node-pool version skew.

## Prerequisites

This article requires Azure CLI version 2.67.0 or a later version. To find the version number, run `az --version`. To install or upgrade the Azure CLI, see [How to install the Azure CLI](/en-us/cli/azure/install-azure-cli).

For more detailed information about the upgrade process, see the "Upgrade an AKS cluster" section in [Upgrade options and recommendations for Azure Kubernetes Service (AKS) clusters](/en-us/azure/aks/upgrade-cluster#upgrade-an-aks-cluster).

## Symptoms

The upgrade fails with one or more of the following errors.

### Error message 1: K8sVersionNotSupported

> 
> `<ClusterName>` is on version 1.25.6 which is not supported in this region. Please use the `[az aks get-versions]` command to get the supported version list in this region. For more information, see [Supported Kubernetes versions in Azure Kubernetes Service (AKS)](https://aka.ms/supported-version-list).

### Error message 2: OperationNotAllowed

> 
> Upgrading Kubernetes version 1.24.9 to 1.26.6 is not allowed. Available upgrades: [1.29.15 1.29.14 1.29.13 1.29.12 1.29.11 1.29.10 1.29.9 1.29.8 1.29.7 1.29.6 1.29.5 1.29.4 1.29.2 1.29.0]. For more information, see [AKS supported Kubernetes versions](https://aka.ms/aks-supported-k8s-ver) for version details.

### Error message 3: NodePoolMcVersionIncompatible

> 
> Node pool version 1.24.9 and control plane version 1.29.15 is incompatible. Minor version of node pool cannot be more than 3 versions less than control plane's version. Minor version of node pool is 24 and control plane is 29. For more information, see [AKS upgrade version skew policy](https://aka.ms/aks/UpgradeVersionRules).

The version numbers are historical examples, not upgrade targets. For current guidance, see the [AKS version support policy](/en-us/azure/aks/supported-kubernetes-versions#can-i-skip-multiple-aks-versions-during-a-cluster-upgrade) and [Kubernetes version upgrade rules](/en-us/azure/aks/upgrade-aks-control-plane#kubernetes-version-upgrade-rules).

## Cause

The upgrade isn't allowed for one or more of the following reasons:

- The target Kubernetes version is unavailable in the selected Azure region or is no longer supported for the cluster's support plan.
- The requested upgrade path isn't allowed for the support plan. See Upgrade-path combinations.
- A node pool version is too far behind or newer than the target control plane version. See Node-pool skew checks.

For more information, see:

- [AKS supported Kubernetes versions](/en-us/azure/aks/supported-kubernetes-versions)
- [AKS upgrade version skew policy](/en-us/azure/aks/upgrade-aks-control-plane#kubernetes-version-upgrade-rules)

## AKS upgrade troubleshooting flow

Record the error, target version, support plan, and whether the request used `--control-plane-only`. Start with the version and support checks.

[![Screenshot of the AKS upgrade troubleshooting flowchart for version support, LTS status, and node pool skew checks.](media/aks-upgrade-blocked/upgrade-troubleshooting-flow.png)](media/aks-upgrade-blocked/upgrade-troubleshooting-flow.png#lightbox)

### Upgrade-path combinations

Check the [AKS upgrade policy](/en-us/azure/aks/supported-kubernetes-versions#can-i-skip-multiple-aks-versions-during-a-cluster-upgrade) for the current and target versions. Non-Long Term Support (LTS) (community) uses `KubernetesOfficial`; LTS uses `AKSLongTermSupport`. Check support status under the applicable plan.

The following table summarizes the allowed and disallowed upgrade paths based on the current and target Kubernetes versions.

| Current version | Target version | Upgrade |
| --- | --- | --- |
| Unsupported non-LTS | Supported LTS | Allowed |
| Unsupported LTS | Supported LTS | Allowed |
| Unsupported non-LTS | Lowest supported GA non-LTS version offered by AKS | Allowed |
| Supported LTS | Higher supported LTS | Allowed |
| Supported non-LTS | Next supported non-LTS minor version | Allowed |
| Supported non-LTS | Supported non-LTS more than one minor version ahead | Not allowed |
| Any current version | Unsupported target version | Not allowed |

#### Conditions for "Allowed"

AKS must offer the target, and all skew and validation checks must pass. Unsupported non-LTS recovery requires a full-cluster upgrade. LTS requires Premium and explicit `AKSLongTermSupport` enrollment.

Important

Unsupported recovery remains outside support and isn't guaranteed safe.

For support-plan changes, see [LTS support-plan transitions](/en-us/azure/aks/long-term-support). A plan change alone doesn't upgrade Kubernetes or make a version skip eligible.

## Troubleshooting and resolution

### Collect cluster details and verify target availability

Get the region, support plan, and control plane and pool versions. Use the failed command or error to identify the target; `ConfiguredVersion` is the resource setting, not necessarily the failed target.

Run the following commands to collect cluster details and verify the target availability.

```azurecli
az aks show --resource-group <RG> --name <ClusterName> --query "{Location:location,ConfiguredVersion:kubernetesVersion,CurrentVersion:currentKubernetesVersion,State:provisioningState,SupportPlan:supportPlan,Tier:sku.tier,UpgradeChannel:autoUpgradeProfile.upgradeChannel}" --output json
```

```azurecli
az aks nodepool list --resource-group <RG> --cluster-name <ClusterName> --query "[].{Name:name,ConfiguredVersion:orchestratorVersion,CurrentVersion:currentOrchestratorVersion,State:provisioningState}" --output table
```

Use that region to check version availability.

Run the following command.

```azurecli
az aks get-versions --location <region> --output table
```

Check current and target support dates in the [AKS release calendar](/en-us/azure/aks/supported-kubernetes-versions#aks-kubernetes-release-calendar-and-upcoming-versions), including the LTS calendar when applicable. List the cluster's offered targets.

Run the following command.

```azurecli
az aks get-upgrades --resource-group <RG> --name <ClusterName> --output table
```

`get-upgrades` shows control plane targets, not every pool's version. A missing target doesn't prove regional deprecation. Check regional availability, support status, and cluster-offered targets separately.

If the target isn't available, supported, or offered, don't retry it. Choose an allowed path in the following section.

### Select the upgrade path for your scenario

Choose a path from the upgrade-path combinations. For control-plane-only requests, also check node-pool skew.

Important

A gapped upgrade skips one or more minor versions and can accumulate API removals and breaking changes. An allowed upgrade doesn't guarantee workload or add-on compatibility.

Note

Before upgrading, read the [Kubernetes release notes](https://kubernetes.io/releases/notes/) for the target and intervening versions, [AKS release notes](https://github.com/Azure/AKS/releases), and [AKS compatibility checks](/en-us/azure/aks/upgrade-options#validations-used-in-the-upgrade-process). Follow [AKS production upgrade guidance](/en-us/azure/aks/aks-production-upgrade-strategies): test workloads and add-ons in nonproduction, back up data, and plan for disruption.

#### Supported community upgrades

Upgrade to the next offered minor version. Confirm completion, rerun `get-upgrades`, and repeat until you reach the target. Don't skip minor versions or downgrade.

#### Supported LTS upgrades

For LTS benefits, including extended support, see [Long-term support for AKS versions](/en-us/azure/aks/long-term-support).

Select a higher supported LTS target offered by AKS. Minor-version skips are allowed only if skew and validation checks pass. If an eligible upgrade remains blocked, contact Azure support.

#### Recovery from unsupported versions

For non-LTS to community recovery, select the **oldest supported GA target offered by AKS** and use a **full-cluster upgrade**. Then upgrade one minor version at a time.

For the LTS recovery route, follow these steps:

1. Choose an offered [supported LTS target](/en-us/azure/aks/supported-kubernetes-versions#lts-versions). Run a full-cluster upgrade with `--tier premium --k8s-support-plan AKSLongTermSupport`. See [Enable long-term support](/en-us/azure/aks/long-term-support#enable-long-term-support).
2. Continue through supported LTS versions one minor at a time **only if each next target is offered**. Confirm completion and rerun `get-upgrades` at each step.
3. When the control plane and pools reach the desired **community-supported** version, [disable LTS](/en-us/azure/aks/long-term-support#disable-long-term-support-on-an-existing-cluster) with Free or Standard and `KubernetesOfficial`.

If no eligible recovery target is offered or the risk is unacceptable, migrate to a new cluster on a supported version. Back up and validate data, and test workloads before migration.

#### Perform a full-cluster upgrade

Run a full-cluster upgrade with the selected target. For LTS recovery, include the tier and support-plan flags above. AKS upgrades the control plane, then the pools sequentially; all validation checks still apply.

Run the following command.

```azurecli
az aks upgrade --resource-group <RG> --name <ClusterName> --kubernetes-version <AvailableUpgradeVersion>
```

Confirm completion before the next upgrade.

### Check node-pool skew for control-plane-only upgrades

For unsupported non-LTS recovery or cluster autoupgrade, use a full-cluster upgrade, not control-plane-only. Otherwise, compare each pool's **current** version with the control plane **target**.

For control plane version 1.N starting with Kubernetes 1.28, pool minor versions must be between **N-3 and N, inclusive**. Pools can't be newer than the control plane. For older versions, check the applicable [version-skew policy](https://kubernetes.io/releases/version-skew-policy/).

The following scenarios might occur when checking node-pool skew:

- **Pool too old:**[Upgrade the pool](/en-us/azure/aks/upgrade-aks-node-pools-rolling) to an offered version that's compatible with the **current** control plane. Confirm completion before retrying the control plane upgrade.
- **Pool newer than the target:** Recheck the versions. Select an offered target that isn't older than the current control plane or any pool. Don't upgrade the pool further or downgrade the control plane.

If no eligible sequence exists, use the recovery or migration guidance. Otherwise, retry with an offered target after every pool meets the skew requirements.

Run the following command.

```azurecli
az aks upgrade --resource-group <RG> --name <ClusterName> --kubernetes-version <AvailableUpgradeVersion> --control-plane-only
```

Other upgrade checks still apply. If the request is rejected, follow If the upgrade remains blocked.

### Confirm the upgrade result

Rerun the cluster and node-pool commands. For the control plane and each upgraded pool, verify that `CurrentVersion` matches the target and `State` is `Succeeded`. Don't use `ConfiguredVersion` alone to confirm completion.

If an upgrade failed, troubleshoot the returned error before retrying. Check workload health separately.

### If the upgrade remains blocked

[Create an Azure support request](/en-us/azure/azure-portal/supportability/how-to-create-azure-support-request) if the checks don't explain the failure. Include the error code and message, failure time, operation or correlation ID, region, current and target versions, support plan, request mode, and diagnostic output. Submit these details privately, not in a public issue.

Contacting support doesn't guarantee an upgrade exception or make unsupported recovery supported.

### Additional recommendations for AKS upgrades

- If you enable cluster autoupgrade, use a full-cluster upgrade. See [autoupgrade restrictions](/en-us/azure/aks/auto-upgrade-cluster#control-plane-upgrade-constraints).
- If you use the managed Istio add-on, check [revision compatibility](/en-us/azure/aks/istio-support-policy#aks-compatibility) with the target version and support plan, and then follow the [required upgrade order](/en-us/azure/aks/istio-upgrade#minor-revision-upgrade).