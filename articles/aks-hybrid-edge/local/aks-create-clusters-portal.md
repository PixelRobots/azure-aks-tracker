---
layout: Conceptual
title: Create Kubernetes Clusters by Using the Azure Portal | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/aks-create-clusters-portal
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
description: Create Kubernetes clusters by using the Azure portal.
author: davidsmatlak
ms.author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.lastreviewed: 2024-01-30T00:00:00.0000000Z
ms.reviewer: srikantsarwa
ms.custom: local
locale: en-us
document_id: 940552b2-8f1e-34f3-76d8-8196aac2d0fc
document_version_independent_id: d23bf879-8570-ecad-a00d-fc399043c1fd
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/aks-create-clusters-portal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../aks/toc.json
asset_id: aks-hybrid-edge/local/aks-create-clusters-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/aks-create-clusters-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
platformId: 47a1e193-c254-7a30-1067-55550e4eaa62
---

# Create Kubernetes Clusters by Using the Azure Portal | Microsoft Learn

> 
> Applies to: AKS on Azure Local

This article describes how to create Kubernetes clusters in Azure Local by using the Azure portal. You need to:

- Create a Kubernetes cluster by using the Azure portal. By default, the cluster is connected to Azure Arc.
- Provide a Microsoft Entra group that contains the list of Microsoft Entra users with Kubernetes cluster administrator access.

## Before you begin

- Make sure that you have the following details from your on-premises infrastructure administrator:

    - **Azure subscription ID**: The Azure subscription ID where the Azure Arc resource bridge, the Azure Kubernetes Service (AKS) extension Hybrid and Edge, and the custom location are created.
    - **Custom location ID**: The Azure Resource Manager ID of the custom location. Your infrastructure admin should give you Contributor access to the custom location. Custom location is a required parameter to create Kubernetes clusters.
    - **AKS logical network ID Hybrid and Edge**: The Azure Resource Manager ID of the Azure Arc logical network. Your infrastructure admin should give you Contributor access to an AKS logical network Hybrid and Edge. The logical network ID is a required parameter to create Kubernetes clusters.
- Create a Microsoft Entra group and add members to it so that you can connect to the cluster from anywhere. All the members in the Microsoft Entra group have cluster administrator access to the AKS cluster Hybrid and Edge.

    Make sure to add yourself to the Microsoft Entra group. If you don't add yourself, you can't access the AKS cluster Hybrid and Edge by using `kubectl`. For more information about how to create Microsoft Entra groups and add users, see [Create Microsoft Entra groups by using the Azure portal](/en-us/azure/active-directory/fundamentals/active-directory-groups-create-azure-portal).

## Create a Kubernetes cluster

1. Sign in to the [Azure portal](https://portal.azure.com/).
2. In the Azure portal search bar, enter **Kubernetes Azure Arc**.
3. Select **Add** &gt; **Create a Kubernetes cluster with Azure Arc**.

    [![Screenshot that shows the cluster creation page in the portal.](../media/aks-create-clusters-portal/cluster-portal.png)](../media/aks-create-clusters-portal/cluster-portal.png#lightbox)
4. On the **Basics** tab, configure the following options.

    [![Screenshot that shows the Basics tab for cluster creation in the portal.](../media/aks-create-clusters-portal/cluster-create-portal.png)](../media/aks-create-clusters-portal/cluster-create-portal.png#lightbox)

    - **Project details**:
        - Select an Azure subscription. This Azure subscription is where your infrastructure administrator deployed the Azure Arc resource bridge, the AKS extension Hybrid and Edge, and the custom location.
        - Select an Azure resource group, such as **myResourceGroup**.
    - **Cluster details**:
        - Enter a Kubernetes cluster name, such as **myk8scluster**. The name of a Kubernetes cluster name must consist of lowercase alphanumeric characters.
        - Select a custom location where you want to deploy the cluster. Make sure that your infrastructure administrator gives you Contributor access on a custom location.
        - Select a Kubernetes version from the list of available versions.
    - **Primary node pool**:
        - Leave the default values selected, or change the default value from the dropdown list.
    - **Secure Shell (SSH) keys**:
        - Use SSH keys because they're essential for troubleshooting and log collection. Save your private key file for future use.
        - Use an existing SSH key or generate a new key pair during cluster creation. For information about how to create new SSH keys from the Azure portal, see [Create and store SSH keys in the portal](/en-us/azure/virtual-machines/ssh-keys-portal#generate-new-keys).
        - Provide the SSH public key value to use an existing public key. Use an RSA public key in the single line format (starting with `ssh-rsa`) or the multiline Privacy-Enhanced Mail format.
5. Select **Next: Node pools** after configuration is finished.
6. On the **Node pools** page, configure the following options:

    - **Control plane nodes:**
        - ⁠Use control plane nodes to host Kubernetes components. These nodes make global decisions about the cluster, such as scheduling containers and detecting and responding to cluster events. An example is starting up a new pod. For simplicity and reliability, run these important Kubernetes components in separate control plane nodes.
        - Leave the default values selected.
    - **Node pools:**
        - Add optional node pools in addition to the primary node pool that you created on the **Basics** page.
7. At the bottom of the screen, select **Next: Access**.
8. On the **Access** page, configure the following options:

    - Select **Local accounts with Kubernetes RBAC**, which is the default value for Kubernetes cluster authentication. This option requires that you have a direct line of sight to your on-premises infrastructure to access the cluster by using `kubectl`.
    - Select **Microsoft Entra authentication with Kubernetes role-based access control (RBAC)**. This option lets you choose one or more Microsoft Entra groups. By default, all members of the specified Microsoft Entra groups have cluster administrator access to the Kubernetes cluster.

        You can also use this option to connect to AKS Hybrid and Edge from anywhere, without requiring a line of sight to the on-premises infrastructure. Make sure to add yourself to the Microsoft Entra group. If you don't add yourself, you can't access the AKS cluster Hybrid and Edge by using `kubectl`.
    - Choose one or more Microsoft Entra groups. At the bottom of the screen, select **Next: Networking**.
9. On the **Networking** page, select an AKS logical network Hybrid and Edge from the **Logical Network** dropdown list. The Kubernetes nodes and services in your cluster get IP addresses and networking configurations from this logical network. Make sure that your infrastructure administrator gives you Contributor access on an AKS logical network Hybrid and Edge.
10. Select **Integration**. Connect your cluster to other services, such as Azure Monitor, which is enabled by default. You can also add Kubernetes extensions to your cluster from the **Home** &gt; `YourClusterName` &gt; **Settings** &gt; **Extensions** pane.

    You can choose the default Log Analytics workspace or create one of your own. This workspace stores monitoring data.
11. Select **Tags**. Tags are name/value pairs that you can use to categorize resources and view consolidated billing by applying the same tag to multiple resources and resource groups. Use this page to assign tags (optional) to your resource groups.
12. Select **Review + create**. When you go to the **Review + create** tab, Azure runs validation on the settings that you chose. If validation passes, select **Create** to create the cluster. If validation fails, the tab indicates which settings you must modify.
13. It takes a few minutes to create the cluster. When your deployment is finished, go to your resource by either selecting **Go to resource** or browsing to the Kubernetes cluster resource group and selecting the resource.