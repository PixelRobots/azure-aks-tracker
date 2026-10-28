---
layout: Conceptual
title: 'Tutorial: Add an Azure Linux node pool to your existing Azure Kubernetes Service (AKS) cluster | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-add-azure-linux-node-pool
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
description: In this Azure Linux tutorial, you learn how to add an Azure Linux node pool to your existing Azure Kubernetes Service (AKS) cluster.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: f8ff079c-2367-cdb6-c45e-51ca94f4112e
document_version_independent_id: a7766b78-2917-d522-1bae-111fa9a711eb
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-add-azure-linux-node-pool.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-add-azure-linux-node-pool
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-add-azure-linux-node-pool.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 1c45a000-cdc0-578e-9d05-37fb3440ad79
---

# Tutorial: Add an Azure Linux node pool to your existing Azure Kubernetes Service (AKS) cluster | Microsoft Learn

In AKS, nodes with the same configurations are grouped together into node pools. Each pool contains the VMs that run your applications. In the previous tutorial, you created an Azure Linux Container Host cluster with a single node pool. To meet the varying compute or storage requirements of your applications, you can create extra user node pools.

In this tutorial, part *two of five*, you learn how to:

- Add an Azure Linux node pool.
- Check the status of your node pools.

The commands in this tutorial use the environment variables set in [Tutorial 1: Create a cluster with the Azure Linux Container Host for AKS](tutorial-create-cluster-azure-linux-aks).

In later tutorials, you learn how to migrate nodes to Azure Linux and enable telemetry to monitor your clusters.

## Prerequisites

- In the previous tutorial, you created and deployed an Azure Linux Container Host cluster. If you haven't done these steps and would like to follow along, start with [Tutorial 1: Create a cluster with the Azure Linux Container Host for AKS](tutorial-create-cluster-azure-linux-aks).
- You need the latest version of Azure CLI. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Set environment variables

Set the following environment variables to create unique resource names for each deployment. Replace the placeholder `<your-node-pool-name>` with a name of your choice. You can optionally append a random suffix to ensure uniqueness. The name of a node pool must start with a lowercase letter and can only contain alphanumeric characters. For Linux node pools the length must be between one and 12 characters.

```bash
# Set random suffix for uniqueness
export RANDOM_SUFFIX=$(openssl rand -hex 3)

# Set node pool name
export NODE_POOL_NAME="<your-node-pool-name>$RANDOM_SUFFIX"
```

## Add an Azure Linux node pool

Add an Azure Linux node pool to your existing cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az_aks_nodepool_add) command and specify `--os-sku AzureLinux`. The following example creates a node pool that runs three nodes in the cluster from [Tutorial 1: Create a cluster with the Azure Linux Container Host for AKS](tutorial-create-cluster-azure-linux-aks).

```azurecli
az aks nodepool add \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --node-count 3 \
    --os-sku AzureLinux
```

Example output:

```JSON
{
  "agentPoolType": "VirtualMachineScaleSets",
  "count": 3,
  "name": "alnodepool",
  "osType": "Linux",
  "provisioningState": "Succeeded",
  "resourceGroup": "testAzureLinuxResourceGroupxxxxx",
  "type": "Microsoft.ContainerService/managedClusters/agentPools"
}
```

## Check the node pool status

Check the status of your node pools using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az_aks_nodepool_list) command.

```azurecli
az aks nodepool list --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME
```

Example output:

```output
[
  {
    "agentPoolType": "VirtualMachineScaleSets",
    "availabilityZones": null,
    "count": 1,
    "enableAutoScaling": false,
    "enableEncryptionAtHost": false,
    "enableFips": false,
    "enableNodePublicIp": false,
    "id": "/subscriptions/REDACTED/resourcegroups/myAKSResourceGroupxxxxx/providers/Microsoft.ContainerService/managedClusters/myAKSClusterxxxxx/agentPools/nodepoolx",
    "maxPods": 110,
    "mode": "System",
    "name": "nodepoolx",
    "nodeImageVersion": "AKSUbuntu-1804gen2containerd-2023.06.06",
    "orchestratorVersion": "1.25.6",
    "osDiskSizeGb": 128,
    "osDiskType": "Managed",
    "osSku": "Ubuntu",
    "osType": "Linux",
    "powerState": {
      "code": "Running"
    },
    "provisioningState": "Succeeded",
    "resourceGroup": "myAKSResourceGroupxxxxx",
    "type": "Microsoft.ContainerService/managedClusters/agentPools",
    "vmSize": "Standard_DS2_v2"
  },
  {
    "agentPoolType": "VirtualMachineScaleSets",
    "availabilityZones": null,
    "count": 3,
    "enableAutoScaling": false,
    "enableEncryptionAtHost": false,
    "enableFips": false,
    "enableNodePublicIp": false,
    "id": "/subscriptions/REDACTED/resourcegroups/myAKSResourceGroupxxxxx/providers/Microsoft.ContainerService/managedClusters/myAKSClusterxxxxx/agentPools/npxxxxxx",
    "maxPods": 110,
    "mode": "User",
    "name": "npxxxxxx",
    "nodeImageVersion": "AzureLinuxContainerHost-2023.06.06",
    "orchestratorVersion": "1.25.6",
    "osDiskSizeGb": 128,
    "osDiskType": "Managed",
    "osSku": "AzureLinux",
    "osType": "Linux",
    "powerState": {
      "code": "Running"
    },
    "provisioningState": "Succeeded",
    "resourceGroup": "myAKSResourceGroupxxxxx",
    "type": "Microsoft.ContainerService/managedClusters/agentPools",
    "vmSize": "Standard_DS2_v2"
  }
]
```