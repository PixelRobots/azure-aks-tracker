---
layout: Conceptual
title: Overview of Azure Linux Container Host Packages for Azure Kubernetes Service (AKS) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/aks-packages
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
description: TLearn about the packages included in the Azure Linux Container Host for Azure Kubernetes Service (AKS), how to view the package list for a given node image version, and how to determine the versions of packages installed in a running cluster.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: overview
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 264f55ed-f0c0-99c1-8324-6759ffcdb06b
document_version_independent_id: cb58897f-80a0-842c-3a3b-9ce006bd4c60
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/aks-packages.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/aks-packages
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/aks-packages.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a7dab4d0-b30c-622f-d2a4-236448cb8312
---

# Overview of Azure Linux Container Host Packages for Azure Kubernetes Service (AKS) | Microsoft Learn

The Azure Linux Container Host for Azure Kubernetes Service (AKS) is based on the Microsoft Azure Linux distribution, which supports thousands of packages. The container host contains a subset of those packages based on customer operating system (OS) and Kubernetes needs. This set of curated packages is among the most requested and necessary packages to run container workloads based on feedback from customers and the open-source community.

This article provides an overview of the packages included in the Azure Linux Container Host for AKS, how to view the package list for a given node image version, and how to determine the versions of packages installed in a running cluster.

## Azure Linux Container Host package list

The Azure Linux Container Host package list includes all the needed dependencies to run an Azure Linux virtual machine (VM) and also pulls in any necessary AKS dependencies. To view the full package list for the latest Azure Linux Container Host image released by AKS, see [/release-notes/AKSAzureLinuxV3/gen2/latest.txt](https://github.com/Azure/AgentBaker/blob/main/vhdbuilder/release-notes/AKSAzureLinuxV3/gen2/latest.txt).

Whenever AKS releases a new Azure Linux Container Host image, we update the [AKS Azure Linux release notes folder](https://github.com/Azure/AgentBaker/blob/main/vhdbuilder/release-notes/AKSAzureLinuxV3/gen2/latest.txt) with a new `latest.txt` file, which details the most up-to-date package list. You can also view previous image package lists and the historical versions of each package in the most recent image release in the GitHub repository. For each prior image release, you can find a corresponding `.txt` file with the naming convention `YYYY.MM.DD.txt`, where `YYYY.MM.DD` is the date of each previous image release.

Note

Packages on a running Azure Linux Container Host cluster might be automatically updated to their latest versions as new packages are released on [packages.microsoft.com](https://packages.microsoft.com/).

### Kernel package

One of the key benefits of the Azure Linux Container Host package set is the kernel package. We patch and update the Linux kernel package for the Azure Linux Container Host at least twice a month. This package is managed and owned by an entire Microsoft team, which ensures it's secure and contains all the latest updates for development.

## Find cluster package versions

If you have direct access to the container host, you can query packages from the host itself using the commands in List all installed packages and Check package installation dates. If you don't have direct access to the container host, you can work backwards from the node image version date to determine the package versions in a cluster.

### List all installed packages

List all the installed packages and their versions using the following command:

```console
rpm -qa
```

### Check package installation dates

Determine when individual packages were installed using the following command:

```console
cat /var/log/dnf.log
```

### Determine package versions from node image version

1. Get the node image version for your cluster using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command. Replace the `<resource-group-name>` and `<cluster-name>` placeholders with your own values.

    ```azurecli
    az aks show --resource-group <resource-group-name> --name <cluster-name> | grep nodeImageVersion
    ```
2. Check the [AKS Azure Linux release notes folder](https://github.com/Azure/AgentBaker/blob/main/vhdbuilder/release-notes/AKSAzureLinuxV3/gen2) for the file that corresponds with the previously determined node image version date. In the file, the *Installed Packages Begin* section lists all the package versions in your cluster.