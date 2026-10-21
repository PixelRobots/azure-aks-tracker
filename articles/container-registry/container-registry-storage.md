---
layout: Conceptual
title: Container Image Storage in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-storage
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Details on how your container images and other artifacts are stored in Azure Container Registry, including security, redundancy, and capacity.
ms.topic: concept-article
ms.date: 2023-10-31T00:00:00.0000000Z
ms.custom: references_regions
locale: en-us
document_id: a3d99bf5-e7dd-9146-4ba7-a6ce384ac81c
document_version_independent_id: 27f0c8f4-62b8-6458-68b2-f9705e2aac24
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-storage.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-storage
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-storage.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 99df6d32-5c31-f0b7-67b2-d46bf1bf3160
---

# Container Image Storage in Azure Container Registry - Azure Container Registry | Microsoft Learn

Every [Basic, Standard, and Premium](container-registry-skus) Azure container registry benefits from advanced Azure storage features including encryption-at-rest. The following sections describe the features and limits of image storage in Azure Container Registry (ACR).

## Encryption-at-rest

All container images and other artifacts in your registry are encrypted at rest. Azure automatically encrypts an image before storing it, and decrypts it on-the-fly when you or your applications and services pull the image. Optionally apply an extra encryption layer with a [customer-managed key](tutorial-enable-customer-managed-keys).

## Regional storage

Azure Container Registry stores data in the region where the registry is created, to help customers meet data residency and compliance requirements. In all regions except Brazil South and Southeast Asia, Azure may also store registry data in a paired region in the same geography. In the Brazil South and Southeast Asia regions, registry data is always confined to the region, to accommodate data residency requirements for those regions.

If a regional outage occurs, the registry data may become unavailable and is not automatically recovered. Customers who wish to have their registry data stored in multiple regions for better performance across different geographies or who wish to have resiliency in the event of a regional outage should enable [geo-replication](container-registry-geo-replication).

## Geo-replication

For scenarios requiring high-availability assurance, consider using the [geo-replication](container-registry-geo-replication) feature of Premium registries. Geo-replication helps guard against losing access to your registry in the event of a regional failure. Geo-replication provides other benefits, too, like network-close image storage for faster pushes and pulls in distributed development or deployment scenarios.

## Zone redundancy

To help create a resilient and high-availability Azure container registry, [zone redundancy](zone-redundancy) is enabled by default in select Azure regions. Zone redundancy uses Azure [availability zones](/en-us/azure/reliability/availability-zones-overview) to replicate your registry to a minimum of three separate zones in each enabled region.

## Scalable storage

Azure Container Registry allows you to create as many repositories, images, layers, or tags as you need, up to the [registry storage limit](container-registry-skus#sku-features-and-limits).

High numbers of repositories and tags can affect the performance of your registry. Periodically delete unused repositories, tags, and images as part of your registry maintenance routine, and optionally set a [retention policy](container-registry-retention-policy) for untagged manifests. Deleted registry resources such as repositories, images, and tags *cannot* be recovered after deletion. For more information about deleting registry resources, see [Delete container images in Azure Container Registry](container-registry-delete).

## Storage cost

For full details about pricing, see [Azure Container Registry pricing](https://aka.ms/acr/pricing).