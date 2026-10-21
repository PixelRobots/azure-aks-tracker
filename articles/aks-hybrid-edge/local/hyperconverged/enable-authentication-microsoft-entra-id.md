---
layout: Conceptual
title: Enable Microsoft Entra authentication for Kubernetes clusters | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/enable-authentication-microsoft-entra-id
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn how to enable Microsoft Entra ID on Azure Kubernetes Service with kubelogin and authenticate Azure users with credentials or managed roles.
author: davidsmatlak
ms.author: davidsmatlak
ms.lastreviewed: 2024-07-26T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.topic: how-to
ms.custom: hyperconverged - devx-track-azurecli
ms.date: 2026-09-01T00:00:00.0000000Z
locale: en-us
document_id: b8b084fa-3577-64f4-dba6-8b34e786a194
document_version_independent_id: d0196471-04f1-7738-b954-8d9f988cba78
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/enable-authentication-microsoft-entra-id.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/enable-authentication-microsoft-entra-id
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/enable-authentication-microsoft-entra-id.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
platformId: b3918924-deb6-7347-bafd-817bb3a6b65c
---

# Enable Microsoft Entra authentication for Kubernetes clusters | Microsoft Learn

> 
> Applies to: AKS on Azure Local

AKS Hybrid and Edge simplifies the authentication process with Microsoft Entra ID integration. For authorization, cluster administrators can configure Kubernetes role-based access control (Kubernetes RBAC) or Azure role-based access control (Azure RBAC) based on the directory group membership of the Microsoft Entra ID integration.

Microsoft Entra authentication is provided to AKS clusters with OpenID Connect. OpenID Connect is an identity layer built on top of the OAuth 2.0 protocol. For more information about OpenID Connect, see the [OpenID Connect documentation](/en-us/entra/identity-platform/v2-protocols-oidc). For more information about the Microsoft Entra integration flow, see the [Microsoft Entra documentation](concepts-security-access-identity#microsoft-entra-integration).

This article describes how to enable and use Microsoft Entra ID authentication for Kubernetes clusters.

## Before you begin

- This configuration requires that you have a Microsoft Entra group for your cluster. This group is registered as an admin group on the cluster to grant admin permissions. If you don't have an existing Microsoft Entra group, you can create one using the [`az ad group create`](/en-us/cli/azure/ad/group#az_ad_group_create) command.
- To create or update a Kubernetes cluster, you need the **Azure Kubernetes Service Arc Contributor** role.
- To access the Kubernetes cluster directly using the [`az aksarc get-credentials`](/en-us/cli/azure/aksarc#az-aksarc-get-credentials) command and download the kubeconfig file, you need the **Microsoft.HybridContainerService/provisionedClusterInstances/listUserKubeconfig/action**, which is included in the **Azure Kubernetes Service Arc Cluster User** role permission.
- Once your Microsoft Entra group is enabled with admin access to your AKS cluster, this Microsoft Entra group can interact with Kubernetes clusters. You must install [**kubectl**](https://kubernetes.io/docs/tasks/tools/) and [**kubelogin**](https://azure.github.io/kubelogin/install.html).
- Integration can't be disabled once added. You can still use [`az aksarc update`](/en-us/cli/azure/aksarc#az-aksarc-update) to update the `aad-admin-group-object-ids` if needed.

## Enable Microsoft Entra authentication for Kubernetes cluster

### Create a new cluster with Microsoft Entra authentication

1. Create an Azure resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command:

    ```azurecli
    az group create --name $resource_group --location centralus
    ```
2. Create an AKS cluster and enable admin access for your Microsoft Entra group using the `--aad-admin-group-object-ids` parameter in the [`az aksarc create`](/en-us/cli/azure/aksarc#az-aksarc-create) command:

    ```azurecli
    az aksarc create -n $aks_cluster_name -g $resource_group --custom-location $customlocationID --vnet-ids $logicnetId --aad-admin-group-object-ids $aadgroupID --generate-ssh-keys
    ```

### Use an existing cluster with Microsoft Entra authentication

Enable Microsoft Entra authentication on your existing Kubernetes cluster using the `--aad-admin-group-object-ids` parameter in the [`az aksarc update`](/en-us/cli/azure/aksarc#az-aksarc-update) command. Make sure to set your admin group to retain access on your cluster:

```azurecli
az aksarc update -n $aks_cluster_name -g $resource_group --aad-admin-group-object-ids $aadgroupID
```

## Access your Microsoft Entra-enabled cluster

1. Get the user credentials to access your cluster using the [`az aksarc get-credentials`](/en-us/cli/azure/aksarc#az-aksarc-get-credentials) command. You need the **Microsoft.HybridContainerService/provisionedClusterInstances/listUserKubeconfig/action**, which is included in the **Azure Kubernetes Service Arc Cluster User** role permission:

    ```azurecli
    az aksarc get-credentials --resource-group $resource_group --name $aks_cluster_name
    ```
2. View the nodes in the cluster with the `kubectl get nodes` command and follow the instructions to sign in. You need to be in the Microsoft Entra ID group specified with the AKS cluster when you pass the `--aad-admin-group-object-ids $aadgroupID` parameter:

    ```azurecli
    kubectl get nodes
    ```