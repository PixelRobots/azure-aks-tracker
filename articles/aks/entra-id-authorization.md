---
layout: Conceptual
title: Use Microsoft Entra ID Authorization for the Kubernetes API in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/entra-id-authorization
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
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to authorize Kubernetes API access in Azure Kubernetes Service (AKS) using Microsoft Entra ID role assignments and ABAC conditions.
ms.topic: how-to
ms.subservice: aks-security
ms.custom: devx-track-azurecli, aeo-round-2
ms.date: 2026-08-18T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: df729d61-7afc-697f-d5b7-a6d772abdc3e
document_version_independent_id: 2eeb1025-a63e-0613-a900-99b209a3d7ea
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/entra-id-authorization.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/entra-id-authorization
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/entra-id-authorization.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/1433a524-c01f-4b87-beab-670c040dea4f
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://microsoft-devrel.poolparty.biz/DevRelOfferingOntology/312f1f05-a431-4193-8a4d-e6245d5966de
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: feacb223-aafd-14a0-4f0e-f17f4172d573
---

# Use Microsoft Entra ID Authorization for the Kubernetes API in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic ✔️ AKS Standard

This article shows how to authorize calls to the Kubernetes API in Azure Kubernetes Service (AKS) by using Microsoft Entra ID identities. Microsoft Entra ID authorization for the Kubernetes API uses Azure RBAC role assignments to grant access to Kubernetes resources. For built-in Kubernetes resources, assign one of the AKS built-in roles (such as Azure Kubernetes Service RBAC Reader) at the cluster or namespace scope. For custom resources (CRDs), assign a custom role with Azure ABAC conditions that specify which CRD groups or kinds the assignee can access. The two role assignments compose: one grants access to standard Kubernetes resources, and the other grants conditional access to specific custom resources.

For most production workloads, AKS Automatic is the recommended production-ready default for AKS. AKS Automatic clusters are preconfigured with Azure RBAC for Kubernetes authorization, so you can focus on assigning the right Microsoft Entra role assignments to users, groups, and service principals.

For a conceptual overview of the available Kubernetes API authorization options in AKS, see [Cluster authorization concepts](concepts-cluster-authorization).

Note

When you use [integrated authentication between Microsoft Entra ID and AKS](managed-azure-ad), you can use Microsoft Entra users, groups, or service principals as subjects in [Kubernetes role-based access control (Kubernetes RBAC)](kubernetes-rbac-entra-id). By using Microsoft Entra ID authorization, you don't need to separately manage user identities and credentials for Kubernetes. However, you still need to set up and manage Microsoft Entra ID role assignments and any Kubernetes RBAC bindings separately.

Note

AKS Automatic clusters are preconfigured to use Azure RBAC for Kubernetes authorization. You don't need to enable `--enable-azure-rbac` on AKS Automatic clusters. In AKS Standard, you can enable or disable Azure RBAC based on your cluster configuration.

## Prerequisites

- You need the Azure CLI version 2.24.0 or later installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need `kubectl`, with a minimum version of [1.18.3](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#v1183).
- You need managed Microsoft Entra integration enabled on your cluster before you can add Microsoft Entra ID authorization for the Kubernetes API. If you need to enable managed Microsoft Entra integration, see [Use Microsoft Entra ID in AKS](managed-azure-ad).
- New role assignments can take up to five minutes to propagate and be updated by the authorization server.
- Microsoft Entra ID authorization for the Kubernetes API requires that the Microsoft Entra tenant configured for authentication is the same as the tenant for the subscription that holds your AKS cluster.

## AKS cluster mode behavior

| Cluster mode | Azure RBAC for Kubernetes authorization |
| --- | --- |
| AKS Automatic | Preconfigured (enabled by default) |
| AKS Standard | Optional (enable with `--enable-azure-rbac`) |

## Create a new AKS cluster with managed Microsoft Entra integration and Microsoft Entra ID authorization

### AKS Automatic (recommended for production workloads)

For new production workloads, use AKS Automatic. Azure RBAC for Kubernetes authorization is preconfigured on AKS Automatic clusters.

1. Create an AKS Automatic cluster by following [Create an Azure Kubernetes Service (AKS) Automatic cluster](automatic/quick-automatic-managed-network).
2. Optional: verify that Azure RBAC for Kubernetes authorization is enabled on your cluster using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    # Set environment variables
    export RESOURCE_GROUP=<resource-group-name>
    export CLUSTER_NAME=<cluster-name>
    
    az aks show \
      --resource-group $RESOURCE_GROUP \
      --name $CLUSTER_NAME \
      --query "aadProfile.enableAzureRbac" \
      --output tsv
    ```

### AKS Standard

1. Create an Azure resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    export RESOURCE_GROUP=<resource-group-name>
    export LOCATION=<azure-region>
    
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```
2. Create an AKS Standard cluster with managed Microsoft Entra integration and Microsoft Entra ID authorization using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

    ```azurecli
    export CLUSTER_NAME=<cluster-name>
    
    az aks create \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --enable-aad \
        --enable-azure-rbac \
        --generate-ssh-keys
    ```

    Your output should look similar to the following example output:

    ```output
    "AADProfile": {
        "adminGroupObjectIds": null,
        "clientAppId": null,
        "enableAzureRbac": true,
        "managed": true,
        "serverAppId": null,
        "serverAppSecret": null,
        "tenantId": "****-****-****-****-****"
    }
    ```

## Enable Microsoft Entra ID authorization on an existing AKS cluster

For existing AKS Standard clusters, enable Microsoft Entra ID authorization for the Kubernetes API using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-azure-rbac` flag.

```azurecli
# Set environment variables
export RESOURCE_GROUP=<resource-group-name>
export CLUSTER_NAME=<cluster-name>

# Enable Microsoft Entra ID authorization for the Kubernetes API
az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --enable-azure-rbac
```

AKS Automatic clusters already have Azure RBAC for Kubernetes authorization preconfigured. You don't need to run `--enable-azure-rbac` for AKS Automatic.

## AKS built-in roles

AKS provides the following built-in roles:

| Role | Description |
| --- | --- |
| [Azure Kubernetes Service RBAC Reader](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-service-rbac-reader) | Allows read-only access to see most objects in a namespace. It doesn't allow viewing roles or role bindings. This role doesn't allow viewing `Secrets`, since reading the contents of Secrets enables access to ServiceAccount credentials in the namespace, which would allow API access as any ServiceAccount in the namespace (a form of privilege escalation). |
| [Azure Kubernetes Service RBAC Writer](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-service-rbac-writer) | Allows read/write access to most objects in a namespace. This role doesn't allow viewing or modifying roles or role bindings. However, this role allows accessing `Secrets` and running Pods as any ServiceAccount in the namespace, so it can be used to gain the API access levels of any ServiceAccount in the namespace. |
| [Azure Kubernetes Service RBAC Admin](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-service-rbac-admin) | Allows admin access, intended to be granted within a namespace. Allows read/write access to most resources in a namespace (or cluster scope), including the ability to create roles and role bindings within the namespace. This role doesn't allow write access to resource quota or to the namespace itself. |
| [Azure Kubernetes Service RBAC Cluster Admin](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-service-rbac-cluster-admin) | Allows super-user access to perform any action on any resource. It gives full control over every resource in the cluster and in all namespaces. |

## Create role assignments for cluster access

# [Azure CLI](#tab/azure-cli)
1. Get your AKS resource ID using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    # Set environment variables
    export RESOURCE_GROUP=<resource-group-name>
    export CLUSTER_NAME=<cluster-name>
    
    # Get the AKS resource ID
    AKS_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query id --output tsv)
    ```
2. Create a role assignment using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. `<AAD-ENTITY-ID>` can be a username or the client ID of a service principal. The following example creates a role assignment for the Azure Kubernetes Service RBAC Admin role.

    ```azurecli
    # Set environment variables
    export RESOURCE_GROUP=<resource-group-name>
    export CLUSTER_NAME=<cluster-name>
    
    # Get the AKS resource ID
    AKS_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query id --output tsv)
    
    # Create a role assignment for the Azure Kubernetes Service RBAC Admin role
    az role assignment create --role "Azure Kubernetes Service RBAC Admin" --assignee <AAD-ENTITY-ID> --scope $AKS_ID
    ```

    Note

    You can create the Azure Kubernetes Service RBAC Reader and Azure Kubernetes Service RBAC Writer role assignments scoped to a specific namespace within the cluster using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command and setting the scope to the desired namespace.

    ```azurecli
    az role assignment create --role "Azure Kubernetes Service RBAC Reader" --assignee <AAD-ENTITY-ID> --scope $AKS_ID/namespaces/<namespace-name>
    ```

# [Azure portal](#tab/azure-portal)
1. In the [Azure portal](https://portal.azure.com/), navigate to your AKS cluster.
2. In the service menu, select **Access control (IAM)** &gt; **Add role assignment**.
3. On the **Role** tab, select the role you want, such as *Azure Kubernetes Service RBAC Admin*, and then select **Next**.
4. On the **Members** tab, configure the following settings:

    - **Assign access to**: Select **User, group, or service principal**.
    - **Members**: Select **+ Select members**, search for and select the members you want, and then select **Select**.
5. Select **Review + assign** &gt; **Assign**.

    Note

    In the Azure portal, after you create role assignments scoped to a desired namespace, you can't see role assignments for namespace [at a scope](/en-us/azure/role-based-access-control/role-assignments-list-portal#list-role-assignments-at-a-scope). You can find them by using the [`az role assignment list`](/en-us/cli/azure/role/assignment#az-role-assignment-list) command, or [list role assignments for a user or group](/en-us/azure/role-based-access-control/role-assignments-list-portal#list-role-assignments-for-a-user-or-group), which you assigned the role to.

    ```azurecli
    az role assignment list --scope $AKS_ID/namespaces/<namespace-name>
    ```

---

## Create custom roles definitions

For built-in Kubernetes resources, custom role definitions reference the corresponding API group action under `Microsoft.ContainerService/managedClusters/`. The following example allows a user to only read deployments and nothing else. For the full list of possible actions, see [Microsoft.ContainerService operations](/en-us/azure/role-based-access-control/resource-provider-operations#microsoftcontainerservice).

For custom resources, the custom role must grant the applicable custom resource data action, such as `Microsoft.ContainerService/managedClusters/customresources/read`. A custom role alone doesn't filter access by custom resource definition (CRD) group or kind. To apply that filtering, add an Azure ABAC condition to the role assignment. For the complete procedure, see Restrict custom resource access using ABAC conditions.

1. To create your own custom role definitions, copy the following file, replace `<YOUR-SUBSCRIPTION-ID>` with your own subscription ID, and then save it as `deploy-view.json`.

    ```json
    {
        "Name": "AKS Deployment Reader",
        "Description": "Lets you view all deployments in cluster/namespace.",
        "Actions": [],
        "NotActions": [],
        "DataActions": [
            "Microsoft.ContainerService/managedClusters/apps/deployments/read"
        ],
        "NotDataActions": [],
        "assignableScopes": [
            "/subscriptions/<YOUR-SUBSCRIPTION-ID>"
        ]
    }
    ```
2. Create the role definition using the [`az role definition create`](/en-us/cli/azure/role/definition#az-role-definition-create) command, setting the `--role-definition` to the `deploy-view.json` file you created in the previous step.

    ```azurecli
    az role definition create --role-definition @deploy-view.json 
    ```
3. Assign the role definition to a user or other identity using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
        # Set environment variables
    export RESOURCE_GROUP=<resource-group-name>
    export CLUSTER_NAME=<cluster-name>
    
    # Get the AKS resource ID
    AKS_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query id --output tsv)
    
    # Create a role assignment for the AKS Deployment Reader role
    az role assignment create --role "AKS Deployment Reader" --assignee <AAD-ENTITY-ID> --scope $AKS_ID
    ```

## Restrict custom resource access using ABAC conditions (preview)

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

ABAC conditions let you filter Microsoft Entra ID role assignments to specific custom resource (CRD) groups and kinds - centrally, from Microsoft Entra ID, without writing per-cluster Kubernetes RBAC `Role` and `RoleBinding` manifests. For background on Azure ABAC, see [What are Azure role assignment conditions?](/en-us/azure/role-based-access-control/conditions-overview)

### When to use ABAC conditions

Use this feature when you want to:

- Restrict which CRD groups or kinds an assignee can list or get.
- Centrally enforce custom resource access boundaries from Microsoft Entra ID without managing Kubernetes RBAC `Role` and `RoleBinding` objects on every cluster.
- Distinguish between CRDs published by different operators (for example, allow `secrets-store.csi.x-k8s.io` while blocking `security.istio.io`).

### Available condition attributes

The following request attributes are available when authoring conditions for the Kubernetes API on an AKS cluster:

| Attribute | Description |
| --- | --- |
| `Microsoft.ContainerService/managedClusters/customResources:group` | The API group of the custom resource being accessed (for example, `secrets-store.csi.x-k8s.io`). |
| `Microsoft.ContainerService/managedClusters/customResources:kind` | The kind of the custom resource being accessed (for example, `secretproviderclasses`). |

### Add an ABAC condition to a role assignment

The following example creates an AKS CRD Reader custom role that grants read access to custom resources. Then it assigns the role with a condition that only allows access to `secretproviderclasses` in the `secrets-store.csi.x-k8s.io` group (the CRD used by the Azure Key Vault provider for the Secrets Store CSI Driver).

1. Save the following role definition to a file named `crd-reader.json`, replacing `<YOUR-SUBSCRIPTION-ID>` with your own subscription ID.

    ```json
    {
        "Name": "AKS CRD Reader",
        "Description": "Lets you read custom resources in the cluster.",
        "Actions": [],
        "NotActions": [],
        "DataActions": [
            "Microsoft.ContainerService/managedClusters/customresources/read"
        ],
        "NotDataActions": [],
        "assignableScopes": [
            "/subscriptions/<YOUR-SUBSCRIPTION-ID>"
        ]
    }
    ```
2. Create the role definition using the [`az role definition create`](/en-us/cli/azure/role/definition#az-role-definition-create) command.

    ```azurecli
    az role definition create --role-definition @crd-reader.json
    ```
3. Save the following condition to a file named `abac-condition.txt`. The condition allows non-custom-resource reads to pass through unchanged, and restricts custom resource reads to a specific group and kind.

    ```text
    (
     (
      !(ActionMatches{'Microsoft.ContainerService/managedClusters/customresources/read'})
     )
     OR
     (
      @Request[Microsoft.ContainerService/managedClusters/customResources:group] StringEqualsIgnoreCase 'secrets-store.csi.x-k8s.io'
      AND
      @Request[Microsoft.ContainerService/managedClusters/customResources:kind] StringEqualsIgnoreCase 'secretproviderclasses'
     )
    )
    ```
4. Create the role assignment with the condition using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    # Set environment variables
    export RESOURCE_GROUP=<resource-group-name>
    export CLUSTER_NAME=<cluster-name>
    
    # Get the AKS resource ID
    AKS_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query id --output tsv)
    
    # Create a role assignment for the AKS CRD Reader role with an ABAC condition
    az role assignment create \
        --role "AKS CRD Reader" \
        --assignee <AAD-ENTITY-ID> \
        --scope $AKS_ID \
        --condition "$(cat abac-condition.txt)" \
        --condition-version "2.0" \
        --description "Allow reads on SecretProviderClass resources only"
    ```

You can also add a condition through the Azure portal. On the **Add role assignment** page, select the **Conditions** tab, then select **Add condition** and use the visual editor to build the expression.

### Verify the condition

After the role assignment propagates (up to five minutes), sign in as the assignee and confirm they can read the allowed CRD but not other CRDs.

1. Get the cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    # Set environment variables
    export RESOURCE_GROUP=<resource-group-name>
    export CLUSTER_NAME=<cluster-name>
    
    # Get the cluster credentials
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```
2. List `secretproviderclasses` from the `secrets-store.csi.x-k8s.io` group, which the condition allows. The command should succeed and return either the existing resources or an empty list (or a not-found error if the CRD isn't installed on the cluster).

    ```bash
    kubectl get secretproviderclasses.secrets-store.csi.x-k8s.io --all-namespaces
    ```
3. List `authorizationpolicies` from the Istio `security.istio.io` group, which the condition blocks. The command should fail with a `Forbidden` error from the Microsoft Entra ID authorization webhook (assuming the Istio CRD is installed on the cluster; otherwise `kubectl` returns a not-found error before the API server reaches the authorization webhook).

    ```bash
    kubectl get authorizationpolicies.security.istio.io --all-namespaces
    ```

## Clean up resources

### Disable Microsoft Entra ID authorization

Remove Microsoft Entra ID authorization using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-azure-rbac` flag.

```azurecli
# Set environment variables
export RESOURCE_GROUP=<resource-group-name>
export CLUSTER_NAME=<cluster-name>

# Disable Microsoft Entra ID authorization for the Kubernetes API
az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --disable-azure-rbac
```

### Delete role assignment

# [Azure CLI](#tab/azure-cli)
1. List role assignments using the [`az role assignment list`](/en-us/cli/azure/role/assignment#az-role-assignment-list) command.

    ```azurecli
    # Set environment variables
    export RESOURCE_GROUP=<resource-group-name>
    export CLUSTER_NAME=<cluster-name>
    
    # Get the AKS resource ID
    AKS_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query id --output tsv)
    
    # List role assignments for the AKS cluster
    az role assignment list --scope $AKS_ID --query [].id --output tsv
    ```
2. Delete the role assignments using the [`az role assignment delete`](/en-us/cli/azure/role/assignment#az-role-assignment-delete) command.

    ```azurecli
    az role assignment delete --ids <LIST OF ASSIGNMENT IDS>
    ```

# [Azure portal](#tab/azure-portal)
1. Navigate to your AKS cluster and select **Access control (IAM)** &gt; **Role assignments**.
2. Select the role assignment to delete, and then select **Delete** &gt; **Yes**.

---

### Delete role definition

Delete a custom role definition using the [`az role definition delete`](/en-us/cli/azure/role/definition#az-role-definition-delete) command.

```azurecli
az role definition delete --name "AKS Deployment Reader"
```

### Delete resource group and AKS cluster

# [Azure CLI](#tab/azure-cli)
Delete the resource group (and the AKS cluster it contains) using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command.

```azurecli
# Set environment variables
export RESOURCE_GROUP=<resource-group-name>

# Delete the resource group and all resources in it
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

# [Azure portal](#tab/azure-portal)
1. Navigate to the resource group that contains your AKS cluster and select **Delete resource group**.
2. On **Delete a resource group**, enter the resource group name, and then select **Delete** &gt; **Delete**.

---