---
layout: Conceptual
title: Limit access to kubeconfig in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/control-kubeconfig-access
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
description: Learn how to control access to the Kubernetes configuration file (kubeconfig) for cluster administrators and cluster users
ms.topic: how-to
ms.subservice: aks-security
author: schaffererin
ms.author: schaffererin
ms.custom: devx-track-azurecli
ms.date: 2023-03-28T00:00:00.0000000Z
locale: en-us
document_id: bf72cbe9-db23-de39-0eba-06d60f4f028e
document_version_independent_id: 1a75b9d6-b49b-4bc4-d950-4758ff96b5a7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/control-kubeconfig-access.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/control-kubeconfig-access
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/control-kubeconfig-access.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: ed2d25be-ce1d-a659-74d5-05f4018c6bfd
---

# Limit access to kubeconfig in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

You can interact with Kubernetes clusters using the `kubectl` tool. The Azure CLI provides an easy way to get the access credentials and *kubeconfig* configuration file to connect to your AKS clusters using `kubectl`. You can use Azure role-based access control (Azure RBAC) to limit who can get access to the *kubeconfig* file and the permissions they have.

This article shows you how to assign Azure roles that limit who can get the configuration information for an AKS cluster.

## Before you begin

- This article assumes that you have an existing AKS cluster. If you need an AKS cluster, create one using [Azure CLI](learn/quick-kubernetes-deploy-cli), [Azure PowerShell](learn/quick-kubernetes-deploy-powershell), or [the Azure portal](learn/quick-kubernetes-deploy-portal).
- This article also requires that you're running Azure CLI version 2.0.65 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Available permissions for cluster roles

When you interact with an AKS cluster using the `kubectl` tool, a configuration file, called *kubeconfig*, defines cluster connection information. This configuration file is typically stored in *~/.kube/config*. Multiple clusters can be defined in this *kubeconfig* file. You can switch between clusters using the [`kubectl config use-context`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#config) command.

The [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command lets you get the access credentials for an AKS cluster and merges these credentials into the *kubeconfig* file. You can use Azure RBAC to control access to these credentials. These Azure roles let you define who can retrieve the *kubeconfig* file and what permissions they have within the cluster.

There are two Azure roles you can apply to a Microsoft Entra user or group:

- **Azure Kubernetes Service Cluster Admin Role**

    - Allows access to `Microsoft.ContainerService/managedClusters/listClusterAdminCredential/action` API call. This API call [lists the cluster admin credentials](/en-us/rest/api/aks/managedclusters/listclusteradmincredentials).
    - Downloads *kubeconfig* for the *clusterAdmin* role.
- **Azure Kubernetes Service Cluster User Role**

    - Allows access to `Microsoft.ContainerService/managedClusters/listClusterUserCredential/action` API call. This API call [lists the cluster user credentials](/en-us/rest/api/aks/managedclusters/listclusterusercredentials).
    - Downloads *kubeconfig* for *clusterUser* role.

Note

On clusters that use Microsoft Entra ID, users with the *clusterUser* role have an empty *kubeconfig* file that prompts a login. Once logged in, users have access based on their Microsoft Entra user or group settings. Users with the *clusterAdmin* role have admin access.

On clusters that don't use Microsoft Entra ID, the *clusterUser* role has same effect of *clusterAdmin* role.

## Assign role permissions to a user or group

To assign one of the available roles, you need to get the resource ID of the AKS cluster and the ID of the Microsoft Entra user account or group using the following steps:

1. Get the cluster resource ID using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command for the cluster named *myAKSCluster* in the *myResourceGroup* resource group. Provide your own cluster and resource group name as needed.
2. Use the [`az account show`](/en-us/cli/azure/account#az-account-show) and [`az ad user show`](/en-us/cli/azure/ad/user#az-ad-user-show) commands to get your user ID.
3. Assign a role using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

The following example assigns the *Azure Kubernetes Service Cluster Admin Role* to an individual user account:

```azurecli
# Get the resource ID of your AKS cluster
AKS_CLUSTER=$(az aks show --resource-group myResourceGroup --name myAKSCluster --query id -o tsv)

# Get the account credentials for the logged in user
ACCOUNT_UPN=$(az account show --query user.name -o tsv)
ACCOUNT_ID=$(az ad user show --id $ACCOUNT_UPN --query objectId -o tsv)

# Assign the 'Cluster Admin' role to the user
az role assignment create \
    --assignee $ACCOUNT_ID \
    --scope $AKS_CLUSTER \
    --role "Azure Kubernetes Service Cluster Admin Role"
```

If you want to assign permissions to a Microsoft Entra group, update the `--assignee` parameter shown in the previous example with the object ID for the *group* rather than the *user*.

To get the object ID for a group, use the [`az ad group show`](/en-us/cli/azure/ad/group#az-ad-group-show) command. The following command gets the object ID for the Microsoft Entra group named *appdev*:

```azurecli
az ad group show --group appdev --query objectId -o tsv
```

Important

In some cases, such as Microsoft Entra guest users, the *user.name* in the account is different than the *userPrincipalName*.

```azurecli
$ az account show --query user.name -o tsv
user@contoso.com

$ az ad user list --query "[?contains(otherMails,'user@contoso.com')].{UPN:userPrincipalName}" -o tsv
user_contoso.com#EXT#@contoso.onmicrosoft.com
```

In this case, set the value of *ACCOUNT\_UPN* to the *userPrincipalName* from the Microsoft Entra user. For example, if your account *user.name* is *user@contoso.com*, this action would look like the following example:

```azurecli
ACCOUNT_UPN=$(az ad user list --query "[?contains(otherMails,'user@contoso.com')].{UPN:userPrincipalName}" -o tsv)
```

## Get and verify the configuration information

Once the roles are assigned, use the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command to get the *kubeconfig* definition for your AKS cluster. The following example gets the *--admin* credentials, which works correctly if the user has been granted the *Cluster Admin Role*:

```azurecli
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster --admin
```

You can then use the [`kubectl config view`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#config) command to verify that the *context* for the cluster shows that the admin configuration information has been applied.

```azurecli
$ kubectl config view
```

Your output should look similar to the following example output:

```azurecli
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://myaksclust-myresourcegroup-19da35-4839be06.hcp.eastus.azmk8s.io:443
  name: myAKSCluster
contexts:
- context:
    cluster: myAKSCluster
    user: clusterAdmin_myResourceGroup_myAKSCluster
  name: myAKSCluster-admin
current-context: myAKSCluster-admin
kind: Config
preferences: {}
users:
- name: clusterAdmin_myResourceGroup_myAKSCluster
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
    token: e9f2f819a4496538b02cefff94e61d35
```

## Remove role permissions

To remove role assignments, use the [`az role assignment delete`](/en-us/cli/azure/role/assignment#az-role-assignment-delete) command. Specify the account ID and cluster resource ID that you obtained in the previous steps. If you assigned the role to a group rather than a user, specify the appropriate group object ID rather than account object ID for the `--assignee` parameter.

```azurecli
az role assignment delete --assignee $ACCOUNT_ID --scope $AKS_CLUSTER
```