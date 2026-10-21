---
layout: Conceptual
title: Cluster authorization concepts in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-cluster-authorization
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
description: Learn how authorization for the Kubernetes API works in Azure Kubernetes Service (AKS), and how to choose between Kubernetes RBAC and Microsoft Entra ID authorization with optional Azure ABAC conditions.
ms.topic: concept-article
ms.subservice: aks-security
ms.date: 2026-04-19T00:00:00.0000000Z
author: shashankbarsin
ms.author: shasb
ai-usage: ai-assisted
locale: en-us
document_id: f3317e86-be92-aa35-490a-24e36d7546a9
document_version_independent_id: 3aeb02a0-b7a1-ad4a-385a-d8a182955d53
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-cluster-authorization.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-cluster-authorization
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-cluster-authorization.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 0c3a757f-1b40-9074-e330-3d82f6b9ef12
---

# Cluster authorization concepts in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article describes how Azure Kubernetes Service (AKS) decides what an authenticated caller is allowed to do against the Kubernetes API. It covers the two authorization models AKS supports and fine-grained custom resource control with Azure ABAC conditions.

For how AKS *authenticates* callers in the first place, see [Cluster authentication concepts](concepts-cluster-authentication).

For an orientation across all four AKS identity scenarios, see [Access and identity options for AKS](concepts-identity).

## Authorize the Kubernetes API

After a caller is authenticated, AKS evaluates whether the caller is authorized to perform the requested action. AKS supports two authorization models for the Kubernetes API:

- **Kubernetes role-based access control (RBAC).** The native Kubernetes authorization model. Permissions are defined as `Role` and `ClusterRole` objects and granted to subjects through `RoleBinding` and `ClusterRoleBinding` objects stored in each cluster.
- **Microsoft Entra ID authorization.** An AKS authorization webhook that delegates authorization decisions to Microsoft Entra ID. Permissions are granted as Azure role assignments to Entra ID identities, and can be optionally refined with [Azure ABAC conditions](/en-us/azure/role-based-access-control/conditions-overview).

You can use both models on the same cluster. We recommend Microsoft Entra ID authorization as the default and reserve Kubernetes RBAC for fine-grained intra-cluster permissions. The rest of this section explains why and when to use each.

### Kubernetes RBAC

Kubernetes RBAC is the upstream Kubernetes authorization model. You author `Role` or `ClusterRole` objects that grant verbs (such as `get`, `list`, `create`) on resources (such as `pods`, `deployments`), and bind them to subjects (users, groups, or service accounts) using `RoleBinding` or `ClusterRoleBinding` objects. The Kubernetes API server's built-in RBAC authorizer evaluates these bindings on every request.

Use Kubernetes RBAC when you want:

- Fine-grained, intra-cluster, per-namespace access control authored as Kubernetes manifests alongside the workloads they protect.
- GitOps-managed authorization that lives in the same source of truth as your application configuration.
- Permissions for in-cluster service accounts that workloads use to call the Kubernetes API.

Kubernetes RBAC permissions are scoped to a single cluster. To apply the same policy to many clusters, you must apply the manifests to each cluster (typically through GitOps). Use Microsoft Entra users and groups as subjects in Kubernetes `RoleBinding` and `ClusterRoleBinding` objects so that human identities still come from your central directory.

For background on the Kubernetes RBAC model, see the [upstream Kubernetes RBAC documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/). For setup in AKS, see [Use Kubernetes RBAC with Microsoft Entra integration](kubernetes-rbac-entra-id).

### Microsoft Entra ID authorization for the Kubernetes API

With Entra ID authorization, AKS deploys an authorization webhook that delegates Kubernetes API authorization decisions to Microsoft Entra ID. When a request reaches the API server, the webhook calls the Entra ID `checkaccess` API to evaluate the caller's Azure role assignments (and any attached ABAC conditions) and returns an allow or deny decision.

![Diagram that shows the Entra ID authorization webhook flow for the Kubernetes API.](media/concepts-identity/azure-rbac-k8s-authz-flow.png)

Entra ID authorization gives you the following benefits over managing Kubernetes RBAC manifests on every cluster:

- **Single identity plane.** The same Microsoft Entra users, groups, and service principals that govern access to your Azure resources also govern access to your Kubernetes API. There's no separate user directory to provision or rotate.
- **Assign once, govern many clusters.** Azure role assignments can be made at **subscription, management group, or resource group scope**. A single role assignment at a resource group scope grants access to every current and future AKS cluster in that resource group. With Kubernetes RBAC, you must apply manifests to every cluster individually.
- **Conditional Access and Privileged Identity Management (PIM).** Cluster access automatically inherits your organization's existing Entra ID Conditional Access policies (such as multifactor authentication or location-based restrictions) and can be elevated just-in-time through PIM.
- **Centralized audit.** Every role assignment change is recorded in the Azure Activity Log alongside other Azure resource changes, so you have one audit trail for cluster access governance.
- **Fine-grained custom resource constraints.** With ABAC conditions, you can restrict access to specific custom resource (CRD) groups and kinds without writing per-cluster Kubernetes RBAC manifests.

AKS provides the following built-in roles for Entra ID authorization:

| Role | Description |
| --- | --- |
| Azure Kubernetes Service RBAC Reader | Read-only access to most objects in a namespace. Doesn't allow viewing roles, role bindings, or `Secrets`. |
| Azure Kubernetes Service RBAC Writer | Read/write access to most objects in a namespace. Doesn't allow viewing or modifying roles or role bindings. |
| Azure Kubernetes Service RBAC Admin | Read/write access to most resources in a namespace, plus the ability to create roles and role bindings within the namespace. |
| Azure Kubernetes Service RBAC Cluster Admin | Full control over every resource in the cluster, across all namespaces. |

For custom permission patterns, you can author custom role definitions that target specific Kubernetes API groups using the `Microsoft.ContainerService` resource provider's data actions. For step-by-step setup and custom role examples, see [Use Microsoft Entra ID authorization for the Kubernetes API](entra-id-authorization).

### Comparison

| Capability | Kubernetes RBAC | Entra ID authorization |
| --- | --- | --- |
| Identity source | Kubernetes users, groups, service accounts | Microsoft Entra ID identities |
| Scope of a single grant | One cluster | Resource, resource group, subscription, or management group |
| Multi-cluster governance | Apply manifests to each cluster (typically GitOps) | One role assignment at a higher scope governs many clusters |
| Conditional Access / PIM | Not supported | Inherited from Entra ID |
| Audit trail | Cluster audit log | Azure Activity Log |
| Filter access by CRD group or kind | Author per-CRD `Role` objects | Use ABAC condition attributes on the role assignment |

## Restrict custom resource access with ABAC conditions

When you grant broad read access through Microsoft Entra ID authorization but want to restrict which custom resources (CRDs) the assignee can read, attach an Azure ABAC condition to the role assignment.

Without ABAC conditions, granting read on custom resources requires a wildcard like `Microsoft.ContainerService/managedClusters/*/read`, which covers every CRD on every cluster in scope. With ABAC, you can attach a condition that restricts access to specific CRD groups and kinds — for example, allow `templates.gatekeeper.sh` while blocking `kyverno.io` — without writing per-cluster Kubernetes RBAC manifests.

For Kubernetes API authorization, you can filter access to custom resources by their API group and kind using the following attributes:

- `Microsoft.ContainerService/managedClusters/customResources:group`
- `Microsoft.ContainerService/managedClusters/customResources:kind`

For background on Azure ABAC, see [What are Azure role assignment conditions?](/en-us/azure/role-based-access-control/conditions-overview). For step-by-step setup, see [Restrict custom resource access using ABAC conditions](entra-id-authorization#restrict-custom-resource-access-using-abac-conditions-preview).