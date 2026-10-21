---
layout: Conceptual
title: Azure Arc-enabled Kubernetes system requirements - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/system-requirements
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
ms.date: 2024-10-08T00:00:00.0000000Z
ms.topic: concept-article
ms.custom: devx-track-azurepowershell
description: Learn about the system requirements to connect Kubernetes clusters to Azure Arc.
locale: en-us
document_id: 672f6b09-6e35-235a-3c06-f296eff11ac6
document_version_independent_id: 7e4b01dc-3d33-8acd-84c7-86c083df5a76
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/system-requirements.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurepowershell,azurecli
toc_rel: toc.json
asset_id: azure-arc/kubernetes/system-requirements
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/system-requirements.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 8760f7fe-d5f0-0955-f798-66b9572ddbac
---

# Azure Arc-enabled Kubernetes system requirements - Azure Arc | Microsoft Learn

This article describes the basic requirements for [connecting a Kubernetes cluster to Azure Arc](quickstart-connect-cluster), along with system requirement information related to various Arc-enabled Kubernetes scenarios.

## Cluster requirements

Azure Arc-enabled Kubernetes works with any Cloud Native Computing Foundation (CNCF) certified Kubernetes clusters. This includes clusters running on other public cloud providers (such as GCP or AWS) and clusters running on your on-premises data center (such as VMware vSphere or Azure Local).

You must also have a [kubeconfig file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) and context pointing to your cluster.

The cluster must have at least one node with operating system and architecture type `linux/amd64` and/or `linux/arm64`.

Important

Many Arc-enabled Kubernetes features and scenarios are supported on ARM64 nodes, such as [cluster connect](cluster-connect) and [viewing Kubernetes resources in the Azure portal](kubernetes-resource-view). However, if using Azure CLI to enable these scenarios, [Azure CLI must be installed](/en-us/cli/azure/install-azure-cli) and run from an AMD64 machine. Azure RBAC on Arc-enabled Kubernetes is currently not supported on ARM64 nodes. For access to ARM64 nodes, use [Kubernetes RBAC](identity-access-overview#kubernetes-rbac-authorization).

Currently, Azure Arc-enabled Kubernetes [cluster extensions](conceptual-extensions) aren't supported on ARM64-based clusters, except for [Flux (GitOps)](conceptual-gitops-flux2). To [install and use other cluster extensions](extensions), the cluster must have at least one node of operating system and architecture type `linux/amd64`.

## Compute and memory requirements

The [Arc agents deployed on the cluster](conceptual-agent-overview) require:

- At least 850 MB of free memory
- Capacity to use approximately 7% of a single CPU

For a multi-node Kubernetes cluster environment, pods can get scheduled on different nodes.

## Management tool requirements

To connect a cluster to Azure Arc, you'll need to use either Azure CLI or Azure PowerShell.

For Azure CLI:

- [Install or upgrade Azure CLI](/en-us/cli/azure/install-azure-cli) to the latest version.
- Install the latest version of **connectedk8s** Azure CLI extension:

    ```azurecli
    az extension add --name connectedk8s
    ```

For Azure PowerShell:

- Install [Azure PowerShell version 6.6.0 or later](/en-us/powershell/azure/install-azure-powershell).
- Install the **Az.ConnectedKubernetes** PowerShell module:

    ```azurepowershell
    Install-Module -Name Az.ConnectedKubernetes
    ```

Note

When you deploy the Azure Arc agents to a cluster, Helm v. 3.6.3 will be installed in the `.azure` folder of the deployment machine. This [Helm 3](https://helm.sh/docs/) installation is only used for Azure Arc, and it doesn't remove or change any previously installed versions of Helm on the machine.

## Microsoft Entra identity requirements

To connect your cluster to Azure Arc, you must have a Microsoft Entra identity (user or service principal) which can be used to log in to [Azure CLI](/en-us/cli/azure/authenticate-azure-cli) or [Azure PowerShell](/en-us/powershell/azure/authenticate-azureps) and connect your cluster to Azure Arc.

This identity must have **Read** and **Write** permissions on the Azure Arc-enabled Kubernetes resource type (`Microsoft.Kubernetes/connectedClusters`). If connecting the cluster to an existing resource group (rather than a new one created by this identity), the identity must have **Read** permission for that resource group.

The [Kubernetes Cluster - Azure Arc Onboarding built-in role](/en-us/azure/role-based-access-control/built-in-roles#kubernetes-cluster---azure-arc-onboarding) can be used for this identity. This role is useful for at-scale onboarding, as it has only the granular permissions required to connect clusters to Azure Arc, and doesn't have permission to update, delete, or modify any other clusters or other Azure resources.

## Azure resource provider requirements

To use Azure Arc-enabled Kubernetes, the following [Azure resource providers](/en-us/azure/azure-resource-manager/management/resource-providers-and-types) must be registered in your subscription:

- **Microsoft.Kubernetes**
- **Microsoft.KubernetesConfiguration**
- **Microsoft.ExtendedLocation**

You can register the resource providers using the following commands:

Azure PowerShell:

```azurepowershell
Connect-AzAccount
Set-AzContext -SubscriptionId [subscription you want to onboard]
Register-AzResourceProvider -ProviderNamespace Microsoft.Kubernetes
Register-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration
Register-AzResourceProvider -ProviderNamespace Microsoft.ExtendedLocation
```

Azure CLI:

```azurecli
az account set --subscription "{Your Subscription Name}"
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.ExtendedLocation
```

You can also register the resource providers in the [Azure portal](/en-us/azure/azure-resource-manager/management/resource-providers-and-types#azure-portal).

## Network requirements

Be sure that you have connectivity to the [required endpoints for Azure Arc-enabled Kubernetes](network-requirements).