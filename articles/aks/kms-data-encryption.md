---
layout: Conceptual
title: Enable KMS data encryption in Azure Kubernetes Service (AKS) clusters (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/kms-data-encryption
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
description: Learn how to enable Key Management Service (KMS) data encryption with platform-managed keys or customer-managed keys in AKS.
ms.date: 2025-12-19T00:00:00.0000000Z
ms.subservice: aks-security
ms.topic: how-to
ms.custom:
- devx-track-azurecli
author: shashankbarsin
ms.author: shasb
zone_pivot_groups: kms-key-type
locale: en-us
document_id: 9d91895c-8b1e-04b0-5829-46a547f0da8d
document_version_independent_id: ec882cc6-bfc7-633d-1cdf-1e0ba8f1d4b2
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/kms-data-encryption.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/kms-data-encryption
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/kms-data-encryption.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: fa22dc57-ead9-2e09-ad54-87aab2cc1ae1
---

# Enable KMS data encryption in Azure Kubernetes Service (AKS) clusters (Preview) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to enable Key Management Service (KMS) data encryption for Kubernetes secrets in Azure Kubernetes Service (AKS). KMS encryption encrypts Kubernetes secrets stored in etcd using Azure Key Vault keys.

AKS supports two key management options:

- **Platform-managed keys (PMK)**: AKS automatically creates and manages the encryption keys. This option provides the simplest setup with automatic key rotation.
- **Customer-managed keys (CMK)**: You create and manage your own Azure Key Vault and encryption keys. This option provides full control over key lifecycle and meets compliance requirements that mandate customer-managed keys.

For more information about encryption concepts and key options, see [Data encryption at rest concepts for AKS](kms-data-encryption-concepts).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- This article requires version 2.73.0 or later of the Azure CLI. If you're using Azure Cloud Shell, the latest version is already installed there.
- You need the `aks-preview` Azure CLI extension version *19.0.0b13*or later.
    - If you don't already have the `aks-preview` extension, install it using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command. 

        ```azurecli
        az extension add --name aks-preview
        ```
    - If you already have the `aks-preview` extension, update it to make sure you have the latest version using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command. 

        ```azurecli
        az extension update --name aks-preview
        ```
- `kubectl` CLI tool installed.

### Register the feature flag

To use KMS data encryption with platform-managed keys, register the `KMSPMKPreview` feature flag in your subscription.

1. Register the feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace Microsoft.ContainerService --name KMSPMKPreview
    ```
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*.

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name KMSPMKPreview
    ```
3. When the status shows *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

## Set up environment variables

Set up environment variables for your deployment. Replace the placeholder values with your own.

```azurecli
# Set environment variables
export SUBSCRIPTION_ID="<your-subscription-id>"
export RESOURCE_GROUP="<your-resource-group>"
export LOCATION="<your-location>"
export CLUSTER_NAME="<your-cluster-name>"

# Set subscription
az account set --subscription $SUBSCRIPTION_ID

# Create resource group if it doesn't exist
az group create --name $RESOURCE_GROUP --location $LOCATION
```

::: zone pivot="pmk"

## Enable platform-managed key encryption

With platform-managed keys, AKS automatically creates and manages the Azure Key Vault and encryption keys. Key rotation is handled automatically by the platform.

### Create a new AKS cluster with platform-managed keys

Create a new AKS cluster with KMS encryption using platform-managed keys.

```azurecli
az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --kubernetes-version 1.33.0 \
    --kms-infrastructure-encryption Enabled \
    --generate-ssh-keys
```

### Enable platform-managed keys on an existing cluster

Enable KMS encryption with platform-managed keys on an existing AKS cluster.

Note

The cluster must be running Kubernetes version 1.33 or later.

If the `az aks update` command returns a `ReconcileAzureKeyVaultKmsError` error, run the following command to check if you can read and write existing secrets:

```bash
kubectl get secrets --all-namespaces -o json | kubectl replace -f -
```

If this command fails (for example, webhook rejection or resource not found), fix the issue and re-run the update command. A "The object has been modified" message requires no action — treat it as success.

```azurecli
az aks update \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --kms-infrastructure-encryption Enabled
```

### Verify KMS configuration

After enabling KMS encryption, verify the configuration.

```azurecli
az aks show --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --query 'securityProfile'
```

The output includes the KMS configuration:

```json
{
    "kubernetesResourceObjectEncryptionProfile": {
        "infrastructureEncryption": "Enabled"
    }
}
```

::: zone-end

::: zone pivot="cmk-private"

## Enable customer-managed key encryption with a private key vault

For enhanced security, you can use a private key vault that has public network access disabled. AKS accesses the private key vault through the [trusted services firewall exception](/en-us/azure/key-vault/general/network-security#key-vault-firewall-enabled-trusted-services-only). This section shows how to configure customer-managed keys with a private key vault.

### Create a key vault and key with trusted services access

Note

This section illustrates creating a key vault with public network access initially, then enabling the firewall with trusted services bypass. This approach is for illustrative purposes only. In production environments, you should create and manage your key vault as private from the start. For guidance on managing private key vaults, see [Azure Key Vault network security](/en-us/azure/key-vault/general/network-security).

1. Create a key vault with Azure RBAC enabled.

    ```azurecli
    export KEY_VAULT_NAME="<your-key-vault-name>"
    
    az keyvault create \
        --name $KEY_VAULT_NAME \
        --resource-group $RESOURCE_GROUP \
        --enable-rbac-authorization true \
        --public-network-access Enabled
    
    # Get the key vault resource ID
    export KEY_VAULT_RESOURCE_ID=$(az keyvault show --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --query id -o tsv)
    ```
2. Assign yourself the Key Vault Crypto Officer role to create a key.

    ```azurecli
    az role assignment create \
        --role "Key Vault Crypto Officer" \
        --assignee-object-id $(az ad signed-in-user show --query id -o tsv) \
        --assignee-principal-type "User" \
        --scope $KEY_VAULT_RESOURCE_ID
    ```
3. Create a key in the key vault. Ensure `encrypt` and `decrypt` key operations are enabled.

    ```azurecli
    export KEY_NAME="<your-key-name>"
    
    az keyvault key create --name $KEY_NAME --vault-name $KEY_VAULT_NAME
    
    # Get the key ID (without version for automatic rotation)
    export KEY_ID=$(az keyvault key show --name $KEY_NAME --vault-name $KEY_VAULT_NAME --query 'key.kid' -o tsv)
    export KEY_ID_NO_VERSION=$(echo $KEY_ID | sed 's|/[^/]*$||')
    ```
4. Enable the key vault firewall with trusted services bypass.

    ```azurecli
    az keyvault update \
        --name $KEY_VAULT_NAME \
        --resource-group $RESOURCE_GROUP \
        --default-action Deny \
        --bypass AzureServices
    ```

    The `--default-action Deny` parameter blocks public network access, and the `--bypass AzureServices` parameter allows trusted Azure services (including AKS) to access the key vault.

### Create a user-assigned managed identity

1. Create a user-assigned managed identity for the cluster.

    ```azurecli
    export IDENTITY_NAME="<your-identity-name>"
    
    az identity create --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP
    
    # Get the identity details
    export IDENTITY_OBJECT_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP --query 'principalId' -o tsv)
    export IDENTITY_RESOURCE_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP --query 'id' -o tsv)
    ```
2. Assign the required roles to the managed identity.

    ```azurecli
    # Assign Key Vault Crypto User role for encrypt/decrypt operations
    az role assignment create \
        --role "Key Vault Crypto User" \
        --assignee-object-id $IDENTITY_OBJECT_ID \
        --assignee-principal-type "ServicePrincipal" \
        --scope $KEY_VAULT_RESOURCE_ID
    
    # Assign Key Vault Contributor role for key management
    az role assignment create \
        --role "Key Vault Contributor" \
        --assignee-object-id $IDENTITY_OBJECT_ID \
        --assignee-principal-type "ServicePrincipal" \
        --scope $KEY_VAULT_RESOURCE_ID
    ```

### Create a new AKS cluster with customer-managed keys (private)

Create a new AKS cluster with KMS encryption using customer-managed keys with a private key vault.

```azurecli
az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --kubernetes-version 1.33.0 \
    --kms-infrastructure-encryption Enabled \
    --enable-azure-keyvault-kms \
    --azure-keyvault-kms-key-id $KEY_ID_NO_VERSION \
    --azure-keyvault-kms-key-vault-resource-id $KEY_VAULT_RESOURCE_ID \
    --azure-keyvault-kms-key-vault-network-access Private \
    --assign-identity $IDENTITY_RESOURCE_ID \
    --generate-ssh-keys
```

### Enable customer-managed keys on an existing cluster (private)

Enable KMS encryption with customer-managed keys using a private key vault on an existing AKS cluster.

Note

The cluster must be running Kubernetes version 1.33 or later.

If the `az aks update` command returns a `ReconcileAzureKeyVaultKmsError` error, run the following command to check if you can read and write existing secrets:

```bash
kubectl get secrets --all-namespaces -o json | kubectl replace -f -
```

If this command fails (for example, webhook rejection or resource not found), fix the issue and re-run the update command. A "The object has been modified" message requires no action — treat it as success.

```azurecli
az aks update \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --kms-infrastructure-encryption Enabled \
    --enable-azure-keyvault-kms \
    --azure-keyvault-kms-key-id $KEY_ID_NO_VERSION \
    --azure-keyvault-kms-key-vault-resource-id $KEY_VAULT_RESOURCE_ID \
    --azure-keyvault-kms-key-vault-network-access Private \
    --assign-identity $IDENTITY_RESOURCE_ID
```

### Verify KMS configuration

After enabling KMS encryption, verify the configuration.

```azurecli
az aks show --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --query 'securityProfile'
```

The output includes the KMS configuration:

```json
{
    "azureKeyVaultKms": {
        "enabled": true,
        "keyId": "https://<key-vault-name>.vault.azure.net/keys/<key-name>",
        "keyVaultNetworkAccess": "Private",
        "keyVaultResourceId": "<key-vault-resource-id>"
    },
    "kubernetesResourceObjectEncryptionProfile": {
        "infrastructureEncryption": "Enabled"
    }
}
```

::: zone-end

::: zone pivot="cmk-public"

## Enable customer-managed key encryption with a public key vault

With customer-managed keys, you create and manage your own Azure Key Vault and encryption keys. This section shows how to configure customer-managed keys with a public key vault.

### Create a key vault and key

1. Create a key vault with Azure RBAC enabled.

    ```azurecli
    export KEY_VAULT_NAME="<your-key-vault-name>"
    
    az keyvault create \
        --name $KEY_VAULT_NAME \
        --resource-group $RESOURCE_GROUP \
        --enable-rbac-authorization true \
        --public-network-access Enabled
    
    # Get the key vault resource ID
    export KEY_VAULT_RESOURCE_ID=$(az keyvault show --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --query id -o tsv)
    ```
2. Assign yourself the Key Vault Crypto Officer role to create a key.

    ```azurecli
    az role assignment create \
        --role "Key Vault Crypto Officer" \
        --assignee-object-id $(az ad signed-in-user show --query id -o tsv) \
        --assignee-principal-type "User" \
        --scope $KEY_VAULT_RESOURCE_ID
    ```
3. Create a key in the key vault. Ensure `encrypt` and `decrypt` key operations are enabled.

    ```azurecli
    export KEY_NAME="<your-key-name>"
    
    az keyvault key create --name $KEY_NAME --vault-name $KEY_VAULT_NAME
    
    # Get the key ID (without version for automatic rotation)
    export KEY_ID=$(az keyvault key show --name $KEY_NAME --vault-name $KEY_VAULT_NAME --query 'key.kid' -o tsv)
    export KEY_ID_NO_VERSION=$(echo $KEY_ID | sed 's|/[^/]*$||')
    ```

### Create a user-assigned managed identity

1. Create a user-assigned managed identity for the cluster.

    ```azurecli
    export IDENTITY_NAME="<your-identity-name>"
    
    az identity create --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP
    
    # Get the identity details
    export IDENTITY_OBJECT_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP --query 'principalId' -o tsv)
    export IDENTITY_RESOURCE_ID=$(az identity show --name $IDENTITY_NAME --resource-group $RESOURCE_GROUP --query 'id' -o tsv)
    ```
2. Assign the required roles to the managed identity.

    ```azurecli
    # Assign Key Vault Crypto User role for encrypt/decrypt operations
    az role assignment create \
        --role "Key Vault Crypto User" \
        --assignee-object-id $IDENTITY_OBJECT_ID \
        --assignee-principal-type "ServicePrincipal" \
        --scope $KEY_VAULT_RESOURCE_ID
    
    # Assign Key Vault Contributor role for key management
    az role assignment create \
        --role "Key Vault Contributor" \
        --assignee-object-id $IDENTITY_OBJECT_ID \
        --assignee-principal-type "ServicePrincipal" \
        --scope $KEY_VAULT_RESOURCE_ID
    ```

### Create a new AKS cluster with customer-managed keys

Create a new AKS cluster with KMS encryption using customer-managed keys.

```azurecli
az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --kubernetes-version 1.33.0 \
    --kms-infrastructure-encryption Enabled \
    --enable-azure-keyvault-kms \
    --azure-keyvault-kms-key-id $KEY_ID_NO_VERSION \
    --azure-keyvault-kms-key-vault-resource-id $KEY_VAULT_RESOURCE_ID \
    --azure-keyvault-kms-key-vault-network-access Public \
    --assign-identity $IDENTITY_RESOURCE_ID \
    --generate-ssh-keys
```

### Enable customer-managed keys on an existing cluster

Enable KMS encryption with customer-managed keys on an existing AKS cluster.

Note

The cluster must be running Kubernetes version 1.33 or later.

If the `az aks update` command returns a `ReconcileAzureKeyVaultKmsError` error, run the following command to check whether existing secrets can be read and written:

```bash
kubectl get secrets --all-namespaces -o json | kubectl replace -f -
```

If this command fails (for example, webhook rejection or resource not found), fix the issue and re-run the update command. A "The object has been modified" message requires no action — treat it as success.

```azurecli
az aks update \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --kms-infrastructure-encryption Enabled \
    --enable-azure-keyvault-kms \
    --azure-keyvault-kms-key-id $KEY_ID_NO_VERSION \
    --azure-keyvault-kms-key-vault-resource-id $KEY_VAULT_RESOURCE_ID \
    --azure-keyvault-kms-key-vault-network-access Public \
    --assign-identity $IDENTITY_RESOURCE_ID
```

### Verify KMS configuration

After enabling KMS encryption, verify the configuration.

```azurecli
az aks show --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --query 'securityProfile'
```

The output includes the KMS configuration:

```json
{
    "azureKeyVaultKms": {
        "enabled": true,
        "keyId": "https://<key-vault-name>.vault.azure.net/keys/<key-name>",
        "keyVaultNetworkAccess": "Public",
        "keyVaultResourceId": "<key-vault-resource-id>"
    },
    "kubernetesResourceObjectEncryptionProfile": {
        "infrastructureEncryption": "Enabled"
    }
}
```

::: zone-end

## Migrate between key management options

You can migrate between platform-managed keys and customer-managed keys.

### Migrate from platform-managed keys to customer-managed keys

To migrate from platform-managed keys to customer-managed keys, first set up the key vault, key, and managed identity as described in the customer-managed keys section, then run the update command:

```azurecli
az aks update \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --kms-infrastructure-encryption Enabled \
    --enable-azure-keyvault-kms \
    --azure-keyvault-kms-key-id $KEY_ID_NO_VERSION \
    --azure-keyvault-kms-key-vault-resource-id $KEY_VAULT_RESOURCE_ID \
    --azure-keyvault-kms-key-vault-network-access Public \
    --assign-identity $IDENTITY_RESOURCE_ID
```

### Migrate from customer-managed keys to platform-managed keys

To migrate from customer-managed keys to platform-managed keys:

```azurecli
az aks update \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --kms-infrastructure-encryption Enabled \
    --disable-azure-keyvault-kms
```

## Key rotation

With KMS data encryption, key rotation is handled differently depending on your key management option:

- **Platform-managed keys**: Key rotation is automatic. No action is required.
- **Customer-managed keys**: After you rotate the key in Azure Key Vault, KMS periodically detects the new key version. Wait at least seven days between creating the new key version and deleting the old one.

Note

Unlike the legacy KMS experience, with this new implementation you don't need to manually re-encrypt secrets after key rotation. The platform handles this automatically.

Don't delete or expire the old key version right after you create the new one.