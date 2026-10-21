---
layout: Conceptual
title: Custom locations with Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-custom-locations
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
ms.date: 2025-07-21T00:00:00.0000000Z
ms.topic: concept-article
description: This article provides a conceptual overview of the custom locations capability of Azure Arc-enabled Kubernetes.
locale: en-us
document_id: ae94e97f-8649-1f08-a84f-a90d5ad00d7b
document_version_independent_id: bbaad3c9-1790-ca4f-17ed-ec3ef3e8d149
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-custom-locations.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-custom-locations
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-custom-locations.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: cd76be9c-3c24-6d3f-330c-b48349ab51e4
---

# Custom locations with Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

As an extension of the Azure location construct, the *custom locations* feature provides a way for tenant administrators to use their Azure Arc-enabled Kubernetes clusters as target locations for deploying Azure services instances. Examples of Azure offerings that can be deployed on top of custom locations include databases, such as SQL Managed Instance enabled by Azure Arc.

Similar to Azure locations, end users within the tenant who have access to Custom Locations can deploy resources there using their company's private compute.

![Diagram showing the Arc platform layers.](media/conceptual-arc-platform-layers.png)

You can visualize custom locations as an abstraction layer on top of Azure Arc-enabled Kubernetes clusters, cluster connect, and cluster extensions. Custom locations create the granular [RoleBindings and ClusterRoleBindings](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding) necessary for other Azure services to access the cluster. These other Azure services require cluster access to manage deployed resources.

## Architecture

When the admin [enables the custom locations feature on the cluster](custom-locations), a `ClusterRoleBinding` is created on the cluster, authorizing the Microsoft Entra application used by the custom locations resource provider. Once authorized, the custom locations resource provider can create `ClusterRoleBinding` or `RoleBinding` objects that are needed by other Azure resource providers to create custom resources on this cluster. The cluster extensions installed on the cluster determine the list of resource providers to authorize.

[![Diagram of custom locations architecture, using Arc-enabled data services as an example.](media/conceptual-custom-locations-usage.png)](media/conceptual-custom-locations-usage.png#lightbox)

*To download architecture diagrams in high resolution, visit [Jumpstart Gems](https://aka.ms/JumpstartGems_Docs).*

When the user creates a data service instance on the cluster:

1. The PUT request is sent to Azure Resource Manager.
2. The PUT request is forwarded to the Azure Arc-enabled data services resource provider.
3. The RP fetches the `kubeconfig`file associated with the Azure Arc-enabled Kubernetes cluster on which the custom location exists.
    - Custom location is referenced as `extendedLocation` in the original PUT request.
4. The Azure Arc-enabled data services resource provider uses the `kubeconfig`to communicate with the cluster to create a custom resource of the Azure Arc-enabled data services type on the namespace mapped to the custom location.
    - The Azure Arc-enabled data services operator was deployed via cluster extension creation before the custom location existed.
5. The Azure Arc-enabled data services operator reads the new custom resource created on the cluster and creates the data controller, translating into realization of the desired state on the cluster.