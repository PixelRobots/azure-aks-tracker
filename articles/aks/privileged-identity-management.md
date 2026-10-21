---
layout: Conceptual
title: Control cluster and node access using Privileged Identity Management (PIM) with Microsoft Entra integration - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/privileged-identity-management
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
description: Learn how to access clusters and nodes using Privileged Identity Management (PIM) when integrating Microsoft Entra ID in your Azure Kubernetes Service (AKS) clusters.
ms.topic: how-to
ms.date: 2025-11-10T00:00:00.0000000Z
author: shashankbarsin
ms.author: shasb
locale: en-us
document_id: 141093d2-768c-3314-9f0e-9dbf320e2a7c
document_version_independent_id: 57fe343a-52c6-d6ed-825a-14c2638e9389
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/privileged-identity-management.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/privileged-identity-management
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/privileged-identity-management.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 0be18a20-c248-9bc9-7642-d02e0c707e68
---

# Control cluster and node access using Privileged Identity Management (PIM) with Microsoft Entra integration - Azure Kubernetes Service | Microsoft Learn

When setting up permissions for different teams, you might want to set default permissions for specified teams, then grant privileged access to specific users when needed. Using Azure Kubernetes Service (AKS) with Microsoft Entra ID allows you to set up Privileged Identity Management (PIM) for just-in-time (JIT) requests for both cluster control plane access and SSH access to nodes.

In this article, you learn how to:

- Set default roles for example groups to access or perform operations on AKS clusters and cluster nodes based on Microsoft Entra group memberships.
- Configure basic roles for accessing AKS clusters and SSH access to nodes.
- Self-activate roles to get just-in-time access to AKS clusters and nodes.
- Set approvers to approve or deny approval requests for just-in-time access.

Note

Microsoft Entra Privileged Identity Management (PIM) has Microsoft Entra ID P2 or Microsoft Entra ID Governance capabilities requiring a Premium P2 SKU. For more information, see [Microsoft Entra ID Governance licensing fundamentals](/en-us/entra/id-governance/licensing-fundamentals) and [pricing guide](https://azure.microsoft.com/pricing/details/active-directory/).

## Prerequisites

This article assumes you have an existing AKS cluster with Microsoft Entra ID integration. If you don't have one, see [Create an AKS cluster with Microsoft Entra ID integration](entra-id-control-plane-authentication).

For SSH access to nodes, this article assumes you have configured your AKS cluster with Entra ID based SSH. If you haven't, see [Manage SSH for secure access to Azure Kubernetes Service (AKS) nodes](manage-ssh-node-access).

## Create demo groups in Microsoft Entra ID

In this section, we create four groups in Microsoft Entra ID:

- **Default**: This group has *read-only* access (`Azure Kubernetes Service RBAC Reader`) to resources in the AKS cluster.
- **Admin**: This group has *admin* access (`Azure Kubernetes Service RBAC Admin`) to resources in the AKS cluster.
- **Node-access**: This group has permissions to SSH into cluster nodes using Entra ID authentication (`Virtual Machine User Login`).
- **Approver**: This group has permissions to *approve or deny requests* for just-in-time access to the AKS cluster and nodes.

You *can* use just the **default** and **admin** groups instead of creating a separate **approver** group. However, if you include approval permissions in the **admin** group, the member who gets just-in-time access can approve their own requests and the requests of others. We don't recommend using this configuration in a production environment, but it's useful for testing purposes.

### Create default group

1. Get the *resource ID* of the AKS cluster using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    AKS_ID=$(az aks show \
        --resource-group <resource-group-name> \
        --name <cluster-name> \
        --query id \
        --output tsv)
    ```
2. Get the *resource group ID* of the AKS cluster using the [`az group show`](/en-us/cli/azure/group#az-group-show) command.

    ```azurecli
    RG_ID=$(az group show \
        --resource-group <resource-group-name> \
        --query id \
        --output tsv)
    ```
3. Create the **default** group using the [`az ad group create`](/en-us/cli/azure/ad/group#az-ad-group-create) command.

    ```azurecli
    DEFAULT_ID=$(az ad group create \
        --display-name default \
        --mail-nickname default \
        --query id \
        --output tsv)
    ```
4. Create an Azure role assignment for the **default** group using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    There are *three* roles you can assign to the **default** group depending on your specific requirements:

    - `Azure Kubernetes Service RBAC Reader`: Assigned at the scope of the AKS cluster and gives basic read-only access to most resources in the cluster.
    - `Reader`: Assigned at the scope of the resource group and gives read-only access to resources in the resource group.
    - `Azure Kubernetes Service Cluster User Role`: Assigned at the scope of the AKS cluster and gives access to get the kubeconfig context for the AKS cluster.

    ```azurecli
    # Assign the Azure Kubernetes Service RBAC Reader role to the default group
    az role assignment create \
        --role "Azure Kubernetes Service RBAC Reader" \
        --assignee $DEFAULT_ID \
        --scope $AKS_ID
    
    # Assign the Reader role to the default group
    az role assignment create \
        --role "Reader" \
        --assignee $DEFAULT_ID \
        --scope $RG_ID
    
    # Assign the Azure Kubernetes Service Cluster User Role to the default group
    az role assignment create \
        --role "Azure Kubernetes Service Cluster User Role" \
        --assignee $DEFAULT_ID \
        --scope $AKS_ID
    ```

### Create admin group

1. Create the **admin** group using the [`az ad group create`](/en-us/cli/azure/ad/group#az-ad-group-create) command.

    ```azurecli
    ADMIN_ID=$(az ad group create \
        --display-name admin \
        --mail-nickname admin \
        --query id \
        --output tsv)
    ```
2. Assign the `Azure Kubernetes Service RBAC Admin` role to the **admin** group using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create \
        --role "Azure Kubernetes Service RBAC Admin" \
        --assignee $ADMIN_ID \
        --scope $AKS_ID
    ```

Note

If you want to let users in the **admin** group change node pool settings, such as manual scaling, you need to create a `Contributor` role assignment on the cluster node pool using the following command:

```azurecli
az role assignment create \
   --role "Contributor" \
   --assignee $ADMIN_ID \
   --scope $AKS_ID/nodepools/<node-pool-name>
```

Keep in mind that this only gives permission to scale in or out from the AKS resource. If you want to allow scaling in or out from the Virtual Machine Scale Set resource, you need to create an assignment at the Virtual Machine Scale Set level.

### Create approver group

- Create the **approver** group using the [`az ad group create`](/en-us/cli/azure/ad/group#az-ad-group-create) command.

    ```azurecli
    APPROVER_ID=$(az ad group create \
        --display-name approver \
        --mail-nickname approver \
        --query id \
        --output tsv)
    ```

### Create node-access group

1. Create the **node-access** group using the [`az ad group create`](/en-us/cli/azure/ad/group#az-ad-group-create) command.

    ```azurecli
    NODEACCESS_ID=$(az ad group create \
        --display-name node-access \
        --mail-nickname node-access \
        --query id \
        --output tsv)
    ```
2. Get the resource ID of the node resource group (also known as the infrastructure resource group) using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    NODE_RG_ID=$(az aks show \
        --resource-group <resource-group-name> \
        --name <cluster-name> \
        --query nodeResourceGroup \
        --output tsv)
    
    NODE_RG_SCOPE=$(az group show \
        --name $NODE_RG_ID \
        --query id \
        --output tsv)
    ```
3. Assign the `Virtual Machine User Login` role to the **node-access** group using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create \
        --role "Virtual Machine User Login" \
        --assignee $NODEACCESS_ID \
        --scope $NODE_RG_SCOPE
    ```

    Note

    If you want to grant admin access to nodes instead, use the `Virtual Machine Administrator Login` role.

## Create demo users in Microsoft Entra ID

In this section, we create two users in Microsoft Entra ID: a **normal** user with only the default role, and a **privileged** user who can approve or deny just-in-time requests from the *normal* user.

1. Create the **normal** user using the [`az ad user create`](/en-us/cli/azure/ad/user#az-ad-user-create) command. For the password variable commands, the values are hidden so they aren't displayed on your console.

    ```azurecli
    DOMAIN=contoso.com
    read -sp 'Enter password for NUSER_ID: ' NUSERPASSWORD
    read -sp 'Enter password for PUSER_ID: ' PUSERPASSWORD
    
    NUSER_ID=$(az ad user create \
        --display-name n01 \
        --password ${NUSERPASSWORD} \
        --user-principal-name n01@${DOMAIN} \
        --query id \
        --output tsv)
    ```
2. Add the **normal** user to the default group using the [`az ad group member add`](/en-us/cli/azure/ad/group/member#az-ad-group-member-add) command.

    ```azurecli
    az ad group member add \
        --group $DEFAULT_ID \
        --member-id $NUSER_ID
    ```
3. Create the **privileged** user using the [`az ad user create`](/en-us/cli/azure/ad/user#az-ad-user-create) command.

    ```azurecli
    PUSER_ID=$(az ad user create \
        --display-name p01 \
        --password ${PUSERPASSWORD} \
        --user-principal-name p01@${DOMAIN} \
        --query id \
        --output tsv)
    ```
4. Add the **privileged** user to the approver group using the [`az ad group member add`](/en-us/cli/azure/ad/group/member#az-ad-group-member-add) command.

    ```azurecli
    az ad group member add \
        --group $APPROVER_ID \
        --member-id $PUSER_ID
    ```

## Enable Privileged Identity Management (PIM) for the admin group

This section shows you how to enable PIM for the **admin** group to provide just-in-time access to the AKS cluster control plane.

1. From the [Azure portal home page](https://portal.azure.com/), select **Microsoft Entra ID**.
2. From the service menu, under **Manage**, select **Groups**, and then select the **admin** group.
3. From the service menu, under **Activity**, select **Privileged Identity Management**, and then select **Enable PIM for this group**.

### Set an approver for the admin group

1. From the [Azure portal home page](https://portal.azure.com/), search for and select **Privileged Identity Management**.
2. From the service menu, under **Manage**, select **Groups**, and then select the **admin** group.
3. From the service menu, under **Manage**, select **Assignments** &gt; **Add assignments**.
4. On the **Membership** tab of the **Add assignments** page, select **Member** as the selected role and **default** as the selected member, and then select **Next**.
5. On the **Settings** tab, select **Eligible** as the assignment type, and then select **Assign**.
6. From the service menu, under **Manage**, select **Settings** &gt; **Member** &gt; **Edit**.
7. On the **Edit role setting - Member** page, select the **Require approval to activate** checkbox and add the **approver** group as the selected approver.

    Note

    If you don't select the **Require approval to activate** checkbox, the users in the **default** group can self-activate the role to get just-in-time access to the AKS cluster without approval. The user in the **approver** group has to be a member of the group. Even if you set the user as the **owner**, they still aren't able to review just-in-time requests because the group owner only has administrative rights to the group, not the role assignment. You *can* set the user as the member and owner of the same group without conflict.
8. Make any other necessary changes, and then select **Update**.

For more information about PIM configuration, see [Configure PIM for groups](/en-us/entra/id-governance/privileged-identity-management/groups-assign-member-owner).

## Enable Privileged Identity Management (PIM) for the node-access group

This section shows you how to enable PIM for the **node-access** group to provide just-in-time SSH access to cluster nodes.

1. From the [Azure portal home page](https://portal.azure.com/), select **Microsoft Entra ID**.
2. From the service menu, under **Manage**, select **Groups**, and then select the **node-access** group.
3. From the service menu, under **Activity**, select **Privileged Identity Management**, and then select **Enable PIM for this group**.

### Set an approver for the node-access group

1. From the [Azure portal home page](https://portal.azure.com/), search for and select **Privileged Identity Management**.
2. From the service menu, under **Manage**, select **Groups**, and then select the **node-access** group.
3. From the service menu, under **Manage**, select **Assignments** &gt; **Add assignments**.
4. On the **Membership** tab of the **Add assignments** page, select **Member** as the selected role and **default** as the selected member, and then select **Next**.
5. On the **Settings** tab, select **Eligible** as the assignment type, and then select **Assign**.
6. From the service menu, under **Manage**, select **Settings** &gt; **Member** &gt; **Edit**.
7. On the **Edit role setting - Member** page, select the **Require approval to activate** checkbox and add the **approver** group as the selected approver.
8. Make any other necessary changes, and then select **Update**.

## Interact with cluster resources using the default role

Now, we can try to access the AKS cluster using the **normal** user, who is a member of the **default** group.

1. Log in to the Azure portal as the **normal** user using the [`az login`](/en-us/cli/azure/reference-index#az-login) command.

    ```azurecli
    az login --username n01@$DOMAIN --password ${NUSERPASSWORD}
    ```

    Microsoft recommends you use the most secure method available to sign in to Azure. For more information, see the following articles:

    - [Sign in with credentials on the command line](/en-us/cli/azure/authenticate-azure-cli-interactively#sign-in-with-credentials-on-the-command-line)
    - [Sign into Azure interactively using the Azure CLI](/en-us/cli/azure/authenticate-azure-cli-interactively)
    - [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli)
2. Get the user credentials to access the cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group <resource-group-name> --name <cluster-name>
    ```
3. Try to access the cluster pods using the `kubectl get` command.

    ```bash
    kubectl get pods --namespace kube-system
    ```

    Your output should look similar to the following example output, which shows the pods in the `kube-system` namespace:

    ```output
    NAME                                   READY   STATUS    RESTARTS   AGE
    azure-ip-masq-agent-2rdd9              1/1     Running   0          30h
    azure-policy-767c9d9d9d-886rf          1/1     Running   0          31h
    cloud-node-manager-92t6h               1/1     Running   0          30h
    coredns-789789675-b2dhg                1/1     Running   0          31h
    coredns-autoscaler-77bbc46446-pgt92    1/1     Running   0          31h
    csi-azuredisk-node-lnzrf               3/3     Running   0          30h
    csi-azurefile-node-lhbxr               3/3     Running   0          31h
    konnectivity-agent-7645d94b-9wqct      1/1     Running   0          30h
    kube-proxy-lkx4w                       1/1     Running   0          31h
    metrics-server-5955767688-lpbjb        2/2     Running   0          30h
    ```
4. Try to access the cluster secrets using the `kubectl get` command.

    ```bash
    kubectl get secrets --namespace kube-system
    ```

    Your output should look similar to the following example output, which shows an error message because the user doesn't have permission to access the secrets:

    ```output
    Error from server (Forbidden): secrets is forbidden: User "[email protected]" cannot list resource "secrets" in API group "" in the namespace "kube-system": User does not have access to the resource in Azure. Update role assignment to allow access.
    ```

    The `Azure Kubernetes Service RBAC Reader` role doesn't have permission to access secrets, so this error is expected.

## Request just-in-time access to the AKS cluster

This section shows you how to request just-in-time access as a temporary `Azure Kubernetes Service RBAC Admin` for cluster control plane access. Use the steps in [Activate your group membership or ownership in Privileged Identity Management](/en-us/entra/id-governance/privileged-identity-management/groups-activate-roles). To learn how to approve or deny requests as an approver, see [Approve activation requests for group members and owners](/en-us/entra/id-governance/privileged-identity-management/groups-approval-workflow).

## Request just-in-time SSH access to cluster nodes

This section shows you how to request just-in-time SSH access to cluster nodes by temporarily activating membership in the **node-access** group.

1. From the [Azure portal home page](https://portal.azure.com/), search for and select **Privileged Identity Management**.
2. From the service menu, select **My roles** &gt; **Groups**.
3. Find the **node-access** group in the list of eligible assignments and select **Activate**.
4. Provide a justification for the activation request and select **Activate**.
5. If approval is required, wait for the approver to approve your request. You'll receive a notification when your request is approved.
6. Once activated, you can SSH into cluster nodes using Entra ID authentication.

### SSH into cluster nodes with just-in-time access

After your just-in-time access to the **node-access** group is activated, you can SSH into cluster nodes using Entra ID authentication.

1. Install the SSH extension for Azure CLI:

    ```azurecli
    az extension add --name ssh
    ```
2. Get the list of nodes in your cluster:

    ```azurecli
    kubectl get nodes
    ```
3. SSH into a node using Entra ID authentication:

    ```azurecli
    az ssh vm --resource-group <resource-group-name> --name <node-name>
    ```
4. During the authentication flow, sign in with your Entra ID credentials that now have temporary access to the **node-access** group.
5. After successful authentication, you'll be connected to the node with the permissions granted by your role assignment.

Note

If you configured Conditional Access policies for SSH access to nodes, you'll need to satisfy those requirements during the authentication flow.

## Interact with cluster resources using the admin role

After temporarily adding the `Azure Kubernetes Service RBAC Admin` role, you can access the cluster resources that require admin permissions.

1. Remove existing stored tokens using the following `kubelogin` command:

    ```bash
    kubelogin remove-tokens
    ```

    Note

    If you encounter an error due to lack of permissions, log in to refresh the permissions using the `az login` command.
2. Try to access the cluster secrets again using the `kubectl get secrets` command.

    ```bash
    kubectl get secrets --namespace kube-system
    ```

    Your output should look similar to the following example output, which shows the secrets in the `kube-system` namespace:

    ```output
    NAME                     TYPE                            DATA   AGE
    bootstrap-token-sw3rck   bootstrap.kubernetes.io/token   4      35h
    konnectivity-certs       Opaque                          3      35h
    ```

    The user can now access the secrets because they have the `Azure Kubernetes Service RBAC Admin` role.

### Token lifetime considerations

Due to [token lifetime](/en-us/entra/identity-platform/access-tokens#token-lifetime) design, if you're granting roles to users who use CLI tools, like `kubectl` or `kubelogin`, the activation duration technically can't be less than *60 minutes*. Even if the duration is set to less than 60 minutes, the actual effective duration remains between 60-75 minutes.

When `kubelogin` tries to [get tokens from the Microsoft identity platform](/en-us/entra/identity-platform/access-tokens#token-lifetime), `access_token` and `refresh_token` are returned for further use. The `access_token` makes requests to the API, and the `refresh_token` is used to get a new `access_token` when the current one expires. The `access_token` can't be revoked once generated, but the `refresh_token` can be revoked. If the `refresh_token` is revoked, the user has to reauthenticate to get a new `refresh_token`. To manually revoke the `refresh_token`, you can use [`Revoke-AzureADUserAllRefreshToken`](/en-us/powershell/module/azuread/revoke-azureaduserallrefreshtoken).