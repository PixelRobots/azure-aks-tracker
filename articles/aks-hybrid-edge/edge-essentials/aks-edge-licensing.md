---
layout: Conceptual
title: AKS Edge Essentials licensing options | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/edge-essentials/aks-edge-licensing
breadcrumb_path: /azure/breadcrumb/azure-aks/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/200/azure-kubernetes-service/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
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
ms.service: azure-kubernetes-service-hybrid
description: Learn about AKS Edge Essentials licensing options.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: overview
ms.date: 2026-09-01T00:00:00.0000000Z
ms.custom: template-overview, edge-essentials
locale: en-us
document_id: 6d3e8a8a-f8e9-8471-f23b-cdf85f8a27fe
document_version_independent_id: 4de0f205-40f4-fbdb-3cba-23550f7b8f3d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/edge-essentials/aks-edge-licensing.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/edge-essentials/aks-edge-licensing
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/edge-essentials/aks-edge-licensing.md
platformId: 6bf59361-5fdc-31e1-18f4-462aae6f1209
---

# AKS Edge Essentials licensing options | Microsoft Learn

AKS Edge Essentials can be licensed for development and test purposes or for commercial use. Review the applicable user terms carefully to understand the rights and obligations provided. AKS Edge Essentials usage for development and test purposes are governed by the [Microsoft Software License Terms](aks-edge-software-license-terms). AKS Edge Essentials can be licensed for commercial use using one of the following options:

- Azure subscription-based model
- Volume licensing model

AKS Edge Essentials is licensed and priced as per device, per month model. Each licensed unit is applied to a device in your cluster.

## Azure subscription-based model

You're entitled to commercially use AKS Edge Essentials, provided you connect your Kubernetes clusters to Azure using Azure Arc. AKS Edge Essentials includes both the agent required to connect to Azure Arc and corresponding PowerShell commands, to easily connect your cluster to Arc.

## Volume licensing based model

The volume licensing model offers a more traditional licensing model for customers who need to deploy AKS Edge Essentials in disconnected scenarios and can't report their usage to Microsoft. You can purchase an annual subscription for all devices in your AKS Edge Essentials cluster, which allows unlimited use of AKS Edge Essentials, on a specified number of devices, without the need to report usage to Azure commerce. The volume licensing model doesn't have integrated billing with Azure. An Azure monetary commitment can't be applied to this model.

The volume licensing model is only available in the Microsoft Enterprise Agreement (EA) and can be ordered via the [Volume Licensing Service Center (VLSC)](https://www.microsoft.com/licensing/servicecenter/default.aspx). Once you purchase the required number of licenses, you receive an email with the details needed to register your cluster. Once you register your cluster with the VL information, you're entitled to use the product for commercial use cases. You are not charged even if you choose to connect your clusters to Azure via Azure Arc.

Caution

Licenses procured via the volume licensing model and EA are subject to terms and conditions stated in the [Microsoft Product Terms](https://www.microsoft.com/licensing/terms/productoffering/MicrosoftAzure/MOSA).

### Third party access for software purchased via hoster's enterprise agreement

Third-party access to solutions built on the volume licensing model procured via EA is granted via the Azure Customer Solution. This means that, if the end customer needs to deploy a disconnected AKS Edge Essentials, a hoster/service provider needing a disconnected scenario is able to use the AKS Edge Essentials volume licensing model purchased with an EA. The volume licensing model doesn't offer the same per-tenant billing and CSP Partner Center integration benefits as the pay-as-you-use model, but it eliminates the need to connect the AKS Edge Essentials clusters to Azure to report usage.

Caution

Microsoft will be a controller of [personal data](https://www.microsoft.com/licensing/terms/product/Glossary/all) processed in connection with your use of AKS Edge Essentials, and Microsoft handles the [personal data](https://www.microsoft.com/licensing/terms/product/Glossary/all) in accordance with the [Microsoft Privacy Statement](https://aka.ms/privacy).