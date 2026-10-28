---
layout: Conceptual
title: Azure Linux Official Support Options | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/support-options
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
description: Learn about the official support options available for Azure Linux running on Azure, including production support, bug reporting, security vulnerability reporting, and community engagement opportunities.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 2e1a90f1-9aa8-7232-2139-70f1ab7dfb62
document_version_independent_id: 86149726-ee8e-a5d1-263d-b92ca1597cd0
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/support-options.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/support-options
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/support-options.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 0c8ff20a-d7fe-7fb8-e8ac-aa033c48e1f3
---

# Azure Linux Official Support Options | Microsoft Learn

Azure Linux provides official support for customers running workloads on Azure in supported scenarios. This includes support for virtual machines (VMs), virtual machine scale sets (VMSS), Azure Kubernetes Service (AKS) container hosts, and Azure Linux container images.

This article outlines the official support options available for Azure Linux, including how to get production support, report bugs and documentation issues, report security vulnerabilities, and engage with the community through office hours and community calls.

Important

Azure Linux is open source, but Microsoft support and lifecycle commitments apply only to **Azure scenarios**. Specifically:

- Azure Linux Virtual Machines (VM) / Virtual Machine Scale Sets (VMSS), AKS container host, and container images are supported.
- Bare metal, ISO images, on-premises, and other clouds aren't supported.
- Customized images are supported only when built on top of a prebuilt Azure Linux image (for example, with [Image Customizer](customize-images)). Images built from scratch from the [Azure Linux sources on GitHub](https://github.com/microsoft/azurelinux) aren't covered.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Production support

Azure Support is for **production issues only**. If you're running an Azure Linux production workload on Azure and you hit an outage, regression, or configuration problem that's affecting that workload, [open an Azure support request](/en-us/azure/azure-portal/supportability/how-to-create-azure-support-request) through the Azure portal.

Use Azure Support for production issues such as:

- Package management and repository issues affecting a running workload.
- System configuration and lifecycle management on production hosts.
- Security baseline guidance for a deployed environment.
- Image and deployment troubleshooting in production.

For bugs, documentation problems, feature requests, and general questions, use GitHub instead. See Bugs, docs, and feature requests. GitHub issues aren't monitored for production support.

## Bugs, docs, and feature requests

For bug reports, documentation improvements, and feature requests, see [Report issues and request features for Azure Linux](report-issues-request-features). All issues require a GitHub issue filed in the correct repository.

## Security vulnerabilities

**Please don't report security vulnerabilities through public GitHub issues**. Follow the guidance under [Manage CVEs](manage-cves#report-a-security-issue).

## Join our Azure Linux community calls

Azure Linux team hosts monthly community calls where you can get help from our product and support teams.

The Azure Linux community calls are for Azure Linux users to get together and discuss new features, provide feedback, and learn more about how others use Azure Linux. In each session, we feature a new demo.

The schedule for the upcoming community calls is as follows:

| Date | Time | Meeting link |
| --- | --- | --- |
| 5/28/2026 | 8-9 AM PST | [Click to join](https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZDcyZjRkYWMtOWQxYS00OTk3LWFhNmMtMTMwY2VhMTA4OTZi%40thread.v2/0?context=%7b%22Tid%22%3a%2272f988bf-86f1-41af-91ab-2d7cd011db47%22%2c%22Oid%22%3a%2271a6ce92-58a5-4ea0-96f4-bd4a0401370a%22%7d). |
| 7/23/2026 | 8-9 AM PST | [Click to join](https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZDcyZjRkYWMtOWQxYS00OTk3LWFhNmMtMTMwY2VhMTA4OTZi%40thread.v2/0?context=%7b%22Tid%22%3a%2272f988bf-86f1-41af-91ab-2d7cd011db47%22%2c%22Oid%22%3a%2271a6ce92-58a5-4ea0-96f4-bd4a0401370a%22%7d). |
| 9/24/2026 | 8-9 AM PST | [Click to join](https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZDcyZjRkYWMtOWQxYS00OTk3LWFhNmMtMTMwY2VhMTA4OTZi%40thread.v2/0?context=%7b%22Tid%22%3a%2272f988bf-86f1-41af-91ab-2d7cd011db47%22%2c%22Oid%22%3a%2271a6ce92-58a5-4ea0-96f4-bd4a0401370a%22%7d). |
| 11/19/2026 | 8-9 AM PST | [Click to join](https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZDcyZjRkYWMtOWQxYS00OTk3LWFhNmMtMTMwY2VhMTA4OTZi%40thread.v2/0?context=%7b%22Tid%22%3a%2272f988bf-86f1-41af-91ab-2d7cd011db47%22%2c%22Oid%22%3a%2271a6ce92-58a5-4ea0-96f4-bd4a0401370a%22%7d). |
| 1/28/2027 | 8-9 AM PST | [Click to join](https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZDcyZjRkYWMtOWQxYS00OTk3LWFhNmMtMTMwY2VhMTA4OTZi%40thread.v2/0?context=%7b%22Tid%22%3a%2272f988bf-86f1-41af-91ab-2d7cd011db47%22%2c%22Oid%22%3a%2271a6ce92-58a5-4ea0-96f4-bd4a0401370a%22%7d). |
| 3/25/2027 | 8-9 AM PST | [Click to join](https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZDcyZjRkYWMtOWQxYS00OTk3LWFhNmMtMTMwY2VhMTA4OTZi%40thread.v2/0?context=%7b%22Tid%22%3a%2272f988bf-86f1-41af-91ab-2d7cd011db47%22%2c%22Oid%22%3a%2271a6ce92-58a5-4ea0-96f4-bd4a0401370a%22%7d). |

## Stay up-to-date

Azure Linux publishes a [feature roadmap](https://github.com/orgs/microsoft/projects/970/views/2) that contains features that are in development and available for general availability (GA) and preview. We review this roadmap in each community call to highlight upcoming features and changes. We welcome you to leave feedback or ask questions on feature items.

## Attributions

The Azure Linux penguin icon is inspired by the Linux mascot ("Tux"), created by Larry Ewing.