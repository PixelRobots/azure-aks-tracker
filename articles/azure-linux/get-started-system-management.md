---
layout: Conceptual
title: Get Started with Azure Linux System Management | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/get-started-system-management
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
description: Get started with the core system management tasks for Azure Linux, including kernel configuration, network setup, storage management, logging and monitoring, and package management.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: get-started
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 6a4abe18-5336-5c93-72b2-3cc37556a200
document_version_independent_id: 159a88aa-068b-2778-20ff-01b4fadebf2f
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/get-started-system-management.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/get-started-system-management
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/get-started-system-management.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 365350fe-d41f-e33b-14b6-1be31387d1ce
---

# Get Started with Azure Linux System Management | Microsoft Learn

This article provides an overview of the core operational tasks for running and maintaining Azure Linux deployments, including kernel configuration, network setup, package updates, storage management, and system monitoring. It also points to the detailed guidance in each area, which you can use to effectively configure and manage your Azure Linux environment.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Core system management topics

| Topic | Description |
| --- | --- |
| [Kernel](kernel-management) | Kernel selection, configuration, boot parameters, and LTS/HWE kernel tracks to match your hardware and workload needs |
| [Network configuration](configure-networking) | Managing network interfaces, DHCP, static IPs, and advanced features such as VLANs, bridges, and bonded interfaces with systemd-networkd |
| [Storage and filesystems](storage-file-system-management) | Disk management, partition configuration, filesystem selection, and mount options for Azure Linux deployments |
| [Logging and monitoring](logging-monitoring) | System logging with journald, Azure Monitor integration, and monitoring tools for visibility and troubleshooting |
| [Package management](package-management-overview) | DNF5 package manager, repository configuration, RPM packages, and dependency resolution for keeping your system current and secure |