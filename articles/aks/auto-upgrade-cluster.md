---
layout: Conceptual
title: Automatically Upgrade an Azure Kubernetes Service (AKS) Cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster
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
description: Learn how to automatically upgrade an Azure Kubernetes Service (AKS) cluster to get the latest features and security updates. For AKS Automatic clusters, cluster upgrades are preconfigured using the stable channel. For AKS Standard clusters, select the upgrade channel that best meets your needs.
ms.topic: how-to
ms.author: schaffererin
author: schaffererin
ms.subservice: aks-upgrade
ms.date: 2026-06-26T00:00:00.0000000Z
ms.custom: aks-upgrade, automation, innovation-engine
locale: en-us
document_id: 56afdd50-cc63-915e-d07c-83c74993afad
document_version_independent_id: ed4520e2-6e15-a477-e90f-cc38e7ac8b85
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/auto-upgrade-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/auto-upgrade-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/auto-upgrade-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 0d1c5137-6401-bedc-b482-d0be70214e2f
---

# Automatically Upgrade an Azure Kubernetes Service (AKS) Cluster - Azure Kubernetes Service | Microsoft Learn

Important

**AKS platform-initiated upgrades.** Starting on **June 1, 2027**, AKS automatically upgrades any cluster that stays on an unsupported Kubernetes version after its 60-day [platform support grace period](platform-initiated-upgrades#platform-support-grace-period) ends. A platform-initiated upgrade **doesn't follow your maintenance window**, **doesn't stop for deprecated API usage**, and **can override a Pod Disruption Budget** that blocks a node drain, so workloads might be disrupted. Before the upgrade month, replace APIs removed from the target Kubernetes version and update incompatible self-managed add-ons. Keep your clusters on a supported Kubernetes version to avoid a platform-initiated upgrade. For more information, see [Prepare for platform-initiated upgrades in AKS](platform-initiated-upgrades#prepare-before-aks-starts-the-upgrade).

Part of the AKS cluster lifecycle involves performing periodic upgrades to the latest Kubernetes version. It's important you apply the latest security releases or upgrade to get the latest features. Before you learn about automatic upgrades, make sure you understand the [AKS cluster upgrade fundamentals](upgrade-cluster).

Tip

If you're using **AKS Automatic**, cluster upgrades are preconfigured to use the **stable** channel, automatically upgrading to the latest patch on minor version N-1 (where N is the latest supported version). No configuration is needed. For AKS Automatic clusters with specific maintenance requirements, you can set planned maintenance windows. To learn more, see [What is Azure Kubernetes Service (AKS) Automatic?](intro-aks-automatic) For AKS Standard clusters, continue reading to select the channel that best fits your requirements.

Note

Any upgrade operation, whether performed manually or automatically, upgrades the node image version if it's not already on the latest version. The latest version is contingent on a full AKS release and can be determined by visiting the [AKS release tracker](release-tracker).

Autoupgrade first upgrades the control plane, and then upgrades agent pools one by one.

## Why use cluster autoupgrade

Cluster autoupgrade provides a *set once and forget* mechanism that yields tangible time and operational cost benefits. You don't need to stop your workloads, redeploy your workloads, or create a new AKS cluster. By enabling autoupgrade, you can ensure your clusters are up to date and don't miss the latest features or patches from AKS and upstream Kubernetes.

For **AKS Automatic** clusters, this benefit comes built-in - cluster autoupgrades are preconfigured and enabled by default using the stable channel, eliminating the need for manual configuration or decision-making.

AKS follows a strict supportability versioning window. With properly selected autoupgrade channels, you can avoid clusters falling into an unsupported version. For more on the AKS support window, see [Alias minor versions](supported-kubernetes-versions).

## Customer versus AKS-initiated cluster autoupgrades

You can specify cluster autoupgrade specifics using the following guidance. The upgrades occur based on your specified cadence and are recommended to remain on supported Kubernetes versions.

- AKS automatically upgrades clusters in version N-3 (where N is the latest supported AKS GA minor version) that are about to fall to N-4, upgrading them to N-2 instead. This action ensures clusters remain in the AKS support window. For more information, see [AKS support window](supported-kubernetes-versions).
- Stopped node pools are upgraded during an autoupgrade operation. The upgrade applies to nodes when the node pool is started. To minimize disruptions, set up [maintenance windows](planned-maintenance).

If a cluster stays on an unsupported version after the 60-day platform support grace period, AKS upgrades it through a [platform-initiated upgrade](platform-initiated-upgrades). This upgrade can run regardless of your auto-upgrade channel, including `none` or `patch`, or when no channel is configured. It can occur outside your maintenance window. Your channel and maintenance window configurations aren't changed.

Setting the `stable` channel together with a [maintenance window](planned-maintenance) helps keep your cluster on a supported minor version and avoid a platform-initiated upgrade. The `patch` channel applies patches within the current minor version but doesn't move the cluster to a newer minor version. For more information, see [How to avoid platform-initiated upgrades](platform-initiated-upgrades#how-to-avoid-platform-initiated-upgrades).

## Cluster autoupgrade limitations

### Control plane upgrade constraints

If you're using cluster autoupgrade, you can no longer upgrade the control plane first, and then upgrade the individual node pools. Cluster autoupgrade always upgrades the control plane and the node pools together. You can't upgrade the control plane only. Running the `az aks upgrade --control-plane-only` command raises the following error:

```output
NotAllAgentPoolOrchestratorVersionSpecifiedAndUnchanged: Using managed cluster api, all Agent pools' OrchestratorVersion must be all specified or all unspecified. If all specified, they must be stay unchanged or the same with control plane.
```

### Node-image autoupgrade and unattended upgrades

If using the `node-image` cluster autoupgrade channel, which is now legacy and should no longer be used, or the `NodeImage` node image autoupgrade channel, Linux [unattended upgrades](https://help.ubuntu.com/community/AutomaticSecurityUpdates) are disabled by default.

## Cluster autoupgrade channels

Automatically completed upgrades are functionally the same as manual upgrades. The selected autoupgrade channel determines the timing of upgrades. When making changes to autoupgrade, allow 24 hours for the changes to take effect. Automatically upgrading a cluster follows the same process as manually upgrading a cluster. For more information, see [Upgrade an AKS cluster](upgrade-cluster).

### For AKS Automatic clusters

AKS Automatic clusters use the **stable** channel by default. This channel provides the recommended balance of staying current with the latest features and security updates while maintaining stability. Clusters automatically upgrade to the latest patch release on minor version N-1 (where N is the latest supported minor version).

**No configuration is required** - upgrades happen automatically within your maintenance window. You can set planned maintenance windows if needed to control when upgrades occur, but the channel choice is fixed to stable.

**Why stable for AKS Automatic?**

- Keeps clusters within the N-2 support window (safe and compliant)
- Balances innovation with stability
- Fully managed by AKS with safe deployment practices
- Aligned with AKS well-architected best practices
- Optimized for production workloads

### For AKS Standard clusters

If you're using AKS Standard, choose the channel that best aligns with your operational requirements.

The following upgrade channels are available:

| Channel | Action | Example |
| --- | --- | --- |
| `none` | Disables autoupgrades and keeps the cluster at its current version of Kubernetes. | Default setting if left unchanged. |
| `patch` | Automatically upgrades the cluster to the latest supported patch version when it becomes available while keeping the minor version the same. | For example, if a cluster runs version *1.17.7*, and versions *1.17.9*, *1.18.4*, *1.18.6*, and *1.19.1* are available, the cluster upgrades to *1.17.9*. |
| `stable` | Automatically upgrades the cluster to the latest supported patch release on minor version *N-1*, where *N* is the latest supported minor version. | For example, if a cluster runs version *1.17.7* and versions *1.17.9*, *1.18.4*, *1.18.6*, and *1.19.1* are available, the cluster upgrades to *1.18.6*. |
| `rapid` | Automatically upgrades the cluster to the latest supported patch release on the latest supported minor version. | In cases where the cluster's Kubernetes version is an *N-2* minor version, where *N* is the latest supported minor version, the cluster first upgrades to the latest supported patch version on *N-1* minor version. For example, if a cluster runs version *1.17.7* and versions *1.17.9*, *1.18.4*, *1.18.6*, and *1.19.1* are available, the cluster first upgrades to *1.18.6*, then upgrades to *1.19.1*. |
| `node-image`(legacy) | Automatically upgrades the node image to the latest version available. | Microsoft provides patches and new images for image nodes frequently (weekly), but your running nodes don't get the new images unless you do a node image upgrade. Turning on the node-image channel automatically updates your node images whenever a new version is available. If you use this channel, Linux [unattended upgrades] are disabled by default. Node image upgrades work on patch versions that are deprecated, so long as the minor Kubernetes version is still supported. This channel is no longer recommended and is planned for deprecation in future. For an option that can automatically upgrade node images, see the `NodeImage` channel in [node image autoupgrade](auto-upgrade-node-image). |

Note

Keep the following information in mind when using cluster autoupgrade:

- Cluster autoupgrade only updates to GA versions of Kubernetes and doesn't update to preview versions.
- With AKS, you can create a cluster without specifying the exact patch version. When you create a cluster without designating a patch, the cluster runs the minor version's latest GA patch. To learn more, see [AKS support window](supported-kubernetes-versions).
- Auto-upgrade requires the cluster's Kubernetes version to be within the [AKS support window](supported-kubernetes-versions), even if using the `node-image` channel. Once a cluster falls out of support, auto-upgrade no longer applies. If it remains on the unsupported version after the 60-day platform support grace period, AKS upgrades it through a [platform-initiated upgrade](platform-initiated-upgrades) instead.
- If you're using the preview API `11-02-preview` or later, and you select the `node-image` cluster autoupgrade channel, the node image upgrade setting automatically switches to the `NodeImage` channel.
- Each cluster can only be associated with a single autoupgrade channel. The reason is because your specified channel determines the Kubernetes version that runs on the cluster.

## Cluster mode comparison

The following table summarizes cluster autoupgrade configuration by cluster mode:

| Aspect | AKS Automatic | AKS Standard |
| --- | --- | --- |
| Default channel | stable (preconfigured) | Manual selection required |
| Upgrade cadence | Weekly (fixed to N-1) | Based on your selected channel |
| Configuration required | None - upgrades automatic | Yes - select channel and schedule |
| Recommended for | Most production workloads | Custom requirements or specific constraints |
| Maintenance window control | Optional | Highly recommended |
| Channel options available | stable only (fixed) | patch, stable, rapid, none |

## Use cluster autoupgrade with a new AKS cluster

Note

If you're creating an **AKS Automatic cluster**, skip these steps. The stable channel is already preconfigured for automatic upgrades. These steps apply to AKS Standard clusters only.

# [Azure CLI](#tab/azure-cli)
Set the autoupgrade channel when creating a new cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command and the `auto-upgrade-channel` parameter.

```azurecli
az aks create \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --auto-upgrade-channel stable \
  --generate-ssh-keys
```

# [Azure portal](#tab/azure-portal)
1. In the Azure portal, select **Create a resource** &gt; **Containers** &gt; **Azure Kubernetes Service (AKS)**.
2. In the **Basics** tab, under **Cluster details**, select the desired autoupgrade channel from the **Automatic upgrade** dropdown. We recommend selecting the **Enabled with patch (recommended)** option.

    ![Screenshot of the automatic upgrade field that shows Enabled with patch (recommended) selected.](media/auto-upgrade-cluster/portal-autoupgrade-new-cluster.png)
3. To create the cluster, complete the remaining steps.

---

## Use cluster autoupgrade with an existing AKS cluster

Note

If you're using an **AKS Automatic cluster**, you can't change the cluster autoupgrade channel - it's preconfigured to use stable. These steps apply to AKS Standard clusters only. You can set planned maintenance windows for your AKS Automatic cluster if needed.

# [Azure CLI](#tab/azure-cli)
Set the autoupgrade channel on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `auto-upgrade-channel` parameter.

```azurecli
az aks update \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --auto-upgrade-channel stable
```

Results:

```JSON
{
  "id": "/subscriptions/aaaa6a6a-bb7b-cc8c-dd9d-eeeeee0e0e0e/resourceGroups/myResourceGroupabc123/providers/Microsoft.ContainerService/managedClusters/myAKSCluster",
  "properties": {
    "autoUpgradeChannel": "stable",
    "provisioningState": "Succeeded"
  }
}
```

# [Azure portal](#tab/azure-portal)
1. In the Azure portal, go to your AKS cluster.
2. In the service menu, under **Settings**, select **Upgrades**.
3. Under **Upgrade** &gt; **Kubernetes version**, select **Upgrade version**.

    ![Screenshot of the upgrade cluster page for an AKS cluster in the Azure portal.](media/auto-upgrade-cluster/portal-autoupgrade-existing-cluster.png)
4. On the **Upgrade Kubernetes version** page, select the desired autoupgrade channel from the **Automatic upgrade** dropdown. We recommend selecting the **Enabled with patch (recommended)** option.

    ![Screenshot of the Upgrade Kubernetes version page for an AKS cluster in the Azure portal.](media/auto-upgrade-cluster/portal-autoupgrade-upgrade-page-existing-cluster.png)
5. Select **Save**.

---

## Use cluster autoupgrade with Planned Maintenance

If using Planned Maintenance and cluster autoupgrade, your upgrade starts during your specified maintenance window.

Note

To ensure proper functionality, use a maintenance window of *four hours or more*.

If you manage the same cluster autoupgrade schedule across multiple clusters, you can link each cluster's `aksManagedAutoUpgradeSchedule` maintenance configuration to a shared maintenance window. For more information, see [Use a shared maintenance window](/en-us/azure/aks/planned-maintenance?pivots=azure-cli#use-a-shared-maintenance-window-preview).

For more information on how to set a maintenance window with Planned Maintenance, see [Use Planned Maintenance to schedule maintenance windows for your Azure Kubernetes Service (AKS) cluster](planned-maintenance).

## Best practices for cluster autoupgrade

Use the following best practices to help maximize your success when using autoupgrade:

- To ensure your cluster is always in a supported version, such as within the N-2 rule, choose either the `stable` or `rapid` channels. (**Note**: AKS Automatic clusters use `stable` by default.)
- If you want to get the latest patches as soon as possible, use the `patch` channel.
- To automatically upgrade node images while using a different cluster upgrade channel, consider using the [node image autoupgrade](auto-upgrade-node-image)`NodeImage` channel.
- Follow [Operator best practices](operator-best-practices-scheduler).
- Follow [PodDisruptionBudget (PDB) best practices](https://kubernetes.io/docs/tasks/run-application/configure-pdb/).
- For upgrade troubleshooting information, see the [AKS troubleshooting documentation](/en-us/support/azure/azure-kubernetes/welcome-azure-kubernetes).

### Is cluster autoupgrade configured differently for AKS Automatic?

Yes. AKS Automatic clusters are preconfigured to use the stable channel by default - you don't need to configure anything. This configuration provides:

- Automatic upgrades to the latest patch on minor version N-1
- Weekly upgrade cadence aligned with AKS best practices
- Fully managed by AKS with safe deployment practices
- Maintenance window control (optional)
- Production-ready defaults optimized for most workloads

AKS Standard clusters require you to select a channel based on your specific needs. To migrate from AKS Standard to AKS Automatic and benefit from these preconfigured defaults, see [What is Azure Kubernetes Service (AKS) Automatic?](intro-aks-automatic)

For a detailed discussion of upgrade best practices and other considerations, see [AKS patch and upgrade guidance](/en-us/azure/architecture/operator-guides/aks/aks-upgrade-practices).