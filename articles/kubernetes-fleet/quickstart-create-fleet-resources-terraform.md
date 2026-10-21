---
layout: Conceptual
title: 'Quickstart: Create an Azure Kubernetes Fleet Manager and join member clusters using Terraform | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/quickstart-create-fleet-resources-terraform
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
description: In this quickstart, you learn how to create an Azure Kubernetes Fleet Manager and join member clusters using Terraform.
ms.date: 2025-12-16T00:00:00.0000000Z
author: MuhammadAli
ms.author: alimuhammad
ms.service: azure-kubernetes-fleet-manager
ms.custom: template-quickstart, mode-other
ms.devlang: azurecli
ms.topic: quickstart
locale: en-us
document_id: 21c87c14-5ff2-a880-1cd9-f00996c65342
document_version_independent_id: e4d92bed-2f2c-8495-7840-bd1eef41dc11
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/quickstart-create-fleet-resources-terraform.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/quickstart-create-fleet-resources-terraform
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/quickstart-create-fleet-resources-terraform.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: e1c01337-640f-7b4b-71ea-491e858f2f72
---

# Quickstart: Create an Azure Kubernetes Fleet Manager and join member clusters using Terraform | Microsoft Learn

**Applies to:** ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Learn how to create an Azure Kubernetes Fleet Manager using Terraform.

## Before you begin

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Read the [conceptual overview of Fleet Manager](concepts-fleet), which provides an explanation of fleets and member clusters referenced in this document.
- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Install and configure Terraform](/en-us/azure/developer/terraform/quickstart-configure).

Important

If you're using the 4.x AzureRM Terraform provider, you must [explicitly specify the Azure subscription ID](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/4.0-upgrade-guide#specifying-subscription-id-is-now-mandatory) to authenticate to Azure before running commands.

One way to specify the Azure subscription ID without putting it in the `providers` block is to specify the subscription ID in an environment variable named `ARM_SUBSCRIPTION_ID`.

For more information, see the [Azure provider reference documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#argument-reference).

## Create a Fleet Manager

You can create a Fleet Manager and later add your AKS and Arc-enabled clusters as member clusters. If the Fleet Manager has a hub cluster, more features are enabled, such as [Kubernetes object propagation](concepts-resource-placement) and [Managed Fleet Namespaces](concepts-fleet-managed-namespace). For more information, see the [conceptual overview of Fleet Manager types](concepts-choosing-fleet), which provides a comparison of different Fleet Manager configurations.

Note

Once a Fleet Manager is created, it's possible to upgrade a Fleet Manager resource without a hub cluster to one with a hub cluster. For Fleet Manager resources with a hub cluster, once private or public is selected it can't be changed.

# [Fleet Manager without hub cluster](#tab/without-hub-cluster)
To create a Fleet Manager without a hub cluster, use the following steps.

1. Create a directory you can use to test the sample Terraform code and make it your current directory.
2. Create a file named `providers.tf` and insert the following code:

    ```terraform
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~>4.0"
        }
        random = {
          source  = "hashicorp/random"
          version = "~>3.0"
        }
      }
    }
    provider "azurerm" {
      features {}
    }
    ```
3. Create a file named `main.tf` and insert the following code:

    ```terraform
    resource "random_pet" "rg_name" {
      prefix = var.resource_group_name_prefix
    }
    resource "azurerm_resource_group" "fleet_rg" {
      name     = random_pet.rg_name.id
      location = var.resource_group_location
    }
    
    resource "random_string" "fleet_name" {
      length  = 63
      lower   = true
      numeric = false
      special = false
      upper   = false
    }
    
    resource "azurerm_kubernetes_fleet_manager" "fleet" {
    
      location            = azurerm_resource_group.fleet_rg.location
      name                = coalesce(var.fleet_name, random_string.fleet_name.result)
      resource_group_name = azurerm_resource_group.fleet_rg.name
    }
    ```
4. Create a file named `variables.tf` and insert the following code:

    ```terraform
    variable "resource_group_location" {
      type        = string
      default     = "eastus"
      description = "Location of the resource group"
    }
    variable "resource_group_name_prefix" {
      type        = string
      default     = "rg"
      description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
    }
    variable "fleet_name" {
      type        = string
      description = "Name of the fleet resource. If left blank, this value is randomly generated."
      default     = ""
    }
    ```
5. Create a file named `outputs.tf` and insert the following code:

    ```terraform
    output "resource_group_name" {
      value = azurerm_resource_group.fleet_rg.name
    }
    
    output "fleet_name" {
      value = azurerm_kubernetes_fleet_manager.fleet.name
    }
    ```

# [Fleet Manager with hub cluster](#tab/with-hub-cluster)
To use Fleet Manager for Kubernetes object propagation or Managed Fleet Namespaces in addition to cluster upgrades, you need to create the Fleet Manager with a hub cluster.

Fleet Manager hub clusters support both public and private modes for network access. For more information, see [Choose an Azure Kubernetes Fleet Manager option](concepts-choosing-fleet#network-access-modes-for-hub-cluster).

1. Create a directory you can use to test the sample Terraform code and make it your current directory.
2. Create a file named `providers.tf` and insert the following code:

    ```terraform
    terraform {
     required_providers {
        azapi = {
          source  = "azure/azapi"
          version = "~> 2.0"
        }
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
        random = {
          source  = "hashicorp/random"
          version = "~> 3.1"
        }
      }
    }
    provider "azurerm" {
      features {}
    }
    provider "azapi" {
    }
    ```
3. Create a file named `variables.tf` insert the following code.

    ```terraform
    variable "location" {
      description = "The Azure region where resources will be created"
      type        = string
      default     = "Australia East"
    }
    
    variable "resource_group_name" {
      description = "The name of the resource group"
      type        = string
      default     = null
    }
    
    variable "fleet_name" {
      description = "The name of the Fleet"
      type        = string
      default     = null
    }
    
    variable "hub_cluster_vm_size" {
      description = "VM size for the Fleet hub cluster"
      type        = string
      default     = "Standard_D2s_v3"
    }
    ```
4. Create a file named `main.tf` and insert the following code:

    ```terraform
    # Generate random suffix for unique resource names
    resource "random_string" "suffix" {
      length  = 4
      special = false
      upper   = false
    }
    
    # Local values for resource naming
    locals {
      resource_group_name = coalesce(var.resource_group_name, "rg-fleet-example-${random_string.suffix.result}")
      fleet_name = coalesce(var.fleet_name, "fleet-example-${random_string.suffix.result}")
    }
    
    # Resource Group
    resource "azurerm_resource_group" "fleet_rg" {
      name     = local.resource_group_name
      location = var.location
    }
    ```

#### Public hub cluster

1. Create a file named `fleet.tf` and insert the following code:

    ```terraform
    resource "azapi_resource" "fleet_public" {
      type      = "Microsoft.ContainerService/fleets@2025-03-01"
      name      = "${local.fleet_name}-pub"
      location  = azurerm_resource_group.fleet_rg.location
      parent_id = azurerm_resource_group.fleet_rg.id
    
      body = {
        properties = {
          hubProfile = {
            agentProfile = {
              vmSize = var.hub_cluster_vm_size
            }
            apiServerAccessProfile = {
              enablePrivateCluster = false
              enableVnetIntegration = false
            }
            dnsPrefix = "${local.fleet_name}-pub"
          }
        }
      }
    
      identity {
        type = "SystemAssigned"
      }
    
      depends_on = [
        azurerm_resource_group.fleet_rg
      ]
    }
    ```

#### Private hub cluster

When you create a Fleet Manager with a private hub cluster, take these additional considerations into account:

- Fleet Manager requires you to provide the subnet on which the Fleet Manager hub cluster's node Virtual Machine (VM) is placed. This can be done by setting `subnetId` in the `agentProfile` within the Fleet Manager's `hubProfile`.
- The address prefix of the vnet **vnetName** must not overlap with the Azure Kubernetes Service's (AKS) default service range of `10.0.0.0/16`.
- Private access mode doesn't allow configuring domain names.
- Private access mode requires a `Network Contributor` role assignment on the agent subnet for Fleet Manager's first party service principal (Fleet Manager's first party service principal ID varies across different Entra tenants). This role assignment is **NOT** needed when creating private Fleet Manager using the `az fleet create` command because the CLI automatically creates the role assignment.

1. Fetch Fleet Manager's service principal object ID:

    ```azurecli
    az ad sp list \
        --display-name "Azure Kubernetes Service - Fleet RP" \
        --query "[].{id:id}" \
        --output tsv
    ```

    ```output
    xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    ```
2. Create a file named `identity.tf` and insert the following code, updating the placeholder `principal_id` to match the output from the earlier service principal query:

    ```terraform
    ##
    # REQUIRED: Assign Network Contributor Role to "Azure Kubernetes Service - Fleet RP" to enable hub cluster updates
    ##
    resource "azurerm_role_assignment" "fleet_identity_01_network_contributor" {
      scope                = azurerm_subnet.hub-cluster-subnet.id
      role_definition_name = "Network Contributor"
      principal_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      principal_type       = "ServicePrincipal"
    
      depends_on = [azurerm_subnet.hub-cluster-subnet]
    }
    
    ##
    # REQUIRED: Create User Assigned Managed Identity for Fleet Manager
    ##
    resource "azurerm_user_assigned_identity" "fleet_user_assigned_identity" {
      location            = azurerm_resource_group.fleet_rg.location
      name                = "${local.fleet_name}-uai"
      resource_group_name = azurerm_resource_group.fleet_rg.name
    }
    
    # REQUIRED: Assign Managed Identity the Network Contributor Role scoped to Hub Cluster API Server Subnet
    resource "azurerm_role_assignment" "fleet_user_assign_id_api_subnet_network_contributor" {
      scope                = azurerm_subnet.fleet-hub-apiserver-subnet.id
      role_definition_name = "Network Contributor"
      principal_id         = azurerm_user_assigned_identity.fleet_user_assigned_identity.principal_id
      principal_type       = "ServicePrincipal"
    
      depends_on = [azurerm_subnet.fleet-hub-apiserver-subnet, azurerm_user_assigned_identity.fleet_user_assigned_identity]
    }
    
    # REQUIRED: Assign Managed Identity the Network Contributor Role scoped to Hub Cluster Subnet
    resource "azurerm_role_assignment" "fleet_user_assign_id_hub_subnet_network_contributor" {
      scope                = azurerm_subnet.hub-cluster-subnet.id
      role_definition_name = "Network Contributor"
      principal_id         = azurerm_user_assigned_identity.fleet_user_assigned_identity.principal_id
      principal_type       = "ServicePrincipal"
    
      depends_on = [azurerm_subnet.hub-cluster-subnet, azurerm_user_assigned_identity.fleet_user_assigned_identity]
    }
    ```
3. Create a file named `vnet.tf` and insert the following code. If you want to use an existing virtual network you can replace the contents of `vnet.tf` file with resource references only, ensuring you have the correct subnets and delegations in place.

    ```terraform
    resource "azurerm_virtual_network" "hub-vnet" {
      name                = "${local.fleet_name}-vnet"
      location            = azurerm_resource_group.fleet_rg.location
      resource_group_name = azurerm_resource_group.fleet_rg.name
      address_space       = ["10.224.0.0/12"]
    }
    
    resource "azurerm_subnet" "hub-cluster-subnet" {
      name                 = "fleet-hub-cluster-subnet"
      resource_group_name  = azurerm_resource_group.fleet_rg.name
      virtual_network_name = azurerm_virtual_network.hub-vnet.name
      address_prefixes     = ["10.224.0.0/15"]
      private_endpoint_network_policies = "Disabled"
      private_link_service_network_policies_enabled = true
    }
    
    resource "azurerm_subnet" "fleet-hub-apiserver-subnet" {
      name                 = "fleet-hub-apiserver-subnet"
      resource_group_name  = azurerm_resource_group.fleet_rg.name
      virtual_network_name = azurerm_virtual_network.hub-vnet.name
      address_prefixes     = ["10.226.0.0/15"]
      delegation {
        name = "aksApiServerSubnetDelegation"
        service_delegation {
          name    = "Microsoft.ContainerService/managedClusters"
        }
      }
    }
    ```
4. Create a file named `fleet.tf` and insert the following code:

    ```terraform
    # Fleet Resource
    resource "azapi_resource" "fleet" {
      type      = "Microsoft.ContainerService/fleets@2025-03-01"
      name      = local.fleet_name
      location  = azurerm_resource_group.fleet_rg.location
      parent_id = azurerm_resource_group.fleet_rg.id
    
      body = {
        properties = {
          hubProfile = {
            agentProfile = {
              subnetId = azurerm_subnet.hub-cluster-subnet.id
              vmSize = var.hub_cluster_vm_size
            }
            apiServerAccessProfile = {
              enablePrivateCluster = true
              enableVnetIntegration = true
              subnetId = azurerm_subnet.fleet-hub-apiserver-subnet.id
            }
            dnsPrefix = local.fleet_name
          }
        }
      }
    
      identity {
        type = "UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.fleet_user_assigned_identity.id]
      }
    
      depends_on = [
        azurerm_resource_group.fleet_rg,
        azurerm_role_assignment.fleet_identity_01_network_contributor, 
        azurerm_user_assigned_identity.fleet_user_assigned_identity, 
        azurerm_role_assignment.fleet_user_assign_id_api_subnet_network_contributor,
        azurerm_role_assignment.fleet_user_assign_id_hub_subnet_network_contributor
      ]
    }
    ```

---

#### Initialize Terraform

Run [terraform init](https://www.terraform.io/docs/commands/init.html) to initialize the Terraform deployment. This command downloads the Azure provider required to manage your Azure resources.

```console
terraform init -upgrade
```

**Key points:**

- The `-upgrade` parameter upgrades the necessary provider plugins to the newest version that complies with the configuration's version constraints.

#### Create a Terraform execution plan

Run [terraform plan](https://www.terraform.io/docs/commands/plan.html) to create an execution plan.

```console
terraform plan -out main.tfplan
```

**Key points:**

- The `terraform plan` command creates an execution plan, but doesn't execute it. Instead, it determines what actions are necessary to create the configuration specified in your configuration files. This pattern allows you to verify whether the execution plan matches your expectations before making any changes to actual resources.
- The optional `-out` parameter allows you to specify an output file for the plan. Using the `-out` parameter ensures that the plan you reviewed is exactly what is applied.

#### Apply a Terraform execution plan

Run [terraform apply](https://www.terraform.io/docs/commands/apply.html) to apply the execution plan to your cloud infrastructure.

```console
terraform apply main.tfplan
```

**Key points:**

- The example `terraform apply` command assumes you previously ran `terraform plan -out main.tfplan`.
- If you specified a different filename for the `-out` parameter, use that same filename in the call to `terraform apply`.
- If you didn't use the `-out` parameter, call `terraform apply` without any parameters.

#### Verify the results

Verify results using either Azure CLI or Azure PowerShell.

# [Azure CLI](#tab/azure-cli)
1. Get the Azure resource group name.

    ```console
    resource_group_name=$(terraform output -raw resource_group_name)
    ```
2. Get the Fleet Manager name.

    ```console
    batch_name=$(terraform output -raw fleet_name)
    ```
3. Run [az fleet show](/en-us/cli/azure/fleet#az-fleet-show) to view the Azure Kubernetes Fleet Manager.

    ```azurecli
    az fleet show --resource-group $resource_group_name --name $fleet_name
    ```

# [Azure PowerShell](#tab/azure-powershell)
1. Get the Azure resource group name.

    ```powershell
    $resource_group_name=$(terraform output -raw resource_group_name)
    ```
2. Get the Fleet Manager name.

    ```powershell
    $batch_name=$(terraform output -raw fleet_name)
    ```
3. Run [Get-AzFleet](/en-us/powershell/module/az.fleet/get-azfleet) to view the Azure Kubernetes Fleet Manager.

    ```azurepowershell
    Get-AzFleet -ResourceGroupName $resource_group_name -Name $fleet_name
    ```

---

#### Clean up resources

When you no longer need the resources created via Terraform, do the following steps:

1. Run [terraform plan](https://www.terraform.io/docs/commands/plan.html) and specify the `destroy` flag.

    ```console
    terraform plan -destroy -out main.destroy.tfplan
    ```

    **Key points:**

    - The `terraform plan` command creates an execution plan, but doesn't execute it. Instead, it determines what actions are necessary to create the configuration specified in your configuration files. This pattern allows you to verify whether the execution plan matches your expectations before making any changes to actual resources.
    - The optional `-out` parameter allows you to specify an output file for the plan. Using the `-out` parameter ensures that the plan you reviewed is exactly what is applied.
2. Run [terraform apply](https://www.terraform.io/docs/commands/apply.html) to apply the execution plan.

    ```console
    terraform apply main.destroy.tfplan
    ```