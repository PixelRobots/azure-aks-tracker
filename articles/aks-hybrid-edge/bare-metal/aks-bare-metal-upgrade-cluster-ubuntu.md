---
layout: Conceptual
title: Upgrade AKS on Bare Metal on Ubuntu (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-upgrade-cluster-ubuntu
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
description: Check available Kubernetes patch versions and upgrade an AKS on bare metal cluster on Ubuntu by using Azure CLI.
ms.topic: how-to
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: rishimody
ms.author: rmody
ms.custom: bare-metal
locale: en-us
document_id: 9a8339ae-9e8d-469f-580f-51557671aa31
document_version_independent_id: b6e2536e-3333-7c0e-6a2f-fd40101ea07b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-upgrade-cluster-ubuntu.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-upgrade-cluster-ubuntu
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-upgrade-cluster-ubuntu.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: c5dd5464-07f3-b694-7d92-c1b5ef58b042
---

# Upgrade AKS on Bare Metal on Ubuntu (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

AKS on bare metal supports Kubernetes patch-version upgrades during the Ubuntu public preview. Minor-version upgrades and downgrades aren't supported.

Because the preview uses a single-node cluster, workloads are temporarily unavailable during an upgrade. Schedule the upgrade during a maintenance window and back up important workload data.

## Prerequisites

- An AKS on bare metal cluster on Ubuntu in a `Succeeded` state.
- The public-preview version of the `aksarc` Azure CLI extension.
- A healthy Azure Arc connection from the Ubuntu host.

Update the public extension before you begin:

```azurecli
az extension add --name aksarc --upgrade --allow-preview true
```

## Check available upgrades

The versions supported for new deployments don't necessarily represent valid upgrade paths for an existing cluster. For deployment versions, see [Supported Kubernetes versions](aks-bare-metal-create-cluster-ubuntu-cli#supported-kubernetes-versions).

List the patch versions available for your cluster:

```azurecli
az aksarc get-upgrades \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --output table
```

## Upgrade the cluster

Upgrade to an available patch version:

```azurecli
az aksarc upgrade \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --kubernetes-version <kubernetes-version>
```

## Verify the upgrade

Check the Kubernetes version that Azure reports:

```azurecli
az aksarc show \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --query properties.kubernetesVersion \
  --output tsv
```

Connect to the cluster and verify the node version:

```bash
kubectl get nodes
```