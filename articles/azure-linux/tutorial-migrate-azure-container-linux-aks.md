---
layout: Conceptual
title: 'Tutorial: Migrate Nodes to Azure Container Linux (ACL) for Azure Kubernetes Service (AKS) | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-migrate-azure-container-linux-aks
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
learn_banner_products:
- azure
manager: kumud
description: In this Azure Linux tutorial, you learn how to migrate nodes to Azure Container Linux (ACL) for AKS.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: f01caeff-4663-af74-e61c-f801beded950
document_version_independent_id: 331271a8-621a-fa23-dbd8-1202dcb66768
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-migrate-azure-container-linux-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-migrate-azure-container-linux-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-migrate-azure-container-linux-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 24b098de-fe8f-873a-f328-d1e268756c1b
---

# Tutorial: Migrate Nodes to Azure Container Linux (ACL) for Azure Kubernetes Service (AKS) | Microsoft Learn

In this tutorial, part *three of five*, you migrate your existing nodes to ACL. You can migrate your existing nodes using one of the following methods:

- Remove existing node pools and add new ACL node pools.
- Perform an in-place operating system (OS) SKU migration.

The commands in this tutorial use the environment variables set in [Tutorial 1: Create a cluster with ACL for AKS](tutorial-create-cluster-azure-container-linux-aks).

If you don't have any existing nodes to migrate, skip to the [next tutorial](tutorial-monitor-azure-container-linux-aks). In later tutorials, you learn how to enable telemetry and monitoring in your clusters and upgrade ACL nodes.

## Prerequisites

- In previous tutorials, you created and deployed an ACL cluster. If you haven't completed these steps and want to follow along, see [Tutorial 1: Create a cluster with ACL for AKS](tutorial-create-cluster-azure-container-linux-aks).
- Azure Container Linux requires Azure CLI version [2.86.0](/en-us/cli/azure/release-notes-azure-cli#may-21-2024) or higher. Use the [`az version`](/en-us/cli/azure/reference-index?#az-version) command to find the version. To upgrade to the latest version, use the [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade) command.

## Azure Container Linux (ACL) considerations and limitations

Before you begin, review the following considerations and limitations for ACL:

- ACL is generally available starting AKS v1.34.
- ACL requires [Trusted Launch](/en-us/azure/aks/use-trusted-launch) with Secure Boot and vTPM. Non-Trusted Launch variants aren't available.
- ACL on Arm64 requires Cobalt-based (v6) SKUs to enable Trusted Launch compatibility.
- `NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image). `Unmanaged` and `SecurityPatch` are incompatible with ACL due to the immutable `/usr` directory.
- [Artifact Streaming](/en-us/azure/aks/artifact-streaming) isn't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Generation 1 VMs](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.

## Add ACL node pools and remove existing node pools

1. Add a new ACL node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. Use `--mode System` so the new pool can serve as the system agent pool, which allows you to delete the original node pool in the next step. The following example creates a node pool named *aclsystem* that adds three nodes to the cluster:

    ```azurecli
    az aks nodepool add \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --name aclsystem \
        --mode System \
        --os-sku AzureContainerLinux \
        --node-count 3
    ```

    Example output:

    ```JSON
    {
      "id": "/subscriptions/xxxxx/resourceGroups/myACLResourceGroup/providers/Microsoft.ContainerService/managedClusters/myACLCluster/nodePools/aclsystem",
      "name": "aclsystem",
      "osSku": "AzureContainerLinux",
      "provisioningState": "Succeeded"
    }
    ```
2. Remove your existing node pool using the [`az aks nodepool delete`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-delete) command.

    ```azurecli
    az aks nodepool delete \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --name <existing-node-pool-name>
    ```

## In-place OS SKU migration

### Limitations for in-place OS SKU migration

There are several settings that can block the OS SKU migration request. To ensure a successful migration, review the following guidelines and limitations:

- The OS SKU migration feature isn't available through PowerShell or the Azure portal.
- The OS SKU migration feature doesn't support renaming existing node pools.
- Ubuntu, Azure Linux, and AzureContainerLinux are the only supported Linux OS SKU migration targets.
- ACL requires Trusted Launch. If not already enabled on your node pool, you must include `--enable-secure-boot` and `--enable-vtpm` when migrating to the `AzureContainerLinux` OS SKU. Your node pool's VM size must also support Trusted Launch. If your current VM size doesn't support it, you need to resize or recreate the node pool with a supported VM size before migrating.
- [Generation 1 VMs](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.
- An Ubuntu OS SKU with `UseGPUDedicatedVHD` enabled can't perform an OS SKU migration.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- Windows OS SKU migration isn't supported.

### Prerequisites for in-place OS SKU migration

- An existing AKS cluster with at least one Linux node pool.
- We recommend that you verify your workloads run successfully on ACL by [deploying an ACL cluster](quick-deploy-azure-container-linux-aks-cli) in a development or staging environment before migrating production clusters.
- Ensure the migration feature is working for you in test/dev before using the process on a production cluster.
- Ensure that your pods have enough [Pod Disruption Budget (PDB)](/en-us/azure/aks/operator-best-practices-scheduler#plan-for-availability-using-pod-disruption-budgets) to allow AKS to move pods between VMs during the upgrade.
- You need Azure CLI version [2.61.0](/en-us/cli/azure/release-notes-azure-cli#may-21-2024) or higher. Use the [`az version`](/en-us/cli/azure/reference-index?#az-version) command to find the version. To upgrade to the latest version, use the [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade) command.

### Migrate to ACL using in-place OS SKU migration

You can migrate your existing Ubuntu or Azure Linux node pools to ACL by changing the OS SKU of the node pool, which rolls the cluster through the standard node image upgrade process. This method doesn't require creating new node pools; instead, your existing node pools are automatically reimaged.

Important

ACL requires Trusted Launch. You must include `--enable-secure-boot` and `--enable-vtpm` when migrating to the `AzureContainerLinux` OS SKU. Your node pool's VM size must also support Trusted Launch.

Migrate the OS SKU of your node pool to ACL using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command. This command triggers a reimage of your node pool. The OS SKU change triggers an immediate upgrade operation, which takes several minutes to complete.

```azurecli
az aks nodepool update \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --name <existing-node-pool-name> \
    --os-sku AzureContainerLinux \
    --enable-secure-boot \
    --enable-vtpm
```

Example output:

```JSON
{
  "id": "/subscriptions/xxxxx/resourceGroups/myACLResourceGroup/providers/Microsoft.ContainerService/managedClusters/myACLCluster/nodePools/nodepool1",
  "name": "nodepool1",
  "osSku": "AzureContainerLinux",
  "provisioningState": "Succeeded"
}
```

Note

If you experience issues during the OS SKU migration, you can roll back to your previous OS SKU.

### Verify the OS SKU migration

Once the migration is complete on your test clusters, verify the following to ensure a successful migration:

1. Confirm the new nodes are running ACL using the following command:

    ```bash
    kubectl get nodes -o wide
    ```
2. Verify all of your pods and daemonsets are running on the new node pool using the following command:

    ```bash
    kubectl get pods -o wide -A
    ```
3. Verify all of the node labels in your upgraded node pool are what you expect using the following command:

    ```bash
    kubectl get nodes --show-labels
    ```
4. Check the node image version using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command.

    ```azurecli
    az aks nodepool list \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --query '[].{name: name, osSku: osSku, nodeImageVersion: nodeImageVersion}'
    ```

    Example output:

    ```json
    [
      {
        "name": "nodepool1",
        "nodeImageVersion": "AKSAzureContainerLinux-202606.01.0",
        "osSku": "AzureContainerLinux"
      }
    ]
    ```

Tip

We recommend monitoring the health of your service for a couple of weeks before migrating your production clusters.

### Roll back to your previous OS SKU

If you experience issues during the OS SKU migration, you can roll back to your previous OS SKU. To do this, change the OS SKU field back to your previous value and resubmit the deployment, which triggers another upgrade operation and reimages the node pool to its previous OS SKU.

Roll back to your previous OS SKU using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command. This example rolls back from ACL to Azure Linux:

```azurecli
az aks nodepool update \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --name <existing-node-pool-name> \
    --os-sku AzureLinux
```