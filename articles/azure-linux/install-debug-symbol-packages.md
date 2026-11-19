---
layout: Conceptual
title: Install debug symbol packages on Azure Linux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/install-debug-symbol-packages
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
description: Learn how to enable the production base debug symbol repository on Azure Linux 4.0 and use DNF5 to install symbol packages that match your installed binaries.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: how-to
ms.date: 2026-10-12T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: f546b39d-b229-3bbe-7362-c1218257d3dc
document_version_independent_id: 1ef2b630-b677-b0af-9db4-b80ed52731a3
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/install-debug-symbol-packages.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/install-debug-symbol-packages
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/install-debug-symbol-packages.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: fe909a1d-5b4b-a220-31ae-9c7f50ed8328
---

# Install debug symbol packages on Azure Linux | Microsoft Learn

Debug symbol (`debuginfo`) RPMs contain debugging information that tools such as `gdb` use to resolve addresses to function names and source lines. Azure Linux publishes these packages in separate repositories. The production `base` debug symbol repository isn't enabled by default. Enable it when you need symbols for troubleshooting.

This article explains where Azure Linux 4 publishes `debuginfo` packages, how to enable the production `base` debug symbol repository, and how to install symbols that match your installed packages.

## Prerequisites

- An Azure Linux system with shell access, DNF5, and the Azure Linux repository configuration.
- A user account with `sudo` privileges to change repository settings and install packages.
- Access to `packages.microsoft.com` to download repository metadata and packages.

## Where Azure Linux publishes `debuginfo` packages

Azure Linux publishes `debuginfo` RPMs to [packages.microsoft.com](https://packages.microsoft.com/) (PMC), organized by major release, package channel, repository, and architecture. For Azure Linux 4 distribution packages in `base`, the layout is:

```text
https://packages.microsoft.com/azurelinux/4/<STAGE>/base/debuginfo/<ARCH>/
```

- `<STAGE>` is `prod` for production packages or `preview` for packages in the public testing channel. Use symbols from the channel that supplied the binary package. Don't enable preview repositories to obtain symbols for production packages.
- `<ARCH>` is the package architecture, such as `x86_64` or `aarch64`.

For example, production symbols for `base` packages on x86-64 systems are published at:

```text
https://packages.microsoft.com/azurelinux/<AZURE_LINUX_VERSION>/prod/base/debuginfo/x86_64/
```

Azure Linux 4.0 and later 4.x image versions share the `azurelinux/4` namespace. Symbols must match the binary's exact build, including its package epoch, version, release, and architecture. Matching only the major Azure Linux release isn't sufficient.

## Enable the `debuginfo` repository

On Azure Linux 4.0, `dnf` invokes DNF5. Use the following steps for packages from the production `base` repository.

1. Check that the repository is configured, even if it's disabled:

    ```bash
    dnf repo list --all
    dnf repo info --all azurelinux-base azurelinux-base-debuginfo
    ```

    Confirm that `azurelinux-base` points to `/azurelinux/4/prod/base/` and `azurelinux-base-debuginfo` points to `/azurelinux/4/prod/base/debuginfo/` for your architecture. If either repository is missing or points to another channel, stop and verify your image's repository configuration before continuing. Enabling a repository doesn't create a missing definition or change its base URL.
2. Install the config-manager plugin:

    ```bash
    sudo dnf install 'dnf5-command(config-manager)'
    ```
3. Enable the production `base` debug symbol repository:

    ```bash
    sudo dnf config-manager setopt azurelinux-base-debuginfo.enabled=1
    ```
4. Confirm that the production `base` and debug symbol repositories are enabled:

    ```bash
    dnf repo info --all azurelinux-base azurelinux-base-debuginfo
    ```

    Check the enabled/disabled status in the output. Both `azurelinux-base` and `azurelinux-base-debuginfo` should be enabled.

## Install a debug symbol package

Debug symbol package names commonly end in `-debuginfo`, such as `glibc-debuginfo` and `openssl-debuginfo`. A symbol package can cover multiple binary subpackages from the same source package, so don't assume that every installed package has a symbol package with the same name.

The following example installs symbols for the installed `glibc` package.

1. Check the installed binary package:

    ```bash
    dnf info --installed glibc
    ```

    Record its epoch, version, release, and architecture.
2. Refresh the debug symbol repository metadata and list all available versions, not just the latest:

    ```bash
    dnf --refresh --repo=azurelinux-base-debuginfo info --available --showduplicates glibc-debuginfo
    ```

    Find the symbol package that matches the installed binary's epoch, version, release, and architecture.

    The `debuginfo` package must match the installed binary package so that debugging tools, such as `crash` and `gdb`, can correctly map crash data to functions, variables, and source code.
3. Install that exact symbol package:

    ```bash
    sudo dnf --repo=azurelinux-base,azurelinux-base-debuginfo install 'glibc-debuginfo-<EPOCH>:<VERSION>-<RELEASE>.<ARCH>'
    ```

    Replace the placeholders with the matching values. If the package has no epoch, omit `<EPOCH>:`. The `--repo` option limits this transaction to the production `base` and `base` debug symbol repositories. Review the proposed transaction before confirming it.

    To install symbols for several packages, add each exact symbol package identifier to the command. Match each one to its corresponding binary package rather than assuming they share a version.
4. Confirm the installed symbol package:

    ```bash
    dnf info --installed glibc-debuginfo
    ```

Debug symbol packages install separate debug files under `/usr/lib/debug/`. GDB can load matching separate debug files automatically. Other debuggers and profilers might require their own symbol-path configuration.

Important

If the exact matching symbols aren't available, don't substitute symbols from another version, architecture, or channel. Verify the binary's source repository and the symbol package name. For a core dump or copied executable, match the symbols to the binary that produced it, not necessarily the package currently installed on your troubleshooting system.

## Disable the debug symbol repository

If you no longer need the repository enabled, disable it:

```bash
sudo dnf config-manager setopt azurelinux-base-debuginfo.enabled=0
```

Disabling the repository doesn't uninstall symbol packages that are already installed.