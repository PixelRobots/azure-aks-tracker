---
layout: Conceptual
title: List Available VM SKUs for Azure Kubernetes Service (AKS) Clusters (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-list-skus
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
description: Learn how to view VM SKUs that are available for AKS node pool creation in a specific Azure region.
ms.topic: how-to
ms.date: 2026-05-19T00:00:00.0000000Z
ms.author: sachidesai
author: sdesai345
ms.reviewer: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: a00e6351-0550-b3e5-7c7c-a37ab3b12cae
document_version_independent_id: 94a19b83-0f52-d0a9-0ec3-fc84dcfad5cb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-list-skus.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/aks-list-skus
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-list-skus.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 3d75c720-571a-ec91-013c-fefb8106d885
---

# List Available VM SKUs for Azure Kubernetes Service (AKS) Clusters (Preview) - Azure Kubernetes Service | Microsoft Learn

When you create an Azure Kubernetes Service (AKS) cluster or add a new node pool, you need to choose a VM SKU that's available in your target Azure region and supported by AKS. You can use the [`az aks list-vm-skus`](/en-us/cli/azure/aks#az-aks-list-vm-skus) command to quickly view SKUs for AKS in a specific region.

In this article, you learn how to:

- List VM SKUs for AKS in a specific region.
- Filter SKUs by exact or partial Azure VM size name.
- List only SKUs that support availability zones.
- Include all regional SKUs, including SKUs not currently available to your subscription.

Note

This feature lists options of SKUs that are supported in AKS in the specified Azure region and does not consider your current quota or real-time available capacity. Visit the [Azure quota documentation](/en-us/azure/quotas/view-quotas) to learn more about managing quota requests.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- Azure CLI installed and updated to minimum version `2.85.0`. If you need to install or update, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Install and upgrade to latest version of the `aks-preview` extension.

Tip

If `az aks list-vm-skus` isn't recognized in your environment, update Azure CLI to the latest version and update installed AKS extensions.

### Install the `aks-preview` CLI extension

Install the aks-preview CLI extension by using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

```azurecli
az extension add --name aks-preview
```

Update the extension to ensure you have the latest version installed by using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

```azurecli
az extension update --name aks-preview
```

### Set environment variables

Set the following environment variables to use with commands in this article:

```azurecli
export RESOURCE_GROUP=<resource-group-name>
export CLUSTER_NAME=<cluster-name>
export LOCATION=<location>
```

## List supported VM SKUs on an AKS cluster

List supported VM SKUs on an AKS cluster using the [`az aks list-vm-skus`](/en-us/cli/azure/aks#az-aks-list-vm-skus) command.

```azurecli
LOCATION=eastus

az aks list-vm-skus \
  --location $LOCATION \
  --query "[].name" \
  --output table
```

Example output:

```output
Result
--------------------------
Standard_D2ds_v5
Standard_D4ds_v5
Standard_D8ds_v5
Standard_E4ds_v5
Standard_E8ds_v5
```

By default, this command only returns VM SKUs available to your current Azure subscription.

## Filter by Azure VM size name

List supported VM SKUs on an AKS cluster using the [`az aks list-vm-skus`](/en-us/cli/azure/aks#az-aks-list-vm-skus) command with the `--size` parameter to apply a case-insensitive partial match against the SKU name. The following example sets `--size` to *d4ds*:

```azurecli
az aks list-vm-skus \
  --location $LOCATION \
  --size d4ds \
  --query "[].name" \
  --output table
```

Example output:

```output
Result
--------------------
Standard_D4ds_v5
Standard_D4ds_v6
```

## Show only zone-capable Azure VM SKUs

List supported VM SKUs on an AKS cluster using the [`az aks list-vm-skus`](/en-us/cli/azure/aks#az-aks-list-vm-skus) command with the `--zone` parameter to return only SKUs that support availability zones in the selected region.

```azurecli
az aks list-vm-skus \
  --location $LOCATION \
  --zone \
  --query "[].{name:name,zones:join(', ', locationInfo[0].zones)}" \
  --output table
```

Example output:

```output
Name                Zones
------------------  ---------
Standard_D4ds_v5    [1, 2, 3]
Standard_E8ds_v5    [1, 2, 3]
```

## Include all SKUs in the Azure region

List supported VM SKUs on an AKS cluster using the [`az aks list-vm-skus`](/en-us/cli/azure/aks#az-aks-list-vm-skus) command with the `--all` parameter to include SKUs that might not currently be available to your subscription.

```azurecli
az aks list-vm-skus \
  --location $LOCATION \
  --all \
  --query "[].name" \
  --output table
```

Note

AKS uses a best-effort approach to provision VM SKUs. A SKU appearing in this list doesn't guarantee allocation success at deployment time.

## View full details in JSON

List supported VM SKUs on an AKS cluster using the [`az aks list-vm-skus`](/en-us/cli/azure/aks#az-aks-list-vm-skus) command with the `--output` parameter set to *jsonc* to return a JSON output with all returned properties of the supported Azure VM SKUs.

```azurecli
az aks list-vm-skus \
  --location $LOCATION \
  --zone \
  --output jsonc
```

Example output:

```json
[
  {
    "name": "Standard_D4ds_v5",
    "locationInfo": [
      {
        "location": "eastus",
        "zones": [
          "1",
          "2",
          "3"
        ]
      }
    ]
  },
  {
    "name": "Standard_E8ds_v5",
    "locationInfo": [
      {
        "location": "eastus",
        "zones": [
          "1",
          "2",
          "3"
        ]
      }
    ]
  }
]
```

The exact set of returned properties might vary by Azure CLI or API version.

## Use a returned SKU for AKS cluster or node pool creation

After you identify a suitable Azure VM SKU in your target region, specify the name with the `--node-vm-size` parameter when creating your AKS cluster or node pool. The following examples set the VM size to `Standard_D4ds_v5`:

```azurecli
RESOURCE_GROUP=myResourceGroup
CLUSTER_NAME=myAKSCluster
VM_SIZE=Standard_D4ds_v5

az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 3 \
  --node-vm-size $VM_SIZE \
  --generate-ssh-keys

az aks nodepool add \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 1 \
  --node-vm-size $VM_SIZE \
```

## Troubleshooting

- If no suitable Azure VM SKU appears, verify regional availability and quota by reviewing [Quotas, virtual machine size restrictions, and region availability in Azure Kubernetes Service (AKS)](quotas-skus-regions).
- If AKS cluster or node pool creation fails with allocation or capacity errors, rerun `az aks list-vm-skus` and select another SKU family or region.