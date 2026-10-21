---
layout: Conceptual
title: How to upgrade an Azure Kubernetes Fleet Manager resource between hub types | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/upgrade-hub-cluster-type
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
learn_banner_products:
- azure
description: Learn how to upgrade an Azure Kubernetes Fleet Manager resource from hubless to hubful.
ms.topic: how-to
ms.date: 2024-05-02T00:00:00.0000000Z
author: shashankbarsin
ms.author: shasb
ms.service: azure-kubernetes-fleet-manager
ms.custom:
- build-2024
locale: en-us
document_id: 5390c5ff-e6c6-5246-12ad-343a9b721bbd
document_version_independent_id: 56c2844f-7cfb-8001-59ec-66231f903daf
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/upgrade-hub-cluster-type.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/upgrade-hub-cluster-type
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/upgrade-hub-cluster-type.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 79053ed1-0340-4cf3-d619-3b95778bea7e
---

# How to upgrade an Azure Kubernetes Fleet Manager resource between hub types | Microsoft Learn

In this article, you learn how to upgrade an Azure Kubernetes Fleet Manager (Kubernetes Fleet) resource without a hub cluster to a Kubernetes Fleet resource that has a hub cluster. When a Kubernetes Fleet resource is created without a hub cluster, a central Azure Kubernetes Service (AKS) cluster isn't created for the Kubernetes Fleet resource. When a Kubernetes Fleet resource with a hub cluster is created, a central and managed AKS cluster is created to enable scenarios such as workload orchestration and layer-4 load balancing.

For more information, see [Choosing an Azure Kubernetes Fleet Manager option](concepts-choosing-fleet).

## Prerequisites and limitations

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- [Install or upgrade Azure CLI](/en-us/cli/azure/install-azure-cli) to the latest version.
- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- You must have an existing Kubernetes Fleet resource without a hub cluster. The steps in this article show you how to create a Kubernetes Fleet resource without a hub cluster. If you already have one, you can skip the initial setup and begin at Upgrade hub cluster type for the Kubernetes Fleet resource.
- This article also includes steps on joining member clusters. If you plan to follow along, you need at least one AKS cluster.

Important

Kubernetes Fleet resources without a hub cluster can be upgraded to a Kubernetes Fleet resource with a hub cluster. However, a Kubernetes Fleet resource that already has a hub cluster can't be downgraded to a Kubernetes Fleet resource without a hub cluster. All configuration options and settings associated with Kubernetes Fleet resource that has a hub cluster are immutable and can't be changed after creation or upgrade time. Upgrading from a Kubernetes Fleet resource without a hub cluster to one with a hub cluster can only be done through the Azure CLI. Currently there's no equivalent Azure portal experience.

## Initial setup

To begin, create a resource group and a Kubernetes Fleet resource without a hub cluster, and join your existing AKS cluster as a member. You'll need to repeat the `az fleet member create` command for each individual member cluster you want to associate with the fleet resource.

```azurecli
RG=myResourceGroup
LOCATION=eastus
FLEET=myKubernetesFleet
FLEET_MEMBER=<name-identifying-member-cluster>
SUBSCRIPTION_ID=<your-subscription-id>
CLUSTER=<your-aks-cluster-name>

# Create resource group
az group create -n $RG -l $LOCATION

# Create a hubless fleet resource 
az fleet create -g $RG -n $FLEET

# Join member cluster to hubless fleet resource
az fleet member create --name $FLEET_MEMBER --fleet-name $FLEET --resource-group $RG --member-cluster-id /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG/providers/Microsoft.ContainerService/managedClusters/$CLUSTER
```

## Upgrade hub cluster type for the Kubernetes Fleet resource

To upgrade the hub cluster type for the Kubernetes Fleet resource, use the `az fleet create` command with the `--enable-hub` flag set. Be sure to include any other relevant configuration options, as the fleet resource will become immutable after this operation is complete.

```azurecli
# Upgrade the Kubernetes fleet resource without a hub cluster to one with a hub cluster
az fleet create --name $FLEET --resource-group $RG --enable-hub 

```

## Validate the upgrade

After running the `az fleet create` command to upgrade the fleet resource, verify that the upgrade succeeded by viewing the output. The `provisioningState` should read `Succeeded` and the `hubProfile` field should exist. For example, see the following output:

```bash
{
  ...
  "hubProfile": {
    "agentProfile": {
      "subnetId": null,
      "vmSize": null
    },
    "apiServerAccessProfile": {
      "enablePrivateCluster": false,
      "enableVnetIntegration": false,
      "subnetId": null
    },
    "dnsPrefix": "contoso-user-xxxx-xxxxxxx",
    "fqdn": "contoso-user-flth-xxxxxx-xxxxxxxx.hcp.eastus.azmk8s.io",
    "kubernetesVersion": "1.28.5",
    "portalFqdn": "contoso-user-flth-xxxxxxx-xxxxxxxx.portal.hcp.eastus.azmk8s.io"
  },
  "provisioningState": "Succeeded"
  ...
}
```

## Rejoin member clusters

To rejoin member clusters to the newly upgrade fleet resource, use the `az fleet member reconcile` command for each individual member cluster.

```azurecli
az fleet member reconcile -g $RG -f $FLEET -n $FLEET_MEMBER
```

Note

Clusters being joined to the fleet for the first time after an upgrade don't require reconciliation.

## Verify member clusters joined successfully

For each member cluster that you rejoin to the newly upgraded fleet, view the output and verify that `provisioningState` reads `Succeeded`. For example:

```bash
{
  ...
  "provisioningState": "Succeeded"
  ...
}
```

## Verify functionality

You need access to the Kubernetes API of the hub cluster. If you don't have access, see [Access Fleet hub cluster Kubernetes API](access-fleet-hub-cluster-kubernetes-api).

To verify that your newly upgraded Kubernetes Fleet resource is functioning properly and that the member clusters joined successfully, confirm that you're able to access the hub cluster's API server using the `kubectl get memberclusters` command.

If successful, your output should look similar to the following example output:

```bash
NAME           JOINED   AGE
aks-member-1   True     2m
arc-member-2   True     2m
aks-member-3   True     2m
```

## Clean up resources

Once you're finished, you can remove the fleet resource and related resources by deleting the resource group. This operation won't delete your clusters if they are in a different resource group.

```azurecli
az group delete -n $RG
```