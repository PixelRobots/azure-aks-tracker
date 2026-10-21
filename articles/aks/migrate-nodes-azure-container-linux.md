---
layout: Conceptual
title: Migrate Existing Nodes to Azure Container Linux (ACL) for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/migrate-nodes-azure-container-linux
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
description: In this Azure Linux article, you learn how to migrate nodes to Azure Container Linux (ACL) for AKS.
author: schaffererin
ms.author: schaffererin
ms.custom: aks-migration
ms.topic: how-to
ms.date: 2026-04-12T00:00:00.0000000Z
locale: en-us
document_id: 30ced048-5fc9-5bbe-7374-4216a29d2cee
document_version_independent_id: bbb8a45a-90f8-c946-982e-93cae3db6a83
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/migrate-nodes-azure-container-linux.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/migrate-nodes-azure-container-linux
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/migrate-nodes-azure-container-linux.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 8bbe1529-0774-5c3d-d18e-ff5d4f819f1c
---

# Migrate Existing Nodes to Azure Container Linux (ACL) for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to migrate your existing AKS node pools to Azure Container Linux (ACL) for AKS. You can migrate your existing nodes using one of the following methods:

- **In-place OS SKU migration**: Change the OS SKU of your existing node pools to ACL, which reimages the nodes automatically.
- **Remove existing node pools and add new ACL node pools**: Create new ACL node pools, move your workloads, and remove the old node pools.

Important

If you're using **Azure Container Linux (ACL)** on AKS, make sure you review the following considerations and limitations:

- ACL is generally available starting AKS v1.34.
- ACL requires [Trusted Launch](/en-us/azure/aks/use-trusted-launch) with Secure Boot and vTPM. Non-Trusted Launch variants aren't available.
- ACL on Arm64 requires Cobalt-based (v6) SKUs to enable Trusted Launch compatibility.
- `NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image). `Unmanaged` and `SecurityPatch` are incompatible with ACL due to the immutable `/usr` directory.
- [Artifact Streaming](/en-us/azure/aks/artifact-streaming) isn't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Generation 1 VMs](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.

## In-place OS SKU migration limitations

In addition to the general ACL limitations, the following apply specifically to in-place OS SKU migration:

- The OS SKU migration feature isn't available through PowerShell or the Azure portal.
- The OS SKU migration feature doesn't support renaming existing node pools.
- Node pools with `UseGPUDedicatedVHD` enabled can't perform an OS SKU migration.
- Windows node pools can't migrate to ACL.

## Prerequisites

- An existing AKS cluster with at least one Linux node pool.
- Azure CLI version 2.86.0 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- We recommend that you verify your workloads run successfully on ACL by [deploying an ACL cluster](learn/quick-azure-container-linux-deploy-cli) in a development or staging environment before migrating production clusters.
- Ensure the migration feature is working for you in test/dev before using the process on a production cluster.
- Ensure that your pods have enough [Pod Disruption Budget (PDB)](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/) to allow AKS to move pods between VMs during the migration.

## Add ACL node pools and remove existing node pools

1. Add a new ACL node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. Use `--mode System` so the new pool can serve as the system agent pool, which allows you to delete the original node pool in the next step.

    ```azurecli
    az aks nodepool add \
        --resource-group <resource-group> \
        --cluster-name <cluster-name> \
        --name <new-node-pool-name> \
        --os-sku AzureContainerLinux \
        --mode System \
        --node-count 3
    ```

    Example output:

    ```json
    {
      "id": "/subscriptions/xxxxx/resourceGroups/myResourceGroup/providers/Microsoft.ContainerService/managedClusters/myAKSCluster/nodePools/myNewNodePool",
      "name": "myNewNodePool",
      "osSku": "AzureContainerLinux",
      "provisioningState": "Succeeded"
    }
    ```
2. Remove your existing node pool using the [`az aks nodepool delete`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-delete) command.

    ```azurecli
    az aks nodepool delete \
        --resource-group <resource-group> \
        --cluster-name <cluster-name> \
        --name <existing-node-pool-name>
    ```

## In-place OS SKU migration

You can migrate your existing Linux node pools to ACL by changing the OS SKU of the node pool, which rolls the cluster through the standard node image upgrade process. This method doesn't require creating new node pools; instead, your existing node pools are automatically reimaged.

### Perform an in-place OS SKU migration

Important

ACL requires Trusted Launch. You must include `--enable-secure-boot` and `--enable-vtpm` when migrating to the `AzureContainerLinux` OS SKU. Your node pool's virtual machine (VM) size must also support Trusted Launch. If your current VM size doesn't support it, you need to resize or recreate the node pool with a supported VM size before migrating.

Migrate the OS SKU of your node pool to ACL using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command. This command triggers a reimage of your node pool, updating the OS SKU to `AzureContainerLinux`. The OS SKU change triggers an immediate upgrade operation, which takes several minutes to complete.

```azurecli
az aks nodepool update \
    --resource-group <resource-group> \
    --cluster-name <cluster-name> \
    --name <existing-node-pool-name> \
    --os-sku AzureContainerLinux \
    --enable-secure-boot \
    --enable-vtpm
```

Example output:

```json
{
  "id": "/subscriptions/xxxxx/resourceGroups/myResourceGroup/providers/Microsoft.ContainerService/managedClusters/myAKSCluster/nodePools/nodepool1",
  "name": "nodepool1",
  "osSku": "AzureContainerLinux",
  "provisioningState": "Succeeded"
}
```

Note

If you experience issues during the OS SKU migration, you can roll back to your previous OS SKU.

## Verify the OS SKU migration

Tip

We recommend monitoring the health of your service for a couple of weeks before migrating your production clusters.

Once the migration is complete on your test clusters, we recommend monitoring the cluster and workloads for a couple of weeks to confirm everything is running as expected before migrating production clusters. Use the following commands to verify the migration and monitor your cluster:

1. Confirm the new nodes are running ACL using the `kubectl get nodes -o wide` command. The output should show the ACL OS image.

    ```bash
    kubectl get nodes -o wide
    ```
2. Verify all your pods and daemonsets are running on the new node pool using the `kubectl get pods -o wide -A` command.

    ```bash
    kubectl get pods -o wide -A
    ```
3. Verify all the node labels in your upgraded node pool are what you expect using the `kubectl get nodes --show-labels` command.

    ```bash
    kubectl get nodes --show-labels
    ```
4. Check the node image version using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command.

    ```azurecli
    az aks nodepool list \
        --resource-group <resource-group> \
        --cluster-name <cluster-name> \
        --query '[].{name: name, osSku: osSku, nodeImageVersion: nodeImageVersion}'
    ```

    Example output:

    ```json
    [
      {
        "name": "myNodePool",
        "nodeImageVersion": "AKSAzureContainerLinux-202606.01.0",
        "osSku": "AzureContainerLinux"
      }
    ]
    ```

## Roll back to your previous OS SKU

If you experience issues during the OS SKU migration, you can roll back to your previous OS SKU. To do this, change the OS SKU field back to your previous value and resubmit the deployment, which triggers another upgrade operation and reimages the node pool to its previous OS SKU. If you roll back from ACL to your previous OS SKU, the node pool uses the Trusted Launch (Gen2) image variant by default unless Trusted Launch is explicitly disabled.

Roll back to your previous OS SKU using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command. This example rolls back from ACL to Azure Linux:

```azurecli
az aks nodepool update \
    --resource-group <resource-group> \
    --cluster-name <cluster-name> \
    --name <existing-node-pool-name> \
    --os-sku AzureLinux
```