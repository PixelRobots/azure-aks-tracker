---
layout: Conceptual
title: MetalLB speaker pods don't run on nodes tainted with CriticalAddonsOnly=true:NoSchedule | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/troubleshoot-metallb-speaker-taint
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
description: Learn how to troubleshoot MetalLB speaker pods that don't run on nodes tainted with CriticalAddonsOnly=true:NoSchedule.
ms.topic: troubleshooting
ms.date: 2026-09-01T00:00:00.0000000Z
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: srikantsarwa
ms.lastreviewed: 2025-08-21T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: b778edcb-a7fe-207d-eb51-16c6ef192eba
document_version_independent_id: 8b43022e-0842-5fef-054f-b841109ddd3d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/troubleshoot-metallb-speaker-taint.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/troubleshoot-metallb-speaker-taint
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/troubleshoot-metallb-speaker-taint.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 91372372-61db-bb87-37d7-d151ffce3176
---

# MetalLB speaker pods don't run on nodes tainted with CriticalAddonsOnly=true:NoSchedule | Microsoft Learn

MetalLB speaker pods don't run on nodes tainted with `CriticalAddonsOnly=true:NoSchedule`. This behavior is expected; such nodes are reserved for critical system pods. However, in some cases, you might require MetalLB speaker pods to be scheduled on these tainted nodes.

## Mitigation

Follow these steps to customize the MetalLB configuration by reinstalling the Arc extension for MetalLB with tolerations for the `CriticalAddonsOnly=true:NoSchedule` taint.

1. Run Azure CLI to get the objectId:

    ```azurecli
    $objID = az ad sp list --filter "appId eq '<app_id>'" --query "[].id" --output tsv
    ```
2. Create a new file named `config.json` and insert the following content:

    ```json
    {
      "k8sRuntimeFpaObjectId": "$objID",
      "metallb.speaker.tolerations[0].key": "CriticalAddonsOnly",
      "metallb.speaker.tolerations[0].operator": "Exists",
      "metallb.speaker.tolerations[0].effect": "NoSchedule"
    }
    ```
3. Install the extension:

    ```azurecli
    az k8s-extension create --cluster-name $clusterName -g $rgName --cluster-type connectedClusters --extension-type microsoft.arcnetworking --config-file config.json -n arcnetworking
    ```
4. When the installation succeeds, MetalLB speaker pods should be scheduled on nodes with the `CriticalAddonsOnly=true:NoSchedule` taint.

Note

Scheduling MetalLB speaker pods on nodes with this taint should only be done if required for your scenario. These nodes are typically reserved for critical system workloads.