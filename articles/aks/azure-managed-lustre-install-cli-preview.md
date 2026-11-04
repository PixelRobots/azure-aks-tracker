---
layout: Conceptual
title: Install Azure Managed Lustre with AKS CLI options (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/azure-managed-lustre-install-cli-preview
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
description: Install the Azure Managed Lustre managed extension when you create or update an AKS cluster using the preview AKS CLI options.
ms.topic: how-to
ms.subservice: aks-storage
ms.date: 2026-11-02T00:00:00.0000000Z
author: wolfgang-desalvador
ms.author: wdesalvador
locale: en-us
document_id: 1a22fc14-fc7c-70e3-a4e4-083001274c04
document_version_independent_id: 8f988e89-dac7-82aa-5f23-87fbec199318
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/azure-managed-lustre-install-cli-preview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/azure-managed-lustre-install-cli-preview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/azure-managed-lustre-install-cli-preview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ae365aa9-5e19-49e1-95cb-6d0af6f19080
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/06cefb7d-f6d5-4371-a867-a6339677d3ad
platformId: 330e5520-02f2-7f6e-4295-bfaad1cd9d57
---

# Install Azure Managed Lustre with AKS CLI options (preview) - Azure Kubernetes Service | Microsoft Learn

This article describes the alternative AKS CLI installation option that's in preview. For the default Helm or script procedures, see [Install the Azure Managed Lustre CSI driver](azure-managed-lustre-install).

## Before you begin

You need:

- An Azure subscription and access to create or update the AKS cluster.
- A supported Linux node pool for the existing or planned cluster. Review the [driver compatibility requirements](azure-managed-lustre-overview#supported-kubernetes-and-aks-versions).
- [Network connectivity](azure-managed-lustre-network-planning) between AKS and the existing or planned Lustre file system, using separate subnets.
- `kubectl` available for cluster access after installation.

Important

Don't install the managed extension alongside an existing Helm, script, or other extension installation of the driver.

## Install with AKS CLI options (preview)

As an alternative installation option in preview, you can enable the Azure Managed Lustre managed extension when you create an AKS cluster with `az aks create` or add it to an existing cluster with `az aks update`. Both commands use `--enable-azure-managed-lustre` to install the extension instead of running Helm or the script. This option isn't a migration procedure for an existing Helm or script installation.

Important

The `--enable-azure-managed-lustre` and `--disable-azure-managed-lustre` options are preview features provided by the `aks-preview` Azure CLI extension. You can also use their aliases, `--enable-amlfs` and `--disable-amlfs`.

This option requires Azure CLI 2.85.0 or later and an `aks-preview` build that includes the Azure Managed Lustre options. The Helm and script procedures don't require `aks-preview`.

Install or update the required Azure CLI extensions:

```azurecli
az extension add --name aks-preview --upgrade --allow-preview true
az extension add --name k8s-extension --upgrade
```

Confirm that `az aks create --help` and `az aks update --help` list `--enable-azure-managed-lustre`, and that update also lists `--disable-azure-managed-lustre`. If the options aren't listed, the installed `aks-preview` build doesn't include this feature.

Set values for your existing AKS resource group and the cluster to create or update:

```azurecli
RESOURCE_GROUP="myResourceGroup"
AKS_CLUSTER="myAKSCluster"
```

### Create an AKS cluster with Azure Managed Lustre enabled

Set the resource ID of the AKS subnet prepared with connectivity to your existing or planned Lustre file system. Use a subnet separate from the Lustre subnet:

```azurecli
AKS_SUBNET_ID="<AKS_SUBNET_RESOURCE_ID>"
```

Create the cluster:

```azurecli
az aks create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AKS_CLUSTER" \
  --vnet-subnet-id "$AKS_SUBNET_ID" \
  --generate-ssh-keys \
  --enable-azure-managed-lustre
```

### Enable Azure Managed Lustre on an existing AKS cluster

```azurecli
az aks update \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AKS_CLUSTER" \
  --enable-azure-managed-lustre
```

The command installs the Azure Managed Lustre extension as `azurelustre`. Enabling an already successfully installed extension preserves its configuration; it doesn't upgrade or reinstall it.

Verify that the extension was installed successfully:

```azurecli
az k8s-extension show \
  --resource-group "$RESOURCE_GROUP" \
  --cluster-name "$AKS_CLUSTER" \
  --cluster-type managedClusters \
  --name azurelustre \
  --query "{provisioningState:provisioningState, version:version}" \
  --output table
```

Get credentials for the cluster:

```azurecli
az aks get-credentials \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AKS_CLUSTER"
```

If installation fails, see [Troubleshoot Azure Managed Lustre CSI driver extension errors](/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-azurelustre-csi-extension-errors).