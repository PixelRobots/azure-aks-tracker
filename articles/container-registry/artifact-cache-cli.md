---
layout: Conceptual
title: Enable artifact cache in your Azure Container Registry with Azure CLI - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/artifact-cache-cli
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Learn how to use Azure CLI to cache container images in Azure Container Registry, improving performance and efficiency.
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2025-04-29T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 89fa041c-d5c7-7c26-db9a-77811165b902
document_version_independent_id: ef266076-8afd-2ead-2bd7-eacd1a88ce4d
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/artifact-cache-cli.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: container-registry/artifact-cache-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/artifact-cache-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/f488294d-f483-456e-94e3-755f933b811b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/02662057-0b9b-40f4-a3c7-537125b6d283
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: efed308b-350f-76c7-691a-c269baba78fc
---

# Enable artifact cache in your Azure Container Registry with Azure CLI - Azure Container Registry | Microsoft Learn

In this article, you learn how to use Azure CLI to enable the [artifact cache feature](artifact-cache-overview) in your Azure Container Registry (ACR) with or without authentication.

In addition to the prerequisites listed here, you need an Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).

## Prerequisites

- Azure CLI. You can use the [Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart) or a local installation of Azure CLI to run the commands in this article. To use it locally, Azure CLI version 2.46.0 or later is required. To confirm your Azure CLI version, run `az --version`. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- An existing ACR instance. If you don't already have one, [use our quickstart to create a new container registry](/en-us/azure/container-registry/container-registry-get-started-azure-cli).
- An existing Key Vault to [create and store credentials](/en-us/azure/key-vault/secrets/quick-create-cli#add-a-secret-to-key-vault).
- Permissions to [set and retrieve secrets from your Key Vault](/en-us/azure/key-vault/secrets/quick-create-cli#retrieve-a-secret-from-key-vault).

In this article, we use an example ACR instance named `MyRegistry`.

## Create the credentials

Before configuring the credentials, make sure you're able to [create and store secrets in the Azure Key Vault](/en-us/azure/key-vault/secrets/quick-create-cli#add-a-secret-to-key-vault) and [retrieve secrets from the Key Vault](/en-us/azure/key-vault/secrets/quick-create-cli#retrieve-a-secret-from-key-vault).

1. Run [`az acr credential set create`](/en-us/cli/azure/acr/credential-set#az-acr-credential-set-create):

    ```azurecli
    az acr credential-set create 
    -r MyRegistry \
    -n MyDockerHubCredSet \
    -l docker.io \ 
    -u https://MyKeyvault.vault.azure.net/secrets/usernamesecret \
    -p https://MyKeyvault.vault.azure.net/secrets/passwordsecret
    ```
2. Run [`az acr credential set update`](/en-us/cli/azure/acr/credential-set#az-acr-credential-set-update) to update the username or password Key Vault secret ID on the credential set:

    ```azurecli
    az acr credential-set update -r MyRegistry -n MyDockerHubCredSet -p https://MyKeyvault.vault.azure.net/secrets/newsecretname
    ```
3. Run [az acr credential-set show](/en-us/cli/azure/acr/credential-set#az-acr-credential-set-show) to show credentials:

    ```azurecli
    az acr credential-set show -r MyRegistry -n MyDockerHubCredSet
    ```

## Create a cache rule

Next, create and configure the cache rule that pulls artifacts from the repository into your cache.

1. To create a new cache rule, run [`az acr cache create`](/en-us/cli/azure/acr/cache#az-acr-cache-create):

    ```azurecli
    az acr cache create -r MyRegistry -n MyRule -s docker.io/library/ubuntu -t ubuntu -c MyDockerHubCredSet
    ```
2. To update credentials on the cache rule, run [`az acr cache update`](/en-us/cli/azure/acr/cache#az-acr-cache-update):

    ```azurecli
    az acr cache update -r MyRegistry -n MyRule -c NewCredSet
    ```

    If you need to remove the credentials, run `az acr cache update -r MyRegistry -n MyRule --remove-cred-set`.
3. To show cache rules, run [`az acr cache show`](/en-us/cli/azure/acr/cache#az-acr-cache-show):

    ```azurecli
     az acr cache show -r MyRegistry -n MyRule
    ```

Important

If the target Azure container registry is network-restricted by using private endpoints or public IP access rules, enable **Allow trusted Microsoft Services to access this container registry**. Artifact cache can't populate the target registry when trusted-services access is disabled. For configuration steps, see [Allow trusted services to securely access a network-restricted container registry](allow-access-trusted-services).

Tip

To create a cache rule without using credentials, use the same command without credentials specified. For example, `az acr cache create --registry Myregistry --name MyRule --source-repo MySourceRepository --target-repo MyTargetRepository`. For some sources, such as Docker Hub, credentials are required to create a cache rule.

## Assign permissions to Key Vault with Azure RBAC

You can use Azure RBAC to assign the appropriate permissions to users so they can access the Azure Key Vault.

The `Microsoft.KeyVault/vaults/secrets/getSecret/action` permission is required to access the Key Vault. The **Key Vault Secrets User** Azure built-in role is typically granted, as it's the least privileged role that includes this action. Alternately, you can create a custom role that includes that permission.

The steps used vary depending on whether you're using Azure CLI or Bash.

# [Azure CLI](#tab/azure-cli)
1. Get the principal ID of the system identity in use to access Key Vault:

    ```azurecli
    az acr credential-set show --name MyCredentialSet --registry MyRegistry 
    ```

    Take note of the principal ID value, as you'll need it in step 3.
2. Display properties of the Key Vault to get its resource ID:

    ```azurecli
    az keyvault show --name MyKeyVaultName --resource-group MyResouceGroup
    ```

    You'll need this resource ID value for the next step.
3. Assign the **Key Vault Secrets User** role to the system identity of the credential set:

    ```azurecli
    az role assignment create --role "Key Vault Secrets User" --assignee CredentialSetPrincipalID --scope KeyVaultResourceID 
    
    ```

# [Bash](#tab/bash)
1. Get the principal ID of the system identity in use to access Key Vault:

    ```bash
    CredentialSetPrincipalID=$(az acr credential-set show --name MyCredentialSet --registry MyRegistry  --query 'identity.principalId'  -o tsv
    ```
2. Display properties of the Key Vault to get its resource ID:

    ```bash
    KeyVaultResourceID=$(az keyvault show --name MyKeyVaultName --resource-group MyResouceGroup --query 'id' -o tsv
    ```
3. Assign the **Key Vault Secrets User** role to the system identity of the credential set:

    ```bash
    az role assignment create --role "Key Vault Secrets User" --assignee $CredentialSetPrincipalID --scope $KeyVaultResourceID
    ```

---

Tip

Using the Key Vault's resource ID grants access to all secrets in the Key Vault. If you prefer, you can grant access only to the username and password secrets. To do so, instead of the command from step 2, run the following commands to retrieve only the username and password secrets:

```azurecli
az keyvault secret show --vault-name MyKeyVaultName --name MyUsernameSecretName
az keyvault secret show --vault-name MyKeyVaultName --name MyPasswordSecretName
```

Next, perform step 3 twice, first replacing `KeyVaultResourceID` with the ID of the username secret, then with the ID of the password secret.

## Assign permissions to Key Vault with access policies

Alternately, you can use access policies to assign permissions.

# [Azure CLI](#tab/azure-cli)
1. Get the principal ID of the system identity in use to access Key Vault:

    ```azurecli
    az acr credential-set show --name CredentialSet --registry MyRegistry
    ```

    Take note of the principal ID value, as you'll need it in the next step.
2. Run the `az keyvault set-policy` command to assign access to the Key Vault before pulling the image. For example, to assign permissions for the credentials to access the KeyVault secret:

    ```azurecli
    az keyvault set-policy --name MyKeyVault --object-id MyCredentialSetPrincipalID --secret-permissions get
    ```

# [Bash](#tab/bash)
1. Get the principal ID of the system identity in use to access Key Vault:

    ```azurecli
    PRINCIPAL_ID=$(az acr credential-set show 
                    -name MyDockerHubCredSet \ 
                    -registry MyRegistry  \
                    --query 'identity.principalId' \ 
                    -o tsv) 
    ```
2. Run the `az keyvault set-policy` command to assign access to the Key Vault before pulling the image. For example, to assign permissions for the credentials to access the KeyVault secret:

    ```azurecli
    az keyvault set-policy --name MyKeyVault \
    --object-id $PRINCIPAL_ID \
    --secret-permissions get
    ```

---

## Pull your image

To pull an image from your cache, use the Docker command and provide the registry sign-in server name, repository name, and its desired tag. For example, to pull an image from the repository `hello-world` with desired tag `latest` for the registry sign-in server `myregistry.azurecr.io`, run:

```azurecli
 docker pull myregistry.azurecr.io/hello-world:latest
```

## Clean up resources

When no longer needed, delete the cache rule and credentials that you created.

1. To delete the cache rule, run [`az acr cache delete`](/en-us/cli/azure/acr/cache#az-acr-cache-delete):

    ```azurecli
    az acr cache delete -r MyRegistry -n MyRule
    ```
2. To delete the credentials, run [`az acr credential-set delete`](/en-us/cli/azure/acr/credential-set#az-acr-credential-set-delete):

    ```azurecli
    az acr credential-set delete -r MyRegistry -n MyDockerHubCredSet
    ```