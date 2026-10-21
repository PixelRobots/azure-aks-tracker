---
layout: Conceptual
title: Deploy a Production-Ready Azure Kubernetes Service (AKS) Cluster using Terraform with an Azure Verified Module (AVM) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/deploy-cluster-terraform-verified-module
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
description: Learn how to deploy a production-ready Azure Kubernetes Service (AKS) cluster using Terraform with an Azure Verified Module (AVM).
ms.topic: how-to
ms.date: 2026-04-07T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-developer
locale: en-us
document_id: ec954d01-702a-6f46-5e19-9270c04ab7cd
document_version_independent_id: 8e395312-bff0-af76-95a6-03ee70f09981
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/deploy-cluster-terraform-verified-module.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/deploy-cluster-terraform-verified-module
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/deploy-cluster-terraform-verified-module.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a876da18-ce35-113b-ed72-c20d3f59f0cf
---

# Deploy a Production-Ready Azure Kubernetes Service (AKS) Cluster using Terraform with an Azure Verified Module (AVM) - Azure Kubernetes Service | Microsoft Learn

Azure Verified Modules (AVMs) are pre-defined, reusable Infrastructure as Code (IaC) modules developed and maintained by Microsoft for [Bicep](/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep) and [Terraform](/en-us/azure/developer/terraform/overview). AVMs are designed to help you deploy Azure resources in a consistent and reliable manner, following best practices and compliance standards.

In this article, you learn how to deploy a production-ready AKS cluster using Terraform with an Azure Verified Module (AVM).

For more information about AVMs, see [Azure Verified Modules](/en-us/community/content/azure-verified-modules).

## Prerequisites

- An active Azure subscription. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Set your subscription context using the [`az account set`](/en-us/cli/azure/account#az_account_set) command. For example:

    ```azurecli
    az account set --subscription "00000000-0000-0000-0000-000000000000"
    ```
- Azure CLI installed and configured. Find your version using the `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- [kubectl](https://kubernetes.io/releases/download/) installed. You can install it locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az_aks_install_cli) command.
- Terraform installed locally. For installation instructions, see [Install Terraform](https://developer.hashicorp.com/terraform/install).

## Understand the Terraform configuration

The Terraform module implements a production-ready AKS cluster with the following features:

- **Zone-aligned node pools in multiple availability zones**: We implement [availability zones](reliability-availability-zones-configure) with the cluster autoscaler, using a single node pool for each zone. The `balance_similar_node_groups` parameter enables a balanced distribution of nodes across the zones for scalability and high availability.
- **Automatic AKS upgrades**: We enforce the [`patch` upgrade channel](auto-upgrade-cluster#cluster-autoupgrade-channels) and enable [node OS image autoupgrades](auto-upgrade-node-os-image) to ensure the cluster stays up-to-date with the latest security patches and features.
- **Azure CNI Overlay networking**: We use [Azure CNI Overlay networking](azure-cni-overlay) to provide advanced networking capabilities, including IP address management (IPAM) and network policy enforcement.
- **Private Kubernetes API endpoint and Microsoft Entra authentication**: We keep the Kubernetes API safe by putting it in a private network, allow authentication using [Microsoft Entra ID](concepts-cluster-authentication), and turn off local accounts (optional).
- **Bring-your-own (BYO) virtual network (VNet) and require a user-assigned managed identity**: We allow you to bring your own VNet and require a user-assigned managed identity for the AKS cluster to enhance security and control over network and identity resources. You can use the same managed identity across multiple clusters for consistent identity management.

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
    resource "azurerm_resource_group" "aks" {
     name     = "rg-aksprod-demo"
     location = "eastus"
    }
    ```

## Create the virtual network (VNet) and subnet

Add the following code to `main.tf` to create a virtual network (VNet) and a subnet for the AKS cluster:

```Terraform
resource "azurerm_virtual_network" "aks" {
 name                = "vnet-aksprod-demo"
 location            = azurerm_resource_group.aks.location
 resource_group_name = azurerm_resource_group.aks.name
 address_space       = ["10.31.0.0/16"]
}
resource "azurerm_subnet" "aks_nodes" {
 name                 = "snet-aks-nodes"
 resource_group_name  = azurerm_resource_group.aks.name
 virtual_network_name = azurerm_virtual_network.aks.name
 address_prefixes     = ["10.31.0.0/17"]
}
```

## Create the production-ready AKS cluster

Add the following code to `main.tf` to create a production-ready AKS cluster using the AVM:

```Terraform
module "aks_production" {
 source  = "Azure/avm-ptn-aks-production/azurerm"
 version = "0.5.0"
 name                = "aksprod-demo"
 location            = azurerm_resource_group.aks.location
 resource_group_name = azurerm_resource_group.aks.name
 network = {
   node_subnet_id = azurerm_subnet.aks_nodes.id
   pod_cidr       = "192.168.0.0/16"
 }
}
```

## Initialize Terraform

Initialize Terraform in the directory containing your `main.tf` file using the [`terraform init`](https://www.terraform.io/docs/commands/init.html) command. This command downloads the Azure provider required to manage Azure resources with Terraform.

```console
terraform init
```

## Validate the Terraform configuration

Validate the Terraform configuration using the [`terraform validate`](https://www.terraform.io/docs/commands/validate.html) command. This command checks the syntax and internal consistency of the Terraform configuration files.

```console
terraform validate
```

You might encounter warnings related to deprecated arguments. These warnings come from the AVM and don't prevent deployment.

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

## Connect to the AKS cluster

1. Configure kubectl to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az_aks_get_credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group <resource-group> --name <cluster-name>
    ```
2. Verify the connection to your cluster using the [`kubectl get`][kubectl-get] command. This command returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```