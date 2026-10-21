---
layout: Conceptual
title: Full Caching Mode for Ephemeral OS Disks in Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/full-cache-ephemeral-os-disk
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
description: Learn how to enable full caching for ephemeral OS disks in Azure Kubernetes Service (AKS) to improve resiliency and performance.
ms.author: schaffererin
author: schaffererin
ms.topic: how-to
ms.date: 2026-07-17T00:00:00.0000000Z
locale: en-us
document_id: 4e3cb33b-7a2a-d785-233f-3930146eecfb
document_version_independent_id: 9bbd9c69-49dc-9582-ff98-e14e863bbf0c
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/full-cache-ephemeral-os-disk.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/full-cache-ephemeral-os-disk
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/full-cache-ephemeral-os-disk.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 602466b8-3301-486f-d307-f47333edcb6d
---

# Full Caching Mode for Ephemeral OS Disks in Azure Kubernetes Service (AKS) (Preview) - Azure Kubernetes Service | Microsoft Learn

Ephemeral OS disks with full caching enhance the standard ephemeral OS disk by fully caching the OS disk onto the local disk. This feature improves the resiliency of general-purpose virtual machines (VMs) and virtual machine scale sets by ensuring the OS disk remains available even during storage disruptions.

This article provides guidance on how to enable full caching for ephemeral OS disks in AKS.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## How full caching works

When you create a VM with full caching enabled, the following actions occur:

- The temporary disk size is reduced by two times the OS disk size, and the freed space is used to create the OS disk.
- The OS disk is cached in the background after the VM boots up. This caching process ensures no impact on VM creation times.

## Limitations

- You can only enable full-cache ephemeral OS disks during node pool creation; you can't update existing node pools to use full caching.
- The feature requires an ephemeral OS disk configuration.
- You can access the feature only through preview AKS API versions and tooling.
- Full-cache ephemeral OS disks are designed for stateless workloads; they're not recommended for stateful workloads.
- The local disk size must be greater than (2x the OS disk size + 1 GiB) to support full caching.
- All VM SKUs are supported except for 2-core and 4-core VMs.

## Prerequisites

- Azure CLI version 2.76.0 or later. Check your version using the `az --version` command. To install or update the Azure CLI, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- AKS REST API version 2026-04-02-preview or later.
- The `aks-preview` extension installed and updated to version 21.0.0.b2 or later. To install or update the `aks-preview` extension, see Install the `aks-preview` extension.
- The `FullCachePreview` feature flag registered on your subscription. To register the feature flag, see Register the `FullCachePreview` feature flag.

### Install the `aks-preview` extension

Install the `aks-preview` extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

```azurecli
az extension add --name aks-preview
```

Update the `aks-preview` extension to the latest version using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

```azurecli
az extension update --name aks-preview
```

### Register the `FullCachePreview` feature flag

1. Register the `FullCachePreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace Microsoft.ContainerService --name FullCachePreview
    ```
2. Check the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. The registration process can take several minutes to complete.

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name FullCachePreview
    ```
3. After the feature flag is registered, refresh the provider registration using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

## Create a node pool with full-cache ephemeral OS disks

Create a new node pool with full caching enabled for ephemeral OS disks using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--enable-osdisk-full-caching` flag.

Note

You can also use the abbreviated flag `--enable-osdisk-fc` to enable full caching.

```azurecli
# Set environment variables
export RESOURCE_GROUP=<resource-group>
export CLUSTER_NAME=<cluster-name>
export NODE_POOL_NAME=<node-pool-name>

# Create a new node pool with full caching enabled for ephemeral OS disks
az aks nodepool add \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --enable-osdisk-full-caching
```