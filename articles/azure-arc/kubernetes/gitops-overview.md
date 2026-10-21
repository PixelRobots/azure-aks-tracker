---
layout: Conceptual
title: GitOps based application deployment for AKS and Azure Arc enabled Kubernetes  - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/gitops-overview
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: ponatara
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
description: Provides overview on GitOps managed offerings for AKS and Azure Arc enabled Kubernetes
ms.topic: overview
ms.date: 2026-09-17T00:00:00.0000000Z
locale: en-us
document_id: 6b9a5d0d-fc41-1c76-b96f-5e3f616aa2c1
document_version_independent_id: 9a5d87ed-b89e-e133-8642-d1a208838fbf
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/gitops-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/gitops-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/gitops-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/63959238-cb90-4871-a33d-4a5519097e47
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/78d87f42-5582-4a6b-90be-7db2f12b34e6
platformId: 279c5762-e42f-cd36-c459-58016fdf9911
---

# GitOps based application deployment for AKS and Azure Arc enabled Kubernetes  - Azure Arc | Microsoft Learn

GitOps provides a declarative approach to Kubernetes application deployment and configuration management. By using source control as the system of record, platform teams can consistently deploy and manage applications across Azure Kubernetes Service (AKS), Azure Arc-enabled Kubernetes, on-premises environments, edge locations, and multicloud deployments.

## Why GitOps?

As Kubernetes adoption grows, organizations often need a consistent way to manage application deployments across multiple environments and clusters.

GitOps helps platform teams:

- Standardize deployment workflows.
- Improve deployment consistency.
- Detect and remediate configuration drift.
- Audit and review infrastructure and application changes.
- Reduce manual operational tasks.
- Scale application delivery across large Kubernetes fleets.

By storing desired configuration in source control, teams can use existing development processes, reviews, and approval workflows to manage Kubernetes deployments.

## Managed GitOps solutions in Azure

Azure provides managed GitOps experiences for both Flux and Argo CD on Azure Kubernetes Service (AKS) and Azure Arc-enabled Kubernetes.

Organizations can use GitOps to manage:

- Application deployments
- Kubernetes configuration
- Infrastructure components
- Environment-specific settings
- Fleet-wide operational standards

By providing managed GitOps experiences, Azure helps platform teams reduce operational overhead while continuing to use familiar GitOps workflows and open-source tooling.

## Enterprise capabilities

Both Flux and Argo CD extensions integrate with Azure services and enterprise operational practices, enabling organizations to scale GitOps adoption across teams, environments, and clusters.

### Azure-managed lifecycle management

Flux and Argo CD extensions are available as Azure-managed experiences that reduce the operational overhead associated with deploying, upgrading, and maintaining GitOps infrastructure.

Benefits include:

- Simplified deployment and upgrades
- Consistent management across environments
- Azure Resource Manager integration
- Centralized governance and operations
- Reduced maintenance burden

### Hybrid and multicloud deployments

Apply consistent GitOps practices across:

- Azure Kubernetes Service (AKS)
- Azure Arc-enabled Kubernetes (On-premises Kubernetes environments, Multicloud Kubernetes deployments)

Platform teams can standardize application delivery and configuration management regardless of where clusters run.

### Enterprise identity and security

GitOps solutions integrate with Microsoft Entra ID and Azure identity services, helping organizations align deployment workflows with existing security and compliance requirements.

Benefits include:

- Centralized authentication
- Consistent access controls
- Reduced credential management
- Improved auditability
- Support for secure access to Azure services

### Flexible deployment sources

Flux and Argo CD extensions support common Kubernetes deployment sources including:

- Git repositories
- Helm charts
- OCI artifacts
- Kustomize configurations

This flexibility allows teams to adopt GitOps without changing existing packaging and deployment workflows.

### Governance and compliance

Platform teams can apply consistent governance controls across environments and clusters. Common scenarios include:

- Environment standardization
- Repository governance
- Policy enforcement
- Team-level isolation
- Controlled promotion across environments
- Configuration consistency across large cluster fleets

### Observability and operations

GitOps deployments integrate with Azure monitoring and operational tooling, enabling teams to monitor deployment health, synchronization status, and platform operations by using familiar Azure experiences. This integration helps platform teams maintain operational visibility while quickly identifying deployment issues and configuration drift.

### Fleet-scale Kubernetes management

Organizations that operate hundreds or thousands of Kubernetes clusters can use GitOps to standardize application delivery and operational practices across distributed environments.

Common examples include:

- Retail stores
- Manufacturing facilities
- Branch offices
- Healthcare environments
- Financial services organizations

By using GitOps, platform teams can reduce operational variation while maintaining governance, compliance, and security requirements across large Kubernetes fleets.