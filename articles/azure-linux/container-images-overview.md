---
layout: Conceptual
title: Overview of Azure Linux Container Images | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/container-images-overview
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
description: This article provides an overview of the Azure Linux container images, including standard and distroless images, their use cases, and tagging policy.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-26T00:00:00.0000000Z
locale: en-us
document_id: e2a51fba-ddaa-330d-3a73-7dcb64cbc98e
document_version_independent_id: 736d69e2-bf32-7554-c9ac-93309249886b
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/container-images-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/container-images-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/container-images-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: fb8906ba-52e0-d721-5110-2d2ae259e286
---

# Overview of Azure Linux Container Images | Microsoft Learn

This article provides an overview of the Azure Linux container images, including the standard base images and the distroless images, their intended use cases, and the tagging policy used to manage image versions.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Azure Linux container images

An Azure Linux base container is a minimal container image provided by Microsoft and built on the Azure Linux distribution. It provides a standardized, secure foundation for building custom, partner and golden container images.

```bash
mcr.microsoft.com/azurelinux-beta/base/core:4.0
```

## Azure Linux distroless images

Azure Linux distroless container images are lightweight and provide a minimal attack surface.

Distroless containers contain only the minimal set of packages, with anything extra removed (such as the package manager, libraries, and shell).

Due to their limited set of packages, distroless containers have a minimized security attack surface as well as reduced noise from vulnerability scanners. This generally translates to a reduced overhead of patching vulnerabilities, allowing developers to focus on building their application.

Azure Linux has three distroless images that are intended to support different application types and use cases:

- `minimal`: The smallest distroless image. This image is primarily intended for use with golang or other statically linked applications.

    ```bash
    mcr.microsoft.com/azurelinux-beta/distroless/minimal:4.0
    ```
- `base`: This image is primarily intended for C-based applications.

    ```bash
    mcr.microsoft.com/azurelinux-beta/distroless/base:4.0
    ```
- `debug`: This image adds [busybox](https://busybox.net/about.html) package to the base image and provides a lightweight debugging environment combining minimal versions of many common utilities into a single small executable.

    ```bash
    mcr.microsoft.com/azurelinux-beta/distroless/debug:4.0
    ```

    - To access the debug container and use the busybox utilities included in it, use the following `docker run` command to start a container and launch a shell inside it:

        ```bash
        docker run -it --rm mcr.microsoft.com/azurelinux-beta/distroless/debug:4.0 busybox sh
        ```

## Azure Linux container image tagging policy

The Azure Linux team tags every base container image upload with the `base/core:MajorVersion` and `base/core:FullVersion` tags.

The format of the tags is as follows:

- `Major Version`: X.X, where X.X is the major version number of the release (Example: 4.0).
- `Full Version`: `MajorVersion`.YYYYMMDD, where YYYYMMDD is the date the image was built (Example: 4.0.20260602).

This results in a `base/core:MajorVersion` tag that always represents the latest base container image release for a given major release, and a growing list of `base/core:FullVersion` tags that preserve a tag for each base container image that was pushed. Once a new major version of Azure Linux is released, base container image updates for the prior release continue to be published until the prior release is end of life.