---
layout: Conceptual
title: Resolve AKSOperationPreempted or AKSOperationPreemptedByDelete error when performing a new operation in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-codes/aksoperationpreempted-error
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
description: Resolve the AKSOperationPreempted or AKSOperationPreemptedByDelete error on an AKS cluster. Learn how to check or abort the blocking operation and retry.
ms.date: 2026-11-23T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, erbookbi, jopalhei, dorinalecu, v-leedennis, v-weizhu, kaushika
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
ai-usage: ai-assisted
locale: en-us
document_id: 4255b04c-0942-aaa5-5bc6-82c596f313ab
document_version_independent_id: 4255b04c-0942-aaa5-5bc6-82c596f313ab
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/error-codes/aksoperationpreempted-error.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/error-codes/aksoperationpreempted-error
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/error-codes/aksoperationpreempted-error.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 423a88e4-2fa4-a176-2ab7-cefb3ea30a88
---

# Resolve AKSOperationPreempted or AKSOperationPreemptedByDelete error when performing a new operation in AKS - Azure | Microsoft Learn

## Summary

This article explains how to resolve the `AKSOperationPreempted` or `AKSOperationPreemptedByDelete` error in Azure Kubernetes Service (AKS). The error occurs when another operation preempts your new operation on a cluster. Learn how to check or abort the blocking operation so that you can retry successfully.

## Symptoms

When you try to perform a new operation on an AKS cluster, you receive one of the following error messages:

- > 
> Code: "AKSOperationPreempted"
> 
> Message: "This operation has been preempted by another operation with ID &lt;operation ID&gt;"

    This message indicates that another operation preempted the operation. The error message gives the GUID for the new operation.
- > 
> Code: "AKSOperationPreemptedByDelete"
> 
> Message: "This operation has been preempted by Deleting operation."

    This message indicates that a delete operation preempted the operation.

## Cause

This error usually occurs when a subsequent operation interrupts an in-progress operation. The error indicates the subsequent operation, which can be a delete operation or any other operation.

## Solution

To resolve this issue, use one of the following methods. When no operations are running, try your operation again.

- Wait for the previous operation to complete. Check the status of the operation by using the ID in the error message with the following command.

    ```azurecli
    az aks operation show \
        --resource-group myResourceGroup \
        --name myCluster \
        --operation-id "<operation-id>"
    ```
- Run an `abort` command to stop the previous operation. For more information about how to abort an operation, see [Terminate a long running operation on an Azure Kubernetes Service (AKS) cluster](/en-us/azure/aks/manage-abort-operations).

## References

- [General troubleshooting of AKS cluster creation issues](../create-upgrade-delete/troubleshoot-aks-cluster-creation-issues)