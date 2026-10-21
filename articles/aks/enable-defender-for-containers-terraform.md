---
layout: Conceptual
title: 'Quickstart: Use Terraform for Defender for Containers on Azure - Azure Kubernetes Service | Microsoft Learn'
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/enable-defender-for-containers-terraform
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
description: Use Terraform to deploy an AKS cluster, enable Microsoft Defender for Containers at the subscription level, and verify runtime protection.
author: schaffererin
ms.author: schaffererin
ms.topic: quickstart
ms.custom: devx-track-terraform
ms.date: 2026-08-31T00:00:00.0000000Z
content_well_notification:
- AI-contribution
ai-usage: ai-assisted
locale: en-us
document_id: cdb6a918-8b27-f369-4e56-05ba27c3a235
document_version_independent_id: d17fb683-a6ab-7653-2dd1-826cabb7e1d8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/enable-defender-for-containers-terraform.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/enable-defender-for-containers-terraform
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/enable-defender-for-containers-terraform.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 3b79d37e-6467-9d1a-798d-988de38f85cc
---

# Quickstart: Use Terraform for Defender for Containers on Azure - Azure Kubernetes Service | Microsoft Learn

Microsoft Defender for Containers is a cloud workload protection plan in Microsoft Defender for Cloud that provides security monitoring, vulnerability assessment, and threat detection for your Kubernetes environments. In this quickstart, you use Terraform to enable the Defender for Containers plan at the subscription level and deploy an Azure Kubernetes Service (AKS) cluster with Microsoft Defender security monitoring connected to a Log Analytics workspace.

[Terraform](https://www.terraform.io) enables the definition, preview, and deployment of cloud infrastructure. Using Terraform, you create configuration files using [HCL syntax](https://developer.hashicorp.com/terraform/language/syntax/configuration). The HCL syntax allows you to specify the cloud provider - such as Azure - and the elements that make up your cloud infrastructure. After you create your configuration files, you create an *execution plan* that allows you to preview your infrastructure changes before they're deployed. Once you verify the changes, you apply the execution plan to deploy the infrastructure.

In this article, you learn how to:

- Access the current subscription context using [azurerm_client_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config).
- Create an Azure resource group using [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group).
- Create a Log Analytics workspace for AKS security monitoring data using [azurerm_log_analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace).
- Enable the Defender for Containers plan at the subscription level using [azurerm_security_center_subscription_pricing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing).
- Create an AKS cluster with Azure Policy, OIDC issuer, and Microsoft Defender security monitoring enabled using [azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster).

Important

The `azurerm_security_center_subscription_pricing` resource sets the Defender for Containers plan for the entire Azure subscription, not just the AKS cluster created in this quickstart. Enabling the Standard tier affects all supported container resources in the subscription, including other AKS clusters and container registries, and can increase your Azure bill. Review the [Defender for Containers pricing](https://azure.microsoft.com/pricing/details/defender-for-cloud/) before you apply this configuration in a subscription that you share with other workloads.

## Prerequisites

- [Install and configure Terraform](/en-us/azure/developer/terraform/quickstart-configure).
- Terraform version 1.5.0 or later.
- An Azure account with an active subscription. If you don't have an Azure account, [create one for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- [Azure CLI](/en-us/cli/azure/install-azure-cli) installed, and signed in using `az login`.
- Permission to create resource groups, Log Analytics workspaces, and AKS clusters in the target subscription (for example, the [Contributor](/en-us/azure/role-based-access-control/built-in-roles/general#contributor) role).
- Permission to modify Microsoft Defender for Cloud pricing plans at the subscription scope. You must be assigned the [Security Admin](/en-us/azure/defender-for-cloud/permissions#roles-and-allowed-actions), Owner, or Contributor role on the subscription. For more information, see [User roles and permissions in Defender for Cloud](/en-us/azure/defender-for-cloud/permissions).

## Implement the Terraform code

Note

The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-defender-containers). You can view the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-defender-containers/TestRecord.md).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/terraform).

1. Create a directory to test the sample Terraform code and set it as the current directory.
2. Create a file named `main.tf` and add the following code:

    ```terraform
    terraform {
      required_version = ">= 1.5.0"
    
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
    
    data "azurerm_client_config" "current" {}
    
    locals {
      suffix   = substr(replace(data.azurerm_client_config.current.subscription_id, "-", ""), 0, 6)
      location = "eastus"
    }
    
    resource "azurerm_resource_group" "example" {
      name     = "rg-aks-defender-${local.suffix}"
      location = local.location
    }
    
    resource "azurerm_log_analytics_workspace" "example" {
      name                = "law-aks-defender-${local.suffix}"
      location            = azurerm_resource_group.example.location
      resource_group_name = azurerm_resource_group.example.name
      sku                 = "PerGB2018"
      retention_in_days   = 30
    }
    
    resource "azurerm_security_center_subscription_pricing" "containers" {
      tier          = "Standard"
      resource_type = "Containers"
    
      extension {
        name = "AgentlessVmScanning"
        additional_extension_properties = {
          ExclusionTags = jsonencode([])
        }
      }
    
      extension {
        name = "ContainerSensor"
        additional_extension_properties = {
          AntiMalwareEnabled    = "True"
          AutoProvisioning      = "True"
          InstallationMethod    = "AKSAddon"
          SecurityGatingEnabled = "True"
        }
      }
    
      extension {
        name = "AgentlessDiscoveryForKubernetes"
      }
    
      extension {
        name = "ContainerRegistriesVulnerabilityAssessments"
      }
    
      extension {
        name = "ContainerIntegrityContribution"
      }
    }
    
    resource "azurerm_kubernetes_cluster" "example" {
      name                              = "aks-defender-${local.suffix}"
      location                          = azurerm_resource_group.example.location
      resource_group_name               = azurerm_resource_group.example.name
      dns_prefix                        = "aks-defender-${local.suffix}"
      role_based_access_control_enabled = true
      azure_policy_enabled              = true
      oidc_issuer_enabled               = true
    
      default_node_pool {
        name       = "system"
        node_count = 1
        vm_size    = "Standard_D2s_v3"
    
        upgrade_settings {
          drain_timeout_in_minutes      = 0
          max_surge                     = "10%"
          node_soak_duration_in_minutes = 0
        }
      }
    
      identity {
        type = "SystemAssigned"
      }
    
      microsoft_defender {
        log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      }
    
      tags = {
        Environment = "Test"
        Purpose     = "DefenderForContainers"
      }
    
      depends_on = [
        azurerm_security_center_subscription_pricing.containers
      ]
    }
    
    output "resource_group_name" {
      value = azurerm_resource_group.example.name
    }
    
    output "aks_cluster_name" {
      value = azurerm_kubernetes_cluster.example.name
    }
    
    output "log_analytics_workspace_id" {
      value = azurerm_log_analytics_workspace.example.id
    }
    ```

Note

The configuration enables the following Defender for Containers extensions on the `Containers` pricing plan:

- **AgentlessVmScanning**: Performs agentless vulnerability scanning of AKS node disks without installing an agent on the nodes.
- **ContainerSensor**: Deploys the Defender sensor to AKS nodes. The `AntiMalwareEnabled`, `AutoProvisioning`, `InstallationMethod`, and `SecurityGatingEnabled` properties enable malware protection, automatic provisioning of the sensor, installation through the AKS security profile add-on, and security gating for the sensor.
- **AgentlessDiscoveryForKubernetes**: Discovers Kubernetes cluster configuration and workload data without requiring an agent.
- **ContainerRegistriesVulnerabilityAssessments**: Scans container images in Azure Container Registry for known vulnerabilities.
- **ContainerIntegrityContribution**: Monitors runtime configuration drift and integrity of running containers.

The AKS cluster resource also enables Azure Policy (`azure_policy_enabled`) for at-scale governance of the cluster, the OIDC issuer (`oidc_issuer_enabled`) for workload identity federation, and the Microsoft Defender security profile (`microsoft_defender`) that connects the cluster to the Log Analytics workspace for security monitoring.

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

1. Get the resource group name, AKS cluster name, and Log Analytics workspace ID from the Terraform state.

    ```console
    resource_group_name=$(terraform output -raw resource_group_name)
    aks_cluster_name=$(terraform output -raw aks_cluster_name)
    log_analytics_workspace_id=$(terraform output -raw log_analytics_workspace_id)
    ```
2. Verify that the Defender for Containers plan is set to the Standard tier at the subscription level by using the [az security pricing show](/en-us/cli/azure/security/pricing#az-security-pricing-show) command.

    ```azurecli
    az security pricing show -n Containers --query "{name:name, tier:pricingTier}" -o table
    ```

    The output shows the `Containers` plan with the `Standard` pricing tier.
3. Check the extensions enabled on the plan by using the [az security pricing show](/en-us/cli/azure/security/pricing#az-security-pricing-show) command.

    ```azurecli
    az security pricing show -n Containers --query "extensions[].{name:name, isEnabled:isEnabled}" -o table
    ```

    The output lists the `AgentlessVmScanning`, `ContainerSensor`, `AgentlessDiscoveryForKubernetes`, `ContainerRegistriesVulnerabilityAssessments`, and `ContainerIntegrityContribution` extensions as enabled.
4. Confirm that Azure Policy, the OIDC issuer, and Microsoft Defender security monitoring are enabled on the AKS cluster by using the [az aks show](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show \
      --resource-group $resource_group_name \
      --name $aks_cluster_name \
      --query "{azurePolicy:addonProfiles.azurepolicy.enabled, oidc:oidcIssuerProfile.enabled, defender:securityProfile.defender}" \
      -o json
    ```

    The output shows `azurePolicy` and `oidc` set to `true`, and a `defender` object with `securityMonitoring.enabled` set to `true` and `logAnalyticsWorkspaceResourceId` set to the ID of the Log Analytics workspace that Terraform created.
5. Confirm that the Log Analytics workspace exists and is linked to the AKS cluster by using the [az monitor log-analytics workspace show](/en-us/cli/azure/monitor/log-analytics/workspace#az-monitor-log-analytics-workspace-show) command.

    ```azurecli
    az monitor log-analytics workspace show --ids $log_analytics_workspace_id --query "{name:name, provisioningState:provisioningState}" -o table
    ```

    The output shows the workspace name and a `provisioningState` of `Succeeded`.

## Clean up resources

Important

The `azurerm_security_center_subscription_pricing` resource manages the Defender for Containers plan for the entire subscription. When Terraform destroys this resource, it resets the `Containers` pricing tier back to `Free` for the whole subscription. This action disables Defender for Containers protection and its extensions for every AKS cluster and container registry in that subscription, not only the resources created in this quickstart. Confirm that no other clusters or workloads in the subscription depend on Defender for Containers protection before you continue.

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