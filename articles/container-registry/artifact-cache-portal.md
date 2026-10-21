---
layout: Conceptual
title: Enable artifact cache in your Azure Container Registry with Azure portal - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/artifact-cache-portal
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
description: Learn how to use the Azure portal to cache container images in Azure Container Registry, improving performance and efficiency.
ms.topic: how-to
ms.date: 2025-04-29T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 45492610-b262-71aa-d636-974ee9470cb2
document_version_independent_id: 15e5ab10-f3ad-aff4-39f7-fef3a4357357
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/artifact-cache-portal.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/artifact-cache-portal
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/artifact-cache-portal.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 455b9fd3-43d3-cca3-198e-9c4fdebd1d0a
---

# Enable artifact cache in your Azure Container Registry with Azure portal - Azure Container Registry | Microsoft Learn

In this article, you learn how to use the Azure portal to enable the [artifact cache feature](artifact-cache-overview) in your Azure Container Registry (ACR).

In addition to the prerequisites listed here, you need an Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).

## Prerequisites

- An existing ACR instance. If you don't have one, [use our quickstart to create a new container registry](/en-us/azure/container-registry/container-registry-get-started-azure-cli).
- An existing Key Vault to [create and store credentials](/en-us/azure/key-vault/secrets/quick-create-cli#add-a-secret-to-key-vault).
- Permissions to [set and retrieve secrets from your Key Vault](/en-us/azure/key-vault/secrets/quick-create-cli#retrieve-a-secret-from-key-vault).
- Azure CLI. You can use the [Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart) or a local installation of the Azure CLI to run the commands in this article. Use Azure CLI version 2.46.0 or later to run it locally. To confirm your Azure CLI version, run `az --version`. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Configure Artifact cache

To create and configure the cache rule that pulls artifacts from the repository into your cache, follow these steps.

Follow the steps to create a cache rule in the [Azure portal](https://portal.azure.com).

1. Navigate to your Azure Container Registry instance.
2. In the service menu, under **Services**, select **Cache**.
3. Select **Create rule**.

    ![Screenshot showing the Create rule command for a container registry in the Azure portal.](media/container-registry-artifact-cache/artifact-cache-create-rule.png)
4. In the **New cache rule** pane, enter a **Rule name**.
5. For **Source**, select a login server.
6. For **Repository Path**, enter the full repository path to the artifacts you want to cache.
7. Depending on your source, **Authentication** might be required. If the **Authentication** box isn't already checked, and you don't want to use authentication, you can skip this section. Otherwise, ensure the box is checked and add your credentials:

    - Select **Create new credentials** to create a new set of credentials to store the username and password for your source registry. For more information, see [create new credentials](tutorial-enable-artifact-cache-auth#create-new-credentials).
    - To use existing credentials, choose **Select credentials** from the drop-down menu.
8. For **Destination**, enter the name of the **New ACR repository namespace** to store cached artifacts.
9. Select **Create** to create your cache rule.

    ![Screenshot showing details entered to create a new cache rule for a container registry in the Azure portal.](media/container-registry-artifact-cache/artifact-cache-enter-rule-details.png)

Important

If the target Azure container registry is network-restricted by using private endpoints or public IP access rules, enable **Allow trusted Microsoft services to access this container registry**. Artifact cache can't populate the target registry when trusted-services access is disabled. For configuration steps, see [Allow trusted services to securely access a network-restricted container registry](allow-access-trusted-services).

## Create new credentials

Before configuring the credentials, make sure you're able to [create and store secrets in the Azure Key Vault](/en-us/azure/key-vault/secrets/quick-create-cli#add-a-secret-to-key-vault) and [retrieve secrets from the Key Vault](/en-us/azure/key-vault/secrets/quick-create-cli#retrieve-a-secret-from-key-vault).

1. In your container registry's **Cache** pane, select **Credentials**, then select **Create credentials**.

    ![Screenshot of the steps to start adding credentials for a container registry in Azure portal.](media/container-registry-artifact-cache/artifact-cache-create-credentials.png)
2. Enter a **Name** for the new credentials for your source registry.
3. Select a **Source Authentication**. Artifact cache currently supports **Select from Key Vault** and **Enter secret URIs**.
4. For the **Select from Key Vault** option, [create your credentials using Key Vault](/en-us/azure/key-vault/secrets/quick-create-cli#add-a-secret-to-key-vault).
5. Select **Create**.

    ![Screenshot showing details entered to create credentials for a container registry in Azure portal.](media/container-registry-artifact-cache/artifact-cache-enter-credential-details.png)

Alternately, you can use Azure RBAC to assign the **Key Vault Secrets User** role (or a custom role that includes the `Microsoft.KeyVault/vaults/secrets/getSecret/action` permission) to the system identity. For more information, see [Assign Azure roles using the Azure portal](/en-us/azure/role-based-access-control/role-assignments-portal) and [Grant permission to applications to access an Azure Key Vault using Azure RBAC](/en-us/azure/key-vault/general/rbac-guide?tabs=azure-portal).