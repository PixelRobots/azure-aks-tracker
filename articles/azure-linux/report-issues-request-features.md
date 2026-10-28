---
layout: Conceptual
title: Report Issues and Request Features for Azure Linux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/report-issues-request-features
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
description: Learn how to report bugs, documentation issues, and security vulnerabilities and make feature requests for Azure Linux.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: how-to
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: e8ec4a46-4000-23a4-70cf-6a8635733636
document_version_independent_id: 6f08a9d7-d85a-75df-2c2e-d549773402d3
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/report-issues-request-features.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/report-issues-request-features
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/report-issues-request-features.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: bf336f63-bf85-1b09-6887-c509411a2226
---

# Report Issues and Request Features for Azure Linux | Microsoft Learn

This article explains how to report bugs, documentation issues, and security vulnerabilities, and how to request new features for Azure Linux. Following the guidance here ensures that your issues and requests are routed to the correct channels and can be addressed efficiently.

Important

Azure Linux is open source, but Microsoft support and lifecycle commitments apply only to **Azure scenarios**. Specifically:

- Azure Linux Virtual Machines (VM) / Virtual Machine Scale Sets, AKS container host, and container images are supported.
- Bare metal, ISO images, on-premises, and other clouds aren't supported.
- Customized images are supported only when built on top of a prebuilt Azure Linux image (for example, with [Image Customizer](customize-images)). Images built from scratch from the [Azure Linux sources on GitHub](https://github.com/microsoft/azurelinux) aren't covered.

Issues outside this scope might be closed.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Before you file

- **Search existing issues** to see if the problem has already been reported. If you find an existing issue that matches your scenario, add a thumbs up (👍) reaction and include any extra context in a comment. This helps us prioritize without creating duplicates.
- **Check the latest Azure Linux image and patches** to see if the issue has already been fixed in a newer release before filing a new issue.

## Where to file

| Issue / request type | Where to file |
| --- | --- |
| Production issues or outages | If you're experiencing a technical issue affecting your Azure workload, [open an Azure support request](/en-us/azure/azure-portal/supportability/how-to-create-azure-support-request) through the Azure portal. GitHub issues aren't monitored for production support. |
| Bug reports, documentation issues, feature requests | GitHub issues using the appropriate issue template in the [correct repository](how-to-contribute#choose-the-correct-repository-for-your-contribution). |
| Security vulnerabilities | Follow the guidance under [Manage CVEs](manage-cves#report-a-security-issue). **Please don't report security vulnerabilities through public GitHub issues**. |

## How to write a good bug report

Important

When you open a bug report on GitHub, a pre-filled issue template will guide you through these fields. Use the template to provide all the requested information. Please fill it out completely. Incomplete reports might be closed.

The smaller and more self-contained your reproduction case is, the faster it can be triaged. Try to isolate the issue from unrelated configuration or dependencies.

A good bug report helps maintainers reproduce and fix the problem faster. In your report, please include the following information:

- **Azure Linux version and image name**: For example, `AzureLinux 4.0 AKS node image 2026.05`.
- **Steps to reproduce**: Numbered, specific steps that someone else can follow.
- **Expected behavior** vs. **actual behavior**.
- **Logs**: Relevant system or application logs that show the error or unexpected behavior.
- **Environment details**: Azure service (AKS, VM, Virtual Machine Scale Sets, etc.), VM size/SKU, region, networking configuration, and any custom image or package modifications.
- **Screenshots or terminal output** where helpful (paste text, not images of text).

## Exclusions from triage

To keep triage manageable, the following types of issues will be closed:

- **Issues for scenarios outside Microsoft support and lifecycle commitments**, including:
    - Bare metal, ISO images, on-premises, and other clouds.
    - Images built from scratch from the [Azure Linux sources on GitHub](https://github.com/microsoft/azurelinux) (only customizations on top of a prebuilt Azure Linux image, for example with [Image Customizer](customize-images), are covered).
- **Incomplete reports** that are missing reproduction steps, version info, or environment details.
- **Duplicate issues**: Add a thumbs up (👍) on the existing issue instead.
- **Feature requests without a clear Azure use case** or business justification.
- **Production-related questions that belong in an official support channel**: Review the guidance in [Azure Linux official support options](support-options) for the appropriate way to get help with production issues.

## What happens after you file

- **Triage is best effort**. Maintainers triage issues as capacity allows. There are no guaranteed SLAs on community-filed issues.
- Issues might be **labeled** for tracking (for example, `bug`, `docs`, `upstream`, `help-wanted`).
- Issues might be **redirected** to an upstream project or Fedora when that's the correct ownership path.
- Issues that are out of scope, missing key details, or not actionable might be **closed without an explanation**.
- We **prioritize issues** that affect Azure Linux usage on Azure and include reproducible detail.
- Issues with **no activity for 30 days** might be closed automatically.