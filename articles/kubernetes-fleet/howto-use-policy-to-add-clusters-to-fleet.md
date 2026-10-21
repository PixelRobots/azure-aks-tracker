---
layout: Conceptual
title: Use Azure Policy to ensure AKS clusters are enrolled with a Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-use-policy-to-add-clusters-to-fleet
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
description: Learn how to use in-built Azure Policies to identify existing clusters that aren't managed by a Fleet Manager and to automatically add them to Fleet Manager.
ms.topic: how-to
ms.date: 2025-08-11T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
locale: en-us
document_id: 8fdf6f5e-86b7-5536-4a7b-b1e0f07e01ac
document_version_independent_id: fa55d9d2-189a-5a0c-24d2-97893c338ba6
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-use-policy-to-add-clusters-to-fleet.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-use-policy-to-add-clusters-to-fleet
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-use-policy-to-add-clusters-to-fleet.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/eea02214-631d-404a-92d1-5a3357c32a26
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/f42c31d7-eed9-43b7-9757-54caffb53cdc
platformId: 1d6944f1-cb4a-8bbb-92fe-082bdc958358
---

# Use Azure Policy to ensure AKS clusters are enrolled with a Fleet Manager | Microsoft Learn

Platform administrators can use Azure Policy to enforce consistency of fleet management for existing and new Azure Kubernetes Service clusters.

By using the built-in Azure Kubernetes Fleet Manager policies, it is possible to identify existing clusters that aren't managed by a Fleet Manager, while also ensuring that newly created clusters are automatically joined to a fleet.

## Available policies

Fleet Manager's policies are part of the [Kubernetes built-in policy](../aks/policy-reference) set, with the following two policies relating to Fleet Manager.

- **Azure Kubernetes Service clusters should be a member of an Azure Kubernetes Fleet Manager**: Use this policy to identify any AKS clusters not managed by a Fleet Manager. It supports clusters that use either service principals or managed identities.
- **Configure AKS clusters to automatically join the specified Azure Kubernetes Fleet Manager**: Use this policy to ensure new AKS clusters automatically join a designated Fleet Manager. Only clusters using managed identities are supported.

It is recommended to use both policies, firstly to identify existing clusters not managed by a Fleet Manager, and then to ensure that new clusters are automatically enrolled.

## Prerequisites

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- You need a Kubernetes Fleet resource. If you don't have one, see [Create an Azure Kubernetes Fleet Manager resource and join member clusters by using the Azure CLI](quickstart-create-fleet-and-members).
- [Install or upgrade Azure CLI](/en-us/cli/azure/install-azure-cli) to version `2.53.1` or later.
- You also need the `fleet` Azure CLI extension, which you can install by running the following command:

    ```azurecli
    az extension add --name fleet
    ```

    Run the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command to update to the latest version of the extension released:

    ```azurecli
    az extension update --name fleet
    ```

## Assign Autojoin Fleet Manager policy

You can apply a policy definition or initiative in the Azure portal using the following steps:

1. Navigate to the [Azure Policy](https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyMenuBlade/%7E/Overview) service in Azure portal.
2. In the left panes of the Azure Policy page, select **Authoring**, then **Definitions**.
3. From **Category** filter, select **Kubernetes**.
4. Select **Apply**.
5. Choose the **Configure AKS clusters to automatically join the specified Azure Kubernetes Fleet Manager** Policy.
6. Select **Assign**.
7. Set the **Scope** to the Management Group, Subscription, or Resource Group where new AKS clusters are deployed.
8. Select whether **Policy enforcement** is enabled. Enabling ensures new AKS clusters join the specified Fleet Manager.
9. Select the **Parameters** page and set the Fleet Manager to use.
10. Select **Review + create** &gt; **Create** to submit the policy assignment.

## Validate policy is applied to new clusters

1. Follow the steps in the [Deploy an Azure Kubernetes Service (AKS) cluster using Azure CLI](/en-us/azure/aks/learn/quick-kubernetes-deploy-cli) quickstart, selecting an Azure location covered by the previously applied policy definition.
2. Once the AKS cluster is created use the Azure CLI to verify it's a member cluster in the specified Fleet Manager by using the [`az fleet member list`](/en-us/cli/azure/fleet/member#az-fleet-member-list) command. Substitute your AKS cluster name for `aks-member-1` in the `--query`.

    ```azurecli
    az fleet member list \
        --resource-group ${FLEET_GROUP} \
        --fleet-name ${FLEET_NAME} \
        --query "[?contains(Name, 'aks-member-1')]" -o table
    ```

    If successful, your output should look similar to the following example output:

    ```output
    ClusterResourceId                                                                                                          Name          ProvisioningState    ResourceGroup
    -------------------------------------------------------------------------------------------------------------------------  ------------  -------------------  ---------------
    /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<GROUP>/providers/Microsoft.ContainerService/managedClusters/aks-member-1  aks-member-1  Succeeded            <GROUP>
    ```