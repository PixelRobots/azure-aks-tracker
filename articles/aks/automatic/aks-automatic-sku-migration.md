---
layout: Conceptual
title: Migrate AKS Automatic clusters and managed system node pools - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/automatic/aks-automatic-sku-migration
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
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to migrate AKS Automatic clusters between managed system node pool and AKS Standard configurations.
ms.topic: how-to
ms.date: 2026-09-08T00:00:00.0000000Z
author: wangyira
ms.author: wangamanda
locale: en-us
document_id: 1440884c-161d-36b4-d063-a3b4fd0b9c89
document_version_independent_id: 27acf025-6727-3e58-a4bc-1aaf302760e0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/automatic/aks-automatic-sku-migration.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/automatic/aks-automatic-sku-migration
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/automatic/aks-automatic-sku-migration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: b43d6e57-29fa-55ef-ef76-cd00df8703d6
---

# Migrate AKS Automatic clusters and managed system node pools - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic ✔️ AKS Standard

This article shows you how to migrate AKS Automatic clusters between supported [managed system node pool](aks-automatic-managed-system-node-pools-about) and AKS Standard configurations.

## Supported migration paths

| Migration path | Support |
| --- | --- |
| AKS Automatic with managed system node pools to AKS Standard (`base` SKU) | Supported |
| AKS Automatic without managed system node pools to AKS Automatic with managed system node pools | Supported in preview in regions where managed system node pools are generally available |
| AKS Standard (`base` SKU) to AKS Automatic with managed system node pools | Coming soon |
| AKS Automatic with managed system node pools to AKS Automatic without managed system node pools | Not supported |

## Migrate from an AKS Automatic cluster with managed system node pools to an AKS Standard cluster

### How the migration works

An AKS Automatic cluster with managed system node pools runs its system components on system node pools that AKS provisions, scales, and upgrades for you.

Important

An AKS Standard (`base` SKU) cluster doesn't enable managed system node pools, so you're responsible for running, managing, and upgrading the system node pool and the system components.

To migrate from AKS Automatic to AKS Standard, complete the following high-level steps:

1. Add a self-managed system node pool to your AKS Automatic cluster.
2. Update the cluster SKU from `automatic` to `base`.

After you update the SKU, the cluster runs as an AKS Standard cluster, and your system components run on the system node pool that you added and manage.

### Migrate to an AKS Standard cluster

1. Add a self-managed system node pool to your existing AKS Automatic cluster by using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. Set the node pool mode to `System` so it can run system components after migration.

    ```azurecli
    az aks nodepool add \
        --resource-group "${RESOURCE_GROUP}" \
        --cluster-name "${RESOURCE_NAME}" \
        --name systempool \
        --mode System \
        --node-count 3
    ```
2. Update the cluster SKU from `automatic` to `base` by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

    ```azurecli
    az aks update \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --sku base
    ```

### Verify the migration

1. Confirm that the cluster now uses the `base` SKU by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --query "sku" \
        --output table
    ```
2. List the node pools on the cluster to confirm your self-managed system node pool is present and in the `System` mode by using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command.

    ```azurecli
    az aks nodepool list \
        --resource-group "${RESOURCE_GROUP}" \
        --cluster-name "${RESOURCE_NAME}" \
        --query "[].{Name:name, Mode:mode, Count:count}" \
        --output table
    ```

## Migrate from an AKS Automatic cluster without managed system node pools to AKS Automatic with managed system node pools (preview)

AKS Automatic supports preview migration from non-managed system node pools to managed system node pools in regions where managed system node pools are generally available. This migration keeps the cluster on the `automatic` SKU and moves AKS system components to a system node pool managed by AKS.

### Prerequisites

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

- An existing AKS Automatic cluster without managed system node pools.
- Azure CLI version 2.86.0 or later. To find the version, run `az --version`. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The latest version of the `aks-preview` Azure CLI extension.
- The `Microsoft.ContainerService/NonHoboToHoboConversionPreview` feature flag registered in your subscription.

Register the `NonHoboToHoboConversionPreview` feature flag by using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command:

```azurecli
az feature register \
    --namespace Microsoft.ContainerService \
    --name NonHoboToHoboConversionPreview
```

Check the registration status by using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command:

```azurecli
az feature show \
    --namespace Microsoft.ContainerService \
    --name NonHoboToHoboConversionPreview \
    --query properties.state \
    --output tsv
```

Wait until the command returns `Registered` before you continue. Then, refresh the `Microsoft.ContainerService` resource provider registration.

```azurecli
az provider register --namespace Microsoft.ContainerService
```

Install or update the `aks-preview` extension:

```azurecli
az extension add --name aks-preview
az extension update --name aks-preview
```

### Migrate an AKS-managed virtual network cluster

For an AKS Automatic cluster that uses AKS-managed networking, migrate to managed system node pools by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-hosted-system` parameter:

```azurecli
az aks update \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${RESOURCE_NAME}" \
    --enable-hosted-system
```

### Migrate a custom virtual network cluster

For an AKS Automatic cluster that uses a custom virtual network, provide a subnet for the managed system node pool by using the `--system-node-subnet-id` parameter. The system node subnet must:

- Be in the same virtual network and region as the cluster.
- Be at least `/26`.
- Not be delegated to another service.
- Be different from the node subnet.

The `--node-subnet-id` parameter is optional. If you don't provide it, AKS uses the existing system node pool subnet.

```azurecli
az aks update \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${RESOURCE_NAME}" \
    --enable-hosted-system \
    --system-node-subnet-id "${SYSTEM_NODE_SUBNET_ID}" \
    --node-subnet-id "${NODE_SUBNET_ID}"
```

### Verify the migration

Confirm the cluster uses managed system node pools by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command:

```azurecli
az aks show \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${RESOURCE_NAME}" \
    --query hostedSystemProfile \
    --output json
```

The following example output shows the `hostedSystemProfile.enabled` property set to `true`:

```output
{
  "enabled": true,
  "nodeSubnetId": "<node-subnet-resource-id>",
  "systemNodeSubnetId": "<system-node-subnet-resource-id>"
}
```