---
layout: Conceptual
title: Manually Scale Nodes in an Azure Kubernetes Service (AKS) Cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/scale-cluster
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
description: Manually scale the node count in your Azure Kubernetes Service (AKS) cluster with Azure CLI or PowerShell to match demand and optimize capacity.
ms.topic: how-to
ms.custom: aks-scaling
ms.date: 2026-09-09T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: 0cf1aa7d-0fc9-51a3-1b1b-57e4829f0c98
document_version_independent_id: d33cd9ea-1e17-6319-c5f3-251d93c687da
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/scale-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/scale-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/scale-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 6d4f4578-ddac-1cb3-2ea9-415fe4f693f5
---

# Manually Scale Nodes in an Azure Kubernetes Service (AKS) Cluster - Azure Kubernetes Service | Microsoft Learn

If the resource needs of your applications change, your cluster performance may be impacted due to low capacity on CPU, memory, PID space, or disk sizes. To address these changes, you can manually scale your AKS cluster to run a different number of nodes. When you scale in, nodes are carefully [cordoned and drained](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) to minimize disruption to running applications. When you scale out, AKS waits until nodes are marked **Ready** by the Kubernetes cluster before pods are scheduled on them.

This article describes how to manually increase or decrease the number of nodes in an AKS cluster.

Note

This article applies to AKS Standard clusters. AKS Automatic clusters use [node autoprovisioning](intro-aks-automatic#node-management-scaling-and-cluster-operations) to manage node scaling.

## Before you begin

- Review the [AKS service quotas and limits](quotas-skus-regions#service-quotas-and-limits) to verify your cluster can scale to your desired number of nodes.
- If the cluster autoscaler is enabled on the node pool, you can't manually change the node count. You can either [update the cluster autoscaler minimum and maximum values](cluster-autoscaler#update-the-cluster-autoscaler-settings) or [disable the cluster autoscaler on the node pool](cluster-autoscaler#disable-the-cluster-autoscaler-on-a-node-pool) before manually scaling it.
- Azure Linux 2.0 support ended on November 30, 2025. Beginning March 31, 2026, Azure Linux 2.0 node images were removed, and affected node pools can no longer scale. Migrate to [Azure Linux 3](/en-us/azure/azure-linux/how-to-enable-azure-linux-3) before scaling an Azure Linux 2.0 node pool.
- Node pool names must meet the following requirements:

    | Node pool type | Name requirements |
    | --- | --- |
    | Linux | Between 1-12 lowercase alphanumeric characters. Must begin with a lowercase letter. |
    | Windows | Between 1-6 lowercase alphanumeric characters. Must begin with a lowercase letter. |

## Scale cluster nodes in AKS

Important

Removing nodes from a node pool by using the [`kubectl`](https://kubernetes.io/docs/reference/kubectl/) command isn't supported. This action can create scaling problems with your AKS cluster.

# [Azure CLI](#tab/azure-cli)
1. Get the name, mode, and node count of your node pools by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command. The following example gets the node pool details for the cluster named *myAKSCluster* in the *myResourceGroup* resource group:

    ```azurecli
    az aks show --resource-group myResourceGroup --name myAKSCluster --query "agentPoolProfiles[].{Name:name,Mode:mode,Count:count}" --output table
    ```

    The following example output shows that *nodepool1* is a system node pool with three nodes:

    ```output
    Name       Mode    Count
    ---------  ------  -------
    nodepool1  System  3
    ```
2. Scale the cluster nodes by using the [`az aks scale`](/en-us/cli/azure/aks#az-aks-scale) command. The following example scales *nodepool1* in the cluster named *myAKSCluster* to two nodes:

    ```azurecli
    az aks scale --resource-group myResourceGroup --name myAKSCluster --node-count 2 --nodepool-name nodepool1 --query "agentPoolProfiles[?name=='nodepool1'].{Name:name,Mode:mode,Count:count}" --output table
    ```

    The following example output shows the system node pool successfully scaled to two nodes:

    ```output
    Name       Mode    Count
    ---------  ------  -------
    nodepool1  System  2
    ```

    System node pools must have at least two nodes. For production clusters, use at least three nodes in a system node pool. For more information, see [System and user node pools](use-system-pools#system-and-user-node-pools).

# [Azure PowerShell](#tab/azure-powershell)
1. Get the name, mode, node count, and provisioning state of your node pools by using the [`Get-AzAksCluster`](/en-us/powershell/module/az.aks/get-azakscluster) command. The following example gets the node pool details for the cluster named *myAKSCluster* in the *myResourceGroup* resource group:

    ```azurepowershell
    Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster |
      Select-Object -ExpandProperty AgentPoolProfiles |
      Select-Object Name, Mode, Count, ProvisioningState
    ```

    The following example output shows that *nodepool1* is a system node pool with three nodes:

    ```output
    Name                   : nodepool1
    Mode                   : System
    Count                  : 3
    ProvisioningState      : Succeeded
    ```
2. Scale the cluster nodes by using the [Set-AzAksCluster](/en-us/powershell/module/az.aks/set-azakscluster) command. The `-NodeName` parameter accepts the node pool name. The following example scales *nodepool1* in the cluster named *myAKSCluster* to two nodes:

    ```azurepowershell
    Set-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -NodeCount 2 -NodeName nodepool1 |
      Select-Object -ExpandProperty AgentPoolProfiles |
      Where-Object Name -eq nodepool1 |
      Select-Object Name, Mode, Count, ProvisioningState
    ```

    The following example output shows the system node pool successfully scaled to two nodes:

    ```output
    Name                   : nodepool1
    Mode                   : System
    Count                  : 2
    ProvisioningState      : Succeeded
    ```

    System node pools must have at least two nodes. For production clusters, use at least three nodes in a system node pool. For more information, see [System and user node pools](use-system-pools#system-and-user-node-pools).

---

## Scale user node pools to 0

Unlike system node pools that always require running nodes, user node pools can scale to 0. To learn more about the differences between system and user node pools, see [System and user node pools](use-system-pools).

Important

To scale a user node pool to 0 nodes, disable the cluster autoscaler. For more information, see [Disable the cluster autoscaler on a node pool](cluster-autoscaler#disable-the-cluster-autoscaler-on-a-node-pool).

# [Azure CLI](#tab/azure-cli)
To scale a user node pool to 0, use [az aks nodepool scale](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-scale) instead of the `az aks scale` command used for general node scaling, and set `--node-count` to `0`.

```azurecli
az aks nodepool scale --name <your node pool name> --cluster-name myAKSCluster --resource-group myResourceGroup  --node-count 0
```

You can allow, but not force, autoscaling to zero nodes on autoscaled user node pools by setting the `--min-count` parameter of the [Cluster Autoscaler](cluster-autoscaler) to `0`.

# [Azure PowerShell](#tab/azure-powershell)
To scale a user node pool to 0, use [Update-AzAksNodePool](/en-us/powershell/module/az.aks/update-azaksnodepool) instead of the `Set-AzAksCluster` command used for general node scaling, and set `-NodeCount` to `0`.

```azurepowershell
Update-AzAksNodePool -Name <your node pool name> -ClusterName myAKSCluster -ResourceGroupName myResourceGroup -NodeCount 0
```

You can allow, but not force, autoscaling to zero nodes on autoscaled user node pools by setting the `-MinCount` parameter to `0`:

```azurepowershell
Update-AzAksNodePool -Name <your node pool name> -ClusterName myAKSCluster -ResourceGroupName myResourceGroup -EnableAutoScaling -MinCount 0 -MaxCount <maximum node count>
```

---