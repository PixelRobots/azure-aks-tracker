---
layout: Conceptual
title: Install Debug Symbol Packages on Azure Linux | Microsoft Learn
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
description: Learn how to install debug symbol (`debuginfo`) packages on Azure Linux by enabling the dedicated `debuginfo` repository and using DNF to install the corresponding symbol packages for installed binaries.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: how-to
ms.date: 2026-04-27T00:00:00.0000000Z
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

# Install Debug Symbol Packages on Azure Linux | Microsoft Learn

Debug symbol (`debuginfo`) RPMs contain the symbol tables that debuggers and profilers, such as `gdb`, use to resolve addresses to function names and source lines. Azure Linux publishes a `debuginfo` package alongside most binary packages, but the `debuginfo` repository isn't enabled by default. This avoids pulling large symbol packages onto production systems unless you explicitly opt in.

This article explains where Azure Linux publishes `debuginfo` packages, how to enable the `debuginfo` repository, and how to install symbol packages on a system that needs them.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Prerequisites

- An Azure Linux system that you can authenticate to with shell access.
- A user account with `sudo` privileges, which is required to write `.repo` files under `/etc/yum.repos.d/` and to install packages.

## Where Azure Linux publishes `debuginfo` packages

Azure Linux publishes `debuginfo` RPMs to [packages.microsoft.com](https://packages.microsoft.com/) (PMC) in a dedicated location, organized by release version, release stage, and architecture. For Azure Linux 4.0, the layout is:

```text
https://packages.microsoft.com/azurelinux/4.0/<STAGE>/base/debuginfo/<ARCH>/
```

- **`<STAGE>`** is `beta` for packages in Azure Linux preview.
- **`<ARCH>`** is the target architecture, such as `x86_64` or `aarch64`.

The version, stage, and architecture must match the system the symbols will be loaded on. Mismatched `debuginfo` packages don't resolve symbols correctly.

## Enable the `debuginfo` repository

1. Install the config-manager plugin using the following command:

    ```bash
    sudo dnf install 'dnf5-command(config-manager)'
    ```
2. To install `debuginfo` packages, configure DNF to read from the Azure Linux `debuginfo` repository for your release and architecture:

    ```bash
    sudo dnf config-manager setopt azurelinux-base-debuginfo.enabled=1
    ```
3. Confirm that the `debuginfo` repository is enabled using the following command:

    ```bash
    dnf repolist
    ```

    The output should list the new `debuginfo` repository alongside the default Azure Linux repositories.

## Install a debug symbol package

After the `debuginfo` repository is enabled, install symbol packages with `dnf install`. Debug symbol packages share the binary package's name and add a `-debuginfo` suffix. For example, to install symbols for `glibc`, run:

```bash
sudo dnf install glibc-debuginfo
```

To install symbols for several packages at once, list each `-debuginfo` package on the command line. For example:

```bash
sudo dnf install glibc-debuginfo openssl-debuginfo
```

After installation, debuggers and profilers automatically pick up the new symbols from `/usr/lib/debug/`.

Tip

Match the `debuginfo` package version to the binary package version that's installed on the system. Mismatched versions cause the debugger to fall back to address-only stack traces. Run `dnf info <package>-debuginfo` to confirm the available version before you install.