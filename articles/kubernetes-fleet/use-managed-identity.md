---
layout: Conceptual
title: Use a managed identity in Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/use-managed-identity
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
adobe-target: true
learn_banner_products:
- azure
description: Learn how to use a system-assigned or user-assigned managed identity in Azure Kubernetes Fleet Manager
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: how-to
ms.date: 2025-08-04T00:00:00.0000000Z
locale: en-us
document_id: 2d4f3a45-916a-c759-7085-da0d5835dd8e
document_version_independent_id: f60360d5-8224-0507-2d23-ceb33877099a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/use-managed-identity.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/use-managed-identity
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/use-managed-identity.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: e907be87-02cb-2219-a624-3daf2ba4e6d8
---

# Use a managed identity in Azure Kubernetes Fleet Manager | Microsoft Learn

Azure Kubernetes Fleet Manager uses a Microsoft Entra identity to access Azure resources like Azure virtual networks or to manage long-running background activities such as multi-cluster [auto-upgrade](update-automation).

You can use a managed identity to authorize access from a Fleet Manager to any service that supports Microsoft Entra authorization, without needing to manage credentials or include them in your code. You assign an Azure role-based access control (Azure RBAC) role to the managed identity to grant it permissions to a particular resource in Azure. For more information about Azure RBAC, see [What is Azure role-based access control (Azure RBAC)?](/en-us/azure/role-based-access-control/overview).

This article shows how to enable the following types of managed identity on a new or existing Azure Kubernetes Fleet Manager:

- **System-assigned managed identity.** A system-assigned managed identity is associated with a single Azure resource, such as a Fleet Manager. It exists for the lifecycle of the Fleet Manager only.
- **User-assigned managed identity.** A user-assigned managed identity is a standalone Azure resource that a Fleet Manager can use to authorize access to other Azure services. It persists separately from the Fleet Manager and can be used by multiple Azure resources.

To learn more about managed identities, see [Managed identities for Azure resources](/en-us/entra/identity/managed-identities-azure-resources/overview).

## Before you begin

If you intend to use the Azure CLI, make sure you have Azure CLI version 2.75.0 or later installed. To find the version, run `az --version`. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

Before running the Azure CLI examples in this article, set your subscription as the current active subscription by calling the [az account set](/en-us/cli/azure/account#az-account-set) command and passing in your subscription ID.

```azurecli
az account set --subscription <subscription-id>
```

Also create an Azure resource group if you don't already have one by calling the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

```azurecli
az group create \
    --name myResourceGroup \
    --location westus2
```

## Enable a system-assigned managed identity

A system-assigned managed identity is an identity that is associated with a Fleet Manager or another Azure resource. The system-assigned managed identity is tied to the lifecycle of the Fleet Manager. When the Fleet Manager is deleted, the system-assigned managed identity is also deleted.

Fleet Manager can use the system-assigned managed identity to authorize access to other resources running in Azure and execute long-running background processes. You can assign an Azure RBAC role to the system-assigned managed identity to grant the Fleet Manager permissions to access specific resources. For example, if your Fleet Manager needs to manage network resources, you can assign to the system-assigned managed identity an Azure RBAC role that grants those permissions.

### Enable a system-assigned managed identity on a new Fleet Manager

# [Azure portal](#tab/azure-portal)
When you create a new Fleet Manager in the Azure portal, a system-assigned managed identity is automatically created.

You can verify that the system-assigned managed identity is enabled by checking the **Identity** blade in the Fleet Manager's **Settings** section. The **Status** is **On** and the **Object (principal) ID** is populated (not shown in image).

[![Screenshot of the Azure Kubernetes Fleet Manager Azure portal Identity pane showing the System assigned identity configuration. Object (principal) ID is blanked out.](media/managed-identity/managed-identity-system-assigned.png)](media/managed-identity/managed-identity-system-assigned.png#lightbox)

# [Azure CLI](#tab/cli)
Create a Fleet Manager using the [`az fleet create`](/en-us/cli/azure/fleet#az-fleet-create) command, passing the `--enable-managed-identity` parameter to enable the system-assigned managed identity.

```azurecli
az fleet create \
    --resource-group myResourceGroup \
    --name myFleetName \
    --location westus2 \
    --enable-managed-identity
```

The command output indicates the identity type is **SystemAssigned** and includes the principal ID and tenant.

```output
{
  "eTag": "\"13003f4b-0000-1b00-0000-68900c3c0000\"",
  "hubProfile": null,
  "id": "/subscriptions/<subscription-id>/resourceGroups/myResourceGroup/providers/Microsoft.ContainerService/fleets/myFleetName",
  "identity": {
    "principalId": "<principal-id>",
    "tenantId": "<tenant-id>",
    "type": "SystemAssigned",
    "userAssignedIdentities": null
  },
  "location": "westus2",
  "name": "flt-mgr-02",
  "provisioningState": "Succeeded",
  "resourceGroup": "myResourceGroup",
  "status": {
    "lastOperationError": null,
    "lastOperationId": "d31e866c-a3d3-46ab-8a97-094bc4672d35"
  },
  "systemData": {
    "createdAt": "2025-08-04T01:26:17.588030+00:00",
    "createdBy": "",
    "createdByType": "User",
    "lastModifiedAt": "2025-08-04T01:26:17.588030+00:00",
    "lastModifiedBy": "",
    "lastModifiedByType": "User"
  },
  "tags": null,
  "type": "Microsoft.ContainerService/fleets"
}
```

---

### Update an existing Fleet Manager to use a system-assigned managed identity

# [Azure portal](#tab/azure-portal)
You can manage the Fleet Manager managed identity using the **Identity** blade in the Fleet Manager's **Settings** section.

1. Enable the system-assigned managed identity by setting the **System assigned** status to **On** and selecting **Save**.

    [![Screenshot of the Azure Kubernetes Fleet Manager Azure portal Identity pane showing system assigned identity disabled.](media/managed-identity/managed-identity-enable-system-assigned-01.png)](media/managed-identity/managed-identity-enable-system-assigned-01.png#lightbox)
2. Select **Yes** on the confirmation dialog.
3. After a few moments the **Status** changes to **On** and the **Object (principal) ID** is populated (not shown in image).

    [![Screenshot of the Azure Kubernetes Fleet Manager Azure portal Identity pane showing the system assigned identity configuration.](media/managed-identity/managed-identity-system-assigned.png)](media/managed-identity/managed-identity-system-assigned.png#lightbox)

# [Azure CLI](#tab/cli)
To update an existing Fleet Manager to use a system-assigned managed identity, run the [az fleet update](/en-us/cli/azure/fleet#az-fleet-update) command with the `--enable-managed-identity` parameter set to `true`.

```azurecli
az fleet update \
    --resource-group myResourceGroup \
    --name myFleetName \
    --enable-managed-identity true
```

The command output indicates the identity type is **SystemAssigned** and includes the principal ID and tenant.

```output
{
  "eTag": "\"13003f4b-0000-1b00-0000-68900c3c0000\"",
  "hubProfile": null,
  "id": "/subscriptions/<subscription-id>/resourceGroups/myResourceGroup/providers/Microsoft.ContainerService/fleets/myFleetName",
  "identity": {
    "principalId": "<principal-id>",
    "tenantId": "<tenant-id>",
    "type": "SystemAssigned",
    "userAssignedIdentities": null
  },
  "location": "westus2",
  "name": "flt-mgr-02",
  "provisioningState": "Succeeded",
  "resourceGroup": "myResourceGroup",
  "status": {
    "lastOperationError": null,
    "lastOperationId": "d31e866c-a3d3-46ab-8a97-094bc4672d35"
  },
  "systemData": {
    "createdAt": "2025-08-04T01:26:17.588030+00:00",
    "createdBy": "",
    "createdByType": "User",
    "lastModifiedAt": "2025-08-04T01:26:17.588030+00:00",
    "lastModifiedBy": "",
    "lastModifiedByType": "User"
  },
  "tags": null,
  "type": "Microsoft.ContainerService/fleets"
}
```

---

### Add a role assignment for a system-assigned managed identity

You can assign an Azure RBAC role to the system-assigned managed identity to grant the Fleet Manager permissions on another Azure resource. Azure RBAC supports both built-in and custom role definitions that specify levels of permissions. For more information about assigning Azure RBAC roles, see [Steps to assign an Azure role](/en-us/azure/role-based-access-control/role-assignments-steps).

When you assign an Azure RBAC role to a managed identity, you must define the scope for the role. In general, it's a best practice to limit the scope of a role to the minimum privileges required by the managed identity. For more information on scoping Azure RBAC roles, see [Understand scope for Azure RBAC](/en-us/azure/role-based-access-control/scope-overview).

Note

It can take up to 60 minutes for the permissions granted to your Fleet Manager's managed identity to propagate.

# [Azure portal](#tab/azure-portal)
1. Select **Azure role assignments** tab in the Fleet Manager's **Identity** blade. This opens the **Azure role assignments** pane.

    [![Screenshot of the Azure Role assignments pane.](media/managed-identity/managed-identity-azure-role-assignment-01.png)](media/managed-identity/managed-identity-azure-role-assignment-01.png#lightbox)
2. Select **Add role assignment** to open the **Add role assignment** pane and enter:

    - **Scope** - select **Resource group**.
    - **Subscription** - choose the Azure subscription containing the resource group you want to use.
    - **Resource group** - select the resource group.
    - **Role** - choose the role you want to assign to the Fleet Manager's system-assigned managed identity (for example, **Network Contributor**).

        [![Screenshot of Add Role Assignment pane.](media/managed-identity/managed-identity-azure-role-assignment-02.png)](media/managed-identity/managed-identity-azure-role-assignment-02.png#lightbox)
3. Select **Save** to assign the role to the Fleet Manager's system-assigned managed identity.

# [Azure CLI](#tab/cli)
1. Get the principal ID of the system-assigned managed identity

    To assign an Azure RBAC role to a Fleet Manager's system-assigned managed identity, you first need the principal ID for the managed identity. Get the principal ID for the Fleet Manager's system-assigned managed identity by calling the [`az fleet show`](/en-us/cli/azure/fleet#az-fleet-show) command.

    ```azurecli
    # Get the principal ID for a system-assigned managed identity.
    CLIENT_ID=$(az fleet show \
        --name myFleetName \
        --resource-group myResourceGroup \
        --query identity.principalId \
        --output tsv)
    ```
2. Assign an Azure RBAC role to the system-assigned managed identity

    To grant a system-assigned managed identity permission to a resource in Azure, call the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command to assign an Azure RBAC role to the managed identity.

    For example, assign the `Network Contributor` role on the custom resource group using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. For the `--scope` parameter, provide the resource ID for the resource group for the Fleet Manager.

    ```azurecli
    az role assignment create \
        --assignee $CLIENT_ID \
        --role "Network Contributor" \
        --scope "<fleet-manager-resource-group-id>"
    ```

---

## Enable a user-assigned managed identity

A user-assigned managed identity is a standalone Azure resource. When you create a Fleet Manager with a user-assigned managed identity, the user-assigned managed identity resource must exist before Fleet Manager creation.

### Create a user-assigned managed identity

If you don't yet have a user-assigned managed identity resource, create one using the Azure portal or Azure CLI.

# [Azure portal](#tab/azure-portal)
Follow the steps in the [create a user-assigned managed identity documentation](/en-us/entra/identity/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp#create-a-user-assigned-managed-identity).

# [Azure CLI](#tab/cli)
1. Create a user-assigned managed identity.

    If you don't yet have a user-assigned managed identity resource, create one using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    ```azurecli
    az identity create \
        --name myIdentity \
        --resource-group myResourceGroup
    ```

    Your output should resemble the following example output:

    ```output
    {                                  
      "clientId": "<client-id>",
      "clientSecretUrl": "<clientSecretUrl>",
      "id": "/subscriptions/<subscriptionid>/resourcegroups/myResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myIdentity", 
      "location": "westus2",
      "name": "myIdentity",
      "principalId": "<principal-id>",
      "resourceGroup": "myResourceGroup",                       
      "tags": {},
      "tenantId": "<tenant-id>",
      "type": "Microsoft.ManagedIdentity/userAssignedIdentities"
    }
    ```
2. Get the principal ID of the user-assigned managed identity

    To get the principal ID of the user-assigned managed identity, call [az identity show](/en-us/cli/azure/identity#az-identity-show) and query on the `principalId` property:

    ```azurecli
    CLIENT_ID=$(az identity show \
        --name myIdentity \
        --resource-group myResourceGroup \
        --query principalId \
        --output tsv)
    ```
3. Get the resource ID of the user-assigned managed identity

    To create a Fleet Manager with a user-assigned managed identity, you need the resource ID for the new managed identity. To get the resource ID of the user-assigned managed identity, call [az identity show](/en-us/cli/azure/identity#az-identity-show) and query on the `id` property:

    ```azurecli
    RESOURCE_ID=$(az identity show \
        --name myIdentity \
        --resource-group myResourceGroup \
        --query id \
        --output tsv)
    ```

---

### Assign an Azure RBAC role to the user-assigned managed identity

Before you create the Fleet Manager, add a role assignment for the managed identity.

Note

It may take up to 60 minutes for the permissions granted to your Fleet Manager's managed identity to propagate.

# [Azure portal](#tab/azure-portal)
1. Navigate to the managed identity resource.
2. Select **Azure role assignments** tab in the managed identity resource's left navigation. This opens the **Azure role assignments** pane.

    [![Screenshot of the Azure Role assignments pane.](media/managed-identity/managed-identity-azure-role-assignment-01.png)](media/managed-identity/managed-identity-azure-role-assignment-01.png#lightbox)
3. Select **Add role assignment** to open the **Add role assignment** pane and enter:

    - **Scope** - select **Resource group**.
    - **Subscription** - choose the Azure subscription containing the resource group you want to use.
    - **Resource group** - select the resource group.
    - **Role** - choose the role you want to assign to the managed identity (for example, **Network Contributor**).

        [![Screenshot of Add Role Assignment pane.](media/managed-identity/managed-identity-azure-role-assignment-02.png)](media/managed-identity/managed-identity-azure-role-assignment-02.png#lightbox)
4. Select **Save** to assign the role to the managed identity.

# [Azure CLI](#tab/cli)
Use the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command to assign a role to the user-assigned managed identity.

The following example assigns the **Network Contributor** role to grant the identity permissions to access networking resources. The role assignment is scoped to the Fleet Manager resource group.

```azurecli
az role assignment create \
    --assignee $CLIENT_ID \
    --role "Network Contributor" \
    --scope "<fleet-manager-resource-group-id>"
```

---

### Create a Fleet Manager with the user-assigned managed identity

Note

The USDOD Central, USDOD East, and USGov Iowa regions in Azure US Government cloud don't support creating a Fleet Manager with a user-assigned managed identity.

# [Azure portal](#tab/azure-portal)
You can't create a Fleet Manager with a user-assigned managed identity in the Azure portal. You can change the Fleet Manager identity type to user-assigned after the Fleet Manager is created, or use the Azure CLI.

# [Azure CLI](#tab/cli)
Create a Fleet Manager with the user-assigned managed identity by using the [`az fleet create`](/en-us/cli/azure/fleet#az-fleet-create) command with the `--assign-identity` parameter. Pass in the resource ID for the user-assigned managed identity:

```azurecli
az fleet create \
    --resource-group myResourceGroup \
    --name myFleetName \
    --assign-identity $RESOURCE_ID
```

---

### Update an existing Fleet Manager to use a user-assigned managed identity

# [Azure portal](#tab/azure-portal)
You can manage the Fleet Manager managed identity using the **Identity** blade in the Fleet Manager's **Settings** section.

1. Switch to the user-assigned managed identity tab by selecting **User assigned**.

    [![Screenshot of the Azure Kubernetes Fleet Manager Azure portal Identity blade showing an empty user assigned identity list.](media/managed-identity/managed-identity-enable-user-assigned-01.png)](media/managed-identity/managed-identity-enable-user-assigned-01.png#lightbox)
2. Select **+ Add** to open the **Add user assigned managed identity** pane.

    - **Subscription** - choose the Azure subscription containing the user-assigned managed identity you want to use.
    - **User assigned managed identities** - search for the user-assigned managed identity you want to use.

    [![Screenshot of the Azure Kubernetes Fleet Manager Azure portal Identity blade showing the add user assigned managed identity pane.](media/managed-identity/managed-identity-enable-user-assigned-02.png)](media/managed-identity/managed-identity-enable-user-assigned-02.png#lightbox)
3. Select **Add** to add the user-assigned managed identity to the Fleet Manager.
4. After a few moments the **User assigned** list changes and the user-assigned managed identity is listed.

    [![Screenshot of the Azure Kubernetes Fleet Manager Azure portal Identity blade showing the user assigned identity list with a single entry.](media/managed-identity/managed-identity-enable-user-assigned-03.png)](media/managed-identity/managed-identity-enable-user-assigned-03.png#lightbox)

# [Azure CLI](#tab/cli)
To update an existing Fleet Manager to use a user-assigned managed identity, call the [`az fleet update`](/en-us/cli/azure/fleet#az-fleet-update) command. Include the `--assign-identity` parameter and pass in the resource ID for the user-assigned managed identity:

```azurecli
az fleet update \
    --resource-group myResourceGroup \
    --name myFleetName \
    --enable-managed-identity \
    --assign-identity $RESOURCE_ID
```

The output for a successful Fleet Manager update to use a user-assigned managed identity should resemble the following example output:

```output
  "identity": {
    "principalId": null,
    "tenantId": null,
    "type": "UserAssigned",
    "userAssignedIdentities": {
      "/subscriptions/<subscriptionid>/resourcegroups/myResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myIdentity": {
        "clientId": "<client-id>",
        "principalId": "<principal-id>"
      }
    }
  },
```

---

## Determine type of managed identity in use

# [Azure portal](#tab/azure-portal)
You can check the Fleet Manager managed identity settings using the **Identity** blade in the Fleet Manager's **Settings** section.

Check both the **System assigned** and **User assigned** sections to determine which type of managed identity is enabled.

[![Screenshot of the Azure Kubernetes Fleet Manager Azure portal Identity pane showing a populated system assigned identity.](media/managed-identity/managed-identity-system-assigned.png)](media/managed-identity/managed-identity-system-assigned.png#lightbox)

# [Azure CLI](#tab/cli)
To determine which type of managed identity your existing Fleet Manager is using, call the [az fleet show](/en-us/cli/azure/fleet#az-fleet-show) command and query for the identity's *type* property.

```azurecli
az fleet show \
    --name myFleetName \
    --resource-group myResourceGroup \
    --query identity.type \
    --output tsv       
```

The response is either **SystemAssigned** or **UserAssigned**.

---