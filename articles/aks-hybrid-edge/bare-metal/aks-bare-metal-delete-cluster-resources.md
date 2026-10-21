---
layout: Conceptual
title: Delete AKS on bare metal on Azure Linux cluster resources (preview) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/bare-metal/aks-bare-metal-delete-cluster-resources
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
description: Learn how to delete Azure Kubernetes Service on bare metal cluster resources and edge machine resources from Azure in the correct order.
ms.topic: how-to
ms.date: 2026-09-14T00:00:00.0000000Z
ai-usage: ai-assisted
author: SummerSmith
ms.author: sumsmith
ms.custom: bare-metal
locale: en-us
document_id: 98194a83-c43b-d186-cb41-ed3d9b7c1d5a
document_version_independent_id: 2b7da59f-0fc0-cfc9-3e6e-260e9ab353a4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/bare-metal/aks-bare-metal-delete-cluster-resources.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/bare-metal/aks-bare-metal-delete-cluster-resources
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/bare-metal/aks-bare-metal-delete-cluster-resources.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: e1f2e0be-ba0d-a46b-52fd-4e64cad495d7
---

# Delete AKS on bare metal on Azure Linux cluster resources (preview) | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

This article shows you how to delete AKS on bare metal cluster and Azure Local resources for an Azure Linux deployment. You **must** follow the deletion order described in this article. Deleting resources out of order results in orphaned resources or failed deletions. For Ubuntu, see [Delete an AKS on bare metal cluster on Ubuntu](aks-bare-metal-delete-cluster-ubuntu).

Warning

Some steps require waiting for completion before proceeding. Don't skip ahead.

## Deletion order

| Step | Resource | Wait required | Notes |
| --- | --- | --- | --- |
| 1 | AKS cluster | ✅ **Yes** | Must fully complete before continuing. |
| 1b (optional) | Data Collection Rule | No | Only if you created a data collection rule during cluster creation. |
| 2 | Logical Network (LNET) | No | — |
| 3 | Device Pool | ✅ **Yes** | Automatically deletes the Custom Location. Must fully complete before continuing. |

## Step 1: Delete the AKS cluster

1. In the [Azure portal](https://portal.azure.com), go to resource groups and then select the resource group that you created for the cluster.
2. Select the AKS cluster resource.
3. Select **Delete** and confirm.
4. **Wait** for the deletion to complete before proceeding.

**CLI alternative:**

```azurecli
az resource delete --ids <cluster-resource-id>
```

## Step 2: Delete the Azure Local Logical Network (LNET)

1. In the resource group, select the Azure Local Logical Network resource.
2. Select **Delete** and confirm.

**CLI alternative:**

```azurecli
az resource delete --ids <lnet-resource-id>
```

If you created a data collection rule during cluster creation, delete it now.

1. In the resource group, select the Data Collection Rule resource.
2. Select **Delete** and confirm.

**CLI alternative:**

```azurecli
az resource delete --ids <data-collection-rule-resource-id>
```

## Step 3: Delete the Device Pool

1. In the resource group, select the resource with a name ending in **mset** and type **Azure Stack | Preview**.
2. Select **Delete** and confirm.
3. **Wait** for the deletion to complete. This action automatically deletes the Custom Location.

**CLI alternative:**

```azurecli
az resource delete --ids <device-pool-resource-id>
```

Note

You don't need to manually delete the Custom Location. It's removed automatically when the Device Pool is deleted.

At this point, you deleted all your AKS on bare metal cluster resources. If you also want to delete the Azure Local Small Form Factor resources, follow the guidance at [How do I delete all the resources from a test?](/en-us/azure/azure-local/small-form-factor/small-form-factor-faq#how-do-i-delete-all-the-resources-from-a-test).

## Troubleshooting

| Issue | Cause | Fix |
| --- | --- | --- |
| Resource stuck in "Deleting" state | Dependency not deleted first. | Verify you followed the order above. Wait and retry. |
| Custom Location still exists after Device Pool delete | Deletion still in progress. | Wait a few more minutes. The deletion cascades automatically. |