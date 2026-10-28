---
layout: Conceptual
title: 'Tutorial: Upgrade Azure Container Linux (ACL) Nodes | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-upgrade-azure-container-linux-nodes
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
description: In this Azure Linux tutorial, you learn how to upgrade Azure Container Linux (ACL) nodes in an Azure Kubernetes Service (AKS) cluster.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 210e1c0c-92c4-1bdd-0fae-8f4c56750359
document_version_independent_id: 43f22010-7f69-eeea-e427-3419955d21e7
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-upgrade-azure-container-linux-nodes.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-upgrade-azure-container-linux-nodes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-upgrade-azure-container-linux-nodes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 4e7e7df5-93aa-6c0c-c381-17792d6fa629
---

# Tutorial: Upgrade Azure Container Linux (ACL) Nodes | Microsoft Learn

ACL delivers updates through weekly node images that include the latest security patches and bug fixes. As part of the application and cluster lifecycle, we recommend keeping your clusters up to date and secured by enabling upgrades for your cluster. You can enable automatic node image upgrades to ensure your clusters use the latest ACL image when it scales up. You can also manually upgrade the node image on a cluster.

In this tutorial, part *five of five*, you learn how to:

- Manually upgrade the node image on a cluster.
- Automatically upgrade an ACL cluster.

The commands in this tutorial use the environment variables set in [Tutorial 1: Create a cluster with ACL for AKS](tutorial-create-cluster-azure-container-linux-aks).

Note

Any upgrade operation, whether performed manually or automatically, upgrades the node image version if it's not already on the latest version. The latest version is contingent on a full AKS release, and you can determine it by visiting the [AKS release tracker](/en-us/azure/aks/release-tracker).

Important

`NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image) for ACL. `Unmanaged` and `SecurityPatch` are incompatible with ACL due to the immutable `/usr` directory. Automatic A/B updates for the OS partition aren't yet available.

## Prerequisites

- In previous tutorials, you created and deployed an ACL cluster. To complete this tutorial, you need an existing cluster. If you haven't completed this step and want to follow along, see [Tutorial 1: Create a cluster with ACL for AKS](tutorial-create-cluster-azure-container-linux-aks).
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

## Manually upgrade your cluster

Manually upgrade the node image on your cluster using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command.

```azurecli
az aks nodepool upgrade --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name <node-pool-name>
```

## Automatically upgrade your cluster

Automatic upgrades are functionally the same as manual upgrades. The selected channel determines the timing of upgrades. When making changes to auto-upgrade, allow 24 hours for the changes to take effect.

Set the auto-upgrade channel on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az_aks_update) command with the `--auto-upgrade-channel` parameter. The following example sets the auto-upgrade channel to `stable` for an existing cluster:

```azurecli
az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --auto-upgrade-channel stable
```

Example output:

```json
{
  "id": "/subscriptions/xxxxx/resourceGroups/myACLResourceGroup",
  "location": "westus",
  "name": "myACLCluster",
  "properties": {
    "autoUpgradeChannel": "stable",
    "provisioningState": "Succeeded"
  }
}
```

For more information on upgrade channels, see [Using cluster auto-upgrade](/en-us/azure/aks/auto-upgrade-cluster).

## Automatically upgrade your node OS image

AKS provides multiple auto-upgrade channels dedicated to timely node-level OS security updates. This channel is different from cluster-level Kubernetes version upgrades and supersedes it.

Set the node OS upgrade channel on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--node-os-upgrade-channel` parameter. The following example sets the node OS upgrade channel to `NodeImage` for an existing cluster:

```azurecli
az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-os-upgrade-channel NodeImage
```

Example output:

```json
{
  "id": "/subscriptions/xxxxx/resourceGroups/myACLResourceGroup",
  "location": "westus",
  "name": "myACLCluster",
  "properties": {
    "nodeOsUpgradeChannel": "NodeImage",
    "provisioningState": "Succeeded"
  }
}
```

For more information on node upgrade channels, see [Using node OS auto-upgrade](/en-us/azure/aks/auto-upgrade-node-os-image).

## ACL versioning

ACL releases weekly AKS node images. Versioning follows the AKS date-based format (for example: `202506.13.0`). You can check available node images in the release notes and view the `nodeImageVersion` for a running cluster using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command.

```azurecli
az aks nodepool list \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --query '[].{name: name, nodeImageVersion: nodeImageVersion}'
```

Example output:

```json
[
  {
    "name": "nodepool1",
    "nodeImageVersion": "AKSAzureContainerLinux-202606.01.0"
  }
]
```

## Clean up resources

As this tutorial is the last part of the series, you might want to delete your ACL cluster. The Kubernetes nodes run on Azure virtual machines (VMs) and continue incurring charges even if you don't use the cluster.

Delete the Azure resource group and all related resources using the [`az group delete`](/en-us/cli/azure/group#az_group_delete) command.

```azurecli
az group delete --name $RESOURCE_GROUP --yes --no-wait
```