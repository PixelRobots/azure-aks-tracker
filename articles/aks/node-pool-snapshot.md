---
layout: Conceptual
title: Snapshot Azure Kubernetes Service (AKS) node pools - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-pool-snapshot
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
description: Learn how to snapshot AKS cluster node pools and create clusters and node pools from a snapshot.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2024-01-29T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ms.subservice: aks-nodes
locale: en-us
document_id: ade06cae-79de-3e2c-ec9b-8c0185ffc57c
document_version_independent_id: 10ba08f6-0766-d920-3e6a-6b99e4c18207
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-pool-snapshot.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/node-pool-snapshot
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-pool-snapshot.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ec6262f7-7cac-f852-8623-4a936e2b1dfd
---

# Snapshot Azure Kubernetes Service (AKS) node pools - Azure Kubernetes Service | Microsoft Learn

AKS releases a new node image weekly. Every new cluster, new node pool, or upgrade cluster always receives the latest image, which can make it hard to maintain consistency and have repeatable environments.

Node pool snapshots allow you to take a configuration snapshot of your node pool and then create new node pools or new clusters based of that snapshot for as long as that configuration and kubernetes version is supported. For more information on the supportability windows, see [Supported Kubernetes versions in AKS](supported-kubernetes-versions).

The snapshot is an Azure resource that contains the configuration information from the source node pool, such as the node image version, kubernetes version, OS type, and OS SKU. You can then reference this snapshot resource and the respective values of its configuration to create any new node pool or cluster based off of it.

## Before you begin

This article assumes that you have an existing AKS cluster. If you don't have an AKS cluster, for guidance on a designing an enterprise-scale implementation of AKS, see [Plan your AKS design](/en-us/azure/architecture/reference-architectures/containers/aks-start-here?toc=/azure/aks/toc.json&amp;bc=/azure/aks/breadcrumb/toc.json).

### Limitations

- Any node pool or cluster created from a snapshot must use a VM from the same virtual machine family as the snapshot, for example, you can't create a new N-Series node pool based of a snapshot captured from a D-Series node pool because the node images in those cases are structurally different.
- Snapshots must be created same region as the source node pool, those snapshots can be used to create or update clusters and node pools in other regions.

## Take a node pool snapshot

In order to take a snapshot from a node pool, you need the node pool resource ID, which you can get from the following command:

```azurecli
NODEPOOL_ID=$(az aks nodepool show --name nodepool1 --cluster-name myAKSCluster --resource-group myResourceGroup --query id -o tsv)
```

Important

Your AKS node pool must be created or upgraded after Nov 10th, 2021 in order for a snapshot to be taken from it. If you are using the `aks-preview` Azure CLI extension version `0.5.59` or newer, the commands for node pool snapshot have changed. For updated commands, see the [Node Pool Snapshot CLI reference](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add).

Now, to take a snapshot from the previous node pool, you use the `az aks snapshot` CLI command.

```azurecli
az aks nodepool snapshot create --name MySnapshot --resource-group MyResourceGroup --nodepool-id $NODEPOOL_ID --location eastus
```

## Create a node pool from a snapshot

First, you need the resource ID from the snapshot that was previously created, which you can get from the following command:

```azurecli
SNAPSHOT_ID=$(az aks nodepool snapshot show --name MySnapshot --resource-group myResourceGroup --query id -o tsv)
```

Now, we can use the following command to add a new node pool based off of this snapshot.

```azurecli
az aks nodepool add --name np2 --cluster-name myAKSCluster --resource-group myResourceGroup --snapshot-id $SNAPSHOT_ID
```

## Upgrading a node pool to a snapshot

You can upgrade a node pool to a snapshot configuration if the snapshot Kubernetes version and node image version are more recent than the current node pool versions. And the snapshot node image version is within 90 days of the node image publish date.

First, you need the resource ID from the snapshot that was previously created, which you can get from the following command:

```azurecli
SNAPSHOT_ID=$(az aks nodepool snapshot show --name MySnapshot --resource-group myResourceGroup --query id -o tsv)
```

Now, we can use this command to upgrade this node pool to this snapshot configuration.

```azurecli
az aks nodepool upgrade --name nodepool1 --cluster-name myAKSCluster --resource-group myResourceGroup --snapshot-id $SNAPSHOT_ID
```

Note

Your node pool image version is the same contained in the snapshot and remains the same throughout every scale operation. However, if this node pool is upgraded or a node image upgrade is performed without providing a snapshot-id the node image is upgraded to the latest version.

Note

To upgrade only the node version for your node pool, use the `--node-image-only` flag. This is required when upgrading the node image version for a node pool based on a snapshot with an identical Kubernetes version.

## Create a cluster from a snapshot

When you create a cluster from a snapshot, the snapshot configuration creates the cluster original system pool.

First, you need the resource ID from the snapshot that was previously created, which you can get from the following command:

```azurecli
SNAPSHOT_ID=$(az aks nodepool snapshot show --name MySnapshot --resource-group myResourceGroup --query id -o tsv)
```

Now, we can use this command to create this cluster off of the snapshot configuration.

```azurecli
az aks create \
    --name myAKSCluster2 \
    --resource-group myResourceGroup \
    --snapshot-id $SNAPSHOT_ID \
    --generate-ssh-keys
```