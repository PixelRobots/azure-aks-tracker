---
layout: Conceptual
title: Use cluster connect to securely connect to Azure Arc-enabled Kubernetes clusters - Azure Arc | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/cluster-connect
breadcrumb_path: ../../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/146/azure-arc/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/5c778dec-0625-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: davidsmatlak
learn_banner_products:
- azure
ms.reviewer: davidsmatlak
ms.author: davidsmatlak
ms.service: azure-arc
ms.subservice: azure-arc-kubernetes
ms.date: 2026-06-04T00:00:00.0000000Z
ms.topic: how-to
ms.custom: devx-track-azurecli
description: With cluster connect, you can securely connect to Azure Arc-enabled Kubernetes clusters from anywhere without requiring any inbound port to be enabled on the firewall.
locale: en-us
document_id: df2cd607-99aa-7541-e93e-323a536c2615
document_version_independent_id: 5bca3714-7ac9-1f60-6054-28f7c750bcdf
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-arc/kubernetes/cluster-connect.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: azure-arc/kubernetes/cluster-connect
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-arc/kubernetes/cluster-connect.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/beac614b-f66d-40ed-a947-3996de709333
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9da05372-4706-43ec-a899-f436adab380d
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: cc1d42f9-8662-aede-78f7-88604cee9723
---

# Use cluster connect to securely connect to Azure Arc-enabled Kubernetes clusters - Azure Arc | Microsoft Learn

With cluster connect, you can securely connect to Azure Arc-enabled Kubernetes clusters from anywhere without requiring any inbound port to be enabled on the firewall.

Access to the API server of the Azure Arc-enabled Kubernetes cluster enables the following scenarios:

- Interactive debugging and troubleshooting.
- Cluster access to Azure services for [custom locations](custom-locations) and other resources created on the cluster.

Before you begin, review the [conceptual overview of the cluster connect feature](conceptual-cluster-connect).

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- An existing Azure Arc-enabled Kubernetes connected cluster.

    - If you haven't connected a cluster yet, use the [quickstart](quickstart-connect-cluster).
    - [Upgrade your agents](agent-upgrade#manually-upgrade-agents) to the latest version.
- Enable the [network requirements for Arc-enabled Kubernetes](network-requirements), including all endpoints listed as required for cluster connect.

# [Azure CLI](#tab/azure-cli)
- [Install](/en-us/cli/azure/install-azure-cli) or [update](/en-us/cli/azure/update-azure-cli) Azure CLI to the latest version.
- Install the latest version of the `connectedk8s` Azure CLI extension:

    ```azurecli
    az extension add --name connectedk8s
    ```

    If you've already installed the `connectedk8s` extension, update the extension to the latest version:

    ```azurecli
    az extension update --name connectedk8s
    ```
- Replace the placeholders and run the following command to set the environment variables:

    ```azurecli
    CLUSTER_NAME=<cluster-name>
    RESOURCE_GROUP=<resource-group-name>
    ARM_ID_CLUSTER=$(az connectedk8s show -n $CLUSTER_NAME -g $RESOURCE_GROUP --query id -o tsv)
    ```

# [Azure PowerShell](#tab/azure-powershell)
- Install [the latest version of Azure PowerShell](/en-us/powershell/azure/install-azure-powershell).
- Replace the placeholders and run the following command to set the environment variables:

    ```azurepowershell
    $CLUSTER_NAME = <cluster-name>
    $RESOURCE_GROUP = <resource-group-name>
    $ARM_ID_CLUSTER = (Get-AzConnectedKubernetes -ResourceGroupName $RESOURCE_GROUP -Name $CLUSTER_NAME).Id
    ```

---

## Set up authentication

On the existing Arc-enabled cluster, create the ClusterRoleBinding with either Microsoft Entra ID authentication or service account token.

### Microsoft Entra ID authentication

# [Azure CLI](#tab/azure-cli)
1. Get the `objectId` associated with your Microsoft Entra ID entity. For single user accounts, get the user principal name (UPN) associated with your Microsoft Entra ID entity.

    - For a Microsoft Entra group account:

        ```azurecli
        AAD_ENTITY_ID=$(az ad group show --group <group-name> --query id -o tsv)
        ```
    - For a Microsoft Entra single user account:

        ```azurecli
        AAD_ENTITY_ID=$(az ad signed-in-user show --query userPrincipalName -o tsv)
        ```
    - For a Microsoft Entra application:

        ```azurecli
        AAD_ENTITY_ID=$(az ad sp show --id <id> --query id -o tsv)
        ```
2. Authorize the entity with appropriate permissions.

    - If you use Kubernetes native ClusterRoleBinding or RoleBinding for authorization checks on the cluster, with the `kubeconfig` file pointing to the Kubernetes API server (`kube-apiserver`) of your cluster for direct access, you can create one mapped to the Microsoft Entra ID entity that needs to access this cluster. For example:

        ```console
        kubectl create clusterrolebinding demo-user-binding --clusterrole cluster-admin --user=$AAD_ENTITY_ID
        ```
    - If you use Azure RBAC for authorization checks on the cluster, you can create an applicable [Azure role assignment](azure-rbac#built-in-roles) mapped to the Microsoft Entra ID entity. For example:

        ```azurecli
        az role assignment create --role "Azure Arc Kubernetes Viewer" --assignee $AAD_ENTITY_ID --scope $ARM_ID_CLUSTER
        az role assignment create --role "Azure Arc Enabled Kubernetes Cluster User Role" --assignee $AAD_ENTITY_ID --scope $ARM_ID_CLUSTER
        ```

# [Azure PowerShell](#tab/azure-powershell)
1. Get the `objectId` associated with your Microsoft Entra ID entity. For single user accounts, get the user principal name (UPN) associated with your Microsoft Entra ID entity.

    - For a Microsoft Entra group account:

        ```azurepowershell
        $AAD_ENTITY_ID = (az ad group show --group <group-name> --query id -o tsv)
        ```
    - For a Microsoft Entra single user account:

        ```azurepowershell
        $AAD_ENTITY_ID = (az ad signed-in-user show --query userPrincipalName -o tsv)
        ```
    - For a Microsoft Entra application:

        ```azurepowershell
        $AAD_ENTITY_ID = (az ad sp show --id <id> --query id -o tsv)
        ```
2. Authorize the entity with appropriate permissions.

    - If you use native Kubernetes ClusterRoleBinding or RoleBinding for authorization checks on the cluster, with the `kubeconfig` file pointing to the Kubernetes API server (`kube-apiserver`) of your cluster for direct access, you can create one mapped to the Microsoft Entra ID entity that needs to access this cluster. For example:

        ```console
        kubectl create clusterrolebinding demo-user-binding --clusterrole cluster-admin --user=$AAD_ENTITY_ID
        ```
    - If you use [Azure RBAC for authorization checks](azure-rbac) on the cluster, you can create an applicable [Azure role assignment](azure-rbac#built-in-roles) mapped to the Microsoft Entra ID entity. For example:

        ```azurepowershell
        az role assignment create --role "Azure Arc Kubernetes Viewer" --assignee $AAD_ENTITY_ID --scope $ARM_ID_CLUSTER
        az role assignment create --role "Azure Arc Enabled Kubernetes Cluster User Role" --assignee $AAD_ENTITY_ID --scope $ARM_ID_CLUSTER
        ```

---

### Service account token authentication

# [Azure CLI](#tab/azure-cli)
Note

The commands in this tab assume a Bash-compatible shell (Linux, macOS, or Windows Subsystem for Linux). For Windows PowerShell, use the **Azure PowerShell** tab.

1. With the `kubeconfig` file pointing to the Kubernetes API server (`kube-apiserver`) of your Kubernetes cluster, run this command to create a service account. This example creates the service account in the default namespace, but you can substitute any other namespace for `default`.

    ```console
    kubectl create serviceaccount demo-user -n default
    ```
2. Create a ClusterRoleBinding to [grant this service account the appropriate permissions on the cluster](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-rolebinding). If you used a different namespace in the first command, substitute it here for `default`.

    ```console
    kubectl create clusterrolebinding demo-user-binding --clusterrole cluster-admin --serviceaccount default:demo-user
    ```
3. Create a service account token:

    ```console
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Secret
    metadata:
      name: demo-user-secret
      annotations:
        kubernetes.io/service-account.name: demo-user
    type: kubernetes.io/service-account-token
    EOF
    ```

    ```console
    TOKEN=$(kubectl get secret demo-user-secret -o jsonpath='{$.data.token}' | base64 -d | sed 's/$/\n/g')
    ```
4. Output the token to the console:

    ```console
    echo $TOKEN
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. With the `kubeconfig` file pointing to the Kubernetes API server (`kube-apiserver`) of your Kubernetes cluster, run this command to create a service account. This example creates the service account in the default namespace, but you can substitute any other namespace for `default`.

    ```console
    kubectl create serviceaccount demo-user -n default
    ```
2. Create a ClusterRoleBinding or RoleBinding to [grant this service account the appropriate permissions on the cluster](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-rolebinding). If you used a different namespace in the first command, substitute it here for `default`.

    ```console
    kubectl create clusterrolebinding demo-user-binding --clusterrole cluster-admin --serviceaccount default:demo-user
    ```
3. Create a service account token. Create a `demo-user-secret.yaml` file with the following content:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: demo-user-secret
      annotations:
        kubernetes.io/service-account.name: demo-user
    type: kubernetes.io/service-account-token
    ```

    Then run these commands:

    ```console
    kubectl apply -f demo-user-secret.yaml
    ```

    ```console
    $TOKEN = ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl get secret demo-user-secret -o jsonpath='{$.data.token}'))))
    ```
4. Output the token to the console:

    ```console
    echo $TOKEN
    ```

---

## Access your cluster from a client device

After you set up authentication on the cluster, use the following steps from any client device to open a cluster connect proxy and run `kubectl` commands against the Azure Arc-enabled Kubernetes cluster.

1. Sign in using either Microsoft Entra ID authentication or service account token authentication.
2. Get the cluster connect `kubeconfig` that you use to communicate with the cluster from anywhere (even outside the firewall), based on your authentication option:

    - For Microsoft Entra ID authentication:

        ```azurecli
        # Microsoft Entra ID authentication
        az connectedk8s proxy -n $CLUSTER_NAME -g $RESOURCE_GROUP
        ```
    - For service account token authentication:

        ```azurecli
        # Service account token authentication
        az connectedk8s proxy -n $CLUSTER_NAME -g $RESOURCE_GROUP --token $TOKEN
        ```

        Note

        This command opens the proxy and blocks the current shell.
3. In a different shell session, use `kubectl` to send requests to the cluster. For example, run the following command:

    ```console
    kubectl get pods -n default
    ```

If the connection works properly, the response lists all pods in the `default` namespace.

## Known limitations

The following limitation applies when you use cluster connect to access an Azure Arc-enabled Kubernetes cluster.

If you sign in to Azure CLI with a Microsoft Entra ID service principal before running `az connectedk8s proxy`, and that service principal is a member of more than 200 groups, you might see the following error:

`Overage claim (users with more than 200 group membership) for SPN is currently not supported. For troubleshooting, please refer to aka.ms/overageclaimtroubleshoot`

To work around this limitation:

1. Create a [service principal](/en-us/cli/azure/create-an-azure-service-principal-azure-cli), which is less likely to be a member of more than 200 groups.
2. [Sign in](/en-us/cli/azure/create-an-azure-service-principal-azure-cli#sign-in-using-a-service-principal) to Azure CLI with the service principal before running the `az connectedk8s proxy` command.