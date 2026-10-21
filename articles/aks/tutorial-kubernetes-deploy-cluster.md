---
layout: Conceptual
title: Kubernetes on Azure tutorial - Create an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster
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
description: In this Azure Kubernetes Service (AKS) tutorial, you learn how to create an AKS cluster and use kubectl to connect to the Kubernetes main node.
ms.topic: tutorial
ms.date: 2026-06-23T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ai-usage: ai-assisted
ms.custom: mvc, devx-track-azurecli, devx-track-azurepowershell, devx-track-extended-azdevcli, aks-getting-started
locale: en-us
document_id: b1ea7f7e-7f8c-c3a7-c64b-22dc94189490
document_version_independent_id: 67964e9a-4397-a951-d049-06b9015bbefa
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/tutorial-kubernetes-deploy-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/tutorial-kubernetes-deploy-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/tutorial-kubernetes-deploy-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: c6e06eb1-d406-d2e3-e4ab-00109f9995c6
---

# Kubernetes on Azure tutorial - Create an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

Kubernetes provides a distributed platform for containerized applications. With Azure Kubernetes Service (AKS), you can quickly create a production-ready Kubernetes cluster.

In this tutorial, you deploy a Kubernetes cluster in AKS. You learn how to:

- Deploy an AKS cluster that can authenticate to an Azure Container Registry (ACR).
- Install the Kubernetes CLI, `kubectl`.
- Configure `kubectl` to connect to your AKS cluster.

## Before you begin

In previous tutorials, you created a container image and uploaded it to an ACR instance. Start with [Tutorial 1 - Prepare application for AKS](tutorial-kubernetes-prepare-app) to follow along.

This tutorial creates billable AKS cluster resources and requires an **Owner** or **Azure account administrator** role in your Azure subscription.

- If you're using Azure CLI, this tutorial requires that you're running the Azure CLI version 2.35.0 or later. Check your version with `az --version`. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- If you're using Azure PowerShell, this tutorial requires that you're running Azure PowerShell version 5.9.0 or later. Check your version with `Get-InstalledModule -Name Az`. To install or upgrade, see [Install Azure PowerShell](/en-us/powershell/azure/install-az-ps).
- If you're using Azure Developer CLI, this tutorial requires that you're running the Azure Developer CLI version 1.5.1 or later. Check your version with `azd version`. To install or upgrade, see [Install Azure Developer CLI](/en-us/azure/developer/azure-developer-cli/install-azd).

## Create a Kubernetes cluster

AKS clusters can use [Kubernetes role-based access control (Kubernetes RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/), which allows you to define access to resources based on roles assigned to users. If a user is assigned multiple roles, permissions are combined. Permissions can be scoped to either a single namespace or across the whole cluster.

To learn more about AKS and Kubernetes RBAC, see [Control access to cluster resources using Kubernetes RBAC and Microsoft Entra identities in AKS](kubernetes-rbac-entra-id).

# [Azure CLI](#tab/azure-cli)
This tutorial requires Azure CLI version 2.35.0 or later. Check your version with `az --version`. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli). If you're using the Bash environment in Azure Cloud Shell, the latest version is already installed.

# [Azure PowerShell](#tab/azure-powershell)
This tutorial requires Azure PowerShell version 5.9.0 or later. Check your version with `Get-InstalledModule -Name Az`. To install or upgrade, see [Install Azure PowerShell](/en-us/powershell/azure/install-az-ps). If you're using Azure Cloud Shell, the latest version is already installed.

# [Azure Developer CLI](#tab/azure-azd)
This tutorial requires Azure Developer CLI version 1.5.1 or later. Check your version with `azd version`. To install or upgrade, see [Install Azure Developer CLI](/en-us/azure/developer/azure-developer-cli/install-azd).

---

## Install the Kubernetes CLI

You use the Kubernetes CLI, [`kubectl`](https://kubernetes.io/docs/reference/kubectl/), to connect to your Kubernetes cluster. If you use the Azure Cloud Shell, `kubectl` is already installed. If you're running the commands locally, you can use the Azure CLI or Azure PowerShell to install `kubectl`.

# [Azure CLI](#tab/azure-cli)
- Install `kubectl` locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.

    ```azurecli
    az aks install-cli
    ```

# [Azure PowerShell](#tab/azure-powershell)
- Install `kubectl` locally using the [`Install-AzAksCliTool`](/en-us/powershell/module/az.aks/install-azaksclitool) cmdlet.

    ```azurepowershell
    Install-AzAksCliTool
    ```

# [Azure Developer CLI](#tab/azure-azd)
`azd` environments in a codespace automatically download all dependencies found in `./devcontainer/devcontainer.json`. This includes the Kubernetes CLI along with any Azure Container Registry (ACR) images.

- To install `kubectl` locally, use the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.

    ```azurecli
    az aks install-cli
    ```

---

## Create an AKS cluster

AKS clusters can use [Kubernetes role-based access control (Kubernetes RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/), which allows you to define access to resources based on roles assigned to users. Permissions are combined when users are assigned multiple roles. Permissions can be scoped to either a single namespace or across the whole cluster. For more information, see [Control access to cluster resources using Kubernetes RBAC and Microsoft Entra ID in AKS](kubernetes-rbac-entra-id).

# [Azure CLI](#tab/azure-cli)
To allow an AKS cluster to interact with other Azure resources, the Azure platform automatically creates a cluster identity. In this example, the cluster identity is [granted the right to pull images](cluster-container-registry-integration) from the ACR instance you created in the previous tutorial. To execute the command successfully, you must have an **Owner** or **Azure account administrator** role in your Azure subscription.

- Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. The following example creates a cluster named *myAKSCluster* in the resource group named *myResourceGroup*. This resource group was created in the [previous tutorial](tutorial-kubernetes-prepare-acr) in the *westus2* region. We'll continue to use the environment variable, `$ACRNAME`, that we set in the [previous tutorial](tutorial-kubernetes-prepare-acr). If you don't have this environment variable set, set it now to the same value you used previously.

Choose one cluster option and run only the matching command block. You have two options to create an AKS cluster. See [here](intro-aks-automatic) for a detailed comparison.

1. **AKS Automatic** (recommended) — a fully managed Kubernetes experience that automates cluster setup, operations, and node management. Choose this option for simplified operations and to use the [AKS Desktop](aks-desktop-app) application UI with recommended defaults.

    Run this command block only if you chose **AKS Automatic**.

    ```azurecli
    az aks create \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --sku automatic \
        --attach-acr $ACRNAME
    
    AKS_ID=$(az aks show --resource-group myResourceGroup --name myAKSCluster --query id -o tsv)
    ENTRA_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
    
    # Grant yourself admin permissions to the cluster using the Azure Kubernetes Service RBAC Cluster Admin role.
    az role assignment create --role "Azure Kubernetes Service RBAC Cluster Admin" \
        --assignee $ENTRA_OBJECT_ID \
        --scope $AKS_ID
    ```
2. **AKS Standard** — gives you full control over cluster configuration and node management. Choose this option if you need to customize cluster settings. To use [AKS Desktop](aks-desktop-app) with Standard clusters, specify [additional cluster options](aks-desktop-install-cluster-setup#aks-standard-clusters) at creation time.

    Run this command block only if you chose **AKS Standard**.

    Important

    This tutorial creates a three-node cluster. If you get an error message when trying to create the cluster, then you might need to request a quota increase for your Azure subscription or try a different Azure region. Alternatively, you can use fewer nodes, or omit the node VM size parameter to use the default VM size. For information about AKS resource limits and region availability, see [Quotas, virtual machine size restrictions, and region availability in AKS](quotas-skus-regions).

    ```azurecli
    az aks create \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --node-count 3 \
        --node-vm-size standard_l8s_v3 \
        --generate-ssh-keys \
        --attach-acr $ACRNAME
    ```

    Note

    If you already generated SSH keys, you might encounter an error similar to `linuxProfile.ssh.publicKeys.keyData is invalid`. To proceed, retry the command without the `--generate-ssh-keys` parameter.

To avoid needing an **Owner** or **Azure account administrator** role, you can also manually configure a service principal to pull images from ACR. For more information, see [ACR authentication with service principals](/en-us/azure/container-registry/container-registry-auth-service-principal) or [Authenticate from Kubernetes with a pull secret](/en-us/azure/container-registry/container-registry-auth-kubernetes). Alternatively, you can use a [managed identity](use-managed-identity) instead of a service principal for easier management.

# [Azure PowerShell](#tab/azure-powershell)
To allow an AKS cluster to interact with other Azure resources, the Azure platform automatically creates a cluster identity. In this example, the cluster identity is [granted the right to pull images](cluster-container-registry-integration) from the ACR instance you created in the previous tutorial. To execute the command successfully, you need to have an **Owner** or **Azure account administrator** role in your Azure subscription.

- Create an AKS cluster using the [`New-AzAksCluster`](/en-us/powershell/module/az.aks/new-azakscluster) cmdlet. The following example creates a cluster named *myAKSCluster* in the resource group named *myResourceGroup*. This resource group was created in the [previous tutorial](tutorial-kubernetes-prepare-acr) in the *westus2* region.

    ```azurepowershell
    New-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster -NodeCount 3 -NodeVmSize standard_l8s_v3 -GenerateSshKey -AcrNameToAttach $ACRNAME
    ```

    Note

    If you already generated SSH keys, you might encounter an error similar to `linuxProfile.ssh.publicKeys.keyData is invalid`. To proceed, retry the command without the `-GenerateSshKey` parameter.

To avoid needing an **Owner** or **Azure account administrator** role, you can also manually configure a service principal to pull images from ACR. For more information, see [ACR authentication with service principals](/en-us/azure/container-registry/container-registry-auth-service-principal) or [Authenticate from Kubernetes with a pull secret](/en-us/azure/container-registry/container-registry-auth-kubernetes). Alternatively, you can use a [managed identity](use-managed-identity) instead of a service principal for easier management.

# [Azure Developer CLI](#tab/azure-azd)
`azd` packages the deployment of clusters with the application itself using the `azd up` command. This command is covered in the [Deploy containerized application](tutorial-kubernetes-deploy-application) tutorial.

If you're using this path, skip AKS cluster creation commands in this tutorial and continue to the next tutorial.

---

## Connect to cluster using kubectl

# [Azure CLI](#tab/azure-cli)
1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. The following example gets credentials for the AKS cluster named *myAKSCluster* in *myResourceGroup*.

    ```azurecli
    az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
    ```
2. Verify connection to your cluster using the [`kubectl get nodes`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command, which returns a list of cluster nodes.

    ```azurecli
    kubectl get nodes
    ```

    The following example output shows a list of the cluster nodes:

    ```output
    NAME                                STATUS   ROLES   AGE   VERSION
    aks-nodepool1-19366578-vmss000000   Ready    agent   47h   v1.30.9
    aks-nodepool1-19366578-vmss000001   Ready    agent   47h   v1.30.9
    aks-nodepool1-19366578-vmss000002   Ready    agent   47h   v1.30.9
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. Configure `kubectl` to connect to your Kubernetes cluster using the [`Import-AzAksCredential`](/en-us/powershell/module/az.aks/import-azakscredential) cmdlet. The following example gets credentials for the AKS cluster named *myAKSCluster* in *myResourceGroup*.

    ```azurepowershell
    Import-AzAksCredential -ResourceGroupName myResourceGroup -Name myAKSCluster
    ```
2. Verify connection to your cluster using the [`kubectl get nodes`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command, which returns a list of cluster nodes.

    ```azurepowershell
    kubectl get nodes
    ```

    The following example output shows a list of the cluster nodes.

    ```output
    NAME                                STATUS   ROLES   AGE   VERSION
    aks-nodepool1-19366578-vmss000000   Ready    agent   47h   v1.30.9
    aks-nodepool1-19366578-vmss000001   Ready    agent   47h   v1.30.9
    aks-nodepool1-19366578-vmss000002   Ready    agent   47h   v1.30.9
    ```

# [Azure Developer CLI](#tab/azure-azd)
1. Configure authentication to your cluster using the [`azd auth login`](/en-us/azure/developer/azure-developer-cli/reference#azd-auth-login) command.

    ```azdeveloper
    azd auth login 
    ```
2. Follow the directions for your auth method.
3. Verify the connection to your cluster using the [`kubectl get nodes`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```azurecli
    kubectl get nodes
    ```

    The following example output shows a list of the cluster nodes:

    ```output
    NAME                                STATUS   ROLES   AGE   VERSION
    aks-nodepool1-19366578-vmss000000   Ready    agent   47h   v1.30.9
    aks-nodepool1-19366578-vmss000001   Ready    agent   47h   v1.30.9
    aks-nodepool1-19366578-vmss000002   Ready    agent   47h   v1.30.9
    ```

### azd auth workaround

This workaround requires you to have the [Azure CLI](/en-us/cli/azure/install-azure-cli) installed.

1. Open a terminal window and log in with the Azure CLI using the [`az login`](/en-us/cli/azure/#az-login) command with the `--scope` parameter set to `https://graph.microsoft.com/.default`.

    ```azurecli
    az login --scope https://graph.microsoft.com/.default
    ```

    You should be redirected to an authentication page in a new tab to create a browser access token, as shown in the following example:

    ```output
    https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize?clientid=<your_client_id>.
    ```
2. Copy the localhost URL of the webpage you received after attempting to sign in with `azd auth login`.
3. In a new terminal window, use the following `curl` request to log in. Make sure you replace the `<localhost>` placeholder with the localhost URL you copied in the previous step.

    ```console
    curl <localhost>
    ```

    A successful login outputs an HTML webpage, as shown in the following example:

    ```output
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8" />
        <meta http-equiv="refresh" content="60;url=https://docs.microsoft.com/cli/azure/">
        <title>Login successfully</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
    
            code {
                font-family: Consolas, 'Liberation Mono', Menlo, Courier, monospace;
                display: inline-block;
                background-color: rgb(242, 242, 242);
                padding: 12px 16px;
                margin: 8px 0px;
            }
        </style>
    </head>
    <body>
        <h3>You have logged into Microsoft Azure!</h3>
        <p>You can close this window, or we will redirect you to the <a href="https://docs.microsoft.com/cli/azure/">Azure CLI documentation</a> in 1 minute.</p>
        <h3>Announcements</h3>
        <p>[Windows only] Azure CLI is collecting feedback on using the <a href="https://learn.microsoft.com/windows/uwp/security/web-account-manager">Web Account Manager</a> (WAM) broker for the login experience.</p>
        <p>You may opt-in to use WAM by running the following commands:</p>
        <code>
            az config set core.allow_broker=true<br>
            az account clear<br>
            az login
        </code>
    </body>
    </html>
    ```
4. Close the current terminal and open the original terminal. You should see a JSON list of your subscriptions.
5. Copy the `id` field of the subscription you want to use.
6. Set your subscription using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription <subscription_id>
    ```

---