---
layout: Conceptual
title: 'Tutorial: Upgrade Azure Linux Container Host Nodes | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-upgrade-azure-linux-nodes
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
description: In this Azure Linux tutorial, you learn how to upgrade Azure Linux Container Host nodes in an Azure Kubernetes Service (AKS) cluster.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 52419087-2581-761f-a397-e93a6383face
document_version_independent_id: 646578a0-1502-6a6c-76ad-17ffe7bfb502
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-upgrade-azure-linux-nodes.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-upgrade-azure-linux-nodes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-upgrade-azure-linux-nodes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 93cef42b-4a79-3008-4c34-c818a2b84a19
---

# Tutorial: Upgrade Azure Linux Container Host Nodes | Microsoft Learn

The Azure Linux Container Host ships updates through two mechanisms: updated Azure Linux node images and automatic package updates.

As part of the application and cluster lifecycle, we recommend keeping your clusters up to date and secured by enabling upgrades for your cluster. You can enable automatic node image upgrades to ensure your clusters use the latest Azure Linux Container Host image when it scales up. You can also manually upgrade the node image on a cluster.

In this tutorial, part *five of five*, you learn how to:

- Manually upgrade the node image on a cluster.
- Automatically upgrade an Azure Linux Container Host cluster.
- Deploy Kured in an Azure Linux Container Host cluster.

The commands in this tutorial use the environment variables set in [Tutorial 1: Create a cluster with the Azure Linux Container Host for AKS](tutorial-create-cluster-azure-linux-aks) and [Tutorial 2: Add an Azure Linux node pool to your existing AKS cluster](tutorial-add-azure-linux-node-pool).

Note

Any upgrade operation, whether performed manually or automatically, upgrades the node image version if not already on the latest. The latest version is contingent on a full AKS release, and can be determined by visiting the [AKS release tracker](/en-us/azure/aks/release-tracker).

## Prerequisites

- In previous tutorials, you created and deployed an Azure Linux Container Host cluster. To complete this tutorial, you need an existing cluster. If you haven't done this step and would like to follow along, start with [Tutorial 1: Create a cluster with the Azure Linux Container Host for AKS](tutorial-create-cluster-azure-linux-aks).
- You need the latest version of Azure CLI. Find the version using the `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Manually upgrade your cluster

Manually upgrade the node image on a cluster using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) command.

```azurecli
az aks nodepool upgrade --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --name $NODE_POOL_NAME
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
  "id": "/subscriptions/xxxxx/resourceGroups/testAzureLinuxResourceGroup",
  "location": "WestUS2",
  "name": "testAzureLinuxCluster",
  "properties": {
    "autoUpgradeChannel": "stable",
    "provisioningState": "Succeeded"
  }
}
```

For more information on upgrade channels, see [Using cluster auto-upgrade](/en-us/azure/aks/auto-upgrade-cluster).

## Enable automatic package upgrades

You can also enable automatic package upgrades. If automatic package upgrades are enabled, the dnf-automatic systemd service runs daily and installs any updated packages that have been published.

Set the node OS upgrade channel on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az_aks_update) command with the `--node-os-upgrade-channel` parameter. The following example sets the node OS upgrade channel to `Unmanaged` for an existing cluster:

```azurecli
az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-os-upgrade-channel Unmanaged
```

Example output:

```json
{
  "id": "/subscriptions/xxxxx/resourceGroups/testAzureLinuxResourceGroup",
  "location": "WestUS2",
  "name": "testAzureLinuxCluster",
  "properties": {
    "nodeOsUpgradeChannel": "Unmanaged",
    "provisioningState": "Succeeded"
  }
}
```

## Enable an automatic reboot daemon

To protect your clusters, security updates are automatically applied to Azure Linux nodes. These updates include OS security fixes, kernel updates, and package upgrades. Some of these updates require a node reboot to complete the process. AKS doesn't automatically reboot these nodes to complete the update process.

We recommend enabling an automatic reboot daemon, such as [Kured](https://kured.dev/docs/), so that your cluster can reboot nodes that have taken kernel updates. To deploy the Kured DaemonSet in an Azure Linux Container Host cluster, see [Deploy Kured in an AKS cluster](/en-us/azure/aks/node-updates-kured#deploy-kured-in-an-aks-cluster).

## Clean up resources

As this tutorial is the last part of the series, you might want to delete your Azure Linux Container Host cluster. The Kubernetes nodes run on Azure virtual machines (VMs) and continue incurring charges even if you don't use the cluster.

Delete the Azure resource group and all related resources using the [`az group delete`](/en-us/cli/azure/group#az_group_delete) command.

```azurecli
az group delete --name $RESOURCE_GROUP --yes --no-wait
```