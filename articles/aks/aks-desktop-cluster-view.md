---
layout: Conceptual
title: Connect to AKS clusters, view resources, and manage applications using AKS desktop - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-desktop-cluster-view
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
description: Learn how to connect to Azure Kubernetes Service (AKS) clusters, view cluster resources, deploy new applications, and manage existing applications using AKS desktop.
ms.subservice: aks-developer
author: danielsollondon
ms.reviewer: schaffererin
ms.topic: how-to
ms.date: 2026-06-23T00:00:00.0000000Z
ms.author: danis
ai-usage: ai-assisted
locale: en-us
document_id: e8261126-dd2a-bfbe-0a09-38a88256ea8c
document_version_independent_id: 75103cbf-fce9-d70d-3d5e-eb3a5b511913
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-desktop-cluster-view.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-desktop-cluster-view
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-desktop-cluster-view.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a80928ae-803e-d8d3-63ca-461acee9f018
---

# Connect to AKS clusters, view resources, and manage applications using AKS desktop - Azure Kubernetes Service | Microsoft Learn

AKS desktop is an application-focused developer local desktop UI tool for Azure Kubernetes Service (AKS) built on [Headlamp](https://headlamp.dev/). It lets Kubernetes operators and developers connect to clusters, explore all running resources, deploy new applications, and manage or troubleshoot existing workloads from dashboards without writing Kubernetes manifests or running kubectl commands.

This article covers how to:

- Connect to an AKS cluster using AKS desktop.
- View cluster resources across all namespaces and resource types.
- Deploy new applications using guided workflows.
- Import and manage existing applications.
- Observe and troubleshoot applications using logs, metrics, and insights.

## Prerequisites

- [AKS desktop](aks-desktop-overview) installed. AKS desktop supports Windows, Linux, and macOS.
- An existing AKS cluster. The cluster must use Microsoft Entra ID authentication. For the best experience, use an [AKS Automatic cluster](intro-aks-automatic). For Standard cluster requirements, see [AKS Standard clusters for AKS desktop](aks-desktop-install-cluster-setup#aks-standard-clusters).
- The [Azure Kubernetes Service RBAC Cluster Admin role](manage-azure-rbac#aks-built-in-roles) or equivalent permissions on the target cluster.

## Connect to an AKS cluster

Before you can view resources or manage applications, you must register your AKS cluster with AKS desktop.

1. Sign in to AKS desktop using the same account that has access to your AKS cluster.
2. Select **Add from Azure Subscription**.
3. If you have more than one subscription, enter or select the name of your Azure subscription.
4. Select your cluster from the list, and then select **Register Cluster**.

    ![A video demonstrating how to add a cluster to the AKS desktop app.](media/aks-desktop-app/aks-desktop-app-add-cluster.gif)

Once registered, you will see a list of clusters, click on one and your cluster appears in the left-hand navigation. You can add multiple clusters and switch between them at any time.

Tip

To add additional clusters later, select **Add** in the cluster list and repeat the steps in this section. You can also add non-AKS clusters (for example: on premise Kubernetes or cloud vendor managed Kubernetes). When adding these clusters, you need the kubeconfig for the cluster and networking connectivity.

![A video demonstrating how to add additional clusters to AKS desktop.](media/aks-desktop-app/aks-desktop-app-add-additional-clusters.gif)

## View cluster resources

AKS desktop gives you visibility into all Kubernetes resources running in your cluster across all namespaces and resource types. From the left-hand navigation, select your registered cluster to expand the resource tree. You can browse the following resource categories:

| Category | Description |
| --- | --- |
| **Map** | Visualize the relationships between all resources in your cluster, showing how components depend on and interact with each other. |
| **Workloads** | View deployments, pods, replica sets, stateful sets, daemon sets, jobs, and cron jobs across all namespaces. |
| **Storage** | View persistent volumes, persistent volume claims, and storage classes configured in your cluster. |
| **Network** | View services, ingresses, and network policies that control traffic flow between pods and external endpoints. |
| **Gateway** (beta) | View Kubernetes Gateway API resources for advanced ingress and load balancing configurations. |
| **Security** | View pod security policies, role-based access control (RBAC) settings, and network policies. |
| **Configuration** | View ConfigMaps and secrets that store configuration and sensitive data for your applications. |
| **Custom Resources** | View any custom resource definitions (CRDs) and custom resources deployed to the cluster. |

![Screenshot that shows AKS cluster details overview.](media/aks-desktop-app/aks-desktop-cluster-details.png)

Note

AKS desktop shows the full cluster resource tree to users with cluster admin access. Access to individual namespaces and Projects is governed by Kubernetes RBAC roles. For more information, see [Set up permissions for AKS desktop](aks-desktop-permissions).

### View workload details

Select any workload resource to view its details, including:

- Container status, restarts, and readiness probes.
- Events related to that resource.
- Labels and annotations.
- The live YAML definition.

![Screenshot of the workload Resources view in AKS desktop.](media/aks-desktop-app/aks-desktop-app-resources.png)

## Deploy new applications

AKS desktop uses [Projects](aks-desktop-projects) to group everything an application needs, such as deployments, services, and configuration into a single, manageable unit. To deploy a new application, you first create a Project, and then deploy one or more applications into it.

For a complete step-by-step deployment walkthrough, including creating the cluster, building a container image, and deploying the application, see [Quickstart: Deploy and manage applications using AKS desktop](aks-desktop-quickstart-auto).

The following images show the key steps in the AKS desktop deployment experience:

Create a new Project to group your application resources:

![Screenshot of creating a new Project in AKS desktop.](media/aks-desktop-app/aks-desktop-new-project.png)

Choose a deployment source — container image, Kubernetes YAML, or Helm chart:

![Screenshot of selecting a deployment source in AKS desktop.](media/aks-desktop-app/aks-desktop-select-app-src.png)

Review and confirm the deployment, then monitor resource status from the Project overview:

[![Screenshot of the Project overview screen in AKS desktop after deployment.](media/aks-desktop-app/aks-desktop-app-project-overview.png)](media/aks-desktop-app/aks-desktop-app-project-overview.png#lightbox)

## Manage existing applications

You don't need to deploy a new application to benefit from AKS desktop. If you have workloads already running in the cluster, you can import the namespace into AKS desktop as a Project and manage it from there.

### Import an existing namespace as a Project

1. In AKS desktop, navigate to the **Projects** tab.
2. Select **Create a New Managed Project** or **Import existing namespace**.
3. Select **Use an existing namespace**, then choose the namespace where your application is running.

AKS desktop adds labels to the namespace and exposes it as a Project. Your existing workloads continue running without interruption.

Note

For more information on namespace labeling and how access is managed for imported Projects, see [Namespace labeling and access for Projects in AKS desktop](aks-desktop-projects#namespace-labeling-and-access-for-projects).

### Observe and troubleshoot application health

From the Project overview screen, you can monitor the health and performance of any application managed by AKS desktop:

- **Resources**: View all Kubernetes resources deployed in the Project, including workloads, services, and configuration.
- **Map**: Visualize how resources interact and depend on each other.
- **Logs**: Stream pod logs for real-time debugging.
- **Metrics**: View CPU and memory consumption for application components.
- **Scaling**: View current replica counts and configure Horizontal Pod Autoscaler (HPA) settings.

![Screenshot of the Metrics view in AKS desktop showing CPU and memory usage.](media/aks-desktop-app/aks-desktop-app-metrics.png)