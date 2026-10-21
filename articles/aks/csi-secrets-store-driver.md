---
layout: Conceptual
title: Use the Azure Key Vault Provider for Secrets Store CSI Driver for Azure Kubernetes Service (AKS) Secrets - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver
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
description: Learn how to use the Azure Key Vault provider for Secrets Store CSI Driver to integrate secrets stores with Azure Kubernetes Service (AKS).
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2026-09-14T00:00:00.0000000Z
ms.custom: template-how-to, devx-track-azurecli, biannual
zone_pivot_groups: cli-terraform-csi-driver
locale: en-us
document_id: 8079040b-d227-4825-2ab3-d5a67dcfd075
document_version_independent_id: 7e2f5556-e7ca-2c18-5eb2-9048a24ba219
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/csi-secrets-store-driver.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/csi-secrets-store-driver
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/csi-secrets-store-driver.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 78ac1b99-5875-65c6-3ac5-7f4f6b2d5e8b
---

# Use the Azure Key Vault Provider for Secrets Store CSI Driver for Azure Kubernetes Service (AKS) Secrets - Azure Kubernetes Service | Microsoft Learn

The Azure Key Vault provider for Secrets Store Container Storage Interface (CSI) Driver allows for the integration of an Azure Key Vault as a secret store with an Azure Kubernetes Service (AKS) cluster via a [CSI volume](https://kubernetes-csi.github.io/docs/).

## Features

- Mounts secrets, keys, and certificates to a pod using a CSI volume.
- Supports CSI inline volumes.
- Supports mounting multiple secrets store objects as a single volume.
- Supports pod portability with the `SecretProviderClass` Custom Resource Definition (CRD).
- Supports Windows containers.
- Syncs with Kubernetes secrets.
- Supports autorotation of mounted contents and synced Kubernetes secrets.

## Limitations

- A container using a `ConfigMap` or `Secret` as a `subPath` volume mount doesn't receive automated updates when the secret is rotated, which is a Kubernetes limitation. To have the changes take effect, the application needs to reload the changed file by either watching for changes in the file system or by restarting the pod. For more information, see [Secrets Store CSI Driver known limitations](https://secrets-store-csi-driver.sigs.k8s.io/known-limitations.html#secrets-not-rotated-when-using-subpath-volume-mount).
- The add-on creates a managed identity named `azurekeyvaultsecretsprovider-xxxxx` in the node resource group (`MC_`) and assigns it to the Virtual Machine Scale Set automatically. You can use this managed identity or your own managed identity to access the key vault. It's not supported to prevent creation of the identity.

## Prerequisites

::: zone pivot="azure-cli-create,azure-cli-update"

- If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Check that your version of the Azure CLI is 2.30.0 or later. If it's an earlier version, [install the latest version](/en-us/cli/azure/install-azure-cli).

::: zone-end

::: zone pivot="terraform-create"

- If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Terraform that's version 1.6 or later.
- Azure CLI installed and logged in. [install the latest version](/en-us/cli/azure/install-azure-cli).
- Permissions to create AKS and Key Vault resources.
- Set your Azure subscription in the Azure CLI with the following command. Replace `<subscriptionId>` with your subscription ID.

    ```azurecli
    az account set --subscription <subscriptionId>
    ```

::: zone-end

### Network

- If using network isolated clusters, the recommendation is to [set up private endpoint to access Azure Key Vault](/en-us/azure/key-vault/general/private-link-service).
- If the cluster has outbound type `userDefinedRouting` and uses a firewall device that can control outbound traffic based on domain names, such as Azure Firewall, ensure the [required outbound network rules and FQDNs are allowed](outbound-rules-control-egress#azure-key-vault-provider-for-secrets-store-csi-driver).
- If you're restricting Ingress to the cluster, make sure ports **9808** and **8095** are open.

### Roles

- The Azure CLI workflows use the [Key Vault Secrets Officer](/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-officer) role to give your account permission to create a secret. The Terraform sample uses the Key Vault Administrator role and grants the add-on identity the Key Vault Secrets User role.
- In the article to [provide Azure Key Vault access](csi-secrets-store-identity-access), the identity used with the `SecretProviderClass` needs [Key Vault Certificate User](/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-certificate-user) to access `key` or `certificate`[object types](/en-us/azure/key-vault/general/about-keys-secrets-certificates#object-types) and [Key Vault Secrets User](/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-user) to access `secret`[object type](/en-us/azure/key-vault/general/about-keys-secrets-certificates#object-types).

::: zone pivot="azure-cli-create"

## Create an AKS cluster

Create an AKS cluster with Azure Key Vault provider for Secrets Store CSI Driver support.

1. Create variables that are used in the commands to create an AKS cluster and Key Vault.

    ```azurecli
    export RANDOM_STRING=$(printf '%05d%05d' "$RANDOM" "$RANDOM")
    export KEYVAULT_NAME=myKeyVault${RANDOM_STRING}
    export RESOURCE_GROUP=myResourceGroup
    export CLUSTER_NAME=myAKSCluster
    export LOCATION=eastus2
    ```

    Azure Key Vault names must be globally unique, alphanumeric including hyphens, and 3-24 characters. The key vault name concatenates the `KEYVAULT_NAME` variable's `myKeyVault` value with the `RANDOM_STRING` variable's 10 character string.
2. Create an Azure resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```
3. Create an AKS cluster with Azure Key Vault provider for Secrets Store CSI Driver capability using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-addons azure-keyvault-secrets-provider` parameter.

    The `--enable-addons` parameter creates a user-assigned managed identity named `azurekeyvaultsecretsprovider-xxxx` that you can use to authenticate to your key vault. The managed identity is stored in the node resource group (`MC_`) and is automatically assigned to the Virtual Machine Scale Set. You can use this managed identity or your own managed identity to access the key vault. It's not supported to prevent creation of the identity.

    ```azurecli
    az aks create \
      --name $CLUSTER_NAME \
      --resource-group $RESOURCE_GROUP \
      --enable-addons azure-keyvault-secrets-provider \
      --generate-ssh-keys
    ```

    Tip

    If you want to use Microsoft Entra Workload ID, the `az aks create` command must include the `--enable-oidc-issuer` and `--enable-workload-identity` parameters.

::: zone-end

::: zone pivot="terraform-create"

## Create an AKS cluster

Create a `main.tf` file and copy the following tested sample configuration into it. The [Azure Terraform GitHub repository](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-access-keyvault) maintains the sample. The sample creates the resource group, AKS cluster, Azure Key Vault, example secret, and required role assignments.

```terraform
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  location            = "eastus"
  resource_group_name = "rg-aks-kv-csi-demo-${random_string.suffix.result}"
  aks_name            = "aks-kv-csi-demo"
  key_vault_name      = "kvcsidemo${random_string.suffix.result}"
  secret_name         = "ExampleSecret"
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-aks-kv-csi-demo"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_kubernetes_cluster" "this" {
  name                      = local.aks_name
  location                  = azurerm_resource_group.this.location
  resource_group_name       = azurerm_resource_group.this.name
  dns_prefix                = "akskvcsidemo"
  kubernetes_version        = null
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_D2s_v3"

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    scenario = "aks-keyvault-csi"
  }
}

resource "azurerm_key_vault" "this" {
  name                          = local.key_vault_name
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  purge_protection_enabled      = false
  soft_delete_retention_days    = 7
  enable_rbac_authorization     = true
  public_network_access_enabled = true
}

resource "azurerm_role_assignment" "current_user_kv_admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "example" {
  name         = local.secret_name
  value        = "HelloFromKeyVault"
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_role_assignment.current_user_kv_admin
  ]
}

resource "azurerm_role_assignment" "aks_csi_secrets_user" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  # This is the managed identity automatically created by the AKS Key Vault CSI addon.
  principal_id = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].object_id
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "key_vault_name" {
  value = azurerm_key_vault.this.name
}

output "key_vault_secret_name" {
  value = azurerm_key_vault_secret.example.name
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "aks_csi_client_id" {
  value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].client_id
}

output "aks_csi_object_id" {
  value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].object_id
}
```

1. Deploy the configuration. From a Bash session, run the following commands to deploy the resources:

    ```bash
    terraform init
    terraform validate
    terraform plan
    terraform apply
    ```
2. Set the variables used in the remaining commands from the Terraform outputs:

    ```bash
    export RESOURCE_GROUP=$(terraform output -raw resource_group_name)
    export CLUSTER_NAME=$(terraform output -raw aks_cluster_name)
    export KEYVAULT_NAME=$(terraform output -raw key_vault_name)
    ```

::: zone-end

::: zone pivot="azure-cli-update"

## Update an existing AKS cluster

Update an existing AKS cluster with Azure Key Vault provider for Secrets Store CSI Driver support.

1. Create variables that are used in the commands. Replace the values as needed to update your existing AKS cluster or Key Vault.

    For example, if you're using an existing key vault, replace the `KEYVAULT_NAME` variable's value without using the `RANDOM_STRING` variable.

    If you don't have a key vault, Azure Key Vault names must be globally unique, alphanumeric including hyphens, and 3-24 characters. The key vault name concatenates the `KEYVAULT_NAME` variable's `myKeyVault` value with the `RANDOM_STRING` variable's 10 character string. You can create the key vault later in this article.

    ```azurecli
    export RANDOM_STRING=$(printf '%05d%05d' "$RANDOM" "$RANDOM")
    export KEYVAULT_NAME=myKeyVault${RANDOM_STRING}
    export RESOURCE_GROUP=myResourceGroup
    export CLUSTER_NAME=myAKSCluster
    export LOCATION=eastus2
    ```
2. Update an existing AKS cluster with Azure Key Vault provider for Secrets Store CSI Driver capability using the [`az aks enable-addons`](/en-us/cli/azure/aks#az-aks-enable-addons) command and enable the `azure-keyvault-secrets-provider` add-on. The add-on creates a user-assigned managed identity you can use to authenticate to your key vault.

    ```azurecli
    az aks enable-addons \
      --addons azure-keyvault-secrets-provider \
      --name $CLUSTER_NAME \
      --resource-group $RESOURCE_GROUP
    ```

    After you enable the Azure Key Vault secret provider, AKS creates a managed identity named `azurekeyvaultsecretsprovider-xxxx` that you can use to authenticate to your key vault. The managed identity is stored in the node resource group (`MC_`) and is automatically assigned to the Virtual Machine Scale Set. You can use this managed identity or your own managed identity to access the key vault. It's not supported to prevent creation of the identity.

::: zone-end

::: zone pivot="azure-cli-create,azure-cli-update,terraform-create"

### Verify the managed identity and key vault provider installation

The following commands use the `$CLUSTER_NAME` and `$RESOURCE_GROUP` variables. The Azure CLI workflows define these variables earlier, and the Terraform workflow sets them from outputs after deployment.

#### Verify the managed identity

Use the following steps to verify the managed identity was created and assigned to the cluster's Virtual Machine Scale Set.

1. Verify the managed identity was created and assigned to the cluster using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show \
      --name $CLUSTER_NAME \
      --resource-group $RESOURCE_GROUP \
      --query addonProfiles
    ```

    ```output
    {
      "azureKeyvaultSecretsProvider": {
        "config": {
          "enableSecretRotation": "false",
          "rotationPollInterval": "2m"
        },
        "enabled": true,
        "identity": {
          "clientId": "00001111-aaaa-2222-bbbb-3333cccc4444",
          "objectId": "aaaaaaaa-0000-1111-2222-bbbbbbbbbbbb",
          "resourceId": "/subscriptions/<subscriptionID>/resourcegroups/MC_myResourceGroup_myAKSCluster_eastus2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/azurekeyvaultsecretsprovider-myakscluster"
        }
      }
    }
    ```

    The `resourceId` property shows the resource group and the identity's name `azurekeyvaultsecretsprovider-myakscluster`.
2. Verify the managed identity is assigned to node resource group's Virtual Machine Scale Set.

    ```azurecli
    NODE_RG=$(az aks show \
      --name $CLUSTER_NAME \
      --resource-group $RESOURCE_GROUP \
      --query nodeResourceGroup --output tsv)
    
    VMSS_NAME=$(az vmss list \
      --resource-group $NODE_RG \
      --query [].name --output tsv)
    
    az vmss show --name $VMSS_NAME --resource-group $NODE_RG --query '[id, identity]'
    ```

    The output shows the Virtual Machines Scale sets `Microsoft.Compute/virtualMachineScaleSets` resource ID and the `userAssignedIdentities` property with a resource ID for `azurekeyvaultsecretsprovider-myakscluster` that confirms the identity is assigned to the Virtual Machine Scale Set.

#### Verify the Azure Key Vault provider for Secrets Store CSI Driver installation

1. Get the AKS cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials \
      --name $CLUSTER_NAME \
      --resource-group $RESOURCE_GROUP
    ```
2. Verify the installation is finished using the `kubectl get pods` command, which lists all pods with the `secrets-store-csi-driver` and `secrets-store-provider-azure` labels in the `kube-system` namespace.

    ```bash
    kubectl get pods -n kube-system -l 'app in (secrets-store-csi-driver,secrets-store-provider-azure)' -o wide
    ```

    The `-o wide` flag includes the node that each pod is running on in the output.

    Your output should look similar to the following example output:

    ```output
    NAME                                     READY   STATUS    RESTARTS   AGE    NODE
    aks-secrets-store-csi-driver-4vpkj       3/3     Running   2          4m25s  aks-nodepool1-12345678-vmss000002
    aks-secrets-store-csi-driver-ctjq6       3/3     Running   2          4m21s  aks-nodepool1-12345678-vmss000001
    aks-secrets-store-csi-driver-tlvlq       3/3     Running   2          4m24s  aks-nodepool1-12345678-vmss000000
    aks-secrets-store-provider-azure-5p4nb   1/1     Running   0          4m21s  aks-nodepool1-12345678-vmss000000
    aks-secrets-store-provider-azure-6pqmv   1/1     Running   0          4m24s  aks-nodepool1-12345678-vmss000001
    aks-secrets-store-provider-azure-f5qlm   1/1     Running   0          4m25s  aks-nodepool1-12345678-vmss000002
    ```

::: zone-end

::: zone pivot="azure-cli-create"

## Create new key vault

Run the [`az keyvault create`](/en-us/cli/azure/keyvault#az-keyvault-create) command to create a new key vault with Azure RBAC enabled.

```azurecli
az keyvault create \
  --name $KEYVAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --enable-rbac-authorization
```

Azure RBAC is enabled by default when you create a new key vault even if you don't include the `--enable-rbac-authorization` parameter.

For more information about key vault permission models and Azure RBAC, see [Provide access to Key Vault keys, certificates, and secrets with an Azure role-based access control](/en-us/azure/key-vault/general/rbac-guide).

::: zone-end

::: zone pivot="azure-cli-update"

## Update existing key vault

Run the [`az keyvault update`](/en-us/cli/azure/keyvault#az-keyvault-update) command to update an existing key vault with Azure role-based access control (Azure RBAC). The `--enable-rbac-authorization` parameter is needed to enable Azure RBAC when you update an existing key vault that has Azure RBAC disabled.

```azurecli
az keyvault update \
  --name $KEYVAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --enable-rbac-authorization
```

For more information about key vault permission models and Azure RBAC, see [Provide access to Key Vault keys, certificates, and secrets with an Azure role-based access control](/en-us/azure/key-vault/general/rbac-guide)

::: zone-end

::: zone pivot="azure-cli-create,azure-cli-update"

### Add role assignment and secret to key vault

1. Run the [`az keyvault show`](/en-us/cli/azure/keyvault#az-keyvault-show) command to verify the key vault has Azure RBAC enabled.

    ```azurecli
    az keyvault show \
      --name $KEYVAULT_NAME \
      --resource-group $RESOURCE_GROUP \
      --query properties.enableRbacAuthorization
    ```

    The output should be `true`.
2. Add a role assignment for your user account to the key vault scope using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command so that you can add a key vault secret in the next step.

    The [Key Vault Secrets Officer](/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-officer) role with unique identifier `b86a8fe4-44ce-4948-aee5-eccb2c155cd7` is added and you can use the name or unique identifier. Using the role's unique identifier is a best practice to prevent issues if the roles name changes.

    ```azurecli
    KEYVAULT_ID=$(az keyvault show \
      --name $KEYVAULT_NAME \
      --resource-group $RESOURCE_GROUP \
      --query id -o tsv)
    
    MYID=$(az ad signed-in-user show --query id --output tsv)
    
    az role assignment create \
      --assignee-object-id $MYID \
      --role "b86a8fe4-44ce-4948-aee5-eccb2c155cd7" \
      --scope $KEYVAULT_ID \
      --assignee-principal-type User
    ```

    It can take several minutes for the role assignment to take effect. You can verify the role assignment was created with the following command:

    ```azurecli
    az role assignment list \
      --assignee-object-id $MYID \
      --scope $KEYVAULT_ID \
      --query '[].{Role:roleDefinitionName, Scope:scope}' \
      --output table
    ```
3. Create a plain-text secret named `ExampleSecret` in the key vault using the [`az keyvault secret set`](/en-us/cli/azure/keyvault#az-keyvault-secret-set) command.

    Your key vault can store keys, secrets, and certificates. The `value` parameter uses the `RANDOM_STRING` variable to create a unique value for the secret.

    ```azurecli
    az keyvault secret set \
      --vault-name $KEYVAULT_NAME \
      --name ExampleSecret \
      --value MyAKSExampleSecret${RANDOM_STRING}
    ```
4. Verify the secret was added to the key vault using the [`az keyvault secret show`](/en-us/cli/azure/keyvault/secret#az-keyvault-secret-show) command.

    ```azurecli
    az keyvault secret show --vault-name $KEYVAULT_NAME --name ExampleSecret
    ```

::: zone-end

::: zone pivot="terraform-create"

## Create new key vault

The Terraform sample included earlier creates a new key vault with Azure RBAC enabled, assigns the required roles, and creates `ExampleSecret`. No separate configuration update is required.

1. Get the key vault name from the Terraform output.

    ```bash
    KEYVAULT_NAME=$(terraform output -raw key_vault_name)
    ```
2. Verify `ExampleSecret` was added to the key vault by using the [`az keyvault secret show`](/en-us/cli/azure/keyvault/secret#az-keyvault-secret-show) command.

    ```azurecli
    az keyvault secret show \
     --vault-name $KEYVAULT_NAME \
     --name ExampleSecret
    ```

::: zone-end

## Clean up resources

If you're going to the next article and need these resources, ignore the following steps. Otherwise, if you're finished and don't plan to continue to the next article, you should delete the resources created in this article to avoid unnecessary costs.

::: zone pivot="azure-cli-create,azure-cli-update"

1. Remove your cluster's credentials from your local *.kube/config* file.

    ```bash
    KUBE_CONTEXT=$(kubectl config current-context)
    kubectl config delete-context $KUBE_CONTEXT
    ```
2. Delete the resource group and all resources within it, including resources in the node resource group (`MC_`) using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command.

    ```azurecli
    az group delete --name $RESOURCE_GROUP --yes --no-wait
    ```

::: zone-end

::: zone pivot="terraform-create"

The `terraform destroy` command removes all resources defined in the current Terraform configuration and state file. Only run this command from the working directory used for this article.

Warning

If you're working with existing or production resources, review the execution plan carefully before you run:

`terraform plan -destroy`

Avoid running `terraform destroy` against shared or imported infrastructure unless you're certain it's safe to remove. For more information, see the Terraform documentation for the [terraform destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy) command.

1. Remove your cluster's credentials from your local *.kube/config* file.

    ```bash
    KUBE_CONTEXT=$(kubectl config current-context)
    kubectl config delete-context $KUBE_CONTEXT
    ```
2. Run the following command to remove the resources created in this article:

    ```bash
    terraform destroy
    ```

::: zone-end