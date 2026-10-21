---
layout: Conceptual
title: Scaling and Zone-redundant Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/scaling-zone-resiliency
breadcrumb_path: /azure/bread/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/148/azure-application-gateway/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/8ae9bf04-8326-ec11-b6e6-000d3a4f0789?c=8d429912-8326-ec11-b6e6-000d3a4f0789
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
adobe-target: true
learn_banner_products:
- azure
manager: kumud
ms.reviewer: mbender
description: This article defines Application Gateway for Containers Autoscaling and Zone-redundant features.
services: application-gateway
author: mbender-ms
ms.custom: references_regions
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2026-03-12T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: cde43239-d30a-d598-2b77-c122204981de
document_version_independent_id: 5a0075b1-0f86-e4a4-db43-07be1b64a999
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/scaling-zone-resiliency.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/scaling-zone-resiliency
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/scaling-zone-resiliency.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 4fc49272-877b-4f88-54a2-6d40ca8cc563
---

# Scaling and Zone-redundant Application Gateway for Containers | Microsoft Learn

Application Gateway for Containers is configured with autoscaling in a high availability configuration in all cases. The gateway scales in or out based on application traffic. This offers better elasticity to your application and eliminates the need to guess capacity or manually manage instance counts. Autoscaling also maximizes cost savings by not requiring the gateway to constantly run at peak-provisioned capacity for the expected maximum traffic load.

## Autoscaling and high availability

Azure Application Gateway for Containers is always deployed in a highly available configuration. The service takes advantage of [availability zones](/en-us/azure/reliability/availability-zones-overview) if the region supports availability zones. If the region does not support zones, Application Gateway for Containers leverages availability sets to ensure resiliency. In the event the Application Gateway for Containers service has an underlying problem and becomes degraded, the service is designed to self-recover.

- During scale in and out events, operation and configuration updates continue to be applied.
- During scale-out events, introduction of additional capacity can take up to five minutes.
- During scale-in events, Application Gateway for containers drains existing connections for five minutes on the capacity that is subject to removal. After five minutes, the existing connections are closed, and the capacity is removed. Any new connections during or after the five-minute scale in time are established to the remaining capacity on the same gateway.

## Maintenance

Updates initiated to Application Gateway for Containers are applied one update domain at a time to eliminate downtime. During maintenance, operation and configuration updates continue to be applied. Active connections are gracefully drained for up to 5 minutes, establishing new connections to the remaining capacity in a different update domain prior to the update beginning. The update process proceeds through each update domain, only proceeding to the next update domain once a healthy status is returned.