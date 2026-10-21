---
layout: Conceptual
title: Application deployments with GitOps (Argo CD) - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-gitops-argocd
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
description: This article provides a conceptual overview of GitOps with Argo CD for use in Azure Arc-enabled Kubernetes and Azure Kubernetes Service (AKS) clusters.
ms.date: 2026-03-23T00:00:00.0000000Z
ms.topic: concept-article
locale: en-us
document_id: 380c404e-95b7-0ad7-cfc8-31a142a78d02
document_version_independent_id: 7a5e0390-ef02-085e-a8d2-3754ce4a8d9a
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-gitops-argocd.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-gitops-argocd
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-gitops-argocd.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 8734365e-251b-50cc-86b7-f263e2628b1d
---

# Application deployments with GitOps (Argo CD) - Azure Arc | Microsoft Learn

When you use [Argo CD for GitOps on Azure Kubernetes Service (AKS) and Azure Arc-enabled Kubernetes clusters](tutorial-use-gitops-argocd), your Git repository becomes the source of truth for the desired state of your applications and cluster configurations. This approach offers several benefits:

- **Continuous synchronization**: Argo CD runs natively within your cluster, pulling manifests, Helm charts, or Kustomize configurations directly from Git.
- **Drift detection and remediation**: The system constantly monitors the cluster's live state against the desired state in Git. It instantly detects any drift and reconciles it based on your specific automation policies.
- **Security-first pull model**: Unlike traditional CI/CD, Argo CD uses a pure pull-based architecture. Since the cluster initiates the connection, you don't need to open inbound firewall ports or grant Git repositories network access to your private clusters. This architecture makes Argo CD ideal for high-security environments, edge computing, and massive hybrid-cloud scales.

## Argo CD cluster extension

To streamline management, Azure provides Argo CD as a managed [cluster extension](conceptual-extensions) (`Microsoft.KubernetesConfiguration/extensions/microsoft.argocd`). To manage applications via GitOps, [deploy the Argo CD extension](tutorial-use-gitops-argocd#create-gitops-argo-cd-extension-simple-installation) to your cluster.

## Managed components and controllers

The Argo CD extension packages and manages the core components required for enterprise-grade GitOps:

| **Component name** | **Kubernetes service name** | **Primary responsibility** |
| --- | --- | --- |
| [Application controller](https://argo-cd.readthedocs.io/en/stable/operator-manual/server-commands/argocd-application-controller/) | `argocd-application-controller` | Continuously monitors running applications and compares the live state against the desired target state in Git. |
| [API server](https://argo-cd.readthedocs.io/en/stable/operator-manual/architecture/) | `argocd-server` | Acts as the gRPC/REST server that exposes the API used by the Web UI, CLI, and external CI/CD systems. |
| [Repository server](https://argo-cd.readthedocs.io/en/stable/operator-manual/server-commands/argocd-repo-server/) | `argocd-repo-server` | Maintains a local cache of Git repositories and is responsible for generating Kubernetes manifests from source (Helm, Kustomize, etc.). |
| Redis | `argocd-redis` | Provides an ephemeral, in-memory data store used for caching manifest generation results and application state. |
| [Dex](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#dex) and notifications | `argocd-dex-server` | An open-source OpenID Connect provider that brokers identity from external providers like [GitHub](https://github.com/), SAML, or LDAP. |
| [Notifications controller](https://argocd-operator.readthedocs.io/en/latest/usage/notifications/) | `argocd-notifications-controller` | Monitors application state changes and triggers alerts to external services like Slack, Email, or Webhooks. |
| [ApplicationSet controller](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/) | `argocd-applicationset-controller` | Automates the creation of multiple applications across multiple clusters. |

## Argo CD constructs

After you deploy the Argo CD extension to your cluster, you can manage your workloads by using Argo CD constructs, such as:

- **Application and ApplicationSet**: Define individual applications for single-target deployments, or use ApplicationSets to automate the creation of multiple applications across different clusters and environments based on templates.
- **Management interfaces**: Manage and monitor resources through the Argo CD Web UI for a visual representation of cluster health, or by using the Argo CD CLI for terminal-based operations and automation.

For more information, see the [Argo CD documentation](https://argo-cd.readthedocs.io/en/stable/).

## Identity and access

To align with enterprise security requirements, the Argo CD extension integrates with Azure identity for both AKS and Azure Arc‑enabled Kubernetes clusters.

The extension supports workload identity federation, which enables Argo CD to securely access Azure resources such as Azure Container Registry (ACR) and Azure DevOps without relying on long‑lived secrets. The Argo CD extension also supports single sign‑on (SSO) by using Microsoft Entra ID, which allows users to authenticate to Argo CD by using their existing enterprise identities. By using this model, Azure centrally governs credentials and access policies, rather than embedding them directly in cluster configuration or Git repositories.