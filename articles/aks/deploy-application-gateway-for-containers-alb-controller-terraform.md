---
layout: Conceptual
title: 'Quickstart: Deploy Azure ALB Controller on AKS using Terraform - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/deploy-application-gateway-for-containers-alb-controller-terraform
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
description: Use Terraform to deploy an AKS cluster, enable the Application Gateway for Containers ALB Controller add-on, and verify the Gateway API installation.
author: schaffererin
ms.author: schaffererin
ms.topic: quickstart
ms.custom: devx-track-terraform
ms.date: 2026-08-31T00:00:00.0000000Z
content_well_notification:
- AI-contribution
ai-usage: ai-assisted
locale: en-us
document_id: 19069b46-df3d-7e5f-ad72-e6355d3076f7
document_version_independent_id: 629bef80-ca0e-09ea-8797-9d66aa5fc9a4
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/deploy-application-gateway-for-containers-alb-controller-terraform.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/deploy-application-gateway-for-containers-alb-controller-terraform
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/deploy-application-gateway-for-containers-alb-controller-terraform.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 5ba20a44-cb71-3eca-7d37-bcde60f706f1
---

# Quickstart: Deploy Azure ALB Controller on AKS using Terraform - Azure Kubernetes Service | Microsoft Learn

Application Gateway for Containers is a managed layer 7 load balancing and ingress service for Kubernetes workloads. The ALB Controller is the Kubernetes controller that runs in your Azure Kubernetes Service (AKS) cluster and translates Gateway API and Ingress API configuration into Application Gateway for Containers load balancing rules. In this quickstart, you use Terraform to deploy an AKS cluster, enable the Application Gateway for Containers ALB Controller add-on, and install the managed Gateway API implementation that the add-on requires.

[Terraform](https://www.terraform.io) enables the definition, preview, and deployment of cloud infrastructure. Using Terraform, you create configuration files using [HCL syntax](https://developer.hashicorp.com/terraform/language/syntax/configuration). The HCL syntax allows you to specify the cloud provider - such as Azure - and the elements that make up your cloud infrastructure. After you create your configuration files, you create an *execution plan* that allows you to preview your infrastructure changes before they're deployed. Once you verify the changes, you apply the execution plan to deploy the infrastructure.

In this article, you learn how to:

- Create a random value for the resource group and AKS cluster names using [random_pet](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet).
- Access the AzAPI provider's Azure subscription context using [azapi_client_config](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/client_config).
- Register the `ApplicationLoadBalancerPreview` and `ManagedGatewayAPIPreview` subscription features using [azapi_resource_action](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource_action).
- Pause while the preview feature registrations propagate using [time_sleep](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep).
- Re-register the `Microsoft.ContainerService` resource provider using [azapi_resource_action](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource_action).
- Create an Azure resource group using [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group).
- Create an AKS cluster using [azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster).
- Enable the Application Gateway for Containers ALB Controller add-on and install the managed Gateway API using [azapi_update_resource](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/update_resource).

## Prerequisites

- [Install and configure Terraform](/en-us/azure/developer/terraform/quickstart-configure).
- An Azure account with an active subscription and permission to create AKS resources and assign roles in that subscription. If you don't have an Azure account, [create one for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Terraform version 1.6.0 or later.
- [Azure CLI](/en-us/cli/azure/install-azure-cli) installed, and signed in with `az login`.
- [`kubectl`](https://kubernetes.io/releases/download/) installed.
- This quickstart deploys a new AKS cluster, so you don't need an existing cluster before you begin. The cluster that Terraform creates uses Azure CNI networking. AKS Automatic clusters aren't supported for this scenario.
- The `Microsoft.ContainerService` and `Microsoft.ServiceNetworking` resource providers registered in your subscription. For more information, see [Azure resource providers and types](/en-us/azure/azure-resource-manager/management/resource-providers-and-types).
- A supported [Azure region for Application Gateway for Containers](/en-us/azure/application-gateway/for-containers/overview#supported-regions).
- The Application Gateway for Containers ALB Controller add-on and the AKS-managed Gateway API installation are in preview. Preview features are governed by the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/).
- The `ApplicationLoadBalancerPreview` and `ManagedGatewayAPIPreview` preview features registered on the `Microsoft.ContainerService` resource provider in your subscription. Feature registration is subscription-wide, so if another cluster in the subscription already registered these features, you don't need to register them again. Registration is asynchronous and can take several minutes to propagate. The Terraform configuration in this quickstart registers the features and waits for the registration to propagate, but you can also register them ahead of time:

    ```azurecli
    az feature register --namespace Microsoft.ContainerService --name ApplicationLoadBalancerPreview
    az feature register --namespace Microsoft.ContainerService --name ManagedGatewayAPIPreview
    az provider register --namespace Microsoft.ContainerService
    ```

## Implement the Terraform code

Note

The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-alb-controller).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/terraform).

1. Create a directory to test the sample Terraform code and set it as the current directory.
2. Create a file named `main.tf` and add the following code:

    ```terraform
    terraform {
      required_version = ">= 1.6.0"
    
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
        azapi = {
          source  = "Azure/azapi"
          version = "~> 2.0"
        }
        random = {
          source  = "hashicorp/random"
          version = "~> 3.6"
        }
        time = {
          source  = "hashicorp/time"
          version = "~> 0.12"
        }
      }
    }
    
    provider "azurerm" {
      features {}
    }
    
    provider "azapi" {}
    
    data "azapi_client_config" "current" {}
    
    resource "random_pet" "suffix" {
      length = 2
    }
    
    locals {
      resource_group_name = "rg-agfc-alb-${random_pet.suffix.id}"
      aks_name            = "aks-alb-${random_pet.suffix.id}"
      location            = "eastus"
      # The ALB Controller add-on and the managed Gateway API installation are in preview
      # and require these subscription level feature registrations.
      preview_features = [
        "ApplicationLoadBalancerPreview",
        "ManagedGatewayAPIPreview",
      ]
    }
    
    resource "azapi_resource_action" "register_preview_features" {
      for_each = toset(local.preview_features)
    
      type        = "Microsoft.Features/featureProviders/subscriptionFeatureRegistrations@2021-07-01"
      resource_id = "${data.azapi_client_config.current.subscription_resource_id}/providers/Microsoft.Features/featureProviders/Microsoft.ContainerService/subscriptionFeatureRegistrations/${each.value}"
      method      = "PUT"
      body = {
        properties = {}
      }
    }
    
    # Feature registration is asynchronous, wait before refreshing the resource provider.
    resource "time_sleep" "wait_for_feature_registration" {
      create_duration = "10m"
    
      depends_on = [azapi_resource_action.register_preview_features]
    }
    
    # Re-registering the resource provider propagates the registered preview features.
    resource "azapi_resource_action" "register_container_service" {
      type        = "Microsoft.Resources/providers@2021-04-01"
      resource_id = "${data.azapi_client_config.current.subscription_resource_id}/providers/Microsoft.ContainerService"
      action      = "register"
      method      = "POST"
    
      depends_on = [time_sleep.wait_for_feature_registration]
    }
    
    resource "azurerm_resource_group" "rg" {
      name     = local.resource_group_name
      location = local.location
    }
    
    resource "azurerm_kubernetes_cluster" "aks" {
      name                      = local.aks_name
      location                  = azurerm_resource_group.rg.location
      resource_group_name       = azurerm_resource_group.rg.name
      dns_prefix                = local.aks_name
      oidc_issuer_enabled       = true
      workload_identity_enabled = true
    
      default_node_pool {
        name       = "systempool"
        node_count = 1
        vm_size    = "Standard_D2s_v7"
    
    upgrade_settings {
         drain_timeout_in_minutes      = 0
         max_surge                     = "10%"
         node_soak_duration_in_minutes = 0
       }
      }
    
      identity {
        type = "SystemAssigned"
      }
    
      network_profile {
        network_plugin    = "azure"
        network_policy    = "azure"
        load_balancer_sku = "standard"
      }
    }
    
    resource "azapi_update_resource" "enable_alb_controller_addon" {
      type        = "Microsoft.ContainerService/managedClusters@2025-09-02-preview"
      resource_id = azurerm_kubernetes_cluster.aks.id
      body = {
        properties = {
          ingressProfile = {
            applicationLoadBalancer = {
              enabled = true
            }
            gatewayAPI = {
              installation = "Standard"
            }
          }
        }
      }
    
      # Keep retrying while the preview feature registrations propagate to the resource provider.
      retry = {
        error_message_regex  = ["PreviewFeatureNotRegistered"]
        interval_seconds     = 60
        max_interval_seconds = 300
      }
    
      timeouts {
        create = "90m"
        update = "90m"
      }
    
      depends_on = [azapi_resource_action.register_container_service]
    }
    
    output "resource_group_name" {
      value = azurerm_resource_group.rg.name
    }
    
    output "aks_cluster_name" {
      value = azurerm_kubernetes_cluster.aks.name
    }
    
    output "aks_cluster_id" {
      value = azurerm_kubernetes_cluster.aks.id
    }
    ```

Note

The configuration registers the `ApplicationLoadBalancerPreview` and `ManagedGatewayAPIPreview` subscription features, waits for the registrations to propagate, and then re-registers the `Microsoft.ContainerService` resource provider so the propagated features take effect. The resource that enables the add-on retries automatically while the resource provider still reports the features as unregistered. Because of this registration and retry sequence, the first `terraform apply` can take considerably longer than a typical AKS deployment.

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

1. Get the resource group name, AKS cluster name, and AKS cluster resource ID from the Terraform state.

    ```console
    resource_group_name=$(terraform output -raw resource_group_name)
    aks_cluster_name=$(terraform output -raw aks_cluster_name)
    aks_cluster_id=$(terraform output -raw aks_cluster_id)
    ```
2. Get the AKS cluster credentials by using the [az aks get-credentials](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $resource_group_name --name $aks_cluster_name
    ```
3. Confirm the AKS `ingressProfile` shows the Application Gateway for Containers ALB Controller add-on as enabled. Query the same preview API version that the Terraform configuration used to enable the add-on.

    ```azurecli
    az rest --method get --uri "https://management.azure.com${aks_cluster_id}?api-version=2025-09-02-preview" --query "properties.ingressProfile"
    ```

    The output shows `applicationLoadBalancer.enabled` set to `true` and `gatewayAPI.installation` set to `Standard`.
4. Verify the ALB Controller pods are running in the `kube-system` namespace.

    ```console
    kubectl get pods -n kube-system | grep alb-controller
    ```

    You should see two `alb-controller` pods in a `Running` state.
5. Verify the `azure-alb-external` GatewayClass is installed on your cluster.

    ```console
    kubectl get gatewayclass azure-alb-external -o yaml
    ```

    The output shows a condition of type `Accepted` with the message `Valid GatewayClass`, which confirms the ALB Controller manages the `azure-alb-external` GatewayClass.

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

Running `terraform destroy` removes the resource group and the AKS cluster that Terraform created. It doesn't remove the `ApplicationLoadBalancerPreview` and `ManagedGatewayAPIPreview` feature registrations, or the `Microsoft.ContainerService` resource provider registration, because those registrations are subscription-wide settings that Terraform doesn't manage as destroyable resources. Before you unregister a preview feature manually, verify that no other clusters or workloads in your subscription still depend on it.

## Troubleshoot Terraform on Azure

[Troubleshoot common problems when using Terraform on Azure](/en-us/azure/developer/terraform/troubleshoot).