---
layout: Conceptual
title: Use a Service Principal with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kubernetes-service-principal
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
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to create and manage a Microsoft Entra service principal with a cluster in Azure Kubernetes Service (AKS).
author: schaffererin
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2024-05-30T00:00:00.0000000Z
ms.author: shasb
ms.custom: devx-track-azurepowershell, devx-track-azurecli
zone_pivot_groups: kubernetes-service-principal
locale: en-us
document_id: 8d0ed331-8ec8-5298-cb98-39e8c652f287
document_version_independent_id: 5668d233-434f-4853-67d7-d71b33ba8c12
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kubernetes-service-principal.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli,azurepowershell
toc_rel: toc.json
asset_id: aks/kubernetes-service-principal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kubernetes-service-principal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
platformId: 7c32f6e4-3314-abba-4537-10643196ba56
---

# Use a Service Principal with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) clusters require either a [Microsoft Entra service principal](/en-us/entra/identity-platform/app-objects-and-service-principals) or a [managed identity](/en-us/azure/active-directory/managed-identities-azure-resources/overview) to dynamically create and manage other Azure resources. This article describes how to create a Microsoft Entra service principal and use it with your AKS cluster.

Note

For optimal security and ease of use, we recommend using managed identities instead of service principals to authorize access from an AKS cluster to other resources in Azure. A managed identity is a special type of service principal that you can use to get Microsoft Entra credentials without the need to manage and secure credentials. For more information, see [Use a managed identity in AKS](use-managed-identity).

## Prerequisites

::: zone pivot="azure-cli"

- You need Azure CLI version 2.0.59 or higher. Find your version using the `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

::: zone-end

::: zone pivot="azure-powershell"

- If using Azure PowerShell, you need Azure PowerShell version 5.0.0 or higher. Find your version using the `Get-InstalledModule -Name Az` cmdlet. If you need to install or upgrade, see [Install the Azure Az PowerShell module](/en-us/powershell/azure/install-az-ps).

::: zone-end

- You need permissions to register an application with your Microsoft Entra tenant and to assign the application to a role in your subscription. If you don't have the necessary permissions, you need to ask your Microsoft Entra ID or subscription administrator to assign the necessary permissions or create the service principal for you.

## Considerations when using a service principal

Keep the following considerations in mind when using a Microsoft Entra service principal with AKS:

- The service principal for Kubernetes is a part of the cluster configuration, but don't use this identity to deploy the cluster. Instead, create a service principal first, then use that service principal to create the AKS cluster.
- Every service principal is associated with a Microsoft Entra application. You can associate the service principal for a Kubernetes cluster with any valid Microsoft Entra application name (for example: `https://www.contoso.org/example`). The URL for the application doesn't have to be a real endpoint.
- When you specify the service principal **client ID**, use the value of the application ID (`appId` for Azure CLI or `ApplicationId` for Azure PowerShell).
- On the agent node virtual machines (VMs) in the AKS cluster, the service principal credentials are stored in the `/etc/kubernetes/azure.json` file.
- When you delete an AKS cluster that you created using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command or the [`New-AzAksCluster`](/en-us/powershell/module/az.aks/new-azakscluster) cmdlet, the service principal created isn't automatically deleted. See the steps to delete a service principal.
- If you're using a service principal from a different Microsoft Entra tenant, there are other considerations around the permissions available when you deploy the cluster. You might not have the appropriate permissions to read and write directory information. For more information, see [What are the default user permissions in Microsoft Entra ID?](/en-us/azure/active-directory/fundamentals/users-default-permissions)

## Create a service principal

::: zone pivot="azure-cli"

1. Create a service principal using the [`az ad sp create-for-rbac`](/en-us/cli/azure/ad/sp#az-ad-sp-create-for-rbac) command.

    ```azurecli
    # Set environment variable
    SERVICE_PRINCIPAL_NAME=<your-service-principal-name>
    
    # Create the service principal
    az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME
    ```

    Your output should be similar to the following example output:

    ```output
    {
      "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "displayName": "myAKSClusterServicePrincipal",
      "name": "http://myAKSClusterServicePrincipal",
      "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    }
    ```
2. Copy the values for `appId` and `password` from the output to use when creating the AKS cluster.

::: zone-end

::: zone pivot="azure-powershell"

1. Create a service principal using the [`New-AzADServicePrincipal`](/en-us/powershell/module/az.resources/new-azadserviceprincipal) command.

    ```azurepowershell
    # Set environment variable
    $SpName = <your-service-principal-name>
    
    # Create the service principal
    New-AzADServicePrincipal -DisplayName $SpName -OutVariable sp
    ```

    Your output should be similar to the following example output:

    ```output
    Secret                : System.Security.SecureString
    ServicePrincipalNames : {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx, http://myAKSClusterServicePrincipal}
    ApplicationId         : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    ObjectType            : ServicePrincipal
    DisplayName           : myAKSClusterServicePrincipal
    Id                    : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    Type                  :
    ```

    The values are stored in a variable that you use when creating the AKS cluster.
2. Decrypt the value stored in the **Secret** secure string using the following command.

    ```azurepowershell
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)
    [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    ```

::: zone-end

## Create an AKS cluster with an existing service principal

::: zone pivot="azure-cli"

- Create an AKS cluster with an existing service principal using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--service-principal` and `--client-secret` parameters set to specify the `appId` and `password` values.

    ```azurecli
    # Set environment variables
    RESOURCE_GROUP=<your-resource-group-name>
    CLUSTER_NAME=<your-aks-cluster-name>
    APP_ID=<app-id>
    CLIENT_SECRET=<password-value>
    
    # Create the AKS cluster
    az aks create \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --service-principal $APP_ID \
        --client-secret $CLIENT_SECRET \
        --generate-ssh-keys
    ```

::: zone-end

::: zone pivot="azure-powershell"

1. Convert the service principal `ApplicationId` and `Secret` to a **PSCredential** object using the following command.

    ```azurepowershell
    $Cred = New-Object -TypeName System.Management.Automation.PSCredential ($sp.ApplicationId, $sp.Secret)
    ```
2. Create an AKS cluster with an existing service principal using the [`New-AzAksCluster`](/en-us/powershell/module/az.aks/new-azakscluster) cmdlet and specify the `ServicePrincipalIdAndSecret` parameter with the **PSCredential** object as its value.

    ```azurepowershell
    # Set environment variables
    $ResourceGroupName = <your-resource-group-name>
    $ClusterName = <your-aks-cluster-name>
    
    # Create the AKS cluster
    New-AzAksCluster -ResourceGroupName $ResourceGroupName -Name $ClusterName -ServicePrincipalIdAndSecret $Cred
    ```

::: zone-end

Note

If you're using an existing service principal with customized secret, make sure the secret isn't longer than 190 bytes.

## Delegate access to other Azure resources

You can use the service principal for the AKS cluster to access other resources. For example, if you want to deploy your AKS cluster into an existing Azure virtual network (VNet) subnet, connect to ACR, or access keys or secrets in a key vault from your cluster, then you need to delegate access to those resources to the service principal. To delegate access, assign an Azure role-based access control (Azure RBAC) role to the service principal.

When you assign roles, you specify the scope for the role assignment, such as a resource group or VNet resource. The role assignment determines what permissions the service principal has on the resource and at what scope.

Important

Permissions granted to a service principal associated with a cluster can take up 60 minutes to propagate.

## Create a role assignment

Note

The scope for a resource needs to be a full resource ID, such as `/subscriptions/\<guid\>/resourceGroups/myResourceGroup` or `/subscriptions/\<guid\>/resourceGroups/myResourceGroupVnet/providers/Microsoft.Network/virtualNetworks/myVnet`.

::: zone pivot="azure-cli"

- Create a role assignment using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. Specify the value of the service principal app ID for the `--assignee` parameter and the scope for the role assignment for the `--scope` parameter. The following example assigns the service principal permissions to access secrets in a key vault:

    ```azurecli
    az role assignment create \
        --assignee <app-id> \
        --scope "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<vault-name>" \
        --role "Key Vault Secrets User"
    ```

::: zone-end

::: zone pivot="azure-powershell"

- Create a role assignment using the [`New-AzRoleAssignment`](/en-us/powershell/module/az.resources/new-azroleassignment) cmdlet. Specify the value of the service principal app ID for the `-ApplicationId` parameter and the scope for the role assignment for the `-Scope` parameter. The following example assigns the service principal permissions to access secrets in a key vault:

    ```azurepowershell
    New-AzRoleAssignment -ApplicationId <app-id> `
        -Scope "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<vault-name>" `
        -RoleDefinitionName "Key Vault Secrets User"
    ```

::: zone-end

## Grant access to Azure Container Registry

If you use Azure Container Registry (ACR) as your container image store, you need to grant permissions to the service principal for your AKS cluster to read and pull images. We recommend following the steps in [Authenticate with Azure Container Registry from Azure Kubernetes Service](cluster-container-registry-integration) to integrate with a registry and assign the appropriate role for the service principal.

## Grant access to networking resources

If you're using advanced networking with a VNet and subnet or public IP addresses in different resource group, you can assign the [Network Contributor](/en-us/azure/role-based-access-control/built-in-roles#network-contributor) built-in role on the subnet within the VNet. Alternatively, you can create a [custom role](/en-us/azure/role-based-access-control/custom-roles) with permissions to access the network resources in that resource group. For more information, see [AKS service permissions](concepts-identity#aks-service-permissions).

## Grant access to storage disks

If you need to access existing disk resources in another resource group, assign one of the following sets of role permissions:

- Create a [custom role](/en-us/azure/role-based-access-control/custom-roles) and define the *Microsoft.Compute/disks/read* and *Microsoft.Compute/disks/write* role permissions.
- Assign the [Virtual Machine Contributor](/en-us/azure/role-based-access-control/built-in-roles#virtual-machine-contributor) built-in role on the resource group.

## Grant access to Azure Container Instances

If you use virtual kubelet to integrate with AKS and run Azure Container Instances (ACI) in resource group separate from the AKS cluster, you need to assign *Contributor* permissions to the AKS cluster service principal for the ACI resource group.

## Delete a service principal

::: zone pivot="azure-cli"

- Query for the service principal client ID (`servicePrincipalProfile.clientId`) and delete the service principal using the [`az ad sp delete`](/en-us/cli/azure/ad/sp#az-ad-sp-delete) command with the `--id` parameter. The [`az aks show`][az-aks-show] command retrieves the client ID for the specified AKS cluster.

    ```azurecli
    # Set environment variables
    RESOURCE_GROUP=<your-resource-group-name>
    CLUSTER_NAME=<your-aks-cluster-name>
    
    # Delete the service principal
    az ad sp delete --id $(az aks show \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --query servicePrincipalProfile.clientId \
        --output tsv)
    ```

::: zone-end

::: zone pivot="azure-powershell"

- Query for the service principal client ID (`ServicePrincipalProfile.ClientId`) and delete the service principal using the [`Remove-AzADServicePrincipal`](/en-us/powershell/module/az.resources/remove-azadserviceprincipal) cmdlet with the `-ApplicationId` parameter. The [`Get-AzAksCluster`][get-azakscluster] cmdlet retrieves the client ID for the specified AKS cluster.

    ```azurepowershell
    # Set environment variables
    $ResourceGroupName = <your-resource-group-name>
    $ClusterName = <your-aks-cluster-name>
    $ClientId = (Get-AzAksCluster -ResourceGroupName myResourceGroup -Name myAKSCluster ).ServicePrincipalProfile.ClientId
    
    # Delete the service principal
    Remove-AzADServicePrincipal -ApplicationId $ClientId
    ```

::: zone-end

## Resolve service principal credential issues

::: zone pivot="azure-cli"

Azure CLI caches the service principal credentials for AKS clusters.

::: zone-end

::: zone pivot="azure-powershell"

Azure PowerShell caches the service principal credentials for AKS clusters.

::: zone-end

If these credentials expire, you might encounter errors during AKS cluster deployment. If there's an issue with the cached credentials, you might receive an error message similar to the following error message:

```output
Operation failed with status: 'Bad Request'.
Details: The credentials in ServicePrincipalProfile were invalid. Please see https://aka.ms/aks-sp-help for more details.
Details: adal: Refresh request failed. Status Code = '401'.
```

::: zone pivot="azure-cli"

You can check the expiration date of your service principal credentials using the [`az ad app credential list`](/en-us/cli/azure/ad/app/credential#az-ad-app-credential-list) command with the `"[].endDateTime"` query. The output shows you the `endDateTime` of your credentials.

```azurecli
az ad app credential list \
    --id <app-id> \
    --query "[].endDateTime" \
    --output tsv
```

::: zone-end

::: zone pivot="azure-powershell"

- Check the expiration date of your service principal credentials using the [`Get-AzADAppCredential`](/en-us/powershell/module/az.resources/get-azadappcredential) cmdlet. The output shows you the `EndDate` of your credentials.

```azurepowershell
Get-AzADAppCredential -ApplicationId <app-id> 
```

::: zone-end

**The default expiration time for the service principal credentials is one year**. If your credentials are older than one year, you can [reset the existing credentials](update-credentials#reset-the-existing-service-principal-credentials) or [create a new service principal](update-credentials#create-a-new-service-principal).