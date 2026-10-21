---
layout: Conceptual
title: Azure Arc-enabled Kubernetes agent overview - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-agent-overview
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
ms.date: 2026-03-30T00:00:00.0000000Z
ms.topic: concept-article
description: Learn about the Azure Arc agents deployed on the Kubernetes clusters when connecting them to Azure Arc.
locale: en-us
document_id: b4a46de8-2fe0-8fa6-8585-4a498ce45568
document_version_independent_id: 9bcd84c6-2027-c0d0-87dd-0e1249a2c39d
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/conceptual-agent-overview.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/conceptual-agent-overview
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/conceptual-agent-overview.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d2970637-9a0c-380a-50db-0a4b5fd86cc4
---

# Azure Arc-enabled Kubernetes agent overview - Azure Arc | Microsoft Learn

[Azure Arc-enabled Kubernetes](overview) provides a centralized, consistent control plane to manage policy, governance, and security across Kubernetes clusters in different environments.

You deploy Azure Arc agents on Kubernetes clusters when you [connect them to Azure Arc](quickstart-connect-cluster). This article provides an overview of these agents, along with high-level steps for deploying them to your cluster and moving connected resources across Azure regions.

## Deploy agents to your cluster

Most on-premises datacenters enforce strict network rules that prevent inbound communication on the network boundary firewall. Azure Arc-enabled Kubernetes works with these restrictions by not requiring inbound ports on the firewall. Azure Arc agents require outbound communication to a [set list of network endpoints](network-requirements).

This diagram provides a high-level view of Azure Arc components. Kubernetes clusters in on-premises datacenters or different clouds are connected to Azure through the Azure Arc agents. This connection allows you to manage the clusters in Azure by using management tools and Azure services. You can also access the clusters through offline management tools.

[![Diagram showing an architectural overview of the Azure Arc-enabled Kubernetes agents.](media/architectural-overview.png)](media/architectural-overview.png#lightbox)

The following high-level steps are involved in [connecting a Kubernetes cluster to Azure Arc](quickstart-connect-cluster):

1. Create a Kubernetes cluster on your choice of infrastructure (VMware vSphere, Amazon Web Services, Google Cloud Platform, or any Cloud Native Computing Foundation (CNCF) certified Kubernetes distribution). The cluster must already exist before you connect it to Azure Arc.
2. Start the Azure Arc registration for your cluster. This process deploys the agent Helm chart on the cluster. After that, the cluster nodes initiate an outbound communication to the [Microsoft Artifact Registry](https://github.com/microsoft/containerregistry), pulling the images needed to create the following agents in the `azure-arc` namespace:

    | Agent | Description |
    | --- | --- |
    | `deployment.apps/clusteridentityoperator` | Azure Arc-enabled Kubernetes currently supports only [system assigned identities](/en-us/azure/active-directory/managed-identities-azure-resources/overview). `clusteridentityoperator` initiates the first outbound communication. This first communication fetches the Managed Service Identity (MSI) certificate used by other agents for communication with Azure. |
    | `deployment.apps/config-agent` | Watches the connected cluster for source control configuration resources applied on the cluster. Updates the compliance state. |
    | `deployment.apps/controller-manager` | An operator of operators that orchestrates interactions between Azure Arc components. |
    | `deployment.apps/metrics-agent` | Collects metrics of other Arc agents to verify optimal performance. |
    | `deployment.apps/cluster-metadata-operator` | Gathers cluster metadata, including cluster version, node count, and Azure Arc agent version. |
    | `deployment.apps/resource-sync-agent` | Syncs the above-mentioned cluster metadata to Azure. |
    | `deployment.apps/flux-logs-agent` | Collects logs from the Flux operators deployed as a part of [source control configuration](conceptual-gitops-flux2). |
    | `deployment.apps/extension-manager` | Installs and manages lifecycle of extension Helm charts. |
    | `deployment.apps/kube-aad-proxy` | Used for authentication of requests sent to the cluster using cluster connect. |
    | `deployment.apps/clusterconnect-agent` | Reverse proxy agent that enables the cluster connect feature to provide access to `apiserver` of the cluster. Optional component deployed only if the [cluster connect](conceptual-cluster-connect) feature is enabled. |
    | `deployment.apps/guard` | Authentication and authorization webhook server used for Microsoft Entra RBAC. Optional component deployed only if [Azure RBAC](conceptual-azure-rbac) is enabled on the cluster. |
3. When all the Azure Arc-enabled Kubernetes agent pods are in `Running` state, verify that your cluster is connected to Azure Arc. You should see:

    - An Azure Arc-enabled Kubernetes `connectedClusters` resource in [Azure Resource Manager](/en-us/azure/azure-resource-manager/management/overview). Azure tracks this resource as a projection of the customer-managed Kubernetes cluster, rather than tracking the actual Kubernetes cluster itself.
    - Cluster metadata (such as Kubernetes version, agent version, and number of nodes) appearing on the Azure Arc-enabled Kubernetes resource as metadata.

For more information on deploying the agents to a cluster, see [Quickstart: Connect an existing Kubernetes cluster to Azure Arc](quickstart-connect-cluster).

## Move Arc-enabled Kubernetes clusters across Azure regions

In some circumstances, you might want to move your Arc-enabled Kubernetes clusters to another Azure region. For example, you might want to deploy features or services that are only available in specific regions, or you might need to change regions due to internal governance requirements or capacity planning considerations.

When you move a connected cluster to a new region, you delete the `connectedClusters` Azure Resource Manager resource in the source region, then deploy the agents to recreate the `connectedClusters` resource in the target region. For source control configurations, [Flux configurations](conceptual-gitops-flux2), and [extensions](conceptual-extensions) within the cluster, you'll need to save details about the resources, then recreate the child resources in the new cluster resource.

Before you begin, ensure that Azure Arc-enabled Kubernetes resources (`Microsoft.Kubernetes/connectedClusters`) and any needed Azure Arc-enabled Kubernetes configuration resources (`Microsoft.KubernetesConfiguration/SourceControlConfigurations`, `Microsoft.KubernetesConfiguration/Extensions`, `Microsoft.KubernetesConfiguration/FluxConfigurations`) are [supported in the target region](https://azure.microsoft.com/explore/global-infrastructure/products-by-region/table).

1. Do a LIST to get all configuration resources in the source cluster (the cluster to be moved) and save the response body:

    - [Microsoft.KubernetesConfiguration/SourceControlConfigurations](/en-us/cli/azure/k8s-configuration?view=azure-cli-latest&amp;preserve-view=true#az-k8sconfiguration-list)
    - [Microsoft.KubernetesConfiguration/Extensions](/en-us/cli/azure/k8s-extension?view=azure-cli-latest&amp;preserve-view=true#az-k8s-extension-list)
    - [Microsoft.KubernetesConfiguration/FluxConfigurations](/en-us/cli/azure/k8s-configuration/flux?view=azure-cli-latest&amp;preserve-view=true#az-k8s-configuration-flux-list)

    Note

    LIST/GET of configuration resources don't return `ConfigurationProtectedSettings`. For such cases, the only option is to save the original request body and reuse them while creating the resources in the new region.
2. [Delete](quickstart-connect-cluster?tabs=azure-cli#clean-up-resources) the previous Arc deployment from the underlying Kubernetes cluster.
3. With network access to the underlying Kubernetes cluster, [connect the cluster](quickstart-connect-cluster#connect-an-existing-kubernetes-cluster) in the new region.
4. Verify that the Arc connected cluster is successfully running in the new region:

    1. Run `az connectedk8s show -n <connected-cluster-name> -g <resource-group>` and ensure the `connectivityStatus` value is `Connected`.
    2. Run `kubectl get deployments,pods -n azure-arc` to [verify that all agents are successfully deployed](quickstart-connect-cluster#view-azure-arc-agents-for-kubernetes).
5. Using the response body you saved, recreate each of the configuration resources obtained in the LIST command from the source cluster on the target cluster. To confirm, compare the results from a LIST of all configuration resources in the target cluster with the original LIST response from the source cluster.