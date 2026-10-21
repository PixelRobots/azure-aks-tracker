---
layout: Conceptual
title: 'Quickstart: Create an Azure Kubernetes Fleet Manager and Join Member Clusters using the Azure portal | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/quickstart-create-fleet-and-members-portal
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
learn_banner_products:
- azure
description: In this quickstart, you learn how to create an Azure Kubernetes Fleet Manager and join member clusters using the Azure portal.
ms.date: 2026-05-25T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.reviewer: schaffererin
ms.service: azure-kubernetes-fleet-manager
ms.custom: template-quickstart, mode-other
ms.devlang: azurecli
ms.topic: quickstart
locale: en-us
document_id: 3a0dcc8c-fc66-351a-54bb-c80da1393e61
document_version_independent_id: 752c2d40-61f6-acd2-45e3-79fd42a0c615
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/quickstart-create-fleet-and-members-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/quickstart-create-fleet-and-members-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/quickstart-create-fleet-and-members-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 7aadc604-17ea-a2f8-d71c-fdf7fc5fa872
---

# Quickstart: Create an Azure Kubernetes Fleet Manager and Join Member Clusters using the Azure portal | Microsoft Learn

**Applies to**: ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Get started with Azure Kubernetes Fleet Manager using the Azure portal to create a Fleet Manager and join [supported Kubernetes clusters](concepts-member-cluster-types) as members.

## Before you begin

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Read the [conceptual overview of Fleet Manager](concepts-fleet), which provides an explanation of fleets and member clusters referenced in this document.
- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- An identity (user or service principal) with the following permissions:

    - **Fleet Manager**:
        - Microsoft.ContainerService/fleets/read
        - Microsoft.ContainerService/fleets/write
        - Microsoft.ContainerService/fleets/members/read
        - Microsoft.ContainerService/fleets/members/write
        - Microsoft.ContainerService/fleetMemberships/read
        - Microsoft.ContainerService/fleetMemberships/write
    - **AKS member clusters**:
        - Microsoft.ContainerService/managedClusters/read
        - Microsoft.ContainerService/managedClusters/write
        - Microsoft.ContainerService/managedClusters/listClusterUserCredential/action
    - **Arc-enabled Kubernetes member clusters**:
        - Microsoft.Kubernetes/connectedClusters/read
        - Microsoft.KubernetesConfiguration/extensions/read
        - Microsoft.KubernetesConfiguration/extensions/write
        - Microsoft.KubernetesConfiguration/extensions/delete
    - **Azure resource group**:
        - [Azure RBAC Contributor](/en-us/azure/role-based-access-control/built-in-roles/privileged#contributor)
- Clusters you wish to join as members to Fleet must use supported versions of their respective platforms. For more information, see [AKS cluster version support policy](/en-us/azure/aks/supported-kubernetes-versions#kubernetes-version-support-policy) and [Azure Arc-enabled Kubernetes validation](/en-us/azure/azure-arc/kubernetes/validation-program).

## Create a Fleet Manager resource

1. Sign in to the [Azure portal](https://portal.azure.com/).
2. On the Azure portal home page, select **Create a resource**.
3. In the search box, enter **Kubernetes Fleet Manager** and select **Create &gt; Kubernetes Fleet Manager** from the search results.
4. On the **Basics** tab, configure the following options:

    - Under **Project details**:

        - **Subscription**: Select the Azure subscription that you want to use.
        - **Resource group**: Select an existing resource group or select **Create new** to create a new resource group.
    - Under **Fleet details**:

        - **Name**: Enter a name for the Fleet Manager.
        - **Region**: Select the region where you want to create the Fleet Manager.
        - **Hub cluster mode**: Select one of the following options based on features you require:
            - **With hub cluster** multi-cluster Kubernetes resource placement, Managed Fleet Namespaces, DNS load balancing, and cluster upgrades.
            - **Without hub cluster** safe multi-cluster Kubernetes and node image upgrades, cluster observability.

        [![Screenshot of the Create Fleet Manager basics tab in the Azure portal.](media/quickstart-create-fleet-and-members-portal/create-fleet-manager-portal-basics.png)](media/quickstart-create-fleet-and-members-portal/create-fleet-manager-portal-basics.png#lightbox)
5. Select **Next: Member clusters**.
6. Select **+ Add** to add existing clusters, filtering the cluster list using the search box.

    [![Screenshot of the Create Fleet Manager add member cluster dialog in the Azure portal.](media/quickstart-create-fleet-and-members-portal/add-fleet-members-portal.png)](media/quickstart-create-fleet-and-members-portal/add-fleet-members-portal.png#lightbox)
7. Select **Add** to add the selected clusters.
8. In the member list:

    - A **Name** is generated for the member cluster to uniquely identify it within Fleet Manager. Modify the generated name if necessary.
    - Enter an **update group**, such as *dev*, for the member cluster so the cluster can be safely updated when the group is included in a Fleet Manager [update strategy](update-create-update-strategy).

    [![Screenshot of the Create Fleet Manager add member cluster name and update group options in the Azure portal.](media/quickstart-create-fleet-and-members-portal/update-fleet-members-portal.png)](media/quickstart-create-fleet-and-members-portal/update-fleet-members-portal.png#lightbox)
9. Select **Next: Advanced**.
10. On the **Advanced** tab, configure the following options:

    - Select **Enable private hub cluster** to provision a private hub cluster with [API server VNet integration](../aks/api-server-vnet-integration).
        - **Virtual network**: Select an existing Azure virtual network (VNet) or select **Create new** to create a new VNet.
        - **Cluster subnet**: Select a VNet subnet for the hub cluster node.
        - **API server subnet**: Select a VNet subnet for the hub cluster's API server integration.
    - Select an existing [user assigned managed identity](/en-us/entra/identity/managed-identities-azure-resources/overview#managed-identity-types) or select **Create new** to create a new user-assigned managed identity.
    - Optionally, create one or more [Managed Fleet Namespaces](concepts-fleet-managed-namespace) to provision with the Fleet Manager.

    [![Screenshot of the Create Fleet Manager advanced tab in the Azure portal.](media/quickstart-create-fleet-and-members-portal/create-fleet-advanced-portal.png)](media/quickstart-create-fleet-and-members-portal/create-fleet-advanced-portal.png#lightbox)
11. Select **Next: Tags** and define any Azure resource tags to apply to the new Fleet Manager.
12. Select **Review + create** &gt; **Create** to create the Fleet Manager.

    It takes a few minutes to create the Fleet Manager. When your deployment completes, you can select **Go to resource** to view the Fleet Manager.