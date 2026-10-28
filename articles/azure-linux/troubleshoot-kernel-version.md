---
layout: Conceptual
title: Troubleshoot Outdated Kernel Versions in Azure Linux Container Host Node Images | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/troubleshoot-kernel-version
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
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
manager: kumud
description: Guidance on troubleshooting issues where Azure Linux Container Host node images in AKS are running outdated kernel versions, including identifying symptoms, understanding causes, and applying solutions.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: troubleshooting-general
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 6d842cc4-adc2-770f-b926-92b1d6453e31
document_version_independent_id: bcd34bf5-ba8c-7855-5505-235bdfeae59f
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/troubleshoot-kernel-version.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/troubleshoot-kernel-version
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/troubleshoot-kernel-version.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a28d871e-f8af-0beb-5b89-f77e0fdf7420
---

# Troubleshoot Outdated Kernel Versions in Azure Linux Container Host Node Images | Microsoft Learn

During migration or when adding new node pools to your Azure Linux Container Host, you might encounter issues with outdated kernel versions. [Azure Kubernetes Service (AKS)](/en-us/azure/aks/intro-kubernetes) releases a new Azure Linux node image every week, which is used for new node pools and as the starting image for scaling up. However, older node pools might not be updating their kernel versions as expected.

This article provides guidance on how to troubleshoot issues where Azure Linux Container Host node images in AKS are running outdated kernel versions, including identifying the symptoms, understanding the underlying causes, and applying recommended solutions to ensure that your nodes are running the latest kernel versions.

## Verify the kernel version of your node pools

1. Check the kernel version of your node pools using the following command:

    ```bash
    kubectl get nodes -o wide
    ```
2. Compare the kernel version of your node pools with the latest kernel published on [packages.microsoft.com](https://packages.microsoft.com/azurelinux/).

## Symptom

A common symptom of this issue is that the Azure Linux nodes aren't using the latest kernel version.

## Causes

You might encounter outdated kernel versions on Azure Linux Container Host node images in AKS due to one or both of the following reasons:

- Automatic node-image upgrades weren't enabled when the node pool was created.
- The base image that AKS uses to start clusters runs two weeks behind the latest kernel versions due to their rollout procedure.

## Solution

You can enable automatic upgrades using [GitHub Actions](/en-us/azure/aks/node-upgrade-github-actions) and reboot the nodes.

### Enable automatic AKS node image upgrades

# [Azure CLI](#tab/azure-cli)
Enable automatic node image upgrades on a new AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the parameter `--auto-upgrade-channel node-image`. Replace the placeholder values with your own values.

```azurecli
az aks create --name <cluster-name> --resource-group <resource-group-name> --os-sku AzureLinux --auto-upgrade-channel node-image
```

# [ARM template](#tab/arm-template)
Enable automatic node image upgrades in an Azure Resource Manager (ARM) template by setting the [`upgradeChannel`](/en-us/azure/templates/microsoft.containerservice/managedclusters?tabs=bicep&amp;pivots=deployment-language-bicep#managedclusterautoupgradeprofile) property in `autoUpgradeProfile` to `node-image`. For example:

```json
    autoUpgradeProfile: {
      upgradeChannel: 'node-image'
    }
```

---

### Reboot the nodes

When updating the kernel version, you need to reboot the node to use the new kernel version. We recommend that you set up the [kured daemonset](/en-us/azure/aks/node-updates-kured). You can use [Kured](https://github.com/kubereboot/kured) to monitor your nodes for the `/var/run/reboot-required` file, drain the workload, and reboot the nodes.

### Workaround: Manual upgrades

If you need a quick workaround, you can manually upgrade the node image on an AKS cluster using the [`az aks nodepool upgrade`](/en-us/cli/azure/aks#az-aks-nodepool-upgrade) command. For example:

```azurecli
az aks nodepool upgrade \
    --resource-group testAzureLinuxResourceGroup \
    --cluster-name testAzureLinuxCluster \
    --name myAzureLinuxNodePool \
    --node-image-only
```