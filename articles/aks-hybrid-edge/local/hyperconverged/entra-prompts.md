---
layout: Conceptual
title: Entra authentication prompts when running kubectl with Kubernetes RBAC | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/entra-prompts
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
description: Learn how to troubleshoot Entra authentication issues when using kubectl with Kubernetes RBAC.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: troubleshooting
ms.date: 2026-09-01T00:00:00.0000000Z
ms.reviewer: leslielin
ms.lastreviewed: 2025-06-24T00:00:00.0000000Z
ms.custom: hyperconverged
locale: en-us
document_id: 6b074fb7-d502-1e41-1ff5-3436503375e5
document_version_independent_id: 0bf2f825-c267-909d-d174-b20526671b86
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/entra-prompts.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/entra-prompts
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/entra-prompts.md
platformId: a7cd757b-1bea-40dc-8817-c08d52b90878
---

# Entra authentication prompts when running kubectl with Kubernetes RBAC | Microsoft Learn

This article helps you diagnose and resolve issues related to repeated Entra authentication prompts when using **kubectl** with Kubernetes RBAC on AKS Hybrid and Edge.

## Symptoms

When you use **kubectl** with [Microsoft Entra authentication and Kubernetes RBAC](kubernetes-rbac-local) in AKS on Azure Local, Entra authentication prompts appear after each command execution.

## Possible causes

This issue is caused by [a GitHub bug](https://github.com/Azure/kubelogin/issues/654) introduced in **kubelogin** version 0.2.0 and later.

## Mitigation

To mitigate this issue, you can use one of the following two methods:

- Downgrade **kubelogin** to version 0.1.9. This stable version does not have the bug that causes repeated authentication prompts. You can [download this version from the GitHub repository](https://github.com/Azure/kubelogin/releases/tag/v0.1.9). Select the appropriate asset for your OS or architecture, extract it, and replace your existing **kubelogin** binary.
- Alternatively, if you have administrator permissions, you can use the `--admin` flag with the `az aksarc get-credentials` command. This method bypasses **kubelogin** authentication by retrieving admin credentials directly:

    ```azurecli
    az aksarc get-credentials -g $resource_group_name -n $aks_cluster_name --file <file-name> --admin
    ```