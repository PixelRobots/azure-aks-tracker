---
layout: Conceptual
title: Delete AKS on Bare Metal on Ubuntu (Preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-delete-cluster-ubuntu
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
description: Delete an AKS on bare metal cluster from an Ubuntu host in the correct dependency order by using Azure CLI.
ms.topic: how-to
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: rishimody
ms.author: rmody
ms.custom: bare-metal
locale: en-us
document_id: 8ad7a44d-c3cc-cc43-ec30-58b11603bcda
document_version_independent_id: 5c4d9ee7-4d80-2421-2e17-fca9d0d22dae
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-delete-cluster-ubuntu.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-delete-cluster-ubuntu
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-delete-cluster-ubuntu.md
platformId: c5d1d4a7-657a-6748-906f-75f2b0cad26e
---

# Delete AKS on Bare Metal on Ubuntu (Preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Use `az aksarc undeploy` to delete the Kubernetes cluster and its dependent resources from an Ubuntu host in the correct order.

Important

Don't delete an AKS on bare metal cluster on Ubuntu through the Azure portal. Use `az aksarc undeploy` so that AKS removes the cluster and its dependent resources from the host in the correct order.

Warning

Don't delete the resource group before you undeploy the cluster. Deleting resources out of order can leave components on the Ubuntu host. Undeploying permanently deletes the cluster and its workloads. Back up any data that you need to keep.

## Delete the cluster

Install or update the public-preview version of the `aksarc` extension:

```azurecli
az extension add --name aksarc --upgrade --allow-preview true
```

- Sign in and select the subscription that contains the Arc-enabled server.

```azurecli
az login
az account set --subscription <subscription-id>
```

Undeploy the cluster:

```azurecli
az aksarc undeploy \
  --resource-group <resource-group> \
  --arc-machine-names <host-name> \
  --yes
```

## Verify deletion

Confirm that the cluster no longer appears in the resource group:

```azurecli
az aksarc list \
  --resource-group <resource-group> \
  --output table
```

The Ubuntu host remains connected to Azure Arc. Disconnect or delete the Arc-enabled server only if you no longer need Azure management for that host. For more information, see [Manage the Azure Connected Machine agent](/en-us/azure/azure-arc/servers/manage-agent).