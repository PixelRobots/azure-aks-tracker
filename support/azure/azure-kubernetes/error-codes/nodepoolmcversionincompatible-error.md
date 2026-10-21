---
layout: Conceptual
title: NodePoolMcVersionIncompatible error - Node pool version 1.x and control plane version 1.y are incompatible - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/nodepoolmcversionincompatible-error
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
description: Resolve the NodePoolMcVersionIncompatible error during AKS node pool upgrades when versions are out of range. Follow the steps to upgrade successfully.
ms.date: 2024-10-23T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: axelg, chiragpa, cssakscic, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 5ee4ebbf-d18c-d37f-ab56-e858b303e124
document_version_independent_id: 5ee4ebbf-d18c-d37f-ab56-e858b303e124
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/nodepoolmcversionincompatible-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/nodepoolmcversionincompatible-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/nodepoolmcversionincompatible-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: da1281ab-2071-2043-138f-27d4b9240ced
---

# NodePoolMcVersionIncompatible error - Node pool version 1.x and control plane version 1.y are incompatible - Azure | Microsoft Learn

## Summary

This article discusses how to resolve the "NodePoolMcVersionIncompatible - Node pool version 1.x.y and control plane version 1.a.b are incompatible" error that occurs when you upgrade a node pool in a Microsoft Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli)

## Symptoms

When you upgrade a node pool in an AKS cluster, you receive one of the following error messages:

> 
> **BadRequest - NodePoolMcVersionIncompatible**
> 
> Error: Node pool version 1.x.y and control plane version 1.a.b are incompatible. Minor version of node pool cannot be more than 2 versions less than control plane's version. Minor version of node pool is x and control plane is a. For more information, please check https://aka.ms/version-skew-policy.
> 
> Resource ID: /subscriptions/&lt;subscription\_id&gt;/resourcegroups/&lt;aks\_cluster\_resource\_group&gt;/providers/Microsoft.ContainerService/managedClusters/&lt;aks\_cluster\_name&gt;.

> 
> **BadRequest - NodePoolMcVersionIncompatible**
> 
> Error: Node pool version 1.x.y and control plane version 1.a.b are incompatible. Minor version of node pool version x is bigger than control plane version a. For more information, please check https://aka.ms/version-skew-policy.
> 
> Resource ID: /subscriptions/&lt;subscription\_id&gt;/resourcegroups/&lt;aks\_cluster\_resource\_group&gt;/providers/Microsoft.ContainerService/managedClusters/&lt;aks\_cluster\_name&gt;.

## Cause

These issues occur if you try to upgrade a node pool that's more than two versions behind the AKS control plane version, or if you try to add a node pool that's at a more recent version than the control plane version.

You must meet the following conditions when you upgrade a node pool:

- The node pool version can't be greater than the control *&lt;major&gt;.&lt;minor&gt;.&lt;patch&gt;* version.
- The node pool version must be within two *minor* versions of the control plane version.

For more information, see the [AKS validation rules for upgrade](/en-us/azure/aks/use-multiple-node-pools#validation-rules-for-upgrades).

## Solution 1: Make sure that the node pool version is within two minor versions of the control plane version

1. [Get the control plane version](/en-us/azure/aks/tutorial-kubernetes-upgrade-cluster#get-available-cluster-versions) by running the [az aks get-upgrades](/en-us/cli/azure/aks#az-aks-get-upgrades) command in Azure CLI.

    Here's an example use of the command. The `MasterVersion` output column contains the control plane version.

    ```azurecli
    az aks get-upgrades --resource-group aksrg --name testcluster1 --output table  
    ```

    ```output
    Name     ResourceGroup    MasterVersion    Upgrades
    -------  ---------------  ---------------  -----------------------
    default  aksrg            1.23.12          1.23.15, 1.24.6, 1.24.9
    ```
2. [Upgrade the node pool](/en-us/azure/aks/use-multiple-node-pools#upgrade-a-node-pool) by running the [az aks nodepool upgrade](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) Azure CLI command, and provide a Kubernetes version that's within two minor versions of the control plane version.

    For example, if the control plane version is `1.23.12`, you can specify the Kubernetes version of the node pool as `1.23.8` or `1.23.12`.

    Here's an example use of the command:

    ```azurecli
    az aks nodepool upgrade \
        --resource-group aksrg \
        --cluster-name testcluster1 \
        --name mynodepool \
        --kubernetes-version 1.23.8 \
        --no-wait
    ```

## Solution 2: Make sure that the node pool version isn't greater than the control plane version

1. [Get the control plane version](/en-us/azure/aks/tutorial-kubernetes-upgrade-cluster#get-available-cluster-versions) by running the [az aks get-upgrades](/en-us/cli/azure/aks#az-aks-get-upgrades) command in Azure CLI.

    Here's an example use of the command. The `MasterVersion` output column contains the control plane version.

    ```azurecli
    az aks get-upgrades --resource-group aksrg --name testcluster1 --output table  
    ```

    ```output
    Name     ResourceGroup    MasterVersion    Upgrades
    -------  ---------------  ---------------  -----------------------
    default  aksrg            1.23.12          1.23.15, 1.24.6, 1.24.9
    ```
2. [Upgrade the node pool](/en-us/azure/aks/use-multiple-node-pools#upgrade-a-node-pool) by running the [az aks nodepool upgrade](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-upgrade) Azure CLI command, and provide a Kubernetes version that's less than or equal to the control plane version.

    Here's an example use of the command:

    ```azurecli
    az aks nodepool upgrade \
        --resource-group aksrg \
        --cluster-name testcluster1 \
        --name mynodepool \
        --kubernetes-version 1.23.12 \
        --no-wait
    ```