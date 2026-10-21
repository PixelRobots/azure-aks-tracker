---
layout: Conceptual
title: Set up Permissions and Role-Based Access Control (RBAC) in AKS Desktop - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-desktop-permissions
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
description: Learn how to configure RBAC permissions for AKS desktop based on your role as a cluster operator or developer.
ms.subservice: aks-developer
ms.reviewer: schaffererin
author: danielsollondon
ms.topic: how-to
ms.date: 2026-04-16T00:00:00.0000000Z
ms.author: danis
zone_pivot_groups: aks-desktop
locale: en-us
document_id: f005bd66-5178-ae8e-f5b1-c49c46ae4707
document_version_independent_id: 57cba78e-404f-f9aa-c5d8-da0d950a0b7a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-desktop-permissions.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/aks-desktop-permissions
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-desktop-permissions.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d73221f5-e38a-8a36-b3e6-22fc2603b985
---

# Set up Permissions and Role-Based Access Control (RBAC) in AKS Desktop - Azure Kubernetes Service | Microsoft Learn

![Screenshot of a diagram showing AKS desktop RBAC role assignments for cluster operator and developer roles](media/aks-desktop-app/aks-desktop-role-based-security.png)

Depending on your role as a cluster operator or developer, you can provide an environment (Project) in AKS desktop for developers to deploy, migrate, or manage applications, or allow them to self-serve deploying and managing applications on a dedicated AKS cluster. Alternatively, you might want to grant more developers access to manage, observe, and troubleshoot applications.

By default, when you create a Project in AKS desktop you can share this with other people in your organization, and it sets the permissions for you. However, you might need to maintain permissions over time or automate them or define an operating model by setting the appropriate permissions.

This article describes how to manage RBAC permissions to enable team members to work with AKS desktop.

Note

AKS desktop doesn't currently provide a UI option to modify Project permissions after creation. To update permissions or grant access to additional users after a Project is created, use the Azure portal or Azure CLI as described in this article.

Note

When you create Projects in AKS desktop, [AKS managed namespaces](concepts-managed-namespaces) are created in the same resource group as your cluster.

## Prerequisites

- An Azure subscription. If you don't have one, create a [free Azure account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Azure CLI version 2.64.0 or later. Check your version using the [`az --version`](/en-us/cli/azure/reference-index#az-version) command. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The `aks-preview` Azure CLI extension. Install it using the `az extension add --name aks-preview` command. For more information, see [Manage Azure CLI extensions](/en-us/cli/azure/azure-cli-extensions-overview).
- A basic understanding of Azure role-based access control (RBAC), see [What is Azure RBAC?](/en-us/azure/role-based-access-control/overview) and [Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles).
- An Azure resource group that contains your AKS cluster and any AKS managed Projects created through AKS desktop.
- An [AKS Standard cluster](aks-desktop-install-cluster-setup) that meets AKS desktop requirements or an [AKS Automatic cluster](intro-aks-automatic), which is the Kubernetes cluster where your applications run.
- An [Azure Container Registry (ACR)](/en-us/azure/container-registry/container-registry-intro) to store your container images for deployment.

::: zone pivot="cluster-operator"

## Cluster operator responsibilities

As a cluster operator, you're responsible for provisioning and configuring the foundational infrastructure that enables development teams to build and deploy applications. Your responsibilities include:

- Creating the required Azure infrastructure (resource group, AKS cluster, ACR).
- Configuring ACR integration with your AKS cluster.
- Assigning permissions for users to create Projects.
- Optionally delegating permission management to Project creators.

## Create infrastructure resources

To create the infrastructure resources, you need permissions to create resources in Azure. If you aren't assigned the **Owner** RBAC role, you need the **Contributor** role to create resources and the **User Access Administrator** role to assign permissions to other users. Assign permissions to users so they can create resources in the resource group using the following steps:

1. Set environment variables for your resource group and cluster name. Make sure to replace the placeholders with your actual resource group and cluster names.

    ```bash
    export RESOURCE_GROUP=<infra-resource-group>
    export CLUSTER_NAME=<cluster-name>
    export SUBSCRIPTION_ID=$(az account show --query id --output tsv)
    export ACR_NAME=<acr-name>
    ```
2. Assign the necessary role to create resources in the resource group using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. Make sure to replace `<user-id>` with the appropriate user or service principal ID.

    ```azurecli
    az role assignment create --role "Contributor" \
        --assignee <user-id> \
        --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP
    ```

## Integrate ACR with your AKS cluster

Attach your Azure container registry with your AKS cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

```azurecli
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --attach-acr $ACR_NAME
```

## Select a Project creation model

As a cluster operator, you have two options for how developers work with Projects in AKS desktop:

- **Self-service model**: Developers create and manage their own Projects. This approach gives developers full autonomy but requires granting them the **Azure Kubernetes Service Namespace Contributor** role. When developers create their own Projects, they automatically receive **Owner** role on the managed namespace and can immediately start deploying applications.
- **Managed model**: You create Projects for developers and grant them access. Currently, you can configure this during Project creation. This approach provides more control over Project creation, but if you need to assign more team members to the Project post creation, you need to assign them the necessary permissions using the Azure portal or Azure CLI as described in the next sections.

### Self-service model: Allow developers to create their own Projects

To allow developers to create their own Projects, assign them the **Azure Kubernetes Service Namespace Contributor** role on the AKS cluster. AKS desktop Projects create [AKS managed namespaces](concepts-managed-namespaces) behind the scenes, and this role grants the necessary permissions.

Assign developers the **Azure Kubernetes Service Namespace Contributor** role using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. Make sure to replace the placeholder with the appropriate user or service principal ID.

```azurecli
az role assignment create \
    --role "Azure Kubernetes Service Namespace Contributor" \
    --assignee <developer-user-id> \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME
```

### Managed model: Create Projects for developers and assign access

If you prefer to create Projects on behalf of developers, you must assign three essential roles to enable them to access the cluster and work within their assigned namespace:

- **Azure Kubernetes Service Cluster User Role**: Allows developers to download the cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.
- **Azure Kubernetes Service Namespace User**: Grants access to the managed namespace.
- One of the Kubernetes RBAC roles (**Reader**, **Writer**, or **Admin**): Controls what actions they can perform in the namespace.

All three roles are required for developers to successfully access and work with their Projects in AKS desktop. Without the **Azure Kubernetes Service Cluster User Role**, developers can't download the kubeconfig file needed to connect to the cluster.

#### Assign cluster access

Assign the **Azure Kubernetes Service Cluster User Role** to enable kubeconfig download using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. Make sure to replace the placeholder with the appropriate user or service principal ID.

```azurecli
az role assignment create \
    --role "Azure Kubernetes Service Cluster User Role" \
    --assignee <developer-user-id> \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME
```

#### Assign namespace access

Assign **Azure Kubernetes Service Namespace User** role for the specific Project/namespace using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. Make sure to replace the placeholder with the appropriate user or service principal ID.

```azurecli
export NAMESPACE_NAME=<namespace-or-project-name>

az role assignment create \
    --role "Azure Kubernetes Service Namespace User" \
    --assignee <developer-user-id> \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME/namespaces/$NAMESPACE_NAME
```

#### Assign Kubernetes RBAC role

Assign the appropriate Kubernetes RBAC role based on what the developer needs to do:

- **Azure Kubernetes Service RBAC Reader** for read-only access.
- **Azure Kubernetes Service RBAC Writer** for deploying applications.
- **Azure Kubernetes Service RBAC Admin** for full administrative control.

1. Get the AKS cluster ID using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    AKS_ID=$(az aks show \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --query id \
        --output tsv)
    ```
2. Assign the appropriate Kubernetes RBAC role using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. Make sure to replace the placeholder with the appropriate user or service principal ID. The following example assigns the **Azure Kubernetes Service RBAC Writer** role:

    ```azurecli
    az role assignment create \
        --role "Azure Kubernetes Service RBAC Writer" \
        --assignee <developer-user-id> \
        --scope $AKS_ID/namespaces/$NAMESPACE_NAME
    ```

## Allow Project creators to assign access permissions (optional)

If you want Project creators to be able to assign access permissions to other users, grant them the [User Access Administrator](/en-us/azure/role-based-access-control/built-in-roles/privileged#user-access-administrator) role. This permission allows the user to set permissions on any resources in the infrastructure resource group.

Assign the **User Access Administrator** role using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. Make sure to replace the placeholder with the appropriate user or service principal ID.

```azurecli
az role assignment create \
    --role "User Access Administrator" \
    --assignee <user-id> \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP
```

::: zone-end

::: zone pivot="developer"

## Developer responsibilities

As a developer, you work within an existing AKS desktop environment to deploy applications, manage Projects, and monitor your workloads. The cluster operator grants you the necessary permissions to perform these tasks. Your responsibilities include:

- Deploying applications into Projects.
- Viewing and managing deployed applications.
- Monitoring application metrics and logs.
- Modifying Project access (if needed).

## Required user roles for developers

To work with AKS desktop as a developer, your cluster operator must assign you three essential roles:

- **Azure Kubernetes Service Cluster User Role**: Allows you to download cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command, which is a requirement to connect to the cluster from your local machine or through AKS desktop.
- **Azure Kubernetes Service Namespace User**: Grants access to your assigned managed namespace/Project.
- One of the Kubernetes RBAC roles (**Reader**, **Writer**, or **Admin**): Controls what actions you can perform in the namespace.

    - **Azure Kubernetes Service RBAC Reader** for read-only access.
    - **Azure Kubernetes Service RBAC Writer** for deploying applications.
    - **Azure Kubernetes Service RBAC Admin** for full administrative control.

### How permissions are assigned

Permissions are assigned based on how Projects are created in AKS desktop:

- **Project creator**: Automatically receives **Owner** role on the managed namespace and all necessary permissions to deploy applications.
- **Other users**: Must be granted access by the cluster operator or Project creator. They receive:

    - **Azure Kubernetes Service Cluster User Role** on the cluster.
    - **Azure Kubernetes Service Namespace User** role on the namespace.
    - One of the Kubernetes RBAC roles (**Reader**, **Writer**, or **Admin**).

To deploy applications, you need the **Writer** or **Admin** role. For more information, see [Managed namespaces built-in roles](concepts-managed-namespaces#managed-namespaces-built-in-roles).

## View application metrics

Note

It might take up to 10 minutes for the metrics to populate once an application is deployed.

In the Project home screen, you can view metrics for your application, such as CPU, memory, and network usage. These metrics are sourced from the Managed Prometheus endpoint backed by an Azure Monitor workspace.

To view metrics, you need the **Monitoring Data Reader** role on the Azure Monitor workspace. This role grants access to all metrics for the cluster, not just your specific Projects.

Your cluster operator can assign this permission using the following steps:

1. Identify the Azure Monitor workspace used by your cluster using the [`az alerts-management prometheus-rule-group list`](/en-us/cli/azure/alerts-management/prometheus-rule-group#az-alerts-management-prometheus-rule-group-list) command.

    ```azurecli
    export WORKSPACE_ACC_FOR_PROM_RULES=$(az alerts-management prometheus-rule-group list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[?clusterName=='$CLUSTER_NAME'] | [0].scopes[0]" \
        --output tsv)
    ```
2. Assign the **Monitoring Data Reader** role using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. Make sure to replace the placeholder with the appropriate user or service principal ID.

    ```azurecli
    az role assignment create \
        --role "Monitoring Data Reader" \
        --assignee <user-id> \
        --scope $WORKSPACE_ACC_FOR_PROM_RULES
    ```

## Modify Project access permissions

Currently, AKS desktop doesn't provide a UI option to modify Project permissions after creation. If you need to update your permissions or grant access to others, work with your cluster operator to update permissions using the Azure portal or Azure CLI. The following steps outline how to assign the necessary roles using Azure CLI:

### Assign cluster access

Assign the **Azure Kubernetes Service Cluster User Role** to enable kubeconfig download using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. Make sure to replace the placeholder with the appropriate user or service principal ID.

```azurecli
az role assignment create \
    --role "Azure Kubernetes Service Cluster User Role" \
    --assignee <developer-user-id> \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME
```

### Assign namespace access

Assign **Azure Kubernetes Service Namespace User** role for the specific Project/namespace using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. Make sure to replace the placeholder with the appropriate user or service principal ID.

```azurecli
export NAMESPACE_NAME=<namespace-or-project-name>

az role assignment create \
    --role "Azure Kubernetes Service Namespace User" \
    --assignee <developer-user-id> \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerService/managedClusters/$CLUSTER_NAME/namespaces/$NAMESPACE_NAME
```

### Assign Kubernetes RBAC role

Assign the appropriate Kubernetes RBAC role based on what the developer needs to do:

- **Azure Kubernetes Service RBAC Reader** for read-only access.
- **Azure Kubernetes Service RBAC Writer** for deploying applications.
- **Azure Kubernetes Service RBAC Admin** for full administrative control.

1. Get the AKS cluster ID using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    AKS_ID=$(az aks show \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --query id \
        --output tsv)
    ```
2. Assign the appropriate Kubernetes RBAC role using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command. Make sure to replace the placeholder with the appropriate user or service principal ID. The following example assigns the **Azure Kubernetes Service RBAC Writer** role:

    ```azurecli
    az role assignment create \
        --role "Azure Kubernetes Service RBAC Writer" \
        --assignee <developer-user-id> \
        --scope $AKS_ID/namespaces/$NAMESPACE_NAME
    ```

### Grant permissions for viewing metrics (optional)

To grant permissions to view metrics, follow the steps in the View application metrics section.

::: zone-end