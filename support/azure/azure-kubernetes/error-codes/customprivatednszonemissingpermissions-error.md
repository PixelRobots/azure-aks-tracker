---
layout: Conceptual
title: CustomPrivateDNSZoneMissingPermissionError Error Code - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/customprivatednszonemissingpermissions-error
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: jotavar
ms.author: jotavar
ms.topic: troubleshooting
description: Learn how to resolve the CustomPrivateDNSZoneMissingPermissionError error that occurs when you try to create or update an Azure Kubernetes Service (AKS) cluster.
ms.date: 2023-11-28T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: cssakscic, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: 0aac3e90-85a9-2bfe-ef45-e5d5d97af2a5
document_version_independent_id: 0aac3e90-85a9-2bfe-ef45-e5d5d97af2a5
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/customprivatednszonemissingpermissions-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/customprivatednszonemissingpermissions-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/customprivatednszonemissingpermissions-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 888ef774-1fe5-26dd-c5d7-1d6b9951666a
---

# CustomPrivateDNSZoneMissingPermissionError Error Code - Azure | Microsoft Learn

## Summary

This article discusses how to identify and resolve the "CustomPrivateDNSZoneMissingPermissionError" error code that occurs when you try to create or update a Microsoft Azure Kubernetes Service (AKS) cluster.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli), version 2.53.0 or a later version. To find your installed version, run `az --version`.

## Symptoms

An AKS cluster create or update operation fails and returns the following error message:

> 
> **Code: CustomPrivateDNSZoneMissingPermissionError** Message: Service principal or user-assigned identity must be given permission to read and write to custom private dns zone &lt;custom-private-dns-zone-resource-id&gt;. Check access result not allowed for action Microsoft.Network/privateDnsZones/read.

## Cause

Before AKS runs a cluster create or update operation for a private cluster that uses a [custom private DNS zone](/en-us/azure/aks/private-clusters#configure-a-private-dns-zone), it checks whether the cluster's managed identity or service principal has the required permissions to control the private DNS zone. If AKS doesn't find the necessary permissions, it blocks the operation so that the cluster doesn't enter a failed state.

## Solution

To create the missing role assignment, follow these steps:

1. Get the resource ID of the cluster's private DNS zone by running the [az aks show](/en-us/cli/azure/aks#az-aks-show) command, and store it as the `CUSTOM_PRIVATE_DNS_ZONE_ID` variable:

    ```azurecli
    CUSTOM_PRIVATE_DNS_ZONE_ID=$(az aks show \
        --resource-group <aks-resource-group> \
        --name <aks-cluster-name> \
        --query apiServerAccessProfile.privateDnsZone \
        --output tsv)
    ```

    Note

    Because the resource ID of the custom private DNS zone was also shown in the original error message, you can alternatively assign that resource ID to the variable instead of running the `az aks show` command.
2. Assign the [Private DNS Zone Contributor](/en-us/azure/role-based-access-control/built-in-roles#private-dns-zone-contributor) role to the cluster's managed identity or service principal by running the [az role assignment create](/en-us/cli/azure/role/assignment#az-role-assignment-create) command:

    ```azurecli
    az role assignment create --role "Private DNS Zone Contributor" \
        --scope $CUSTOM_PRIVATE_DNS_ZONE_ID \
        --assignee <control-plane-principal-id>
    ```

Note

It can take up to 60 minutes to finish granting permissions to your cluster's managed identity or service principal.