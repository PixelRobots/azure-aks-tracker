---
layout: Conceptual
title: Azure attribute-based access control (Azure ABAC) repository permissions in Azure Container Registry - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-rbac-abac-repository-permissions
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
description: Use Azure ABAC to manage repository permissions for an Azure Container Registry.
ms.topic: how-to
ms.date: 2025-12-11T00:00:00.0000000Z
locale: en-us
document_id: 5be8412f-a015-d1b8-17c5-0622c22e3d33
document_version_independent_id: bcb30d49-04fd-62ed-505d-dfbc095f4500
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-rbac-abac-repository-permissions.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-rbac-abac-repository-permissions
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-rbac-abac-repository-permissions.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: b3fdc213-e06e-ccc9-be12-809a2b200f80
---

# Azure attribute-based access control (Azure ABAC) repository permissions in Azure Container Registry - Azure Container Registry | Microsoft Learn

Azure Container Registry (ACR) supports [Azure attribute-based access control (Azure ABAC)](/en-us/azure/role-based-access-control/conditions-overview) for managing repository permissions. This feature enhances security by enabling more granular permissions management to container registry repositories.

Azure ABAC builds upon Azure role-based access control (Azure RBAC) by introducing repository-specific conditions in role assignments. By using Azure ABAC, you can grant a security principal access to a repository resource based on attributes.

This article describes how to enable Azure ABAC for repository permissions in your container registry, the effects of changing the role assignment permissions mode, and how to configure role assignments with ABAC conditions.

Important

**ABAC-enabled mode (`rbac-abac`) will become the default role assignment permissions mode for Azure Container Registry in the future.** We recommend that all customers migrate their existing registries from RBAC-only mode to ABAC-enabled mode. You don't need to use ABAC conditions to benefit from this mode—assigning ABAC-enabled roles without conditions grants registry-wide permissions, similar to legacy roles.

**Switching an existing registry to ABAC-enabled mode without first assigning equivalent ABAC-enabled roles risks cutting off access for existing identities.** Legacy ACR roles such as `AcrPull`, `AcrPush`, and `AcrDelete` are not honored in ABAC-enabled registries. Follow the recommended migration guide to transition safely.

## Configure role assignment permissions mode setting

To use Azure ABAC to manage repository permissions, set the **Role assignment permissions mode** for your registry to **RBAC Registry + ABAC Repository Permissions**. This mode allows you to use optional ABAC conditions to scope role assignments to specific repositories, in addition to RBAC role assignments by using [ACR built-in roles](container-registry-rbac-built-in-roles-overview).

You can configure the **Role assignment permissions mode** when creating your registry, or you can update the setting on any existing registry. You can set this configuration through the [Azure portal](container-registry-get-started-portal#create-a-container-registry) or the [Azure CLI](container-registry-get-started-azure-cli#configure-role-assignment-permissions-mode).

If you change the setting for an existing registry, be sure to understand the effects on existing role assignments and tasks as described in the following sections.

Note

Ensure that you have the latest version of the Azure CLI installed by running the Azure CLI command `az upgrade`. Additionally, if you previously participated in the preview of this feature, you might have installed a custom preview extension to manage ACR ABAC. This custom extension is no longer needed and should be uninstalled (to avoid conflicts) by running the Azure CLI command `az extension remove --name acrabac`.

### Effect on existing role assignments

If you configure a registry to use **RBAC Registry + ABAC Repository Permissions**, be aware that some existing role assignments aren't honored or have different effects. A different set of ACR built-in roles apply to ABAC-enabled registries.

For example, the `AcrPull`, `AcrPush`, and `AcrDelete` roles aren't honored in an ABAC-enabled registry. Instead, in ABAC-enabled registries, use the `Container Registry Repository Reader`, `Container Registry Repository Writer`, and `Container Registry Repository Contributor` roles to grant either registry-wide or repository-specific image permissions.

Additionally, privileged roles such as `Owner`, `Contributor`, and `Reader` have different effects in an ABAC-enabled registry. In these repositories, these privileged roles grant only control plane permissions to create, update, and delete the registry itself, without granting data plane permissions to the repositories and images in the registry.

For more information on these roles, see [Azure Container Registry permissions and role assignments overview](container-registry-rbac-built-in-roles-overview). Alternatively, consult the [ACR built-in roles reference](container-registry-rbac-built-in-roles-directory-reference) for an in-depth description of each role.

### Effect on ACR Tasks, Quick Tasks, Quick Builds, and Quick Runs

If you configure a registry to use **RBAC Registry + ABAC Repository Permissions**, new and existing ACR Tasks, as well as Quick Tasks, Quick Builds, and Quick Runs, are affected. They no longer have default data plane access to an ABAC-enabled source registry and its content.

To understand the effects of this change—and how to grant data plane access for ACR Tasks, Quick Tasks, Quick Builds, and Quick Runs in ABAC-enabled source registries—see Effects of enabling ABAC on ACR Tasks, Quick Tasks, Quick Builds, and Quick Runs.

### Create a registry with ABAC enabled

You can enable Azure ABAC by using the Azure portal or the Azure CLI.

# [Azure portal](#tab/azure-portal)
When creating a [new registry through Azure portal](container-registry-get-started-portal), select **RBAC Registry + ABAC Repository Permissions** for **Role assignment permissions mode**.

![Screenshot showing the container registry creation settings in the portal.](media/container-registry-get-started-portal/configure-container-registry-options.png)

# [Azure CLI](#tab/azure-cli)
When running `az acr create`, use the `--role-assignment-mode` parameter to [set the role assignment permissions mode](container-registry-get-started-azure-cli#configure-role-assignment-permissions-mode). Specify `rbac-abac` to create a registry with Azure ABAC enabled:

```azurecli
az acr create --name <registry-name> --resource-group <resource-group> --sku <sku> --role-assignment-mode 'rbac-abac' --location <location>
```

---

### Update an existing registry to enable ABAC

Important

Changing the role assignment permissions mode of an existing registry can affect existing role assignments and tasks, as described in the previous sections. Be sure to review these effects before changing the setting.

# [Azure portal](#tab/azure-portal)
To view the existing role assignment permissions mode of a registry, go to the registry in the Azure portal. In the service menu, under **Settings**, select **Properties**, then check the **Role assignment permissions mode** setting.

To enable Azure RBAC, select **RBAC Registry + ABAC Repository Permissions**, then select **Save.**

# [Azure CLI](#tab/azure-cli)
When running `az acr update`, use the `--role-assignment-mode` parameter to set the registry role assignment permissions mode. Specify `rbac-abac` to create a registry with **RBAC Registry + ABAC Repository Permissions** enabled.

To show the current role assignment permissions mode of a registry, run the following command:

```azurecli
az acr show --name <registry-name> --resource-group <resource-group> --query "roleAssignmentMode"
```

To update an existing registry to enable Azure ABAC, run the following command:

```azurecli
az acr update --name <registry-name> --resource-group <resource-group> --role-assignment-mode 'rbac-abac'
```

---

## Configure Azure ABAC repository permissions

You can use either the Azure portal or Azure CLI to assign Azure ABAC conditions to scope role assignments to specific repositories.

Tip

The Azure portal supports a limited number of ABAC conditions per role assignment. To add more ABAC conditions, use the Azure CLI.

This section provides examples of how to add ABAC conditions for a specific repository, a repository prefix (wildcard), or multiple repository prefixes (multiple wildcards).

### ABAC-enabled built-in roles

The following ACR built-in roles are ABAC-enabled roles. You can specify optional ABAC conditions to the following roles to scope the role assignments to specific repositories.

- `Container Registry Repository Reader` - ABAC-enabled role that grants permissions to **read** images, tags, and metadata within repositories in a registry.
- `Container Registry Repository Writer` - ABAC-enabled role that grants permissions to **read, write, and update** images, tags, and metadata within repositories in a registry.
- `Container Registry Repository Contributor` - ABAC-enabled role that grants permissions to **read, write, update, and delete** images, tags, and metadata within repositories in a registry.

These roles don't support catalog listing permissions to list repositories in a registry. To list all repositories in a registry (without granting permissions to read repository content), you must also assign the `Container Registry Repository Catalog Lister` role. This separate role doesn't support ABAC conditions, so it always has permissions to list all repositories in a registry.

Important

**If you assign an ABAC-enabled role without ABAC conditions, the role assignment isn't scoped to repositories**. This role assignment acts as a registry-wide role assignment, granting permissions to all repositories in the registry. **To scope a role assignment to specific repositories, include ABAC conditions when assigning an ABAC-enabled role**.

For more information on these roles, see [Azure Container Registry permissions and role assignments overview](container-registry-rbac-built-in-roles-overview) and the [ACR built-in roles reference](container-registry-rbac-built-in-roles-directory-reference).

### Scope role assignment to a specific repository

This example assigns the `Container Registry Repository Reader` role to grant pull permissions to a single repository. By adding ABAC conditions, the role assignment lets the identity pull images, view tags, and read metadata only from the specified repository, preventing access to other repositories in the registry.

# [Azure portal](#tab/azure-portal)
1. Go to the registry in the Azure portal. In the service menu, select **Access control (IAM)**.
2. Select **Add**, and then select **Add role assignment**.
3. Search for `Container Registry Repository Reader`. Select that role, and then select **Next**.
4. In the **Members** tab, specify the identity who should be assigned this role, and then select **Next**.
5. In the **Conditions** tab, select **Add condition**.
6. Ensure **Visual** is selected for **Editor type**.
7. Under **Condition #1**, select the actions (permissions) belonging to this role that you want to grant in this repository-scoped role assignment. In most cases, select all actions to limit all actions performed by identities with this role to the repository scope. Choose **Select** to save your changes.

    [![Screenshot of selecting actions and permissions to grant for an Azure ABAC role assignment.](media/container-registry-rbac-abac-repository-permissions/attribute-based-access-control-role-assignment-actions.png)](media/container-registry-rbac-abac-repository-permissions/attribute-based-access-control-role-assignment-actions.png#lightbox)
8. Next, under **Build expression**, select **Add expression**. Configure the following options for the expression to scope the ABAC condition to a specific repository:

    - **Attribute source**: `Request`
    - **Attribute**: `Repository name`
    - **Operator**: `StringEqualsIgnoreCase`
    - **Value**: `<repository-name>` - the full name of the repository

    [![Screenshot of building an expression in an Azure ABAC role assignment.](media/container-registry-rbac-abac-repository-permissions/attribute-based-access-control-assignment-expression.png)](media/container-registry-rbac-abac-repository-permissions/attribute-based-access-control-assignment-expression.png#lightbox)
9. Select **Save** to save the ABAC condition, and then review the code expression of the ABAC condition. You can use this code to perform the same role assignment with the same ABAC condition by using the Azure CLI.

    [![Screenshot of reviewing the code for an expression in an Azure ABAC role assignment.](media/container-registry-rbac-abac-repository-permissions/attribute-based-access-control-role-assignment-expression-code.png)](media/container-registry-rbac-abac-repository-permissions/attribute-based-access-control-role-assignment-expression-code.png#lightbox)
10. Select **Review + assign** to finalize the role assignment.

After you create the role assignment, you can view, edit, or delete it in the **Access control (IAM)** page for your registry by selecting **Role assignments**.

# [Azure CLI](#tab/azure-cli)
To add a role assignment with an ABAC condition scoped to a specific repository, use [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create). This command includes the following parameters related to ABAC conditions:

| Parameter | Type | Description |
| --- | --- | --- |
| `role` | String | The name or ID of the role to assign, such as `Container Registry Repository Reader`. |
| `scope` | String | The full resource ID of the registry. Use the registry resource ID (without the repository name), even for role assignments scoped to a specific repository, with the format `/subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.ContainerRegistry/registries/{registry-name}`. You can also specify the resource group or subscription scope to perform this role assignment across all registries in the resource group or subscription. |
| `assignee` | String | The email address or object ID of the identity to assign the role to. For example, specify `user@contoso.com` for a user assignee. You can also specify the object ID of the identity. |
| `assignee-object-id` | String | Use this parameter instead of `--assignee` to bypass Graph API invocation if there's insufficient privileges. This parameter only works with object IDs for users, groups, service principals, and managed identities. For managed identities, use the principal ID. For service principals, use the object ID and not the application ID. |
| `description` | String | A description for the role assignment to help identify the purpose of the role assignment. This parameter is optional. |
| `condition` | String | A code expression which defines the ABAC condition for the role assignment. |
| `condition-version` | String | Version of the condition syntax. If `--condition` is specified without `--condition-version`, the version is set to the default value of `2.0`. |

To create the expression for the ABAC condition, we recommend [using the visual editor in the Azure portal role assignment experience](/en-us/azure/container-registry/container-registry-rbac-abac-repository-permissions?tabs=azure-portal#assigning-microsoft-entra-abac-repository-permissions). For this example, use the following expression for the ABAC condition to restrict the role assignment to the repository `hello-world`:

```
(
 (
  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})
  AND
  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'})
 )
 OR 
 (
  @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringEqualsIgnoreCase 'hello-world'
 )
)
```

You can store this ABAC condition into a shell variable named `condition` for use in the `az role assignment create` command:

```azurecli
condition=$(cat <<'EOF' | tr -d '\n'
(
 (
  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})
  AND
  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'})
 )
 OR 
 (
  @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringEqualsIgnoreCase 'hello-world'
 )
)
EOF
)
```

Inspect the `condition` variable carefully to verify that it's correct. Be sure to use double quotes (`"`) whenever you use the `condition` variable.

```azurecli
echo "$condition"
```

Before performing the role assignment, query the registry resource ID for the `--scope` parameter. Always use the registry resource ID (without the repository name) for the `--scope` parameter, even for role assignments scoped to a specific repository. You can also specify the resource group or subscription scope to perform this role assignment across all registries in the resource group or subscription.

```azurecli
scope=$(az acr show --name <registry-name> --resource-group <resource-group> --query "id" -o tsv)
```

Finally, run the following command to perform the role assignment:

```azurecli
az role assignment create \
  --role "Container Registry Repository Reader" \
  --scope "$scope" \
  --assignee "user@contoso.com" \
  --description "Read access to a specific repository" \
  --condition "$condition" \
  --condition-version "2.0"
```

The following shows an example of the output:

```json
{
    "canDelegate": null,
    "condition": "( (  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})  AND  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'}) ) OR  (  @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringEqualsIgnoreCase 'hello-world' ))",
    "conditionVersion": "2.0",
    "description": "{description}",
    "id": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Authorization/roleAssignments/{roleAssignmentId}",
    "name": "{roleAssignmentId}",
    "principalId": "{userObjectId}",
    "principalType": "User",
    "resourceGroup": "{resourceGroup}",
    "roleDefinitionId": "/subscriptions/{subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/{roleDefinitionId}",
    "scope": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.ContainerRegistry/registries/{registryName}",
    "type": "Microsoft.Authorization/roleAssignments"
}
```

To update or delete the role assignment, use [`az role assignment update`](/en-us/cli/azure/role/assignment#az-role-assignment-update) or [`az role assignment delete`](/en-us/cli/azure/role/assignment#az-role-assignment-delete).

---

### Scope role assignment to multiple repositories using repository prefix (wildcard)

In this example, you assign the `Container Registry Repository Reader` role to grant pull permissions to multiple repositories with a common prefix (wildcard). By adding ABAC conditions, this role assignment lets the identity pull images, view tags, and read metadata only from the repositories with a common prefix, while preventing access to other repositories in the registry.

# [Azure portal](#tab/azure-portal)
If you followed the previous example to assign the `Container Registry Repository Reader` role to a specific repository, delete that role assignment before you create a new one. You can delete the assignment in **Access control (IAM)** by selecting **Role assignments**, selecting the role assignment, and then selecting **Delete**.

1. Follow the same steps as in the previous example to perform a role assignment with ABAC conditions.
2. In the step to add an expression for the ABAC condition, configure an expression for an ABAC condition to scope the role assignment to multiple repositories with a common prefix (wildcard). Configure the following options:

    - **Attribute source**: `Request`
    - **Attribute**: `Repository name`
    - **Operator**: `StringStartsWithIgnoreCase`
    - **Value**: `<repository-prefix>` - the prefix of the repositories, including the trailing slash `/`. For example, to grant permissions to all repositories with the prefix `backend/`, such as `backend/nginx` and `backend/redis`, enter `backend/`. To grant permissions to all repositories with the prefix `frontend/js/`, such as `frontend/js/react` and `frontend/js/vue`, enter `frontend/js/`.

        Important

        The trailing slash `/` is required in the `Value` field for the expression of the ABAC condition. If you don't include the trailing slash `/`, you might unintentionally grant permissions to other repositories that don't match the prefix. For example, if you enter `backend` without the trailing slash `/`, the role assignment grants permissions to all repositories with the prefix `backend`, such as `backend/nginx`, `backend/redis`, `backend-infra/k8s`, `backend-backup/store`, `backend`, and `backendsvc/containers`.
3. Select **Save** to save the ABAC condition, then review the code expression of the ABAC condition.
4. Select **Review + assign** to finalize the role assignment.

# [Azure CLI](#tab/azure-cli)
If you followed the previous example to assign the `Container Registry Repository Reader` role to a specific repository, delete that role assignment (by using [`az role assignment delete`](/en-us/cli/azure/role/assignment#az-role-assignment-delete)) before creating a new one with an ABAC condition scoped to a repository prefix.

To add a role assignment with an ABAC condition scoped to multiple repositories under a prefix, use [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create).

To create the expression for the ABAC condition, we recommend [using the visual editor in the Azure portal role assignment experience](/en-us/azure/container-registry/container-registry-rbac-abac-repository-permissions?tabs=azure-portal#assigning-microsoft-entra-abac-repository-permissions). For this example, use the following expression for the ABAC condition to restrict the role assignment to repositories with the prefix `backend/`, such as `backend/nginx` and `backend/redis`:

```
(
 (
  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})
  AND
  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'})
 )
 OR 
 (
  @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringStartsWithIgnoreCase 'backend/'
 )
)
```

Follow the steps described in the first section to store this ABAC condition into a shell variable named `condition` and query the registry resource ID for the `--scope` parameter. Then perform the role assignment by running the following command:

```azurecli
az role assignment create \
  --role "Container Registry Repository Reader" \
  --scope "$scope" \
  --assignee "user@contoso.com" \
  --description "Read access to a multiple repositories under a repository prefix" \
  --condition "$condition" \
  --condition-version "2.0"
```

The following shows an example of the output:

```json
{
    "canDelegate": null,
    "condition": "( (  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})  AND  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'}) ) OR  (  @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringStartsWithIgnoreCase 'backend/' ))",
    "conditionVersion": "2.0",
    "description": "{description}",
    "id": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Authorization/roleAssignments/{roleAssignmentId}",
    "name": "{roleAssignmentId}",
    "principalId": "{userObjectId}",
    "principalType": "User",
    "resourceGroup": "{resourceGroup}",
    "roleDefinitionId": "/subscriptions/{subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/{roleDefinitionId}",
    "scope": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.ContainerRegistry/registries/{registryName}",
    "type": "Microsoft.Authorization/roleAssignments"
}
```

---

### Scope role assignment to multiple repositories using multiple repository prefixes (multiple wildcards)

In this example, you assign the `Container Registry Repository Reader` role to grant pull permissions to multiple repositories under two different prefixes (multiple wildcards). By adding ABAC conditions, this role assignment lets the identity pull images, view tags, and read metadata only from the specified repositories, preventing access to other repositories in the registry.

# [Azure portal](#tab/azure-portal)
If you followed the previous example to assign the `Container Registry Repository Reader` role to a specific repository prefix, delete that role assignment before you create a new one. You can delete the assignment in **Access control (IAM)** by selecting **Role assignments**, selecting the role assignment, and then selecting **Delete**.

1. Follow the same steps as in the first example to perform a role assignment with ABAC conditions.
2. In the step to add an expression for the ABAC condition, configure two expressions to scope the role assignment to multiple repositories under two prefixes: `backend/` and `frontend/js/` (multiple wildcards). Include the trailing slash `/` in each prefix.

    For the first expression, configure the following options:

    - **Attribute source**: `Request`
    - **Attribute**: `Repository name`
    - **Operator**: `StringStartsWithIgnoreCase`
    - **Value**: `backend/`
3. Select **Add expression**. The visual editor also supports multiple boolean operators including **And**, **Or**, hierarchical grouping, and negation. For this example, ensure that the boolean operator is set to **Or**.
4. For the second expression, configure the following options:

    - **Attribute source**: `Request`
    - **Attribute**: `Repository name`
    - **Operator**: `StringStartsWithIgnoreCase`
    - **Value**: `frontend/js/`

    [![Screenshot showing an example of configuring an ABAC condition with multiple repository prefixes.](media/container-registry-rbac-abac-repository-permissions/attribute-based-access-control-role-assignment-multiple-prefix-code.png)](media/container-registry-rbac-abac-repository-permissions/attribute-based-access-control-role-assignment-multiple-prefix-code.png#lightbox)
5. Select **Save** to save the ABAC condition, then review the code expression of the ABAC condition.
6. Select **Review + assign** to finalize the role assignment.

# [Azure CLI](#tab/azure-cli)
If you followed the previous example to assign the `Container Registry Repository Reader` role to a specific repository prefix, delete that role assignment (by using [`az role assignment delete`](/en-us/cli/azure/role/assignment#az-role-assignment-delete)) before creating a new one with an ABAC condition scoped to a repository prefix.

To add a role assignment with an ABAC condition scoped to multiple repositories under a prefix, use [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create).

To create the expression for the ABAC condition, we recommend [using the visual editor in the Azure portal role assignment experience](/en-us/azure/container-registry/container-registry-rbac-abac-repository-permissions?tabs=azure-portal#assigning-microsoft-entra-abac-repository-permissions). For this example, use the following expression for the ABAC condition to restrict the role assignment to repositories with either the prefix `backend/` or `frontend/js/`:

```
(
 (
  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})
  AND
  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'})
 )
 OR 
 (
  @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringStartsWithIgnoreCase 'backend/'
  OR
  @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringStartsWithIgnoreCase 'frontend/js/'
 )
)
```

Follow the steps described in the first section to store this ABAC condition into a shell variable named `condition` and query the registry resource ID for the `--scope` parameter. Then perform the role assignment by running the following command:

```azurecli
az role assignment create \
  --role "Container Registry Repository Reader" \
  --scope "$scope" \
  --assignee "user@contoso.com" \
  --description "Read access to a multiple repositories under multiple repository prefixes" \
  --condition "$condition" \
  --condition-version "2.0"
```

The following shows an example of the output:

```json
{
    "canDelegate": null,
    "condition": "( (  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})  AND  !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'}) ) OR  (  @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringStartsWithIgnoreCase 'backend/' ))",
    "conditionVersion": "2.0",
    "description": "{description}",
    "id": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Authorization/roleAssignments/{roleAssignmentId}",
    "name": "{roleAssignmentId}",
    "principalId": "{userObjectId}",
    "principalType": "User",
    "resourceGroup": "{resourceGroup}",
    "roleDefinitionId": "/subscriptions/{subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/{roleDefinitionId}",
    "scope": "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.ContainerRegistry/registries/{registryName}",
    "type": "Microsoft.Authorization/roleAssignments"
}
```

---

## Effects of enabling ABAC on ACR Tasks, Quick Tasks, Quick Builds, and Quick Runs

When you enable Azure ABAC for repository permissions in your container registry by setting the **Role assignment permissions mode** to **RBAC Registry + ABAC Repository Permissions**, new and existing ACR Tasks, as well as Quick Tasks, Quick Builds, and Quick Runs, are affected. Review the following sections to understand these effects and how to grant data plane access for these tasks in ABAC-enabled source registries.

### Effect on ACR Tasks

When you configure a registry with **"RBAC Registry + ABAC Repository Permissions"**, new and existing ACR Tasks no longer have default data plane access to the source registry, including its images and artifacts within repositories.

You must explicitly attach and set an identity for new and existing ACR Tasks to use for authentication to an ABAC-enabled source registry. Then, grant the attached identity the appropriate ACR built-in role to enable authentication and access to registry repositories.

#### Attach an identity to a new ACR Task for source registry access

For ABAC-enabled source registries, use `az acr task create` with the `--source-acr-auth-id` flag to specify the identity the Task uses to authenticate to the source registry.

You can specify one of the following options for the `--source-acr-auth-id` flag:

- `--source-acr-auth-id [system]` – Attaches a system-assigned managed identity.
- `--source-acr-auth-id $resourceId` – Attaches a user-assigned managed identity by using its resource ID.

Once you attach the identity, assign it an ACR built-in role (optionally with ABAC conditions) to grant appropriate permissions.

#### Update an existing ACR Task to use an identity for source registry access

For ABAC-enabled source registries, use `az acr task update` with the same `--source-acr-auth-id` options to assign or change the identity the Task uses to authenticate to the source registry. As with new Tasks, follow up with the appropriate role assignment.

#### Remove source registry access from an ACR Task

To explicitly prevent an ACR Task from authenticating by using an ABAC-enabled source registry and block the Task's permissions to the source registry, set `--source-acr-auth-id none`. This action disables the task's ability to perform any operations on the source registry and content within it.

Note

Note: The `--auth-mode` flag is deprecated for ABAC-enabled registries and is no longer supported for controlling ACR Task access.

### Effect on Quick Tasks, Quick Builds, and Quick Runs

When you configure a registry with **"RBAC Registry + ABAC Repository Permissions"**, new Quick Tasks such as [Quick Builds](/en-us/cli/azure/acr#az-acr-build) and [Quick Runs](/en-us/cli/azure/acr#az-acr-run) no longer have default data plane access to the source registry, including its images and artifacts within repositories. For Quick Tasks, you must use the caller's identity to authenticate the Quick Task to the source registry. The caller's identity must have the appropriate ACR built-in role to enable authentication and access to registry repositories.

#### Run a Quick Task with the caller identity for source registry access

For ABAC-enabled source registries, use `az acr build` or `az acr run` with the `--source-acr-auth-id [caller]` option to specify the caller's identity as the identity the Quick Task uses to authenticate to the source registry. Before running the Quick Task, ensure that the caller's identity has the appropriate ACR built-in role to enable authentication and access to the source registry and its repositories.

#### Run a Quick Task without source registry access

To run a Quick Task without any source registry access, use `az acr build` or `az acr run` with the `--source-acr-auth-id none` option. This setting disables the Quick Task's ability to perform any operations on the source registry and content within it.

## Migrate from RBAC-only to ABAC-enabled mode

If you have an existing registry using RBAC-only mode (**RBAC Registry Permissions**), you should migrate to ABAC-enabled mode (**RBAC Registry + ABAC Repository Permissions**). Enabling ABAC doesn't require you to use ABAC conditions—you can assign ABAC-enabled roles without conditions to grant registry-wide permissions equivalent to the legacy roles.

Caution

**Switching an existing registry to ABAC-enabled mode without first assigning equivalent ABAC-enabled roles risks cutting off access for existing identities.** Legacy ACR roles such as `AcrPull`, `AcrPush`, and `AcrDelete` aren't honored in ABAC-enabled registries. Follow the recommended transition plan in the next section to minimize access disruptions.

### Recommended transition plan

Switching modes briefly disrupts clients that cached credentials under RBAC-only mode until those clients refresh, which can take from minutes to hours depending on how each client is configured. Follow these steps to migrate an existing registry from RBAC-only mode to ABAC-enabled mode with minimal disruption to existing identities:

#### Step 1: Keep the registry in RBAC-only mode

Don't change the role assignment permissions mode yet. Leave the registry in **RBAC Registry Permissions** mode while you prepare the new role assignments.

#### Step 2: Assign the equivalent ABAC-enabled roles

For each identity (user, group, service principal, or managed identity) that currently has a legacy role assignment, create an additional role assignment using the equivalent ABAC-enabled role **without ABAC conditions**. Assigning the role without conditions grants registry-wide access, which is equivalent to the legacy role.

The following table maps legacy ACR roles to their ABAC-enabled equivalents:

| Legacy role (RBAC-only) | Equivalent ABAC-enabled role(s) |
| --- | --- |
| `AcrPull` | `Container Registry Repository Reader` + `Container Registry Repository Catalog Lister` |
| `AcrPush` | `Container Registry Repository Writer` |
| `AcrDelete` | `Container Registry Repository Contributor` |

The ABAC-enabled roles don't include catalog listing permissions to list repositories, so you must also assign the `Container Registry Repository Catalog Lister` role to maintain equivalent access.

For example, if an identity or group currently has an `AcrPull` role assignment (which allows pull and repository list permissions), create additional role assignments with the `Container Registry Repository Reader` role (without any ABAC conditions) and the `Container Registry Repository Catalog Lister` role.

##### Assign the equivalent role using the Azure portal

1. Go to the registry in the Azure portal. In the service menu, select **Access control (IAM)**.
2. Select **Add**, and then select **Add role assignment**.
3. Search for the equivalent ABAC-enabled role (for example, `Container Registry Repository Reader`). Select that role, and then select **Next**.
4. Select the identity (user, group, service principal, or managed identity) that currently has the legacy role. Select **Next**.
5. On the **Conditions** tab, don't add any conditions. Select **Next**, then select **Review + assign**.

##### Assign the equivalent role using the Azure CLI

```azurecli
# Example: Assign the equivalent of AcrPull by assigning the roles as per the table
az role assignment create \
  --assignee <principal-id-or-group-object-id> \
  --role "Container Registry Repository Reader" \
  --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ContainerRegistry/registries/<registry-name>

az role assignment create \
  --assignee <principal-id-or-group-object-id> \
  --role "Container Registry Repository Catalog Lister" \
  --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ContainerRegistry/registries/<registry-name>
```

#### Step 3: Switch the registry to ABAC-enabled mode

After you assign the equivalent ABAC-enabled roles to all existing identities, transition the registry to ABAC-enabled mode. Before you switch, allow a few minutes for the new role assignments to propagate through Azure RBAC.

Warning

Switching to ABAC-enabled mode invalidates the registry credentials that clients obtained while the registry was in RBAC-only mode. The registry binds each credential to the role assignment permissions mode that was in effect when the credential was issued, so a credential issued in RBAC-only mode is rejected with an authentication error (HTTP `401`) after the switch, **even for identities that already have equivalent ABAC-enabled role assignments**. Affected clients can't pull or push images until they refresh and obtain a new credential while the registry is in ABAC-enabled mode. This disruption is expected; it lasts until each client refreshes its cached credential, which can take from a few minutes to several hours depending on how the client is configured.

Refreshing credentials before the switch doesn't prevent this problem, because any credential obtained while the registry is still in RBAC-only mode is invalidated by the switch. Refresh cached credentials on all clients immediately after the switch, as described in the next step.

# [Azure portal](#tab/azure-portal)
In the Azure portal, go to the registry. In the service menu, under **Settings**, select **Properties**. Change the **Role assignment permissions mode** to **RBAC Registry + ABAC Repository Permissions**, and then select **Save**.

# [Azure CLI](#tab/azure-cli)
```azurecli
az acr update --name <registry-name> --resource-group <resource-group> --role-assignment-mode 'rbac-abac'
```

---

#### Step 4: Refresh cached credentials on all clients

Immediately after you switch the registry to ABAC-enabled mode, refresh the registry credentials that your clients cached so they obtain new credentials that are valid in ABAC-enabled mode. Until a client refreshes, it keeps using the credential that it cached under RBAC-only mode, which the registry now rejects.

Refresh credentials in one of the following ways:

- **Force an immediate refresh (recommended to minimize disruption).** Restart the client or its credential provider so that it requests a new credential right away. For example, on Azure Kubernetes Service (AKS), restart kubelet on the affected nodes, or replace the nodes, so that they obtain new credentials while the registry is in ABAC-enabled mode. Restarting your workloads (for example, restarting pods) doesn't refresh the credential, because the credential is cached by the client's credential provider rather than by the workload.
- **Wait for the cached credentials to expire.** If you don't force a refresh, each client recovers on its own when its cached credential expires and it requests a new one. Each client platform (for example, AKS) determines and configures the credential cache lifetime, not the registry. As a result, affected clients can fail to pull or push images for as long as that cache lifetime after the switch. This period often ranges from a few minutes to several hours depending on the client's configuration.

To reduce the effect of this window, validate the entire sequence in a preproduction environment that mirrors your production registries and clients before you perform the migration in production.

#### Step 5: Confirm access with the ABAC-enabled roles

Before removing any legacy role assignments, verify that all identities continue to have the expected access with the new ABAC-enabled roles. For example:

- Verify that Kubernetes clusters can still pull images from the registry.
- Verify that CI/CD pipelines can still push images to the registry.
- Verify that any other automated processes that interact with the registry continue to work.

If any identity loses access, check the role assignments and verify that the correct ABAC-enabled role is assigned before proceeding.

#### Step 6: Remove the legacy role assignments

After you've confirmed the ABAC-enabled roles are correctly assigned and the registry is in ABAC-enabled mode, remove the legacy role assignments (for example, `AcrPull`, `AcrPush`, `AcrDelete`) to clean up.

##### Remove the legacy role using the Azure CLI

```azurecli
# Example: Remove the legacy AcrPull role assignment
az role assignment delete \
  --assignee <principal-id-or-group-object-id> \
  --role "AcrPull" \
  --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ContainerRegistry/registries/<registry-name>
```

#### Step 7: Validate access with only the ABAC-enabled roles

After removing the legacy role assignments, perform a final validation to confirm that all identities still have the expected access using only the ABAC-enabled roles.