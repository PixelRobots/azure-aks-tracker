---
layout: Conceptual
title: Stop Azure Kubernetes Service (AKS) Cluster Upgrades Automatically on API Breaking Changes - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/stop-cluster-upgrade-api-breaking-changes
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
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how AKS blocks cluster upgrades when deprecated Kubernetes API usage is detected, and how to remediate or bypass validation.
ms.topic: how-to
ms.subservice: aks-upgrade
ms.date: 2026-07-01T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: f67a2dca-4b1a-cbfa-7eab-e676f33c90fe
document_version_independent_id: d936c7dd-b515-c1ed-ca8e-39229eab1abd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/stop-cluster-upgrade-api-breaking-changes.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/stop-cluster-upgrade-api-breaking-changes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/stop-cluster-upgrade-api-breaking-changes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 0e1d5311-5264-e0ef-8dfc-4749b5d3eae3
---

# Stop Azure Kubernetes Service (AKS) Cluster Upgrades Automatically on API Breaking Changes - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic ✔️ AKS Standard

Important

**AKS platform-initiated upgrades.** Starting on **June 1, 2027**, AKS automatically upgrades any cluster that stays on an unsupported Kubernetes version after its 60-day [platform support grace period](platform-initiated-upgrades#platform-support-grace-period) ends. A platform-initiated upgrade **doesn't follow your maintenance window**, **doesn't stop for deprecated API usage**, and **can override a Pod Disruption Budget** that blocks a node drain, so workloads might be disrupted. Before the upgrade month, replace APIs removed from the target Kubernetes version and update incompatible self-managed add-ons. Keep your clusters on a supported Kubernetes version to avoid a platform-initiated upgrade. For more information, see [Prepare for platform-initiated upgrades in AKS](platform-initiated-upgrades#prepare-before-aks-starts-the-upgrade).

This article shows how Azure Kubernetes Service (AKS) can automatically block cluster upgrades when it detects deprecated Kubernetes API usage.

For most production workloads, AKS Automatic is the recommended production-ready default experience for AKS. Kubernetes API breaking-change detection is preconfigured on both AKS Automatic and AKS Standard clusters.

## Behavior in AKS Automatic and AKS Standard

Both cluster modes include this safeguard:

- **AKS Automatic**: Included by default as part of AKS Automatic production-ready platform safeguards.
- **AKS Standard**: Included by default on AKS Standard clusters.

In both modes, AKS can block minor version upgrade operations when it detects recent usage of APIs deprecated or removed in the target Kubernetes version.

## Overview

To stay within a supported Kubernetes version, you must upgrade your cluster at least once per year and prepare for possible disruptions. These disruptions can include API breaking changes, deprecations, and dependencies such as Helm and Container Storage Interface (CSI). It can be difficult to anticipate these disruptions and migrate critical workloads without downtime.

When AKS detects deprecated API usage for the target version, it can automatically block minor version upgrade operations and alert you to the issue. This behavior helps you avoid unexpected disruptions and gives you time to fix deprecated API usage before continuing the upgrade.

Important

This safeguard doesn't apply to [platform-initiated upgrades](platform-initiated-upgrades). When a cluster stays on an unsupported Kubernetes version after the platform support grace period ends, AKS upgrades it even if deprecated API usage is detected. Check for deprecated API usage and remediate it before your cluster's platform-initiated upgrade month.

## Prerequisites

Make sure you meet the following prerequisites:

- The upgrade operation is a Kubernetes minor version change for the cluster control plane.
- The Kubernetes target version is 1.26 or later.
- The last-seen usage of deprecated APIs for the target version occurred within 12 hours before the upgrade operation. AKS records usage hourly, so usage within the most recent hour isn't guaranteed to appear in detection.

Note

You don't need to manually enable this detection feature. AKS Automatic and AKS Standard clusters preconfigure it.

## Mitigate stopped upgrade operations

If you meet the prerequisites, attempt an upgrade, and receive an error similar to the following error message:

```output
Bad Request({
  "code": "ValidationError",
  "message": "Control Plane upgrade is blocked due to recent usage of a Kubernetes API deprecated in the specified version. Please refer to https://kubernetes.io/docs/reference/using-api/deprecation-guide to migrate the usage. To bypass this error, set enable-force-upgrade in upgradeSettings.overrideSettings. Bypassing this error without migrating usage will result in the deprecated Kubernetes API calls failing. Usage details: 1 error occurred:\n\t* usage has been detected on API flowcontrol.apiserver.k8s.io.prioritylevelconfigurations.v1beta1, and was recently seen at: 2023-03-23 20:57:18 +0000 UTC, which will be removed in 1.26\n\n",
  "subcode": "UpgradeBlockedOnDeprecatedAPIUsage"
})
```

Use one of the following options:

- Remove usage of deprecated APIs (recommended)
- Bypass validation to ignore API changes.

### Remove usage of deprecated APIs (recommended)

1. In the Azure portal, navigate to your cluster resource and select **Diagnose and solve problems**
2. Select **Create, Upgrade, Delete, and Scale** &gt; **Kubernetes API deprecations**.

    ![A screenshot of the Azure portal showing the 'Selected Kubernetes API deprecations' section.](media/upgrade-cluster/applens-api-detection-full-v2.png)
3. Wait 12 hours from the time the last deprecated API usage was seen. Read-only verbs are excluded from the deprecated API usage, namely [Get/List/Watch](https://kubernetes.io/docs/reference/using-api/api-concepts/). You can also check past API usage by enabling [Container insights](/en-us/azure/azure-monitor/containers/container-insights-log-query#resource-logs) and exploring kube audit logs.
4. Retry your cluster upgrade.

### Bypass validation to ignore API changes

Note

This method requires Azure CLI version 2.57 or later. If you have the preview CLI extension installed, update to version 3.0.0b10 or later. This method isn't recommended for normal production operations because deprecated APIs in the target Kubernetes version might fail long term. Remove deprecated API usage as soon as possible after the upgrade.

Run upgrade with validation bypass by using the [`az aks upgrade`](/en-us/cli/azure/aks#az-aks-upgrade) command with `--enable-force-upgrade` and set `--upgrade-override-until` to define when the bypass window ends. If you don't set a value, the window defaults to three days from current time. The provided date and time must be in the future.

```azurecli
# Set environment variables
RESOURCE_GROUP_NAME=<your-resource-group-name>
CLUSTER_NAME=<your-cluster-name>
KUBERNETES_VERSION=<target-kubernetes-version>

# Run the upgrade command with validation bypass
az aks upgrade --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME --kubernetes-version $KUBERNETES_VERSION --enable-force-upgrade --upgrade-override-until 2023-10-01T13:00:00Z
```

Note

`Z` is the zone designator for the zero UTC/GMT offset, also known as 'Zulu' time. This example sets the end of the window to `13:00:00` GMT. For more information, see [Combined date and time representations](https://wikipedia.org/wiki/ISO_8601#Combined_date_and_time_representations).

## Production considerations

For production workloads, follow these practices:

- Treat upgrade blocking as a safety mechanism, not a failure state.
- Prefer API migration over force bypass.
- Use planned maintenance windows and pre-upgrade checks.
- Monitor deprecated API usage continuously to avoid last-minute upgrade blocks.