---
layout: Conceptual
title: 'Tutorial: Create a Cluster with Azure Container Linux (ACL) for Azure Kubernetes Service (AKS) | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-create-cluster-azure-container-linux-aks
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
description: In this Azure Linux tutorial, you learn how to create a cluster with Azure Container Linux (ACL) for Azure Kubernetes Service (AKS).
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 3a1aa09c-db4b-7fda-c8d0-48c66af94d84
document_version_independent_id: c6902340-858f-060b-efc9-bf23ed3025fa
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-create-cluster-azure-container-linux-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-create-cluster-azure-container-linux-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-create-cluster-azure-container-linux-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 40e50e39-af5f-7488-4f29-80b286f24141
---

# Tutorial: Create a Cluster with Azure Container Linux (ACL) for Azure Kubernetes Service (AKS) | Microsoft Learn

In this tutorial, part *one of five*, you learn how to:

- Install the Kubernetes CLI, `kubectl`.
- Create an Azure resource group.
- Create and deploy an ACL cluster.
- Configure `kubectl` to connect to your ACL cluster.

In later tutorials, you learn how to add an ACL node pool to an existing cluster and migrate existing nodes to ACL.

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

## Prerequisites

- Azure Container Linux requires Azure CLI version 2.86.0 or higher. Use the [`az version`](/en-us/cli/azure/reference-index?#az-version) command to find the version. To upgrade to the latest version, use the [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade) command.

## Set environment variables

Set the following environment variables to create unique resource names for each deployment:

```bash
export RESOURCE_GROUP="<your-resource-group-name>"
export REGION="<your-region>"
export CLUSTER_NAME="<your-cluster-name>"
```

## Create a resource group

When creating a resource group in Azure, you're required to specify a location. This location is the storage location of your resource group metadata and where your resources run in Azure if you don't specify another region when creating a resource.

Create a resource group using the [`az group create`](/en-us/cli/azure/group#az_group_create) command.

```azurecli
az group create --name $RESOURCE_GROUP --location $REGION
```

Example output:

```JSON
{
  "id": "/subscriptions/xxxxx/resourceGroups/myACLResourceGroup",
  "location": "westus",
  "managedBy": null,
  "name": "myACLResourceGroup",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

## Create an ACL cluster

Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--os-sku AzureContainerLinux` parameter to provision an ACL cluster. The following example creates an ACL cluster with three nodes:

```azurecli
az aks create \
  --name $CLUSTER_NAME \
  --resource-group $RESOURCE_GROUP \
  --os-sku AzureContainerLinux \
  --node-count 3 \
  --generate-ssh-keys
```

Example output:

```JSON
{
  "id": "/subscriptions/xxxxx/resourceGroups/myACLResourceGroup/providers/Microsoft.ContainerService/managedClusters/myACLCluster",
  "location": "westus",
  "name": "myACLCluster",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "type": "Microsoft.ContainerService/managedClusters"
}
```

After a few minutes, the command completes and returns JSON-formatted information about the cluster.

## Connect to the cluster using kubectl

Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. The following example gets credentials for the ACL cluster:

```azurecli
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

## Verify the connection to your cluster

Verify the connection to your cluster using the [`kubectl get nodes`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command to return a list of the cluster nodes.

```bash
kubectl get nodes
```

Example output:

```text
NAME                                STATUS   ROLES   AGE     VERSION
aks-nodepool1-00000000-0            Ready    agent   10m     v1.34.0
aks-nodepool1-00000000-1            Ready    agent   10m     v1.34.0
aks-nodepool1-00000000-2            Ready    agent   10m     v1.34.0
```