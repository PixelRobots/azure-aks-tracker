---
layout: Conceptual
title: Cluster authentication concepts in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/concepts-cluster-authentication
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
description: Learn how Azure Kubernetes Service (AKS) authenticates Kubernetes API requests using Microsoft Entra ID, and how to disable local cluster admin accounts in production.
ms.topic: concept-article
ms.subservice: aks-security
ms.date: 2026-04-19T00:00:00.0000000Z
author: shashankbarsin
ms.author: shasb
ai-usage: ai-assisted
locale: en-us
document_id: 1d6c2638-a0c5-f34d-a0d9-3c7e42f8d934
document_version_independent_id: 66e123b1-5a86-7bed-0d5a-b27fb73a40d7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/concepts-cluster-authentication.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/concepts-cluster-authentication
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/concepts-cluster-authentication.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
platformId: 4832d75a-dc62-5174-baba-2c5c08a0a0ff
---

# Cluster authentication concepts in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article describes how Azure Kubernetes Service (AKS) authenticates callers to the Kubernetes API — that is, who can connect to the control plane. It covers the recommended Microsoft Entra ID-based authentication path and how to lock down break-glass access.

For how AKS evaluates what an authenticated caller is *allowed to do*, see [Cluster authorization concepts](concepts-cluster-authorization).

For the other identity scenarios in AKS, see:

- [Managed identities in AKS](use-managed-identity) for cluster-to-Azure access (such as pulling images from ACR or attaching disks).
- [Microsoft Entra Workload ID overview](workload-identity-overview) for pod-to-Azure access (such as workloads calling Key Vault).

For an orientation across all four AKS identity scenarios, see [Access and identity options for AKS](concepts-identity).

## Authenticate to the Kubernetes API server (control plane)

### Microsoft Entra ID (recommended)

Kubernetes itself doesn't provide an identity directory. Without an external identity provider, you'd need to manage local credentials per cluster, which doesn't scale and creates audit gaps.

We recommend deploying AKS clusters with [Microsoft Entra ID authentication for the control plane](entra-id-control-plane-authentication). With this integration, the cluster validates incoming Kubernetes API requests against Microsoft Entra ID and uses the caller's Entra identity for authorization decisions. Microsoft Entra ID centralizes the identity layer — any change in user or group status is automatically reflected in cluster access — and enables Conditional Access, multifactor authentication, and Privileged Identity Management.

![Diagram that shows Microsoft Entra integration with AKS clusters for authentication.](media/concepts-identity/aad-integration.png)

For setup, see [Enable Microsoft Entra ID authentication for the AKS control plane](entra-id-control-plane-authentication). Note the following:

- The Microsoft Entra tenant configured for cluster authentication must be the same as the tenant of the subscription that holds the AKS cluster.
- For non-interactive logins or older `kubectl` versions, use the [`kubelogin`](https://github.com/Azure/kubelogin) plugin.

### External identity providers (preview)

Some organizations need to authenticate cluster users with an OIDC-compliant identity provider other than Microsoft Entra ID — for example, GitHub, Google Workspace, Okta, or a self-hosted IdP. AKS supports this through structured authentication, which configures the Kubernetes API server's JWT authenticators to validate tokens issued by your external provider.

Use this option only when you have a hard requirement to keep cluster identity outside Microsoft Entra ID. Otherwise, prefer the Microsoft Entra ID path for richer integration with Conditional Access, multifactor authentication, and Privileged Identity Management.

For an overview, see [External identity provider authentication for AKS clusters](external-identity-provider-authentication-overview). For setup, see [Configure external identity providers with AKS structured authentication](external-identity-provider-authentication-configure).

### Disable local accounts

Local accounts use a built-in cluster admin certificate that bypasses Microsoft Entra ID. Any caller who can list this credential gets full cluster admin access without going through Entra ID, which breaks centralized audit, Conditional Access, and Privileged Identity Management. In production, disable local accounts so that all access flows through Microsoft Entra ID.

To enforce this at scale across many clusters, assign the built-in Azure Policy **Azure Kubernetes Service Clusters should have local authentication methods disabled** at a subscription or management group scope. The policy audits or denies clusters that are created or updated with local accounts enabled. For the full list of AKS-related built-in policies, see [Azure Policy built-in definitions for AKS](/en-us/azure/governance/policy/samples/built-in-policies#kubernetes).

For details, see [Manage local accounts in AKS](local-accounts).

## Authenticate to cluster nodes

### SSH access modes

Beyond authenticating to the Kubernetes API, you might also need to authenticate directly to a node over SSH for troubleshooting. AKS supports three SSH access modes that you set per cluster or node pool:

- **Disabled SSH (preview)**: Block SSH access to nodes entirely. Recommended for production where node-level access is governed only through `kubectl debug` or other Kubernetes-native paths.
- **Microsoft Entra ID based SSH (preview)**: Sign in to nodes using Microsoft Entra identities, with no SSH keys to manage. This mode is consistent with the rest of cluster authentication: it inherits Conditional Access and multifactor authentication from Entra ID, supports just-in-time elevation through Azure RBAC and Privileged Identity Management, and centralizes audit through Entra ID sign-in logs.
- **Local user SSH**: Traditional SSH key–based access. Use this only when Entra ID based SSH isn't an option, and rotate keys regularly.

For setup and per-mode configuration steps, see [Manage SSH access on AKS cluster nodes](manage-ssh-node-access).