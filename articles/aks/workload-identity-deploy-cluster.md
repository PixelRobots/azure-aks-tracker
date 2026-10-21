---
layout: Conceptual
title: Deploy and Configure an Azure Kubernetes Service (AKS) Cluster with Microsoft Entra Workload ID - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster
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
description: This article shows you how to deploy an AKS cluster and configure it with Microsoft Entra Workload ID, including creating a managed identity, Kubernetes service account, and federated identity credential.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.subservice: aks-security
ms.custom: devx-track-azurecli, innovation-engine
ms.date: 2026-07-31T00:00:00.0000000Z
zone_pivot_groups: azure-cli-or-terraform
locale: en-us
document_id: ef12c3f7-4ef2-e064-4fa9-ac187a0a9ed7
document_version_independent_id: 80aeac64-0221-05fc-0736-c4c01c8f00e8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/workload-identity-deploy-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/workload-identity-deploy-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/workload-identity-deploy-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/f233afb4-f511-4877-ab18-c53e36c47c54
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/aa758f63-7086-440d-afba-dcb5819f0b6f
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 58963fa3-148d-7960-005c-c222c6ea492f
---

# Deploy and Configure an Azure Kubernetes Service (AKS) Cluster with Microsoft Entra Workload ID - Azure Kubernetes Service | Microsoft Learn

In this article, you learn how to deploy and configure an Azure Kubernetes Service (AKS) cluster with [Microsoft Entra Workload ID](workload-identity-overview). The steps in this article include:

- Create a new or update an existing AKS cluster using the Azure CLI or Terraform with OpenID Connect (OIDC) issuer and Microsoft Entra Workload ID enabled.
- Create a workload identity and Kubernetes service account.
- Configure the managed identity for token federation.
- Deploy the workload and verify authentication with the workload identity.
- Optionally grant a pod in the cluster access to secrets in an Azure key vault.

## Prerequisites

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- This article requires version 2.47.0 or later of the Azure CLI. If using Azure Cloud Shell, the latest version is already installed. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Make sure that the identity that you're using to create your cluster has the appropriate minimum permissions. For more information, see [Access and identity options for Azure Kubernetes Service (AKS)](concepts-identity).
- Make sure that your identity has permission to create role assignments at the key vault scope, such as the [Role Based Access Control Administrator](/en-us/azure/role-based-access-control/built-in-roles/privileged#role-based-access-control-administrator) role. The Contributor and Key Vault Contributor roles can't create role assignments.
- If you have multiple Azure subscriptions, select the appropriate subscription ID in which the resources should be billed using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

::: zone pivot="terraform"

- Terraform installed locally. For installation instructions, see [Install Terraform](https://developer.hashicorp.com/terraform/install).
- The `ARM_SUBSCRIPTION_ID` environment variable set to the subscription ID where you want to create the resources. AzureRM 4.x requires the subscription ID for plan and apply operations.

::: zone-end

Note

You can use *Service Connector* to help you configure some steps automatically. For more information, see [Tutorial: Connect to Azure storage account in Azure Kubernetes Service (AKS) with Service Connector using Microsoft Entra Workload ID](/en-us/azure/service-connector/tutorial-python-aks-storage-workload-identity).

::: zone pivot="terraform"

## Create the Terraform configuration file

The `main.tf` file includes definitions for the AKS cluster, managed identity, federated identity credential, Azure Key Vault, and Kubernetes resources used to configure and verify Microsoft Entra Workload ID.

1. Create a file named `main.tf` and add the following code to define the Terraform version and specify the Azure provider:

    ```Terraform
    terraform {
     required_version = ">= 1.5.0"
     required_providers {
       azurerm = {
         source  = "hashicorp/azurerm"
         version = "~> 4.0"
       }
       kubernetes = {
         source  = "hashicorp/kubernetes"
         version = "~> 2.30"
       }
       random = {
         source  = "hashicorp/random"
         version = "~> 3.6"
       }
     }
    }
    provider "azurerm" {
     features {}
    }
    data "azurerm_client_config" "current" {}
    ```
2. Add the following code to `main.tf` to define reusable variables and generate unique names for all resources:

    ```Terraform
    resource "random_string" "suffix" {
     length  = 6
     upper   = false
     special = false
     numeric = true
    }
    locals {
     suffix = random_string.suffix.result
     resource_group_name       = "rg-aks-wi-${local.suffix}"
     cluster_name              = "akswi${local.suffix}"
     managed_identity_name     = "uami-wi-${local.suffix}"
     federated_credential_name = "fic-wi-${local.suffix}"
     key_vault_name            = lower(substr("kvwi${local.suffix}", 0, 24))
     secret_name               = "secret-${local.suffix}"
     service_account_name      = "workload-sa-${local.suffix}"
     service_account_namespace = "default"
     workload_identity_subject = "system:serviceaccount:${local.service_account_namespace}:${local.service_account_name}"
    }
    ```

::: zone-end

## Create a resource group

::: zone pivot="azure-cli"

Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

```azurecli
export RANDOM_ID="$(openssl rand -hex 3)"
export RESOURCE_GROUP="myResourceGroup$RANDOM_ID"
export LOCATION="<your-preferred-region>"
az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}"
```

::: zone-end

::: zone pivot="terraform"

Add the following code to `main.tf` to create an Azure resource group. Update the `location` value to match your preferred Azure region.

```Terraform
resource "azurerm_resource_group" "this" {
 name     = local.resource_group_name
 location = "eastus"
}
```

::: zone-end

## Enable OIDC issuer and Microsoft Entra Workload ID on an AKS cluster

You can enable OIDC issuer and Microsoft Entra Workload ID on a new or existing AKS cluster.

# [Create a new AKS cluster](#tab/new-cluster)
::: zone pivot="azure-cli"

Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-oidc-issuer` parameter to enable OIDC issuer and the `--enable-workload-identity` parameter to enable Microsoft Entra Workload ID. The following example creates a cluster with a single node:

```azurecli
export CLUSTER_NAME="myAKSCluster$RANDOM_ID"
az aks create \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --enable-oidc-issuer \
    --enable-workload-identity \
    --generate-ssh-keys
```

After a few minutes, the command completes and returns JSON-formatted information about the cluster.

::: zone-end

::: zone pivot="terraform"

Add the following code to `main.tf` to create an AKS cluster with OIDC issuer and Microsoft Entra Workload ID enabled:

```Terraform
resource "azurerm_kubernetes_cluster" "this" {
 name                              = local.cluster_name
 location                          = azurerm_resource_group.this.location
 resource_group_name               = azurerm_resource_group.this.name
 dns_prefix                        = local.cluster_name
 oidc_issuer_enabled               = true
 workload_identity_enabled         = true
 role_based_access_control_enabled = true
 default_node_pool {
   name       = "system"
   node_count = 1
   vm_size    = "Standard_B4ms"
 }
 identity {
   type = "SystemAssigned"
 }
}
```

::: zone-end

# [Update an existing AKS cluster](#tab/existing-cluster)
::: zone pivot="azure-cli"

Update an existing AKS cluster to enable OIDC issuer and Microsoft Entra Workload ID using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-oidc-issuer` and the `--enable-workload-identity` parameters.

```azurecli
az aks update \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --enable-oidc-issuer \
    --enable-workload-identity
```

::: zone-end

::: zone pivot="terraform"

If you already have an existing AKS cluster managed by Terraform, you can update the `azurerm_kubernetes_cluster` resource in your `main.tf` file to enable OIDC issuer and Microsoft Entra Workload ID:

```Terraform
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
```

::: zone-end

---

## Retrieve the OIDC issuer URL

::: zone pivot="azure-cli"

Get the OIDC issuer URL using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command and save it to an environmental variable.

```azurecli
export AKS_OIDC_ISSUER="$(az aks show --name "${CLUSTER_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --query "oidcIssuerProfile.issuerUrl" \
    --output tsv)"
```

The environment variable should contain the issuer URL, similar to the following example:

```output
https://eastus.oic.prod-aks.azure.com/00000000-0000-0000-0000-000000000000/11111111-1111-1111-1111-111111111111/
```

By default, the issuer is set to use the base URL `https://{region}.oic.prod-aks.azure.com/{tenant_id}/{uuid}`, where the value for `{region}` matches the location to which the AKS cluster is deployed. The value `{uuid}` represents the OIDC key, which is a randomly generated and immutable GUID for each cluster.

::: zone-end

::: zone pivot="terraform"

Add the following code to `main.tf` to retrieve the OIDC issuer URL:

```Terraform
output "oidc_issuer_url" {
 value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}
```

::: zone-end

## Create a managed identity

::: zone pivot="azure-cli"

1. Get your subscription ID and save it to an environment variable using the [`az account show`](/en-us/cli/azure/account#az-account-show) command.

    ```azurecli
    export SUBSCRIPTION="$(az account show --query id --output tsv)"
    ```
2. Create a user-assigned managed identity using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    ```azurecli
    export USER_ASSIGNED_IDENTITY_NAME="myIdentity$RANDOM_ID"
    az identity create \
        --name "${USER_ASSIGNED_IDENTITY_NAME}" \
        --resource-group "${RESOURCE_GROUP}" \
        --location "${LOCATION}" \
        --subscription "${SUBSCRIPTION}"
    ```

    The following output example shows successful creation of a managed identity:

    ```output
    {
      "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/myResourceGroupxxxxxx/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myIdentityxxxxxx",
      "location": "eastus",
      "name": "myIdentityxxxxxx",
      "principalId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "resourceGroup": "myResourceGroupxxxxxx",
      "systemData": null,
      "tags": {},
      "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "type": "Microsoft.ManagedIdentity/userAssignedIdentities"
    }
    ```
3. Get the client ID of the managed identity and save it to an environment variable using the [`az identity show`](/en-us/cli/azure/identity#az-identity-show) command.

    ```azurecli
    export USER_ASSIGNED_CLIENT_ID="$(az identity show \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${USER_ASSIGNED_IDENTITY_NAME}" \
        --query 'clientId' \
        --output tsv)"
    ```

::: zone-end

::: zone pivot="terraform"

Add the following code to `main.tf` to create a managed identity:

```Terraform
resource "azurerm_user_assigned_identity" "this" {
 name                = local.managed_identity_name
 location            = azurerm_resource_group.this.location
 resource_group_name = azurerm_resource_group.this.name
}
```

::: zone-end

## Create a Kubernetes service account

::: zone pivot="azure-cli"

1. Connect to your AKS cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --name "${CLUSTER_NAME}" --resource-group "${RESOURCE_GROUP}"
    ```
2. Create a Kubernetes service account and annotate it with the client ID of the managed identity by applying the following manifest using the [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) command.

    ```azurecli
    export SERVICE_ACCOUNT_NAME="workload-identity-sa$RANDOM_ID"
    export SERVICE_ACCOUNT_NAMESPACE="default"
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      annotations:
        azure.workload.identity/client-id: "${USER_ASSIGNED_CLIENT_ID}"
      name: "${SERVICE_ACCOUNT_NAME}"
      namespace: "${SERVICE_ACCOUNT_NAMESPACE}"
    EOF
    ```

    The following output shows successful creation of the workload identity:

    ```output
    serviceaccount/workload-identity-sa created
    ```

::: zone-end

::: zone pivot="terraform"

1. Add the following code to `main.tf` to configure Kubernetes access to allow creation of Kubernetes resources:

    ```Terraform
    data "azurerm_kubernetes_cluster" "this" {
     name                = azurerm_kubernetes_cluster.this.name
     resource_group_name = azurerm_resource_group.this.name
    }
    provider "kubernetes" {
     host                   = data.azurerm_kubernetes_cluster.this.kube_config[0].host
     client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
     client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_key)
     cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
    }
    ```
2. Add the following code to `main.tf` to create a Kubernetes service account and annotate it with the client ID of the managed identity:

    ```Terraform
    resource "kubernetes_service_account" "this" {
     metadata {
       name      = local.service_account_name
       namespace = local.service_account_namespace
       annotations = {
         "azure.workload.identity/client-id" = azurerm_user_assigned_identity.this.client_id
       }
     }
    }
    ```

::: zone-end

## Create the federated identity credential

::: zone pivot="azure-cli"

Create a federated identity credential between the managed identity, the service account issuer, and the subject using the [`az identity federated-credential create`](/en-us/cli/azure/identity/federated-credential#az-identity-federated-credential-create) command.

```azurecli
export FEDERATED_IDENTITY_CREDENTIAL_NAME="myFedIdentity$RANDOM_ID"
az identity federated-credential create \
    --name ${FEDERATED_IDENTITY_CREDENTIAL_NAME} \
    --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --issuer "${AKS_OIDC_ISSUER}" \
    --subject system:serviceaccount:"${SERVICE_ACCOUNT_NAMESPACE}":"${SERVICE_ACCOUNT_NAME}" \
    --audience api://AzureADTokenExchange
```

Note

It takes a few seconds for the federated identity credential to propagate after it's added. If a token request is made immediately after adding the federated identity credential, the request might fail until the cache is refreshed. To avoid this issue, you can add a slight delay after adding the federated identity credential.

Warning

The audience listed above is the default and recommended audience for Microsoft Entra Workload Identity. This value is global and consistent across all Azure clouds, changing the audience value might break compatibility with existing configurations and isn't recommended unless explicitly required.

::: zone-end

::: zone pivot="terraform"

Add the following code to `main.tf` to create a federated identity credential between the managed identity, the service account issuer, and the subject:

```Terraform
resource "azurerm_federated_identity_credential" "this" {
 name                = local.federated_credential_name
 resource_group_name = azurerm_resource_group.this.name
 parent_id           = azurerm_user_assigned_identity.this.id
 issuer              = azurerm_kubernetes_cluster.this.oidc_issuer_url
 subject             = local.workload_identity_subject
 audience            = ["api://AzureADTokenExchange"]
}
```

Warning

The audience listed above is the default and recommended audience for Microsoft Entra Workload Identity. This value is global and consistent across all Azure clouds, changing the audience value might break compatibility with existing configurations and isn't recommended unless explicitly required.

::: zone-end

For more information about federated identity credentials in Microsoft Entra, see [Overview of federated identity credentials in Microsoft Entra ID](/en-us/graph/api/resources/federatedidentitycredentials-overview).

## Create an Azure Key Vault with Azure RBAC authorization

The following steps use the Azure role-based access control (Azure RBAC) permission model. For background, see [Grant permission to applications to access an Azure key vault using Azure RBAC](/en-us/azure/key-vault/general/rbac-guide).

::: zone pivot="azure-cli"

1. Create a key vault with purge protection and Azure RBAC authorization enabled using the [`az keyvault create`](/en-us/cli/azure/keyvault#az-keyvault-create) command. You can also use an existing key vault if it's configured for both purge protection and Azure RBAC authorization.

    ```azurecli
    export KEYVAULT_NAME="kv-workload-id$RANDOM_ID"
    az keyvault create \
        --name "${KEYVAULT_NAME}" \
        --resource-group "${RESOURCE_GROUP}" \
        --location "${LOCATION}" \
        --enable-purge-protection \
        --enable-rbac-authorization
    ```
2. Get the key vault resource ID and save it to an environment variable using the [`az keyvault show`](/en-us/cli/azure/keyvault#az-keyvault-show) command.

    ```azurecli
    export KEYVAULT_RESOURCE_ID=$(az keyvault show --resource-group "${RESOURCE_GROUP}" \
        --name "${KEYVAULT_NAME}" \
        --query id \
        --output tsv)
    ```

::: zone-end

::: zone pivot="terraform"

Add the following code to `main.tf` to create a key vault with purge protection and Azure RBAC authorization enabled:

```Terraform
resource "azurerm_key_vault" "this" {
 name                       = local.key_vault_name
 location                   = azurerm_resource_group.this.location
 resource_group_name        = azurerm_resource_group.this.name
 tenant_id                  = data.azurerm_client_config.current.tenant_id
 sku_name                   = "standard"
 enable_rbac_authorization  = true
 purge_protection_enabled   = true
}
```

::: zone-end

### Assign RBAC permissions for Azure Key Vault management

::: zone pivot="azure-cli"

1. Get the caller object ID and save it to an environment variable using the [`az ad signed-in-user show`](/en-us/cli/azure/ad/signed-in-user#az-ad-signed-in-user-show) command.

    ```azurecli
    export CALLER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
    ```
2. Assign yourself the Azure RBAC [Key Vault Secrets Officer](/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-officer) role so that you can create a secret in the new key vault using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create --assignee "${CALLER_OBJECT_ID}" \
        --role "Key Vault Secrets Officer" \
        --scope "${KEYVAULT_RESOURCE_ID}"
    ```

    Important

    Azure role assignments can take up to 10 minutes to propagate. If creating the secret in the next section returns a `403` error, wait for the role assignment to propagate, and then retry the command. For more information, see [Troubleshoot Azure RBAC](/en-us/azure/role-based-access-control/troubleshooting).

::: zone-end

::: zone pivot="terraform"

Add the following code to `main.tf` to assign yourself the Azure RBAC [Key Vault Secrets Officer](/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-officer) role so that you can create a secret in the new key vault and assign the [Key Vault Secrets User](/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-user) role to the user-assigned managed identity:

```Terraform
resource "azurerm_role_assignment" "user" {
 scope                = azurerm_key_vault.this.id
 role_definition_name = "Key Vault Secrets Officer"
 principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_role_assignment" "identity" {
 scope                = azurerm_key_vault.this.id
 role_definition_name = "Key Vault Secrets User"
 principal_id         = azurerm_user_assigned_identity.this.principal_id
}
```

::: zone-end

### Create and configure secret access

::: zone pivot="azure-cli"

1. Create a secret in the key vault using the [`az keyvault secret set`](/en-us/cli/azure/keyvault/secret#az-keyvault-secret-set) command.

    Create a secret whose name is stored in the `KEYVAULT_SECRET_NAME` variable, and set its value to `Hello!` in the key vault you created.

    ```azurecli
    export KEYVAULT_SECRET_NAME="my-secret$RANDOM_ID"
    az keyvault secret set \
        --vault-name "${KEYVAULT_NAME}" \
        --name "${KEYVAULT_SECRET_NAME}" \
        --value 'Hello!'
    ```
2. Get the principal ID of the user-assigned managed identity and save it to an environment variable using the [`az identity show`](/en-us/cli/azure/identity#az-identity-show) command.

    ```azurecli
    export IDENTITY_PRINCIPAL_ID=$(az identity show \
        --name "${USER_ASSIGNED_IDENTITY_NAME}" \
        --resource-group "${RESOURCE_GROUP}" \
        --query principalId \
        --output tsv)
    ```
3. Assign the [Key Vault Secrets User](/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-user) role to the user-assigned managed identity using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. This step gives the managed identity permission to read secrets from the key vault.

    ```azurecli
    az role assignment create \
        --assignee-object-id "${IDENTITY_PRINCIPAL_ID}" \
        --role "Key Vault Secrets User" \
        --scope "${KEYVAULT_RESOURCE_ID}" \
        --assignee-principal-type ServicePrincipal
    ```
4. Create an environment variable for the key vault URL using the [`az keyvault show`](/en-us/cli/azure/keyvault#az-keyvault-show) command.

    ```azurecli
    export KEYVAULT_URL="$(az keyvault show \
        --resource-group "${RESOURCE_GROUP}" \
        --name ${KEYVAULT_NAME} \
        --query properties.vaultUri \
        --output tsv)"
    ```

::: zone-end

::: zone pivot="terraform"

Add the following code to `main.tf` to create a secret in the key vault:

```Terraform
resource "azurerm_key_vault_secret" "this" {
 name         = local.secret_name
 value        = "Hello from Key Vault"
 key_vault_id = azurerm_key_vault.this.id

 depends_on = [azurerm_role_assignment.user]
}
```

Important

Azure role assignments can take up to 10 minutes to propagate. If `terraform apply` returns a `403` error while creating the secret, wait for the role assignment to propagate, and then rerun the command. For more information, see [Troubleshoot Azure RBAC](/en-us/azure/role-based-access-control/troubleshooting).

::: zone-end

::: zone pivot="azure-cli"

## Deploy a verification pod and test access (Azure CLI)

1. Deploy a pod to verify that the workload identity can access the secret in the key vault. The following example uses the `ghcr.io/azure/azure-workload-identity/msal-go` image, which contains a sample application that retrieves a secret from Azure Key Vault using Microsoft Entra Workload ID:

    ```bash
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Pod
    metadata:
        name: sample-workload-identity-key-vault
        namespace: ${SERVICE_ACCOUNT_NAMESPACE}
        labels:
            azure.workload.identity/use: "true"
    spec:
        serviceAccountName: ${SERVICE_ACCOUNT_NAME}
        containers:
          - image: ghcr.io/azure/azure-workload-identity/msal-go
            name: oidc
            env:
              - name: KEYVAULT_URL
                value: ${KEYVAULT_URL}
              - name: SECRET_NAME
                value: ${KEYVAULT_SECRET_NAME}
        nodeSelector:
            kubernetes.io/os: linux
    EOF
    ```
2. Wait for the pod to be in the `Ready` state using the [`kubectl wait`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#wait) command.

    ```bash
    kubectl wait --namespace ${SERVICE_ACCOUNT_NAMESPACE} --for=condition=Ready pod/sample-workload-identity-key-vault --timeout=120s
    ```
3. Check that the `SECRET_NAME` environment variable is set in the pod using the [`kubectl describe`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command.

    ```bash
    kubectl describe pod sample-workload-identity-key-vault | grep "SECRET_NAME:"
    ```

    If successful, the output should be similar to the following example:

    ```output
    SECRET_NAME: ${KEYVAULT_SECRET_NAME}
    ```
4. Verify that pods can get a token and access the resource using the [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs) command.

    ```bash
    kubectl logs sample-workload-identity-key-vault
    ```

    If successful, the output should be similar to the following example:

    ```output
    I0114 10:35:09.795900       1 main.go:63] "successfully got secret" secret="Hello!"
    ```

    Important

    Azure RBAC role assignments can take up to 10 minutes to propagate. If the pod is unable to access the secret, you might need to wait for the role assignment to propagate. For more information, see [Troubleshoot Azure RBAC](/en-us/azure/role-based-access-control/troubleshooting).

## Disable Microsoft Entra Workload ID on an AKS cluster

To disable Microsoft Entra Workload ID on the AKS cluster where you enabled and configured it, use the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-workload-identity` parameter.

```azurecli
az aks update \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --disable-workload-identity
```

::: zone-end

::: zone pivot="terraform"

## Deploy a verification pod (Terraform)

Add the following code to `main.tf` to deploy a verification pod that uses the workload identity to access the secret in the key vault:

```Terraform
resource "kubernetes_pod" "test" {
 metadata {
   name      = "workload-identity-test"
   namespace = local.service_account_namespace
   labels = {
     "azure.workload.identity/use" = "true"
   }
 }
 spec {
   service_account_name = kubernetes_service_account.this.metadata[0].name
   container {
     name  = "test"
     image = "ghcr.io/azure/azure-workload-identity/msal-go"
     env {
       name  = "KEYVAULT_URL"
       value = azurerm_key_vault.this.vault_uri
     }
     env {
       name  = "SECRET_NAME"
       value = azurerm_key_vault_secret.this.name
     }
   }
 }

 depends_on = [
   azurerm_federated_identity_credential.this,
   azurerm_role_assignment.identity,
 ]
}
```

## Initialize Terraform

Initialize Terraform in the directory containing your `main.tf` file using the [`terraform init`](https://www.terraform.io/docs/commands/init.html) command. This command downloads the Azure provider required to manage Azure resources with Terraform.

```console
terraform init
```

## Create a Terraform execution plan

Create a Terraform execution plan using the [`terraform plan`](https://www.terraform.io/docs/commands/plan.html) command. This command shows you the resources that Terraform will create or modify in your Azure subscription.

```console
terraform plan
```

## Apply the Terraform configuration

After reviewing and confirming the execution plan, apply the Terraform configuration using the [`terraform apply`](https://www.terraform.io/docs/commands/apply.html) command. This command creates or modifies the resources defined in your `main.tf` file in your Azure subscription.

```console
terraform apply
```

## Verify the deployment

1. Connect to your AKS cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --name <cluster-name> --resource-group <resource-group>
    ```
2. Check the status of the verification pod using the [`kubectl get pods`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.
3. Once the pod reaches a `Ready` state, verify it can access the key vault secret by checking the pod logs using the [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs) command.

    ```bash
    kubectl logs workload-identity-test
    ```

    If successful, the output is similar to the following example:

    ```output
    I0114 10:35:09.795900       1 main.go:63] "successfully got secret" secret="Hello from Key Vault"
    ```

    Important

    Azure RBAC role assignments can take up to 10 minutes to propagate. If the pod can't access the secret, wait for the role assignment to propagate, and then recreate the pod by using the `terraform apply -replace="kubernetes_pod.test"` command. For more information, see [Troubleshoot Azure RBAC](/en-us/azure/role-based-access-control/troubleshooting).

::: zone-end