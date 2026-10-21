---
layout: Conceptual
title: Get Azure Kubernetes Service (AKS) cost recommendations in Azure Advisor - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/cost-advisors
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
description: Learn how to get Azure Kubernetes Service (AKS) cost recommendations using Azure Advisor.
author: kaysieyu
ms.author: kaysieyu
ms.topic: how-to
ms.date: 2025-03-28T00:00:00.0000000Z
locale: en-us
document_id: 616887c7-ceb3-0e2a-e21b-987373936890
document_version_independent_id: 135dd29d-afac-db75-2976-bd01856c6a42
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/cost-advisors.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/cost-advisors
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/cost-advisors.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/d9dfd2a0-aa13-46ef-a37d-ed697b490607
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/06404839-4766-4799-8cab-c0e1c3b55e48
platformId: 0ba508b5-e737-069b-f9a1-070722004dd6
---

# Get Azure Kubernetes Service (AKS) cost recommendations in Azure Advisor - Azure Kubernetes Service | Microsoft Learn

AKS cost recommendations in Azure Advisor follow AKS cost best practices and help you optimize your deployments to achieve cost-efficiency without compromising on reliability. Advisor analyzes your resource configuration and recommends solutions to optimize your AKS cluster.

With Advisor, you can:

- Get proactive, actionable, and personalized best practices recommendations.
- Identify opportunities to reduce your overall Azure spend.
- Get recommendations with proposed actions inline.

Cost is one of five categories that Advisor recommendations can fall into. Other categories include reliability, security, performance, and operational excellence. For more information, see the [Introduction to Azure Advisor](/en-us/azure/advisor/advisor-overview).

## Prerequisites

- To access Advisor recommendations you must have one of the following roles: Owner, Contributor, or Reader of a subscription, resource group, or resource.

## AKS cost recommendations

Recommendations are available for all clusters, but only the ones relevant to the cluster configuration and historical usage will be surfaced. There is no action required by the customer to enable Azure Advisor, as it is a provided by default for all Azure services out of box.

AKS cost recommendations include the following:

- Enable Vertical Pod Autoscaler recommendation mode to rightsize resource requests and limits.
- Use Azure Kubernetes Service Cost Analysis.
- Fine-tune the cluster autoscaler profile for rapid scale down and cost savings.

For more information, see [Cost recommendations](/en-us/azure/advisor/advisor-reference-cost-recommendations#azure-kubernetes-service).

### Enable Vertical Pod Autoscaler recommendation mode to rightsize resource requests and limits

Setting the correct request and limit values is difficult given the required amount of resources can vary greatly across workloads. Managing this at scale across hundreds or thousands of pods is an even greater challenge. Vertical Pod Autoscaler (VPA) automatically adjusts CPU and memory requests and limits for your pods based on historical workload usage patterns to improve resource utilization.

If you don't want VPA to automatically adjust the values and want additional control, VPA recommendation only mode provides suggested values without making automatic changes. This enables you to review and implement suggested values manually, which can prevent potential disruptions and ensure better control over resource allocation. VPA recommendation mode is a great option to help prevent over-provisioning, a major driver of unnecessary spend.

For more information, see [Vertical pod autoscaling in Azure Kubernetes Service (AKS)](vertical-pod-autoscaler#vpa-overview).

### Use Azure Kubernetes Service cost analysis

AKS cost analysis add-on provides detailed insights into the cost of resources used by your AKS cluster. View costs broken down by Kubernetes constructs like clusters and namespaces. This feature helps you identify cost drivers, track historical trends, identify anomalies and clusters or workloads with optimization opportunities. Having cost monitoring in place is an easy way to get visibility into cluster spend and take action to achieve significant cost savings.

Note

This recommendation is only available for public cloud clusters running in Enterprise or MCA type subscriptions.

For more information, see [Azure Kubernetes Service (AKS) cost analysis](cost-analysis).

### Fine-tune the cluster autoscaler profile for rapid scale down and cost savings

The cluster autoscaler profile is a set of parameters that control the behavior of the cluster autoscaler, which automatically adjusts the number of nodes in a cluster based on workload demand. Tuning these settings allows greater control over autoscaler behavior to optimize resource allocation for specific scenarios. A rapid scale down configuration means more aggressive node scale, which means less idle node costs.

For more information, see [Use the cluster autoscaler in Azure Kubernetes Service (AKS)](cluster-autoscaler#configure-cluster-autoscaler-profile-for-aggressive-scale-down).

## View the Advisor dashboard

You can view recommendations on the Advisor dashboard in Azure portal. For more information, see [Azure Advisor portal basics](/en-us/azure/advisor/advisor-get-started).