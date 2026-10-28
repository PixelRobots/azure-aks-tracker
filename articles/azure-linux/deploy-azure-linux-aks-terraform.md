---
layout: Conceptual
title: 'Quickstart: Deploy an Azure Linux Container Host for AKS Cluster using Terraform | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/azure-linux/deploy-azure-linux-aks-terraform
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/133/azure
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/79b1327d-d925-ec11-b6e6-000d3a4f06a4
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
learn_banner_products:
- azure
manager: kumud
description: Learn how to quickly deploy an Azure Linux Container Host for Azure Kubernetes Service (AKS) cluster using Terraform.
author: kavyamsft
ms.author: schaffererin
ms.service: microsoft-linux
ms.topic: quickstart
ms.date: 2026-04-28T00:00:00.0000000Z
locale: en-us
document_id: 8970950c-e23c-193d-e8fe-f195738288fc
document_version_independent_id: ddea98c0-0141-e750-4095-1a3cb5137f53
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/azure-linux/deploy-azure-linux-aks-terraform.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: azure-linux/deploy-azure-linux-aks-terraform
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/azure-linux/deploy-azure-linux-aks-terraform.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 9a54409e-223e-11ff-a068-b2de499d5973
---

# Quickstart: Deploy an Azure Linux Container Host for AKS Cluster using Terraform | Microsoft Learn

Get started with the Azure Linux Container Host by using [Terraform](https://www.terraform.io/) to deploy an Azure Linux Container Host cluster.

In this quickstart, you learn how to:

- Implement the Terraform code to deploy an Azure Linux Container Host cluster.
- Initialize Terraform and create an execution plan.
- Apply the Terraform execution plan to deploy the Azure Linux Container Host cluster.
- Validate the Azure Linux Container Host cluster deployment.

Note

The example code in this article is located in the [Microsoft Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/201-k8s-cluster-with-tf-and-aks).

## Prerequisites

- If you don't have an Azure account, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- If you haven't already configured Terraform, you can do so using one of the following options:

    - [Azure Cloud Shell with Bash](/en-us/azure/developer/terraform/get-started-cloud-shell-bash?tabs=bash)
    - [Azure Cloud Shell with PowerShell](/en-us/azure/developer/terraform/get-started-cloud-shell-powershell?tabs=bash)
    - [Windows with Bash](/en-us/azure/developer/terraform/get-started-windows-bash?tabs=bash)
    - [Windows with PowerShell](/en-us/azure/developer/terraform/get-started-windows-powershell?tabs=bash)
- If you don't have an Azure service principal, [create a service principal](/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash#create-a-service-principal). Make note of the `appId`, `display_name`, `password`, and `tenant`.
- You need the Kubernetes command-line tool `kubectl`. If you don't have it, [download kubectl](https://kubernetes.io/releases/download/).

### Create an SSH key pair

To access AKS nodes, you connect using an SSH key pair (public and private), which you generate using the `ssh-keygen` command. By default, these files are created in the *~/.ssh* directory. Running the `ssh-keygen` command overwrites any SSH key pair with the same name already existing in the given location.

1. Navigate to https://shell.azure.com to open Cloud Shell in your browser.
2. Run the `ssh-keygen` command. The following example creates an SSH key pair using RSA encryption and a bit length of 4096:

    ```bash
    ssh-keygen -t rsa -b 4096
    ```

For more information about creating SSH keys, see [Create and manage SSH keys for authentication in Azure](/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed).

## Implement the Terraform code

1. Create a directory in which to test the sample Terraform code and make it the current directory.
2. Create a file named `providers.tf` and insert the following code:

    ```terraform
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
3. Create a file named `main.tf` and insert the following code:

    ```terraform
        # Generate random resource group name
        resource "random_pet" "rg_name" {
          prefix = var.resource_group_name_prefix
        }
    
        resource "azurerm_resource_group" "rg" {
          location = var.resource_group_location
          name     = random_pet.rg_name.id
        }
    
        resource "random_id" "log_analytics_workspace_name_suffix" {
          byte_length = 8
        }
    
        resource "azurerm_log_analytics_workspace" "test" {
          location            = var.log_analytics_workspace_location
          # The WorkSpace name has to be unique across the whole of azure;
          # not just the current subscription/tenant.
          name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
          resource_group_name = azurerm_resource_group.rg.name
          sku                 = var.log_analytics_workspace_sku
        }
    
        resource "azurerm_log_analytics_solution" "test" {
          location              = azurerm_log_analytics_workspace.test.location
          resource_group_name   = azurerm_resource_group.rg.name
          solution_name         = "ContainerInsights"
          workspace_name        = azurerm_log_analytics_workspace.test.name
          workspace_resource_id = azurerm_log_analytics_workspace.test.id
    
          plan {
            product   = "OMSGallery/ContainerInsights"
            publisher = "Microsoft"
          }
        }
    
        resource "azurerm_kubernetes_cluster" "k8s" {
          location            = azurerm_resource_group.rg.location
          name                = var.cluster_name
          resource_group_name = azurerm_resource_group.rg.name
          dns_prefix          = var.dns_prefix
          tags                = {
            Environment = "Development"
          }
    
          default_node_pool {
            name       = "azurelinuxpool"
            vm_size    = "Standard_D2_v2"
            node_count = var.agent_count
            os_sku = "AzureLinux"
          }
          linux_profile {
            admin_username = "azurelinux"
    
            ssh_key {
              key_data = file(var.ssh_public_key)
            }
          }
          network_profile {
            network_plugin    = "kubenet"
            load_balancer_sku = "standard"
          }
          service_principal {
            client_id     = var.aks_service_principal_app_id
            client_secret = var.aks_service_principal_client_secret
          }
        }
    ```

    Similarly, you can specify the Azure Linux `os_sku` in [azurerm_kubernetes_cluster_node_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool#os_sku).
4. Create a file named `variables.tf` and insert the following code:

    ```terraform
        variable "agent_count" {
            default = 3
        }
    
        # The following two variable declarations are placeholder references.
        # Set the values for these variable in terraform.tfvars
        variable "aks_service_principal_app_id" {
          default = ""
        }
    
        variable "aks_service_principal_client_secret" {
          default = ""
        }
    
        variable "cluster_name" {
          default = "k8stest"
        }
    
        variable "dns_prefix" {
          default = "k8stest"
        }
    
        # Refer to https://azure.microsoft.com/global-infrastructure/services/?products=monitor for available Log Analytics regions.
        variable "log_analytics_workspace_location" {
          default = "eastus"
        }
    
        variable "log_analytics_workspace_name" {
          default = "testLogAnalyticsWorkspaceName"
        }
    
        # Refer to https://azure.microsoft.com/pricing/details/monitor/ for Log Analytics pricing
        variable "log_analytics_workspace_sku" {
          default = "PerGB2018"
        }
    
        variable "resource_group_location" {
          default     = "eastus"
          description = "Location of the resource group."
        }
    
        variable "resource_group_name_prefix" {
          default     = "rg"
          description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
        }
    
        variable "ssh_public_key" {
          default = "~/.ssh/id_rsa.pub"
        }
    ```
5. Create a file named `outputs.tf` and insert the following code:

    ```terraform
        output "client_certificate" {
          value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
          sensitive = true
        }
    
        output "client_key" {
          value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
          sensitive = true
        }
    
        output "cluster_ca_certificate" {
          value     = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
          sensitive = true
        }
    
        output "cluster_password" {
          value     = azurerm_kubernetes_cluster.k8s.kube_config[0].password
          sensitive = true
        }
    
        output "cluster_username" {
          value     = azurerm_kubernetes_cluster.k8s.kube_config[0].username
          sensitive = true
        }
    
        output "host" {
          value     = azurerm_kubernetes_cluster.k8s.kube_config[0].host
          sensitive = true
        }
    
        output "kube_config" {
          value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
          sensitive = true
        }
    
        output "resource_group_name" {
          value = azurerm_resource_group.rg.name
        }
    ```
6. Create a file named `terraform.tfvars` and insert the following code:

    ```terraform
        aks_service_principal_app_id = "<service_principal_app_id>"
        aks_service_principal_client_secret = "<service_principal_password>"
    ```

## Initialize Terraform and create an execution plan

1. Initialize Terraform and download the Azure modules required to manage your Azure resources using the [`terraform init`](https://developer.hashicorp.com/terraform/cli/commands/init) command.

    ```console
    terraform init
    ```
2. Create a Terraform execution plan using the [`terraform plan`](https://developer.hashicorp.com/terraform/cli/commands/plan) command.

    ```console
    terraform plan -out main.tfplan
    ```

    The `terraform plan` command creates an execution plan, but doesn't execute it. Instead, it determines what actions are necessary to create the configuration specified in your configuration files. This pattern allows you to verify whether the execution plan matches your expectations before making any changes to actual resources.

    The optional `-out` parameter allows you to specify an output file for the plan. Using the `-out` parameter ensures that the plan you reviewed is exactly what is applied.

    To read more about persisting execution plans and security, see the [security warnings](https://developer.hashicorp.com/terraform/cli/commands/plan#security-warning).
3. Apply the Terraform execution plan using the [`terraform apply`](https://developer.hashicorp.com/terraform/cli/commands/apply) command.

    ```console
    terraform apply main.tfplan
    ```

    The `terraform apply` command above assumes you previously ran `terraform plan -out main.tfplan`. If you specified a different file name for the `-out` parameter, use that same file name in the call to `terraform apply`. If you didn't use the `-out` parameter, call `terraform apply` without any parameters.

## Verify the results

1. Get the resource group name using the following `echo` command.

    ```console
    echo "$(terraform output resource_group_name)"
    ```
2. Navigate to the [Azure portal](https://portal.azure.com).
3. Under **Azure services**, select **Resource groups** and locate your new resource group to see the following resources created in this demo:

    - **Solution**: By default, the demo names this solution **ContainerInsights**. The portal shows the solution's workspace name in parenthesis.
    - **Kubernetes service**: By default, the demo names this service **k8stest**. (A managed Kubernetes cluster is also known as an AKS/Azure Kubernetes Service.)
    - **Log Analytics Workspace**: By default, the demo names this workspace with a prefix of **TestLogAnalyticsWorkspaceName-** followed by a random number.
4. Get the Kubernetes configuration from the Terraform state and store it in a file that kubectl can read using the following `echo` command.

    ```console
    echo "$(terraform output kube_config)" > ./azurek8s
    ```
5. Verify the previous command didn't add an ASCII EOT character using the following `cat` command.

    ```console
    cat ./azurek8s
    ```

    If you see `<< EOT` at the beginning and `EOT` at the end, remove these characters from the file. Otherwise, you could receive the following error message: `error: error loading config file "./azurek8s": yaml: line 2: mapping values are not allowed in this context`.
6. Set an environment variable so kubectl picks up the correct config using the following `export` command.

    ```console
    export KUBECONFIG=./azurek8s
    ```
7. Verify the health of the cluster using the `kubectl get nodes` command.

    ```console
    kubectl get nodes
    ```

    When the Azure Linux Container Host cluster was created, monitoring was enabled to capture health metrics for both the cluster nodes and pods. These health metrics are available in the Azure portal. For more information on container health monitoring, see [Monitor Azure Kubernetes Service health](/en-us/azure/azure-monitor/insights/container-insights-overview).

    Several key values were output when you applied the Terraform execution plan. For example, the host address, Azure Linux Container Host cluster username, and Azure Linux Container Host cluster password are output.

    To view all of the output values, run `terraform output`. To view a specific output value, run `echo "$(terraform output <output_value_name>)"`.

## Clean up resources

### Delete AKS resources

When you no longer need the resources created with Terraform, you can remove them using the following steps.

1. Run the [`terraform plan`](https://developer.hashicorp.com/terraform/cli/commands/plan) command and specify the `destroy` flag.

    ```console
    terraform plan -destroy -out main.destroy.tfplan
    ```
2. Remove the execution plan using the [`terraform apply`](https://www.terraform.io/docs/commands/apply.html) command.

    ```console
    terraform apply main.destroy.tfplan
    ```

### Delete service principal

Caution

Delete the service principal you used in this demo only if you're not using it for anything else.

1. Get the object ID of the service principal using the [`az ad sp list`](/en-us/cli/azure/ad/sp#az_ad_sp_list) command

    ```azurecli
    az ad sp list --display-name "<display_name>" --query "[].{\"Object ID\":id}" --output table
    ```
2. Delete the service principal using the [`az ad sp delete`](/en-us/cli/azure/ad/sp#az_ad_sp_delete) command.

    ```azurecli
    az ad sp delete --id <service_principal_object_id>
    ```

## Troubleshoot Terraform on Azure

[Troubleshoot common problems when using Terraform on Azure](/en-us/azure/developer/terraform/troubleshoot).