---
layout: Conceptual
title: Cluster extensions for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/cluster-extensions
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
description: Learn how to deploy and manage the lifecycle of cluster extensions on Azure Kubernetes Service (AKS).
ms.date: 2025-09-09T00:00:00.0000000Z
ms.topic: overview
ms.subservice: aks-developer
author: schaffererin
ms.author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: b2ae50bb-5c14-bb22-6361-c9f1036a127c
document_version_independent_id: 2b39e5c7-6fef-47c3-3c94-67ad6a16f692
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/cluster-extensions.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/cluster-extensions
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/cluster-extensions.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 773fa6f6-5d35-e0ed-f678-bdcce3d64223
---

# Cluster extensions for Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Cluster extensions provide an Azure Resource Manager driven experience for installation and lifecycle management of services like Azure Machine Learning or Kubernetes applications on an AKS cluster. This feature enables:

- Azure Resource Manager-based deployment of extensions, including at-scale deployments across AKS clusters.
- Lifecycle management of the extension (Update, Delete) from Azure Resource Manager.

## Categories of cluster extensions

There are two categories of cluster extensions, *Core* and *Standard* that can be deployed onto AKS clusters.

### Core extensions

Core Kubernetes extensions have broader region availability, a more integrated AKS experience, and release alignment to AKS version releases. Azure Backup and Azure Monitoring for Containers are core extensions.

#### AKS native experience

Core extensions can be managed using `az aks` CLI command.

```azurecli
az aks extension create \
  --name <core extension name> \
  --extension-type <type> \
  --cluster-name <name> \
  --resource-group <group>
```

For more information about the commands, see [`az aks`](/en-us/cli/azure/aks).

#### Release policy

Minor and major upgrades of core extensions occur alongside AKS minor and major version updates to avoid introducing breaking changes and provide better reliability.

### Add-on to core extension migration

[Azure Monitor](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-overview) services, including [Container Insights](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=cli), [Managed Prometheus](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=cli), and [Application Insights](/en-us/azure/azure-monitor/containers/kubernetes-codeless?tabs=portal) are transitioning to a cluster extension based backend model. This change updates AKS monitoring [add-ons](/en-us/azure/aks/integrations) to an extension‑based management model, with no change to functionality or user experience.

- This backend migration is nondisruptive and doesn't change user experience or require customer action.
- There's no impact to workloads, data collection, or monitoring functionality.
- Azure CLI, Azure portal, and all client experiences continue to work as expected.

Note

- **Azure policy restrictions:** Custom Azure policies that block creation or updates to the [cluster extensions resource type](/en-us/rest/api/kubernetesconfiguration/extensions/extensions/create) must be updated or exempted.
- **Azure resource locks:** Azure resource locks can block management of [cluster extensions resource type](/en-us/rest/api/kubernetesconfiguration/extensions/extensions/create).

Refer to the [troubleshooting](https://aka.ms/k8s-extensions-tsg) documentation for mitigation details.

### Standard extensions

For information about the other cluster extensions, see the table in [Currently available extensions](cluster-extensions#currently-available-extensions) and the [Kubernetes apps](deploy-marketplace) deployed via Azure Marketplace are of the Standard Extension type.

Standard extensions can be managed using the `az k8s-extension` CLI command. For more information, see [Deploy and manage cluster extensions by using Azure CLI](deploy-extensions-az-cli).

```azurecli
az k8s-extension create \
  --name <standard extension name> \
  --extension-type <extension-type> \
  --scope cluster \
  --cluster-name <clusterName> \
  --resource-group <resourceGroupName> \
  --cluster-type managedClusters
```

## Cluster extension requirements

The cluster extensions platform is supported in all regions where AKS is deployed. Although the platform is available in all regions, check the region availability for individual extensions.

Important

Ensure that your AKS cluster is created with a managed identity, as cluster extensions don't work with service principal-based clusters.

For new clusters created with `az aks create`, managed identity is configured by default. For existing service principal-based clusters that need to be switched over to managed identity, it can be enabled by running `az aks update` with the `--enable-managed-identity` flag. For more information, see [Use managed identity](use-managed-identity).

Note

If you enabled [Microsoft Entra pod-managed identity](use-azure-ad-pod-identity) on your AKS cluster or are considering implementing it, we recommend you first review [Workload identity overview](workload-identity-overview) to understand our recommendations and options to set up your cluster to use a Microsoft Entra Workload ID (preview). This authentication method replaces pod-managed identity (preview), which integrates with the Kubernetes native capabilities to federate with any external identity providers. The open source Microsoft Entra pod-managed identity (preview) in Azure Kubernetes Service was deprecated as of October 24, 2022.

## Currently available extensions

Extension support for security, identity, networking, and deployment readiness capabilities varies by extension. The following table provides the current support status for each capability. Use it to determine whether an extension meets your organization's operational and governance requirements.

- Federal Information Processing Standard (FIPS) 140-3 is a US government standard that defines minimum security requirements for cryptographic modules in information technology products and systems.
- [Workload Identity](workload-identity-overview) is essential for secure identity management and IMDS restriction, to protect against credential theft.
- [Private Link](/en-us/azure/aks/concepts-network-isolated#how-a-network-isolated-cluster-works%E2%80%8B) is critical for network isolation, preventing unauthorized access and allowing extensions to function in Network Isolated AKS Clusters.​
- [Deployment Safeguards](/en-us/azure/aks/deployment-safeguards) enforce best practices on an Azure Kubernetes Service (AKS) cluster.​
- [Pod Security Standards (PSS)](https://kubernetes.io/docs/concepts/security/pod-security-standards/) define three different policies to broadly cover the security spectrum. PSS-Baseline provides a minimally restrictive policy which prevents known privilege escalations.

### Legend

| Symbol | Meaning |
| --- | --- |
| ✅ | Supported |
| ❌ | Not Supported |
| N/R | Not Required |

### Extension capability matrix

| Extension | Description | PSS - Baseline | FIPS | Deployment Safeguards | Workload Identity | Private Link |
| --- | --- | --- | --- | --- | --- | --- |
| [Azure App Configuration](azure-app-configuration-quickstart) | Centralized management of application settings and feature flags. | ✅ | ❌ | ✅ | ✅ | ✅ |
| [Kueue](/en-us/azure/aks/kueue-overview?pivots=extension) | Managed job queuing, prioritization, and resource-aware workload admission for batch and AI workloads on AKS. | ✅ | ❌ | ❌ | ✅ | ✅ |
| [Azure Machine Learning](/en-us/azure/machine-learning/how-to-attach-kubernetes-anywhere) | Train, deploy, and manage machine learning workloads on AKS. | ❌ | ❌ | ❌ | ❌ | ✅ |
| [Managed KubeRay (preview)](kuberay-overview) | Install and manage the KubeRay operator for Ray workloads on AKS. | ✅ | ❌ | ✅ | N/R | ❌ |
| [Dapr](dapr) | Event-driven application runtime for cloud and edge workloads. | ✅ | ❌ | ❌ | ✅ | ✅ |
| [Azure Backup for AKS](/en-us/azure/backup/azure-kubernetes-service-backup-overview) | Backup and restore protection for persistent volumes. **(Core Extension)** | ✅ | ❌ | ✅ | ✅ | ✅ |
| [Flux (GitOps)](/en-us/azure/azure-arc/kubernetes/conceptual-gitops-flux2) | GitOps-based configuration and application deployment management. | ✅ | ❌ | ✅ | ❌ | ✅ |
| [Azure Container Storage](/en-us/azure/storage/container-storage/container-storage-introduction) | Persistent storage for AKS workloads. | ✅ | ❌ | ✅ | N/R | ❌ |
| Service Connector | Simplifies secure connectivity between AKS workloads and Azure services. | ✅ | ❌ | ✅ | ✅ | N/R |
| [Virtual Nodes v2 on Azure Container Instances (preview)](virtual-nodes-v2) | Use Virtual Nodes v2 to burst AKS workloads to serverless compute on Azure Container Instances (ACI). | N/R | ❌ | ❌ | ✅ | ✅ |
| [Azure Monitor - Container Insights](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=azure-cli#enable-container-insights-and-logging-on-an-aks-cluster) | Log collection and monitoring for AKS clusters and containers. **(Core Extension)** | N/R | ❌ | ❌ | N/R | ✅ |
| [Azure Monitor - Prometheus](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=azure-cli#enable-prometheus-metrics-on-an-aks-cluster) | Prometheus-compatible metrics collection for AKS. **(Core Extension)** | ✅ | ❌ | ✅ | N/R | ✅ |
| [Azure Monitor - App Monitoring](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=azure-cli#enable-container-insights-and-logging-on-an-aks-cluster) | Application performance monitoring and telemetry collection. **(Core Extension)** | N/R | ❌ | ❌ | N/R | ✅ |
| [Argo CD](/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-argocd) | GitOps-based continuous delivery for Kubernetes applications. | ✅ | ❌ | ✅ | ✅ | ❌ |

You can also [select and deploy Kubernetes applications available through Marketplace](deploy-marketplace).

Note

Cluster extensions provide a platform for different extensions to be installed and managed on an AKS cluster. If you're facing issues while using any of these extensions, open a support ticket with the respective service.

Note

Not every capability is relevant to every extension. Extensions marked as Not Required continue to follow applicable AKS security requirements. The status simply indicates the capability isn't needed for the extension's intended functionality.