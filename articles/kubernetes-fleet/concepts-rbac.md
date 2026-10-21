---
layout: Conceptual
title: Grant access to Azure Kubernetes Fleet Manager resources with Azure role-based access control | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-rbac
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
description: This article provides an overview of the Azure role-based access control roles that can be used to access Azure Kubernetes Fleet Manager resources.
ms.date: 2026-05-25T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: bcd2609e-5b12-09cb-40f0-ba40c936df78
document_version_independent_id: 32ac1ed7-41ef-4c3e-268a-00feb81ccfdb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-rbac.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-rbac
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-rbac.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 4e205423-54c1-985f-3cb2-3b8f94410583
---

# Grant access to Azure Kubernetes Fleet Manager resources with Azure role-based access control | Microsoft Learn

**Applies to**: ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

This article provides an overview of the Azure RBAC roles that you can use with Azure Kubernetes Fleet Manager.

[Azure role-based access control (Azure RBAC)](/en-us/azure/role-based-access-control/overview) is an authorization system built on Azure Resource Manager that provides fine-grained access management to Azure resources.

## Azure Resource Manager

These roles grant access to Azure Resource Manager (ARM) Fleet resources and subresources, and are applicable to Fleet Managers with and without a hub cluster.

Note

When using the Azure portal to perform actions such as adding member clusters, ensure the user has Contributor permissions to the resource group in which the Fleet Manager is deployed.

| Role name | Description | Usage |
| --- | --- | --- |
| [Azure Kubernetes Fleet Manager Contributor](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-fleet-manager-contributor-role) | Grants read and write access to Azure resources provided by Azure Kubernetes Fleet Manager, including fleets, fleet members, fleet update strategies, fleet update runs, and more. | Use this role to grant Contributor permissions that apply solely to Fleet Manager ARM resources and subresources. For example, this role can be given to an Azure administrator tasked with defining and maintaining Fleet Manager resources. |
| [Azure Kubernetes Fleet Manager Hub Cluster User Role](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-fleet-manager-hub-cluster-user-role) | Grants read-only access to the Fleet Manager hub cluster and the `kubeconfig` file to connect to the Fleet Manager hub cluster. | Use to view Fleet Manager resources and download a Fleet Manager hub cluster’s `kubeconfig` to inspect configurations and workloads without making any changes. |

## Kubernetes data plane

You can assign Fleet Manager data plane roles at the Fleet scope or at an individual Managed Fleet Namespace scope.

There are two types of data plane roles: RBAC roles for Fleet Manager and RBAC roles for Member Clusters. RBAC roles for Fleet Manager only grant access to Kubernetes objects within the Fleet-managed hub cluster. RBAC roles for Member Clusters only grant access to Kubernetes objects on member clusters in a fleet. Applying an RBAC role for Member Clusters at the managed namespace scope applies that role to the managed namespace on all members of the parent Fleet, regardless of whether the managed namespace is propagated to that member.

When a cluster joins a fleet as a member cluster, users gain any permissions on the cluster that have already been granted at the parent Fleet scope. When a member cluster leaves a fleet, the user loses those permissions for that cluster. For example, a user assigned the `Azure Kubernetes Fleet Manager RBAC Cluster Admin for Member Clusters` role at the fleet scope can create namespaces on all member clusters only while those clusters remain in the fleet.

If a role is applied at a managed namespace scope and that managed namespace is deleted, the role assignment is also deleted. If the managed namespace is recreated, the role assignment isn't automatically recreated and must be manually recreated.

Note

These RBAC roles aren't currently supported for Arc-enabled member clusters. Additionally, access control for specific Kubernetes Custom Resources (CRs) isn't supported for these Azure RBAC roles.

### Fleet Manager hub cluster

The following roles are used to interact with Kubernetes resources on a Fleet Manager hub cluster.

| Role name | Description | Usage |
| --- | --- | --- |
| [Azure Kubernetes Fleet Manager RBAC Cluster Admin](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-fleet-manager-rbac-cluster-admin) | Grants read/write access to all Kubernetes resources in the fleet-managed hub cluster. | Use this role to grant access to all Kubernetes objects (including CRDs) at either namespace or cluster scope. |
| [Azure Kubernetes Fleet Manager RBAC Admin](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-fleet-manager-rbac-admin) | Grants read and write access to Kubernetes resources within a namespace in the fleet-managed hub cluster. Provides write permissions on most objects within a namespace, except for `ResourceQuota` object and the namespace object itself. Applying this role at cluster scope gives access across all namespaces. | Use this role to grant the capability to administer selected Kubernetes objects (including roles and role bindings) at either namespace or cluster scope. For example, for use by a project team responsible for objects in a given namespace. |
| [Azure Kubernetes Fleet Manager RBAC Writer](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-fleet-manager-rbac-writer) | Grants read and write access to most Kubernetes resources within a namespace in the fleet-managed hub cluster. This role doesn't allow viewing or modifying roles or role bindings. However, this role allows accessing Secrets as any `ServiceAccount` in the namespace, so it can be used to gain the API access levels of any `ServiceAccount` in the namespace. Applying this role at cluster scope gives access across all namespaces. | Use this role to grant the capability to write selected Kubernetes objects at either namespace or cluster scope. For example, for use by a project team responsible for objects in a given namespace. |
| [Azure Kubernetes Fleet Manager RBAC Reader](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-fleet-manager-rbac-reader) | Grants read-only access to most Kubernetes resources within a namespace in the fleet-managed hub cluster. It doesn't allow viewing roles or role bindings. This role doesn't allow viewing Secrets, since reading the contents of Secrets enables access to `ServiceAccount` credentials in the namespace, which would allow API access as any `ServiceAccount` in the namespace (a form of privilege escalation). Applying this role at cluster scope gives access across all namespaces. | Use this role to grant the capability to read selected nonsensitive Kubernetes objects at either namespace or cluster scope. For example, you can grant this role for review purposes. |

### Fleet Manager member clusters

The following roles are used to interact with Kubernetes resources on Fleet Manager member clusters when using [Managed Fleet Namespaces](concepts-fleet-managed-namespace).

| Role name | Description | Usage |
| --- | --- | --- |
| [Azure Kubernetes Fleet Manager RBAC Cluster Admin for Member Clusters](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-fleet-manager-rbac-cluster-admin-for-member-clusters) | Full read/write access to all Kubernetes resources on the member clusters in a fleet. | Use this role to grant full access to all resources on member clusters. For example, a platform administrator who needs to access multiple namespaces on member clusters. |
| [Azure Kubernetes Fleet Manager RBAC Admin for Member Clusters](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-fleet-manager-rbac-admin-for-member-clusters) | Read and write access to Kubernetes resources in the namespace on the member cluster. | Use this role to grant the capability to administer selected Kubernetes objects (including roles and role bindings) at namespace scope on fleet members. For example, for use by a project team responsible for objects in a given namespace. |
| [Azure Kubernetes Fleet Manager RBAC Writer for Member Clusters](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-fleet-manager-rbac-writer-for-member-clusters) | Read and write access to most Kubernetes resources in the namespace. Can't view or modify roles or role bindings. Can read Secrets (therefore can assume any `ServiceAccount` in the namespace). | Use this role to grant the capability to write selected Kubernetes objects in a namespace on a fleet member. For example, for use by a project team responsible for objects in a given namespace. |
| [Azure Kubernetes Fleet Manager RBAC Reader for Member Cluster](/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-fleet-manager-rbac-reader-for-member-clusters) | Read-only access to most objects in the namespace on the member cluster. Can't view roles or role bindings. Can't view Secrets (prevents privilege escalation via `ServiceAccount` credentials). | Use this role to grant the capability to read selected nonsensitive Kubernetes objects at the namespace scope on fleet members. |

## Private hub cluster

When using Fleet Manager with a private hub cluster you must add the following Azure RBAC configuration so that Fleet Manager can control the configuration of, and apply updates to the managed hub cluster.

Private hub clusters require a [Network Contributor](/en-us/azure/role-based-access-control/built-in-roles/networking#network-contributor) role assignment on the virtual network subnet that is configured as the agent (node) subnet. The role assignment uses Fleet Manager's Azure service principal whose object ID varies across different Entra tenants.

Note

This role assignment isn't needed when creating a Fleet Manager with a private hub cluster using the `az fleet create` Azure CLI command because the Azure CLI automatically creates the role assignment.

1. Obtain the Azure resource identifier of the Azure Virtual Network subnet that your Fleet Manager hub cluster is attached to. Use appropriate values for the placeholders.

    ```azurecli
    SUBNET_ID=$(az network vnet subnet show --subscription <subscription-id> --resource-group <virtual-network-rg> --vnet-name <virtual-network> -n <subnet-name> -o tsv --query id)
    ```
2. Retrieve Fleet Manager's Azure service principal object ID for your environment.

    ```azurecli
    FLEET_RP_ID=$(az ad sp list --display-name "Azure Kubernetes Service - Fleet RP" --query "[].{id:id}" --output tsv)
    ```
3. Assign the Fleet resource provider the Network Contributor role, setting the scope to the resource identifier of the subnet.

    ```azurecli
    az role assignment create --assignee "${FLEET_RP_ID}" --role "Network Contributor" --scope "${SUBNET_ID}"
    ```
4. Confirm the assignment using the following command.

    ```azurecli
    az role assignment list --assignee "${FLEET_RP_ID}" --scope "${SUBNET_ID}"
    ```

## Example role assignments

You can grant Azure RBAC roles using the [Azure CLI](/en-us/cli/azure/what-is-azure-cli). For example, to create a role assignment at the Fleet scope:

```azurecli
IDENTITY=$(az ad signed-in-user show --output tsv --query id)
FLEET_ID=$(az fleet show --resource-group $GROUP --name $FLEET --output tsv --query id)

az role assignment create \
    --role 'Azure Kubernetes Fleet Manager RBAC Reader' \
    --assignee "$IDENTITY" \
    --scope "$FLEET_ID"
```

You can also scope role assignments to an individual managed namespace by appending `/managedNamespaces/<managed-namespace>` to the Fleet ID scope. For example, to create a role assignment at the managed namespace level for namespace `example-ns`:

```azurecli
IDENTITY=$(az ad signed-in-user show --output tsv --query id)
FLEET_ID=$(az fleet show --resource-group $GROUP --name $FLEET --output tsv --query id)
MANAGED_NAMESPACE_NAME="example-ns"

az role assignment create --role 'Azure Kubernetes Fleet Manager RBAC Reader' --assignee "$IDENTITY" --scope "$FLEET_ID"/managedNamespaces/"$MANAGED_NAMESPACE_NAME"
```