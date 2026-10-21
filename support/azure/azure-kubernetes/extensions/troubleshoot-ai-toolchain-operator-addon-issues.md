---
layout: Conceptual
title: Troubleshoot AKS AI Toolchain Operator Add-on Errors - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-ai-toolchain-operator-addon-issues
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
description: Learn how to resolve errors that occur when you try to enable the Azure Kubernetes Service (AKS) AI toolchain operator add-on.
ms.date: 2025-05-16T00:00:00.0000000Z
ms.reviewer: sachidesai, albarqaw, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Extensions, Policies and Add-Ons, references_regions
locale: en-us
document_id: 0c6f2d12-367b-6e2c-085b-1dafd075fa10
document_version_independent_id: 0c6f2d12-367b-6e2c-085b-1dafd075fa10
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/extensions/troubleshoot-ai-toolchain-operator-addon-issues.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/extensions/troubleshoot-ai-toolchain-operator-addon-issues
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/extensions/troubleshoot-ai-toolchain-operator-addon-issues.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: c889cd23-04bb-bc8c-b491-3487c8ad684d
---

# Troubleshoot AKS AI Toolchain Operator Add-on Errors - Azure | Microsoft Learn

## Summary

This article provides guidance on resolving errors that might occur when you enable the Microsoft Azure Kubernetes Service (AKS) AI Toolchain Operator (KAITO) add-on during cluster creation or update.

## Prerequisites

Ensure the following tools are installed and configured. They're used in the following sections.

- [Azure CLI](/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), the Kubernetes command-line client

## Symptoms

The KAITO add-on consists of two controllers: the `gpu-provisioner` controller and the `workspace` controller. After enabling the add-on and deploying a KAITO workspace, you might encounter one or more of the following errors in your pod logs:

| Error message | Cause |
| --- | --- |
| Workspace was not created | Cause 1: Incorrect KAITO custom resource configuration |
| GPU node was not created | Cause 2: GPU quota limitations |
| Resource ready condition is not `True` | Cause 3: Long pull time for model inference images |

## Cause 1: incorrect KAITO custom resource configuration

After you enable the add-on and deploy a preset or custom workspace custom resource (CR), the `workspace` controller includes a validation webhook. This webhook blocks common mistakes of setting wrong values in the CR specification.

To resolve this issue, follow these steps:

1. Check your `gpu-provisioner` and `workspace` pod logs.
2. Ensure that any updates to the GPU virtual machine (VM) size meet the requirements of your model size.
3. Once the workspace CR is successfully created, track the deployment progress by running the following commands:

    ```azurecli
    kubectl get machine -o wide
    ```

    ```azurecli
    kubectl get workspace -o wide
    ```

## Cause 2: GPU quota limitations

The `gpu-provisioner` controller might fail to create GPU nodes due to quota limitations in your subscription or region. In this case, you can check the machine CR status (internal CR created by the `workspace` controller) for error messages. The machine CR created by the `workspace` controller has a `kaito.sh/workspace` label key whose value is the workspace's name.

To resolve this issue, use one of the following methods:

- Request an [increase in the subscription quota](/en-us/azure/quotas/quickstart-increase-quota-portal?) for the required GPU VM family of your deployment.
- Check the [GPU instance availability](https://azure.microsoft.com/explore/global-infrastructure/products-by-region/table?msockid=182ea2d5e1ff6eb61ccbb1b8e5ff608a) in the specific region of your AKS cluster.

    If the required GPU VM size is unavailable in your current region, consider switching to a different region or selecting an alternative GPU VM size.

## Cause 3: long pull time for model inference images

If the image access mode is set to private, the model inference image might not be pulled. This issue can occur for images with specified URLs and pull secrets.

Inference images are typically large (30 GB -100 GB), so a longer image pull time is expected. Depending on your AKS cluster's networking setup, the pull process might take up to tens of minutes.