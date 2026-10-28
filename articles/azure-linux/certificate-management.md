---
layout: Conceptual
title: Certificate Management in Azure Linux | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/certificate-management
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
description: This article explains how Azure Linux handles trusted root certificates and how to add custom certificates to regular Azure Linux images and distroless container images.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: overview
ms.date: 2026-04-27T00:00:00.0000000Z
locale: en-us
document_id: 843adf43-f7be-34f9-9d0c-c3062ab07301
document_version_independent_id: 33982bd9-5f84-c3d7-8c12-b247d8b88f53
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/certificate-management.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/certificate-management
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/certificate-management.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 8c029bcf-d21c-8704-abf7-5b58248ccc8c
---

# Certificate Management in Azure Linux | Microsoft Learn

This article explains how Azure Linux handles trusted root certificates and how to add custom certificates to regular Azure Linux images and distroless container images.

Azure Linux 4.0 uses Fedora's `ca-certificates` package. Fedora maintains and distributes the package, and the certificate bundle is sourced from [Mozilla's set of trusted CAs](https://wiki.mozilla.org/CA/Included_Certificates).

Note

Azure Linux 4.0 is now in **preview** and is strictly limited to evaluation and testing purposes. It's not suitable for production use.

## Certificate storage and management

Azure Linux stores and manages certificates by using the shared trust store approach described in [Fedora's Shared System Certificates](https://docs.fedoraproject.org/en-US/quick-docs/using-shared-system-certificates/).

## Available certificate bundles

In Azure Linux 4.0 regular images, `ca-certificates` is preinstalled and provides the standard certificate bundle. This package comes from Fedora and distributes the Mozilla-managed certificate set.

For more information, see [Fedora ca-certificates package](https://packages.fedoraproject.org/pkgs/ca-certificates/ca-certificates/).

## Install a certificate

To install a certificate in a regular image, follow the process described in [Fedora's Shared System Certificates](https://docs.fedoraproject.org/en-US/quick-docs/using-shared-system-certificates/).