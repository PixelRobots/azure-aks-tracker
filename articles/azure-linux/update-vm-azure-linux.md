---
layout: Conceptual
title: Update an Azure Linux Virtual Machine (VM) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/update-vm-azure-linux
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
description: This article describes how to keep an Azure Linux virtual machine (VM) up to date using image-based or package-based updates.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: how-to
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 4a7b8c17-f5d5-7b43-2195-d338a5130e00
document_version_independent_id: d028c93c-8f93-6b74-b089-1bcf316acf11
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/update-vm-azure-linux.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/update-vm-azure-linux
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/update-vm-azure-linux.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/2ed91286-6cf7-4b83-810d-75d0ee3b09dd
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/6735bd7e-4f7b-457d-b58c-29e6f0198677
platformId: ca6658bf-6ac8-ed40-429c-5fccc73892f4
---

# Update an Azure Linux Virtual Machine (VM) | Microsoft Learn

This article explains how to keep an Azure Linux virtual machine (VM) updated using:

- **Image-based updates**: Redeploy the VM from a newer Azure Linux image. This approach aligns naturally with safe deployment practices (SDP).
- **Package-based updates**: Apply package updates in place on a running VM. This approach requires more coordination to roll out safely.

Select the method that best fits your release process. You can also combine both approaches.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Image-based updates

Azure Linux ships a new image release each month that includes the previous month's package updates. To stay current, redeploy your fleet from the latest Azure Linux image release.

A typical rollout looks like this:

1. Pull the latest Azure Linux image when it's published.
2. Add the latest versions of any extra packages your workload uses.
3. Test the new image.
4. Roll out the image using a safe deployment practice (SDP).

### Automatic OS image upgrades for Virtual Machine Scale Sets

If your workload runs on a Virtual Machine Scale Set (VMSS), you can opt in to [Automatic operating system (OS) image upgrades](/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-automatic-upgrade) to roll out new image versions to your scale set without manual intervention.

## Package-based updates

Package-based updates apply package changes to a VM that's already running. You can orchestrate them to follow a safe deployment framework, but doing so requires more coordination than image-based updates.

### Use dnf-automatic

[Install dnf-automatic](/en-us/azure/azure-linux/manage-packages#install-dnf-automatic)

### Use Azure VM guest patching

For a managed alternative, enable [Azure VM guest patching](/en-us/azure/virtual-machines/automatic-vm-guest-patching), which applies package updates following a safe deployment framework managed by Azure.