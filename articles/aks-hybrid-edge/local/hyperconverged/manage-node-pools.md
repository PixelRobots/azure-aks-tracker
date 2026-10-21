---
layout: Conceptual
title: Manage node pools for an AKS cluster | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/manage-node-pools
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
description: Learn how to manage multiple node pools in AKS on Azure Local.
ms.topic: how-to
ms.custom: devx-track-azurecli, hyperconverged
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: srikantsarwa
ms.lastreviewed: 2024-06-03T00:00:00.0000000Z
locale: en-us
document_id: e23b6947-b1f6-28a4-0b56-1da58825e437
document_version_independent_id: 1a9f6102-0c81-6a88-feaf-331c6b536bbb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/manage-node-pools.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/manage-node-pools
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/manage-node-pools.md
platformId: 94868cc6-9354-bc0b-0454-72d2b6e0fff3
---

# Manage node pools for an AKS cluster | Microsoft Learn

> 
> Applies to: AKS on Azure Local

Note

For information about managing node pools in AKS on Windows Server, see [Manage node pools](../../windows-server/manage-node-pools-22h2).

In AKS on Azure Local, nodes of the same configuration are grouped together into *node pools*. These node pools contain the underlying VMs that run your applications. This article shows you how to create and manage node pools for an AKS cluster.

## Create a Kubernetes cluster

To get started, create a Kubernetes cluster with a single node pool:

```azurecli
az aksarc create -n <cluster name> -g <resource group> --custom-location <custom location Id> --vnet-ids <vnet id> --generate-ssh-keys
```

## Add a node pool

You can add a node pool to an existing cluster using the [`az aksarc nodepool add`](/en-us/cli/azure/aksarc/nodepool#az-aksarc-nodepool-add) command. Make sure that the name of the node pool is not the same name as an existing node pool:

```azurecli
az aksarc nodepool add --name <node pool name> -g <resource group> --cluster-name <cluster name> --os-sku <Linux or Windows> --node-count <count> --node-vm-size <vm size>
```

## Get configuration information for a node pool

To see the configuration of your node pools, use the [`az aksarc nodepool show`](/en-us/cli/azure/aksarc/nodepool#az-aksarc-nodepool-show) command:

```azurecli
az aksarc nodepool show --cluster-name <cluster name> -n <node pool name> -g <resource group>
```

Example output:

```output
{
"availabilityZones": null,
"count": 1,
"extendedLocation": null,
"id":
"/subscriptions/&lt;subscription&gt;/resourceGroups/edgeci-registration-rr1s46r1710&lt;resource
group&gt;/providers/Microsoft.Kubernetes/connectedClusters/&lt;cluster
name&gt;/providers/Microsoft.HybridContainerService/provisionedClusterInstances/default/agentPools/&lt;nodepoolname&gt;",
"location": "westeurope",
"name": "nodepoolname",
"nodeImageVersion": null,
"osSku": "CBLMariner",
"osType": "Linux",
"provisioningState": "Succeeded",
"resourceGroup": "resourcegroup",
"status": {
  "errorMessage": null,
  "operationStatus": null,
  "readyReplicas": [
   {
    "count": 1,
    "vmSize": "Standard\_A4\_v2"
   }
  ]
},
"systemData": {
…
},
"tags": null,
"type":
"microsoft.hybridcontainerservice/provisionedclusterinstances/agentpools",
"vmSize": "Standard\_A4\_v2"
}
```

## Specify maximum pods deployed to a node pool

You can configure the maximum pods deployable to a node at cluster creation time, or when creating new node pools. If you don't specify `maxPods` when you create node pools, your node pool is deployed with a default value of a maximum 110 pods:

```azurecli
az aksarc nodepool add --cluster-name <cluster name> -n <node pool name> -g <resource group> --max-pods 50 --yes
```

## Scale a node pool

You can scale the number of nodes up or down in a node pool.

To scale the number of nodes in a node pool, use the [`az aksarc nodepool scale`](/en-us/cli/azure/aksarc/nodepool#az-aksarc-nodepool-scale) command. The following example scales the number of nodes to 2 in a node pool named `nodepool1`:

```azurecli
az aksarc nodepool scale --cluster-name <cluster name> -n nodepool1 -g <resource group> --node-count 2 --yes
```

## Delete a node pool

If you need to delete a node pool, use the [`az aksarc nodepool delete`](/en-us/cli/azure/aksarc/nodepool#az-aksarc-nodepool-delete) command:

```azurecli
az aksarc nodepool delete --cluster-name <cluster name> -n <node pool name> -g <resource group> --yes
```