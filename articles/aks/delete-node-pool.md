---
layout: Conceptual
title: Delete an Azure Kubernetes Service (AKS) node pool - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/delete-node-pool
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
description: Learn about deleting a node pool from your Azure Kubernetes Service (AKS) cluster.
ms.topic: how-to
ms.author: alvinli
author: alvinli
ms.date: 2024-05-09T00:00:00.0000000Z
locale: en-us
document_id: 199df19d-7836-c0a6-fe8f-c26ff8bcec8c
document_version_independent_id: 18805526-43fa-7532-5806-b652f570e154
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/delete-node-pool.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/delete-node-pool
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/delete-node-pool.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 9f5737cc-9063-42e9-40f0-4a7a337c432a
---

# Delete an Azure Kubernetes Service (AKS) node pool - Azure Kubernetes Service | Microsoft Learn

This article outlines node pool deletion in Azure Kubernetes Service (AKS), including what happens when you delete a node pool and how to delete a node pool.

## What happens when you delete a node pool?

When you delete a node pool, the following resources are deleted:

- The virtual machine scale set (VMSS) and virtual machines (VMs) for each node in the node pool
- Any node instances in the node pool along with any pods running on those nodes

## Delete a node pool

Important

Keep the following information in mind when deleting a node pool:

- **You can't recover a node pool after it's deleted**. You need to create a new node pool and redeploy your applications.

# [Azure CLI](#tab/azure-cli)
Delete a node pool using the [`az aks nodepool delete`](/en-us/cli/azure/aks#az-aks-nodepool-delete) command.

```azurecli
az aks nodepool delete \
    --resource-group <resource-group-name> \
    --cluster-name <cluster-name> \
    --name <node-pool-name>
```

# [Azure PowerShell](#tab/azure-powershell)
Delete a node pool using the [`Remove-AzAksNodePool`](/en-us/powershell/module/az.aks/remove-azaksnodepool) cmdlet.

```azurepowershell
$params = @{
    ResourceGroupName = '<resource-group-name>'
    ClusterName       = '<cluster-name>'
    Name              = '<node-pool-name>'
}
Remove-AzAksNodePool @params
```

# [Azure portal](#tab/azure-portal)
To delete a node pool in Azure portal, navigate to the **Settings &gt; Node pools** page for the cluster and select the name of the node pool you want to delete. On the **Node Pool | Overview** page, you can select **Delete** to delete the node pool.

---

To verify that the node pool was deleted successfully, use the `kubectl get nodes` command to confirm that the nodes in the node pool no longer exist.

## Ignore PodDisruptionBudgets (PDBs) when removing an existing node pool

If your cluster has PodDisruptionBudgets that are preventing the deletion of the node pool, you can ignore the PodDisruptionBudget requirements by setting `--ignore-pdb`. To learn more about PodDisruptionBudgets, see:

- [Plan for availability using a pod disruption budget](operator-best-practices-scheduler#limit-disruption-impact-by-using-pod-disruption-budgets-pdbs)
- [Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
- [Disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)

1. Delete an existing node pool without following any PodDisruptionBudgets set on the cluster using the [`az aks nodepool delete`](/en-us/cli/azure/aks#az-aks-nodepool-delete) command with the `--ignore-pdb` flag:

    ```azurecli
    az aks nodepool delete \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name nodepool1 \
        --ignore-pdb
    ```
2. To verify that the node pool was deleted successfully, use the `kubectl get nodes` command to confirm that the nodes in the node pool no longer exist.

## Remove specific VMs in an existing node pool

Note

When you delete a VM with this command, AKS doesn't perform cordon and drain. To minimize the disruption of rescheduling pods currently running on the VM you plan to delete, perform a cordon and drain on the VM before deleting. You can learn more about how to cordon and drain using the example scenario provided in the resizing node pools tutorial.

1. List the existing nodes using the `kubectl get nodes` command.

    ```bash
    kubectl get nodes
    ```

    Your output should look similar to the following example output:

    ```output
    NAME                                 STATUS   ROLES   AGE   VERSION
    aks-mynodepool-20823458-vmss000000   Ready    agent   63m   v1.21.9
    aks-mynodepool-20823458-vmss000001   Ready    agent   63m   v1.21.9
    aks-mynodepool-20823458-vmss000002   Ready    agent   63m   v1.21.9
    ```
2. Delete the specified VMs using the [`az aks nodepool delete-machines`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-delete-machines) command. Make sure to replace the placeholders with your own values.

    ```azurecli
    az aks nodepool delete-machines \
        --resource-group <resource-group-name> \
        --cluster-name <cluster-name> \
        --name <node-pool-name> \
        --machine-names <vm-name-1> <vm-name-2>
    ```
3. Verify the VMs were successfully deleted using the `kubectl get nodes` command.

    ```bash
    kubectl get nodes
    ```

    Your output should no longer include the VMs that you specified in the `az aks nodepool delete-machines` command.