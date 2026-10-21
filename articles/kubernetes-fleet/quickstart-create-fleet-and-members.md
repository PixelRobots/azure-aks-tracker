---
layout: Conceptual
title: 'Quickstart: Create an Azure Kubernetes Fleet Manager and join member clusters using Azure CLI | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/quickstart-create-fleet-and-members
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
learn_banner_products:
- azure
description: In this quickstart, you learn how to create an Azure Kubernetes Fleet Manager and join member clusters using Azure CLI.
author: sjwaight
ms.author: simonwaight
ms.date: 2026-07-24T00:00:00.0000000Z
ms.service: azure-kubernetes-fleet-manager
ms.topic: quickstart
ms.custom:
- template-quickstart
- mode-other
- devx-track-azurecli
- ignite-2023
- build-2024
- build-2025
ms.devlang: azurecli
zone_pivot_groups: none-public-private-hub
locale: en-us
document_id: 3e65883a-ee73-c85f-c995-a41eb69514f3
document_version_independent_id: 973e4acd-a10d-e53d-6be3-95f189854046
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/quickstart-create-fleet-and-members.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/quickstart-create-fleet-and-members
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/quickstart-create-fleet-and-members.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: ead1b2b1-1303-fda3-1e8c-4f01bd609345
---

# Quickstart: Create an Azure Kubernetes Fleet Manager and join member clusters using Azure CLI | Microsoft Learn

**Applies to:** ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Get started with Azure Kubernetes Fleet Manager by using the Azure CLI to create a Fleet Manager and join [supported Kubernetes clusters](concepts-member-cluster-types) as members.

Fleet Manager supports an optional hub cluster that is used for intelligent Kubernetes resource placement and is required to use [Managed Fleet Namespaces](concepts-fleet-managed-namespace).

For more information on Fleet Manager configurations, see the [conceptual overview of fleet types](concepts-choosing-fleet).

## Before you begin

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Read the [conceptual overview of Fleet Manager](concepts-fleet), which provides an explanation of fleets and member clusters referenced in this document.
- Read the [conceptual overview of fleet types](concepts-choosing-fleet), which provides a comparison of different fleet configuration options.
- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- An identity (user or service principal) with the following permissions:

    - **Fleet Manager:**
        - Microsoft.ContainerService/fleets/read
        - Microsoft.ContainerService/fleets/write
        - Microsoft.ContainerService/fleets/members/read
        - Microsoft.ContainerService/fleets/members/write
        - Microsoft.ContainerService/fleetMemberships/read
        - Microsoft.ContainerService/fleetMemberships/write
    - **AKS member clusters:**
        - Microsoft.ContainerService/managedClusters/read
        - Microsoft.ContainerService/managedClusters/write
        - Microsoft.ContainerService/managedClusters/listClusterUserCredential/action
    - **Arc-enabled Kubernetes member clusters:**
        - Microsoft.Kubernetes/connectedClusters/read
        - Microsoft.KubernetesConfiguration/extensions/read
        - Microsoft.KubernetesConfiguration/extensions/write
        - Microsoft.KubernetesConfiguration/extensions/delete
- Have the Azure CLI version 2.82.0 or later installed. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- You also need the `fleet` Azure CLI extension version 1.8.3 or later, which you can install by running the following command:

    ```azurecli
    az extension add --name fleet
    ```

    Run the following command to update to the latest version of the extension released:

    ```azurecli
    az extension update --name fleet
    ```
- Set the following environment variables:

    ```bash
    export SUBSCRIPTION_ID=<subscription_id>
    export GROUP=<resource_group_name>
    export FLEET=<fleet_name>
    export LOCATION=<azure_region_name>
    ```
- Install `kubectl` using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.

    ```azurecli
    az aks install-cli
    ```
- Member clusters must run supported versions: see [AKS cluster version support policy](/en-us/azure/aks/supported-kubernetes-versions#kubernetes-version-support-policy) and [Azure Arc-enabled Kubernetes validation](/en-us/azure//azure-arc/kubernetes/validation-program).

## Create a resource group

Set the Azure subscription and create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

```azurecli
az account set -s ${SUBSCRIPTION_ID}
az group create --name ${GROUP} --location ${LOCATION}
```

::: zone pivot="no-hub"

## Fleet Manager with no hub cluster

If you want to use Fleet Manager only for safe multi-cluster Kubernetes or node image updates, you can create a Fleet Manager without a hub cluster using the [`az fleet create`](/en-us/cli/azure/fleet#az-fleet-create) command.

Important

You can change from a Fleet Manager without a hub cluster to one with a hub cluster, but not the reverse.

```azurecli
az fleet create \
    --resource-group ${GROUP} \
    --name ${FLEET} \
    --location ${LOCATION} \
    --enable-managed-identity
```

::: zone-end

::: zone pivot="public-hub"

## Fleet Manager with public hub cluster

If you want to use Fleet Manager for intelligent Kubernetes object placement and multi-cluster load balancing as well as Kubernetes and node image update orchestration, then you must create the Fleet Manager with the hub cluster enabled by specifying the `--enable-hub` parameter with the [`az fleet create`](/en-us/cli/azure/fleet#az-fleet-create) command.

Fleet Manager hub clusters support both public and private modes for network access. For more information, see [Choose an Azure Kubernetes Fleet Manager option](concepts-choosing-fleet#network-access-modes-for-hub-cluster).

Note

By default, Fleet Manager hub clusters are public. Fleet Manager chooses the virtual machine (VM) SKU used for the hub node (at this time, Fleet Manager tries "Standard\_D4s\_v4", "Standard\_D4s\_v3", "Standard\_D4s\_v5", "Standard\_Ds3\_v2", "Standard\_E4as\_v4" in order). If none of these options are acceptable or available, you can select a VM SKU by setting `--vm-size <SKU>`.

To create a public Fleet Manager with a hub cluster, use the `az fleet create` command with the `--enable-hub` flag set.

Important

You can't change a hub cluster's type (public or private) once it's configured.

```azurecli
az fleet create \
    --resource-group ${GROUP} \
    --name ${FLEET} \
    --location ${LOCATION}  \
    --enable-hub \
    --enable-managed-identity
```

Your output should look similar to the following example output:

::: zone-end

::: zone pivot="private-hub"

## Fleet Manager with private hub cluster

When you create a Fleet Manager with a private hub cluster the preferred virtual network integration method for the hub cluster is [API server VNet integration](../aks/api-server-vnet-integration).

1. Set the following environment variables.

```bash
export SUBSCRIPTION_ID=<subscription_id>
export GROUP=<resource_group_name>
export FLEET=<fleet_name>
export LOCATION=<azure_region_name>
export UAMI-NAME=<user_managed_identity>
export VNET-NAME=<virtual_network_name>
export VNET-CLUSTER-SUBNET-NAME=<vnet_cluster_subnet_name>
export VNET-API-SUBNET-NAME=<vnet_api_subnet_name>
```

1. Create a user-assigned managed identity to be used to enable private virtual network integration.

```azurecli
az identity create \
    --resource-group ${GROUP} \
    --name ${UAMI-NAME}
```

Retrieve the resource identifier for the user assigned managed identity to use later.

```bash
UAMI_ID=$(az identity show --resource-group ${GROUP} --name ${UAMI-NAME} --query id --output tsv)
```

1. If one doesn't already exist, create a virtual network.

```azurecli
az network vnet create \
    --resource-group ${GROUP} \
    --name ${FLEET} \
    --address-prefixes 192.168.0.0/16
```

1. Add a subnet for the hub cluster integration.

```azurecli
az network vnet subnet create \
    --resource-group ${GROUP} \
    --vnet-name ${FLEET} \
    --name ${VNET-CLUSTER-SUBNET-NAME} \
    --address-prefixes 192.168.0.0/23
```

Retrieve the resource identifier for the cluster subnet to use later.

```bash
CLUSTER_SUBNET_ID=$(az network vnet subnet show --resource-group ${GROUP} --vnet-name ${FLEET} -n ${VNET-CLUSTER-SUBNET-NAME} -o tsv --query id)
```

1. Add a subnet for the hub cluster's API server VNet integration. This subnet requires delegation to `Microsoft.ContainerService/managedClusters`.

```azurecli
az network vnet subnet create \
    --resource-group ${GROUP} \
    --vnet-name ${FLEET} \
    --name ${VNET-API-SUBNET-NAME} \
    --delegations "Microsoft.ContainerService/managedClusters" \
    --address-prefixes 192.168.2.0/23
```

Retrieve the resource identifier for the API subnet to use later.

```bash
API_SUBNET_ID=$(az network vnet subnet show --resource-group ${GROUP} --vnet-name ${FLEET} -n ${VNET-API-SUBNET-NAME} -o tsv --query id)
```

1. Finally, create the new hub cluster, providing the necessary arguments to enable API VNet integration and a private hub cluster.

```azurecli
az fleet create \
    --resource-group ${GROUP} \
    --name ${FLEET} \
    --location ${LOCATION}  \
    --enable-hub \
    --enable-managed-identity \
    --enable-private-cluster \
    --enable-vnet-integration \
    --agent-subnet-id ${CLUSTER_SUBNET_ID} \
    --apiserver-subnet-id ${API_SUBNET_ID} \
    --assign-identity ${UAMI_ID}
```

::: zone-end

## Join member clusters

Fleet Manager supports joining AKS or Arc-enabled Kubernetes clusters as member clusters.

1. Set the following environment variables for member clusters:

    ```azurecli
    export MEMBER_NAME_1=flt-member-cluster-1
    
    # For an AKS cluster
    export MEMBER_CLUSTER_ID_1=/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${GROUP}/providers/Microsoft.ContainerService/managedClusters/${MEMBER_NAME_1}
    
    # For an Arc-enabled cluster
    export MEMBER_CLUSTER_ID_1=/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${GROUP}/providers/Microsoft.Kubernetes/connectedClusters/${MEMBER_NAME_1}
    ```
2. Join the existing clusters to the Fleet Manager using the [`az fleet member create`](/en-us/cli/azure/fleet/member#az-fleet-member-create) command.

    ```azurecli
    az fleet member create \
        --resource-group ${GROUP} \
        --fleet-name ${FLEET} \
        --name ${MEMBER_NAME_1} \
        --member-cluster-id ${MEMBER_CLUSTER_ID_1}
    ```

    Your output should look similar to the following example output:

    ```output
    {
      "clusterResourceId": "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<GROUP>/providers/Microsoft.ContainerService/managedClusters/aks-member-x",
      "etag": "...",
      "id": "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<GROUP>/providers/Microsoft.ContainerService/fleets/<FLEET>/members/aks-member-x",
      "name": "aks-member-1",
      "provisioningState": "Succeeded",
      "resourceGroup": "<GROUP>",
      "systemData": {
        "createdAt": "2022-10-04T19:04:56.455813+00:00",
        "createdBy": "<user>",
        "createdByType": "User",
        "lastModifiedAt": "2022-10-04T19:04:56.455813+00:00",
        "lastModifiedBy": "<user>",
        "lastModifiedByType": "User"
      },
      "type": "Microsoft.ContainerService/fleets/members"
    }
    ```
3. Verify that the member clusters successfully joined the Fleet Manager using the [`az fleet member list`](/en-us/cli/azure/fleet/member#az-fleet-member-list) command.

    ```azurecli
    az fleet member list \
        --resource-group ${GROUP} \
        --fleet-name ${FLEET} \
        -o table
    ```

    If successful, your output should look similar to the following example output:

    ```output
    ClusterResourceId                                                                                                          Name          ProvisioningState    ResourceGroup
    -------------------------------------------------------------------------------------------------------------------------- ------------  -------------------  ---------------
    /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<GROUP>/providers/Microsoft.ContainerService/managedClusters/aks-member-1  aks-member-1  Succeeded            <GROUP>
    /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<GROUP>/providers/Microsoft.ContainerService/managedClusters/aks-member-2  aks-member-2  Succeeded            <GROUP>
    /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<GROUP>/providers/Microsoft.ContainerService/managedClusters/aks-member-3  aks-member-3  Succeeded            <GROUP>
    ```