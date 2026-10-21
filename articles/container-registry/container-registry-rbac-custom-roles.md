---
layout: Conceptual
title: Azure Container Registry custom roles - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-rbac-custom-roles
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
description: Use Azure RBAC custom roles to create your own fine-grained roles for Azure Container Registry.
ms.topic: concept-article
ms.date: 2025-04-24T00:00:00.0000000Z
locale: en-us
document_id: 6dc069d2-2819-4eb2-9742-06ecf8fad958
document_version_independent_id: a00bc472-4ec6-7ab8-65fe-b0c463c6f571
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-rbac-custom-roles.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-rbac-custom-roles
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-rbac-custom-roles.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
platformId: 0bf5bd3f-25e2-722a-a5b6-202058438303
---

# Azure Container Registry custom roles - Azure Container Registry | Microsoft Learn

Azure Container Registry (ACR) supports [Azure role-based access control (RBAC)](/en-us/azure/role-based-access-control/) to manage access to your registry. If none of the [Azure Container Registry built-in roles](container-registry-rbac-built-in-roles-overview) suit your needs, you can create custom roles with fine-grained permissions tailored to your scenario. This article describes the steps to define, create, and assign custom roles for Azure Container Registry.

## Custom role permissions

A set of permissions (actions and data actions) define a custom role. The permissions defined in the custom role determine what operations users can perform on registry resources.

To determine which permissions (actions and data actions) should be defined in a custom role, you can:

- Review the JSON definition of [Azure built-in roles directory for Containers](/en-us/azure/role-based-access-control/built-in-roles/containers) which includes commonly used permissions (actions and data actions) that are used in ACR built-in roles,
- Review the complete list of `Microsoft.ContainerRegistry` resource provider permissions ([Azure Container Registry reference of actions and data actions](/en-us/azure/role-based-access-control/permissions/containers#microsoftcontainerregistry))

To programmatically list all available permissions (actions and data actions) for the `Microsoft.ContainerRegistry` resource provider, you can use the following Azure CLI or Azure PowerShell commands.

```azurecli
az provider operation show --namespace Microsoft.ContainerRegistry
```

```azurepowershell
Get-AzProviderOperation -OperationSearchString Microsoft.ContainerRegistry/*
```

## Example: Custom role to manage webhooks

For example, the following JSON defines the minimum permissions (actions and data actions) for a custom role that permits [managing ACR webhooks](container-registry-webhook).

```json
{
   "assignableScopes": [
     "/subscriptions/<optional, but you can limit the visibility to one or more subscriptions>"
   ],
   "description": "Manage Azure Container Registry webhooks.",
   "Name": "Container Registry Webhook Contributor",
   "permissions": [
     {
       "actions": [
         "Microsoft.ContainerRegistry/registries/webhooks/read",
         "Microsoft.ContainerRegistry/registries/webhooks/write",
         "Microsoft.ContainerRegistry/registries/webhooks/delete"
       ],
       "dataActions": [],
       "notActions": [],
       "notDataActions": []
     }
   ],
   "roleType": "CustomRole"
 }
```

## Creating or updating a custom role

To define a custom role with a JSON definition, see [steps to create a custom role](/en-us/azure/role-based-access-control/custom-roles#steps-to-create-a-custom-role). You can create the custom role using [Azure CLI](/en-us/azure/role-based-access-control/custom-roles-cli), [Azure Resource Manager template](/en-us/azure/role-based-access-control/custom-roles-template), or [Azure PowerShell](/en-us/azure/role-based-access-control/custom-roles-powershell).

Note

In tenants configured with [Azure Resource Manager private link](/en-us/azure/azure-resource-manager/management/create-private-link-access-portal), Azure Container Registry supports wildcard actions such as `Microsoft.ContainerRegistry/*/read` or `Microsoft.ContainerRegistry/registries/*/write` in custom roles, granting access to all matching actions. In a tenant without an ARM private link, don't use wildcards and specify all required registry actions individually in a custom role.

## Assigning a custom role

Add or remove role assignments for a custom role in the same way that you manage role assignments for built-in roles. Learn more about assigning Azure roles to an Azure identity by using the [Azure portal](/en-us/azure/role-based-access-control/role-assignments-portal), the [Azure CLI](/en-us/azure/role-based-access-control/role-assignments-cli), [Azure PowerShell](/en-us/azure/role-based-access-control/role-assignments-powershell), or other Azure tools.