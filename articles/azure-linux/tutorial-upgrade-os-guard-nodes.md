---
layout: Conceptual
title: 'Tutorial: Upgrade Azure Linux with OS Guard (Preview) Nodes | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/tutorial-upgrade-os-guard-nodes
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
description: In this Azure Linux tutorial, you learn how to upgrade Azure Linux with OS Guard (Preview) nodes in an Azure Kubernetes Service (AKS) cluster.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: tutorial
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 81db99de-0194-ca82-152c-856c38d68df8
document_version_independent_id: d39288b8-0cc4-1f25-8978-a59d95b329ee
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/tutorial-upgrade-os-guard-nodes.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/tutorial-upgrade-os-guard-nodes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/tutorial-upgrade-os-guard-nodes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: de1f8603-ad32-9a27-48ac-3a2e2c248647
---

# Tutorial: Upgrade Azure Linux with OS Guard (Preview) Nodes | Microsoft Learn

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Note

Azure Linux with OS Guard (preview) is being replaced by Azure Container Linux (ACL).

Azure Container Linux is the long‑term, immutable, container‑optimized Linux operating system (OS) for Azure Kubernetes Service (AKS). It provides a secure, minimal, and operationally consistent host OS designed to run containerized workloads at scale.

For more information, see the [Azure Container Linux (ACL) overview](azure-container-linux-overview).

Azure Linux with OS Guard ships updates through updated node images and automatic package updates. As part of the application and cluster lifecycle, we recommend keeping your clusters up to date and secured by enabling upgrades for your cluster. You can enable automatic node image upgrades to ensure your clusters use the latest Azure Linux with OS Guard image when it scales up. You can also manually upgrade the node image on a cluster.

In this tutorial, part *five of five*, you learn how to:

- Manually upgrade the node image on a cluster.
- Automatically upgrade an Azure Linux with OS Guard cluster.
- Deploy Kured in an Azure Linux with OS Guard cluster.

Note

Any upgrade operation, whether performed manually or automatically, upgrades the node image version if it's not already on the latest version. The latest version is contingent on a full AKS release, and you can determine it by visiting the [AKS release tracker](/en-us/azure/aks/release-tracker).

## Prerequisites

- In previous tutorials, you created and deployed an Azure Linux with OS Guard cluster. To complete this tutorial, you need an existing cluster. If you haven't completed this step and want to follow along, see [Tutorial 1: Create a cluster with Azure Linux with OS Guard for AKS](tutorial-create-cluster-os-guard-aks).
- You need the latest version of Azure CLI. Use the [`az version`](/en-us/cli/azure/reference-index?#az-version) command to find the version. To upgrade to the latest version, use the [`az upgrade`](/en-us/cli/azure/reference-index?#az-upgrade) command.

## Azure Linux with OS Guard considerations and limitations

Before you begin, review the following considerations and limitations for Azure Linux with OS Guard (preview):

- Kubernetes version 1.32.0 or higher is required for Azure Linux with OS Guard.
- All Azure Linux with OS Guard images have [Federal Information Process Standard (FIPS)](/en-us/azure/aks/enable-fips-nodes) and [Trusted Launch](/en-us/azure/aks/use-trusted-launch) enabled.
- Azure CLI and ARM templates are the only supported deployment methods for Azure Linux with OS Guard on AKS in preview. PowerShell and Terraform aren't supported.
- [Arm64](/en-us/azure/aks/use-arm64-vms) images aren't supported with Azure Linux with OS Guard on AKS in preview.
- `NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image) for Azure Linux with OS Guard on AKS. `Unmanaged` and `SecurityPatch` are incompatible with Azure Linux with OS Guard due to the immutable /usr directory.
- [Artifact Streaming](/en-us/azure/aks/artifact-streaming) isn't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Gen 1 virtual machines (VMs)](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.

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

## Automatically upgrade your node OS image

AKS provides multiple auto-upgrade channels dedicated to timely node-level OS security updates. This channel is different from cluster-level Kubernetes version upgrades and supersedes it.

Important

`NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image) for Azure Linux with OS Guard on AKS. `Unmanaged` and `SecurityPatch` are incompatible with Azure Linux with OS Guard due to the immutable /usr directory.

Set the node OS upgrade channel on an existing cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--node-os-upgrade-channel` parameter. The following example sets the node OS upgrade channel to `NodeImage` for an existing cluster:

```azurecli
az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-os-upgrade-channel NodeImage
```

Example output:

```json
{
  "id": "/subscriptions/xxxxx/resourceGroups/testAzureLinuxResourceGroup",
  "location": "WestUS2",
  "name": "testAzureLinuxCluster",
  "properties": {
    "nodeOsUpgradeChannel": "NodeImage",
    "provisioningState": "Succeeded"
  }
}
```

For more information on node upgrade channels, see [Using node OS auto-upgrade](/en-us/azure/aks/auto-upgrade-node-os-image).

## Clean up resources

As this tutorial is the last part of the series, you might want to delete your Azure Linux with OS Guard cluster. The Kubernetes nodes run on Azure virtual machines (VMs) and continue incurring charges even if you don't use the cluster.

Delete the Azure resource group and all related resources using the [`az group delete`](/en-us/cli/azure/group#az_group_delete) command.

```azurecli
az group delete --name $RESOURCE_GROUP --yes --no-wait
```