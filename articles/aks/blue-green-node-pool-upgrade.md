---
layout: Conceptual
title: Blue-Green Node Pool Upgrades in Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/blue-green-node-pool-upgrade
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
description: Perform upgrades of AKS node pools using a blue-green deployment strategy to ensure workload availability during updates.
ms.topic: how-to
ms.subservice: aks-upgrade
ms.custom: azure-kubernetes-service
ms.date: 2024-11-06T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.reviewer: schaffererin
locale: en-us
document_id: a9fd98a5-a1bd-8e17-8b31-1a84c93b0f71
document_version_independent_id: ac861b53-1711-ebbc-f6d6-48118a11e412
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/blue-green-node-pool-upgrade.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/blue-green-node-pool-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/blue-green-node-pool-upgrade.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: b10a59c9-4bbb-8fb2-68ab-4fa9cf6bc728
---

# Blue-Green Node Pool Upgrades in Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn

Blue-green upgrades enable you to upgrade your AKS node pools by adding new *green* nodes with the updated configuration (Kubernetes and node image version) to the existing node pool, while the original *blue* nodes continue running. This strategy allows you to test and validate the new configuration before committing to the new version, with the ability to quickly roll back if issues arise.

This article explains when to use blue-green upgrades, how the process works, configuration options, and considerations for using this upgrade strategy.

## When to use blue-green upgrades

Note

Keep in mind that blue-green upgrades require double the node capacity during the upgrade process, which can lead to increased costs and resource requirements.

Consider blue-green upgrades when:

- You require granular testing and verification of workloads batch by batch.
- You need to validate new node configurations before switching production traffic.
- You want instant rollback capability without reprovisioning nodes.
- You're upgrading critical production workloads that can't tolerate disruption.
- You need to test application compatibility with new Kubernetes versions.

If you're currently using a manual blue-green deployment process for node pool upgrades and want to automate this workflow, consider using AKS blue-green node pool upgrades instead. For more information about the manual blue green upgrade process, see [Manual blue-green node pool upgrades](how-does-upgrade-happen#blue-green-node-pool-upgrades-manual).

## When to use standard rolling upgrades

Standard rolling upgrades might be more appropriate in the following scenarios:

- Development or test environments with downtime tolerance.
- Cost-sensitive deployments where temporary doubling is prohibitive.
- Simple stateless applications with good disruption handling.
- Environments with limited available quota or capacity.

## Prerequisites

- Sufficient quota for doubling node pool capacity.
- Azure CLI version 2.64.0 or higher. Find your version using the `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The `aks-preview` Azure CLI extension installed and updated to the latest version.
- API version `2025-08-02-preview` or later.
- [Cluster autoscaler](cluster-autoscaler-overview) configured (recommended, but not required).

### Install the `aks-preview` Azure CLI extension

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Install or update the `aks-preview` extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) and [`az extension update`](/en-us/cli/azure/extension#az-extension-update) commands.

```azurecli
# Install the aks-preview extension
az extension add --name aks-preview

# Update the aks-preview extension
az extension update --name aks-preview
```

## Supported features for blue-green upgrades

Blue-green upgrades currently support the following features:

- [Kubernetes version upgrades](upgrade-cluster)
- [Node image upgrades](node-image-upgrade)
- [System and user node pools](use-system-pools)
- Manual commit and rollback control
- [Cluster autoscaler](cluster-autoscaler)
- [Availability zones](/en-us/azure/reliability/reliability-aks#availability-zone-support)
- [PodDisruptionBudgets](operator-best-practices-scheduler#limit-disruption-impact-by-using-pod-disruption-budgets-pdbs)
- [Autoupgrade channels](auto-upgrade-cluster) and [Planned Maintenance windows](planned-maintenance)
- [AKS Communication Manager](aks-communication-manager)

## Blue-green upgrade limitations and considerations

Blue-green upgrades currently don't support the following features:

- Automated rollback
- Using blue green strategy for updates outside of Kubernetes and node image version (ex. certificate rotation, kubelet/os configuration updates, etc)
- [Virtual machine (VM) pools](virtual-machines-node-pools)
- [Max unavailable](upgrade-cluster#customize-unavailable-nodes-during-upgrade) setting
- [Undrainable node behavior](upgrade-options#option-2-handle-undrainable-nodes-while-honoring-pdbs) and [maxBlockedNodes](upgrade-options#example-configuration-with-max-blocked-nodes) setting

Keep the following considerations in mind when using blue-green upgrades:

| Resource requirements | Complexity considerations | Time factors |
| --- | --- | --- |
| \* Requires double the node capacity during the upgrade process, leading to increased infrastructure costs.  \* You need extra compute quota in your Azure subscription to accommodate the temporary doubling of nodes.  \* You might encounter regional capacity limits during peak usage periods. | \* Requires careful planning for stateful workloads to ensure data consistency during migration.  \* Requires extra monitoring for both the blue and green nodes during the transition period. | \* Longer overall upgrade duration compared to in-place upgrades.  \* Validation period adds time before final cutover. |

## Blue-green upgrade workflow

The blue-green upgrade process creates a parallel environment for safe transitions between node pool versions. You can either **upgrade and commit to the new *green* pool after validation** or **upgrade and roll back to the original *blue* pool** if you encounter issues.

### Upgrade and commit scenario

The following diagram illustrates the upgrade and commit workflow:

[![Diagram showing the upgrade and commit scenario workflow.](media/blue-green-node-pool-upgrade/blue-green-upgrade-commit.png)](media/blue-green-node-pool-upgrade/blue-green-upgrade-commit.png#lightbox)

The upgrade and commit process is as follows:

1. **Cordon *blue* nodes**: Existing *blue* nodes are marked as unschedulable.
2. **Add *green* nodes**: New *green* nodes with the updated configuration are added to the existing node pool.
3. **Parallel operation**: Both *blue* and *green* nodes run simultaneously within the same node pool.
4. **Gradual migration**: Workloads are progressively drained from *blue* nodes and rescheduled to *green* nodes in batches.
5. **Validate *green* nodes**: Monitor and test workloads on the new nodes during migration.
6. **Complete transition**: After the final validation period, the *blue* nodes are deleted and *green* nodes become primary.

### Upgrade and roll back scenario

The following diagram illustrates the upgrade and roll back workflow:

[![Diagram showing the upgrade and roll back scenario workflow.](media/blue-green-node-pool-upgrade/blue-green-upgrade-roll-back.png)](media/blue-green-node-pool-upgrade/blue-green-upgrade-roll-back.png#lightbox)

The upgrade and roll back process is as follows:

1. **Cordon *blue* nodes**: Existing *blue* nodes are marked as unschedulable.
2. **Add *green* nodes**: New *green* nodes with the updated configuration are added to the existing node pool.
3. **Parallel operation**: Both *blue* and *green* nodes run simultaneously within the same node pool.
4. **Detect issues**: Identify problems during validation on *green* nodes.
5. **Execute rollback**: Uncordon *blue* nodes, drain *green* nodes, and migrate workloads back to *blue* nodes.
6. **Restore state**: *Green* nodes are deleted and the node pool returns to its original configuration.

## Choose your upgrade strategy

When creating or upgrading an AKS node pool, you can specify the upgrade strategy (`upgradeStrategy`) to use. The available strategies include:

| Strategy | Description |
| --- | --- |
| `Rolling` (default) | Standard rolling upgrade where nodes are updated one by one. |
| `BlueGreen` | Adds new *green* nodes with the updated configuration to the existing node pool while keeping the original *blue* nodes running. |

During an in-progress upgrade, AKS supports switching from `BlueGreen` to `Rolling`, but not from `Rolling` to `BlueGreen`.

## Customize blue-green upgrade properties

You can customize the following blue-green upgrade properties (`NodePoolBlueGreenUpgradeSettings`):

| Property | Description | Allowed values | Default value |
| --- | --- | --- | --- |
| `drainBatchSize` | Number or percentage of nodes to drain in each batch during upgrade. Percentage is calculated from the total number of blue nodes at the start of the upgrade. Fractional nodes are rounded up. | Integer (for example, `5`) or percentage (for example, `50%`). **Must be a non-zero value**. | 10% |
| `drainTimeoutInMinutes` | Maximum time (in minutes) to wait for pods to gracefully terminate on each node before failing the upgrade. Honors pod disruption budgets during this wait time. If exceeded, the upgrade fails. | Integer between `1` and `1440` (24 hours). | 30 minutes |
| `batchSoakDurationInMinutes` | Pause time (in minutes) between draining batches of nodes to allow for observation and validation. | Integer between `0` and `1440` (24 hours). | 15 minutes |
| `finalSoakDurationInMinutes` | Wait time (in minutes) after all nodes are drained before removing old nodes. Provides a final validation period before committing to the upgrade. Rollback operations are only available during this final soak period. Once this period expires and the blue pool is deleted, rollback is no longer possible. | Integer between `0` and `10080` (seven days). | 60 minutes |

## Create a node pool with default blue-green upgrade settings

- Create a node pool with the default blue-green upgrade strategy and settings using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--upgrade-strategy` parameter set to `bluegreen`. The following example creates a new node pool named `myNodePool` in the AKS cluster `myAKSCluster` within the resource group `myResourceGroup`:

    ```azurecli
    az aks nodepool add \
        --name myNodePool \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --upgrade-strategy bluegreen
    ```

## Create a node pool with custom blue-green upgrade settings

- Create a node pool with custom blue-green upgrade settings using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--upgrade-strategy` parameter set to `bluegreen` and set any desired custom blue-green upgrade settings. The following example creates a new node pool named `myNodePool` in the AKS cluster `myAKSCluster` within the resource group `myResourceGroup`, with custom blue-green upgrade settings:

    ```azurecli
    az aks nodepool add \
        --name myNodePool \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --upgrade-strategy bluegreen \
        --drain-timeout-bg 5 \
        --batch-soak-duration 5 \
        --drain-batch-size 50% \
        --final-soak-duration 180
    ```

## Start a blue-green upgrade for an existing node pool

Important

When you resume a paused upgrade, you can update the blue-green settings, but you can't change the Kubernetes version. You can switch an in-progress blue-green upgrade to the rolling strategy, but you can't switch an in-progress rolling upgrade to blue-green.

- Start a blue-green upgrade for an existing node pool using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command with the `--kubernetes-version` parameter set to your desired version. You can start a blue-green upgrade for a node pool already using the blue-green strategy or for a node pool not yet configured with blue-green strategy. The following examples demonstrate both scenarios:

    ```azurecli
    # Start a blue-green upgrade for an existing node pool already using blue-green strategy
    az aks nodepool upgrade \
        --name myNodePool \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --kubernetes-version <kubernetes-version>
    
    # Start a blue-green upgrade for an existing node pool not yet using blue-green strategy
    az aks nodepool upgrade \
        --name myNodePool \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup \
        --kubernetes-version <kubernetes-version> \
        --upgrade-strategy bluegreen
    ```

## Pause or cancel a blue-green upgrade

- Pause or cancel an ongoing blue-green upgrade using the [`az aks nodepool operation-abort`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-operation-abort) command. The following example pauses or cancels the blue-green upgrade for the node pool named `myNodePool` in the AKS cluster `myAKSCluster` within the resource group `myResourceGroup`:

    ```azurecli
    az aks nodepool operation-abort \
        --name myNodePool \
        --cluster-name myAKSCluster \
        --resource-group myResourceGroup
    ```

## Switch an in-progress blue-green upgrade to rolling

If an in-progress blue-green upgrade can't be resumed because node pool property changes would require a node reimage, you can switch the node pool upgrade strategy to rolling. AKS removes the blue-green upgrade protections and continues cleanup by using the rolling upgrade behavior.

```azurecli
az aks nodepool update \
    --name myNodePool \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup \
    --upgrade-strategy Rolling
```

## Roll back a blue-green upgrade

Once an ongoing blue-green upgrade is canceled, the rollback can be initiated using the [`az aks nodepool rollback`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-rollback) command.

The rollback is only available during the final soak period as described in the [finalSoakDurationInMinutes](/en-us/azure/aks/blue-green-node-pool-upgrade#customize-blue-green-upgrade-properties) property.

The following example performs a rollback of the blue-green upgrade for the node pool named `myNodePool` in the AKS cluster `myAKSCluster` within the resource group `myResourceGroup`:

```azurecli
az aks nodepool rollback \
    --name myNodePool \
    --cluster-name myAKSCluster \
    --resource-group myResourceGroup
```

## Frequently asked questions (FAQs)

### Do blue-green upgrades support the `maxUnavailable` setting?

No, the `maxUnavailable` setting isn't applicable to blue-green upgrades. New *green* nodes are added to the existing node pool alongside the existing *blue* nodes, ensuring all original nodes remain available during the upgrade process.

### Can blue-green upgrades be used for node pool updates beyond Kubernetes and node image version?

No, the blue-green upgrade strategy currently supports only Kubernetes and node image version upgrades. You can't use this strategy for other changes, such as certificate rotation or kubelet and OS configuration changes. If you need to apply changes that trigger node reimage while a blue-green upgrade is in progress, switch the node pool to the rolling upgrade strategy or revert the property changes before retrying.

### Which Kubernetes versions are compatible with blue-green upgrades?

Blue-green upgrades work with all [AKS-supported Kubernetes versions](supported-kubernetes-versions), including both community-supported versions and [Long Term Support (LTS) versions](long-term-support), so long as you use API version `2025-08-02-preview` or later.

### Can I use the automatic security patch channel with blue-green upgrades?

Yes, as long as the node pool's upgrade strategy is configured to use blue-green. When configured, security patches follow the blue-green upgrade process instead of the default rolling update mechanism.

### What happens to persistent volumes during blue-green upgrades?

Persistent volumes remain accessible. Pods are gracefully drained and rescheduled, maintaining their volume attachments.

### Can I perform blue-green upgrades across multiple node pools simultaneously?

Yes, different node pools can undergo blue-green upgrades in parallel, but each pool can only have one active upgrade. You currently can't control the order of upgrades across multiple pools.

### How do blue-green upgrades handle node-specific configurations like taints and labels?

All node configurations including taints, labels, and annotations are automatically replicated to the *green* pool.

### What's the cost impact of blue-green upgrades?

You're charged for both the original *blue* nodes and the new *green* nodes during the upgrade window, so make sure you plan for temporary cost doubling during the transition period.

### What happens during a capacity failure?

In the event of a capacity failure when adding the *green* nodes, the upgrade fails and the *blue* nodes remain unaffected. You can retry the upgrade once sufficient capacity is available or choose to roll back.

### What happens during rollback?

If the number of green nodes is less than or equal to the number of blue nodes when rollback is initiated, the green nodes are removed, and the blue nodes are uncordoned and revived to resume normal operation.