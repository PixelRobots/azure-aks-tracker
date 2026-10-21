---
layout: Conceptual
title: Understand Azure Kubernetes Service (AKS) usage and costs - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/understand-aks-costs
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
description: Understand Azure Kubernetes Service (AKS) usage and costs, including allocation, monitoring, analytics, and anomaly management.
author: schaffererin
ms.author: schaffererin
ms.custom: aks-cost
ms.topic: how-to
ms.date: 2025-01-30T00:00:00.0000000Z
locale: en-us
document_id: 510bee3b-4206-642f-7527-6d1516169052
document_version_independent_id: 835ff580-5b16-e410-3835-d1ec9a2f9293
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/understand-aks-costs.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/understand-aks-costs
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/understand-aks-costs.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 77652bbd-867b-0f38-e1d3-fed45dff424f
---

# Understand Azure Kubernetes Service (AKS) usage and costs - Azure Kubernetes Service | Microsoft Learn

This article provides resources you can use to better understand your Azure Kubernetes Service (AKS) usage and costs and identify cost optimization opportunities.

## About cost analysis

[Microsoft Cost Management](/en-us/azure/cost-management-billing/costs/reporting-get-started) is a suite of FinOps tools that help you analyze, monitor, and optimize your cloud costs. It's available for Azure customers with access to a billing account, subscription, resource group, or management group. For more information, see [What is Microsoft Cost Management?](/en-us/azure/cost-management-billing/costs/overview-cost-management)

[Cost analysis](/en-us/azure/cost-management-billing/costs/reporting-get-started#cost-analysis) is a feature of Cost Management that helps you understand your costs and usage. It provides insights into how your resources are being used and helps you identify opportunities to reduce costs. For more information, see [Start analyzing costs in Azure](/en-us/azure/cost-management-billing/costs/quick-acm-cost-analysis).

## Cost analysis resources

### Cost analysis add-on for AKS

The cost analysis add-on for AKS allows you to view comprehensive cost data scoped to Kubernetes constructs, such as clusters and namespaces, and Azure Compute, Network, and Storage resources. Enable it on your AKS cluster by following the steps in [Enable the Azure Kubernetes Service (AKS) cost analysis add-on](cost-analysis). To learn more about viewing the cost data, see [View Kubernetes costs](/en-us/azure/cost-management-billing/costs/view-kubernetes-costs).

### Azure Cost Optimization workbook

The [Azure Cost Optimization workbook](/en-us/azure/advisor/advisor-workbook-cost-optimization) provides a comprehensive view of your Azure costs and recommendations for optimizing them. For more information, see [Cost Optimization workbook](/en-us/azure/advisor/advisor-workbook-cost-optimization).

### Azure Orphaned Resources workbook

The [Azure Orphaned Resources workbook](https://github.com/dolevshor/azure-orphan-resources) helps you identify and manage unused resources in your Azure environment. For more information, see [Orphaned Resources workbook](https://techcommunity.microsoft.com/blog/fasttrackforazureblog/azure-orphan-resources/3492198).