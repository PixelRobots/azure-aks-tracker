---
layout: Conceptual
title: Upgrade an Azure Kubernetes Service (AKS) on Azure Local for multi-rack deployments | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/multi-rack/cluster-upgrade
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn how to upgrade an AKS cluster to a newer Kubernetes version on Azure Local.
ms.topic: overview
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: sanjanamohan
ms.custom: multi-rack
author: sanjanamsft
locale: en-us
document_id: 67dfbe7d-5806-c88c-0e64-1915f7b9e499
document_version_independent_id: 4340dccc-fb65-39ea-6aac-d5e3e3a9440b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/multi-rack/cluster-upgrade.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/multi-rack/cluster-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/multi-rack/cluster-upgrade.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 70db6c2f-0c21-6f1e-5c27-ba9b3b10ae0b
---

# Upgrade an Azure Kubernetes Service (AKS) on Azure Local for multi-rack deployments | Microsoft Learn

As part of managing the application and cluster lifecycle, you might want to upgrade to the latest available version of Kubernetes. AKS on Azure Local multi-rack deployments supports upgrades that involve a move to a newer version of Kubernetes.

All upgrades run in a continuous, rolling manner to ensure uninterrupted availability of workloads. When a new Kubernetes worker node with a newer build joins the cluster, the process moves resources from the old node to the new node. After this step completes successfully, the process decommissions and removes the old node from the cluster.

## Before you begin

If you're using the Azure CLI, this article requires Azure CLI version 2.83.0 or later. To find the version, run the `az --version` command. If you need to install or upgrade CLI, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Supported Versions

The supported Kubernetes Versions are:

- 1.31.14
- 1.31.100
- 1.32.10
- 1.32.11
- 1.33.11
- 1.33.12
- 1.34.7
- 1.34.8
- 1.35.4
- 1.35.5
- 1.36.0
- 1.36.1

## Upgrade the Kubernetes version

When you upgrade a supported AKS cluster, you can't skip Kubernetes minor versions. You must perform all upgrades sequentially by minor version number. The system automatically blocks any attempts to skip Kubernetes minor versions. For example, you can't upgrade from **1.30.x** to **1.32.x**.

Note

If you don't specify a patch version, the cluster automatically upgrades to the latest GA patch for the specified minor version. For example, setting `--kubernetes-version` to **1.33** upgrades the cluster to **1.33.11**.

Use the following command to upgrade your cluster:

```azurecli
az aksarc upgrade \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --kubernetes-version <KUBERNETES_VERSION>
```

For example, to upgrade a cluster to Kubernetes version 1.34.7, run:

```azurecli
az aksarc upgrade \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --kubernetes-version 1.34.7
```

Use the `show` command to confirm the upgrade was successful:

```azurecli
az aksarc show --resource-group myResourceGroup --name myAKSCluster
```

The following example output shows that the cluster now runs **1.33.11**:

```output
{
  "extendedLocation": {
    "name": "/subscriptions/<subscription>/resourcegroups/<resource group>/providers/microsoft.extendedlocation/customlocations/<custom location>",
    "type": "CustomLocation"
  },
  "id": "/subscriptions/<subscription>/resourceGroups/<resource group>/providers/Microsoft.Kubernetes/connectedClusters/myAKSCluster/providers/Microsoft.HybridContainerService/provisionedClusterInstances/default",
  "name": "default",
  "properties": {
    "agentPoolProfiles": [
      {
      }
    ],
    "controlPlane": {
      "availabilityZones": null,
      "controlPlaneEndpoint": {
        "hostIp": null,
        "port": null
      },
      "count": 1,
      "linuxProfile": {
        "ssh": {
          "publicKeys": null
        }
      },
      "name": null,
      "nodeImageVersion": null,
      "osSku": "AzureLinux",
      "osType": "Linux",
      "vmSize": "Standard_A4_v2"
    },
    "kubernetesVersion": "1.33.11",
    ...
    "provisioningState": "Succeeded",
    ...
  },
  ...
  "type": "microsoft.hybridcontainerservice/provisionedclusterinstances"
}
```

During an upgrade operation, both the `provisioningState` and `currentState` indicators display an **Upgrading** message to reflect the ongoing process. However, if the operation times out, `provisioningState` shows **Failed**, while `currentState` continues to show **Upgrading** as the upgrade continues in the background. No action is required; the upgrade continues until it's complete.

## Update operating system (OS) version

Currently, AKS on Azure Local for multi-rack deployments doesn't support node-image-only updates across all supported Kubernetes versions. If you need to update the node image, you must upgrade the cluster to the latest Kubernetes version to ensure that all node image updates are incorporated.

Important

If you try to use the `node-image-only` flag, you receive a message indicating that this feature isn't yet supported.