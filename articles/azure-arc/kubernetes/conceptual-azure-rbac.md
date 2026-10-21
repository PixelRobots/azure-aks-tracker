---
layout: Conceptual
title: Azure RBAC on Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-azure-rbac
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
ms.date: 2025-04-22T00:00:00.0000000Z
ms.topic: concept-article
description: This article provides a conceptual overview of the Azure RBAC capability on Azure Arc-enabled Kubernetes.
locale: en-us
document_id: f022b625-c161-60ad-72b1-100178755ae5
document_version_independent_id: 62f045de-610a-6a28-09cc-b66fa3c939bf
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-azure-rbac.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-azure-rbac
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-azure-rbac.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: bb9edc13-8708-7079-41d1-403da482e270
---

# Azure RBAC on Azure Arc-enabled Kubernetes - Azure Arc | Microsoft Learn

[Microsoft Entra ID](/en-us/entra/fundamentals/whatis)and [Azure role-based access control (Azure RBAC)](/en-us/azure/role-based-access-control/overview) let you control authorization checks on your Azure Arc-enabled Kubernetes cluster. Using Azure RBAC with your cluster gives you the benefits of Azure role assignments, such as activity logs showing changes made by users to your Azure resource.

## Architecture

![Diagram showing Azure RBAC architecture.](media/conceptual-azure-rbac.png)

*To download architecture diagrams in high resolution, visit [Jumpstart Gems](https://aka.ms/JumpstartGems_Docs).*

In order to route all authorization access checks to the authorization service in Azure, a webhook server ([guard](https://github.com/appscode/guard)) is deployed on the cluster.

The `apiserver` of the cluster is configured to use [webhook token authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#webhook-token-authentication) and [webhook authorization](https://kubernetes.io/docs/reference/access-authn-authz/webhook/) so that `TokenAccessReview` and `SubjectAccessReview` requests are routed to the guard webhook server. The `TokenAccessReview` and `SubjectAccessReview` requests are triggered by requests for Kubernetes resources sent to the `apiserver`.

Guard then makes a `checkAccess` call on the authorization service in Azure to see if the requesting Microsoft Entra entity has access to the resource of concern.

If that entity has a role that permits this access, an `allowed` response is sent from the authorization service to guard. Guard, in turn, sends an `allowed` response to the `apiserver`, enabling the calling entity to access the requested Kubernetes resource.

If the entity doesn't have a role that permits this access, a `denied` response is sent from the authorization service to guard. Guard sends a `denied` response to the `apiserver`, giving the calling entity a 403 forbidden error on the requested resource.

## Enable Azure RBAC on your Arc-enabled Kubernetes clusters

For detailed information about how to set up Azure RBAC and create role assignments for your clusters, see [Use Azure RBAC on Azure Arc-enabled Kubernetes clusters](azure-rbac).