---
layout: Conceptual
title: Contribute to Azure Linux Documentation | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/contribute-to-docs
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
description: Learn how to contribute to Azure Linux documentation by fixing errors, improving guidance, or adding new content for Azure Linux on Azure scenarios.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: a9d940a4-6272-1e30-1978-9ef9bea99e8c
document_version_independent_id: e0550066-1f1d-35c2-6f4d-f2e509cbad58
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/contribute-to-docs.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/contribute-to-docs
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/contribute-to-docs.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 93e60107-98b8-62ec-145d-35f17648f09a
---

# Contribute to Azure Linux Documentation | Microsoft Learn

This article explains how you can contribute to the Azure Linux documentation by fixing errors, improving guidance, or adding new content that helps users run Azure Linux on Azure and provides guidance for supported Azure Linux scenarios.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## In-scope documentation contributions

The Azure Linux documentation covers **Azure scenarios only**, which is in line with Microsoft's support and lifecycle commitments. We maintain and accept contributions for content that helps people use Azure Linux on Azure, specifically:

- Guidance for Azure Linux Virtual Machines (VM) / Virtual Machine Scale Sets (VMSS), AKS, and container images.
- Customizations built on top of a prebuilt Azure Linux image (for example, with [Image Customizer](customize-images)).

If you see a gap, an error, or an opportunity to improve Azure-focused guidance, please share it with us.

## Out-of-scope documentation contributions

To keep the documentation focused and maintainable, the following types of contributions will be closed:

- **Content for scenarios outside Microsoft's support and lifecycle commitments**, including bare metal, ISO images, on-premises, other clouds, or images built from scratch from the [Azure Linux sources on GitHub](https://github.com/microsoft/azurelinux).
- **Duplicate content** that restates what already exists in another page without adding new value.
- **Promotional or vendor-specific content** that highlights a particular product, tool, or service outside the Azure Linux ecosystem.
- **Speculative or unverified guidance** that hasn't been tested on a supported Azure Linux configuration.
- **Large unsolicited rewrites** submitted without a prior issue and maintainer approval.

## Style and formatting guidelines

Azure Linux documentation follows the [Microsoft Learn documentation style guide](/en-us/contribute/content/style-quick-start). All contributions should align with these standards. Pull requests (PRs) that don't follow these conventions might be sent back for revision before review begins.

## Submit a documentation change

Important

**All documentation contributions require an issue first**. Don't open a PR without an associated issue. PRs without a linked issue might be closed without review.

Steps to submit a documentation change:

1. **Open an issue.** Describe the gap, error, or opportunity for improvement. Be as descriptive as possible; include the Azure service, Azure Linux version, workload type, and any relevant context or reproduction steps. **Wait for a maintainer to acknowledge the issue before starting work**.
2. **Search for duplicates**. Before filing, check existing issues and PRs to avoid duplicating work.
3. **Fork and branch**. Once a maintainer confirms the issue, create a personal fork of the repository and a branch with a descriptive name (for example, `fix/aks-quickstart-typo` or `docs/selinux-recipe`).
4. **Submit a PR**. Link the approved issue in your PR description. Keep your changes concise and task-oriented. Include context such as the Azure service, Azure Linux version, and workload type so reviewers can evaluate your contribution.
5. **Wait for review.** A maintainer will review your PR. Be prepared to make changes if requested. Not all PRs are guaranteed to be merged.

## What to expect after you submit a PR

- **Reviews are best effort**. Maintainers review contributions as capacity allows. Response times can vary and there are no guaranteed service-level agreements (SLAs) on community PRs.
- **Not all contributions will be merged**. PRs might be closed if they fall outside the Azure-supported scope, duplicate existing content, or don't align with the documentation direction.
- **You might be asked to revise**. Reviewers might request changes to scope, accuracy, or formatting before a PR can be approved.
- **Issues might be closed without action**. If an issue is incomplete, out of scope, or has no activity after 30 days, it might be closed.
- **Stale PRs will be closed**. PRs with no activity for 30 days might be closed automatically. You can reopen if you want to continue work on the PR.