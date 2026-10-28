---
layout: Conceptual
title: 'Tutorial: Add an Azure Container Linux (ACL) node pool to your existing Azure Kubernetes Service (AKS) cluster | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-add-azure-container-linux-node-pool
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
description: In this Azure Linux tutorial, you learn how to add an Azure Container Linux (ACL) node pool to your existing AKS cluster.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 29a75d70-224b-165d-5ae9-d8fd965cf034
document_version_independent_id: a30c8461-2a2f-4805-ce8f-e27247e9c089
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-add-azure-container-linux-node-pool.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-add-azure-container-linux-node-pool
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-add-azure-container-linux-node-pool.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 090c911d-affa-0922-76d0-c40c7586fe82
---

# Tutorial: Add an Azure Container Linux (ACL) node pool to your existing Azure Kubernetes Service (AKS) cluster | Microsoft Learn

In AKS, nodes with the same configurations are grouped together into node pools. Each node pool contains the virtual machines (VMs) that run your applications. In the previous tutorial, you created an ACL cluster with a single node pool. To meet the varying compute, storage, or security requirements of your applications, you can add user node pools.

In this tutorial, part *two of five*, you learn how to:

- Add an ACL node pool to an existing cluster.
- Check the status of your node pools.

The commands in this tutorial use the environment variables set in [Tutorial 1: Create a cluster with ACL for AKS](tutorial-create-cluster-azure-container-linux-aks).

In later tutorials, you learn how to migrate nodes to ACL and enable telemetry to monitor your clusters.

## Prerequisites

- In the previous tutorial, you created and deployed an ACL cluster. If you haven't completed these steps and want to follow along, see [Tutorial 1: Create a cluster with ACL for AKS](tutorial-create-cluster-azure-container-linux-aks).
- Azure Container Linux requires Azure CLI version 2.86.0 or higher. Use the [`az version`](/en-us/cli/azure/reference-index?#az-version) command to find the version. To upgrade to the latest version, use the [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade) command.

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

## Add an ACL node pool

Add an ACL node pool into your existing cluster using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command and specify `--os-sku AzureContainerLinux`. The following example creates a node pool named *aclpool* that adds three nodes to the cluster:

```azurecli
az aks nodepool add \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --name aclpool \
    --node-count 3 \
    --os-sku AzureContainerLinux
```

Example output:

```JSON
{
  "agentPoolType": "VirtualMachineScaleSets",
  "count": 3,
  "name": "aclpool",
  "osType": "Linux",
  "osSku": "AzureContainerLinux",
  "provisioningState": "Succeeded",
  "resourceGroup": "myACLResourceGroup",
  "type": "Microsoft.ContainerService/managedClusters/agentPools"
}
```

Note

The name of a node pool must start with a lowercase letter and can only contain alphanumeric characters. For Linux node pools, the length must be between one and 12 characters.

## Check the node pool status

Check the status of your node pools using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command.

```azurecli
az aks nodepool list --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME
```

Example output:

```output
[
  {
    "agentPoolType": "VirtualMachineScaleSets",
    "count": 3,
    "name": "nodepool1",
    "nodeImageVersion": "AKSAzureContainerLinux-202606.01.0",
    "osSku": "AzureContainerLinux",
    "osType": "Linux",
    "provisioningState": "Succeeded",
    "resourceGroup": "myACLResourceGroup",
    "vmSize": "Standard_DS2_v2"
  },
  {
    "agentPoolType": "VirtualMachineScaleSets",
    "count": 3,
    "name": "aclpool",
    "nodeImageVersion": "AKSAzureContainerLinux-202606.01.0",
    "osSku": "AzureContainerLinux",
    "osType": "Linux",
    "provisioningState": "Succeeded",
    "resourceGroup": "myACLResourceGroup",
    "vmSize": "Standard_DS2_v2"
  }
]
```