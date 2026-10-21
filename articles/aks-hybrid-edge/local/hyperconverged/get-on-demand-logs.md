---
layout: Conceptual
title: Get on-demand logs for troubleshooting | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/get-on-demand-logs
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
description: Learn how to get full on-demand logs in AKS Hybrid and Edge and send them to Microsoft.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2025-04-08T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: hyperconverged
locale: en-us
document_id: 86c9b050-2560-b5f7-3306-52792c542663
document_version_independent_id: e68a9865-c0cd-b2b8-1a87-36ed480d1da8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/get-on-demand-logs.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/get-on-demand-logs
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/get-on-demand-logs.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: c7c9b25f-fde8-83b2-49a4-904545d5eb19
---

# Get on-demand logs for troubleshooting | Microsoft Learn

> 
> Applies to: AKS on Azure Local

This article describes how to collect full on-demand logs and send them to Microsoft support for troubleshooting issues with AKS Hybrid and Edge.

## Prepare the SSH key

Before log collection, you must have the SSH key you obtained when you created the cluster. It is usually saved under the **~/.ssh** path; for example, **C:\Users\HciiDeploymentUser.ssh\id\_rsa**. If the SSH key is lost, the log can't be collected.

## Collect logs

You can collect logs using IPs or the `kubeconfig` parameter. If an IP is used, it collects the log from a particular node. If `kubeconfig` is used, it collects logs from all cluster nodes. This command generates a .zip file on the local disk. For other parameters, see the [Az CLI reference](/en-us/cli/azure/aksarc#az-aksarc-get-logs). You can also use the [Get-AzAksArcLog](/en-us/powershell/module/az.aksarc/get-azaksarclog) PowerShell command to collect logs. For more information, [see the PowerShell reference](/en-us/powershell/module/az.aksarc/get-azaksarclog).

```azurecli
az aksarc get-logs --ip 192.168.200.25 --credentials-dir ./.ssh --out-dir ./logs
```

Or

```azurecli
az aksarc get-logs --kubeconfig ./.kube/config --credentials-dir ./.ssh --out-dir ./logs
```

## Send logs to Microsoft Support

Contact Microsoft Support to send the logs to Microsoft. If the environment is disconnected, you must recover the network first.