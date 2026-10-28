---
layout: Conceptual
title: Contribute to Azure Linux Code | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/contribute-to-code
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
description: Learn how to contribute to Azure Linux code by submitting pull requests, fixing bugs, or adding new features for Azure Linux on Azure scenarios.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 728a77d7-960b-7945-a07b-187f437f62d0
document_version_independent_id: 8ed2b78c-70ac-3825-dcd9-8f171da2c1d8
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/contribute-to-code.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/contribute-to-code
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/contribute-to-code.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 3ae647a0-c172-e6ec-485a-f15f6885ffd3
---

# Contribute to Azure Linux Code | Microsoft Learn

Azure Linux source repositories are public and follow standard open-source pull request (PR) workflows. This article explains how to contribute to Azure Linux code, including how to submit PRs, fix bugs, and add new features for Azure Linux on Azure scenarios.

Important

Code contributions should target **Azure-supported scenarios**. Microsoft support and lifecycle commitments apply only to:

- Azure Linux Virtual Machines (VM) / Virtual Machine Scale Sets (VMSS), AKS container host, and container images.
- Customizations built on top of a prebuilt Azure Linux image (for example, with [Image Customizer](customize-images)).

Changes specific to bare metal, on-premises, other clouds, or images built from scratch from the [Azure Linux sources on GitHub](https://github.com/microsoft/azurelinux) belong upstream. Consider contributing to the upstream project or the [Fedora Linux Project](https://fedoraproject.org/) instead. For more information, see the [How to contribute to Azure Linux](how-to-contribute).

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Before you begin

**All code contributions require an issue first**. Don't open a PR without a linked, maintainer-approved issue. PRs submitted without prior issue approval might be closed without review.

## Contribution best practices

When contributing code to Azure Linux, follow these best practices to ensure your PR can be reviewed efficiently and merged successfully:

- Follow the [upstream-first model](how-to-contribute). Check whether a change belongs upstream before opening a PR on Azure Linux.
- Open an issue before starting non-trivial work so the team can confirm direction and scope.
- Keep PRs small and focused. One logical change per PR.
    - If you have larger changes to submit, start by filing an issue to discuss the scope and approach before attempting to implement the full change.
- Include tests or validation evidence when adding new behavior or fixing bugs.
- Reference related issues and any upstream submissions in your PR description.
- Submit PRs that make functional changes only. Avoid submitting PRs that only restyle or reformat code without changing behavior.

## Recommended code contribution workflow

To contribute code to Azure Linux:

1. **Create or find an issue** for the work you want to do. **Wait for a maintainer to approve the issue before starting work.** If an existing issue covers your scenario, comment to indicate you'd like to work on it.
2. **Fork the repository** on GitHub.
3. **Create a branch** off of `main` with a descriptive name (for example, `feature/tool-logging`).
4. **Make and commit your changes**. Write clear, concise commit messages.
5. **Test your changes** and make sure builds are clean.
6. **Open a PR** against the `main` branch. Fill in the PR template completely, link related issues, and describe what changed and why.
7. **Respond to any feedback**. Maintainers might request changes, and multiple rounds of revision are common.
8. **Wait for approval**. Once approved, your PR will be merged. There's no guaranteed timeline for this step.

## Contributor License Agreement (CLA)

Most contributions require you to agree to a [Contributor License Agreement (CLA)](https://cla.opensource.microsoft.com) declaring that you have the right to, and actually do, grant us the rights to use your contribution.

When you submit a PR, a CLA bot automatically determines whether you need to provide a CLA and updates the PR accordingly (for example, by adding a status check or comment). If the bot indicates that a CLA is required, follow the instructions it provides to complete the CLA process before your PR can be merged. You only need to do this once across all repos using the Microsoft CLA.

## What to expect during review

- **Reviews are best effort**. Maintainers review contributions as capacity allows. Timelines can vary.
- **Acceptance isn't guaranteed**. Not every PR will be merged. We might suggest a different approach, ask you to submit upstream first, or determine a change is out of scope.
- **We might redirect**. If your change is better suited for an upstream project or Fedora, we'll let you know and help you find the right place.
- **Small PRs move faster**. Focused changes with clear problem statements and reproducible validation are the easiest to review.
- **Stale PRs will be closed**. PRs with no activity for 30 days might be closed automatically. You can reopen if you want to continue work on the PR.