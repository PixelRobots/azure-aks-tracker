---
layout: Conceptual
title: Overview of Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/overview
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2026-03-24T00:00:00.0000000Z
ms.topic: overview
description: Azure Arc-enabled Kubernetes allows you to attach Kubernetes clusters running anywhere so that you can manage and configure them in Azure.
locale: en-us
document_id: ab9877fe-daba-9dd2-26f7-04de1f7a6dce
document_version_independent_id: 3fb88591-d13d-bd9f-7b3e-f48d11f28fbe
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d67c96b5-869a-4314-42dd-28b465192dd1
---

# Overview of Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

Azure Arc-enabled Kubernetes lets you attach Kubernetes clusters running anywhere so that you can manage and configure them in Azure. When you manage all your Kubernetes resources in a single control plane, you get a more consistent development and operation experience. This approach helps you run cloud-native apps anywhere and on any Kubernetes platform.

When you [deploy Azure Arc agents to the cluster](quickstart-connect-cluster), the agents create a secure outbound connection to Azure.

Each Kubernetes cluster that you connect to Azure appears as its own resource in Azure Resource Manager. You can organize these clusters with resource groups and tagging, just like your other Azure resources.

## Supported Kubernetes distributions

Azure Arc-enabled Kubernetes works with any Cloud Native Computing Foundation (CNCF) certified Kubernetes clusters. This support includes clusters running on other public cloud providers, such as Google Cloud Platform (GCP) or Amazon Web Services (AWS), and clusters running in your on-premises data center, such as VMware vSphere or Azure Local.

The Azure Arc team works with key industry partners to [validate conformance of Kubernetes distributions with Azure Arc-enabled Kubernetes](validation-program).

## Arc-enabled Kubernetes scenarios and enhanced functionality

After you connect your Kubernetes clusters to Azure, you can use a wide variety of Azure services and features to manage your clusters at scale, such as:

- View all connected Kubernetes clusters for inventory, grouping, and tagging, along with your Azure Kubernetes Service (AKS) clusters.
- Configure clusters and deploy applications by using GitOps-based configuration management with [Argo CD](tutorial-use-gitops-argocd) or [Flux v2](tutorial-use-gitops-flux2).
- View and monitor your clusters by using [Azure Monitor](/en-us/azure/azure-monitor/containers/container-insights-enable-arc-enabled-clusters?toc=/azure/azure-arc/kubernetes/toc.json).
- Enable threat protection by using [Microsoft Defender for Containers](/en-us/azure/defender-for-cloud/defender-for-kubernetes-azure-arc?toc=/azure/azure-arc/kubernetes/toc.json).
- Manage and report on compliance by using [Azure Policy](/en-us/azure/governance/policy/concepts/policy-for-kubernetes?toc=/azure/azure-arc/kubernetes/toc.json).
- [Connect to your Kubernetes clusters from anywhere](cluster-connect), and manage access by using [Azure role-based access control (Azure RBAC)](azure-rbac).
- Deploy machine learning workloads by using [Azure Machine Learning for Kubernetes clusters](/en-us/azure/machine-learning/how-to-attach-kubernetes-anywhere?toc=/azure/azure-arc/kubernetes/toc.json).
- Deploy and manage [Kubernetes applications from Microsoft Marketplace](deploy-marketplace).
- Deploy services that allow you to take advantage of specific hardware, comply with data residency requirements, or enable new scenarios, such as [Azure Arc-enabled data services](../data/overview) or [Event Grid on Kubernetes](/en-us/azure/event-grid/kubernetes/overview).
- Use [Azure Kubernetes Fleet Manager](/en-us/azure/kubernetes-fleet/overview) and its Arc-enabled Kubernetes cluster extension to tackle hybrid and multicloud Kubernetes management challenges at scale.

Note

This service supports [Azure Lighthouse](/en-us/azure/lighthouse/overview), which lets service providers sign in to their own tenant to manage subscriptions and resource groups that customers have delegated.