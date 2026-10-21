---
layout: Conceptual
title: Use a System-Assigned Managed Identity in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/system-assigned-managed-identity
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
description: This article explains how to enable a system-assigned managed identity on a new or existing AKS cluster, get the principal ID of the system-assigned managed identity, and add a role assignment for the system-assigned managed identity.
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.subservice: aks-security
ms.custom:
- devx-track-azurecli
- ignite-2023
ms.date: 2024-06-07T00:00:00.0000000Z
zone_pivot_groups: azure-cli-or-terraform
locale: en-us
document_id: 6587d5ce-5e07-4dc9-b86e-499ad10ebed1
document_version_independent_id: 29a4f6d1-ae55-8fa2-a7f9-e9b84c4db384
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/system-assigned-managed-identity.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/system-assigned-managed-identity
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/system-assigned-managed-identity.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 1720ac42-4a31-6542-bbcf-c792aa850ed4
---

# Use a System-Assigned Managed Identity in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article explains how to enable a system-assigned managed identity on a new or existing AKS cluster, get the principal ID of the system-assigned managed identity, and add a role assignment for the system-assigned managed identity.

## Prerequisites

- Read the [Overview of managed identities in Azure Kubernetes Service (AKS)](managed-identity-overview) to understand the different types of managed identities available in AKS and how you can use them to securely access Azure resources.
- Set your subscription as the current active subscription using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

    ```azurecli
    az account set --subscription <subscription-id>
    ```

::: zone pivot="azure-cli"

- An existing Azure resource group. If you don't have one, you can create one using the [`az group create`](/en-us/cli/azure/group#az_group_create) command.

    ```azurecli
    az group create \
        --name <resource-group-name> \
        --location <location>
    ```

::: zone-end

- Azure CLI version 2.23.0 or later installed. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- To update an existing cluster to use a [system-assigned managed identity](use-managed-identity#update-an-existing-aks-cluster-to-use-a-system-assigned-managed-identity), you need Azure CLI version 2.49.0 or later installed.

::: zone pivot="terraform"

- Terraform installed locally. For installation instructions, see [Install Terraform](https://developer.hashicorp.com/terraform/install).

::: zone-end

## Limitations

- Once you create a cluster with a managed identity, you can't switch back to using a service principal.
- Moving or migrating a managed identity-enabled cluster to a different tenant isn't supported.
- If the cluster has Microsoft Entra pod-managed identity (`aad-pod-identity`) enabled, Node-Managed Identity (NMI) pods modify the iptables of the nodes to intercept calls to the Azure Instance Metadata (IMDS) endpoint. This configuration means any request made to the IMDS endpoint is intercepted by NMI, even if a particular pod doesn't use `aad-pod-identity`.
    - You can configure the AzurePodIdentityException custom resource definition (CRD) to specify that requests to the IMDS endpoint that originate from a pod matching labels defined in the CRD should be proxied without any processing in NMI. Exclude the system pods with the `kubernetes.azure.com/managedby: aks` label in *kube-system* namespace in `aad-pod-identity` by configuring the AzurePodIdentityException CRD. For more information, see [Use Microsoft Entra pod-managed identities in Azure Kubernetes Service (AKS)](use-azure-ad-pod-identity).
    - To configure an exception, install the [mic-exception YAML](https://github.com/Azure/aad-pod-identity/blob/master/deploy/infra/mic-exception.yaml).
- AKS doesn't support the use of a system-assigned managed identity when using a custom private DNS zone.

## Update cluster considerations

When you update a cluster, consider the following information:

- An update only works if there's a VHD update to consume. If you're running the latest VHD, you need to wait until the next VHD is available in order to perform the update.
- The Azure CLI ensures your add-on's permission is correctly set after migrating. If you're not using the Azure CLI to perform the migrating operation, you need to handle the add-on identity's permission by yourself. For an example using an Azure Resource Manager (ARM) template, see [Assign Azure roles using ARM templates](/en-us/azure/role-based-access-control/role-assignments-template).
- If your cluster was using `--attach-acr` to pull from images from Azure Container Registry (ACR), you need to run the `az aks update --resource-group <resource-group-name> --name <aks-cluster-name> --attach-acr <acr-resource-id>` command after updating your cluster to let the newly created kubelet used for managed identity get the permission to pull from ACR. Otherwise, you won't be able to pull from ACR after the update.

::: zone pivot="azure-cli"

## Enable a system-assigned managed identity on a new AKS cluster

A system-assigned managed identity is enabled by default when you create a new AKS cluster.

Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az_aks_create) command.

```azurecli
az aks create \
    --resource-group <resource-group-name> \
    --name <aks-cluster-name> \
    --generate-ssh-keys
```

## Update an existing cluster to use a system-assigned managed identity

Update an existing AKS cluster from a service principal to a system-assigned managed identity using the [`az aks update`](/en-us/cli/azure/aks#az_aks_update) command with the `--enable-managed-identity` parameter.

```azurecli
az aks update \
    --resource-group <resource-group-name> \
    --name <aks-cluster-name> \
    --enable-managed-identity
```

When you update the cluster to use a system-assigned managed identity instead of a service principal, the control plane and pods use the system-assigned managed identity for authorization when accessing other services in Azure. All nodes in your cluster are reimaged so the Kubelet can immediately start using a managed identity as well. This reimage operation causes downtime for your AKS cluster as the nodes in the node pools are cordoned, drained, and reimaged. Configure [Node Disruption Policy (preview)](use-node-disruption-policy) to control when operations that require node reimage are allowed in your Azure Kubernetes Service (AKS) cluster.

## Get the principal ID of a system-assigned managed identity

Get the principal ID for the cluster's system-assigned managed identity using the [`az aks show`](/en-us/cli/azure/identity#az-identity-show) command.

```azurecli
CLIENT_ID=$(az aks show \
    --name <aks-cluster-name> \
    --resource-group <resource-group-name> \
    --query identity.principalId \
    --output tsv)
```

## Add a role assignment for a system-assigned managed identity

Note

For a virtual network (VNet), attached Azure disk, static IP address, or route table outside the default worker node resource group, you need to assign the `Network Contributor` role on the custom resource group.

Assign an Azure RBAC role to the system-assigned managed identity using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az_role_assignment_create) command. The following example assigns the **Network Contributor** role to the system-assigned managed identity. The role assignment is scoped to the resource group that contains the VNet.

```azurecli
az role assignment create \
    --assignee <client-id> \
    --role "Network Contributor" \
    --scope <custom-resource-group-id>
```

Note

It can take up to 60 minutes for the permissions granted to your cluster's managed identity to propagate.

::: zone-end

::: zone pivot="terraform"

## Create the Terraform configuration file

Terraform configuration files define the infrastructure that Terraform creates and manages.

1. Create a file named `main.tf` and add the following code to define the Terraform version and specify the Azure provider:

    ```Terraform
    terraform {
    required_version = ">= 1.0"
    required_providers {
      azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 4.0"
      }
     }
    }
    provider "azurerm" {
     features {}
    }
    ```
2. Add the following code to `main.tf` to create an Azure resource group. Feel free to change the name and location of the resource group as needed.

    ```Terraform
    resource "azurerm_resource_group" "example" {
     name     = "aks-rg"
     location = "East US"
    }
    ```

## Create an AKS cluster with a system-assigned managed identity using Terraform

Add the following code to `main.tf` to create an AKS cluster with a system-assigned managed identity:

```Terraform
resource "azurerm_kubernetes_cluster" "system_assigned" {
 name                = "aks-system"
 location            = azurerm_resource_group.example.location
 resource_group_name = azurerm_resource_group.example.name
 dns_prefix          = "akssystem"
 identity {
   type = "SystemAssigned"
 }
 default_node_pool {
   name       = "system"
   node_count = 1
   vm_size    = "Standard_DS2_v2"
 }
}
```

## Add a role assignment for a system-assigned managed identity using Terraform

Add the following code to `main.tf` to create a role assignment for the system-assigned managed identity. This example assigns the **Network Contributor** role to the system-assigned managed identity. The role assignment is scoped to the resource group that contains the VNet.

```Terraform
resource "azurerm_role_assignment" "system_assigned_network_contributor" {
 scope                = azurerm_resource_group.example.id
 role_definition_name = "Network Contributor"
 principal_id         = azurerm_kubernetes_cluster.system_assigned.identity[0].principal_id
}
```

## Initialize Terraform

Initialize Terraform in the directory containing your `main.tf` file using the [`terraform init`](https://www.terraform.io/docs/commands/init.html) command. This command downloads the Azure provider required to manage Azure resources with Terraform.

```console
terraform init
```

## Create a Terraform execution plan

Create a Terraform execution plan using the [`terraform plan`](https://www.terraform.io/docs/commands/plan.html) command. This command shows you the resources that Terraform will create or modify in your Azure subscription.

```console
terraform plan
```

## Apply the Terraform configuration

After reviewing and confirming the execution plan, apply the Terraform configuration using the [`terraform apply`](https://www.terraform.io/docs/commands/apply.html) command. This command creates or modifies the resources defined in your `main.tf` file in your Azure subscription.

```console
terraform apply
```

## Verify the Terraform deployment

After applying the Terraform configuration, you can verify the deployment using the [`az aks show`](/en-us/cli/azure/aks#az_aks_show) command with the `--query` parameter to filter the output and display the identity information. For example:

```azurecli
az aks show \
 --name <cluster-name> \
 --resource-group <resource-group> \
 --query identity.type \
 --output tsv
```

::: zone-end