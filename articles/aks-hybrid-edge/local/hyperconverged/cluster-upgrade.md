---
layout: Conceptual
title: Upgrade an Azure Kubernetes Service (AKS) cluster | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/cluster-upgrade
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
description: Learn how to upgrade an Azure Kubernetes Service (AKS) cluster.
ms.topic: overview
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.lastreviewed: 2024-02-27T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: 09347fc3-bdb7-48ac-f326-5a52cc452c32
document_version_independent_id: a213d221-f717-4daf-9631-d5a29e841d9b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/cluster-upgrade.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/cluster-upgrade
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/cluster-upgrade.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 38cf3985-5acc-6ce5-0018-696da1f3aa2d
---

# Upgrade an Azure Kubernetes Service (AKS) cluster | Microsoft Learn

> 
> Applies to: AKS on Azure Local

As part of managing the application and cluster lifecycle, you might want to upgrade to the latest available version of Kubernetes. An upgrade involves either a move to a newer version of Kubernetes, applying operating system (OS) version updates (patching), or both. AKS supports upgrading (or patching) nodes in a workload cluster with the latest OS and runtime updates.

All upgrades run in a continuous, rolling manner to ensure uninterrupted availability of workloads. When a new Kubernetes worker node with a newer build joins the cluster, the process moves resources from the old node to the new node. After this step completes successfully, the process decommissions and removes the old node from the cluster.

## Before you begin

If you're using the Azure CLI, this article requires Azure CLI version 2.34.1 or later. Run `az --version` to find the version. If you need to install or upgrade CLI, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Check for available upgrades

Check which Kubernetes releases are available for your cluster by using the following command:

```azurecli
az aksarc get-upgrades --resource-group myResourceGroup --name myAKSCluster
```

The following example output shows the current version as **1.24.11** and lists the available versions under `upgrades`:

```output
{  
  "agentPoolProfiles": [  
    {  
      "kubernetesVersion": "1.24.11",  
      "upgrades": [  
        {  
          "kubernetesVersion": "1.25.7"  
        }  
      ]  
    }  
  ],  
  "controlPlaneProfile": {  
    "kubernetesVersion": "1.24.11",  
    "name": "aksarc-testupgrade",  
    "osType": "Linux",  
    "upgrades": [  
      {  
        "kubernetesVersion": "1.25.7"  
      }  
    ]  
  },  
  ...  
  "provisioningState": "Succeeded",  
  ...  
}
```

## Upgrade the Kubernetes version

When you upgrade a supported AKS cluster, you can't skip Kubernetes minor versions. You must perform all upgrades sequentially by major version number. For example, you can upgrade from **1.24.x** to **1.25.x** or from **1.25.x** to **1.26.x**. You can't upgrade from **1.24.x** to **1.26.x**.

Note

If you don't specify a patch version, the cluster automatically upgrades to the latest GA patch for the specified minor version. For example, setting `--kubernetes-version` to **1.25** upgrades the cluster to **1.25.7**.

Use the following command to upgrade your cluster:

```azurecli
az aksarc upgrade \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --kubernetes-version <KUBERNETES_VERSION>
```

Use the `show` command to confirm the upgrade was successful:

```azurecli
az aksarc show --resource-group myResourceGroup --name myAKSCluster
```

The following example output shows that the cluster now runs **1.25.7**:

```output
{  
"extendedLocation": {  
  "name":
"/subscriptions/<subscription>/resourcegroups/<resource group>/providers/microsoft.extendedlocation/customlocations/<custom
location>",  
  "type": "CustomLocation"  
},  
"id": "/subscriptions/<subscription>/resourceGroups/<resource group>/providers/Microsoft.Kubernetes/connectedClusters/aksarc-testupgrade/providers/Microsoft.HybridContainerService/provisionedClusterInstances/default",  
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
    "osSku": "CBLMariner",  
    "osType": "Linux",  
    "vmSize": "Standard_A4_v2"  
  },  
  "kubernetesVersion": "1.25.7",  
...  
  "provisioningState": "Succeeded",  
  ...  
},  
....  
"type": "microsoft.hybridcontainerservice/provisionedclusterinstances"  
}
```

Important

If you upgrade from an unsupported version that skips two or more minor versions, the upgrade might not work properly. If your version is significantly out of date, we recommend you recreate your cluster instead.

During an upgrade operation, both the `provisioningState` and `currentState` indicators display an **Upgrading** message to reflect the ongoing process. However, if the operation times out, `provisioningState` shows **Failed**, while `currentState` continues to show **Upgrading** as the upgrade continues in the background. No action is required; the upgrade continues until it's complete.

## Update operating system (OS) version

You can update worker nodes to a newer version of the node image without changing the Kubernetes version only if the new image doesn't require a different Kubernetes version. Currently, AKS doesn't support node-image-only updates across all supported Kubernetes versions. If you need to update the node image, you must upgrade the cluster to the latest Kubernetes version to ensure that all node image updates are incorporated.

Important

If you try to use the `node-image-only` flag, you receive a message indicating that this feature isn't yet supported.