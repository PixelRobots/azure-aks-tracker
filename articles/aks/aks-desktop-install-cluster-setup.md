---
layout: Conceptual
title: Configure an Azure Kubernetes Service (AKS) Cluster for AKS Desktop - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-desktop-install-cluster-setup
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
description: Learn how to set up a compatible Azure Kubernetes Service (AKS) cluster for AKS desktop.
ms.subservice: aks-developer
ms.reviewer: schaffererin
author: danielsollondon
ms.topic: how-to
ms.date: 2026-04-16T00:00:00.0000000Z
ms.author: danis
locale: en-us
document_id: 9e922c06-a603-f6a0-2f7b-18f9cfcb2bba
document_version_independent_id: 5ee7cae7-0b32-14bc-bd51-0dfaaf56d71b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-desktop-install-cluster-setup.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/aks-desktop-install-cluster-setup
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-desktop-install-cluster-setup.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 8fcb895d-9c85-7672-2a01-900f21e98048
---

# Configure an Azure Kubernetes Service (AKS) Cluster for AKS Desktop - Azure Kubernetes Service | Microsoft Learn

AKS desktop supports Standard and Automatic (recommended) AKS clusters. However, there are some differences in setup and features available between the two tiers. This article covers recommended Azure Kubernetes Service (AKS) cluster configurations and add-ons for AKS desktop.

Tip

If you want to get started with AKS desktop as quickly as possible, we recommend:

- Creating an AKS Automatic cluster, which has all required features pre-enabled.
- Attaching an Azure Container Registry (ACR) with your application images.
- [Installing the latest version of AKS desktop](https://github.com/Azure/aks-desktop/releases).

## Prerequisites

- An Azure subscription. If you don't have one, create a [free Azure account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Azure CLI version 2.64.0 or later. Check your version using the [`az --version`](/en-us/cli/azure/reference-index#az-version) command. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The `aks-preview` Azure CLI extension. Install it using the `az extension add --name aks-preview` command. For more information, see [Manage Azure CLI extensions](/en-us/cli/azure/azure-cli-extensions-overview).
- Permissions to create resources in Azure (Contributor role or Owner role on the target resource group).
- **Azure Kubernetes Service RBAC Cluster Admin** role on the target AKS cluster to grant users access to Projects.

## AKS Automatic clusters

[AKS Automatic clusters](intro-aks-automatic) are the easiest way to get started with AKS desktop. They come with all required features pre-enabled, so you can start using AKS desktop right away without needing to configure your cluster. With an AKS Automatic cluster, you get a streamlined experience for creating Projects, deploying applications, and managing resources in AKS desktop.

See the [official feature comparison](intro-aks-automatic#aks-automatic-and-standard-feature-comparison) for a complete breakdown of differences between AKS Automatic and AKS Standard.

If you have an existing AKS Automatic cluster, you can [deploy an application](aks-desktop-app) or import an existing namespace that includes your application. If you want to create a new AKS Automatic cluster and get started with AKS desktop, see [Quickstart: Deploy and managed applications using AKS desktop](aks-desktop-quickstart-auto).

## AKS Standard clusters

You can use AKS desktop with Standard AKS clusters, but you must ensure certain features are enabled for the best experience. Some features are required for basic functionality, while others are optional but recommended for full AKS desktop capabilities.

### Minimum requirements for AKS Standard clusters

The following table outlines the minimum required features for an AKS Standard cluster to be compatible with AKS desktop:

| Requirement | Why it's needed | How to check | How to enable |
| --- | --- | --- | --- |
| **Microsoft Entra ID (AAD) authentication** | Required for Azure RBAC and managed namespace role assignments. Clusters without Entra ID authentication enabled don't appear in the AKS desktop cluster picker. | `az aks show --resource-group <resource-group-name> --name <cluster-name> --query aadProfile` (Must not be `null`) | Must be set at cluster creation using `--enable-aad --enable-azure-rbac` |
| **Azure RBAC for Kubernetes authorization** | Required for assigning users to Projects with Admin, Writer, or Reader roles. | `az aks show --resource-group <resource-group-name> --name <cluster-name> --query aadProfile.enableAzureRbac` (Must be `true`) | Must be set at cluster creation using `--enable-azure-rbac` |

### Recommended configuration for AKS Standard clusters

The following table outlines recommended features for an AKS Standard cluster to unlock the full potential of AKS desktop:

| Feature | What it enables in AKS desktop | Can be enabled after cluster creation? | How to enable |
| --- | --- | --- | --- |
| **Network policy engine** (Cilium recommended) | Ingress and egress network policies on managed namespaces. Without a network policy engine, policies are silently ignored. | **No**. Must be set at cluster creation. | `--network-plugin azure --network-policy cilium` |
| **Azure Monitor Metrics** (Managed Prometheus) | Metrics tab (CPU, memory, and request-rate charts) and the Scaling chart (CPU %). | Yes | `az aks update --resource-group <resource-group-name> --name <cluster-name> --enable-azure-monitor-metrics` |
| **Managed Grafana** | Visualization for metrics dashboards. | Yes | Enabled alongside Azure Monitor Metrics when using the Azure portal. When using Azure CLI, link a Grafana workspace with `--enable-azure-monitor-metrics --azure-monitor-workspace-resource-id <id>`. |
| **KEDA** | Kubernetes Event-Driven Autoscaling in the Scaling tab. | Yes | `az aks update --resource-group <resource-group-name> --name <cluster-name> --enable-keda` |
| **VPA** (Vertical Pod Autoscaler) | Vertical pod autoscaling recommendations in the Scaling tab. | Yes | `az aks update --resource-group <resource-group-name> --name <cluster-name> --enable-vpa` |

## Create a fully compatible AKS Standard cluster

The following [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command creates a new AKS Standard cluster with all recommended features enabled for AKS desktop. Make sure to replace the placeholder values with your own.

```azurecli
az aks create \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --location <location> \
  --tier standard \
  --enable-aad \
  --enable-azure-rbac \
  --network-plugin azure \
  --network-policy cilium \
  --enable-azure-monitor-metrics \
  --enable-keda \
  --enable-vpa \
  --enable-hpa \
  --generate-ssh-keys
```

If you want to attach an existing Azure Container Registry (ACR) to the cluster after creation, you can use the following [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command:

```azurecli
az aks update \
  --resource-group <resource-group-name> \
  --name <cluster-name> \
  --attach-acr <acr-name>
```

## Enable features on an existing AKS Standard cluster

There are some features you can enable after cluster creation. There are other features that you can only enable at cluster creation time. For more information, see the AKS desktop feature availability matrix.

These commands might take several minutes to complete. Each add-on might incur extra Azure costs. For more information, see [AKS pricing](https://azure.microsoft.com/pricing/details/kubernetes-service/).

### Enable Azure Monitor metrics (Managed Prometheus)

Enable Azure Monitor metrics on an existing AKS Standard cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-azure-monitor-metrics` flag. This add-on enables the Metrics tab and the Scaling chart (CPU %) in AKS desktop.

```azurecli
az aks update --resource-group <resource-group-name> --name <cluster-name> --enable-azure-monitor-metrics
```

### Enable KEDA

Enable Kubernetes Event-Driven Autoscaling (KEDA) on an existing AKS Standard cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-keda` flag. This add-on enables the Scaling tab in AKS desktop, which provides recommendations for scaling your workloads based on custom metrics.

```azurecli
az aks update --resource-group <resource-group-name> --name <cluster-name> --enable-keda
```

### Enable VPA

Enable the Vertical Pod Autoscaler (VPA) on an existing AKS Standard cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-vpa` flag. This add-on enables vertical pod autoscaling recommendations in the Scaling tab of AKS desktop, which provides insights into how to optimize resource requests and limits for your workloads.

```azurecli
az aks update --resource-group <resource-group-name> --name <cluster-name> --enable-vpa
```

## AKS desktop feature availability matrix

The following table outlines which AKS desktop features require specific cluster add-ons and whether those add-ons can be enabled after cluster creation:

| AKS desktop feature | Works without add-on? | Required add-on | Can be enabled after cluster creation? |
| --- | --- | --- | --- |
| Project creation | Yes | Azure RBAC + Entra ID | No (Creation-time only) |
| Network policies | No (Silently ignored) | Cilium, Calico, or Azure network policy | No (Creation-time only) |
| Metrics tab | No (Shows error) | Managed Prometheus | Yes |
| Scaling chart (CPU %) | No (Shows error) | Managed Prometheus | Yes |
| HPA (Horizontal scaling) | Yes | `metrics-server` (Included by default) | Yes |
| KEDA scaling | No | KEDA add-on | Yes |
| VPA scaling | No | VPA add-on | Yes |