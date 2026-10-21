---
layout: Conceptual
title: Control cluster and node access using Conditional Access with Microsoft Entra integration - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/access-control-managed-azure-ad
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
description: Learn how to access clusters and nodes using Conditional Access when integrating Microsoft Entra ID in your Azure Kubernetes Service (AKS) clusters.
ms.topic: concept-article
ms.subservice: aks-integration
ms.date: 2025-11-10T00:00:00.0000000Z
author: shashankbarsin
ms.author: shasb
ms.custom: devx-track-azurecli
locale: en-us
document_id: 83e6ee66-67d3-0502-310a-edc8b03610ed
document_version_independent_id: 43ddb87e-6b0a-6eec-fb12-25ed7bc27907
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/access-control-managed-azure-ad.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/access-control-managed-azure-ad
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/access-control-managed-azure-ad.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
platformId: 16d5d0be-2113-cc0c-adf7-f53b544f8866
---

# Control cluster and node access using Conditional Access with Microsoft Entra integration - Azure Kubernetes Service | Microsoft Learn

When you integrate Microsoft Entra ID with your AKS cluster, you can use [Conditional Access](/en-us/azure/active-directory/conditional-access/overview) to control access to your cluster control plane and cluster nodes. This article shows you how to enable Conditional Access on your AKS clusters for both control plane access and SSH access to nodes.

Note

Microsoft Entra Conditional Access has Microsoft Entra ID P1, P2, or Governance capabilities requiring a Premium P2 SKU. For more on Microsoft Entra ID licenses and SKUs, see [Microsoft Entra ID Governance licensing fundamentals](/en-us/entra/id-governance/licensing-fundamentals) and [pricing guide](https://azure.microsoft.com/pricing/details/active-directory/).

## Before you begin

- See [Microsoft Entra integration](managed-azure-ad) for an overview and setup instructions.
- For SSH access to nodes, see [Manage SSH for secure access to Azure Kubernetes Service (AKS) nodes](manage-ssh-node-access) to configure Entra ID based SSH.

## Use Conditional Access with Microsoft Entra ID and AKS

You can use Conditional Access to control access to both the AKS cluster control plane and SSH access to cluster nodes.

### Configure Conditional Access for cluster control plane access

1. In the Azure portal, go to the **Microsoft Entra ID** page and select **Enterprise applications**.
2. Select **Conditional Access** &gt; **Policies** &gt; **New policy**.
3. Enter a name for the policy, such as *aks-policy*.
4. Under **Assignments**, select **Users and groups**. Choose the users and groups you want to apply the policy to. In this example, choose the same Microsoft Entra group that has administrator access to your cluster.
5. Under **Cloud apps or actions** &gt; **Include**, select **Select apps**. Search for **Azure Kubernetes Service** and select **Azure Kubernetes Service Microsoft Entra Server**.
6. Under **Access controls** &gt; **Grant**, select **Grant access**, **Require device to be marked as compliant**, and **Require all the selected controls**.
7. Confirm your settings, set **Enable policy** to **On**, and then select **Create**.

### Verify Conditional Access for cluster control plane access

After implementing your Conditional Access policy, verify that it works as expected by accessing the AKS cluster and checking the sign-in activity.

1. Get the user credentials to access the cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    Assign values to the required environment variables. The AKS cluster and resource group must exist.

    ```azurecli
    export RANDOM_SUFFIX=$(head -c 3 /dev/urandom | xxd -p)
    export RESOURCE_GROUP="myResourceGroup$RANDOM_SUFFIX"
    export AKS_CLUSTER="myManagedCluster$RANDOM_SUFFIX"
    ```

    Download credentials required to access your AKS cluster.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --overwrite-existing
    ```
2. Follow the instructions to sign in.
3. View the nodes in the cluster using the `kubectl get nodes` command.

    ```azurecli
    kubectl get nodes
    ```

    Results:

    ```output
    NAME                                         STATUS   ROLES   AGE     VERSION
    aks-nodepool1-xxxxx-vmss000000               Ready    agent   3d2h    v1.xx.x
    aks-nodepool1-xxxxx-vmss000001               Ready    agent   3d2h    v1.xx.x
    ```
4. In the Azure portal, navigate to **Microsoft Entra ID** and select **Enterprise applications** &gt; **Activity** &gt; **Sign-ins**.
5. Under the **Conditional Access** column you should see a status of *Success*. Select the event and then select the **Conditional Access** tab. Your Conditional Access policy will be listed.

## Configure Conditional Access for SSH access to cluster nodes

When you enable Entra ID based SSH access on your AKS cluster nodes, you can apply Conditional Access policies to control SSH access to the nodes. This provides additional security by enforcing device compliance, multifactor authentication, or other conditions before users can SSH into cluster nodes.

1. In the Azure portal, go to the **Microsoft Entra ID** page and select **Enterprise applications**.
2. Select **Conditional Access** &gt; **Policies** &gt; **New policy**.
3. Enter a name for the policy, such as *aks-node-ssh-policy*.
4. Under **Assignments**, select **Users and groups**. Choose the users and groups you want to apply the policy to.
5. Under **Cloud apps or actions** &gt; **Include**, select **Select apps**. Search for **Azure Virtual Machine Sign-In** and select **Azure Linux Virtual Machine Sign-In**.
6. Under **Access controls** &gt; **Grant**, select **Grant access**, **Require device to be marked as compliant**, **Require multi-factor authentication**, and **Require all the selected controls**.
7. Confirm your settings, set **Enable policy** to **On**, and then select **Create**.

Note

For Entra ID based SSH to work with Conditional Access, ensure that your AKS cluster nodes are configured with `--ssh-access entraid`. For more information, see [Manage SSH for secure access to Azure Kubernetes Service (AKS) nodes](manage-ssh-node-access).

### Verify Conditional Access for SSH access to nodes

After implementing your Conditional Access policy for SSH access to nodes, verify that it works as expected:

1. Ensure you have the appropriate Azure RBAC permissions:

    - **Virtual Machine Administrator Login** role for admin access
    - **Virtual Machine User Login** role for non-admin access
2. Install the SSH extension for Azure CLI:

    ```azurecli
    az extension add --name ssh
    ```
3. SSH into a node using Entra ID authentication:

    ```azurecli
    az ssh vm --resource-group $RESOURCE_GROUP --name <node-name>
    ```
4. During the authentication flow, you'll be prompted to satisfy the Conditional Access policies (e.g., device compliance, MFA).
5. After successful authentication that meets the Conditional Access requirements, you'll be connected to the node.
6. In the Azure portal, navigate to **Microsoft Entra ID** and select **Enterprise applications** &gt; **Activity** &gt; **Sign-ins**.
7. Find the sign-in event for **Azure Linux Virtual Machine Sign-In** and verify that under the **Conditional Access** column you see a status of *Success*.