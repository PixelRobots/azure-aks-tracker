---
layout: Conceptual
title: What is AKS on Azure Local? | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/aks-local-overview
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
description: Learn about AKS on Azure Local, its core infrastructure components, and the personas involved in deploying and operating it.
ms.topic: overview
ms.date: 2026-09-01T00:00:00.0000000Z
ai-usage: ai-assisted
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: srikantsarwa
ms.lastreviewed: 2026-08-12T00:00:00.0000000Z
ms.custom: local
locale: en-us
document_id: bf49cbf4-8a9a-955e-115c-a67bc774346e
document_version_independent_id: 61872dcf-fec4-853b-9b72-ef8173098e51
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/aks-local-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/local/aks-local-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/aks-local-overview.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/289b8734-3abd-4162-bc19-e661c3f4c940
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/6a94795e-9024-410d-b38e-b67941440893
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: aa84cfd8-84df-33e9-b949-ec94dd48446b
---

# What is AKS on Azure Local? | Microsoft Learn

> 
> Applies to: AKS on Azure Local

AKS on Azure Local creates new Kubernetes clusters on Azure Local directly from Azure. It lets you use familiar tools like the Azure portal, Azure CLI, and Azure Resource Manager templates to create and manage Kubernetes clusters running on Azure Local. Because clusters connect to Azure automatically when you create them, you can use your Microsoft Entra ID to connect to your clusters from anywhere. This way, your developers and app operators can set up and manage Kubernetes clusters according to company policies.

Microsoft focuses on delivering a consistent experience for all your AKS clusters. If you created and managed Kubernetes clusters by using Azure, you feel at home managing Kubernetes clusters running on Azure Local with Azure portal or Azure CLI.

## Simplified AKS component management on Azure Local

AKS on Azure Local includes several infrastructure components that give you Azure experiences, like Arc Resource Bridge, Custom Location, and the Kubernetes extension for the AKS operator. These infrastructure components are now part of Azure Local:

- **Arc Resource Bridge**: The Arc Resource Bridge is created automatically when you deploy Azure Local. This lightweight Kubernetes VM connects your Azure Local to Azure Cloud and enables on-premises resource management from Azure. It provides the line of sight to private clouds required to manage resources such as Kubernetes clusters on-premises through Azure.
- **Custom Location**: Like Arc Resource Bridge, a custom location is created automatically when you deploy Azure Local. A custom location is the on-premises equivalent of an Azure region and extends the Azure location concept. Custom locations let tenant admins use their data center with the right extensions installed as target locations for deploying AKS.
- **Kubernetes extension for AKS operators**: The Kubernetes extension for AKS operators is installed automatically on Arc Resource Bridge when you deploy Azure Local. It's the on-premises equivalent of an Azure Resource Manager resource provider and helps you manage AKS through Azure.

By integrating these components, Azure Local gives you a unified and efficient way to provision and manage Kubernetes, bridging the gap between on-premises and cloud infrastructure.

## Key personas

**Infrastructure administrator**: The infrastructure admin sets up Azure Local, including all the infrastructure component deployments mentioned earlier. The admin also sets up platform configuration, like networking and storage, so Kubernetes operators can create and manage Kubernetes clusters.

**Kubernetes operator**: Kubernetes operators create and manage Kubernetes clusters on Azure Local to run applications without coordinating with infrastructure admins. The admin gives the operator access to the Azure subscription, Azure custom location, and virtual network. The operator doesn't need access to the underlying on-premises infrastructure. After getting the required access, the operator creates Kubernetes clusters based on application needs, like Windows or Linux node pools and Kubernetes versions.