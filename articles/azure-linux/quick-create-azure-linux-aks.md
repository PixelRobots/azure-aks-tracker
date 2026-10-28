---
layout: Conceptual
title: 'Quickstart: Create a Cluster with the Azure Linux Container Host for AKS | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/quick-create-azure-linux-aks
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
description: Learn how to quickly create a cluster with the Azure Linux Container Host for AKS and connect to it using `kubectl`.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: quickstart
ms.date: 2026-04-26T00:00:00.0000000Z
locale: en-us
document_id: 7d980abc-0a41-b276-08f5-775f69409ef0
document_version_independent_id: 19b3b113-61a8-cf47-311e-b09207607f54
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/quick-create-azure-linux-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/quick-create-azure-linux-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/quick-create-azure-linux-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 526c45ad-b9dc-9d84-3a6c-b50f358beec6
---

# Quickstart: Create a Cluster with the Azure Linux Container Host for AKS | Microsoft Learn

The Azure Linux container host for AKS delivers fast boot times, predictable updates, and strong security defaults with tight AKS lifecycle integration. Microsoft owns the full stack from kernel to CVE response, simplifying operations and reducing customer overhead. For more information, see [Azure Linux for AKS](azure-linux-aks-overview).

In this quickstart, you learn how to:

- Install the Kubernetes CLI, `kubectl`.
- Create an Azure resource group.
- Create and deploy an Azure Linux Container Host cluster.
- Configure `kubectl` to connect to your Azure Linux Container Host cluster.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Prerequisites

- You need the latest version of Azure CLI. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Set environment variables

Set the following environment variables to ensure consistent naming across your deployment. In this quickstart, we set the resource group name to *testAzureLinuxResourceGroup*, the cluster name to *testAzureLinuxCluster*, and the location to *EastUS2*.

```azurecli
export RESOURCE_GROUP=testAzureLinuxResourceGroup
export CLUSTER_NAME=testAzureLinuxCluster
export LOCATION=EastUS2
```

## Create a resource group

To create a cluster with the Azure Linux Container Host, you use:

- An [Azure resource group](/en-us/azure/azure-resource-manager/management/overview): A logical container into which Azure resources are deployed and managed.
- [AKS](/en-us/azure/aks/intro-kubernetes): A hosted Kubernetes service that allows you to quickly create a production ready Kubernetes cluster.

When creating a resource group, you're required to specify a location. This location is:

- The storage location of your resource group metadata.
- Where your resources run in Azure if you don't specify another region when creating a resource.

Create the resource group using the [`az group create`](/en-us/cli/azure/group#az_group_create) command with the resource group name and region environment variables you set earlier.

```azurecli
az group create --name $RESOURCE_GROUP --location $LOCATION
```

Example output:

```JSON
{
  "id": "/subscriptions/xxxxx/resourceGroups/testAzureLinuxResourceGroup",
  "location": "EastUS2",
  "managedBy": null,
  "name": "testAzureLinuxResourceGroup",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

## Create an Azure Linux Container Host cluster

Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az_aks_create) command with the `--os-sku` parameter to provision the Azure Linux Container Host with an Azure Linux image. The following example creates an Azure Linux Container Host cluster named *testAzureLinuxCluster* in the resource group *testAzureLinuxResourceGroup*:

```azurecli
az aks create --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --os-sku AzureLinux
```

Example output:

```JSON
{
  "id": "/subscriptions/xxxxx/resourceGroups/testAzureLinuxResourceGroup/providers/Microsoft.ContainerService/managedClusters/testAzureLinuxCluster",
  "location": "EastUS2",
  "name": "testAzureLinuxCluster",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "type": "Microsoft.ContainerService/managedClusters"
}
```

After a few minutes, the command completes and returns JSON-formatted information about the cluster.

## Connect to the cluster using kubectl

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az_aks_get_credentials) command. The following example gets credentials for the Azure Linux Container Host cluster using the resource group and cluster name created earlier:

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```
2. Verify the connection to your cluster using the [`kubectl get nodes`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command to return a list of the cluster nodes:

    ```bash
    kubectl get nodes
    ```

    Example output:

    ```output
    NAME                           STATUS   ROLES   AGE     VERSION
    aks-nodepool1-00000000-0       Ready    agent   10m     v1.34.4
    aks-nodepool1-00000000-1       Ready    agent   10m     v1.34.4
    ```

    All nodes show a `Ready` status, confirming your Azure Linux Container Host cluster is running and reachable.

## Clean up resources

If you don't plan to continue using this cluster, delete the resource group to avoid ongoing charges using the [`az group delete`](/en-us/cli/azure/group#az_group_delete) command. Deleting the resource group removes the AKS cluster and all associated resources.

```azurecli
az group delete --name $RESOURCE_GROUP --yes --no-wait
```