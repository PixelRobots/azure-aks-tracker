---
layout: Conceptual
title: Azure Arc-enabled Kubernetes identity and access overview - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/identity-access-overview
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
ms.date: 2026-09-14T00:00:00.0000000Z
ms.topic: concept-article
description: Understand identity and access options for Arc-enabled Kubernetes clusters.
locale: en-us
document_id: 67d3bc82-573e-4c4d-6e33-821be7be66de
document_version_independent_id: 75cb67f4-3a6b-5fdb-22db-2daeba19dac2
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/identity-access-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/identity-access-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/identity-access-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
platformId: df1156b7-11dd-5904-2924-2e6f2db4025e
---

# Azure Arc-enabled Kubernetes identity and access overview - Azure Arc | Microsoft Learn

You can authenticate, authorize, and control access to your Azure Arc-enabled Kubernetes clusters. This article provides an overview of the options for doing so with your Arc-enabled Kubernetes clusters.

This image shows the ways that you can use these different options:

![Diagram showing the different options for authenticating, authorizing, and controlling access to Arc-enabled Kubernetes clusters.](media/identity-access-overview/identity-access-options.png)

You can also use both cluster connect and Azure RBAC together if that is most appropriate for your needs.

## Connectivity options

When planning how users will authenticate and access Arc-enabled Kubernetes clusters, decide whether you want to use the cluster connect feature.

### Cluster connect

The Azure Arc-enabled Kubernetes [cluster connect](conceptual-cluster-connect) feature provides connectivity to the `apiserver` of the cluster. This connectivity doesn't require any inbound port to be enabled on the firewall. A reverse proxy agent running on the cluster can securely start a session with the Azure Arc service in an outbound manner.

By using cluster connect, you can access your Arc-enabled clusters either within Azure or from the internet. This feature can help enable interactive debugging and troubleshooting scenarios. Cluster connect might also require less interaction for updates when permissions are needed for new users. All of the authorization and authentication options described in this article work with cluster connect.

Cluster connect is required if you want to use [custom locations](conceptual-custom-locations) or [view Kubernetes resources from Azure portal](kubernetes-resource-view).

For more information, see [Use cluster connect to securely connect to Azure Arc-enabled Kubernetes clusters](cluster-connect).

### Microsoft Entra ID and Azure RBAC without cluster connect

If you don't want to use cluster connect, you can authenticate and authorize users so they can access the connected cluster by using [Microsoft Entra ID](/en-us/azure/active-directory/fundamentals/active-directory-whatis) and [Azure role-based access control (Azure RBAC)](/en-us/azure/role-based-access-control/overview). By using [Azure RBAC on Azure Arc-enabled Kubernetes](conceptual-azure-rbac), you can control the access that you grant to users in your tenant. Manage access directly from Azure by using familiar Azure identity and access features. You can also configure roles at the subscription or resource group scope, so they roll out to all connected clusters within that scope.

Azure RBAC supports [conditional access](azure-rbac#use-conditional-access-with-azure-ad), so you can enable [just-in-time cluster access](azure-rbac#configure-just-in-time-cluster-access-with-azure-ad) or limit access to approved clients or devices.

Azure RBAC also supports a [direct mode of communication](azure-rbac#use-a-shared-kubeconfig-file), which uses Microsoft Entra identities to access connected clusters directly from within the datacenter, rather than requiring all connections to go through Azure.

For more information, see [Use Azure RBAC on Azure Arc-enabled Kubernetes clusters](azure-rbac).

## Authentication options

Authentication is the process of verifying a user's identity. There are two options for authenticating to an Arc-enabled Kubernetes cluster: cluster connect and Azure RBAC.

### Microsoft Entra authentication

The [Azure RBAC on Arc-enabled Kubernetes](conceptual-azure-rbac) feature lets you use [Microsoft Entra ID](/en-us/azure/active-directory/fundamentals/active-directory-whatis) to allow users in your Azure tenant to access your connected Kubernetes clusters.

You can also use Microsoft Entra authentication with cluster connect. For more information, see [Microsoft Entra authentication option](cluster-connect#microsoft-entra-authentication-option).

### Service token authentication

With cluster connect, you can choose to authenticate by using [service accounts](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#service-account-tokens).

For more information, see [Service account token authentication option](cluster-connect#service-account-token-authentication-option).

## Authorization options

Authorization grants an authenticated user the permission to perform specified actions. With Azure Arc-enabled Kubernetes, there are two authorization options, both of which use role-based access control (RBAC):

- [Azure role-based access control (Azure RBAC)](/en-us/azure/role-based-access-control/overview) uses Microsoft Entra ID and Azure Resource Manager to provide fine-grained access management to Azure resources. This allows the benefits of Azure role assignments, such as activity logs tracking all changes made, to be used with your Azure Arc-enabled Kubernetes clusters.
- [Kubernetes role-based access control (Kubernetes RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) lets you dynamically configure policies through the Kubernetes API so that users, groups, and service accounts only have access to specific cluster resources.

While Kubernetes RBAC works only on Kubernetes resources within your cluster, Azure RBAC works on resources across your Azure subscription.

### Azure RBAC authorization

[Azure role-based access control (RBAC)](/en-us/azure/role-based-access-control/overview) is an authorization system built on Azure Resource Manager and Microsoft Entra ID that provides fine-grained access management of Azure resources. With Azure RBAC, role definitions outline the permissions to apply. You assign these roles to users or groups through a role assignment for a particular scope. The scope can be across the entire subscription or limited to a resource group or to an individual resource such as a Kubernetes cluster.

If you use Microsoft Entra authentication without cluster connect, Azure RBAC authorization is your only option for authorization.

If you use cluster connect with Microsoft Entra authentication, you can use Azure RBAC for connectivity to the `apiserver` of the cluster. For more information, see [Microsoft Entra authentication option](cluster-connect#azure-active-directory-authentication-option).

### Kubernetes RBAC authorization

[Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) provides granular filtering of user actions. By using Kubernetes RBAC, you can assign users or groups permission to create and modify resources or view logs from running application workloads. You can create roles to define permissions, and then assign those roles to users with role bindings. You can scope permissions to a single namespace or across the entire cluster.

If you use cluster connect with the [service account token authentication option](cluster-connect#service-account-token-authentication-option), you must use Kubernetes RBAC to provide connectivity to the `apiserver` of the cluster. This connectivity doesn't require any inbound port to be enabled on the firewall. A reverse proxy agent running on the cluster can securely start a session with the Azure Arc service in an outbound manner.

If you use [cluster connect with Microsoft Entra authentication](cluster-connect#azure-active-directory-authentication-option), you can use Kubernetes RBAC instead of Azure RBAC.