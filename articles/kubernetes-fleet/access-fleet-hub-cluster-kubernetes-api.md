---
layout: Conceptual
title: Access the Kubernetes API for an Azure Kubernetes Fleet Manager Hub Cluster | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/access-fleet-hub-cluster-kubernetes-api
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
description: Learn how to access the Kubernetes API for an Azure Kubernetes Fleet Manager hub cluster.
ms.topic: how-to
ms.date: 2024-04-01T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.service: azure-kubernetes-fleet-manager
zone_pivot_groups: public-hub-private-hub
locale: en-us
document_id: 7651c10b-54fc-4255-c585-415cbfdd697c
document_version_independent_id: b0aac6aa-a1e2-69fa-43b7-a72037f9a40a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/access-fleet-hub-cluster-kubernetes-api.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/access-fleet-hub-cluster-kubernetes-api
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/access-fleet-hub-cluster-kubernetes-api.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7c01134-b8f3-438c-822d-13471e513908
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/82fff6b2-939d-4e9a-8f9c-d1c41a59749b
platformId: dbcee361-d2f3-285c-105b-8179a24e85ac
---

# Access the Kubernetes API for an Azure Kubernetes Fleet Manager Hub Cluster | Microsoft Learn

**Applies to:** ✔️ Fleet Manager with hub cluster

::: zone pivot="public-hub"

If your Azure Kubernetes Fleet Manager (Kubernetes Fleet) resource was created with a hub cluster, you can use it to centrally control scenarios like Kubernetes resource propagation. In this article, you learn how to access the Kubernetes API for a Kubernetes Fleet hub cluster.

## Before you begin

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- You need a Kubernetes Fleet resource with a hub cluster and member clusters. If you don't have one, see [Create an Azure Kubernetes Fleet Manager resource and join member clusters by using the Azure CLI](quickstart-create-fleet-and-members).
- The identity (user or service principal) that you're using needs to have Microsoft.ContainerService/fleets/listCredentials/action permissions on the Kubernetes Fleet resource.

::: zone-end

::: zone pivot="private-hub"

If your Azure Kubernetes Fleet Manager (Kubernetes Fleet) resource was created with a private hub cluster, you can use it to centrally control scenarios like Kubernetes resource propagation. In this article, you learn how to access the Kubernetes API for a private Kubernetes Fleet hub cluster securely using Azure Bastion's native client tunneling feature.

Using Azure Bastion protects your private hub cluster from exposing endpoints to the outside world, while still providing secure access. For more information, see [What is Azure Bastion?](/en-us/azure/bastion/bastion-overview).

## Before you begin

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- You need a Kubernetes Fleet resource with a hub cluster and member clusters. If you don't have one, see [Create an Azure Kubernetes Fleet Manager resource and join member clusters by using the Azure CLI](quickstart-create-fleet-and-members).
- You need a virtual network with the Bastion host already installed.
    - Ensure that you have set up an Azure Bastion host for the virtual network in which the Fleet Manager is located. To set up an Azure Bastion host, see [Quickstart: Deploy Bastion with default settings](/en-us/azure/bastion/quickstart-host-portal).
    - The Bastion must be Standard or Premium SKU and have native client support enabled under configuration settings.
- The identity (user or service principal) that you're using needs to have:
    - Microsoft.ContainerService/fleets/listCredentials/action permissions on the Kubernetes Fleet resource.
    - Microsoft.Network/bastionHosts/read on the Bastion Resource.
    - Microsoft.Network/virtualNetworks/read on the virtual network of the private hub cluster.

::: zone-end

## Access the Kubernetes API

1. Set the following environment variables for your subscription ID, resource group, and Kubernetes Fleet resource:

    ```azurecli
    export SUBSCRIPTION_ID=<subscription-id>
    export GROUP=<resource-group-name>
    export FLEET=<fleet-name>
    ```
2. Set the default Azure subscription by using the [`az account set`](/en-us/cli/azure/account#az-account-set) command:

    ```azurecli
    az account set --subscription ${SUBSCRIPTION_ID}
    ```
3. Get the kubeconfig file of the Kubernetes Fleet hub cluster by using the [`az fleet get-credentials`](/en-us/cli/azure/fleet#az-fleet-get-credentials) command:

    ```azurecli
    az fleet get-credentials --resource-group ${GROUP} --name ${FLEET}
    ```

    Your output should look similar to the following example:

    ```output
    Merged "hub" as current context in /home/fleet/.kube/config
    ```
4. Set the following environment variable for the `FLEET_ID` value of the hub cluster's Kubernetes Fleet resource:

    ```azurecli
    export FLEET_ID=/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${GROUP}/providers/Microsoft.ContainerService/fleets/${FLEET}
    ```
5. Authorize your identity to access the Kubernetes Fleet hub cluster by using the following commands.

    For the `ROLE` environment variable, you can use one of the following four built-in role definitions as the value:

    - Azure Kubernetes Fleet Manager RBAC Reader
    - Azure Kubernetes Fleet Manager RBAC Writer
    - Azure Kubernetes Fleet Manager RBAC Admin
    - Azure Kubernetes Fleet Manager RBAC Cluster Admin

    ```azurecli
    export IDENTITY=$(az ad signed-in-user show --query "id" --output tsv)
    export ROLE="Azure Kubernetes Fleet Manager RBAC Cluster Admin"
    az role assignment create --role "${ROLE}" --assignee ${IDENTITY} --scope ${FLEET_ID}
    ```

    Your output should look similar to the following example:

    ```output
    {
      "canDelegate": null,
      "condition": null,
      "conditionVersion": null,
      "description": null,
      "id": "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<GROUP>/providers/Microsoft.ContainerService/fleets/<FLEET>/providers/Microsoft.Authorization/roleAssignments/<assignment>",
      "name": "<name>",
      "principalId": "<id>",
      "principalType": "User",
      "resourceGroup": "<GROUP>",
      "roleDefinitionId": "/subscriptions/<SUBSCRIPTION_ID>/providers/Microsoft.Authorization/roleDefinitions/18ab4d3d-a1bf-4477-8ad9-8359bc988f69",
      "scope": "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<GROUP>/providers/Microsoft.ContainerService/fleets/<FLEET>",
      "type": "Microsoft.Authorization/roleAssignments"
    }
    ```

::: zone pivot="public-hub"

1. Verify that you can access the API server by using the `kubectl get memberclusters` command:

    ```bash
    kubectl get memberclusters
    ```

    If the command is successful, your output should look similar to the following example:

    ```output
    NAME           JOINED   AGE
    aks-member-1   True     2m
    aks-member-2   True     2m
    aks-member-3   True     2m
    ```

::: zone-end

::: zone pivot="private-hub"

1. Open the tunnel to your Private Fleet Manager's hub cluster:

    ```bash
    export HUB_CLUSTER_ID=<hub-cluster-id-in-FL_resourceGroup>
    az network bastion tunnel --name <BastionName> --resource-group ${GROUP} --target-resource-id ${HUB_CLUSTER_ID}$ --resource-port 443 --port <LocalMachinePort>
    ```
2. In a new terminal window, connect to the hub cluster through the Bastion tunnel and verify API server access:

    ```bash
    kubectl get memberclusters --server=https://localhost:<LocalMachinePort>
    ```

    If the command is successful, your output should look similar to the following example:

    ```output
    NAME           JOINED   AGE
    aks-member-1   True     2m
    aks-member-2   True     2m
    aks-member-3   True     2m
    ```

::: zone-end