---
layout: Conceptual
title: How to Use Managed Namespaces in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/managed-namespaces
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
description: Step-by-step guide on using managed namespaces in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.date: 2025-11-18T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
zone_pivot_groups: bicep-azure-cli-portal
locale: en-us
document_id: 0aa0ed31-870b-549f-94f9-d119e949a6d3
document_version_independent_id: 3f1d8d06-0257-6469-02ae-3c2300e13b27
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/managed-namespaces.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/managed-namespaces
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/managed-namespaces.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: fbc18cdc-197f-762d-27aa-4b30d757f2a2
---

# How to Use Managed Namespaces in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

**Applies to:** ✔️ AKS Automatic ✔️ AKS Standard

Managed namespaces in Azure Kubernetes Service (AKS) provide a way to logically isolate workloads and teams within a cluster. This feature enables administrators to enforce resource quotas, apply network policies, and manage access control at the namespace level. For a detailed overview of managed namespaces, see the [managed namespaces overview](concepts-managed-namespaces).

## Before you begin

### Prerequisites

- An Azure account with an active subscription. If you don't have one, you can [create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- An [AKS cluster](automatic/quick-automatic-managed-network) set up in your Azure environment with [Azure role-based access control for Kubernetes authorization](entra-id-authorization) is required if you intend to utilize Azure RBAC roles.
- To use the network policy feature, the AKS cluster needs to be [configured with a network policy engine](use-network-policies#network-policy-options-in-aks). Cilium is our recommended engine.

| Prerequisite | Notes |
| --- | --- |
| **Azure CLI** | `2.80.0` or later installed. To find the CLI version, run `az --version`. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli). |
| **AKS API Version** | `2025-09-01` or later. |
| **Required permission(s)** | `Microsoft.ContainerService/managedClusters/managedNamespaces/*` or `Azure Kubernetes Service Namespace Contributor` built-in role. `Microsoft.Resources/deployments/*` on the resource group containing the cluster. For more information, see [Managed namespaces built-in roles](concepts-managed-namespaces#managed-namespaces-built-in-roles). |

### Limitations

- Trying to on-board system namespaces such as `kube-system`, `app-routing-system`, `istio-system`, `gatekeeper-system`, etc. to be managed namespaces isn't allowed.
- When a namespace is a managed namespace, changes to the namespace via the Kubernetes API are blocked.

::: zone pivot="azure-portal"

- Listing existing namespaces to convert in the portal doesn't work with private clusters. You can add new namespaces.

::: zone-end

## Create a managed namespace on a cluster and assign users

Note

When you create a managed namespace, a component is installed on the cluster to reconcile the namespace with the state in Azure Resource Manager. This component blocks changes to the managed fields and resources from the Kubernetes API, ensuring consistency with the desired configuration.

::: zone pivot="bicep"

The following Bicep example demonstrates how to create a managed namespace as a subresource of a managed cluster. Make sure to select the appropriate value for `defaultNetworkPolicy`, `adoptionPolicy`, and `deletePolicy`. For more information about what those parameters mean, see the [managed namespaces overview](concepts-managed-namespaces).

```bicep
resource existingCluster 'Microsoft.ContainerService/managedClusters@2024-03-01' existing = {
  name: 'contoso-cluster'
}

resource managedNamespace 'Microsoft.ContainerService/managedClusters/managedNamespaces@2025-09-01' = {
  parent: existingCluster
  name: 'retail-team'
  location: location
  properties: {
    defaultResourceQuota: {
      cpuRequest: '1000m'
      cpuLimit: '2000m'
      memoryRequest: '512Mi'
      memoryLimit: '1Gi'
    }
    defaultNetworkPolicy: {
      ingress: 'AllowSameNamespace'
      egress: 'AllowAll'
    }
    adoptionPolicy: 'IfIdentical'
    deletePolicy: 'Keep'
    labels: {
      environment: 'dev'
    }
    annotations: {
      owner: 'retail'
    }
  }
}
```

Save the Bicep file **managedNamespace.bicep** to your local computer.

Deploy the Bicep file using the Azure CLI.

```azurecli
az deployment group create --resource-group <resource-group> --template-file managedNamespace.bicep
```

::: zone-end

::: zone pivot="azure-cli"

### Define variables

Define the following variables to be used in the subsequent steps.

```azurecli
RG_NAME=cluster-rg
CLUSTER_NAME=contoso-cluster
NAMESPACE_NAME=retail-team
LABELS="environment=dev"
ANNOTATIONS="owner=retail"
```

### Create the managed namespace

To customize its configuration, managed namespaces have various parameter options to choose from during creation. Make sure to select the appropriate value for `ingress-network-policy`, `egress-network-policy`, `adoption-policy`, and `delete-policy`. For more information about what those parameters mean, see the [managed namespaces overview](concepts-managed-namespaces).

```azurecli
az aks namespace add \
    --name ${NAMESPACE_NAME} \
    --cluster-name ${CLUSTER_NAME} \
    --resource-group ${RG_NAME} \
    --cpu-request 1000m \
    --cpu-limit 2000m \
    --memory-request 512Mi \
    --memory-limit 1Gi \
    --ingress-policy [AllowSameNamespace|AllowAll|DenyAll] \
    --egress-policy [AllowSameNamespace|AllowAll|DenyAll] \
    --adoption-policy [Never|IfIdentical|Always] \
    --delete-policy [Keep|Delete] \
    --labels ${LABELS} \
    --annotations ${ANNOTATIONS}
```

### Assign role

After the namespace is created, you can assign [one of the built-in roles](concepts-managed-namespaces#managed-namespaces-built-in-roles) for the control plane and data plane.

```azurecli
ASSIGNEE="user@contoso.com"
NAMESPACE_ID=$(az aks namespace show --name ${NAMESPACE_NAME} --cluster-name ${CLUSTER_NAME} --resource-group ${RG_NAME} --query id -o tsv)
```

Assign a control plane role to be able to view the managed namespace in the portal, Azure CLI output, and Azure Resource Manager. This role also allows the user to retrieve the credentials to connect to this namespace.

```azurecli
az role assignment create \
  --assignee ${ASSIGNEE} \
  --role "Azure Kubernetes Service Namespace User" \
  --scope ${NAMESPACE_ID}
```

Assign data plane role to be able to get access to create resources within the namespace using the Kubernetes API.

```azurecli
az role assignment create \
  --assignee ${ASSIGNEE} \
  --role "Azure Kubernetes Service RBAC Writer" \
  --scope ${NAMESPACE_ID}
```

::: zone-end

::: zone pivot="azure-portal"

1. Sign in to the [Azure portal](https://portal.azure.com).
2. On the Azure portal home page, select **Create a resource**.
3. In the **Categories** section, select **Managed Kubernetes Namespaces**.
4. On the **Basics** tab, under **Project details**configure the following settings:
    1. Select the target **cluster** to create the namespace on.
    2. If you're creating a new namespace, leave the default **create new**, otherwise choose **change existing to managed** to convert an existing namespace.
5. Configure the **networking policy** to be applied on the namespace.
6. Configure the **resource requests and limits** for the namespace.
7. Select the **members (users or groups)** and their **role**.
    1. Assign the **Azure Kubernetes Service Namespace User** role to give them access to view the managed namespace in the portal, Azure CLI output, and Azure Resource Manager. This role also allows the user to retrieve the credentials to connect to this namespace.
    2. Assign the **Azure Kubernetes Service RBAC Writer** role to give them access to create resources within the namespace using the Kubernetes API.
8. Select **Review + create** to run validation on the configuration. After validation completes, select **Create**.

::: zone-end

::: zone pivot="azure-cli"

## List managed namespaces

You can list managed namespaces at different scopes using the Azure CLI.

### Subscription level

Run the following command to list all managed namespaces in a subscription.

```azurecli
az aks namespace list --subscription <subscription-id>
```

### Resource group level

Run the following command to list all managed namespaces in a specific resource group.

```azurecli
az aks namespace list --resource-group <rg-name>
```

### Cluster level

Run the following command to list all managed namespaces in a specific cluster.

```azurecli
az aks namespace list --resource-group <rg-name> --cluster-name <cluster-name>
```

::: zone-end

::: zone pivot="bicep"

## List managed namespaces

You can list managed namespaces at different scopes using the Azure CLI.

### Subscription level

Run the following command to list all managed namespaces in a subscription.

```azurecli
az aks namespace list --subscription <subscription-id>
```

### Resource group level

Run the following command to list all managed namespaces in a specific resource group.

```azurecli
az aks namespace list --resource-group <rg-name>
```

### Cluster level

Run the following command to list all managed namespaces in a specific cluster.

```azurecli
az aks namespace list --resource-group <rg-name> --cluster-name <cluster-name>
```

::: zone-end

::: zone pivot="azure-portal"
::: zone-end

::: zone pivot="azure-cli"

## Connect to the cluster

You can retrieve the credentials to connect to a namespace via the following command.

```azurecli
az aks namespace get-credentials --name <namespace-name> --resource-group <rg-name> --cluster-name <cluster-name>
```

::: zone-end

::: zone pivot="bicep"

## Connect to the cluster

You can retrieve the credentials to connect to a namespace via the following command.

```azurecli
az aks namespace get-credentials --name <namespace-name> --resource-group <rg-name> --cluster-name <cluster-name>
```

::: zone-end

::: zone pivot="azure-portal"
::: zone-end