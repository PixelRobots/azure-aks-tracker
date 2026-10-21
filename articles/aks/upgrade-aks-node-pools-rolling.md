---
layout: Conceptual
title: Configure rolling upgrades for Azure Kubernetes Service (AKS) node pools - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-node-pools-rolling
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
description: Learn how to configure and customize rolling upgrades for Azure Kubernetes Service (AKS) node pools, including surge settings, drain timeout, and soak time.
ms.topic: how-to
ms.subservice: aks-upgrade
ms.date: 2026-05-29T00:00:00.0000000Z
author: kaarthis
ms.author: schaffererin
locale: en-us
document_id: a8a6aab8-38be-0cef-9087-c62482123f87
document_version_independent_id: f0f431d7-c09c-2943-c4cb-6b536a2b2851
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/upgrade-aks-node-pools-rolling.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/upgrade-aks-node-pools-rolling
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/upgrade-aks-node-pools-rolling.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 1a96eca8-0d90-365b-4564-13d7f6793b44
---

# Configure rolling upgrades for Azure Kubernetes Service (AKS) node pools - Azure Kubernetes Service | Microsoft Learn

A rolling upgrade strategy upgrades nodes one at a time (or a few at a time), minimizing workload disruption while ensuring the node pool remains available throughout the upgrade process. This article explains how to configure rolling upgrades for AKS node pools, including surge settings, drain timeout, and soak time.

## Before you begin

- Ensure your control plane is already upgraded to the target Kubernetes version. You can't upgrade node pools to a version higher than the control plane. For more information, see [Upgrade the AKS cluster control plane](upgrade-aks-control-plane).
- If you're using the Azure CLI, this article requires Azure CLI version 2.34.1 or later. Use the `az --version` command to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need the `Microsoft.ContainerService/managedClusters/agentPools/write` RBAC role permission to configure rolling upgrades for AKS node pools.
- If you're upgrading an AKS Standard node pool to Kubernetes 1.37 or later, review its LocalDNS profile. A node pool without an explicit profile can have LocalDNS enabled during the upgrade. If you use custom virtual network DNS, verify that the DNS server and complete network path support both TCP and UDP port 53. For more information, see [Configure LocalDNS in AKS](localdns-custom).

Important

LocalDNS activation changes the DNS forwarding path used by workloads. Test both UDP and TCP DNS resolution from an AKS node before upgrading:

```bash
dig +udp @<custom-dns-ip> <fqdn>
dig +tcp @<custom-dns-ip> <fqdn>
```

If TCP fails, correct the custom DNS server or network rules before upgrading, or explicitly set LocalDNS to `Disabled`.

## Overview of rolling upgrade behavior

During a rolling upgrade, AKS performs the following operations for each node in the node pool:

1. **Add surge nodes**: Add new buffer nodes based on max surge (`--max-surge`) settings to maintain capacity during the upgrade.
2. **Cordon and drain nodes**: [Cordon and drain](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) the old nodes one at a time to minimize disruption to running applications. If you're using max surge, it cordons and drains as many nodes at the same time as the number of buffer nodes specified.
3. **Wait for soak time** (optional): Wait for a configured soak duration before proceeding to allow workloads to stabilize on the new nodes before continuing the upgrade.
4. **Reimage old nodes**: When the old nodes are drained, they're reimaged to receive the new version. The reimaged nodes become the buffer nodes for the next set of nodes to be upgraded.
5. **Repeat**: The process repeats until all nodes in the node pool are upgraded.
6. **Remove surge nodes**: After all nodes are upgraded, any remaining buffer nodes are removed, maintaining the original node pool size and balance.

## Configure rolling upgrade settings

### Customize node surge

Important

- Node surges require subscription quota for the requested max surge count for each upgrade operation. For example, a cluster that has five node pools, each with a count of four nodes, has a total of 20 nodes. If each node pool has a max surge value of 50%, extra compute and IP quota of 10 nodes (*two* nodes × *five* pools) is required to complete the upgrade.
- The max surge setting on a node pool is persistent. Subsequent Kubernetes upgrades or node version upgrades use this setting. You can change the max surge value for your node pools at any time. For production node pools, we recommend a max surge setting of 33%.
- If you're using Azure CNI, validate there are available IPs in the subnet to [satisfy IP requirements of Azure CNI](configure-azure-cni).
- Azure Virtual Machine Scale Sets (VMSS) allow a maximum of 1,000 instances per scale set. If a node pool's current size plus the calculated surge count would exceed 1,000 instances, AKS rejects the upgrade before it starts.

AKS configures upgrades to surge with one extra node by default. A default value of *one* for the max surge setting enables AKS to minimize workload disruption by creating an extra node before the cordon/drain of existing applications to replace an older versioned node. You can customize the max surge value per node pool. When you increase the max surge value, the upgrade process completes faster, but you might experience more disruptions during the upgrade process.

For example, a max surge value of `100%` provides the fastest possible upgrade process but also causes all nodes in the node pool to be drained simultaneously. You might want to use a higher value like this for testing environments. For production node pools, we recommend a max surge setting of `33%`.

AKS accepts both integer values and a percentage value for max surge. For example:

| Value type | Example | Description |
| --- | --- | --- |
| Integer | `5` | Five extra nodes to surge |
| Percentage | `50%` | Surge value of half the current node count in the pool |

Max surge can be set to an integer or a percentage. A percent value is rounded up to the nearest node count. If the max surge value is higher than the required number of nodes to be upgraded, the number of nodes to be upgraded is used for the max surge value.

If scaling to the max surge value isn't possible due to quota or capacity limitations, for agent pools with Kubernetes version &gt;= 1.35, AKS automatically attempts a surge of 1 as a fallback. If the surge of 1 succeeds, the upgrade proceeds with 1 surge node.

#### Set max surge value

Set max surge values for new or existing node pools using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) or [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with the `--max-surge` parameter. For example:

```azurecli
# Set max surge for a new node pool
az aks nodepool add \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --max-surge 33%

# Update max surge for an existing node pool 
az aks nodepool update \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --max-surge 5
```

### Customize unavailable nodes

Important

- Max unavailable doesn't create surge nodes during the upgrade process. Instead, AKS cordons *n* nodes (the max unavailable value) at a time and evicts the pods to other nodes in the agent pool. This might cause workload disruptions if the pods can't be scheduled.
- Max unavailable might cause more failures due to unsatisfied Pod Disruption Budgets (PDBs) since there are fewer resources for pods to be scheduled on. For more information, see [Troubleshooting for Pod Disruption Budgets](/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-poddrainfailure).
- You can't set max unavailable on system node pools.

AKS can also configure upgrades to not use a surge node and upgrade the nodes in place. The max unavailable value determines how many nodes can be simultaneously cordoned and drained from the existing node pool nodes. Using max unavailable for an in-place upgrade is recommended when obtaining additional quota or capacity is not possible for the upgrade surge.

AKS accepts both integer values and a percentage value for max unavailable. For example:

| Value type | Example | Description |
| --- | --- | --- |
| Integer | `5` | Five nodes are cordoned from the existing nodes |
| Percentage | `50%` | Half the current node count in the pool will be unavailable |

The default value of `maxUnavailable` is `0`. When `maxUnavailable` is `0`, AKS requires `maxSurge` to be greater than `0`. For more details, see the [AgentPoolUpgradeSettings API reference](/en-us/rest/api/aks/agent-pools/create-or-update?tabs=HTTP#agentpoolupgradesettings).

Like max surge, if the max unavailable value is higher than the number of nodes remaining to be upgraded in the current operation, the number of nodes remaining to be upgraded is used for the max unavailable value instead. This condition can occur, for example, when an upgrade operation resumes after only some nodes in the pool were previously upgraded.

#### Set max unavailable value

Set max unavailable values for new or existing node pools using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add), [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update), or the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command with the `--max-unavailable` parameter. For example:

```azurecli
# Set max unavailable for a new node pool
az aks nodepool add \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --max-surge 0 \
    --max-unavailable 5

# Update max unavailable for an existing node pool 
az aks nodepool update \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --max-surge 0 \
    --max-unavailable 5

# Set max unavailable at upgrade time
az aks nodepool upgrade \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --max-surge 0 \
    --max-unavailable 5
```

### MaxUnavailable fallback (preview)

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

When both `maxSurge` and `maxUnavailable` are greater than 0, AKS uses a fallback strategy during upgrades:

1. **Attempt full surge**: AKS first attempts to surge using the configured `maxSurge` value.
2. **Fall back to surge of 1**: If the full surge isn't possible due to quota or capacity limitations, AKS attempts a surge of 1 node instead (for agent pools with Kubernetes version &gt;= 1.35).
3. **Fall back to in-place upgrade**: If AKS fails to get a surge node, it falls back to an in-place upgrade using `maxUnavailable`, cordoning and draining existing nodes without adding new ones.

This fallback approach ensures upgrades can proceed even when capacity is constrained, while still preferring the less disruptive surge-based approach when resources are available.

The aks-preview Azure CLI extension is required to use MaxUnavailable fallback. `maxSurge` and `maxUnavailable` can be used together for fallback behavior or individually.

#### Set both max surge and max unavailable values

```azurecli
# Configure fallback: try surge first, fall back to in-place upgrade if capacity is unavailable
az aks nodepool add \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --max-surge 33% \
    --max-unavailable 3

# Update an existing node pool with fallback configuration
az aks nodepool update \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --max-surge 33% \
    --max-unavailable 3
```

### Customize node drain timeout

You might have long-running workloads on certain pods that you can't reschedule to another node during runtime. For example, a memory-intensive stateful workload that must finish running. In these cases, you can configure a node drain timeout that AKS respects in the upgrade workflow.

The default node drain timeout value is 30 minutes. Node drain timeout values can be a minimum of 5 minutes and a maximum of 24 hours.

If the drain timeout value elapses and pods are still running, the upgrade operation stops. Any subsequent `PUT` operation resumes the stopped upgrade.

Tip

For long-running pods, you should also configure the [`terminationGracePeriodSeconds`](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/) in your pod spec.

#### Set node drain timeout value

Set node drain timeout (in minutes) for new or existing node pools using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) or [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with the `--drain-timeout` parameter.

```azurecli
# Set drain timeout for a new node pool
az aks nodepool add \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --drain-timeout 100

# Update drain timeout for an existing node pool
az aks nodepool update \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --drain-timeout 45
```

### Customize node soak time

To enable a waiting period for a specified duration of time between draining a node and proceeding to reimage it and move on to the next node, you can set the soak time. This soak time gives you the opportunity to perform other tasks during the upgrade process, such as checking application health from a monitoring dashboard.

The default node soak time is 0 minutes. Node soak time values can be a minimum of 0 minutes and a maximum of 30 minutes. We recommend keeping soak time as short as reasonably possible. A higher node soak time increases the total upgrade duration and delays discovery of issues.

#### Set node soak time value

Set node soak time (in minutes) for new or existing node pools using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add), [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update), or [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command with the `--node-soak-duration` flag.

```azurecli
# Set node soak time for a new node pool
az aks nodepool add \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --node-soak-duration 10

# Update node soak time for an existing node pool
az aks nodepool update \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --max-surge 33% \
    --node-soak-duration 5

# Set node soak time when upgrading an existing node pool
az aks nodepool upgrade \
    --name <node-pool-name> \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --max-surge 33% \
    --node-soak-duration 20
```

## View AKS node upgrade events

View upgrade events using the `kubectl get events` command to monitor the rolling upgrade progress.

```bash
kubectl get events --field-selector reason=Drain,reason=Surge,reason=Upgrade
```

Example output during an upgrade event:

```output
default  2m1s  Normal  Drain    node/aks-nodepool1-12345678-vmss000001  Draining node: [aks-nodepool1-12345678-vmss000001]
default  9m22s Normal  Surge    node/aks-nodepool1-12345678-vmss000002  Created a surge node [aks-nodepool1-12345678-vmss000002 nodepool1] for agentpool nodepool1
default  1m45s Normal  Upgrade  node/aks-nodepool1-12345678-vmss000001  Soak duration 5m0s after draining node: aks-nodepool1-12345678-vmss000001
```

## Recommended AKS node pool upgrade settings for production workloads

The following table outlines recommended node pool upgrade settings for production workloads:

| Setting | Recommendation |
| --- | --- |
| **Max surge** | Set to 33% for production node pools |
| **Drain timeout** | Configure based on your longest-running pod's requirements |
| **Soak time** | Use a short duration (0-5 minutes) unless you need manual verification |
| **Pod Disruption Budgets** | Configure PDBs for critical workloads to control pod eviction |
| **Upgrade order** | Upgrade non-production node pools first to validate the new version |