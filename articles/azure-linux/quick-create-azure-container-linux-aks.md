---
layout: Conceptual
title: 'Quickstart: Deploy Azure Container Linux (ACL) for AKS | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/quick-create-azure-container-linux-aks
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
description: Learn how to quickly deploy Azure Container Linux (ACL) for Azure Kubernetes Service (AKS) and connect to the cluster using `kubectl`.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: quickstart
ms.date: 2026-04-26T00:00:00.0000000Z
locale: en-us
document_id: 2ce7e2ad-027e-9fd2-8d5a-6a0837897a90
document_version_independent_id: 7b20ac6c-4d02-8645-55a5-776cadf6ed94
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/quick-create-azure-container-linux-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/quick-create-azure-container-linux-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/quick-create-azure-container-linux-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a31f6bb7-bcbf-2e17-b8e6-a508701c5d02
---

# Quickstart: Deploy Azure Container Linux (ACL) for AKS | Microsoft Learn

Azure Container Linux (ACL) for Azure Kubernetes Service (AKS) is an immutable, container-optimized operating system for AKS node pools. For more information, see [Azure Container Linux for AKS](azure-container-linux-overview).

In this quickstart, you learn how to:

- Install the Azure CLI and `kubectl`.
- Create an Azure resource group.
- Deploy an AKS cluster that uses Azure Container Linux.
- Connect to the cluster and verify the nodes.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Prerequisites

- An Azure subscription. If you don't have one, create a [free account](https://azure.microsoft.com/free/).
- The latest version of Azure CLI. To install or upgrade Azure CLI, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The Kubernetes CLI, `kubectl`. To install it with Azure CLI, use the [`az aks install-cli`](/en-us/cli/azure/aks#az_aks_install_cli) command:

    ```azurecli
    az aks install-cli
    ```
- Permissions to create resource groups and AKS clusters in your Azure subscription.

## Set environment variables

Set the following environment variables to define the resource group name, cluster name, and location for your deployment. You can use the same values as shown here or replace them with names that are unique in your environment.

```bash
export RESOURCE_GROUP="acl-aks-rg"
export CLUSTER_NAME="acl-aks-cluster"
export LOCATION="eastus"
```

## Create a resource group

Create an [Azure resource group](/en-us/azure/azure-resource-manager/management/overview) for the AKS cluster using the [`az group create`](/en-us/cli/azure/group#az_group_create) command.

```azurecli
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
```

## Create an AKS cluster that uses Azure Container Linux

Create an AKS cluster that uses ACL using the [`az aks create`](/en-us/cli/azure/aks#az_aks_create) command with the `--os-sku` parameter set to `AzureContainerLinux`.

```azurecli
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 3 \
  --generate-ssh-keys \
  --os-sku AzureContainerLinux
```

The deployment takes a few minutes to complete.

## Connect to the cluster

1. After the cluster is deployed, configure `kubectl` to connect to it by retrieving the cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az_aks_get_credentials) command.

    ```azurecli
    az aks get-credentials \
      --resource-group $RESOURCE_GROUP \
      --name $CLUSTER_NAME
    ```
2. Verify the nodes are ready using the [`kubectl get nodes`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command to return a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

    Example output:

    ```output
    NAME                                STATUS   ROLES   AGE   VERSION
    aks-nodepool1-12345678-vmss000000   Ready    agent   5m    v1.34.4
    aks-nodepool1-12345678-vmss000001   Ready    agent   5m    v1.34.4
    aks-nodepool1-12345678-vmss000002   Ready    agent   5m    v1.34.4
    ```

## Clean up resources

If you don't plan to continue using this cluster, delete the resource group to avoid ongoing charges using the [`az group delete`](/en-us/cli/azure/group#az_group_delete) command. Deleting the resource group removes the AKS cluster and all associated resources.

```azurecli
az group delete --name $RESOURCE_GROUP --yes --no-wait
```