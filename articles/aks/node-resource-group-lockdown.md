---
layout: Conceptual
title: Deploy a Fully Managed Resource Group with Node Resource Group Lockdown in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-resource-group-lockdown
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
description: Learn how node resource group lockdown works in AKS Automatic and AKS Standard, and how to configure lockdown levels on AKS Standard clusters.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.subservice: aks-security
ms.date: 2026-06-30T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 2aa0fde0-2180-ccb8-8b93-e54932c9067c
document_version_independent_id: ead27b75-cd0a-b907-e407-6b7a14a3bb23
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-resource-group-lockdown.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/node-resource-group-lockdown
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-resource-group-lockdown.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: fa658d08-a3da-542c-ee2b-572f7174c710
---

# Deploy a Fully Managed Resource Group with Node Resource Group Lockdown in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic ✔️ AKS Standard

AKS deploys infrastructure into your subscription for connecting to and running your applications. Changes made directly to resources in the [node resource group](concepts-clusters-workloads#node-resource-group) can affect cluster operations or cause future issues. For example, scaling, storage, or network configurations should be made through the Kubernetes API and not directly on these resources.

To prevent changes from being made to the node resource group, you can apply a deny assignment and block users from modifying resources created as part of the AKS cluster.

AKS Automatic is the recommended production-ready default for most AKS workloads. In AKS Automatic, node resource group lockdown is preconfigured as part of the fully managed node resource group model.

In AKS Standard, node resource group lockdown is optional and you can configure it with restriction levels.

For more information about AKS Automatic, see [What is AKS Automatic?](intro-aks-automatic)

## Before you begin

If you're configuring lockdown on AKS Standard using Azure CLI, you need:

- Azure CLI version 2.44.0 or later. Run `az --version` to find the current version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Restriction levels

| Restriction level | Behavior |
| --- | --- |
| ReadOnly | You can view node resource group resources, but a deny assignment blocks direct updates. |
| Unrestricted | Direct updates to node resource group resources are allowed. |

## AKS Automatic

Node resource group lockdown is preconfigured on AKS Automatic clusters. You don't need to run a separate enable command.

To create an AKS Automatic cluster, see [Create an Azure Kubernetes Service (AKS) Automatic cluster](automatic/quick-automatic-managed-network).

## AKS Standard: create a cluster with node resource group lockdown

Create an AKS Standard cluster with node resource group lockdown using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--nrg-lockdown-restriction-level` flag set to `ReadOnly`. This configuration allows you to view the resources but not modify them.

```azurecli
# Set environment variables
export RESOURCE_GROUP_NAME=<your-resource-group-name>
export CLUSTER_NAME=<your-cluster-name>

# Create an AKS Standard cluster with node resource group lockdown
az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --nrg-lockdown-restriction-level ReadOnly \
    --generate-ssh-keys
```

## AKS Standard: update a cluster with node resource group lockdown

Update an existing AKS Standard cluster with node resource group lockdown using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--nrg-lockdown-restriction-level` flag set to `ReadOnly`. This configuration allows you to view the resources but not modify them.

```azurecli
# Set environment variables
export RESOURCE_GROUP_NAME=<your-resource-group-name>
export CLUSTER_NAME=<your-cluster-name>

# Update an existing AKS Standard cluster with node resource group lockdown
az aks update --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME --nrg-lockdown-restriction-level ReadOnly
```

## AKS Standard: remove node resource group lockdown

Remove node resource group lockdown from an existing AKS Standard cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--nrg-lockdown-restriction-level` flag set to `Unrestricted`. This configuration allows you to view and modify the resources.

```azurecli
# Set environment variables
export RESOURCE_GROUP_NAME=<your-resource-group-name>
export CLUSTER_NAME=<your-cluster-name>

# Remove node resource group lockdown from an existing AKS Standard cluster
az aks update --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME --nrg-lockdown-restriction-level Unrestricted
```

## Frequently asked questions (FAQs)

### Is node resource group lockdown enabled by default on AKS Automatic?

Yes, it's preconfigured on AKS Automatic clusters.

### Do I need to run lockdown commands on AKS Automatic?

No, lockdown commands are for AKS Standard configuration.

### When should I use ReadOnly on AKS Standard?

Use ReadOnly when you want stronger protection against direct infrastructure edits and prefer cluster changes through AKS and Kubernetes APIs.