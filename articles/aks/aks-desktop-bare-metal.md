---
layout: Conceptual
title: Connect to and manage AKS on bare metal clusters with AKS desktop (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-desktop-bare-metal
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
description: Learn how to connect to AKS on bare metal clusters with AKS desktop, manage and troubleshoot workloads, and resolve access or proxy issues.
ms.subservice: aks-developer
author: willspacecase
ms.topic: how-to
ms.date: 2026-11-05T00:00:00.0000000Z
ms.author: danis
ai-usage: ai-assisted
locale: en-us
document_id: 9f4f0adf-ea6a-a6ef-0517-27465a273a55
document_version_independent_id: a6cb30f2-5a36-a588-756d-53c586136a21
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-desktop-bare-metal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/aks-desktop-bare-metal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-desktop-bare-metal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 9b3263ac-2af3-7427-f1eb-e45f5515dff7
---

# Connect to and manage AKS on bare metal clusters with AKS desktop (preview) - Azure Kubernetes Service | Microsoft Learn

**Applies to:** AKS desktop and AKS on bare metal clusters.

Important

AKS on bare metal support in AKS desktop is currently in preview. Preview features are provided without a service-level agreement and aren't recommended for production workloads. Certain features might not be supported or might have constrained capabilities.

To report a problem or suggest an improvement, [file an AKS desktop issue](https://github.com/Azure/aks-desktop/issues/new/choose).

AKS desktop gives developers and operators a consistent experience across cloud, hybrid, and edge clusters. For AKS on bare metal, you can register a cluster with guided steps, browse Kubernetes resources, review access, manage existing applications, and troubleshoot workloads without running connection commands or exposing the Kubernetes API server through an inbound firewall port.

AKS desktop uses [Azure Arc cluster connect](/en-us/azure/azure-arc/kubernetes/cluster-connect) to reach the Kubernetes API server through an outbound cluster connection.

This preview capability requires AKS desktop v0.11.0 or later. To verify your installed version, see [Check your installed version](aks-desktop-overview#check-your-installed-version). AKS on bare metal clusters are labeled **AKS Hybrid & Edge** in the application. This article uses *AKS on bare metal* for the product and the UI label when you need to identify an option in AKS desktop.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## What you learn

You learn how to:

- Add an AKS on bare metal cluster to AKS desktop.
- Browse cluster resources and manage existing applications.
- Review access information for clusters that use Kubernetes RBAC or Azure RBAC.
- Restart the cluster connect proxy when troubleshooting.

## Prerequisites

Before you begin, ensure that you have:

- An Azure account with access to the subscription and resource group that contain the AKS on bare metal cluster.
- An existing online AKS on bare metal cluster. [Upgrade the Azure Arc agents](/en-us/azure/azure-arc/kubernetes/agent-upgrade#manually-upgrade-agents) to the latest supported version.
- Azure CLI with the latest `connectedk8s` extension. Install the extension with [`az extension add --name connectedk8s`](/en-us/cli/azure/extension#az-extension-add), or update it with [`az extension update --name connectedk8s`](/en-us/cli/azure/extension#az-extension-update).
- Outbound network access for the [Azure Arc endpoints required by cluster connect](/en-us/azure/azure-arc/kubernetes/network-requirements). Cluster connect doesn't require an inbound firewall port.
- Permission to retrieve a cluster connect-based kubeconfig. The **Azure Arc Enabled Kubernetes Cluster User Role** provides this permission.
- Kubernetes API permissions appropriate for your tasks. For native Kubernetes RBAC, an administrator must create the required RoleBinding or ClusterRoleBinding. For Azure RBAC, assign an appropriate **Azure Arc Kubernetes Viewer**, **Azure Arc Kubernetes Writer**, **Azure Arc Kubernetes Admin**, or **Azure Arc Kubernetes Cluster Admin** role at the cluster or namespace scope.
- A nonproduction cluster for initial validation and troubleshooting.

## Understand how AKS desktop connects

Azure Arc cluster connect provides secure access to an Arc-enabled Kubernetes API server through an outbound connection from the cluster. When you open a saved AKS on bare metal cluster, AKS desktop starts and verifies the local cluster connect proxy before it loads cluster resources.

The proxy uses your current Azure sign-in and the authorization model configured for the cluster. AKS desktop doesn't bypass Azure RBAC or Kubernetes RBAC. If your identity can't perform an operation, AKS desktop displays an authorization error instead of requesting broader access automatically.

The **Start AKS Hybrid & Edge proxy** command is a troubleshooting action. You shouldn't need to run it during the normal connection flow.

## Add an AKS on bare metal cluster

1. Open AKS desktop and sign in with the Microsoft Entra account that has access to the cluster.
2. On the sign-in page, select **Add Cluster from Azure**.
3. Select the Azure subscription and the AKS on bare metal cluster. AKS desktop labels an AKS on bare metal cluster as **AKS Hybrid & Edge** in the cluster list.

    ![Screenshot of the Register AKS Cluster dialog in AKS desktop showing AKS on bare metal clusters labeled AKS Hybrid and Edge.](media/aks-desktop-app/aks-desktop-register-bare-metal-cluster.png)
4. Review the displayed cluster and access information, and then select **Register Cluster**.
5. From **All Clusters**, select the cluster you added. AKS desktop starts the cluster connect proxy automatically and waits for the connection before loading the cluster view.
6. Confirm that the cluster overview and Kubernetes resources load for the selected cluster.

**Expected result:** The cluster opens without requiring a direct inbound network path to the Kubernetes API server. Resource data is scoped to the selected cluster and reflects the permissions of the signed-in identity.

After registration, the cluster appears alongside your other clusters in **All Clusters**. Once AKS desktop establishes the cluster connect proxy, you can use the [standard cluster resource experience](aks-desktop-cluster-view) to browse resources across namespaces, inspect workload configuration and logs, view resource relationships in **Map**, and troubleshoot workloads. Available actions and resources continue to reflect the cluster's capabilities and your assigned permissions.

To manage an existing application, [import its namespace as a Project](aks-desktop-cluster-view#import-an-existing-namespace-as-a-project).

![Screenshot of the standard AKS desktop Map view for a connected AKS on bare metal cluster, showing Kubernetes resources grouped by namespace.](media/aks-desktop-app/aks-desktop-bare-metal-map.png)

## Restart the proxy for troubleshooting

If AKS desktop can't complete automatic proxy setup, use the manual proxy command to retry the connection.

1. Confirm that you're signed in to the correct Azure tenant and subscription.
2. Open **All Clusters**, select the action menu to the far right of your cluster, and then select **Start AKS Hybrid & Edge proxy**.
3. Wait for the proxy status to report **AKS Hybrid & Edge proxy is running**, and then reopen the cluster.
4. If the proxy still fails, record the error and follow the troubleshooting guidance in the next section.

## Troubleshoot common issues

### The cluster doesn't connect

- Confirm that the cluster is connected to Azure Arc and that its agents are current and healthy.
- Confirm outbound connectivity to all Azure Arc endpoints required for cluster connect.
- Confirm that the `clusterconnect-agent` pod and the other pods in the `azure-arc` namespace are running.
- Sign out and back in if the Azure CLI or AKS desktop session expired, and then confirm the tenant and subscription.
- If you troubleshoot outside AKS desktop, update Azure CLI and the `connectedk8s` extension, and then run [`az connectedk8s proxy`](/en-us/cli/azure/connectedk8s#az-connectedk8s-proxy) with the correct cluster and resource group. For more information, see [Troubleshoot Azure Arc-enabled Kubernetes clusters](/en-us/azure/azure-arc/kubernetes/troubleshooting).

### Access is denied or the Access tab is incomplete

- Verify that your identity has permission to retrieve a cluster connect-based kubeconfig. The **Azure Arc Enabled Kubernetes Cluster User Role** provides this permission, regardless of whether the cluster uses native Kubernetes RBAC or Azure RBAC for Kubernetes authorization.
- Determine which Kubernetes authorization model the cluster uses:
    - For native Kubernetes RBAC, verify that your Microsoft Entra identity has the RoleBinding or ClusterRoleBinding required for the operation.
    - For Azure RBAC, verify that your identity has an appropriate Azure Arc Kubernetes data-plane role at the cluster or namespace scope required for the operation.
- Allow time for new Azure role assignments to propagate and then reopen the cluster.

## Security recommendations

- Grant the least-privileged Azure and Kubernetes roles required for each task. Avoid using `cluster-admin` for routine access.
- Scope Azure Arc Kubernetes role assignments to a namespace when cluster-wide access isn't required.
- Use cluster connect instead of exposing the Kubernetes API server through an inbound firewall rule.
- Don't include kubeconfig content, service account tokens, or other credentials in screenshots or support logs.