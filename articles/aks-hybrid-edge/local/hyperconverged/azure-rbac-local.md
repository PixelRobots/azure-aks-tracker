---
layout: Conceptual
title: Use Azure role-based access control (RBAC) for Kubernetes authorization | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/azure-rbac-local
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
description: Learn how infrastructure administrators can use Azure RBAC to control who can access kubeconfig.
ms.topic: how-to
ms.custom: devx-track-azurecli, hyperconverged
author: davidsmatlak
ms.author: davidsmatlak
ms.reviewer: leslielin
ms.date: 2026-09-01T00:00:00.0000000Z
ms.lastreviewed: 2025-07-25T00:00:00.0000000Z
locale: en-us
document_id: efaf7a23-d021-0ca5-ffe4-a18ef42f8d02
document_version_independent_id: 3748de45-989a-28b0-df1f-6a18df2d5eae
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/azure-rbac-local.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/azure-rbac-local
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/azure-rbac-local.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ca9b34e1-b4f8-0c10-612f-c8dea2f8e2a2
---

# Use Azure role-based access control (RBAC) for Kubernetes authorization | Microsoft Learn

> 
> Applies to: AKS on Azure Local

Infrastructure administrators can use Azure role-based access control (Azure RBAC) to control who can access the *kubeconfig* file and the permissions they have. Kubernetes operators can interact with Kubernetes clusters using the **kubectl** tool based on the given permissions. Azure CLI provides an easy way to get the access credentials and kubeconfig configuration file to connect to your AKS clusters using **kubectl**.

When you use integrated authentication between Microsoft Entra ID and AKS, you can use Microsoft Entra users, groups, or service principals as subjects in [Kubernetes role-based access control (Kubernetes RBAC)](concepts-security-access-identity). This feature frees you from having to separately manage user identities and credentials for Kubernetes. However, you still must set up and manage Azure RBAC and Kubernetes RBAC separately.

This article describes how to use Azure RBAC for Kubernetes cluster authorization with Microsoft Entra ID and Azure role assignments.

For a conceptual overview, see [Azure RBAC for Kubernetes Authorization](concepts-security-access-identity) for AKS Hybrid and Edge.

## Before you begin

Before you begin, make sure you have the following prerequisites:

- AKS on Azure Local currently supports enabling Azure RBAC only during Kubernetes cluster creation. You can't enable Azure RBAC after the Kubernetes cluster is created.
- You can enable Azure RBAC using either Azure CLI or the Azure portal. To use Azure CLI, you must install the latest versions of the **aksarc** and **connectedk8s** Azure CLI extensions. Note that you need the **aksarc** extension version 1.1.1 or later to enable Azure RBAC. Run `az --version` to find the current version. If you need to install or upgrade Azure CLI, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

    ```azurecli
    az extension add --name aksarc
    az extension add --name connectedk8s
    ```

    If you already installed the `aksarc` extension, update the extension to the latest version:

    ```azurecli
    az extension update --name aksarc
    az extension update --name connectedk8s
    ```
- To interact with Kubernetes clusters, you must install [**kubectl**](https://kubernetes.io/docs/tasks/tools/) and [**kubelogin**](https://azure.github.io/kubelogin/install.html). You can use the following Azure CLI or Azure PowerShell commands to install both **kubectl** and **kubelogin**:

# [Azure CLI](#tab/cli)
Install kubectl locally using the [az aks install-cli](/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-install-cli&amp;preserve-view=true) command.

# [PowerShell](#tab/powershell)
Install kubectl locally using the [Install-AzAksCliTool](/en-us/powershell/module/az.aks/install-azaksclitool?view=azps-14.2.0&amp;preserve-view=true) cmdlet.

---

- The following permissions are required to enable Azure RBAC when creating a Kubernetes cluster:
    - To create a Kubernetes cluster, the [**Azure Kubernetes Service Arc Contributor**](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-service-arc-contributor-role) role is required.
    - To use the `--enable-azure-rbac` parameter, the [**Role Based Access Control Administrator**](/en-us/azure/role-based-access-control/built-in-roles/privileged#role-based-access-control-administrator) role is required for access to the **Microsoft.Authorization/roleAssignments/write** permission.
    - To assign these roles, use the [az role assignment create](/en-us/cli/azure/role/assignment#az-role-assignment-create) CLI command, or follow [Assign Azure roles using Azure CLI](/en-us/azure/role-based-access-control/role-assignments-cli):

        ```azurecli
        az role assignment create --assignee <assignee-object-id> --role <role-name-or-id> --scope $ARM_ID
        ```
    - New role assignments can take up to five minutes to propagate and be updated by the authorization server.
- Once Azure RBAC is enabled, you can access your Kubernetes cluster with the given permissions using either direct mode or proxy mode.
    - To access the Kubernetes cluster directly using the `az aksarc get-credentials` command, you need the **Microsoft.HybridContainerService/provisionedClusterInstances/listUserKubeconfig/action**, which is included in the **Azure Kubernetes Service Arc Cluster User** role permission.
    - To access the Kubernetes cluster from anywhere with a proxy mode using the `az connectedk8s proxy` command, or from the Azure portal, you need the **Microsoft.Kubernetes/connectedClusters/listClusterUserCredential/action** action, which is included in the **Azure Arc enabled Kubernetes Cluster User** role permission. Meanwhile, you must verify that the agents and the machine performing the onboarding process meet the network requirements specified in [Azure Arc-enabled Kubernetes network requirements](/en-us/azure/azure-arc/kubernetes/network-requirements?tabs=azure-cloud#details).
- To use **kubectl**, you can access it using either Azure RBAC or the AAD Admin Group.
    - To use kubectl with Azure RBAC, you need the **Azure Arc Kubernetes Viewer** role scoped to the connected cluster resource.
    - To use kubectl with the AAD Admin Group, you don't need any specific role, but you must ensure you are in one of the groups in the **add-admin-group** list of the connected cluster resource.

## Step 1: Create an Azure RBAC-enabled Kubernetes cluster

You can create an Azure RBAC-enabled Kubernetes cluster for authorization and a Microsoft Entra ID for authentication.

# [Azure CLI](#tab/azurecli)
```azurecli
az aksarc create -n $aks_cluster_name -g $resource_group_name --custom-location $customlocation_ID --vnet-ids $logicnet_Id --generate-ssh-keys --enable-azure-rbac
```

After a few minutes, the command completes and returns JSON-formatted information about the cluster.

# [Azure portal](#tab/azureportal)
1. Go to **Kubernetes - Azure Arc**, select the **Add** icon, and then select **Create a Kubernetes cluster with Azure Arc**.
2. Under the **Access** tab, locate the authentication and authorization settings. Select **Microsoft Entra Authentication with Azure RBAC**.
3. Complete all other desired configurations for your cluster.
4. Select **Review + create** to create the cluster.

---

## Step 2: Create role assignments for users to access the cluster

AKS provides the following five built-in roles. They are similar to the [Kubernetes built-in roles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles), with a few differences, such as supporting CRDs. See the full list of actions allowed by each [Azure built-in role](/en-us/azure/role-based-access-control/built-in-roles).

| Role | Description |
| --- | --- |
| [Azure Arc-enabled Kubernetes Cluster User](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-arc-enabled-kubernetes-cluster-user-role) | Allows you to retrieve the Cluster Connect-based kubeconfig file to manage clusters from anywhere. |
| [Azure Arc Kubernetes Viewer](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-arc-kubernetes-viewer) | Allows read-only access to see most objects in a namespace.  Doesn't allow viewing secrets, because **read** permission on secrets enables access to **ServiceAccount** credentials in the namespace. These credentials in turn allow API access through that **ServiceAccount** value (a form of privilege escalation). |
| [Azure Arc Kubernetes Writer](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-arc-kubernetes-writer) | Allows read/write access to most objects in a namespace. Doesn't allow viewing or modifying roles or role bindings. However, this role allows accessing secrets and running pods as any **ServiceAccount** value in the namespace, so it can be used to gain the API access levels of any such **ServiceAccount** value in the namespace. |
| [Azure Arc Kubernetes Admin](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-arc-kubernetes-admin) | Allows admin access. It's intended to be granted within a namespace through **RoleBinding**. If you use it in **RoleBinding**, it allows read/write access to most resources in a namespace, including the ability to create roles and role bindings within the namespace. This role doesn't allow write access to resource quota or to the namespace itself. |
| [Azure Arc Kubernetes Cluster Admin](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-arc-kubernetes-cluster-admin) | Allows "superuser" access to execute any action on any resource. When you use it in **ClusterRoleBinding**, it gives full control over every resource in the cluster and in all namespaces. When you use it in **RoleBinding**, it gives full control over every resource in the role binding namespace, including the namespace itself. |

You can use the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command to create role assignments.

# [Azure CLI](#tab/azurecli)
First, get the `$ARM-ID` for the target cluster to which you want to assign a role.

```azurecli
$ARM_ID = (az connectedk8s show -g "$resource_group_name" -n $aks_cluster_name --query id -o tsv)
```

Then, use the `az role assignment create` command to assign roles to your Kubernetes cluster. You must provide the `$ARM_ID` from the first step and the `assignee-object-id` for this step. The `assignee-object-id` can be a Microsoft Entra ID or a service principal client ID.

The following example assigns the **Azure Arc Kubernetes Viewer** role to the Kubernetes cluster:

```azurecli
az role assignment create --role "Azure Arc Kubernetes Viewer" --assignee <assignee-object-id> --scope $ARM_ID
```

In this example, the scope is the Azure Resource Manager ID of the cluster. It can also be the resource group containing the Kubernetes cluster.

# [Azure portal](#tab/azureportal)
1. Go to **Azure Arc | Kubernetes clusters** and locate your Azure RBAC-enabled cluster for which you want to assign roles.
2. Navigate to **Access control (IAM)**, select the **Add** icon, and then select **Add role assignment**. If the **Add role assignment** option is disabled, verify that Azure RBAC is enabled by checking **Settings &gt; Properties &gt; AAD profile &gt; Enable Azure RBAC**.
3. Follow the instructions to complete the role assignment.

---

### Create custom role definitions

You can choose to create your own role definition for use in role assignments.

The following example shows a role definition that allows a user to only read deployments. For more information, see [the full list of data actions that you can use to construct a role definition](/en-us/azure/role-based-access-control/resource-provider-operations#microsoftkubernetes). For more information about creating a custom role, see [Steps to create a custom role](/en-us/azure/role-based-access-control/custom-roles#steps-to-create-a-custom-role)

To create your own custom role definitions, copy the following JSON object into a file called **custom-role.json**. Replace the `<subscription-id>` placeholder with the actual subscription ID. The custom role uses one of the data actions and lets you view all deployments in the scope (cluster or namespace) where the role assignment is created.

```json
{
    "Name": "AKS Arc Deployment Reader",
    "Description": "Lets you view all deployments in cluster/namespace.",
    "Actions": [],
    "NotActions": [],
    "DataActions": [
        "Microsoft.Kubernetes/connectedClusters/apps/deployments/read"
    ],
    "NotDataActions": [],
    "assignableScopes": [
        "/subscriptions/<YOUR SUBSCRIPTION ID>"
    ]
}
```

For information about custom roles and how to author them, see [Azure custom roles](/en-us/azure/role-based-access-control/custom-roles).

Create the role definition using the [`az role definition create`](/en-us/cli/azure/role/definition#az-role-definition-create) command, setting the `--role-definition` parameter to the **deploy-view.json** file you created in the previous step:

```azurecli
az role definition create --role-definition @deploy-view.json 
```

Assign the role definition to a user or other identity using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command:

```azurecli
az role assignment create --role "AKS Arc Deployment Reader" --assignee <assignee-object-id> --scope $ARM_ID
```

## Step 3: Access Kubernetes cluster

You can now access your Kubernetes cluster with the given permissions, using either direct mode or proxy mode.

### Access your cluster with kubectl (direct mode)

To access the Kubernetes cluster with the given permissions, the Kubernetes operator needs the Microsoft Entra **kubeconfig**, which you can get using the [`az aksarc get-credentials`](/en-us/cli/azure/aksarc#az-aksarc-get-credentials) command. This command provides access to the admin-based kubeconfig, as well as a user-based kubeconfig. The admin-based kubeconfig file contains secrets and should be securely stored and rotated periodically. On the other hand, the user-based Microsoft Entra ID kubeconfig doesn't contain secrets and can be distributed to users who connect from their client machines.

To run this Azure CLI command, you need the **Microsoft.HybridContainerService/provisionedClusterInstances/listUserKubeconfig/action**, which is included in the **Azure Kubernetes Service Arc Cluster User** role permission:

```azurecli
az aksarc get-credentials -g "$resource_group_name" -n $aks_cluster_name --file <file-name>
```

Now you can use kubectl manage your cluster. For example, you can list the nodes in your cluster using `kubectl get nodes`. The first time you run it, you must sign in, as shown in the following example:

```azurecli
kubectl get nodes
```

### Access your cluster from a client device (proxy mode)

To access the Kubernetes cluster from anywhere with a proxy mode using `az connectedk8s proxy` command, you need the **Microsoft.Kubernetes/connectedClusters/listClusterUserCredential/action**, which is included in **Azure Arc enabled Kubernetes Cluster User** role permission.

Run the following steps on another client device:

1. Sign in using Microsoft Entra authentication
2. Get the cluster connect **kubeconfig** needed to communicate with the cluster from anywhere (even from outside the firewall surrounding the cluster):

    ```azurecli
    az connectedk8s proxy -n $CLUSTER_NAME -g $RESOURCE_GROUP
    ```

    Note

    This command opens the proxy and blocks the current shell.
3. In a different shell session, use `kubectl` to send requests to the cluster:

    ```powershell
    kubectl get pods -A
    ```

You should now see a response from the cluster containing the list of all pods under the `default` namespace.

For more information, see [Access your cluster from a client device](/en-us/azure/azure-arc/kubernetes/cluster-connect?tabs=azure-cli%2Cagent-version#access-your-cluster-from-a-client-device).

## Clean up resources

### Delete role assignment

```azurecli
# List role assignments
az role assignment list --scope $ARM_ID --query [].id -o tsv

# Delete role assignments
az role assignment delete --ids <LIST OF ASSIGNMENT IDS>
```

### Delete role definition

```azurecli
az role definition delete -n "AKS Arc Deployment Reader"
```