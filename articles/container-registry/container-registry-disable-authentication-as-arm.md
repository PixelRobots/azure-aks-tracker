---
layout: Conceptual
title: Configure Registry Acceptance of Microsoft Entra Authentication Scopes - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-disable-authentication-as-arm
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
description: Configure Azure Container Registry to accept ARM-scoped Microsoft Entra authentication (broad) or ACR-scoped Microsoft Entra authentication (narrow) for enhanced security.
ms.custom: devx-track-arm-template, devx-track-azurecli
ms.topic: how-to
ms.date: 2026-02-06T00:00:00.0000000Z
locale: en-us
document_id: f8cb75e8-b435-b511-6225-fd207be046fe
document_version_independent_id: 4604b910-4720-7635-8ed7-982345683592
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-disable-authentication-as-arm.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-disable-authentication-as-arm
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-disable-authentication-as-arm.md
cmProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/57eae307-c3a1-4cac-b645-1a899934bac8
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/ee561821-1ac7-45a8-9409-6ba5eb7a5b97
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: c3b6faed-8480-6b98-fbd3-7da6c0a5cd65
---

# Configure Registry Acceptance of Microsoft Entra Authentication Scopes - Azure Container Registry | Microsoft Learn

Microsoft Entra authentication with Azure Container Registry (ACR) follows a two-hop process. First, users authenticate with Microsoft Entra ID to get an authentication token with a specific authentication audience scope (for example, `az login`). Next, users authenticate with the registry by using that Microsoft Entra authentication token (for example, `az acr login`). By default, in the second step during registry authentication, registries accept both ARM-scoped Microsoft Entra authentication (broad Azure Resource Manager access) and ACR-scoped Microsoft Entra authentication (narrow registry-specific access). For enhanced security, you can configure your registry to accept only ACR-scoped Microsoft Entra authentication.

Note

Some Azure services and integrations might not work when your registry is configured to accept only ACR-scoped Microsoft Entra authentication. Test compatibility in nonproduction environments before enforcing this configuration in production.

This article shows you how to configure a container registry for ACR-scoped Microsoft Entra authentication by using the Azure CLI or the Azure portal.

## Prerequisites

- [Install or upgrade Azure CLI](/en-us/cli/azure/install-azure-cli) version 2.40.0 or later. To find the version, run `az --version`.
- Sign in to the [Azure portal](https://portal.azure.com).

## Understanding Microsoft Entra authentication scopes for ACR

This section explains the two-hop authentication flow, the difference between authentication scopes, and how registry configuration controls access.

### Two-hop authentication flow

Authentication with ACR involves two distinct steps that apply to Azure CLI users, Azure services, and programmatic code using Software Development Kits (SDKs):

1. **First hop - Authenticate with Microsoft Entra ID**: Run `az login` to authenticate with Microsoft Entra ID and get a Microsoft Entra authentication token. This token contains an audience scope that determines what Azure resources it can access:

    - By default, `az login` gets an ARM-scoped Microsoft Entra authentication token (broad Azure Resource Manager access).
    - By using `az login --scope https://containerregistry.azure.net/.default`, you get an ACR-scoped Microsoft Entra authentication token (narrow registry-specific access).
2. **Second hop - Authenticate with the ACR service**: Run `az acr login` to authenticate with the ACR service by using the Microsoft Entra authentication token from the first hop. At this point, the registry's configuration determines whether to accept or reject your registry authentication attempt based on the scope of your Microsoft Entra authentication token.

### Microsoft Entra authentication scope types

**ARM-scoped Microsoft Entra authentication**

- Provides broad access to the Azure Resource Manager (ARM), the control plane for managing all Azure resources.
- This scope type is the default when you run `az login` with no other parameters.
- ARM-scoped Microsoft Entra authentication tokens are overly permissive for container registry operations as they grant access beyond what you need for registry authentication.

**ACR-scoped Microsoft Entra authentication**

- Provides narrow, registry-specific access limited to ACR operations only.
- Requires explicitly specifying `--scope https://containerregistry.azure.net/.default` during `az login`.
- Follows the principle of least privilege by granting only the permissions necessary for container registry operations.

### Registry configuration options

Your registry configuration, controlled by the `azureADAuthenticationAsArmPolicy` property, determines what happens during the second authentication hop (`az acr login`):

- **When enabled** (default): The registry accepts both ARM-scoped and ACR-scoped Microsoft Entra authentication.
- **When disabled** (recommended): The registry accepts only ACR-scoped Microsoft Entra authentication and rejects ARM-scoped authentication.

Important

When using Web Apps with Azure Container Registry (ACR), image pulls rely on ARM-scoped credentials. Disabling ARM authentication on the registry will cause image pull failures.

### Why ACR recommends ACR-scoped authentication only

Configuring your registry to accept only ACR-scoped Microsoft Entra authentication provides several benefits:

- **Enhanced security**: Limits authentication to narrowly scoped Microsoft Entra authentication tokens, reducing the attack surface.
- **Least privilege access**: Ensures Microsoft Entra authentication tokens used for registry authentication have only the permissions necessary for container registry operations.
- **Compliance alignment**: Helps meet security and compliance requirements that mandate minimal privilege access patterns.
- **Best practice**: Aligns with Azure security best practices for identity and access management.

## Configure registry for ACR-scoped Microsoft Entra authentication - Azure CLI

You can configure your registry to control which Microsoft Entra authentication scopes are accepted during the second authentication hop. The `azureADAuthenticationAsArmPolicy` property controls this configuration.

Requires Azure CLI version 2.40.0 or later. To find your version, run `az --version`.

### Check current registry configuration

Run the following command to view your registry's current configuration:

```azurecli
az acr config authentication-as-arm show -r <registry>
```

The status value shows the current configuration:

- **enabled** (default): Registry accepts both ARM-scoped and ACR-scoped Microsoft Entra authentication.
- **disabled** (recommended): Registry accepts only ACR-scoped Microsoft Entra authentication.

### Update registry configuration

To configure your registry to accept only ACR-scoped Microsoft Entra authentication, set the status to `disabled`:

```azurecli
az acr config authentication-as-arm update -r <registry> --status disabled
```

To revert to the default configuration that accepts both ARM-scoped and ACR-scoped Microsoft Entra authentication:

```azurecli
az acr config authentication-as-arm update -r <registry> --status enabled
```

## Authenticate using ACR-scoped Microsoft Entra authentication

This section shows how to perform the two-hop authentication flow by using ACR-scoped Microsoft Entra authentication. This authentication method works with both registry configurations, but is required when your registry is configured to accept only ACR-scoped Microsoft Entra authentication.

### First hop: Get ACR-scoped Microsoft Entra authentication token

To get an ACR-scoped Microsoft Entra authentication token, specify the `--scope` parameter when running `az login`:

```azurecli
az login --scope https://containerregistry.azure.net/.default
```

This command authenticates you by using Microsoft Entra ID and gets a Microsoft Entra authentication token with ACR-specific scope. The authentication token is stored in your local cache.

Note

To get a Microsoft Entra authentication token scoped for the ACR service, you must specify `https://containerregistry.azure.net/.default`. You can't specify `https://registryname.azurecr.io/` as the scope, as Microsoft Entra ID and ACR don't support registry-specific Microsoft Entra authentication audiences.

### Second hop: Authenticate with the registry

After getting the ACR-scoped Microsoft Entra authentication token in the first hop, authenticate with your registry:

```azurecli
az acr login -n <registry>
```

During this second hop, the registry validates your Microsoft Entra authentication token. If you configure your registry to accept only ACR-scoped authentication, it rejects ARM-scoped tokens and only accepts the ACR-scoped Microsoft Entra authentication token you got in the first hop.

You can use the ACR-scoped Microsoft Entra authentication token to authenticate with all ACR registries that you have permissions to access.

## Configure registry for ACR-scoped Microsoft Entra authentication - Azure portal

You can use Azure Policy to configure your registries to accept only ACR-scoped Microsoft Entra authentication. Assigning a built-in policy automatically configures the registry property for current and future registries within the policy scope. You can apply the policy at either the resource group level or the subscription level.

Azure Container Registry provides two built-in policy definitions for configuring ACR-scoped Microsoft Entra authentication:

- **`Container registries should have ARM audience token authentication disabled.`** - This policy reports and blocks noncompliant resources, and can automatically update noncompliant registries to the recommended configuration.
- **`Configure container registries to disable ARM audience token authentication.`** - This policy offers remediation capabilities and updates noncompliant registries to accept only ACR-scoped authentication.

For more policy definitions, see [Azure Container Registry built-in policy definitions](policy-reference).

### Assign a built-in policy definition

To configure your registries to accept only ACR-scoped Microsoft Entra authentication by using Azure Policy:

1. Sign in to the [Azure portal](https://portal.azure.com).
2. Go to the resource group that contains your Azure Container Registry.
3. In the service menu, under **Settings**, select **Policies**.
4. On the **Policy** page, under **Authoring**, select **Assignments** and select **Assign policy**.
5. On the **Assign policy** tab, use filters to search and find the **Scope**, **Policy definition**, and **Assignment name**.

    ![Screenshot of the Assign policy tab.](media/container-registry-enable-conditional-policy/03-assign-policy-tab.png)
6. Select **Scope** to filter and search for the **Subscription** and **Resource Group** and choose **Select**.
7. Select **Policy definition** to filter and search for the built-in policy definitions that configure ACR-scoped authentication.

    ![Screenshot of built-in-policy-definitions.](media/container-registry-enable-conditional-policy/05-built-in-policy-definitions.png)
8. Use filters to select and confirm **Scope**, **Policy definition**, and **Assignment name**.
9. Use the filters to limit compliance states or to search for policies.
10. Confirm your settings and set policy enforcement as **enabled**. This setting ensures the policy configures registries within the scope to accept only ACR-scoped Microsoft Entra authentication.
11. Select **Review+Create**.