---
layout: Conceptual
title: About the Agentic CLI for Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/agentic-cli-for-aks-overview
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
description: Learn about the agentic CLI for Azure Kubernetes Service (AKS) and its features, best practices, security considerations, how to get started, and more.
ms.topic: overview
ms.date: 2025-10-20T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-developer
locale: en-us
document_id: 279d2733-59a3-24a7-467d-a45f824a341c
document_version_independent_id: 60f80981-c198-e83c-2a23-822490a3cc28
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/agentic-cli-for-aks-overview.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/agentic-cli-for-aks-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/agentic-cli-for-aks-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: afcb2c5f-6703-8140-53fa-a62167eaebf9
---

# About the Agentic CLI for Azure Kubernetes Service (AKS) (preview) - Azure Kubernetes Service | Microsoft Learn

This article provides an overview of the agentic CLI for Azure Kubernetes Service (AKS), an AI-powered troubleshooting and insights tool that brings advanced diagnostics directly to your terminal. This feature is designed to help AKS administrators or developers quickly diagnose, understand, and resolve complex issues without needing deep Kubernetes expertise or memorizing command syntax.

## Agentic CLI for AKS overview

The agentic CLI for AKS provides the `az aks agent` command group. You can use it to ask natural language questions about your cluster's health, configuration, and issues.

### Get cluster information, configurations, and insights

You can use the agentic CLI for AKS to quickly gather detailed information about your AKS clusters, including:

- Comprehensive cluster status and configuration details.
- Real-time cluster metrics and health information.
- Intelligent analysis of cluster state and potential issues.
- Proactive recommendations based on cluster configuration and workload patterns.

### Troubleshoot advanced AKS, Kubernetes, and health issues

The agentic CLI for AKS uses AI to help you troubleshoot complex issues by providing:

- AI-powered diagnostics that analyze complex cluster problems.
- Intelligent issue detection across the AKS control plane, node pools, and workloads.
- Automated root cause analysis for networking, storage, and security issues.
- Guided troubleshooting workflows with step-by-step remediation suggestions.
- Integration with Microsoft's extensive Kubernetes troubleshooting knowledge base.

## Deployment modes

The agentic CLI for AKS supports two deployment modes to accommodate different operational requirements and security models: **client mode** and **cluster mode**.

The following table summarizes ideal use cases and characteristics of each deployment mode to help you choose the best option for your environment:

| Mode | Description | Use cases | Key characteristics |
| --- | --- | --- | --- |
| **Client mode** | Runs the agentic CLI locally on your machine using Docker containers. | • Development and testing environments  • Individual developer workflows  • Environments with strict cluster security policies | • Uses your local Azure CLI credentials and kubectl configuration  • Requires Docker to be installed and running locally  • Provides the same diagnostic capabilities as cluster mode |
| **Cluster mode** | Deploys the agentic CLI as a pod within your AKS cluster using Kubernetes service accounts and workload identity. | • Production environments  • Shared team environments  • Automated workflows  • Enhanced security scenarios with workload identity and Azure RBAC integration | • Uses Kubernetes service accounts with workload identity for secure authentication  • Runs directly within the AKS cluster for optimal performance and network access  • Supports optional Azure RBAC integration for enhanced security |

## Best practices

Keep the following best practices in mind when you use the agentic CLI for AKS:

- **Start with broad diagnostic queries**: Begin with general questions, like "What's wrong with my cluster?" Let the AI guide you to specific issues.
- **Use descriptive problem statements**: Provide context about symptoms that you observe for better AI analysis.
- **Review AI recommendations carefully**: Understand the suggested solutions before you implement them.
- **Use historical analysis**: Ask about patterns and trends in cluster behavior over time.
- **Provide feedback**: Help improve the AI by providing feedback on the accuracy and usefulness of diagnostic responses.
- **Use alongside traditional monitoring**: Complement AI insights with Azure Monitor and other observability tools.

## Security considerations

Keep the following security considerations in mind when you use the agentic CLI for AKS:

### General security practices

- Follow the principle of least privilege when configuring access permissions.
- Review AI recommendations carefully before implementing suggested solutions.
- Audit command usage through Azure activity logs and cluster audit logs.
- Ensure your LLM API keys are stored securely and rotated regularly.

### Client mode security

- Ensure your local Azure CLI credentials are properly secured and up to date.
- Use secure Docker configurations and keep Docker images updated.
- Be mindful of local credential storage and access permissions.

### Cluster mode security

- Configure proper Kubernetes RBAC permissions for the service account.
- Enable workload identity for secure Azure resource access.
- Consider implementing Azure RBAC integration for enhanced security controls.
- Use network policies to control agent pod communication if necessary.
- Regular review and rotation of workload identity credentials.