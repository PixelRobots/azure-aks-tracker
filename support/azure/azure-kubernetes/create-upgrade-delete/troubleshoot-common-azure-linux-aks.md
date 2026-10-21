---
layout: Conceptual
title: Troubleshoot common issues for Azure Linux Container Host for AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-common-azure-linux-aks
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: suhuruli
ms.author: kaushika
ms.topic: troubleshooting
description: Troubleshoot commonly reported issues for Azure Linux container hosts on Azure Kubernetes Service (AKS).
ms.date: 2025-04-02T00:00:00.0000000Z
editor: v-jsitser
ms.reviewer: mnasser, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool), linux-related-content
locale: en-us
document_id: cbf7c655-da00-1406-1ddd-830981dd14bf
document_version_independent_id: cbf7c655-da00-1406-1ddd-830981dd14bf
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-common-azure-linux-aks.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/troubleshoot-common-azure-linux-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-common-azure-linux-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: f5ab9e3e-804d-3ede-8249-22fa3f083f3a
---

# Troubleshoot common issues for Azure Linux Container Host for AKS - Azure | Microsoft Learn

## Summary

This article provides troubleshooting steps for some of the commonly reported issues that you might experience when you use Azure Linux container hosts in Azure Kubernetes Service (AKS). For more information about how to get started using Azure Linux container hosts in AKS, see [Use Azure Linux with AKS](/en-us/azure/aks/use-azure-linux).

## Before you begin

Read the [official guide for troubleshooting Kubernetes clusters](https://kubernetes.io/docs/tasks/debug/debug-cluster/_print/). Also, read the [Microsoft engineer's guide to Kubernetes troubleshooting](https://github.com/feiskyer/kubernetes-handbook/blob/master/en/troubleshooting/index.md). This guide contains commands for troubleshooting pods, nodes, clusters, and other features.

Finally, review the [list of known limitations in Azure Linux](/en-us/azure/aks/use-azure-linux#limitations). An issue that you're trying to resolve might be one that we're already working on.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli), version 2.31 or a later version. If Azure CLI is already installed, you can find the version number by running `az --version`.

## About Azure Linux Container Host for AKS

Azure Linux is an open-source Linux distribution that Microsoft created. As a lightweight OS, Azure Linux has the following features:

- Contains only the packages that are needed to run container workloads
- Undergoes Azure validation tests
- Is compatible with Azure agents

Azure Linux Container Host for AKS is an operating system image for AKS that's optimized for running container workloads. It's maintained by Microsoft and based on Azure Linux. It provides reliability and consistency from cloud to edge across the [AKS](/en-us/azure/aks/intro-kubernetes), [AKS on Azure Stack HCI](/en-us/azure/aks/hybrid/overview), and [Azure Arc](/en-us/azure/azure-arc/overview) products. You can use Azure Linux container hosts to do the following processes:

- Deploy Azure Linux node pools in a new cluster.
- Add Azure Linux node pools to your existing Ubuntu clusters.
- Migrate your Ubuntu nodes to Azure Linux nodes.

For more information about Azure Linux, see the [Azure Linux](https://github.com/microsoft/CBL-Mariner) GitHub repository.

## Troubleshooting checklist

### Step 1: Review equivalent commands in Ubuntu and Azure Linux

Most commands in the Azure Linux OS, such as the process status (`ps`) command, resemble commands that are used in Ubuntu. However, package management is done by using the Tiny DNF (`tdnf`) command. The following table lists some common commands in Ubuntu and their equivalents in Azure Linux.

| Ubuntu command | Suggested Azure Linux command |
| --- | --- |
| `apt -- list installed` | `rpm -qa` |
| `apt autoclean` | `tdnf clean all` |
| `apt autoremove` | `dnf autoremove` |
| `apt dist-upgrade` | `dnf distro-sync` |
| `apt download` | `tdnf download` |
| `apt install` | `tdnf install` |
| `apt install --reinstall` | `tdnf reinstall` |
| `apt list - upgradable` | `dnf list updates` |
| `apt remove` | `tdnf remove` |
| `apt search` | `tdnf search` |
| `apt show` | `tdnf list` |
| `apt upgrade` | `tdnf upgrade` |
| `apt cache dump` | `tdnf list available` |
| `apt-cache dumpavail` | `tdnf list available` |
| `apt-cache policy` | `tdnf list` |
| `apt-cache rdepends` | `dnf repoquery -- alldeps - whatrequires` |
| `apt-cache search` | `tdnf search` |
| `apt-cache show` | `tdnf info` |
| `apt-cache stats` | (no exact equivalent; read the *Packages* file in the */var/lib/rpm* folder) |
| `apt-config shell` | `dnf shell` |
| `apt-file list` | `dnf repoquery -l` |
| `apt-file search` | `tdnf provides` |
| `apt-get autoremove` | `dnf autoremove` |
| `apt-get install` | `tdnf install` |
| `apt-get remove` | `tdnf remove` |
| `apt-get update` | `dnf clean expire-cache dnf check-update` |
| `apt-mark auto` | `tdnf install dnf mark remove` |
| `apt-mark manual` | `dnf mark install` |
| `apt-mark showmanual` | `dnf history userinstalled` |
| `add-apt-repository` | Edit `/etc/yum.repos.d/*.repo` files |
| `apt-key add` | `rpm --import` |

### Step 2: Check the Azure Linux version

Make sure that you're using the correct version of Azure Linux. The supported version of Azure Linux for consumption is Azure Linux 2.0. In the output of the following [az aks nodepool list](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command, the `osSKU` property should read `AzureLinux`.

```azurecli
az aks nodepool list --resource-group <resource-group-name> --cluster-name <aks-cluster-name>
```

Although this command might not address the issue that you're experiencing, versioning is a common issue for users who report that agents or extensions aren't working correctly on Azure Linux.

### Step 3: Understand the difference in certificate file paths

Azure Linux (and other RPM distributions) store certificates differently from Ubuntu.

On Azure Linux, the */etc/ssl/certs* path is a symbolic link to */etc/pki/tls/certs*. If a container expects to map */etc/ssl/certs* to use the *ca-certificates.crt* certificate file on Azure Linux, the container instead gets a symbolic link that points to nowhere. This behavior causes certificate-related errors in the container. The container also has to map */etc/pki* so that the container can follow the symbolic link chain. If the container has to work on both Ubuntu and Azure Linux hosts, you can map */etc/pki* by using the `DirectoryOrCreate` type in a [hostPath volume](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath).

### Step 4: Update Azure CLI and the AKS preview extension

If you try to deploy an Azure Linux AKS cluster by using Azure CLI, you might receive an error message that states that the `AzureLinux` option isn't supported for the `OSSku` parameter. This message means that you might be using an outdated version of the Azure CLI or the AKS preview extension. To fix this issue, take one or both of the following two actions:

- If Azure CLI isn't up to date, install the latest version. To upgrade Azure CLI, run the following [az upgrade](/en-us/cli/azure/reference-index#az-upgrade) command:

    ```azurecli
    az upgrade
    ```
- If you have an older version of the `aks-preview` extension installed, install a newer version so that the `OSSku` parameter has a value of `AzureLinux`. To upgrade the extension, run the following [az extension update](/en-us/cli/azure/extension#az-extension-update) command:

    ```azurecli
    az extension update --name aks-preview
    ```

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.