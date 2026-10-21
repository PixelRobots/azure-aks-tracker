---
layout: Conceptual
title: Create an Azure Kubernetes Service (AKS) cluster with node auto-provisioning (NAP) in a custom virtual network - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-auto-provisioning-custom-vnet
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
description: Learn how to create an AKS cluster with node auto-provisioning in a custom virtual network.
ms.topic: how-to
ms.custom: devx-track-azurecli, aks-scaling
ms.date: 2026-08-06T00:00:00.0000000Z
ai-usage: ai-assisted
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 4ad50a67-cb2f-3cad-f0bc-a7b154232fb1
document_version_independent_id: 311095cb-61e5-1b85-5e4c-d323b13d926b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-auto-provisioning-custom-vnet.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/node-auto-provisioning-custom-vnet
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-auto-provisioning-custom-vnet.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
platformId: 2d3adf21-e560-5272-c557-44156241ed01
---

# Create an Azure Kubernetes Service (AKS) cluster with node auto-provisioning (NAP) in a custom virtual network - Azure Kubernetes Service | Microsoft Learn

This article shows you how to create an Azure Kubernetes Service (AKS) cluster with node auto-provisioning (NAP) enabled in a custom virtual network (VNet). You create a VNet and subnet, then grant a managed identity access to the VNet.

## Prerequisites

- An Azure subscription. If you don't have one, you can create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Azure CLI version `2.76.0` or later. To find the version, run `az --version`. For more information about installing or upgrading the Azure CLI, see [Install Azure CLI](/en-us/cli/azure/get-started-with-azure-cli).
- A Bash environment, such as [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). If you run the commands locally, sign in using the [`az login`](/en-us/cli/azure/reference-index#az-login) command.
- The Kubernetes command-line client, `kubectl`. `kubectl` is already installed in Azure Cloud Shell. To install it locally, use the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.
- `Microsoft.Authorization/roleAssignments/write` permission, such as the [Role Based Access Control Administrator](/en-us/azure/role-based-access-control/built-in-roles/privileged#role-based-access-control-administrator) role, to assign the Network Contributor role.
- Familiarity with the concepts described in [Overview of node auto-provisioning (NAP) in AKS](node-auto-provisioning) and [Overview of networking configurations for node auto-provisioning (NAP) in Azure Kubernetes Service (AKS)](node-auto-provisioning-networking).

## Limitations

- When creating a NAP cluster in a custom virtual network (VNet), you must use a [Standard Load Balancer](load-balancer-standard). The Basic Load Balancer isn't supported.
- To review other limitations and unsupported features for NAP, see the [Overview of node auto-provisioning (NAP) in AKS](node-auto-provisioning#limitations-and-unsupported-features) article.

## Set environment variables and create a resource group

1. Set the environment variables used throughout this article. Replace the placeholder values with your own values.

    ```bash
    export SUBSCRIPTION_ID="<subscription-id>"
    export RG_NAME="<resource-group-name>"
    export LOCATION="<location>"
    export VNET_NAME="<vnet-name>"
    export SUBNET_NAME="<subnet-name>"
    export IDENTITY_NAME="<managed-identity-name>"
    export CLUSTER_NAME="<cluster-name>"
    ```
2. Select your Azure subscription using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription $SUBSCRIPTION_ID
    ```
3. Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create \
        --name $RG_NAME \
        --location $LOCATION
    ```

## Create a virtual network and subnet

1. Create a VNet using the [`az network vnet create`](/en-us/cli/azure/network/vnet#az-network-vnet-create) command.

    ```azurecli
    az network vnet create \
        --name $VNET_NAME \
        --resource-group $RG_NAME \
        --location $LOCATION \
        --address-prefixes 172.19.0.0/16
    ```
2. Create a node subnet using the [`az network vnet subnet create`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-create) command.

    ```azurecli
    az network vnet subnet create \
        --resource-group $RG_NAME \
        --vnet-name $VNET_NAME \
        --name $SUBNET_NAME \
        --address-prefixes 172.19.0.0/24
    ```

## Create a managed identity and assign VNet permissions

1. Create a managed identity using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    ```azurecli
    az identity create \
        --resource-group $RG_NAME \
        --name $IDENTITY_NAME \
        --location $LOCATION
    ```
2. Use the [`az identity show`](/en-us/cli/azure/identity#az-identity-show) command to get the managed identity's principal ID and save it in an environment variable.

    ```azurecli
    IDENTITY_PRINCIPAL_ID=$(az identity show --resource-group $RG_NAME --name $IDENTITY_NAME --query principalId -o tsv)
    ```
3. Assign the Network Contributor role to the managed identity using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. The `--assignee-principal-type` parameter prevents failures caused by replication delays after creating the managed identity.

    Important

    The Network Contributor role at VNet scope grants broad permissions. Before you use this approach in production, review the [RBAC setup for custom subnet configurations](node-auto-provisioning-networking#rbac-setup-for-custom-subnet-configurations) and consider assigning scoped subnet permissions.

    ```azurecli
    az role assignment create \
        --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME/providers/Microsoft.Network/virtualNetworks/$VNET_NAME" \
        --role "Network Contributor" \
        --assignee-object-id $IDENTITY_PRINCIPAL_ID \
        --assignee-principal-type ServicePrincipal
    ```

## Enable NAP and connect to the cluster

Use the managed identity, VNet, and node subnet that you created in the previous sections. The cluster must use a Standard Load Balancer, as described in Limitations.

1. Create an AKS cluster with NAP enabled in your custom VNet using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. The following table describes the NAP and networking parameters used in the command:

    | Parameter | Value | Description |
    | --- | --- | --- |
    | `--node-provisioning-mode` | `Auto` | Enables NAP on the cluster. |
    | `--network-plugin` | `azure` | Uses Azure CNI for cluster networking. |
    | `--network-plugin-mode` | `overlay` | Uses Azure CNI Overlay for pod networking. |
    | `--network-dataplane` | `cilium` | Uses the Cilium data plane. |

    For more information, see [Overview of networking configurations for node auto-provisioning (NAP) in Azure Kubernetes Service (AKS)](node-auto-provisioning-networking).

    ```azurecli
    az aks create \
        --name $CLUSTER_NAME \
        --resource-group $RG_NAME \
        --location $LOCATION \
        --assign-identity "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$IDENTITY_NAME" \
        --network-dataplane cilium \
        --network-plugin azure \
        --network-plugin-mode overlay \
        --vnet-subnet-id "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$SUBNET_NAME" \
        --node-provisioning-mode Auto \
        --generate-ssh-keys
    ```

    When cluster creation finishes, the command returns JSON-formatted information about the cluster.
2. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials \
        --resource-group $RG_NAME \
        --name $CLUSTER_NAME
    ```
3. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. This command returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```