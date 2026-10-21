---
layout: Conceptual
title: 'Quickstart: Create a Windows-based Azure Kubernetes Service (AKS) cluster using Terraform - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-terraform
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
description: In this quickstart, you create an Azure Kubernetes cluster with a default node pool and a separate Windows node pool.
ms.author: schaffererin
author: schaffererin
ms.topic: quickstart
ms.date: 2024-07-15T00:00:00.0000000Z
ms.custom: devx-track-terraform, aks-windows
content_well_notification:
- AI-contribution
ai-usage: ai-assisted
locale: en-us
document_id: bec9d059-efb6-9d7a-4fcf-53305b8b5132
document_version_independent_id: f0c898b1-09a5-1531-4076-86691ad7f8e9
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/learn/quick-windows-container-deploy-terraform.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../toc.json
asset_id: aks/learn/quick-windows-container-deploy-terraform
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/learn/quick-windows-container-deploy-terraform.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 9bc9c52d-19be-1d00-977a-f41a828a285b
---

# Quickstart: Create a Windows-based Azure Kubernetes Service (AKS) cluster using Terraform - Azure Kubernetes Service | Microsoft Learn

In this quickstart, you create an Azure Kubernetes cluster with a Windows node pool using Terraform. Azure Kubernetes Service (AKS) is a managed container orchestration service provided by Azure. It simplifies the deployment, scaling, and operations of containerized applications. The service uses Kubernetes, an open-source system for automating the deployment, scaling, and management of containerized applications. The Windows node pool allows you to run Windows containers in your Kubernetes cluster.

[Terraform](https://www.terraform.io) enables the definition, preview, and deployment of cloud infrastructure. Using Terraform, you create configuration files using [HCL syntax](https://developer.hashicorp.com/terraform/language/syntax/configuration). The HCL syntax allows you to specify the cloud provider - such as Azure - and the elements that make up your cloud infrastructure. After you create your configuration files, you create an *execution plan* that allows you to preview your infrastructure changes before they're deployed. Once you verify the changes, you apply the execution plan to deploy the infrastructure.

- Generate a random resource group name.
- Create an Azure resource group.
- Create an Azure virtual network.
- Create an Azure Kubernetes cluster.
- Create an Azure Kubernetes cluster node pool.

## Prerequisites

- Create an Azure account with an active subscription. You can [create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Install and configure Terraform](/en-us/azure/developer/terraform/quickstart-configure)

## Implement the Terraform code

Note

The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-cluster-windows). You can view the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-cluster-windows/TestRecord.md).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/terraform)

1. Create a directory in which to test and run the sample Terraform code and make it the current directory.
2. Create a file named `providers.tf` and insert the following code.

    ```Terraform
    terraform {
      required_version = ">= 1.0"
    
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~>3.0"
        }
        random = {
          source  = "hashicorp/random"
          version = "~>3.0"
        }
      }
    }
    
    provider "azurerm" {
      features {
      }
    }
    ```
3. Create a file named `main.tf` and insert the following code.

    ```Terraform
    # Generate random resource group name
    resource "random_pet" "rg_name" {
      prefix = var.resource_group_name_prefix
    }
    
    resource "azurerm_resource_group" "rg" {
      location = var.resource_group_location
      name     = random_pet.rg_name.id
    }
    
    resource "random_pet" "azurerm_kubernetes_cluster_name" {
      prefix = "cluster"
    }
    
    resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
      prefix = "dns"
    }
    
    resource "random_string" "azurerm_kubernetes_cluster_node_pool" {
      length  = 6
      special = false
      numeric = false
      lower   = true
      upper   = false
    }
    
    resource "azurerm_virtual_network" "vnet" {
      name                = "myvnet"
      location            = azurerm_resource_group.rg.location
      resource_group_name = azurerm_resource_group.rg.name
      address_space       = ["10.1.0.0/16"]
    
      subnet {
        name           = "subnet1"
        address_prefix = "10.1.1.0/24"
      }
    }
    
    resource "azurerm_kubernetes_cluster" "aks" {
      name                = random_pet.azurerm_kubernetes_cluster_name.id
      location            = azurerm_resource_group.rg.location
      resource_group_name = azurerm_resource_group.rg.name
      dns_prefix          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id
    
      identity {
        type = "SystemAssigned"
      }
    
      default_node_pool {
        name           = "agentpool"
        vm_size        = "Standard_D2_v2"
        node_count     = var.node_count_linux
        vnet_subnet_id = element(tolist(azurerm_virtual_network.vnet.subnet), 0).id
      }
    
      windows_profile {
        admin_username = var.admin_username
        admin_password = var.admin_password
      }
    
      network_profile {
        network_plugin    = "azure"
        load_balancer_sku = "standard"
      }
    }
    
    resource "azurerm_kubernetes_cluster_node_pool" "win" {
      name                  = random_string.azurerm_kubernetes_cluster_node_pool.result
      kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
      vm_size               = "Standard_D4s_v3"
      node_count            = var.node_count_windows
      os_type               = "Windows"
    }
    ```
4. Create a file named `variables.tf` and insert the following code.

    ```Terraform
    variable "resource_group_location" {
      type        = string
      default     = "eastus"
      description = "Location of the resource group."
    }
    
    variable "resource_group_name_prefix" {
      type        = string
      default     = "rg"
      description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
    }
    
    variable "node_count_linux" {
      type        = number
      description = "The initial quantity of Linux nodes for the node pool."
      default     = 1
    }
    
    variable "node_count_windows" {
      type        = number
      description = "The initial quantity of Windows nodes for the node pool."
      default     = 1
    }
    
    variable "admin_username" {
      type        = string
      description = "The admin username for the Windows node pool."
      default     = "azureuser"
    }
    
    variable "admin_password" {
      type        = string
      description = "The admin password for the Windows node pool."
      default     = "Passw0rd1234Us!"
    }
    ```
5. Create a file named `outputs.tf` and insert the following code.

    ```Terraform
    output "resource_group_name" {
      value = azurerm_resource_group.rg.name
    }
    
    output "kubernetes_cluster_name" {
      value = azurerm_kubernetes_cluster.aks.name
    }
    
    output "kubernetes_cluster_dns_prefix" {
      value = azurerm_kubernetes_cluster.aks.dns_prefix
    }
    
    output "kubernetes_cluster_node_pool_name" {
      value = azurerm_kubernetes_cluster_node_pool.win.name
    }
    
    output "kubernetes_cluster_kube_config_raw" {
      value = azurerm_kubernetes_cluster.aks.kube_config_raw
      sensitive = true
    }
    ```

## Initialize Terraform

Run [terraform init](https://www.terraform.io/docs/commands/init.html) to initialize the Terraform deployment. This command downloads the Azure provider required to manage your Azure resources.

```console
terraform init -upgrade
```

**Key points:**

- The `-upgrade` parameter upgrades the necessary provider plugins to the newest version that complies with the configuration's version constraints.

## Create a Terraform execution plan

Run [terraform plan](https://www.terraform.io/docs/commands/plan.html) to create an execution plan.

```console
terraform plan -out main.tfplan
```

**Key points:**

- The `terraform plan` command creates an execution plan, but doesn't execute it. Instead, it determines what actions are necessary to create the configuration specified in your configuration files. This pattern allows you to verify whether the execution plan matches your expectations before making any changes to actual resources.
- The optional `-out` parameter allows you to specify an output file for the plan. Using the `-out` parameter ensures that the plan you reviewed is exactly what is applied.

## Apply a Terraform execution plan

Run [terraform apply](https://www.terraform.io/docs/commands/apply.html) to apply the execution plan to your cloud infrastructure.

```console
terraform apply main.tfplan
```

**Key points:**

- The example `terraform apply` command assumes you previously ran `terraform plan -out main.tfplan`.
- If you specified a different filename for the `-out` parameter, use that same filename in the call to `terraform apply`.
- If you didn't use the `-out` parameter, call `terraform apply` without any parameters.

## Verify the results

Run [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) to print the cluster's nodes.

```bash
kubectl get node -o wide
```

## Clean up resources

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

## Troubleshoot Terraform on Azure

[Troubleshoot common problems when using Terraform on Azure](/en-us/azure/developer/terraform/troubleshoot).