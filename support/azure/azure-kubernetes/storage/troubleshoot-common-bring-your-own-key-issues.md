---
layout: Conceptual
title: Troubleshoot common bring your own key (BYOK) issues - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/troubleshoot-common-bring-your-own-key-issues
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: andyzhangx
ms.author: xiazhang
ms.topic: troubleshooting
description: Learn how to troubleshoot common Bring Your Own Key (BYOK) issues, including key vault and ephemeral OS disk problems, on Azure Kubernetes Service (AKS).
ms.date: 2023-07-28T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: meolsen, chiragpa, joharder, pram, vijayrod, jamote, ramankum, xinyuyuan, aksstoragedev, cssakscic, v-leedennis
ms.service: azure-kubernetes-service
ms.custom: sap:Storage
locale: en-us
document_id: 0e4687ea-b774-33a2-11bd-19922ab0a511
document_version_independent_id: 0e4687ea-b774-33a2-11bd-19922ab0a511
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/storage/troubleshoot-common-bring-your-own-key-issues.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/storage/troubleshoot-common-bring-your-own-key-issues
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/storage/troubleshoot-common-bring-your-own-key-issues.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 17b68027-f8d7-3b2b-6eef-4ac31d95d9e9
---

# Troubleshoot common bring your own key (BYOK) issues - Azure | Microsoft Learn

## Summary

This article discusses troubleshooting methods for the most common bring your own key (BYOK) issues on Microsoft Azure Kubernetes Service (AKS).

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli)

## Troubleshooting checklist

### Step 1: Register a preview feature to enable BYOK on an ephemeral OS disk

To register the preview feature that enables BYOK on an ephemeral operating system (OS) disk (`Microsoft.ContainerService/EnableBYOKOnEphemeralOSDiskPreview`), run the [az feature register](/en-us/cli/azure/feature#az-feature-register) and [az feature show](/en-us/cli/azure/feature#az-feature-show) commands. For instructions, see [Register customer-managed key (preview) feature](/en-us/azure/aks/azure-disk-customer-managed-keys#register-customer-managed-key-preview-feature).

### Step 2: Create a cluster that uses BYOK on an ephemeral OS disk

To create an AKS cluster that uses BYOK on an ephemeral OS disk, run the [az aks create](/en-us/cli/azure/aks#az-aks-create) command. For instructions, see [Create a new AKS cluster and encrypt the OS disk](/en-us/azure/aks/azure-disk-customer-managed-keys#create-a-new-aks-cluster-and-encrypt-the-os-disk).

Note

If you don't specify the `--node-osdisk-type` parameter in the `az aks create` command, the default OS disk type for the node is `Ephemeral` only if the current virtual machine (VM) size supports ephemeral OS disks. For more information, see [Ephemeral OS disks for Azure VMs](/en-us/azure/virtual-machines/ephemeral-os-disks).

## Cause 1: Can't enable purge protection in the key vault

If you receive a `CreateVMSSAgentPoolFailed` error code and a `KeyVaultNotPurgeProtectionEnabled` error subcode, the creation of an agent pool for a virtual machine scale set failed because you didn't enable purge protection when you created the key vault.

### Solution 1: Enable purge protection when you create the key vault

Run the [az keyvault create](/en-us/cli/azure/keyvault#az-keyvault-create) command again, and specify a value of `true` for the `--enable-purge-protection` parameter. For instructions, see [Create an Azure Key Vault instance](/en-us/azure/aks/azure-disk-customer-managed-keys#create-an-azure-key-vault-instance).

## Cause 2: Key vault and disk are in different regions when agent pool creation fails for a virtual machine scale set

If you receive a `CreateVMSSAgentPoolFailed` error code and a `KeyVaultAndDiskInDifferentRegions` error subcode, the key vault and the disk encryption set are located in different regions. The key vault and disk encryption set must be in the same region.

### Solution 2: Use the same region as for the disk when you create the key vault

Run the [az keyvault create](/en-us/cli/azure/keyvault#az-keyvault-create) command again, and make sure that the value that you specify in the `--location` parameter is the same region that you used for the disk encryption set. For instructions, see [Create an Azure Key Vault instance](/en-us/azure/aks/azure-disk-customer-managed-keys#create-an-azure-key-vault-instance).

## Cause 3: Disk encryption set isn't granted

If you delete the disk encryption set permission for the key vault, the AKS cluster node won't run. In this situation, you receive the following error message in the disk encryption set page of the Azure portal:

> 
> To associate a disk, image, or snapshot with this disk encryption set, you must grant permissions to the key vault.

### Solution 3: Update the security policy settings

Update the security policy settings again by running the [az keyvault set-policy](/en-us/cli/azure/keyvault#az-keyvault-set-policy) command. For instructions, see [Grant the DiskEncryptionSet access to key vault](/en-us/azure/aks/azure-disk-customer-managed-keys#grant-the-diskencryptionset-access-to-key-vault).

## Reference

- [Bring your own keys (BYOK) with Azure disks in Azure Kubernetes Service (AKS)](/en-us/azure/aks/azure-disk-customer-managed-keys)