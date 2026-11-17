---
layout: Conceptual
title: Grant access to AI Manager (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/ai-manager/grant-access
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
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Choose and assign Azure roles for AI Manager management, model catalog access, inference, and Kubernetes objects.
ai-usage: ai-assisted
author: asabbour
ms.author: asabbour
ms.topic: how-to
ms.date: 2026-10-13T00:00:00.0000000Z
ms.custom: devx-track-azurecli
locale: en-us
document_id: 41d1b753-0aae-f0a2-7810-71f5e3baf615
document_version_independent_id: 4498076c-a241-a030-1f39-78aa116a442d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/ai-manager/grant-access.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/ai-manager/grant-access
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/ai-manager/grant-access.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/fcc3cd4a-59ea-47a2-9cc1-784142a5a25d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d7a55faf-a992-4e27-aa3a-eadc9830e778
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: d3fa97e0-4ec4-be79-1cd5-bdc56837102e
---

# Grant access to AI Manager (preview) - Azure Kubernetes Service | Microsoft Learn

Use separate Azure roles for managing AI Manager resources, reading the model catalog, sending inference requests, and reading Kubernetes objects. Assign each role at the narrowest scope that meets the user's task.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Before you begin

- An Azure subscription with an AI Manager resource group, AI Manager, and namespace as needed for the access you're assigning.
- Azure CLI with access to the AI Manager CLI extension for the public preview, and permission to create role assignments at the target scope.
- The object ID of the user, group, or application that needs access. To find a user's object ID, run `az ad user show --id "<user-principal-name>" --query id --output tsv`. For a group, run `az ad group show --group "<group-name-or-id>" --query id --output tsv`. For an application, run `az ad sp show --id "<application-client-id>" --query id --output tsv` to get its service principal object ID.

The person creating a role assignment needs **User Access Administrator** or another role that can create role assignments at the target scope. **Azure AIManager Contributor** doesn't grant permission to assign roles.

## Choose a role and scope

| Task | Role | Recommended scope |
| --- | --- | --- |
| Create and manage AI Manager resources | `Azure AIManager Contributor` | Resource group when creating an AI Manager. After creation, use the AI Manager or namespace scope to limit ongoing access. |
| Read AI Manager resources or list credentials and namespace API keys | `Azure AIManager User` | AI Manager or namespace |
| Read model catalog entries and calculate deployment costs | `Azure AIManager Model User` | Subscription scope, because the model catalog is scoped to a subscription and location |
| List namespace API keys and send inference requests | `Azure AIManager Inference User` | Namespace. Assigning it at the AI Manager scope grants access across its namespaces. |
| Read Kubernetes objects other than secrets, roles, and role bindings | `Azure AIManager RBAC Reader` | AI Manager or namespace |
| Read and write Kubernetes objects | `Azure AIManager RBAC Admin` | Use only for exceptional recovery; this role is broad. |

The roles differ in three ways that affect inference and credentials:

- **Inference data action:** For direct Microsoft Entra ID authentication, Azure RBAC checks the inference data action. **Azure AIManager Inference User** grants it. **Azure AIManager Contributor** and **Azure AIManager User** don't grant the inference data action.
- **Namespace API keys:** **Azure AIManager Contributor**, **Azure AIManager User**, and **Azure AIManager Inference User** can list namespace API keys. Anyone who obtains a namespace API key can use it for inference, even without the inference data action. Treat permission to list namespace API keys as access to inference credentials.
- **Kubernetes objects:** **Azure AIManager Inference User** doesn't grant general Kubernetes object or secret access.

Model catalog resources have a location-scoped ARM path under the subscription, not under a resource group or AI Manager. Assign **Azure AIManager Model User** at the subscription scope or another applicable parent scope. A role assignment only at the AI Manager or namespace scope doesn't grant catalog access.

## Set AI Manager scope variables

Set the names and subscription for the resources, and then create the scope IDs. Replace the principal object ID with the ID of the user, group, or application you're assigning.

```bash
export SUBSCRIPTION_ID="<subscription-id>"
export RESOURCE_GROUP="<resource-group>"
export MANAGER_NAME="<ai-manager-name>"
export NAMESPACE_NAME="<namespace-name>"
export PRINCIPAL_OBJECT_ID="<principal-object-id>"

az account set --subscription "$SUBSCRIPTION_ID"

export RESOURCE_GROUP_SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
export MANAGER_SCOPE="$RESOURCE_GROUP_SCOPE/providers/Microsoft.ContainerService/aiManagers/$MANAGER_NAME"
export NAMESPACE_SCOPE="$MANAGER_SCOPE/namespaces/$NAMESPACE_NAME"
```

## Assign an AI Manager role

Run these commands in the same shell session as Set AI Manager scope variables, or redefine the variables first. Set `--assignee-principal-type` to `User`, `Group`, or `ServicePrincipal` to match the principal that you're assigning.

For example, assign inference access to one namespace:

```azurecli
az role assignment create \
  --assignee-object-id "$PRINCIPAL_OBJECT_ID" \
  --assignee-principal-type User \
  --role "Azure AIManager Inference User" \
  --scope "$NAMESPACE_SCOPE"
```

To let a user create and manage AI Manager resources in the resource group, assign **Azure AIManager Contributor** at the resource group scope:

```azurecli
az role assignment create \
  --assignee-object-id "$PRINCIPAL_OBJECT_ID" \
  --assignee-principal-type User \
  --role "Azure AIManager Contributor" \
  --scope "$RESOURCE_GROUP_SCOPE"
```

To grant model catalog access and cost calculation, assign **Azure AIManager Model User** at the subscription scope:

```azurecli
az role assignment create \
  --assignee-object-id "$PRINCIPAL_OBJECT_ID" \
  --assignee-principal-type User \
  --role "Azure AIManager Model User" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

## Verify an AI Manager role assignment

List assignments at the namespace scope, including assignments inherited from parent scopes:

```azurecli
az role assignment list \
  --assignee "$PRINCIPAL_OBJECT_ID" \
  --scope "$NAMESPACE_SCOPE" \
  --include-inherited \
  --output table
```

The output lists each role that the principal has at the namespace scope, including roles inherited from a parent scope. Confirm that the role you assigned appears in the `Role` column, and check the `Scope` column to see where it's assigned.

Azure role assignments aren't always effective immediately. If an operation still fails after you assign a role, see [Troubleshoot Azure RBAC](/en-us/azure/role-based-access-control/troubleshooting). For inference access, see [Connect an application to a model endpoint](connect-to-endpoint).