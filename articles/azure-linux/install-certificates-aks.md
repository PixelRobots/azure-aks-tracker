---
layout: Conceptual
title: Install Certificates on Azure Linux Container Host for Azure Kubernetes Service (AKS) | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/install-certificates-aks
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
description: Learn how to add root certificates to the Azure Linux Container Host for AKS to trust additional certificate authorities beyond the minimal Microsoft set.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.custom: linux-related-content
ms.topic: how-to
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 85ad449e-8b3f-1f76-425c-293149853598
document_version_independent_id: 0dfe35c7-bedf-f682-c4f9-3f88f8cb5983
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/install-certificates-aks.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-linux/install-certificates-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/install-certificates-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c2c22c25-c1d1-a34d-f368-810ec7590acc
---

# Install Certificates on Azure Linux Container Host for Azure Kubernetes Service (AKS) | Microsoft Learn

This article explains how to add root certificates to the Azure Linux Container Host for Azure Kubernetes Service (AKS) so that the container host can trust additional certificate authorities beyond the minimal set of Microsoft-owned certificate authorities (CAs) included in the base image.

For more information on the Azure Linux Container Host for AKS image certifications, see the [GitHub documentation](https://github.com/microsoft/azurelinux/blob/3.0/toolkit/docs/security/ca-certificates.md).

## Default certificates and trust

By default, the Azure Linux Container Host for AKS image has a minimal set of root certs to trust certain Microsoft resources, such as `packages.microsoft.com`. All Microsoft certificates aren't automatically included in our image, which is consistent with the least-privilege principle and gives you the flexibility to opt in to just the root certificates you need and to customize your image.

The `ca-certificates-base` is preinstalled in the container host image and contains certificates from a small set of Microsoft-owned CAs. It consists of certificates from Microsoft's root and intermediate CAs. This package allows your container host to trust a minimal set of servers, all of which were verified and had their certificates issued by Microsoft.

The `ca-certificates` cover the root CAs trust by Microsoft through the [Microsoft Trusted Root Program](/en-us/security/trusted-root/participants-list).

The directory `/etc/pki/ca-trust/source/` contains the CA certificates and trust settings in the PEM file format. The trust settings found here are interpreted with a high priority (higher than the ones found in `/usr/share/pki/ca-trust-source/`).

## Add a certificate in the PEM or DER file format

You can add individual or multiple certificates to your Azure Linux Container Host for AKS image. To add a certificate in the simple PEM or DER file format to the list of CAs trusted on the system, follow these steps:

1. Save your certificate under `etc/pki/ca-trust/source/anchors/`.
2. Run `update-ca-trust` to consolidate CA certificates and associated trust.

## Add a certificate in the extended BEGIN TRUSTED file format

If your certificate is in the extended BEGIN TRUSTED file format (which might contain distrust trust flags or trust flags for usages other than TLS), then follow these steps:

1. Save your certificate under `etc/pki/ca-trust/source/`.
2. Run `update-ca-trust` to consolidate CA certificates and associated trust.