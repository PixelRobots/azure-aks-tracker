---
layout: Conceptual
title: Access and identity options for Azure Kubernetes Service (AKS) on Azure Local for multi-rack deployments | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/multi-rack/concepts-security-access-identity
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
description: Learn about access and identity management options for Kubernetes clusters in AKS on Azure Local.
ms.topic: concept-article
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: sanjanamohan
ms.custom: multi-rack
author: sanjanamsft
locale: en-us
document_id: d0347b42-23ef-f02f-6d82-0245d52b5454
document_version_independent_id: 8ede887e-2e5e-e19a-1d52-675ab068021a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/multi-rack/concepts-security-access-identity.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/multi-rack/concepts-security-access-identity
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/multi-rack/concepts-security-access-identity.md
platformId: 6d848ea2-9ca9-82ed-1c74-3c5047bbec52
---

# Access and identity options for Azure Kubernetes Service (AKS) on Azure Local for multi-rack deployments | Microsoft Learn

You can authenticate, authorize, secure, and control access to Kubernetes clusters in various ways:

- By using Kubernetes role-based access control (Kubernetes RBAC), you can grant users, groups, and service accounts access to only the Kubernetes resources they need.
- By using AKS clusters enabled with Azure RBAC, you can further enhance the security and permissions structure by using Microsoft Entra ID and Azure RBAC.

Kubernetes RBAC and Azure RBAC help you secure your cluster access and provide only the minimum required permissions to developers and operators.

This article introduces the core concepts that help you authenticate and assign permissions in AKS.

Note

On multi-rack deployments, use `az aksarc get-credentials` to retrieve a `kubeconfig` file. You can also use `az connectedk8s proxy` for interactive access to an Azure RBAC-enabled cluster. For step-by-step guidance, see [Use Azure RBAC for AKS on Azure Local for multi-rack deployments](use-azure-rbac). To retrieve the certificate-based admin `kubeconfig`, see [Retrieve certificate-based admin kubeconfig in AKS Arc](../hyperconverged/retrieve-admin-kubeconfig).

## Kubernetes RBAC

Kubernetes RBAC provides granular filtering of user actions. With this control mechanism:

- You assign users or user groups permission to create, read, update, or delete resources or view logs from running application workloads.
- You can scope permissions to a single namespace or across the entire AKS cluster.
- You create *roles* to define permissions, and then assign those roles to users with *role bindings*.

For more information, see [Using Kubernetes RBAC authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/).

Note

Kubernetes RBAC is enabled by default. No flags required in CLI to manually enable it.

### Roles and ClusterRoles

In Kubernetes RBAC, you define permissions as a role.

#### Roles

Before assigning permissions to users with Kubernetes RBAC, you define user permissions as a role. Grant permissions within a Kubernetes namespace using roles.

Kubernetes roles grant permissions but they don't deny permissions. To grant permissions across the entire cluster or to cluster resources outside a given namespace, you can use *ClusterRoles*.

#### ClusterRoles

A ClusterRole grants and applies permissions to resources across the entire cluster, not a specific namespace.

### RoleBindings and ClusterRoleBindings

Once you define roles to grant permissions to resources, you assign those Kubernetes RBAC permissions with a *RoleBinding*.

#### RoleBindings

Assign roles to users for a given namespace using RoleBindings. With RoleBindings, you can logically segregate a single AKS cluster, only enabling users to access the application resources in their assigned namespace.

To bind roles across the entire cluster, or to cluster resources outside a given namespace, use *ClusterRoleBindings*.

#### ClusterRoleBinding

With a ClusterRoleBinding, you bind roles to users and apply to resources across the entire cluster, not a specific namespace. This approach lets you grant administrators or support engineers access to all resources in the AKS cluster.

## Kubernetes service accounts

*Service accounts* are one of the primary user types in Kubernetes. The Kubernetes API holds and manages service accounts. Service account credentials are stored as Kubernetes secrets, allowing them to be used by authorized pods to communicate with the API server. Most API requests provide an authentication token for a service account or a standard user account.

Standard user accounts provide more traditional access for human administrators or developers, not just services and processes. While Kubernetes doesn't provide an identity management solution to store regular user accounts and passwords, you can integrate external identity solutions into Kubernetes. For AKS clusters, this integrated identity solution is Microsoft Entra ID.

For more information about the identity options in Kubernetes, see [Kubernetes authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication).

## Azure role-based access control

Azure role-based access control (RBAC) is an authorization system built on [Azure Resource Manager](/en-us/azure/azure-resource-manager/management/overview) that provides fine-grained access management of Azure resources.

| RBAC system | Description |
| --- | --- |
| Kubernetes RBAC | Designed to work on Kubernetes resources within your AKS cluster. |
| [Azure RBAC](use-azure-rbac) | Designed to work on resources within your Azure subscription. |

With Azure RBAC, you create a *role definition* that outlines the permissions to apply. You then assign this role definition to a user or group through a *role assignment* for a particular *scope*. The scope can be an individual resource, a resource group, or across the subscription.

For more information, see [What is Azure role-based access control (Azure RBAC)?](/en-us/azure/role-based-access-control/overview).

To fully operate an AKS Arc cluster, you need two levels of access:

- Access the AKS resource in your Azure subscription.
    - Control scaling or upgrading your cluster by using the AKS enabled by Azure Arc APIs.
    - Connect to your cluster through the Azure Arc connected cluster proxy (`az connectedk8s proxy`).
- Access to the Kubernetes API. This access is controlled by either:
    - Kubernetes RBAC, or
    - Integrating Azure RBAC with AKS for Kubernetes authorization.

### Azure RBAC to authorize access to the AKS resource

By using Azure RBAC, you can give your users (or identities) granular access to AKS resources across one or more subscriptions. Three roles are available for this control plane action: **Azure Kubernetes Service Arc Cluster Admin Role**, **Azure Kubernetes Service Arc Cluster User Role**, and **Azure Kubernetes Service Arc Contributor Role**. Each role has a different permission scope, as described in [Azure built-in roles for Containers](/en-us/azure/role-based-access-control/built-in-roles/containers). For example, you can use the [Azure Kubernetes Service Arc Contributor](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-service-arc-contributor-role) role to create, scale, and upgrade your cluster.

### Azure RBAC for Kubernetes authorization

By using the Azure RBAC integration, you can manage Kubernetes cluster resource permissions and assignments by using Azure role definitions and role assignments.

[![Diagram of authorization flow.](media/concepts-security-access-identity/azure-rbac-k8s-authorization-flow.png)](media/concepts-security-access-identity/azure-rbac-k8s-authorization-flow.png#lightbox)

When you use the Azure RBAC integration, all requests to the Kubernetes API follow the same authentication flow. If the identity making the request exists in Microsoft Entra ID, Azure teams with Kubernetes RBAC to authorize the request. If the identity exists outside of Microsoft Entra ID (for example, a Kubernetes service account), authorization defers to the normal Kubernetes RBAC.

In this scenario, you use Azure RBAC mechanisms and APIs to assign users built-in roles or create custom roles, just as you would with Kubernetes roles.

By using this feature, you not only give users permissions to the AKS resource across subscriptions, but you also configure the role and permissions for inside each of those clusters controlling Kubernetes API access.

Important

You must enable Azure RBAC for Kubernetes authorization when you **create** the cluster, before doing role assignment. Enabling or disabling Azure RBAC on an existing multi-rack cluster isn't allowed. For more details and step-by-step guidance, see [Use Azure RBAC for AKS on Azure Local for multi-rack deployments](use-azure-rbac).

### Built-in roles

AKS Arc provides the following five built-in roles. They're similar to the [Kubernetes built-in roles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles), with a few differences, such as supporting CRDs. See the full list of actions allowed by each [Azure built-in role](/en-us/azure/role-based-access-control/built-in-roles).

| Role | Description |
| --- | --- |
| [Azure Arc-enabled Kubernetes Cluster User](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-arc-enabled-kubernetes-cluster-user-role) | Allows you to retrieve the Cluster Connect-based kubeconfig file to manage clusters from anywhere. |
| [Azure Arc Kubernetes Viewer](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-arc-kubernetes-viewer) | Allows read-only access to see most objects in a namespace. Doesn't allow viewing secrets, because **read** permission on secrets enables access to **ServiceAccount** credentials in the namespace. These credentials in turn allow API access through that **ServiceAccount** value (a form of privilege escalation). |
| [Azure Arc Kubernetes Writer](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-arc-kubernetes-writer) | Allows read/write access to most objects in a namespace. Doesn't allow viewing or modifying roles or role bindings. However, this role allows accessing secrets and running pods as any **ServiceAccount** value in the namespace, so it can be used to gain the API access levels of any such **ServiceAccount** value in the namespace. |
| [Azure Arc Kubernetes Admin](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-arc-kubernetes-admin) | Allows admin access. It's intended to be granted within a namespace through **RoleBinding**. If you use it in **RoleBinding**, it allows read/write access to most resources in a namespace, including the ability to create roles and role bindings within the namespace. This role doesn't allow write access to resource quota or to the namespace itself. |
| [Azure Arc Kubernetes Cluster Admin](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-arc-kubernetes-cluster-admin) | Allows "superuser" access to execute any action on any resource. When you use it in **ClusterRoleBinding**, it gives full control over every resource in the cluster and in all namespaces. When you use it in **RoleBinding**, it gives full control over every resource in the role binding namespace, including the namespace itself. |

## Microsoft Entra integration

Microsoft Entra integration can help to enhance your AKS cluster security. Built on enterprise identity management experience, Microsoft Entra ID is a multitenant, cloud-based directory and identity management service that combines core directory services, application access management, and identity protection. With Microsoft Entra ID, you can integrate on-premises identities into AKS clusters to provide a single source for account management and security.

[![Flowchart showing Entra integration.](media/concepts-security-access-identity/entra-integration.png)](media/concepts-security-access-identity/entra-integration.png#lightbox)

With Microsoft Entra-integrated AKS clusters, you can grant users or groups access to Kubernetes resources within a namespace or across the cluster.

- To obtain a **kubectl** configuration context, run the [az aksarc get-credentials](/en-us/cli/azure/aksarc#az-aksarc-get-credentials) command.
- When a user interacts with the AKS cluster using **kubectl**, they're prompted to sign in with their Microsoft Entra credentials.

This approach provides a single source for user account management and password credentials. The user can only access the resources as defined by the Kubernetes cluster administrator.

## Current limitations

The following security features aren't currently available on AKS on Azure Local for multi-rack deployments:

| Feature | Status | Notes |
| --- | --- | --- |
| OIDC issuer / Workload identity | Not available | Workload identity federation isn't currently supported on AKS on Azure Local for multi-rack deployments. |
| SSH access restriction (`authorizedIPRanges`) | Not available | The `clusterVMAccessProfile.authorizedIPRanges` field is accepted in the API schema but isn't currently enforced. |

## Summary

The following steps show how users can authenticate to Kubernetes when Azure RBAC is enabled.

1. Run `az login` and authenticate to Azure.
2. Connect to the cluster by using `az aksarc get-credentials` or `az connectedk8s proxy`.
3. Run `kubectl` commands. The first command can trigger browser-based authentication to authenticate to the Kubernetes cluster.