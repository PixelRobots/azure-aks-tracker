---
layout: Conceptual
title: 'Quickstart: Create an Azure container registry using Terraform - Azure Container Registry | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-terraform
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
description: In this quickstart, you create a unique resource group and an Azure container registry in a specified location using Terraform.
ms.topic: quickstart
ms.date: 2024-11-19T00:00:00.0000000Z
ms.custom: devx-track-terraform
content_well_notification:
- AI-contribution
locale: en-us
document_id: 7bcf7847-b1be-9221-4df2-0aac0ac5ffc9
document_version_independent_id: d7559c0d-7724-b990-950f-a81d23204116
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-get-started-terraform.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-get-started-terraform
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-get-started-terraform.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 34abd0e4-eea8-c4d3-3e0a-bf054a81edc1
---

# Quickstart: Create an Azure container registry using Terraform - Azure Container Registry | Microsoft Learn

In this quickstart, you create an Azure container registry and a resource group using Terraform. Azure Container Registry is a managed Docker registry service used for storing private Docker container images. It's typically used with Azure Kubernetes Service (AKS), Azure App Service, and other Azure services to pull down container images. The registry is stored within a resource group, which is a logical container for resources deployed on Azure. These resources are created with unique names by combining a prefix with a random string, ensuring they are unique within your Azure subscription.

[Terraform](https://www.terraform.io) enables the definition, preview, and deployment of cloud infrastructure. Using Terraform, you create configuration files using [HCL syntax](https://developer.hashicorp.com/terraform/language/syntax/configuration). The HCL syntax allows you to specify the cloud provider - such as Azure - and the elements that make up your cloud infrastructure. After you create your configuration files, you create an *execution plan* that allows you to preview your infrastructure changes before they're deployed. Once you verify the changes, you apply the execution plan to deploy the infrastructure.

- Specify the required version of Terraform and the required providers.
- Define the Azure provider with no additional features.
- Define a variable for the location of the resource group and with a default value of "eastus".
- Define a variable for the prefix of the resource group name and with a default value of "rg".
- Generate a random pet name for the resource group.
- Create an Azure resource group with the generated name at a specified location.
- Generate a random string of five lowercase letters to be used as part of the container registry name.
- Create a container registry with the generated string as part of its name and in the same location and resource group as above.
- Output the names of the created resource group and container registry.
- Output the login server of the created container registry.

## Prerequisites

- Create an Azure account with an active subscription. You can [create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Install and configure Terraform](/en-us/azure/developer/terraform/quickstart-configure).

## Implement the Terraform code

Note

The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/101-azure-container-registry). You can view the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/101-azure-container-registry/TestRecord.md).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/terraform).

1. Create a directory in which to test and run the sample Terraform code, and make it the current directory.
2. Create a file named `main.tf`, and insert the following code:

    ```Terraform
    resource "random_pet" "rg_name" {
      prefix = var.resource_group_name_prefix
    }
    
    resource "azurerm_resource_group" "rg" {
      location = var.resource_group_location
      name     = random_pet.rg_name.id
    }
    
    resource "random_string" "acr_name" {
      length  = 5
      lower   = true
      numeric = false
      special = false
      upper   = false
    }
    
    resource "azurerm_container_registry" "example" {
      name                = "${random_string.acr_name.result}registry"
      resource_group_name = azurerm_resource_group.rg.name
      location            = azurerm_resource_group.rg.location
      sku                 = "Standard"
    }
    ```
3. Create a file named `outputs.tf`, and insert the following code:

    ```Terraform
    output "resource_group_name" {
      value = azurerm_resource_group.rg.name
    }
    
    output "container_registry_name" {
      value = azurerm_container_registry.example.name
    }
    
    output "container_registry_login_server" {
      value = azurerm_container_registry.example.login_server
    }
    ```
4. Create a file named `providers.tf`, and insert the following code:

    ```Terraform
    terraform {
      required_version = ">=1.0"
    
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
      features {}
    }
    ```
5. Create a file named `variables.tf`, and insert the following code:

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

# [Azure CLI](#tab/azure-cli)
Run [az acr show](/en-us/cli/azure/acr#az-acr-show) to view the container registry.

```azurecli
az acr show --name <registry_name> --resource-group <resource_group_name>
```

Replace `<registry_name>` with the name of your container registry and `<resource_group_name>` with the name of your resource group.

---

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