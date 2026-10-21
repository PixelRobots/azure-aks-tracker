---
layout: Conceptual
title: Troubleshoot InvalidParameter error - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-invalidparameter
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
description: Introduces how to troubleshoot InvalidParameter error when you try to create and deploy an Azure Kubernetes Service (AKS) cluster.
ms.date: 2024-11-19T00:00:00.0000000Z
editor: v-gsitser
ms.reviewer: rissing, chiragpa, erbookbi, jaewonpark, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: dac62d49-71ce-2981-9836-2d2e6e4ea163
document_version_independent_id: dac62d49-71ce-2981-9836-2d2e6e4ea163
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/error-code-invalidparameter.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/error-code-invalidparameter
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/error-code-invalidparameter.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: aaf03aba-0f8a-0896-0d18-02ba2eb90e75
---

# Troubleshoot InvalidParameter error - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the `InvalidParameter` error that occurs when you try to create and deploy a Microsoft Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli), version 2.0.81 or a later version. If Azure CLI is already installed, you can find the version number by running `az --version`.

## Symptoms

When you create an AKS cluster, the provided configurations are usually validated before the cluster is created. However, on rare occasions, a parameter passes validation before the AKS cluster is created but causes errors when the resources for the cluster are created. Errors that are related to invalid parameters might resemble the following examples:

- Scenario: The selected VM size is not available

    ```
    Code="InvalidParameter"
    
    Message="**The requested VM size Standard_D4s_v3 is not available in the current region. The sizes available in the current region are: ExtraSmall_Internal, Small_Internal, Medium_Internal, Large_Internal, ExtraLarge_Internal, Standard_DC2as_v5, Standard_DC4as_v5, Standard_DC8as_v5, Standard_DC16as_v5, Standard_DC32as_v5, Standard_DC48as_v5, Standard_DC64as_v5, Standard_DC96as_v5, Standard_DC2ads_v5, Standard_DC4ads_v5, Standard_DC8ads_v5, Standard_DC16ads_v5, Standard_DC32ads_v5, Standard_DC48ads_v5, Standard_DC64ads_v5, Standard_DC96ads_v5, Standard_EC2as_v5, Standard_EC4as_v5, Standard_EC8as_v5, Standard_EC16as_v5, Standard_EC20as_v5, Standard_EC32as_v5, Standard_EC48as_v5, Standard_EC64as_v5, Standard_EC96as_v5, Standard_EC96ias_v5, Standard_EC2ads_v5, Standard_EC4ads_v5, Standard_EC8ads_v5, Standard_EC16ads_v5, Standard_EC20ads_v5, Standard_EC32ads_v5, Standard_EC48ads_v5, Standard_EC64ads_v5, Standard_EC96ads_v5, Standard_EC96iads_v5.\r\nFind out more on the available VM sizes in each region at <https://aka.ms/azureregions>."
    
    Target="vmSize"
    ```
- Scenario: Cluster names are unavailable or conflict with Azure reserved values

    - Example 1

        ```
        Code="InvalidParameter"
        
        Message="The value of parameter name is invalid. Error details: "omsagent-aks-dev-microsoft" managed cluster name is invalid because 'MICROSOFT' and 'WINDOWS' can't be used as either a whole word or a substring in the name.. Please see https://aka.ms/aks-naming-rules for more details."
        ```
    - Example 2

        ```
        Message="The value of parameter name is invalid. Error details: "login" managed cluster name is invalid because 'LOGIN' and 'XBOX' can't be used at the start of a resource name, but can be used later in the name.. Please see https://aka.ms/aks-naming-rules for more details."
        ```
    - Example 3

        ```
        Message=" The value of parameter name is invalid. Error details: "azure" managed cluster name is invalid because it is reserved.. Please see https://aka.ms/aks-naming-rules for more details.
        Target: name"
        ```

## Cause

This issue occurs because one of the following conditions is true:

- The Azure Virtual Machine SKU isn't available in the selected region.
- The service principal is invalid.
- A virtual network, subnet, or route table is invalid.
- An Azure CLI parameter is invalid.
- The value of parameter name is unavailable or reserved by Azure.

There might also be other reasons that your cluster creation attempt failed.

## Solution

In the following table, follow the link for the appropriate troubleshooting step.

| Troubleshooting step | Reference link |
| --- | --- |
| Check whether the SKU is available | [Resolve errors for SKU not available](/en-us/azure/azure-resource-manager/troubleshooting/error-sku-not-available) |
| Verify that the service principal is valid | [Service principals together with AKS](/en-us/azure/aks/kubernetes-service-principal) |
| Verify that any commands that were used to create the cluster are valid | [az aks](/en-us/cli/azure/aks#az-aks-create) (Azure CLI reference) |
| Verify that any custom network resources that were used to create the cluster are valid | [Configure Azure CNI networking in AKS](/en-us/azure/aks/configure-azure-cni) and [Customize cluster egress with a user-defined route](/en-us/azure/aks/egress-outboundtype) |
| Avoid using unavailable or Azure-reserved values for names | Refer to the error messages provided |

## More information

- [General troubleshooting of AKS cluster creation issues](troubleshoot-aks-cluster-creation-issues)