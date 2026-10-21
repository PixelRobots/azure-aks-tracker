---
layout: Conceptual
title: Use Virtual Machines Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/virtual-machines-node-pools
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
description: Learn how to add multiple Virtual Machine types of a similar family to a Virtual Machines node pool in an AKS cluster.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2026-07-28T00:00:00.0000000Z
ms.author: wilsondarko
author: wdarko1
locale: en-us
document_id: b0816ba3-7445-edd0-7751-65296e400eb7
document_version_independent_id: 5b8d05eb-273f-e369-a3f5-4c739008b3e3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/virtual-machines-node-pools.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/virtual-machines-node-pools
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/virtual-machines-node-pools.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ed4bf53b-802f-cb77-3c46-974d52fa46a5
---

# Use Virtual Machines Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you'll learn about the new Virtual Machines node pool type for AKS.

With Virtual Machines node pools, AKS directly manages the provisioning and bootstrapping of every single node. For Virtual Machine Scale Sets node pools, AKS manages the model of the Virtual Machine Scale Sets and uses it to achieve consistency across all nodes in the node pool. Virtual Machines node pools enable you to orchestrate your cluster with virtual machines that best fit your individual workloads.

By using virtual machines node pools, AKS directly manages the provisioning and bootstrapping of every single node. For virtual machine scale sets node pools, AKS manages the model of the virtual machine scale sets and uses it to achieve consistency across all nodes in the node pool. Virtual machines node pools enable you to orchestrate your cluster with virtual machines that best fit your individual workloads.

## Virtual machines node pool overview

### How it works

A node pool consists of a set of virtual machines (VMs), where different virtual machine sizes support different types of workloads. These virtual machine sizes, referred to as SKUs, are categorized into different families that are optimized for specific purposes. For more information, see [VM SKUs documentation](/en-us/azure/virtual-machines/sizes/overview). By using virtual machines node pools, you can perform multi-SKU manual scaling and multi-SKU autoscaling.

To enable scaling of multiple virtual machine sizes, the Virtual Machines node pool type uses a `ScaleProfile` that contains configurations indicating how the node pool can scale, specifically the desired list of virtual machine size and the count of each size. A `ManualScaleProfile` is a scale profile that specifies one desired virtual machine size and the total count of that type in the node pool. Only one virtual machine size is allowed in a `ManualScaleProfile`. You need to create a separate `ManualScaleProfile` for each virtual machine size in your node pool. When creating a new Virtual Machines node pool, you add an initial manual scale profile for a virtual machine size using the `vm-size` field and including a `node-count`. You can also add more manual scale profiles following the instructions for [adding manual scale profiles](/en-us/azure/aks/virtual-machines-node-pools#add-a-manual-scale-profile-to-a-node-pool).

To enable scaling of multiple virtual machine sizes, the virtual machines node pool type uses a `ScaleProfile` that contains configurations indicating how the node pool can scale, specifically the desired list of virtual machine size and the count of each size. A `ManualScaleProfile` is a scale profile that specifies one desired virtual machine size and the total count of that type in the node pool. A `ManualScaleProfile` supports only one virtual machine size. You need to create a separate `ManualScaleProfile` for each virtual machine size in your node pool. When creating a new virtual machines node pool, add an initial manual scale profile for a virtual machine size by using the `vm-size` field and including a `node-count`. You can also add more manual scale profiles by following the instructions for [adding manual scale profiles](/en-us/azure/aks/virtual-machines-node-pools#add-a-manual-scale-profile-to-a-node-pool).

Virtual machines node pools also support `Auto` mode, which means the node pool can use [cluster autoscaler](cluster-autoscaler-overview). A virtual machines node pool supports up to five scale profiles total across manual and autoscale modes. Each profile specifies one same-family VM SKU. Each `AutoScaleProfile` can have its own minimum and maximum node count in the node pool.

Note

When creating a new Virtual Machines node pool, you can have multiple scale profiles, and you need at least one manual or auto scale profile in your node pool.

## Advantages of virtual machines node pools

Advantages of the Virtual Machines node pool type include:

- **Flexibility**: Node specifications can be updated to adapt to your current workload and needs.
- **Fine-tuned control**: Single node-level controls allow specifying and mixing nodes of different specs to lift restrictions from a single model and improve consistency.
- **Efficiency**: You can reduce the node footprint for your cluster, simplifying your operational requirements.

Virtual machines node pools support up to five scale profiles per node pool, so workloads can use multiple same-family VM SKUs without requiring a separate node pool for each SKU.

## Compare AKS compute scaling experiences

The following table highlights how Virtual Machines node pools compare with standard [Scale Set](/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-orchestration-modes) node pools.

| Node pool type | Scaling and node management capabilities |
| --- | --- |
| Virtual Machines node pool | You can add, remove, or update nodes in a node pool. Virtual machine types can be any virtual machine of the same family type (for example, D-series, A-Series, and so on). Virtual Machines node pools also allow for multiversion manual and auto scaling. |
| Virtual Machine Scale Set based node pool | You can add or remove nodes of the same size and type in a node pool. If you add a new virtual machine size to the cluster, you need to create a new node pool. |

### Which compute scaling experience should I choose on AKS?

Depending on your workload needs, there are multiple compute scaling experiences to consider. See the use cases for each:

- [Node auto provisioning](node-auto-provisioning): best for multiversion autoscaling, and more intelligent, flexible VM version selection (including multiple version families).
- Virtual Machines node pools: best for multiversion manual scaling and supports multiversion autoscaling. Requires specific version selection of up to five sizes per node pool.
- [Virtual Machine Scale Sets](/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-orchestration-modes): supports single-version manual scaling and single-version autoscaling. Requires specific version selection of one size per node pool.

## Virtual Machines node pool limitations

- VM Sizes specified in the pool must be of the same type. For example, GPU and non-GPU or x86 and ARM64 virtual machines cannot be in the same node pool.
- [InifiniBand](/en-us/azure/virtual-machines/extensions/enable-infiniband) isn't available.
- [Node pool snapshot](node-pool-snapshot) isn't supported.
- All VM sizes selected in a node pool need to be from a similar virtual machine family. For example, you can't mix an N-Series virtual machine type with a D-Series virtual machine type in the same node pool.
- You need to select all VM sizes in a node pool that support the same ephemeral OS disk placement when you use ephemeral OS disks. Because `DiffDiskPlacement` is a single pool-level value, AKS can't express different placements per VM size in one node pool.
- Virtual Machines node pools allow up to five scale profiles total per node pool. Each manual or autoscale profile specifies one VM size from the same VM family.
- Windows node pools aren't supported.

### Ephemeral OS disk placement compatibility

When you add a scale profile that mixes VM sizes with different ephemeral OS disk placements, the create or update operation fails with an `InvalidParameter` error and the subcode `EphemeralOSMixedPlacementNotSupported`.

Use one of the following remediation options:

- Use VM sizes that share the same ephemeral OS disk placement.
- Split VM sizes into separate node pools so each pool has one placement.
- Use managed OS disks instead of ephemeral OS disks.

#### Determine placement before you add a scale profile

Before you add a VM size to a Virtual Machines node pool, check SKU capabilities in the target region and verify ephemeral OS disk placement compatibility.

1. List candidate VM sizes and inspect key capabilities:

    ```azurecli
    az vm list-skus \
        --location <region> \
        --size Standard_D \
        --resource-type virtualMachines \
        --query "[].{name:name, capabilities:capabilities[?name=='EphemeralOSDiskSupported' || name=='MaxResourceVolumeMB' || name=='NvmeDiskSizeInMiB']}" \
        --output json
    ```
2. Confirm each selected VM size supports ephemeral OS disks (`EphemeralOSDiskSupported`) and identify where local disk is available (`MaxResourceVolumeMB` for temp/resource disk and `NvmeDiskSizeInMiB` for NVMe).
3. Group VM sizes so each Virtual Machines node pool uses a single compatible placement.

For example, if one profile uses `Standard_D4ds_v5` (temp/resource disk placement) and another profile uses `Standard_D4ads_v6` (NVMe placement), keep them in separate node pools or use managed OS disks.

Important

**Preflight and what-if behavior** No dedicated preflight API currently validates mixed ephemeral OS disk placement across scale profiles before deployment. `az deployment group what-if` (ARM what-if) doesn't guarantee detection of this node-pool compatibility conflict. The authoritative check occurs when AKS processes the create or update request and returns `EphemeralOSMixedPlacementNotSupported` if placements are incompatible.

## Prerequisites

- An Azure subscription. If you don't have one, you can [create a free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Azure CLI version 2.85.0 or later installed and configured. To find the version, run `az --version`. For more information about installing or upgrading the Azure CLI, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli#install-azure-cli).
- This feature requires Kubernetes version 1.27 or greater. To upgrade your Kubernetes version, see [Upgrade AKS cluster](tutorial-kubernetes-upgrade-cluster).

Important

**Custom virtual network requirement**: If you deploy a Virtual Machines node pool into a custom virtual network, the cluster must use a [user-assigned managed identity](managed-identity-overview) with at least [Network Contributor](/en-us/azure/role-based-access-control/built-in-roles#network-contributor) permissions on the target subnet. Unlike Virtual Machine Scale Set node pools, Virtual Machines node pools rely solely on the cluster identity for subnet join operations and don't use first-party tokens. Clusters that use a system-assigned managed identity fail preflight validation when creating or updating a Virtual Machines node pool on a custom virtual network, returning an `InvalidParameter` error. For more information on configuring a user-assigned managed identity for your cluster, see [Use a managed identity in AKS](managed-identity-overview).

## Create an AKS cluster with Virtual Machines node pools

Note

Only *one* VM size is allowed in a scale profile, and the maximum limit is *five* VM scale profiles overall for a Virtual Machines node pool.

Create an AKS cluster with Virtual Machines node pools using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--vm-set-type` flag set to `"VirtualMachines"`.

The following example creates a cluster named *myAKSCluster* with a Virtual Machines node pool containing two nodes:

```azurecli
az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --vm-set-type "VirtualMachines" \
    --vm-sizes "Standard_D4s_v3" \
    --node-count 2
```

## Create an AKS cluster with Virtual Machines node pools in a custom virtual network

When you deploy Virtual Machines node pools into a custom virtual network, you must create a user-assigned managed identity and grant it Network Contributor permissions on the target subnet before you create the cluster.

1. Create a virtual network and subnet.

    ```azurecli
    az network vnet create \
        --resource-group myResourceGroup \
        --name myVnet \
        --address-prefixes 10.1.0.0/16 \
        --subnet-name mySubnet \
        --subnet-prefix 10.1.0.0/24
    ```
2. Get the subnet resource ID.

    ```azurecli
    SUBNET_ID=$(az network vnet subnet show \
        --resource-group myResourceGroup \
        --vnet-name myVnet \
        --name mySubnet \
        --query id \
        --output tsv)
    ```
3. Create a user-assigned managed identity.

    ```azurecli
    az identity create \
        --name myAKSIdentity \
        --resource-group myResourceGroup
    ```
4. Get the principal ID and resource ID of the managed identity.

    ```azurecli
    IDENTITY_PRINCIPAL_ID=$(az identity show \
        --name myAKSIdentity \
        --resource-group myResourceGroup \
        --query principalId \
        --output tsv)
    
    IDENTITY_RESOURCE_ID=$(az identity show \
        --name myAKSIdentity \
        --resource-group myResourceGroup \
        --query id \
        --output tsv)
    ```
5. Assign the Network Contributor role to the managed identity on the target subnet.

    ```azurecli
    az role assignment create \
        --assignee $IDENTITY_PRINCIPAL_ID \
        --role "Network Contributor" \
        --scope $SUBNET_ID
    ```

    It can take up to 60 minutes to propagate the permissions granted to your cluster's managed identity.
6. Verify that the role assignment exists on the target subnet before you create the cluster.

    ```azurecli
    az role assignment list \
        --assignee $IDENTITY_PRINCIPAL_ID \
        --role "Network Contributor" \
        --scope $SUBNET_ID \
        --query "[].{Role:roleDefinitionName, Scope:scope}" \
        --output table
    ```

    Continue when the output shows the Network Contributor role at the target subnet scope.
7. Create the AKS cluster with Virtual Machines node pools in your custom virtual network.

    ```azurecli
    az aks create \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --vm-set-type "VirtualMachines" \
        --vm-sizes "Standard_D4s_v3" \
        --node-count 2 \
        --vnet-subnet-id $SUBNET_ID \
        --assign-identity $IDENTITY_RESOURCE_ID
    ```

## Add a Virtual Machines node pool to an existing cluster

Add a Virtual Machines node pool to an existing cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--vm-set-type` flag set to `"VirtualMachines"`.

The following example adds a Virtual Machines node pool named *myvmpool* to the *myAKSCluster* cluster. The node pool creates a ManualScaleProfile with `--vm-sizes` set to `Standard_D4s_v3` and a `--node-count` of 3:

```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myvmpool \
    --vm-set-type "VirtualMachines" \
    --vm-sizes "Standard_D4s_v3" \
    --node-count 3
```

## Add a manual scale profile to a node pool

Add a manual scale profile to a node pool using the [`az aks nodepool manual-scale add`](/en-us/cli/azure/aks/nodepool/manual-scale#az-aks-nodepool-manual-scale-add) with the `--vm-sizes` flag set to `"Standard_D2s_v3"` and the `node-count` set to 2.

The following example adds a manual scale profile to node pool *myvmpool* in cluster *myAKSCluster*. The node pool includes two nodes with a VM SKU of `Standard_D2s_v3`:

```azurecli
az aks nodepool manual-scale add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myvmpool \
    --vm-sizes "Standard_D2s_v3" \
    --node-count 2
```

## Update an existing manual scale profile

Update an existing manual scale profile in a node pool using the [`az aks nodepool manual-scale update`](/en-us/cli/azure/aks/nodepool/manual-scale#az-aks-nodepool-manual-scale-update) command with the `--vm-sizes` flag set to `"Standard_D2s_v3"`.

Note

Use the `--current-vm-sizes` parameter to specify the size of the existing node pool that you want to update. You can update `--vm-sizes` and/or `--node-count`. When using other tools or REST APIs, you need to pass in a full `agentPoolProfiles.virtualMachinesProfile.scale` field when updating the node pool scale profile.

The following example updates a manual scale profile to the *myvmpool* node pool in the *myAKSCluster* cluster. The command updates the number of nodes to five and changes the VM SKU from `Standard_D4s_v3` to `Standard_D8s_v3`:

```azurecli
az aks nodepool manual-scale update \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myvmpool \
    --current-vm-sizes "Standard_D4s_v3" \
    --vm-sizes "Standard_D8s_v3" \
    --node-count 5
```

## Delete a manual scale profile

Delete an existing manual scale profile using the [`az aks nodepool manual-scale delete`](/en-us/cli/azure/aks/nodepool/manual-scale#az-aks-nodepool-manual-scale-delete) command.

Note

The `--current-vm-sizes` parameter specifies the size of the existing node pool to be deleted. When using other tools or REST APIs to update the node pool scale profile, pass in a full `agentPoolProfiles.virtualMachinesProfile.scale` field.

The following example deletes the manual scale profile for the `Standard_D8s_v3` VM SKU in the *myvmpool* node pool.

```azurecli
az aks nodepool manual-scale delete \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myvmpool \
    --current-vm-sizes "Standard_D8s_v3"
```

## Cluster autoscaler with Virtual Machines Node Pools

Virtual Machines node pools support [cluster autoscaler](cluster-autoscaler-overview). This support allows autoscaling for both same VM size node pools and multiple VM size node pools. You can enable this feature by using the flag `--enable-cluster-autoscaler` during cluster creation, while adding a new node pool, or when updating an existing manual node pool.

When using cluster autoscaler with Virtual Machine node pools, the behavior is as follows:

- Scale up: autoscaler responds to pending pod pressure, and can scale up the node count of a node pool with multiple VM sizes in that node pool.
- Scale down: autoscaler chooses a specific node based on the utilization of the node. You can configure `scale-down-utilization-threshold` to adjust when cluster autoscaling triggers a scaling action. See [cluster autoscaler documentation](cluster-autoscaler-overview) for more information on configuring autoscaling.

### Limitations

- This feature is only available in public cloud.
- GPU nodes aren't currently supported.

## Create an AKS cluster with Virtual Machines node pools and cluster autoscaler enabled

- Create an AKS cluster with Virtual Machines node pools using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--vm-set-type` flag set to `"VirtualMachines"` and with the flag `--enable-cluster-autoscaler`.

The following example creates a cluster named *myAKSCluster* with a Virtual Machines node pool that uses the node size `Standard_D4s_v3`, a minimum node count of 2, and a maximum node count of 5:

```azurecli
az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --vm-set-type "VirtualMachines" \
    --node-vm-size "Standard_D4s_v3" \
    --enable-cluster-autoscaler \
    --min-count 2 \
    --max-count 5
```

## Add a Virtual Machines node pool with cluster autoscaler enabled to an existing cluster

- Create a Virtual Machines node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--vm-set-type` flag set to `"VirtualMachines"` and with the flag `--enable-cluster-autoscaler`.

The following example adds Virtual Machines node pool *myvmpool* with cluster autoscaler enabled to a cluster named *myAKSCluster* using virtual machine size of "Standard\_D4s\_v3", and a minimum node count of 2 and max count of 5:

```azurecli
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myvmpool \
    --vm-set-type "VirtualMachines" \
    --node-vm-size "Standard_D4s_v3" \
    --enable-cluster-autoscaler \
    --min-count 2 \
    --max-count 5
```

## Update cluster autoscaler settings for a Virtual Machines node pool

- Update the [cluster autoscaler](cluster-autoscaler-overview) node count settings for a Virtual Machines node pool using the [`az aks nodepool auto-scale update`](/en-us/cli/azure/aks/nodepool/auto-scale#az-aks-nodepool-auto-scale-update) command.

The following example updates settings for Virtual Machines node pool *myvmpool* in cluster named *myAKSCluster* using virtual machine size of "Standard\_D4s\_v3":

```azurecli
az aks nodepool auto-scale update \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myvmpool \
    --current-node-vm-size "Standard_D4s_v3" \
    --min-count 3 \
    --max-count 7
```

## Switch Virtual Machines node pool scale profiles from manual to autoscale mode

The following example updates Virtual Machines node pool *myvmpool* in the cluster named *myAKSCluster*, converting all manual scale profiles to autoscale profiles with the same minimum and maximum node count:

```azurecli
az aks nodepool update \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myvmpool \
    --enable-cluster-autoscaler \
    --min-count 2 \
    --max-count 5
```

## Disable cluster autoscaler in a Virtual Machines node pool

You can disable [cluster autoscaler](cluster-autoscaler-overview), or switch all the scale profiles in a virtual machine node pool from `Auto` mode to `Manual` mode.

The following example disables the cluster autoscaler for the Virtual Machines node pool *myvmpool* in the cluster named *myAKSCluster*. It switches all scale profiles from `Auto` mode to `Manual` mode:

```azurecli
az aks nodepool update \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name myvmpool \
    --disable-cluster-autoscaler
```