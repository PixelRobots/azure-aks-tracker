---
layout: Conceptual
title: Use Azure tags in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-tags
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
description: Learn how to use Azure provider tags to track resources in Azure Kubernetes Service (AKS).
ms.topic: concept-article
ms.custom: devx-track-azurecli
ms.date: 2023-06-16T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
locale: en-us
document_id: 451f1185-b94e-c59d-0497-d9b083f41859
document_version_independent_id: 8390e8f1-02f6-a0e6-59b2-b7c9f7de3de2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-tags.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-tags
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-tags.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 738bbc80-9e54-bbff-e9f5-c8ea94c27e3b
---

# Use Azure tags in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

With Azure Kubernetes Service (AKS), you can set Azure tags on an AKS cluster and its related resources using Azure Resource Manager and the Azure CLI. You can also use Kubernetes manifests to set Azure tags for certain resources. Azure tags are a useful tracking resource for certain business processes, such as *chargeback*.

This article explains how to set Azure tags for AKS clusters and related resources.

## Before you begin

Review the following information before you begin:

- Tags set on an AKS cluster apply to all resources related to the cluster, but not the node pools. This operation overwrites the values of existing keys.
- Tags set on a node pool apply only to resources related to that node pool. This operation overwrites the values of existing keys. Resources outside that node pool, including resources for the rest of the cluster and other node pools, are unaffected.
- Public IPs, files, and disks can have tags set by Kubernetes through a Kubernetes manifest. For disks and files created through a `StorageClass`, the `tags` parameter is applied to the underlying Azure resource when AKS provisions the volume. Updating the `StorageClass` later affects only newly provisioned volumes. When you remove public IPs, files, or disks through Kubernetes, any tags set by Kubernetes are removed. The tags on those resources that Kubernetes doesn't track remain unaffected.

### Prerequisites

- The Azure CLI version 2.0.59 or later. To find your version, run `az --version`. If you need to install it or update your version, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Kubernetes version 1.20 or later.

### Limitations

- Azure tags have keys that are case-insensitive for operations, such as when you're retrieving a tag by searching the key. In this case, a tag with the specified key is updated or retrieved regardless of casing. Tag values are case-sensitive.
- In AKS, if multiple tags are set with identical keys but different casing, the tags are used in alphabetical order. For example, `{"Key1": "val1", "kEy1": "val2", "key1": "val3"}` results in `Key1` and `val1` being set.
- For shared resources, tags can't determine the split in resource usage on their own.
- For disks and files that back a Kubernetes persistent volume, the `PersistentVolume` spec is immutable after creation. Editing or patching an existing `PersistentVolume` to change tags or other volume attributes fails.
- Updating tags directly on the underlying Azure resource doesn't synchronize those tag values back to the Kubernetes `PersistentVolume` YAML or metadata.

## Azure tags and AKS clusters

When you create or update an AKS cluster with the `--tags` parameter, the following are assigned the Azure tags that you specified:

- The AKS cluster itself and its related resources:
    - Route table
    - Public IP
    - Load balancer
    - Network security group
    - Virtual network
    - AKS-managed kubelet msi
    - AKS-managed add-on msi
    - Private DNS zone associated with the *private cluster*
    - Private endpoint associated with the *private cluster*
- The node resource group

Note

Azure Private DNS only supports 15 tags. For more information, see the [tag resources](/en-us/azure/azure-resource-manager/management/tag-resources).

## Create or update tags on an AKS cluster

### Create a new AKS cluster

Important

If you're using existing resources when you create a new cluster, such as an IP address or route table, the `az aks create` command overwrites the set of tags. If you delete the cluster later, any tags set by the cluster are removed.

1. Create a cluster and assign Azure tags using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--tags` parameter.

    Note

    To set tags on the initial node pool, the virtual machine scale set, and each virtual machine scale set instance associated with the initial node pool, you can also set the `--nodepool-tags` parameter.

    ```azurecli
    az aks create \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --tags dept=IT costcenter=9999 \
        --generate-ssh-keys
    ```
2. Verify the tags have been applied to the cluster and its related resources using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show --resource-group myResourceGroup --name myAKSCluster --query '[tags]'
    ```

    The following example output shows the tags applied to the cluster:

    ```output
    {
      "clusterTags": {
        "dept": "IT",
        "costcenter": "9999"
      }
    }
    ```

### Update an existing AKS cluster

Important

Setting tags on a cluster using the `az aks update` command overwrites the set of tags. For example, if your cluster has the tags *dept=IT* and *costcenter=9999*, and you use `az aks update` with the tags *team=alpha* and *costcenter=1234*, the new list of tags would be *team=alpha* and *costcenter=1234*.

1. Update the tags on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--tags` parameter.

    ```azurecli
    az aks update \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --tags team=alpha costcenter=1234
    ```
2. Verify the tags have been applied to the cluster and its related resources using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show --resource-group myResourceGroup --name myAKSCluster --query '[tags]'
    ```

    The following example output shows the tags applied to the cluster:

    ```output
    {
      "clusterTags": {
        "team": "alpha",
        "costcenter": "1234"
      }
    }
    ```

## Add tags to node pools

You can apply an Azure tag to a new or existing node pool in your AKS cluster. Tags applied to a node pool are applied to each node within the node pool and are persisted through upgrades. Tags are also applied to new nodes that are added to a node pool during scale-out operations. Adding a tag can help with tasks such as policy tracking or cost estimation.

When you create or update a node pool with the `--tags` parameter, the tags you specify are assigned to the following resources:

- The node pool.
- The virtual machine scale set and each virtual machine scale set instance associated with the node pool.

### Create a new node pool

1. Create a node pool with an Azure tag using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--tags` parameter.

    ```azurecli
    az aks nodepool add \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name tagnodepool \
        --node-count 1 \
        --tags abtest=a costcenter=5555 \
        --no-wait
    ```
2. Verify that the tags have been applied to the node pool using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show --resource-group myResourceGroup --name myAKSCluster --query 'agentPoolProfiles[].{nodepoolName:name,tags:tags}'
    ```

    The following example output shows the tags applied to the node pool:

    ```output
    [
      {
        "nodepoolName": "nodepool1",
        "tags": null
      },
      {
        "nodepoolName": "tagnodepool",
        "tags": {
          "abtest": "a",
          "costcenter": "5555"
        }
      }
    ]
    ```

### Update an existing node pool

Important

Setting tags on a node pool using the `az aks nodepool update` command overwrites the set of tags. For example, if your node pool has the tags *abtest=a* and *costcenter=5555*, and you use `az aks nodepool update` with the tags *appversion=0.0.2* and *costcenter=4444*, the new list of tags would be *appversion=0.0.2* and *costcenter=4444*.

1. Update a node pool with an Azure tag using the [`az aks nodepool update`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-update) command.

    ```azurecli
    az aks nodepool update \
        --resource-group myResourceGroup \
        --cluster-name myAKSCluster \
        --name tagnodepool \
        --tags appversion=0.0.2 costcenter=4444 \
        --no-wait
    ```
2. Verify the tags have been applied to the node pool using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show --resource-group myResourceGroup --name myAKSCluster --query 'agentPoolProfiles[].{nodepoolName:name,tags:tags}'
    ```

    The following example output shows the tags applied to the node pool:

    ```output
    [
      {
        "nodepoolName": "nodepool1",
        "tags": null
      },
      {
        "nodepoolName": "tagnodepool",
        "tags": {
          "appversion": "0.0.2",
          "costcenter": "4444"
        }
      }
    ]
    ```

## Add tags using Kubernetes

Important

Setting tags on files, disks, and public IPs using Kubernetes updates the set of tags. For example, if your disk has the tags *dept=IT* and *costcenter=5555*, and you use Kubernetes to set the tags *team=beta* and *costcenter=3333*, the new list of tags would be *dept=IT*, *team=beta*, and *costcenter=3333*.

Any updates you make to tags through Kubernetes retain the value set through Kubernetes. For example, if your disk has tags *dept=IT* and *costcenter=5555* set by Kubernetes, and you use the portal to set the tags *team=beta* and *costcenter=3333*, the new list of tags would be *dept=IT*, *team=beta*, and *costcenter=5555*. If you then remove the disk through Kubernetes, the disk would have the tag *team=beta*.

For disks and files that back a persistent volume, the `tags` value in a `StorageClass` is a provisioning-time setting. After the volume is created, the `PersistentVolume` spec is immutable, so editing or patching the PV to change tags or other volume attributes fails. Changes you make directly to the underlying Azure resource don't synchronize back to the PV YAML or metadata.

You can apply Azure tags to public IPs, disks, and files using a Kubernetes manifest.

- For public IPs, use *service.beta.kubernetes.io/azure-pip-tags* under *annotations*. For example:

    ```yml
    apiVersion: v1
    kind: Service
    metadata:
      annotations:
        service.beta.kubernetes.io/azure-pip-tags: costcenter=3333,team=beta
    spec:
      ...
    ```
- For files and disks, use *tags* under *parameters*. For example:

    ```yml
    ---
    apiVersion: storage.k8s.io/v1
    ...
    parameters:
      ...
      tags: costcenter=3333,team=beta
    ...
    ```

### Update tags for existing persistent volumes

To update tags for an existing disk-backed or file-backed persistent volume, update the tags on the underlying Azure resource instead of editing the `PersistentVolume`. This operation doesn't interrupt existing mounts, pods, or data access.

- For Azure Disk-backed persistent volumes, update the managed disk directly. For example:

    ```azurecli
    az disk update \
        --name myManagedDisk \
        --resource-group MC_myResourceGroup_myAKSCluster_eastus \
        --set tags.abc=ABC123
    ```
- For Azure Files-backed persistent volumes, update the storage account directly. For example:

    ```azurecli
    az storage account update \
        --name mystorageaccount \
        --resource-group MC_myResourceGroup_myAKSCluster_eastus \
        --set tags.abc=ABC123
    ```

Changes to a `StorageClass` affect only newly provisioned volumes and don't update existing persistent volumes.