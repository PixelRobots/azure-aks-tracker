---
layout: Conceptual
title: Create and Manage Kubernetes resources in the Azure portal with Kubernetes Center (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kubernetes-center-azure-portal
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
adobe-target: true
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to create and manage your Kubernetes resources directly in the Azure portal using Kubernetes Center (preview), which centralizes creation, management, and monitoring of your Kubernetes clusters.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.date: 2025-11-04T00:00:00.0000000Z
locale: en-us
document_id: 95422fa6-722d-4040-4bfc-2267d0347bac
document_version_independent_id: e337a85e-8d4e-2de0-e335-226315f8835a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kubernetes-center-azure-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/kubernetes-center-azure-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kubernetes-center-azure-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/970f20f1-2f12-4aa9-9c95-c00fe1f5e722
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/432c4950-b799-4ed5-93d5-b9b2934edf7d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 4c206b73-a267-9519-7088-783e861b2e83
---

# Create and Manage Kubernetes resources in the Azure portal with Kubernetes Center (preview) - Azure Kubernetes Service | Microsoft Learn

Kubernetes Center (preview) in the Azure portal centralizes and simplifies AKS resource creation and management. This feature provides a unified experience across all your AKS resources and delivers intelligent insights and streamlined workflows, allowing platform teams to maintain control while enabling developers to move quickly and confidently.

This article shows you how to get started with Kubernetes Center (preview) in the Azure portal, including how to access it, explore its features, and leverage its capabilities to enhance your Kubernetes management experience.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Key benefits of Kubernetes Center (preview)

Kubernetes Center (preview) offers several key benefits, including:

- **Actionable insights**: Identify security vulnerabilities, cluster alerts, and compliance gaps in one place.
- **Streamlined management**: Use a unified interface that integrates [AKS](what-is-aks), [AKS Automatic](intro-aks-automatic), [Azure Kubernetes Fleet Manager](/en-us/azure/kubernetes-fleet/overview), and [managed namespaces](managed-namespaces).
- **Centralized learning and support**: Access relevant documentation, quickstarts, and in-context help.

## Prerequisites

To use Kubernetes Center (preview), ensure you have the following prerequisites:

- An active Azure subscription. If you don't have one, you can [create a free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).

## Access quickstarts and documentation

1. From the [Azure portal](https://portal.azure.com/) home page, search for and select **Kubernetes center**.
2. On the **Overview** page, select **Browse quickstarts**.

    [![Screenshot showing the Browse quickstarts option on the Overview page of the Kubernetes center in the Azure portal.](media/kubernetes-center-azure-portal/kubernetes-center-browse-quickstarts.png)](media/kubernetes-center-azure-portal/kubernetes-center-browse-quickstarts.png#lightbox)
3. On the **Kubernetes center | Quickstarts** page, browse the available quickstarts and select one to view detailed instructions and documentation.

    [![Screenshot showing the Quickstarts page in the Kubernetes center of the Azure portal.](media/kubernetes-center-azure-portal/kubernetes-center-quickstarts-page.png)](media/kubernetes-center-azure-portal/kubernetes-center-quickstarts-page.png#lightbox)

## Create resources

1. From the [Azure portal](https://portal.azure.com/) home page, search for and select **Kubernetes center**.
2. On the **Overview** page, select **Create**.

    [![Screenshot showing the Create option on the Overview page of the Kubernetes center in the Azure portal.](media/kubernetes-center-azure-portal/kubernetes-center-create.png)](media/kubernetes-center-azure-portal/kubernetes-center-create.png#lightbox)
3. Select the type of resource you want to create from the available options:

    - AKS Cluster
    - AKS Automatic Cluster
    - Managed Kubernetes Namespace
    - Kubernetes Fleet Manager
    - Deploy your application

    [![Screenshot showing the available resource options in the Kubernetes center of the Azure portal.](media/kubernetes-center-azure-portal/kubernetes-center-resources.png)](media/kubernetes-center-azure-portal/kubernetes-center-resources.png#lightbox)
4. Follow the prompts to configure your resource.
5. Select **Review + create** to proceed with the creation.

## Manage clusters and workloads

The **Overview** page provides cluster health and workload performance details, along with security alerts and upgrade recommendations.

[![Screenshot showing the Overview page of the Kubernetes center in the Azure portal.](media/kubernetes-center-azure-portal/kubernetes-center-overview-page.png)](media/kubernetes-center-azure-portal/kubernetes-center-overview-page.png#lightbox)