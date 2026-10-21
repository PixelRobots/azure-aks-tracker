---
layout: Conceptual
title: Troubleshoot deleted cluster still visible in portal | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/deleted-cluster-visible
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
description: Learn how to troubleshoot deleted cluster still visible in portal, shows "Not found."
ms.topic: troubleshooting
author: davidsmatlak
ms.author: davidsmatlak
ms.date: 2026-09-01T00:00:00.0000000Z
ms.reviewer: sumsmith
ms.custom: hyperconverged
locale: en-us
document_id: 25c2d6a1-5b5b-f344-12e4-c330ccd0acf9
document_version_independent_id: c2007057-5e25-091b-8c18-b0eb2923f556
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/deleted-cluster-visible.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/deleted-cluster-visible
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/deleted-cluster-visible.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
platformId: 7f8d496b-addb-56af-f30a-1c570875bc91
---

# Troubleshoot deleted cluster still visible in portal | Microsoft Learn

A provisioned cluster that you deleted is still visible in the **Overview** blade on the Azure portal. Selecting the resource shows a **Not found** message. This error happens because occasionally, the cluster delete command fails to fully remove a resource. While it might delete the child **provisionedClusterInstance** resource, the parent **connectedCluster** resource often remains, making it still visible in the portal.

## Verify

- Get the provisioned cluster instance resource and verify that it doesn't exist:

    ```azurecli
    az aksarc show -g <resource_group> -n <cluster_name>
    ```
- Get the connected cluster resource and verify that it exists:

    ```azurecli
    az connectedk8s show -g <resource_group> -n <cluster_name>
    ```

## Workaround

Run the following command:

```azurecli
# Replace the following values appropriately

$subscription = <subscription_id>
$resource_group = <resource_group_name>
$cluster_name = <cluster_name>

az aksarc delete -g <resource_group> -n <cluster_name>
```

This command deletes the parent connected cluster resource as well.

## Validation

Run the `az connectedk8s show -g <resource_group> -n <cluster_name>` command to verify that it returns "Not found," or verify that the portal doesn't list the connected cluster resource anymore.