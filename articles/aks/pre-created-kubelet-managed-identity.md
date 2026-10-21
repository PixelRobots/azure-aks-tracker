---
layout: Conceptual
title: Use a Pre-Created Kubelet Managed Identity in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/pre-created-kubelet-managed-identity
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
description: This article explains how to enable a pre-created kubelet managed identity on a new or existing AKS cluster, get the properties of the kubelet managed identity, and add a role assignment for the kubelet managed identity.
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
document_id: 6801b57a-3671-0bd9-54d0-532662a7d2fe
document_version_independent_id: d09015d5-29c1-072d-1eb8-75abd7d7b28f
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/pre-created-kubelet-managed-identity.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/pre-created-kubelet-managed-identity
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/pre-created-kubelet-managed-identity.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 0bd70774-9517-c58b-4620-9fd83bbed9b0
---

# Use a Pre-Created Kubelet Managed Identity in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article explains how to enable a pre-created kubelet managed identity on a new or existing AKS cluster, get the properties of the kubelet managed identity, and add a role assignment for the kubelet managed identity.

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

- Azure CLI version 2.26.0 or later installed. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

::: zone pivot="terraform"

- Terraform installed locally. For installation instructions, see [Install Terraform](https://developer.hashicorp.com/terraform/install).

::: zone-end

## Limitations

- Once you create a cluster with a managed identity, you can't switch back to using a service principal.
- Moving or migrating a managed identity-enabled cluster to a different tenant isn't supported.
- If the cluster has Microsoft Entra pod-managed identity (`aad-pod-identity`) enabled, Node-Managed Identity (NMI) pods modify the iptables of the nodes to intercept calls to the Azure Instance Metadata (IMDS) endpoint. This configuration means any request made to the IMDS endpoint is intercepted by NMI, even if a particular pod doesn't use `aad-pod-identity`.
    - You can configure the AzurePodIdentityException custom resource definition (CRD) to specify that requests to the IMDS endpoint that originate from a pod matching labels defined in the CRD should be proxied without any processing in NMI. Exclude the system pods with the `kubernetes.azure.com/managedby: aks` label in *kube-system* namespace in `aad-pod-identity` by configuring the AzurePodIdentityException CRD. For more information, see [Use Microsoft Entra pod-managed identities in Azure Kubernetes Service (AKS)](use-azure-ad-pod-identity).
    - To configure an exception, install the [mic-exception YAML](https://github.com/Azure/aad-pod-identity/blob/master/deploy/infra/mic-exception.yaml).
- A pre-created kubelet managed identity must be a user-assigned managed identity.
- The China East and China North regions in Microsoft Azure operated by 21Vianet aren't supported.

Important

All Microsoft Defender for Cloud features will be officially retired in the Azure in China region on August 18, 2026. Due to this upcoming retirement, Azure in China customers are no longer able to onboard new subscriptions to the service. A new subscription is any subscription that was not already onboarded to the Microsoft Defender for Cloud service prior to August 18, 2025, the date of the retirement announcement. For more information on the retirement, see [Microsoft Defender for Cloud Deprecation in Microsoft Azure Operated by 21Vianet Announcement](https://aka.ms/mdcretirementinchina).

Customers should work with their account representatives for Microsoft Azure operated by 21Vianet to assess the impact of this retirement on their own operations.

## Update cluster considerations

When you update a cluster, consider the following information:

- An update only works if there's a VHD update to consume. If you're running the latest VHD, you need to wait until the next VHD is available in order to perform the update.
- The Azure CLI ensures your add-on's permission is correctly set after migrating. If you're not using the Azure CLI to perform the migrating operation, you need to handle the add-on identity's permission by yourself. For an example using an Azure Resource Manager (ARM) template, see [Assign Azure roles using ARM templates](/en-us/azure/role-based-access-control/role-assignments-template).
- If your cluster was using `--attach-acr` to pull from images from Azure Container Registry (ACR), you need to run the `az aks update --resource-group <resource-group-name> --name <aks-cluster-name> --attach-acr <acr-resource-id>` command after updating your cluster to let the newly created kubelet used for managed identity get the permission to pull from ACR. Otherwise, you won't be able to pull from ACR after the update.

::: zone pivot="azure-cli"

## Create a kubelet managed identity

If you don't have a kubelet managed identity, create one using the [`az identity create`](/en-us/cli/azure/identity#az_identity_create) command.

```azurecli
az identity create \
    --name <kubelet-identity-name> \
    --resource-group <resource-group-name>
```

Your output should resemble the following example output:

```output
{
    "clientId": "<client-id>",
    "clientSecretUrl": "<clientSecretUrl>",
    "id": "/subscriptions/<subscription-id>/resourcegroups/<resource-group-name>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<kubelet-identity-name>",
    "location": "<location>",
    "name": "<kubelet-identity-name>",
    "principalId": "<principal-id>",
    "resourceGroup": "<resource-group-name>",
    "tags": {},
    "tenantId": "<tenant-id>",
    "type": "Microsoft.ManagedIdentity/userAssignedIdentities"
}
```

## Assign an RBAC role to the kubelet managed identity

Assign the `acrpull` role on the kubelet managed identity using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az_role_assignment_create) command.

```azurecli
az role assignment create \
    --assignee <kubelet-client-id> \
    --role "acrpull" \
    --scope "<acr-registry-id>"
```

## Enable a kubelet managed identity on a new AKS cluster

Create an AKS cluster with your existing identities using the [`az aks create`](/en-us/cli/azure/aks#az_aks_create) command.

```azurecli
az aks create \
    --resource-group <resource-group-name> \
    --name <aks-cluster-name> \
    --network-plugin azure \
    --vnet-subnet-id <vnet-subnet-id> \
    --dns-service-ip 10.2.0.10 \
    --service-cidr 10.2.0.0/24 \
    --assign-identity <identity-resource-id> \
    --assign-kubelet-identity <kubelet-identity-resource-id> \
    --generate-ssh-keys
```

A successful AKS cluster creation using a kubelet managed identity should result in output similar to the following:

```output
...
    "identity": {
    "principalId": null,
    "tenantId": null,
    "type": "UserAssigned",
    "userAssignedIdentities": {
        "/subscriptions/<subscription-id>/resourcegroups/<resource-group-name>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity-name>": {
        "clientId": "<client-id>",
        "principalId": "<principal-id>"
        }
    }
    },
    "identityProfile": {
    "kubeletidentity": {
        "clientId": "<client-id>",
        "objectId": "<object-id>",
        "resourceId": "/subscriptions/<subscription-id>/resourcegroups/<resource-group-name>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<kubelet-identity-name>"
    }
    },
...
```

## Update an existing cluster to use a kubelet managed identity

To update an existing cluster to use the kubelet managed identity, first get the current control plane managed identity for your AKS cluster.

Warning

Updating the kubelet managed identity upgrades your AKS cluster's node pools, make sure you have the right availability configurations, such as Pod Disruption Budgets, configured before executing this to avoid workload disruption or execute this during a maintenance window.

1. Confirm your AKS cluster is using the user-assigned managed identity using the [`az aks show`](/en-us/cli/azure/aks#az_aks_show) command.

    ```azurecli
    az aks show \
        --resource-group <resource-group-name> \
        --name <aks-cluster-name> \
        --query "servicePrincipalProfile"
    ```

    If your cluster is using a managed identity, the output shows `clientId` with a value of **msi**. A cluster using a service principal shows an object ID. For example:

    ```output
    {
      "clientId": "msi"
    }
    ```
2. After confirming your cluster is using a managed identity, find the managed identity's resource ID using the [`az aks show`](/en-us/cli/azure/aks#az_aks_show) command.

    ```azurecli
    az aks show --resource-group <resource-group-name> \
        --name <aks-cluster-name> \
        --query "identity"
    ```

    For a user-assigned managed identity, your output should look similar to the following example output:

    ```output
    {
      "principalId": null,
      "tenantId": null,
      "type": "UserAssigned",
      "userAssignedIdentities": <identity-resource-id>
          "clientId": "<client-id>",
          "principalId": "<principal-id>"
    },
    ```
3. Update your cluster with your existing identities using the [`az aks update`](/en-us/cli/azure/aks#az_aks_update) command. Provide the resource ID of the user-assigned managed identity for the control plane for the `assign-identity` parameter. Provide the resource ID of the kubelet managed identity for the `assign-kubelet-identity` parameter.

    ```azurecli
    az aks update \
        --resource-group <resource-group-name> \
        --name <aks-cluster-name> \
        --enable-managed-identity \
        --assign-identity <identity-resource-id> \
        --assign-kubelet-identity <kubelet-identity-resource-id>
    ```

    Your output for a successful cluster update using your own kubelet managed identity should resemble the following example output:

    ```output
    ...
      "identity": {
        "principalId": null,
        "tenantId": null,
        "type": "UserAssigned",
        "userAssignedIdentities": {
          "/subscriptions/<subscription-id>/resourcegroups/<resource-group-name>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity-name>": {
            "clientId": "<client-id>",
            "principalId": "<principal-id>"
          }
        }
      },
      "identityProfile": {
        "kubeletidentity": {
          "clientId": "<client-id>",
          "objectId": "<object-id>",
          "resourceId": "/subscriptions/<subscription-id>/resourcegroups/<resource-group-name>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<kubelet-identity-name>"
        }
      },
    ...
    ```

## Get the properties of the kubelet managed identity

Get the properties of the kubelet managed identity using the [`az aks show`](/en-us/cli/azure/aks#az_aks_show) command and query on the `identityProfile.kubeletidentity` property.

```azurecli
az aks show \
    --name <aks-cluster-name> \
    --resource-group <resource-group-name> \
    --query "identityProfile.kubeletidentity"
```

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

## Create an AKS cluster with a pre-created kubelet managed identity using Terraform

Add the following code to `main.tf` to create a kubelet managed identity and an AKS cluster that uses the kubelet managed identity:

```Terraform
resource "azurerm_user_assigned_identity" "kubelet" {
 name                = "aks-kubelet-identity"
 resource_group_name = azurerm_resource_group.example.name
 location            = azurerm_resource_group.example.location
}
resource "azurerm_kubernetes_cluster" "kubelet_identity" {
 name                = "aks-kubelet"
 location            = azurerm_resource_group.example.location
 resource_group_name = azurerm_resource_group.example.name
 dns_prefix          = "akskubelet"
 identity {
   type         = "UserAssigned"
   identity_ids = [azurerm_user_assigned_identity.kubelet.id]
 }
 kubelet_identity {
   client_id                 = azurerm_user_assigned_identity.kubelet.client_id
   object_id                 = azurerm_user_assigned_identity.kubelet.principal_id
   user_assigned_identity_id = azurerm_user_assigned_identity.kubelet.id
 }
 default_node_pool {
   name       = "system"
   node_count = 1
   vm_size    = "Standard_DS2_v2"
 }
}
```

## Add a role assignment for the kubelet managed identity using Terraform

Add the following code to `main.tf` to create a role assignment for the kubelet managed identity. This example assigns the **AcrPull** role to the kubelet managed identity to grant it permissions to pull images from Azure Container Registry (ACR). The role assignment is scoped to the resource group.

Note

In production scenarios, assign the **AcrPull** role at the Azure Container Registry scope instead of the resource group.

```Terraform
resource "azurerm_role_assignment" "kubelet_acr_pull" {
 scope                = azurerm_resource_group.example.id
 role_definition_name = "AcrPull"
 principal_id         = azurerm_user_assigned_identity.kubelet.principal_id
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