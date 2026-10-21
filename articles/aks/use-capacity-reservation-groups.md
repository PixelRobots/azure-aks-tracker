---
layout: Conceptual
title: Assign Capacity Reservation Groups to Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-capacity-reservation-groups
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
description: Learn how to use capacity reservation groups with node pools in Azure Kubernetes Service (AKS) to guarantee allocated capacity for your node pools.
ms.topic: how-to
ms.date: 2026-09-14T00:00:00.0000000Z
author: schaffererin
ms.author: stgriffi
ms.subservice: aks-nodes
locale: en-us
document_id: c77d8051-4c76-0c20-ef96-1eaed858eaee
document_version_independent_id: 9a3df3d1-b259-3fdc-0227-7effd58fc7ef
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-capacity-reservation-groups.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-capacity-reservation-groups
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-capacity-reservation-groups.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c74641cb-3f16-9f86-2838-9830c00e7177
---

# Assign Capacity Reservation Groups to Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

As your workload demands change, you can associate existing [capacity reservation groups (CRGs)](/en-us/azure/virtual-machines/capacity-reservation-associate-virtual-machine-scale-set) to your Azure Kubernetes Service (AKS) node pools to guarantee allocated capacity for them. Capacity reservation groups allow you to reserve compute capacity in an Azure region or availability zone for any duration of time. This feature is useful for workloads that require guaranteed capacity, such as those with predictable traffic patterns or those that need to meet specific performance requirements.

In this article, you learn how to use capacity reservation groups with node pools in AKS.

Note

Deleting a node pool implicitly dissociates that node pool from any associated capacity reservation group before the node pool is deleted. Deleting a cluster implicitly dissociates all node pools in that cluster from their associated capacity reservation groups.

## Prerequisites for using capacity reservation groups with AKS node pools

- You need the Azure CLI version 2.56 or later installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need an existing [capacity reservation group](/en-us/azure/virtual-machines/capacity-reservation-associate-virtual-machine-scale-set) with at least one capacity reservation. If not, the node pool is added to the cluster with a warning and no capacity reservation group gets associated.
- You need to create a user-assigned managed identity with the `Contributor` role for the resource group that contains the capacity reservation group and assign the identity to your AKS cluster. System-assigned managed identities don't work for this feature.

Important

For shared or cross-subscription capacity reservation groups, the user or service principal running the AKS command must have `Microsoft.Compute/capacityReservationGroups/write` permission on the linked capacity reservation group. The granular shared capacity reservation group consumer permissions used for virtual machines, such as `Microsoft.Compute/capacityReservationGroups/deploy/action`, aren't currently sufficient for associating an AKS node pool with a capacity reservation group.

Permissions assigned to the AKS cluster's managed identity don't replace this caller authorization check. The cluster managed identity still needs the required permissions on the resource group that contains the capacity reservation group, as described in this article.

### Create a user-assigned managed identity and assign it to an AKS cluster

1. Create a user-assigned managed identity using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    ```azurecli
    az identity create --name <identity-name> --resource-group <resource-group-name> --location <location>
    ```
2. Get the ID of the user-assigned managed identity using the [`az identity show`](/en-us/cli/azure/identity#az-identity-show) command and set it to an environment variable.

    ```azurecli
    IDENTITY_ID=$(az identity show --name <identity-name> --resource-group <resource-group-name> --query identity.id -o tsv)
    ```
3. Assign the `Contributor` role to the user-assigned identity using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create --assignee $IDENTITY_ID --role "Contributor" --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>
    ```

    It can take up to *60 minutes* for the role assignment to propagate.
4. Assign the user-assigned managed identity to a new or existing AKS cluster using the `--assign-identity` flag with the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) or [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

    ```azurecli
    # Create a new AKS cluster with the user-assigned managed identity
    az aks create \
        --resource-group <resource-group-name> \
        --name <cluster-name> \
        --location <location> \
        --node-vm-size <vm-size> --node-count <node-count> \
        --assign-identity $IDENTITY_ID \
        --generate-ssh-keys
    
    # Update an existing AKS cluster to use the user-assigned managed identity
    az aks update \
        --resource-group <resource-group-name> \
        --name <cluster-name> \
        --location <location> \
        --node-vm-size <vm-size> \
        --node-count <node-count> \
        --enable-managed-identity \
        --assign-identity $IDENTITY_ID         
    ```

## Get the ID of an existing capacity reservation group

Get the ID of an existing capacity reservation group by using the [`az capacity reservation group show`](/en-us/cli/azure/capacity/reservation/group#az-capacity-reservation-group-show) command and set it to an environment variable.

```azurecli
CRG_ID=$(az capacity reservation group show --capacity-reservation-group <crg-name> --resource-group <resource-group-name> --query id -o tsv)
```

## Associate an existing capacity reservation group with a new node pool

Associate an existing capacity reservation group with a new node pool by using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--crg-id` flag. The following example assumes you have a CRG named "myCRG".

```azurecli
az aks nodepool add --resource-group <resource-group-name> --cluster-name <cluster-name> --name <node-pool-name> --crg-id $CRG_ID
```

## Associate an existing capacity reservation group with an existing node pool (Preview)

Associate an existing capacity reservation group with an existing node pool by using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command with the `--crg-id` flag.

- For zonal node pools, this operation initiates a rolling update of the target node pool. The update process involves rolling cordon and drain of all nodes, followed by a reboot to apply the change.
- For non-zonal (regional) node pools during the preview, first scale the node pool to zero, then apply the capacity reservation group.

### Prerequisites

- Install the `aks-preview` Azure CLI extension version `20.0.0b7` or later before running this command.
- Ensure the capacity reservation group has enough capacity for your node pool upgrade strategy. When `maxSurge > 0`, reserve extra capacity for the [max surge](upgrade-aks-node-pools-rolling#customize-node-surge) value. For example, a 10-node pool with `maxSurge` set to `2` can run up to 12 nodes during an upgrade. This extra capacity isn't required for [maxUnavailable](upgrade-aks-node-pools-rolling#customize-unavailable-nodes) only rollouts or regional scaled-to-zero paths.

    ```azurecli
    az aks nodepool update --resource-group <resource-group-name> --cluster-name <cluster-name> --name <node-pool-name> --crg-id $CRG_ID
    ```

    If the command fails with `LinkedAuthorizationFailed` and references `Microsoft.Compute/capacityReservationGroups/write`, grant that permission to the signed-in user or service principal running the command on the target capacity reservation group.

## Associate an existing capacity reservation group with a system node pool

To associate an existing capacity reservation group with a system node pool, you need to assign the user-assigned managed identity with the `Contributor` role to the cluster during cluster creation. You can then use the `--crg-id` flag to associate the capacity reservation group with the system node pool.

- Create a new AKS cluster with the user-assigned managed identity and associate it with the capacity reservation group using the `--assign-identity` and `--crg-id` flags with the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

    ```azurecli
    az aks create \
        --resource-group <resource-group-name> \
        --name <cluster-name> \
        --location <location> \
        --node-vm-size <vm-size> --node-count <node-count> \
        --assign-identity $IDENTITY_ID \
        --crg-id $CRG_ID \
        --generate-ssh-keys
    ```

## Next steps: Manage node pools in AKS

To learn more about managing node pools in AKS, see [Manage node pools in Azure Kubernetes Service (AKS)](manage-node-pools).