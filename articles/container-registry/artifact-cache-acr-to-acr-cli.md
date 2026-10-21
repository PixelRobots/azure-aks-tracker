---
layout: Conceptual
title: Enable artifact cache to cache artifacts from another Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/artifact-cache-acr-to-acr-cli
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
author: toddysm
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: memladen
ms.service: azure-container-registry
description: Learn how to cache container images from one Azure Container Registry in another using managed identity authentication with Azure CLI and Bicep.
ms.topic: how-to
ms.custom: devx-track-azurecli, devx-track-bicep
ms.date: 2026-04-06T00:00:00.0000000Z
locale: en-us
document_id: 6a4d148f-9176-d354-4565-bf8200971f8a
document_version_independent_id: d83322ab-1416-62d0-a5b7-7df2b966ea3b
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/artifact-cache-acr-to-acr-cli.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: container-registry/artifact-cache-acr-to-acr-cli
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/artifact-cache-acr-to-acr-cli.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 3fe73769-28ad-6449-6ffa-d66a2152dfd1
---

# Enable artifact cache to cache artifacts from another Azure Container Registry - Azure Container Registry | Microsoft Learn

In this article, you will learn how to enable the [artifact cache feature](artifact-cache-overview) in your Azure Container Registry (ACR) to cache images from another Azure Container Registry. The downstream registry authenticates to the upstream registry using a managed identity, so you don't need to store credentials in Azure Key Vault.

In addition to the prerequisites listed here, you need an Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).

## Prerequisites

- An existing downstream ACR instance (referred to as `MyRegistry` in this article). If you don't already have one, [create a new container registry](/en-us/azure/container-registry/container-registry-get-started-azure-cli).
- An existing upstream ACR instance (referred to as `UpstreamRegistry` in this article) that contains the artifacts you want to cache.
- Azure CLI version 2.85.0 or later. You can use the [Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart) or a local installation. To confirm your version, run `az --version`. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- [Bicep tools](/en-us/azure/azure-resource-manager/bicep/install) (for Bicep deployments).

## Configure artifact cache

# [Azure CLI](#tab/azure-cli)
#### Create a user-assigned managed identity

ACR-to-ACR caching authenticates to the upstream registry using a user-assigned managed identity instead of username and password credentials stored in Key Vault. You need to create a managed identity and grant it pull access to the upstream registry.

1. Create a user-assigned managed identity:

    ```azurecli
    az identity create \
      --name MyACRCacheIdentity \
      --resource-group MyResourceGroup
    ```
2. Get the principal ID and resource ID of the managed identity:

    ```azurecli
    IDENTITY_PRINCIPAL_ID=$(az identity show \
      --name MyACRCacheIdentity \
      --resource-group MyResourceGroup \
      --query 'principalId' \
      -o tsv)
    
    IDENTITY_RESOURCE_ID=$(az identity show \
      --name MyACRCacheIdentity \
      --resource-group MyResourceGroup \
      --query 'id' \
      -o tsv)
    ```

#### Assign pull permissions on the upstream registry

The upstream registry must have [ABAC (Attribute-Based Access Control) enabled](container-registry-rbac-abac-repository-permissions) so you can assign fine-grained repository permissions. The managed identity needs the **Container Registry Repository Reader** role on the upstream registry, scoped to the specific repository you want to cache.

Note

If the upstream registry doesn't have ABAC enabled yet, run `az acr update --name UpstreamRegistry --role-assignment-mode rbac-abac`.

1. Get the resource ID of the upstream registry:

    ```azurecli
    UPSTREAM_ID=$(az acr show \
      --name UpstreamRegistry \
      --query 'id' \
      -o tsv)
    ```
2. Assign the **Container Registry Repository Reader** role to the managed identity on the upstream registry:

    ```azurecli
    az role assignment create \
      --role "Container Registry Repository Reader" \
      --assignee "$IDENTITY_PRINCIPAL_ID" \
      --scope "$UPSTREAM_ID/repositories/myapp"
    ```

#### Create a cache rule

Create a cache rule that pulls artifacts from the upstream registry into your downstream registry.

1. Run [`az acr cache create`](/en-us/cli/azure/acr/cache#az-acr-cache-create) to create a cache rule. Use the `--identity` parameter to specify the user-assigned managed identity for authentication with the upstream registry:

    ```azurecli
    az acr cache create \
      -r MyRegistry \
      -n MyRule \
      -s upstreamregistry.azurecr.io/myapp \
      -t myapp \
      --identity "$IDENTITY_RESOURCE_ID"
    ```
2. Run [`az acr cache show`](/en-us/cli/azure/acr/cache#az-acr-cache-show) to verify the cache rule:

    ```azurecli
    az acr cache show -r MyRegistry -n MyRule
    ```

# [Bicep](#tab/bicep)
#### Define the Bicep template

Create a Bicep file that defines a user-assigned managed identity and cache rule for ACR-to-ACR caching.

```bicep
@description('Name of the downstream (cache) registry.')
param registryName string

@description('Login server of the upstream registry (for example, upstreamregistry.azurecr.io).')
param upstreamLoginServer string

@description('Repository path on the upstream registry to cache (for example, myapp).')
param sourceRepository string

@description('Repository name in the downstream registry for cached artifacts.')
param targetRepository string

@description('Name of the user-assigned managed identity.')
param identityName string = 'acrCacheIdentity'

@description('Name of the cache rule.')
param cacheRuleName string = 'cacheRule'

@description('Location for resources.')
param location string = resourceGroup().location

resource registry 'Microsoft.ContainerRegistry/registries@2025-11-01' existing = {
  name: registryName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

resource cacheRule 'Microsoft.ContainerRegistry/registries/cacheRules@2026-01-01-preview' = {
  name: '${registry.name}/${cacheRuleName}'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    sourceRepository: '${upstreamLoginServer}/${sourceRepository}'
    targetRepository: targetRepository
  }
}

@description('Principal ID of the managed identity. Grant this identity Container Registry Repository Reader on the upstream registry.')
output identityPrincipalId string = managedIdentity.properties.principalId
```

Save this file as `acr-cache.bicep`.

#### Deploy the template

1. Deploy the Bicep template to create the managed identity and cache rule:

    ```azurecli
    az deployment group create \
      --resource-group MyResourceGroup \
      --template-file acr-cache.bicep \
      --parameters \
        registryName=MyRegistry \
        upstreamLoginServer=upstreamregistry.azurecr.io \
        sourceRepository=myapp \
        targetRepository=myapp
    ```
2. Note the `identityPrincipalId` value from the deployment output.
3. Assign the **Container Registry Repository Reader** role to the managed identity on the upstream registry:

    Note

    The upstream registry must have [ABAC enabled](container-registry-rbac-abac-repository-permissions). If it doesn't, run `az acr update --name UpstreamRegistry --role-assignment-mode rbac-abac` first.

    ```azurecli
    UPSTREAM_ID=$(az acr show --name UpstreamRegistry --query 'id' -o tsv)
    
    az role assignment create \
      --role "Container Registry Repository Reader" \
      --assignee "<identityPrincipalId>" \
      --scope "$UPSTREAM_ID/repositories/myapp"
    ```

---

## Verify the cache

After you configure the cache rule and assign the required permissions, pull an image from your downstream registry to verify that caching works correctly.

```azurecli
docker pull myregistry.azurecr.io/myapp:latest
```

The first pull retrieves the image from the upstream registry and caches it in your downstream registry. Subsequent pulls are served directly from the downstream registry cache.

## Clean up resources

When the cache resources are no longer needed, delete the cache rule, role assignment, and managed identity.

1. Delete the cache rule by running [`az acr cache delete`](/en-us/cli/azure/acr/cache#az-acr-cache-delete):

    ```azurecli
    az acr cache delete -r MyRegistry -n <cache-rule-name>
    ```

    Replace `<cache-rule-name>` with the name you used when creating the cache rule (for example, `MyRule` for the Azure CLI tab or `cacheRule` for the Bicep tab).
2. Remove the role assignment on the upstream registry:

    ```azurecli
    UPSTREAM_ID=$(az acr show --name UpstreamRegistry --query 'id' -o tsv)
    
    IDENTITY_PRINCIPAL_ID=$(az identity show \
      --name MyACRCacheIdentity \
      --resource-group MyResourceGroup \
      --query 'principalId' \
      -o tsv)
    
    az role assignment delete \
      --role "Container Registry Repository Reader" \
      --assignee "$IDENTITY_PRINCIPAL_ID" \
      --scope "$UPSTREAM_ID/repositories/myapp"
    ```
3. Delete the user-assigned managed identity:

    ```azurecli
    az identity delete \
      --name MyACRCacheIdentity \
      --resource-group MyResourceGroup
    ```

    Note

    Make sure the identity is not in use by any other resources before deleting it.