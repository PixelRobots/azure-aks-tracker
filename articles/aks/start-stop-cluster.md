---
layout: Conceptual
title: Stop and start an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/start-stop-cluster
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
description: Learn how to stop and start an Azure Kubernetes Service (AKS) cluster.
ms.topic: how-to
ms.custom: aks-reliability
ms.date: 2026-07-21T00:00:00.0000000Z
author: colinmixonn
ms.author: schaffererin
locale: en-us
document_id: a6584bf5-6b28-ebb5-d732-43f6bb3c3028
document_version_independent_id: 92a76e3a-61e4-b046-9a43-664077769f6e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/start-stop-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/start-stop-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/start-stop-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 3ddb2177-4657-6c6d-d6aa-c2439948027f
---

# Stop and start an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

You may not need to continuously run your Azure Kubernetes Service (AKS) workloads. For example, you may have a development cluster that you only use during business hours. This means there are times where your cluster might be idle, running nothing more than the system components. You can reduce the cluster footprint by [scaling all `User` node pools to 0](scale-cluster#scale-user-node-pools-to-0), but your [`System` pool](use-system-pools) is still required to run the system components while the cluster is running.

To better optimize your costs during these periods, you can turn off, or stop, your cluster. This action stops your control plane and agent nodes, allowing you to save on all the compute costs, while maintaining all objects except standalone pods. The cluster state is stored for when you start it again, allowing you to pick up where you left off.

Caution

Stopping your cluster deallocates the control plane and releases the capacity. In regions experiencing capacity constraints, customers may be unable to start a stopped cluster. We do not recommend stopping mission critical workloads for this reason.

Note

AKS start operations will restore all objects from ETCD with the exception of standalone pods with the same names and ages. meaning that a pod's age will continue to be calculated from its original creation time. This count will keep increasing over time, regardless of whether the cluster is in a stopped state.

## Before you begin

This article assumes you have an existing AKS cluster. If you need an AKS cluster, you can create one using [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or the [Azure portal](learn/quick-kubernetes-deploy-portal).

### About the cluster stop/start feature

When using the cluster stop/start feature, the following conditions apply:

- This feature is only supported for Virtual Machine Scale Set backed clusters.
- You can't stop clusters which use the [Node Autoprovisioning (NAP)](node-autoprovision) feature.
- The cluster state of a stopped AKS cluster is preserved for up to 12 months. If your cluster is stopped for more than 12 months, you can't recover the state. For more information, see the [AKS support policies](support-policies).
- You can only perform start or delete operations on a stopped AKS cluster. To perform other operations, like scaling or upgrading, you need to start your cluster first.
- For a private link-based AKS cluster, AKS recreates the API server private endpoint when you start the cluster. AKS places the private endpoint in the subnet used by the first node pool in the cluster configuration. If you replace the initial system node pool, another node pool might become the first node pool, and AKS might place the recreated private endpoint in a different subnet.
- Because the stop process drains all nodes, any standalone pods (i.e. pods not managed by a Deployment, StatefulSet, DaemonSet, Job, etc.) will be deleted.
- When you start your cluster back up, the following behavior is expected:
    - The IP address of your API server may change.
    - If you're using cluster autoscaler, when you start your cluster, your current node count may not be between the min and max range values you set. The cluster starts with the number of nodes it needs to run its workloads, which isn't impacted by your autoscaler settings. When your cluster performs scaling operations, the min and max values will impact your current node count, and your cluster will eventually enter and remain in that desired range until you stop your cluster.

## Stop an AKS cluster

Caution

If your cluster has a `ValidatingWebhookConfiguration` or `MutatingWebhookConfiguration` whose configuration may apply to cluster-scoped resources AKS manages during stop/start (such as nodes, leases, or clusterroles), the stop operation may be rejected with a `ValidationError`. This includes webhooks with wildcard (`*`) rules on `apiGroups` or `resources`. To resolve, either narrow the webhook rules to only the resources you need (avoid wildcards), scope the webhook to namespaced resources using `scope: Namespaced` and a `namespaceSelector`, set `failurePolicy` to `Ignore`, or remove the webhook before stopping.

# [Azure CLI](#tab/azure-cli)
1. Use the [`az aks stop`](/en-us/cli/azure/aks#az-aks-stop) command to stop a running AKS cluster, including the nodes and control plane. The following example stops a cluster named *myAKSCluster*:

    ```azurecli
    az aks stop --name myAKSCluster --resource-group myResourceGroup
    ```
2. Verify your cluster has stopped using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command and confirming the `powerState` shows as `Stopped`.

    ```azurecli
    az aks show --name myAKSCluster --resource-group myResourceGroup
    ```

    Your output should look similar to the following condensed example output:

    ```json
    {
    [...]
      "nodeResourceGroup": "MC_myResourceGroup_myAKSCluster_westus2",
      "powerState":{
        "code":"Stopped"
      },
      "privateFqdn": null,
      "provisioningState": "Succeeded",
      "resourceGroup": "myResourceGroup",
    [...]
    }
    ```

    If the `provisioningState` shows `Stopping`, your cluster hasn't fully stopped yet.

# [Azure PowerShell](#tab/azure-powershell)
1. Use the [`Stop-AzAksCluster`](/en-us/powershell/module/az.aks/stop-azakscluster) cmdlet to stop a running AKS cluster, including the nodes and control plane. The following example stops a cluster named *myAKSCluster*:

    ```azurepowershell
    Stop-AzAksCluster -Name myAKSCluster -ResourceGroupName myResourceGroup
    ```
2. Verify your cluster has stopped using the [`Get-AzAksCluster`](/en-us/powershell/module/az.aks/get-azakscluster) cmdlet and confirming the `ProvisioningState` shows as `Succeeded`.

    ```azurepowershell
    Get-AzAKSCluster -Name myAKSCluster -ResourceGroupName myResourceGroup
    ```

    Your output should look similar to the following condensed example output:

    ```Output
    ProvisioningState       : Succeeded
    MaxAgentPools           : 100
    KubernetesVersion       : 1.20.7
    ...
    ```

    If the `ProvisioningState` shows `Stopping`, your cluster hasn't fully stopped yet.

---

Important

If you're using [pod disruption budgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/), the stop operation can take longer, as the drain process will take more time to complete.

## Start an AKS cluster

Caution

After utilizing the start/stop feature on AKS, it is essential to wait 15-30 minutes before restarting your AKS cluster. This waiting period is necessary because it takes several minutes for the relevant services to fully stop. Attempting to restart your cluster during this process can disrupt the shutdown process and potentially cause issues with the cluster or its workloads.

# [Azure CLI](#tab/azure-cli)
1. Use the [`az aks start`](/en-us/cli/azure/aks#az-aks-start) command to start a stopped AKS cluster. The cluster restarts with the previous control plane state and number of agent nodes. The following example starts a cluster named *myAKSCluster*:

    ```azurecli
    az aks start --name myAKSCluster --resource-group myResourceGroup
    ```
2. Verify your cluster has started using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command and confirming the `powerState` shows `Running`.

    ```azurecli
    az aks show --name myAKSCluster --resource-group myResourceGroup
    ```

    Your output should look similar to the following condensed example output:

    ```json
    {
    [...]
      "nodeResourceGroup": "MC_myResourceGroup_myAKSCluster_westus2",
      "powerState":{
        "code":"Running"
     },
     "privateFqdn": null,
     "provisioningState": "Succeeded",
     "resourceGroup": "myResourceGroup",
    [...]
    }
    ```

    If the `provisioningState` shows `Starting`, your cluster hasn't fully started yet.

# [Azure PowerShell](#tab/azure-powershell)
1. Use the [`Start-AzAksCluster`](/en-us/powershell/module/az.aks/start-azakscluster) cmdlet to start a stopped AKS cluster. The cluster restarts with the previous control plane state and number of agent nodes. The following example starts a cluster named *myAKSCluster*:

    ```azurepowershell
    Start-AzAksCluster -Name myAKSCluster -ResourceGroupName myResourceGroup
    ```
2. Verify your cluster has started using the [`Get-AzAksCluster`](/en-us/powershell/module/az.aks/get-azakscluster) cmdlet and confirming the `ProvisioningState` shows `Succeeded`.

    ```azurepowershell
    Get-AzAksCluster -Name myAKSCluster -ResourceGroupName myResourceGroup
    ```

    Your output should look similar to the following condensed example output:

    ```Output
    ProvisioningState       : Succeeded
    MaxAgentPools           : 100
    KubernetesVersion       : 1.20.7
    ...
    ```

    If the `ProvisioningState` shows `Starting`, your cluster hasn't fully started yet.

---