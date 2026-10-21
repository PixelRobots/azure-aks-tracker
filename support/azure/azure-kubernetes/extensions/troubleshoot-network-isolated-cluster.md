---
layout: Conceptual
title: Troubleshoot Network Isolated AKS Clusters - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-network-isolated-cluster
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Troubleshoot network isolated AKS cluster issues, including image pull and ACR connectivity failures, to restore workloads quickly and keep deployments running.
ms.service: azure-kubernetes-service
ms.date: 2025-04-15T00:00:00.0000000Z
ms.reviewer: doveychase, yuewu2, v-weizhu
ms.custom: sap:Extensions, Policies and Add-Ons
locale: en-us
document_id: 9b246a05-c136-6814-caac-96d11cb9a848
document_version_independent_id: 9b246a05-c136-6814-caac-96d11cb9a848
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/troubleshoot-network-isolated-cluster.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/troubleshoot-network-isolated-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/troubleshoot-network-isolated-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 933925f4-51ec-d12d-4914-230236ed0222
---

# Troubleshoot Network Isolated AKS Clusters - Azure | Microsoft Learn

## Summary

Use this article to troubleshoot issues in [network isolated Azure Kubernetes Service (AKS) clusters](/en-us/azure/aks/concepts-network-isolated), resolve common image pull and ACR problems, and recover faster.

## Prerequisites

- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool. You can install kubectl by running the [Azure CLI](/en-us/cli/azure/install-azure-cli) command [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli).

## Network isolated cluster support

The network isolated cluster follows a similar support model to other [AKS add-ons](/en-us/azure/aks/integrations). When using a network isolated cluster with Azure Container Registry (ACR), you have two options:

- Bring Your Own (BYO) ACR
- AKS-managed ACR

If you choose BYO ACR, you're responsible for configuring your ACR and its associated resources properly.

## Issue 1: Cluster image pull fails due to network isolation

Network isolated clusters use ACR cache rules for image pulls. If an image pull fails due to network isolation, follow these steps:

- For BYO ACR:

    Verify that the private ACR resources are configured, including the cache rule and private endpoints. For more information about how to configure them, see steps 3 and 4 under the [Deploy a network isolated cluster with bring your own ACR](/en-us/azure/aks/network-isolated?pivots=byo-acr#deploy-a-network-isolated-cluster-with-bring-your-own-acr) section.
- For AKS-managed ACR:

    - By default, only Microsoft Container Registry (MCR) images are supported. If the image pull failure occurs with MCR images, check if the associated ACR and private endpoint resource named with the keyword `bootstrap` exist. If they don't exist, reconcile the cluster.
    - If the image pull failure occurs with images from other registries, create extra cache rules in the private ACR for those images.

## Issue 2: Cluster image pull fails after updating an existing cluster to a network isolated cluster or updating the private ACR resource ID

The failure is an intended behavior. To resolve this issue, reimage the node to update the kubelet configuration in Container Service Extension (CSE) following the update actions in [Update your ACR ID](/en-us/azure/aks/network-isolated?pivots=byo-acr#update-your-acr-id).

## Issue 3: ACR or associated cache rules, private endpoints, or private DNS zones are deleted

If the cache rule is deleted from the managed ACR accidentally, the mitigation is to delete the ACR and then reconcile the cluster. If the ACR itself, the associated private endpoints, or the associated private DNS zones are deleted accidentally, the mitigation is just to reconcile the cluster.

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.