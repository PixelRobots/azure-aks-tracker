---
layout: Conceptual
title: Troubleshoot Package Upgrade Issues on Azure Linux Container Host for Azure Kubernetes Service (AKS) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/troubleshoot-package-upgrade-aks
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
description: Guidance on troubleshooting issues where packages on the Azure Linux Container Host for AKS fail to receive automatic upgrades, including identifying symptoms, understanding causes, and applying solutions.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: troubleshooting-general
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 9eeafe9c-026a-0263-a789-9e47635e5380
document_version_independent_id: f4867e22-aff0-45ba-19fa-f218492a85ba
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/troubleshoot-package-upgrade-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/troubleshoot-package-upgrade-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/troubleshoot-package-upgrade-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 951e2363-edc9-3f55-82a5-3d9d27ad9277
---

# Troubleshoot Package Upgrade Issues on Azure Linux Container Host for Azure Kubernetes Service (AKS) | Microsoft Learn

The Azure Linux Container Host for Azure Kubernetes Service (AKS) has `dnf-automatic` enabled by default, a systemd service that runs daily and automatically installs any recently published updated packages. Having this service enabled ensures that packages in the Azure Linux Container Host should automatically update when a fix is published. However, sometimes the packages in the Azure Linux Container Host fail to receive automatic upgrades, which can prevent the system from receiving the latest fixes and security updates in a timely manner.

This article provides guidance on how to troubleshoot issues where packages on the Azure Linux Container Host for AKS fail to receive automatic upgrades, including identifying the symptoms, understanding the underlying causes, and applying recommended solutions to ensure that package updates are applied successfully.

Note

For some settings of the [AKS node operating system (OS) upgrade channel](/en-us/azure/aks/auto-upgrade-node-image), `dnf-automatic` is disabled by default.

## Symptoms

When packages on the Azure Linux Container Host fail to receive automatic upgrades, you might notice one or more of the following symptoms:

- Error messages while referencing or using an updated package.
- Packages not functioning as expected.
- Outdated versions of packages are displayed when checking the Azure Linux Container Host package list. You can verify if the packages on your image are synchronized with the recently published packaged by visiting the repository on [packages.microsoft.com](https://packages.microsoft.com/azurelinux/) or checking the release notes in the [Azure Linux GitHub](https://github.com/microsoft/azurelinux/releases) repository.

## Cause

Some packages, such as the Linux Kernel, require a reboot for the updates to take effect. To facilitate automatic reboots, the Azure Linux virtual machine (VM) runs the check-restart service, which creates the `/var/run/reboot-required` file when a package update requires a reboot.

## Solution

To ensure that Kubernetes acts on the request for a reboot, we recommend setting up the [kured daemonset](/en-us/azure/aks/node-updates-kured). [Kured](https://github.com/kubereboot/kured) monitors your nodes for the `/var/run/reboot-required` file and, when it's found, drains the work off the node and reboots it.