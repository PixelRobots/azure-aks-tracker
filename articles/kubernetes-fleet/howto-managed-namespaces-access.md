---
layout: Conceptual
title: View and access Managed Fleet Namespaces using Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/howto-managed-namespaces-access
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
zone_pivot_group_filename: zone-pivots/azure-aks/zone-pivot-groups.json
adobe-target: true
learn_banner_products:
- azure
description: Learn how to find and access your Managed Fleet Namespaces.
author: sjwaight
ms.author: simonwaight
ms.topic: how-to
ms.date: 2026-06-15T00:00:00.0000000Z
ms.service: azure-kubernetes-fleet-manager
zone_pivot_groups: azure-portal-azure-cli
locale: en-us
document_id: 2677ebac-684f-f46a-134f-5da009b63bd2
document_version_independent_id: 7b159283-af42-8233-1123-7c3c51ca03ff
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/howto-managed-namespaces-access.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/howto-managed-namespaces-access
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/howto-managed-namespaces-access.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 043fef2c-a075-7ceb-98a0-a2c506143236
---

# View and access Managed Fleet Namespaces using Azure Kubernetes Fleet Manager | Microsoft Learn

**Applies to:** ✔️ Fleet Manager with hub cluster

This article is intended for users of a managed namespace who need to discover and access those namespaces. If you're looking to create and configure managed namespaces, see [create and configure Managed Fleet Namespaces](howto-managed-namespaces).

## Before you begin

- You need an Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- You need an existing Managed Fleet Namespace. If you don't have one, see [create and configure Managed Fleet Namespaces](howto-managed-namespaces).
- Understand the Managed Fleet Namespace concept by [reading the overview](concepts-fleet-managed-namespace).

::: zone pivot="azure-cli"

- You need Azure CLI version 2.78.0 or later installed to complete this article. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/aks#az-aks-install-cli).
- You need the `fleet` Azure CLI extension version 1.8.0 or later. You can install it and update to the latest version using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) and [`az extension update`](/en-us/cli/azure/extension#az-extension-update) commands.

    ```azurecli
    # Install the extension
    az extension add --name fleet
    
    # Update the extension
    az extension update --name fleet
    ```
- Confirm the fleet extension version is at least 1.8.0 using the [`az extension show`](/en-us/cli/azure/extension#az-extension-show) command.

    ```azurecli
    az extension show --name fleet
    ```
- Set the following environment variables for your subscription ID, resource group, and Fleet:

    ```bash
    export SUBSCRIPTION_ID=<subscription-id>
    export GROUP=<resource-group-name>
    export FLEET=<fleet-name>
    export FLEET_NAMESPACE_NAME=<fleet-namespace-name>
    ```
- Set the default Azure subscription using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription ${SUBSCRIPTION_ID}
    ```

## View the Managed Fleet Namespaces you can access

View the Managed Fleet Namespaces you can access using the [`az fleet namespace list`](/en-us/cli/azure/fleet/namespace#az-fleet-namespace-list) command.

```azurecli
az fleet namespace list  
    --resource-group ${GROUP} \ 
    --fleet-name ${FLEET} \ 
    -o table 
```

Your output should resemble the following example output:

```output
AdoptionPolicy  DeletePolicy   ETag                                    Location   Name                  ProvisioningState   ResourceGroup
--------------  ------------   -------------------------------------   --------   --------------------  -----------------   -------------
Always          Delete         "aaaaaaaa-0b0b-1c1c-2d2d-333333333333   westus2    my-managed-namespace  Succeeded           test-rg
```

## View a Managed Fleet Namespace's configuration

View a specific Managed Fleet Namespace's details by using the [`az fleet namespace show`](/en-us/cli/azure/fleet/namespace#az-fleet-namespace-show) command.

```azurecli
az fleet namespace show \ 
    --resource-group ${GROUP} \ 
    --fleet-name ${FLEET} \ 
    --name ${FLEET_NAMESPACE_NAME} \ 
    -o table 
```

Your output should resemble the following example output:

```output
AdoptionPolicy  DeletePolicy   ETag                                    Location   Name                  ProvisioningState   ResourceGroup
--------------  ------------   -------------------------------------   --------   --------------------  -----------------   -------------
Always          Delete         "aaaaaaaa-0b0b-1c1c-2d2d-333333333333   westus2    my-managed-namespace  Succeeded           test-rg
```

::: zone-end

::: zone pivot="azure-portal"

## View Managed Fleet Namespaces you can access

You can locate Managed Fleet Namespace from within Fleet Manager, or via Kubernetes center.

Starting in Fleet Manager:

- In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
- From the left menu, under **Fleet Resources**, select **Namespaces**.
- Managed Fleet Namespaces you have access to are shown in the namespaces list.

[![Screenshot of the Azure portal showing the list of namespaces including the Managed Fleet Namespace.](media/managed-namespace/view-managed-fleet-namespace-fleet-manager.png)](media/managed-namespace/view-managed-fleet-namespace-fleet-manager.png#lightbox)

Starting in Kubernetes center:

- Open [Kubernetes center - Managed namespaces](https://portal.azure.com/#view/Microsoft_Azure_KubernetesFleet/KubernetesHub.MenuView/%7E/managedNamespaces) in the Azure portal.
- Set the **Type** filter to **Managed Fleet Namespace**.
- Managed Fleet Namespaces you have access to are shown in the namespaces list.

[![Screenshot of the Azure portal showing the list of Managed namespaces in Kubernetes center filtered to Managed Fleet Namespace.](media/managed-namespace/view-managed-fleet-namespace-kubernetes-center.png)](media/managed-namespace/view-managed-fleet-namespace-kubernetes-center.png#lightbox)

## View Managed Fleet Namespace configuration

View a Managed Fleet Namespace's configuration on its overview by selecting the namespace from the list.

[![Screenshot of the Azure portal showing the overview screen for a Managed Fleet Namespace.](media/managed-namespace/view-managed-fleet-namespace-overview.png)](media/managed-namespace/view-managed-fleet-namespace-overview.png#lightbox)

## View Managed Fleet Namespace member clusters

From the Managed Fleet Namespace overview select **Member clusters** on the left navigation to view the member clusters the namespace is distributed to.

[![Screenshot of the Azure portal showing the member clusters that host the selected Managed Fleet Namespace.](media/managed-namespace/view-managed-fleet-namespace-member-clusters.png)](media/managed-namespace/view-managed-fleet-namespace-member-clusters.png#lightbox)

::: zone-end

## Access a Managed Fleet Namespace

You can retrieve the kubeconfig to access a Managed Fleet Namespace on either the Fleet Manager hub cluster, or on a specific member cluster. If you access the hub cluster, you can utilize Fleet Manager's [intelligent resource placement](intelligent-resource-placement) to replicate your resources to member clusters, avoiding the need to manually redeploy the same artifacts on each cluster.

Get credentials to access the namespace on the Fleet Manager hub cluster using the following command.

```azurecli
az fleet namespace get-credentials \ 
    --resource-group ${GROUP} \ 
    --fleet-name ${FLEET} \ 
    --name ${FLEET_NAMESPACE_NAME}
```

Get credentials to access the namespace on member cluster by providing the `member` parameter.

```azurecli
az fleet namespace get-credentials \ 
    --resource-group ${GROUP} \ 
    --fleet-name ${FLEET} \ 
    --name ${FLEET_NAMESPACE_NAME} \ 
    --member myMemberCluster
```