---
layout: Conceptual
title: Resize Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/resize-node-pool
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
description: Learn how to resize node pools for a cluster in Azure Kubernetes Service (AKS) by cordoning and draining.
ms.topic: how-to
ms.date: 2025-08-28T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-nodes
locale: en-us
document_id: b762cd85-3ad0-424d-86a0-3a4cc52b559e
document_version_independent_id: 8f3a2dfe-0619-3b4b-aa96-6a9f5938d690
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/resize-node-pool.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/resize-node-pool
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/resize-node-pool.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: bd2eaf52-7893-436a-7633-56a18cbc75f3
---

# Resize Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

You might want to change the size of your virtual machines (VMs) to accommodate an increasing number of deployments or to run a larger workload. Resizing AKS instances directly isn't supported when using [Virtual Machine Scale Sets](/en-us/azure/virtual-machine-scale-sets/overview) in AKS, as outlined in the [support policies for AKS](support-policies#user-customization-of-agent-nodes):

> 
> AKS agent nodes appear in the Azure portal as regular Azure IaaS resources. But these virtual machines are deployed into a custom Azure resource group (usually prefixed with MC\_\*). You can't make direct customizations to these nodes using the IaaS APIs or resources. Any custom changes that aren't done via the AKS API won't persist through an upgrade, scale, update, or reboot.

In this article, you learn the recommended method to resize a node pool by creating a new node pool with the desired SKU size, cordoning and draining the existing nodes, and then removing the existing node pool.

Important

This method is specific to [Virtual Machine Scale Sets](/en-us/azure/virtual-machine-scale-sets/overview)-based AKS clusters. When using Virtual Machines-based node pools, you can easily update the VM sizes in an existing node pool using a single Azure CLI command and have multiple VM sizes in the same node pool. For more information, see the [Virtual Machines node pools documentation](virtual-machines-node-pools).

## Resize a VMSS node pool in place (preview)

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

You can now resize the VM size (SKU) of an existing VMSS-based node pool in a single command using `az aks nodepool update --node-vm-size <new-size>`. When you trigger this update, the AKS resource provider performs a rolling upgrade by:

1. Surging new nodes with the target VM size.
2. Cordoning and draining the old nodes.
3. Deleting the old nodes.

This avoids the manual create/cordon/drain/delete workflow described in the rest of this article.

### How the resize rollout works

The resize rollout uses the same rolling upgrade engine as a [node image upgrade](upgrade-node-image) and a [Kubernetes version upgrade](upgrade-aks-node-pools-rolling), so it honors the following upgrade-related settings already configured on the node pool. In particular, the resize respects:

- [**Max surge** (`--max-surge`)](upgrade-aks-node-pools-rolling#customize-node-surge): Controls how many extra nodes with the target VM size are added during the rollout. A higher value resizes the pool faster but consumes more compute and IP quota; a lower value is slower but less disruptive. The AKS default is `1`, and `33%` is recommended for production node pools.
- [**Node drain timeout** (`--drain-timeout`)](upgrade-aks-node-pools-rolling#customize-node-drain-timeout): How long AKS waits for pod eviction on each old node before forcefully deleting it. The default is 30 minutes. Combine this with appropriate [PodDisruptionBudgets](operator-best-practices-scheduler#limit-disruption-impact-by-using-pod-disruption-budgets-pdbs) so workloads can drain safely.
- [**Node soak duration** (`--node-soak-duration`)](upgrade-aks-node-pools-rolling#customize-node-soak-time): How long AKS waits after a new node becomes Ready before moving on to the next batch. Useful for letting workloads stabilize on the new VM size before continuing the rollout.

Because resize reuses the upgrade pipeline, the same prerequisites apply: ensure your subscription has enough target VM size replacement capacity and available subnet IPs for surge nodes, and that your PodDisruptionBudgets allow at least one replica to be evicted at a time, otherwise resize can be blocked during drain. For end-to-end recommendations, see [Best practices for AKS node pool upgrades](aks-production-upgrade-strategies).

### Prerequisites

- AKS API version `2026-01-02-preview` or later.
- The latest version of the [aks-preview Azure CLI extension](/en-us/cli/azure/azure-cli-extensions-list).

### Resize the node pool

Use the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with the `--node-vm-size` parameter to change the VM size of an existing VMSS-based node pool:

```azurecli
az aks nodepool update \
    --resource-group MyResourceGroup \
    --cluster-name MyManagedCluster \
    --name nodepool1 \
    --node-vm-size Standard_D4s_v3
```

### Validation and unsupported combinations

The AKS resource provider validates the resize request and blocks incompatible VM size changes. The following changes are **not supported** as part of an in-place VMSS resize:

- Changing the **disk controller type** (for example, SCSI to NVMe).
- Changing the **CPU architecture** (for example, x64 to ARM64).
- Changing **confidential computing** support (for example, enabling or disabling SNP).
- Changing the **hypervisor generation** (for example, V1 to V2).
- Combining the resize with a **Kubernetes version upgrade** or a **node count change** in the same operation.

If your target VM size requires any of the changes above, use the manual cordon-and-drain workflow described in the following sections instead.

Note

In-place resize requires surge capacity to provision new nodes with the target VM size before draining the old ones. If the node pool is configured with `--max-surge 0` (that is, `--max-unavailable` is in effect), the resize request is rejected with a `400 Bad Request`. To proceed, set `--max-surge` to at least `1` when resize using

```azurecli
az aks nodepool update \
    --resource-group MyResourceGroup \
    --cluster-name MyManagedCluster \
    --name nodepool1 \
    --node-vm-size Standard_D4s_v3 \
    --max-surge 33%
```

and optionally restore your original `--max-surge` and `--max-unavailable` values after the resize completes.

## Create a new node pool with the desired SKU

Note

Every AKS cluster must contain at least one system node pool with at least one node. In this example, we use a `--mode` of `System` to add a system node pool to replace the system node pool we want to resize. You can [update the mode of a node pool](use-system-pools#update-existing-cluster-system-and-user-node-pools) at any time. You can also add a user node pool by setting `--mode` to `User`.

# [Azure CLI](#tab/azure-cli)
When resizing, make sure you consider all workload requirements, such as availability zones, and configure your VMSS node pool accordingly. You might need to modify the following command to best fit your needs. For a full list of the configuration options, see the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) reference page.

1. Create a new node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. In this example, we create a new node pool, `mynodepool`, with three nodes and the `Standard_DS3_v2` VM SKU to replace an existing node pool, `nodepool1`, that has the `Standard_DS2_v2` VM SKU.

    ```azurecli
    az aks nodepool add \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name mynodepool \
        --node-count 3 \
        --node-vm-size Standard_DS3_v2 \
        --mode System \
        --no-wait
    ```

    It takes a few minutes for the new node pool to be created.
2. Get the status of the new node pool using the `kubectl get nodes` command.

    ```bash
    kubectl get nodes
    ```

    Your output should resemble the following example output, showing both the new node pool `mynodepool` and the existing node pool `nodepool1`:

    ```output
    NAME                                 STATUS   ROLES   AGE   VERSION
    aks-mynodepool-98765432-vmss000000   Ready    agent   23m   v1.21.9
    aks-mynodepool-98765432-vmss000001   Ready    agent   23m   v1.21.9
    aks-mynodepool-98765432-vmss000002   Ready    agent   23m   v1.21.9
    aks-nodepool1-12345678-vmss000000    Ready    agent   10d   v1.21.9
    aks-nodepool1-12345678-vmss000001    Ready    agent   10d   v1.21.9
    aks-nodepool1-12345678-vmss000002    Ready    agent   10d   v1.21.9
    ```

# [Azure PowerShell](#tab/azure-powershell)
When resizing, make sure you consider all workload requirements, such as availability zones, and configure your VMSS node pool accordingly. You might need to modify the following command to best fit your needs. For a full list of the configuration options, see the [`New-AzAksNodePool`](/en-us/powershell/module/az.aks/new-azaksnodepool) reference page.

1. Create a new node pool using the [`New-AzAksNodePool`](/en-us/powershell/module/az.aks/new-azaksnodepool) cmdlet. In this example, we create a new node pool, `mynodepool`, with three nodes and the `Standard_DS3_v2` VM SKU to replace an existing node pool, `nodepool1`, that has the `Standard_DS2_v2` VM SKU.

    ```azurepowershell
    $params = @{
        ResourceGroupName = 'myResourceGroup'
        ClusterName       = 'myAKSCluster'
        Name              = 'mynodepool'
        Count             = 3
        VMSize            = 'Standard_DS3_v2'
    }
    New-AzAksNodePool @params
    ```

    It takes a few minutes for the new node pool to be created.
2. Get the status of the new node pool using the `kubectl get nodes` command.

    ```bash
    kubectl get nodes
    ```

    Your output should resemble the following example output, showing both the new node pool `mynodepool` and the existing node pool `nodepool1`:

    ```output
    NAME                                 STATUS   ROLES   AGE   VERSION
    aks-mynodepool-98765432-vmss000000   Ready    agent   23m   v1.21.9
    aks-mynodepool-98765432-vmss000001   Ready    agent   23m   v1.21.9
    aks-mynodepool-98765432-vmss000002   Ready    agent   23m   v1.21.9
    aks-nodepool1-12345678-vmss000000    Ready    agent   10d   v1.21.9
    aks-nodepool1-12345678-vmss000001    Ready    agent   10d   v1.21.9
    aks-nodepool1-12345678-vmss000002    Ready    agent   10d   v1.21.9
    ```

---

## Cordon the existing nodes

Cordoning marks specified nodes as unschedulable and prevents any more pods from being added to the nodes.

1. Get the names of the nodes you want to cordon using the `kubectl get nodes` command.

    ```bash
    kubectl get nodes
    ```

    Your output should resemble the following example output, showing the nodes in the existing node pool `nodepool1` that you want to cordon:

    ```output
    NAME                                STATUS   ROLES   AGE     VERSION
    aks-nodepool1-12345678-vmss000000   Ready    agent   7d21h   v1.21.9
    aks-nodepool1-12345678-vmss000001   Ready    agent   7d21h   v1.21.9
    aks-nodepool1-12345678-vmss000002   Ready    agent   7d21h   v1.21.9
    ```
2. Cordon the existing nodes using the `kubectl cordon` command, specifying the desired nodes in a space-separated list. For example:

    ```bash
    kubectl cordon aks-nodepool1-12345678-vmss000000 aks-nodepool1-12345678-vmss000001 aks-nodepool1-12345678-vmss000002
    ```

    Your output should resemble the following example output, showing that the nodes are cordoned:

    ```output
    node/aks-nodepool1-12345678-vmss000000 cordoned
    node/aks-nodepool1-12345678-vmss000001 cordoned
    node/aks-nodepool1-12345678-vmss000002 cordoned
    ```

## Drain the existing nodes

Important

To successfully drain nodes and evict running pods, ensure that any PodDisruptionBudgets (PDBs) allow for at least one pod replica to be moved at a time. Otherwise, the drain/evict operation fails. To check this, you can run `kubectl get pdb -A` and verify `ALLOWED DISRUPTIONS` is at least `1` or higher.

When you drain nodes, the pods running on them are evicted and recreated on the other schedulable nodes.

1. Drain the existing nodes using the `kubectl drain` command with the `--ignore-daemonsets` and `--delete-emptydir-data` flags, specifying the desired nodes in a space-separated list. For example:

    Important

    Using `--delete-emptydir-data` is required to evict the AKS-created `coredns` and `metrics-server` pods. If you don't use this flag, you get an error. For more information, see the [documentation on emptydir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir).

    ```bash
    kubectl drain aks-nodepool1-12345678-vmss000000 aks-nodepool1-12345678-vmss000001 aks-nodepool1-12345678-vmss000002 --ignore-daemonsets --delete-emptydir-data
    ```
2. After the drain operation finishes, all pods (excluding the pods controlled by daemon sets) should be running on the new node pool. You can verify this using the `kubectl get pods` command.

    ```bash
    kubectl get pods -o wide -A
    ```

### Troubleshoot pod eviction issues

You might encounter the following error when draining nodes:

> 
> `Error when evicting pods/[podname] -n [namespace] (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.`

By default, your cluster has AKS-managed pod disruption budgets (such as `coredns-pdb` or `konnectivity-agent`) with a `MinAvailable` of `1`. For example, if there are two `coredns` pods running, only one can be disrupted at a time. While one of them is getting recreated and is unavailable, the other `coredns` pod can't be evicted due to the pod disruption budget. This issue resolves itself after the initial `coredns` pod is scheduled and running, allowing the second pod to be properly evicted and recreated.

Tip

Consider draining nodes one by one for a smoother eviction experience and to avoid throttling. For more information, see:

- [Plan for availability using a pod disruption budget](operator-best-practices-scheduler#limit-disruption-impact-by-using-pod-disruption-budgets-pdbs)
- [Specify a disruption budget for your application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
- [Disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)

## Remove the existing node pool

Important

When you delete a node pool, AKS doesn't perform cordon and drain. To minimize the disruption of rescheduling pods currently running on the node pool you plan to delete, perform a cordon and drain on all nodes in the node pool before deleting.

# [Azure CLI](#tab/azure-cli)
1. Delete the original node pool using the [`az aks nodepool delete`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-delete) command.

    ```azurecli
    az aks nodepool delete \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name nodepool1
    ```
2. Verify that your AKS cluster has only the new node pool with the applications and pods properly running using the `kubectl get nodes` command.

    ```bash
    kubectl get nodes
    ```

    Your output should resemble the following example output, showing only the new node pool `mynodepool`:

    ```output
    NAME                                 STATUS   ROLES   AGE   VERSION
    aks-mynodepool-98765432-vmss000000   Ready    agent   63m   v1.21.9
    aks-mynodepool-98765432-vmss000001   Ready    agent   63m   v1.21.9
    aks-mynodepool-98765432-vmss000002   Ready    agent   63m   v1.21.9
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. Delete the original node pool using the [`Remove-AzAksNodePool`](/en-us/powershell/module/az.aks/remove-azaksnodepool) cmdlet.

    ```azurepowershell
    $params = @{
        ResourceGroupName = 'myResourceGroup'
        ClusterName       = 'myAKSCluster'
        Name              = 'nodepool1'
        Force             = $true
    }
    Remove-AzAksNodePool @params
    ```
2. Verify that your AKS cluster has only the new node pool with the applications and pods properly running using the `kubectl get nodes` command.

    ```bash
    kubectl get nodes
    ```

    Your output should resemble the following example output, showing only the new node pool `mynodepool`:

    ```output
    NAME                                 STATUS   ROLES   AGE   VERSION
    aks-mynodepool-98765432-vmss000000   Ready    agent   63m   v1.21.9
    aks-mynodepool-98765432-vmss000001   Ready    agent   63m   v1.21.9
    aks-mynodepool-98765432-vmss000002   Ready    agent   63m   v1.21.9
    ```

---