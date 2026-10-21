---
layout: Conceptual
title: Automatic zone placement in Azure Kubernetes Service (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-automatic-zone-placement
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
description: Learn how to use automatic zone placement (--zones auto) to let AKS dynamically select availability zones for your node pools.
ms.topic: how-to
ms.date: 2026-07-23T00:00:00.0000000Z
author: yudian
ms.author: yudian
locale: en-us
document_id: c6df1c8e-e151-bd76-18b3-586231e56670
document_version_independent_id: fb444e98-a89b-b1bc-ee97-7331fbdf388f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-automatic-zone-placement.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/configure-automatic-zone-placement
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-automatic-zone-placement.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 76df8213-8bde-620c-c69c-49390bc5824d
---

# Automatic zone placement in Azure Kubernetes Service (Preview) - Azure Kubernetes Service | Microsoft Learn

Automatic zone placement in Azure Kubernetes Service (AKS) dynamically selects the best set of [availability zones](/en-us/azure/reliability/availability-zones-overview) for a node pool. You don't need to specify the zones manually for each region and VM SKU combination. When you create or update a node pool with `--zones auto`, AKS places virtual machines (VMs) in availability zones that have capacity for the requested SKU in the target region and applies a maximum instance percentage of 50% per zone.

This article shows you how to create or update AKS node pools that use automatic zone placement.

## How automatic zone placement works

When you specify `--zones auto` (or `availabilityZones: ["auto"]` in the agent pool profile), AKS uses the Azure Compute automatic zone placement policy to select zones and distribute nodes. You don't need to specify zone numbers or maintain different zone configurations for each region and VM SKU.

Automatic zone placement works as follows:

1. AKS evaluates which availability zones in the target region can support the requested VM SKU.
2. AKS initially selects up to three available zones and places nodes according to the automatic zone placement policy. No single zone can contain more than 50% of the node pool.
3. During later scale-out operations, AKS reevaluates zone availability. If Azure adds a zone to the region or makes the VM SKU available in another zone, AKS might place new nodes in that zone when the placement policy and available capacity allow it. You don't need to update the node pool configuration.

Important

The 50% limit is a maximum concentration per zone, not a guarantee that nodes are always distributed equally. The actual distribution depends on the node count, the zones that support the selected VM SKU, and the capacity available when nodes are provisioned. A create or scale operation can still fail if Azure can't allocate the requested nodes while honoring the per-zone limit.

This approach addresses common pain points with manually specifying zones:

- **Region-agnostic deployments**: Use consistent configurations across regions without worrying about zone availability differences.
- **Improved resilience**: Automatically achieve multizone redundancy for better application availability.
- **Automatic zone expansion**: Seamlessly leverage new availability zones when regions expand (for example, from three to four zones).
- **Reduced deployment failures**: Reduce creation and scaling allocation failures caused by capacity constraints in specific zone based on your workload tolerance of zonal balancing.

## Limitations and considerations

- Automatic zone placement only supports regions with availability zone support. For more information, see the [List of Azure regions](/en-us/azure/reliability/regions-list).
- Automatic zone placement supports creating and updating both Virtual Machine Scale Sets-based and Virtual Machines-based node pools.
- The per-zone cap is 50% of nodes. A create or scale operation can still fail if Azure can't allocate the requested nodes while honoring the per-zone limit.
- Automatic zone placement is intended for [zone-spanning](reliability-availability-zones-configure#zone-spanning-node-pools) workloads. For [zone-aligned](reliability-availability-zones-configure#zone-aligned-node-pools) workloads (where each node pool is pinned to a single zone), continue specifying the zone explicitly by using `--zones 1`, `--zones 2`, and so on.

## Prerequisites

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

- A region that supports availability zones. For more information, see the [List of Azure regions](/en-us/azure/reliability/regions-list).
- The `aks-preview` CLI extension version 22.0.0b4 or later. If you don't have it, see Install the `aks-preview` CLI extension.
- The `VmssAutomaticZonePlacement` feature flag registered in your subscription. If you haven't registered it, see Register the `VmssAutomaticZonePlacement` feature flag.

## Install the `aks-preview` CLI extension

Install the aks-preview CLI extension by using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

```azurecli
az extension add --name aks-preview
```

Update the extension to ensure you have the latest version installed by using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

```azurecli
az extension update --name aks-preview
```

## Register the `VmssAutomaticZonePlacement` feature flag

Register the feature flag by using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command:

```azurecli
az feature register \
  --namespace Microsoft.Compute \
  --name VmssAutomaticZonePlacement
```

Check the registration status by using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command:

```azurecli
az feature show \
  --namespace Microsoft.Compute \
  --name VmssAutomaticZonePlacement \
  --query properties.state \
  --output tsv
```

Wait until the command returns `Registered` before you continue.

## Create an AKS cluster with automatic zone placement (Preview)

Create a new AKS cluster with a Virtual Machine Scale Sets-based or [Virtual Machines-based](virtual-machines-node-pools) system node pool that uses automatic zone placement by using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with `--zones auto`:

```azurecli
az aks create \
  --resource-group example-rg \
  --name example-cluster \
  --node-vm-size Standard_D8s_v5 \
  --node-count 10 \
  --zones auto
```

AKS picks the zones that have capacity for `Standard_D8s_v5` in the target region and spreads the 10 nodes across them, with no single zone holding more than 50% of the nodes.

## Add a node pool with automatic zone placement (Preview)

Add a new Virtual Machine Scale Sets-based or [Virtual Machines-based](virtual-machines-node-pools) node pool to an existing cluster by using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with `--zones auto`:

```azurecli
az aks nodepool add \
  --resource-group example-rg \
  --cluster-name example-cluster \
  --name userpoolauto \
  --node-vm-size Standard_D8s_v5 \
  --node-count 6 \
  --zones auto
```

## Update an existing node pool to use automatic zone placement (Preview)

Update an existing Virtual Machine Scale Sets-based or [Virtual Machines-based](virtual-machines-node-pools) node pool to use automatic zone placement by using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with `--zones auto`:

```azurecli
az aks nodepool update \
  --resource-group example-rg \
  --cluster-name example-cluster \
  --name nodepool1 \
  --zones auto
```

AKS updates the existing node pool through a rolling operation:

1. AKS adds surge nodes that use automatic zone placement.
2. AKS cordons and drains the existing nodes.
3. AKS removes the existing nodes after their workloads move to the surge nodes.

The operation honors the following upgrade settings that you configure on the node pool:

- **Max surge (`--max-surge`)**: Controls how many extra nodes AKS adds during the update. A higher value completes the update faster but requires more compute quota and subnet IP capacity.
- **Node drain timeout (`--drain-timeout`)**: Controls how long AKS waits for pod eviction on a node before the drain operation fails.
- **Node soak duration (`--node-soak-duration`)**: Controls how long AKS waits after a new node becomes ready before continuing to the next batch.

Before you start the update, make sure that you have enough compute quota and subnet IP capacity for the surge nodes and that your pod disruption budgets allow nodes to drain.

## Verify zone placement

After creating or updating the cluster or node pool, verify the zones that AKS selected by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

```azurecli
az aks show \
 --name example-cluster \
 --resource-group example-rg \
 --query agentPoolProfiles[].availabilityZones \
 --output tsv
```

You can also use `kubectl` to confirm node distribution across zones.

```bash
kubectl get nodes -o custom-columns='NAME:metadata.name, REGION:metadata.labels.topology\.kubernetes\.io/region, ZONE:metadata.labels.topology\.kubernetes\.io/zone'
```

Example output:

```output
NAME                                REGION   ZONE
aks-nodepool1-12345678-vmss000000   eastus   eastus-1
aks-nodepool1-12345678-vmss000001   eastus   eastus-2
aks-nodepool1-12345678-vmss000002   eastus   eastus-3
...
```