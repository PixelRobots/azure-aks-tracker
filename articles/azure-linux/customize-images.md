---
layout: Conceptual
title: Customize Azure Linux images with Image Customizer | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/customize-images
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
description: Learn how to use Image Customizer to modify Azure Linux images for your specific scenarios, including adding packages, configuring users, and applying custom system settings without booting a VM.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: how-to
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 9031aae3-b3c4-6dbb-be56-5382659de7cb
document_version_independent_id: 6f56ff8c-8e69-c63c-a4b8-880d0ce1ecf9
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/customize-images.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/customize-images
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/customize-images.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 7fc2bdfb-4d4d-bb0f-0373-cb90eaa2ecf5
---

# Customize Azure Linux images with Image Customizer | Microsoft Learn

Image Customizer is an open-source tool that modifies existing Azure Linux images to suit your specific scenario. It uses `chroot` and loopback block devices to perform customizations without booting a virtual machine (VM), making the process fast, reliable, and easy to integrate into CI/CD workflows. This is the same technology used to build the official Azure Linux images. For the full configuration reference and advanced usage, see the [Image Customizer documentation](https://microsoft.github.io/azure-linux-image-tools/imagecustomizer/README.html).

Note

Azure Image Builder (AIB) integration with Image Customizer isn't yet available. For now, you can use Image Customizer directly to customize Azure Linux images.

With Image Customizer, you can:

- Add or remove packages.
- Add files or directories.
- Configure users and system settings.
- Apply custom partition layouts.
- Produce output images in multiple formats.

Image Customizer also supports nested customization, so you can further customize an already-customized image. For teams that build multiple images, consider creating a shared custom base image first to reduce maintenance overhead.

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Prerequisites

- **Docker** installed on your host.
- **A base image**: Any Azure Linux image (from the Azure Marketplace or one you already maintain).
- **A configuration file**: A YAML or JSON file that describes your modifications.

## Supported host systems

You can run Image Customizer on:

- Azure Linux
- Ubuntu 22.04

## Use Image Customizer

Image Customizer runs as a container published to the [Microsoft Artifact Registry (MCR)](https://mcr.microsoft.com/azurelinux/imagecustomizer).

### List available tags

List available tags for the Image Customizer container with the following command:

```bash
curl -s "https://mcr.microsoft.com/v2/azurelinux/imagecustomizer/tags/list" | jq '.tags[]'
```

### Customize an image

Customize an image by running the Image Customizer container with your base image and configuration file mounted into the container. For example:

```bash
docker run --rm \
    --privileged \
    -v "<shared-dir>:z" \
    -v "/dev:/dev" \
    "mcr.microsoft.com/azurelinux/imagecustomizer:latest" \
    imagecustomizer \
        --image-file <base-image.vhdx> \
        --config-file <config-file.yaml> \
        --output-image-format raw \
        --output-image-file <output-image.raw> \
        --build-dir "/tmp"
```

Replace the following values:

| Placeholders | Description |
| --- | --- |
| `<shared-dir>` | Absolute path to the directory containing your base image and configuration file. The customized image is also written here. |
| `<base-image.vhdx>` | Path to the base image file to modify. |
| `<config-file.yaml>` | Path to the configuration file that describes your modifications. |
| `<output-image.raw>` | Path for the customized output image. |