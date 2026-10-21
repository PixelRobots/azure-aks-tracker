---
layout: Conceptual
title: Automate Upgrades of Kubernetes and Node Images Across Multiple Clusters using Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/update-automation
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
learn_banner_products:
- azure
description: Learn how to configure automated upgrades of Kubernetes and node images across multiple clusters by using Azure Kubernetes Fleet Manager.
ms.topic: how-to
ms.date: 2026-08-25T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.reviewer: schaffererin
ms.service: azure-kubernetes-fleet-manager
ms.custom: devx-track-terraform
zone_pivot_groups: azure-portal-azure-cli-terraform
locale: en-us
document_id: ddd73775-ab1a-37cc-048c-e453304130a5
document_version_independent_id: 04162096-b81f-4e88-643e-75b03b2e1224
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/update-automation.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/update-automation
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/update-automation.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: ab45f65e-5fc7-8c99-2b13-4d844c2fbaa3
---

# Automate Upgrades of Kubernetes and Node Images Across Multiple Clusters using Azure Kubernetes Fleet Manager | Microsoft Learn

**Applies to**: ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Keeping clusters updated in a timely and safe fashion is a key concern of platform administrators. When you adopt Azure Kubernetes Fleet Manager [Update Runs](update-orchestration) and [Strategies](update-create-update-strategy), you can use auto-upgrade profiles to automate the execution of update runs when new Kubernetes or node image versions are released.

This article explains how to use auto-upgrade profiles to automatically create and execute update runs when Azure Kubernetes Service (AKS) releases new Kubernetes or node image versions.

Note

- **Planned maintenance windows:** Auto-upgrade-triggered update runs honor [planned maintenance windows](/en-us/azure/aks/planned-maintenance) that you set at the AKS cluster level. See [planned maintenance across multiple member clusters](concepts-update-orchestration#planned-maintenance-windows) for details.
- **AKS platform-initiated upgrades:** If a member cluster stays on an unsupported Kubernetes version after the platform support grace period, AKS can upgrade it directly, outside your Fleet auto-upgrade profile, update strategy, or maintenance window. See [AKS platform-initiated upgrades](concepts-update-orchestration#aks-platform-initiated-upgrades) for ways to keep member clusters under Fleet orchestration.

## Before you begin

- Read the [conceptual overview of auto-upgrade profiles](concepts-update-orchestration#auto-upgrade-profiles-overview), which explains the configurations referenced in this guide.
- Set up a Fleet Manager with one or more member clusters. If you don't have one, follow the [quickstart](quickstart-create-fleet-and-members) to create a Fleet Manager and join AKS clusters as members.
- Configure an update strategy. Use the instructions in the [update run how-to article](update-orchestration#create-an-update-run-using-update-strategies). You need the update strategy resource identifier to use with an auto-upgrade profile when using the Azure CLI.

::: zone pivot="azure-cli"

- Set the following environment variables to use in the Azure CLI commands:

    ```bash
    export GROUP=<resource-group>
    export FLEET=<fleet-name>
    export AUTOUPGRADEPROFILE=<upgrade-profile-name>
    # Optional
    export STRATEGYID=<strategy-id>
    export CLUSTER=<aks-cluster-name>
    ```
- Install latest Azure CLI version. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- Install the latest `fleet` Azure CLI extension. Use the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command to install the extension.

    ```azurecli
    az extension add --name fleet
    ```

    Use the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command to update to the latest version of the extension.

    ```azurecli
    az extension update --name fleet
    ```

::: zone-end

::: zone pivot="terraform"

- [Install and configure Terraform](/en-us/azure/developer/terraform/quickstart-configure).
- Install latest Azure CLI version. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli). You use the Azure CLI to verify the auto-upgrade profile that Terraform creates.
- Install the latest `fleet` Azure CLI extension. Use the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command to install the extension.

    ```azurecli
    az extension add --name fleet
    ```

    Use the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command to update to the latest version of the extension.

    ```azurecli
    az extension update --name fleet
    ```
- The Terraform sample used in this article creates its own resource group and Azure Kubernetes Fleet Manager, and it doesn't join any AKS clusters as Fleet members. To exercise the resulting auto-upgrade profile against real update runs, join existing AKS clusters as members of the Fleet after you apply the sample. For more information, see the [quickstart](quickstart-create-fleet-and-members).

::: zone-end

Note

Clusters with agent pools created from [node pool snapshots](/en-us/azure/aks/node-pool-snapshot) are affected as follows based on the selected auto-upgrade channel and node image option:

- **Node image channel**: The node image upgrades to the version determined by Fleet Manager. The reference to the snapshot (`creationData`) is removed from the agent pool.
- **Stable**, **Rapid**, or **Target Kubernetes minor version**channels with node image set to:
    - **Consistent image**: The node image upgrades to the version determined by Fleet Manager. The reference to the snapshot (`creationData`) is removed from the agent pool.
    - **Latest image**: The agent pool keeps its reference to the snapshot (`creationData`), and the node image isn't modified.

For more information, see [understanding node image upgrades and snapshots](concepts-update-orchestration#understanding-node-image-upgrades-and-snapshots).

::: zone pivot="azure-cli"

## Create auto-upgrade profiles

Create auto-upgrade profiles by using the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command.

You can disable an auto-upgrade profile by including the `--disabled` flag with the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command. To reenable a disabled auto-upgrade profile, rerun the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command without the `--disabled` flag.

Note

Disabling an auto-upgrade profile doesn't affect any in-progress update runs. However, the process stops generating new update runs until you reenable the profile.

### Stable channel Kubernetes updates

Update to the latest supported Kubernetes patch release on minor version *N-1*, where *N* is the latest supported minor version.

#### Update member clusters one by one

Update member clusters sequentially by using the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command.

```azurecli
az fleet autoupgradeprofile create \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE \
  --channel Stable
```

#### Update member clusters by using an existing update strategy

Update member clusters by using an existing update strategy. Use the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command with the `--update-strategy-id` parameter set to the ID of the existing update strategy.

```azurecli
az fleet autoupgradeprofile create \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE \
  --update-strategy-id $STRATEGYID \
  --channel Stable
```

#### Update member clusters by using an existing update strategy with consistent node image

Update member clusters by using an existing update strategy, and ensure the same node image version is used in every Azure region. Use the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command with the `--node-image-selection` parameter set to `Consistent`. All member clusters run the same node image version.

```azurecli
az fleet autoupgradeprofile create \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE \
  --update-strategy-id $STRATEGYID \
  --channel Stable \
  --node-image-selection Consistent
```

#### Update member clusters by using an existing update strategy with latest node image

Update member clusters by using an existing update strategy, and ensure the latest available node image version is used for each Azure region. Use the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command with the `--node-image-selection` parameter set to `Latest`. Member clusters can run multiple node image versions.

```azurecli
az fleet autoupgradeprofile create \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE \
  --update-strategy-id $STRATEGYID \
  --channel Stable \
  --node-image-selection Latest
```

### Node image channel updates

Update nodes with a newly patched machine image that includes security fixes and bug fixes.

#### Update node images one by one

Update node images for member clusters sequentially by using the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command.

```azurecli
az fleet autoupgradeprofile create \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE \
  --channel NodeImage
```

#### Update node images by using an existing update strategy

Update node images for member clusters by using an existing update strategy. Use the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command and set the `--update-strategy-id` parameter to the ID of the existing update strategy.

```azurecli
az fleet autoupgradeprofile create \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE \
  --update-strategy-id $STRATEGYID \
  --channel NodeImage 
```

### Target Kubernetes minor version updates

Update to a defined target Kubernetes minor version by using the `--target-kubernetes-version` parameter. Supply the version in the *{major version}.{minor version}* format (for example, 1.33). Fleet Manager Auto-upgrade automatically upgrades member clusters to the latest patch release of the specified target version when the patch is available.

Important

Keep the following information in mind when using the *Target Kubernetes minor version* channel:

- You must specify the `--target-kubernetes-version` parameter. This parameter isn't supported for other auto-upgrade channels (Rapid, Stable, Node image, and Security patch).
- The long-term support (LTS) flag, `--long-term-support`, is only available when using the *Target Kubernetes minor version* channel. For other channels, set this flag to `False`.
- You can only select LTS Kubernetes versions (*N-2*) for an auto-upgrade profile with the `--long-term-support` flag. For Fleet auto-upgrade to keep working in this scenario, ensure that the clusters in the generated update run are all enabled with LTS. Non-LTS clusters cause the update run to fail when the first non-LTS cluster is encountered.
- You can't set the target Kubernetes version to a future Kubernetes version that AKS hasn't released.

#### Update member clusters to a specific Kubernetes minor version

Update member clusters to a specific Kubernetes minor version by using the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command with the `--target-kubernetes-version` parameter set to the desired version. The following example updates member clusters to Kubernetes version 1.33.

```azurecli
az fleet autoupgradeprofile create \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE \
  --channel TargetKubernetesVersion \
  --target-kubernetes-version "1.33"
```

#### Update member clusters with LTS enabled to a specific Kubernetes minor version

Update member clusters with LTS enabled to a specific Kubernetes minor version by using the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command with the `--target-kubernetes-version` parameter set to the desired version and the `--long-term-support` flag enabled. The following example updates member clusters to Kubernetes version 1.29 with LTS enabled.

```azurecli
az fleet autoupgradeprofile create \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE \
  --channel TargetKubernetesVersion \
  --target-kubernetes-version "1.29" \
  --long-term-support
```

### Security patch channel updates

Update Linux nodes with security fixes. Apply updates by using live patching when possible. Otherwise, deploy a newly patched machine image that contains security fixes.

#### Update nodes with security patches one by one

Update node images for member clusters sequentially by using the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command.

```azurecli
az fleet autoupgradeprofile create \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE \
  --channel SecurityPatch
```

#### Update nodes with security patches by using an existing update strategy

Update node images for member clusters by using an existing update strategy. Use the [`az fleet autoupgradeprofile create`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-create) command and set the `--update-strategy-id` parameter to the ID of the existing update strategy.

```azurecli
az fleet autoupgradeprofile create \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE \
  --update-strategy-id $STRATEGYID \
  --channel SecurityPatch 
```

## View auto-upgrade profiles

Auto-upgrade profiles are Fleet-level resources. They aren't attached directly to individual AKS clusters. To determine which profiles can update your AKS clusters, first list the Fleet members and confirm that the clusters are members of the Fleet.

```azurecli
az fleet member list \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --query "[].{memberName:name,clusterResourceId:clusterResourceId}" \
  --output table
```

List all auto-upgrade profiles for the Fleet using the [`az fleet autoupgradeprofile list`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-list) command.

```azurecli
az fleet autoupgradeprofile list \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --output table
```

Show a specific auto-upgrade profile for the Fleet using the [`az fleet autoupgradeprofile show`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-show) command. Review the channel, status, and `updateStrategyId` in the output.

```azurecli
az fleet autoupgradeprofile show \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE
```

If `updateStrategyId` is empty, the profile uses the **One by one** update sequence and includes the Fleet's member clusters sequentially. If `updateStrategyId` contains a resource ID, show the referenced strategy to review the stages, groups, or member selectors that determine which Fleet members the generated update runs include.

```azurecli
PROFILE_STRATEGY_ID=$(az fleet autoupgradeprofile show \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE \
  --query updateStrategyId \
  --output tsv)

if [[ -n "$PROFILE_STRATEGY_ID" ]]; then
  az fleet updatestrategy show \
    --resource-group $GROUP \
    --fleet-name $FLEET \
    --name "${PROFILE_STRATEGY_ID##*/}"
fi
```

## Delete an auto-upgrade profile

Use the [`az fleet autoupgradeprofile delete`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-delete) command to delete an existing auto-upgrade profile. After running this command, you're prompted to confirm deletion. To bypass the confirmation and immediately delete the profile, include `--yes` in the command.

```azurecli
az fleet autoupgradeprofile delete \
  --resource-group $GROUP \
  --fleet-name $FLEET \
  --name $AUTOUPGRADEPROFILE
```

Note

Deleting an auto-upgrade profile doesn't affect any in-progress update runs.

::: zone-end

::: zone pivot="terraform"

## Create auto-upgrade profiles

The Terraform sample in this section creates a resource group, an Azure Kubernetes Fleet Manager (without a hub cluster), and a Fleet auto-upgrade profile. By default, the profile uses the `Stable` channel with `Latest` node image selection and is enabled. Set the `auto_upgrade_channel`, `node_image_selection`, `auto_upgrade_disabled`, `target_kubernetes_version`, and `long_term_support` variables to match the channel and options described in the previous sections. The sample doesn't set an update strategy, so the resulting profile always uses the **One by one** update sequence.

### Review the Terraform code

Note

The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/201-aks-fleet-update-automation). View the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/201-aks-fleet-update-automation/TestRecord.md).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/terraform).

1. Create a directory to test the sample Terraform code, and make it the current directory.
2. Create a file named `providers.tf`, and insert the following code:

    ```terraform
    terraform {
      required_version = ">= 1.9.0"
    
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
          version = "~> 3.0"
        }
      }
    }
    
    provider "azurerm" {
      features {}
    }
    
    provider "azapi" {
    }
    ```
3. Create a file named `variables.tf`, and insert the following code:

    ```terraform
    variable "location" {
      type        = string
      description = "Azure region where the resource group and Fleet Manager are created."
      default     = "eastus"
    }
    
    variable "resource_group_name" {
      type        = string
      description = "Name of the resource group. If null, a unique name is generated."
      default     = null
    }
    
    variable "fleet_name" {
      type        = string
      description = "Name of the Azure Kubernetes Fleet Manager. If null, a unique name is generated."
      default     = null
    }
    
    variable "auto_upgrade_profile_name" {
      type        = string
      description = "Name of the Fleet auto-upgrade profile. If null, a unique name is generated."
      default     = null
    }
    
    variable "auto_upgrade_channel" {
      type        = string
      description = "Auto-upgrade channel used by the profile."
      default     = "Stable"
    
      validation {
        condition     = contains(["Rapid", "Stable", "NodeImage", "TargetKubernetesVersion"], var.auto_upgrade_channel)
        error_message = "Auto-upgrade channel must be one of: Rapid, Stable, NodeImage, TargetKubernetesVersion."
      }
    }
    
    variable "target_kubernetes_version" {
      type        = string
      description = "Target Kubernetes version in major.minor format, for example 1.31. Required when auto_upgrade_channel is TargetKubernetesVersion; otherwise leave null."
      default     = null
    
      validation {
        condition     = var.target_kubernetes_version == null || can(regex("^[0-9]+\\.[0-9]+$", var.target_kubernetes_version))
        error_message = "Target Kubernetes version must be in major.minor format, for example 1.31."
      }
    
      validation {
        condition     = var.auto_upgrade_channel != "TargetKubernetesVersion" || var.target_kubernetes_version != null
        error_message = "Target Kubernetes version is required when auto_upgrade_channel is TargetKubernetesVersion."
      }
    }
    
    variable "node_image_selection" {
      type        = string
      description = "Node image selection type. Latest uses the newest image per region; Consistent waits for the same image version across all member regions."
      default     = "Latest"
    
      validation {
        condition     = contains(["Latest", "Consistent"], var.node_image_selection)
        error_message = "Node image selection must be either Latest or Consistent."
      }
    }
    
    variable "auto_upgrade_disabled" {
      type        = bool
      description = "Set to true to stop the profile from creating new automatic update runs. In-progress update runs aren't cancelled."
      default     = false
    }
    
    variable "long_term_support" {
      type        = bool
      description = "Whether the profile targets long-term support Kubernetes versions. Only supported on the TargetKubernetesVersion channel."
      default     = false
    
      validation {
        condition     = !var.long_term_support || var.auto_upgrade_channel == "TargetKubernetesVersion"
        error_message = "Long-term support can only be enabled when auto_upgrade_channel is TargetKubernetesVersion."
      }
    }
    
    variable "tags" {
      type        = map(string)
      description = "Tags to apply to created resources."
      default = {
        environment = "demo"
        managed_by  = "terraform"
      }
    }
    ```
4. Create a file named `main.tf`, and insert the following code:

    ```terraform
    resource "random_string" "suffix" {
      length  = 5
      lower   = true
      numeric = true
      special = false
      upper   = false
    }
    
    locals {
      resource_group_name       = coalesce(var.resource_group_name, "rg-fleet-update-${random_string.suffix.result}")
      fleet_name                = coalesce(var.fleet_name, "fleet-update-${random_string.suffix.result}")
      auto_upgrade_profile_name = coalesce(var.auto_upgrade_profile_name, "stable-profile-${random_string.suffix.result}")
    
      # targetKubernetesVersion is only valid on the TargetKubernetesVersion channel.
      auto_upgrade_properties = merge(
        {
          channel         = var.auto_upgrade_channel
          disabled        = var.auto_upgrade_disabled
          longTermSupport = var.long_term_support
          nodeImageSelection = {
            type = var.node_image_selection
          }
        },
        var.auto_upgrade_channel == "TargetKubernetesVersion" ? {
          targetKubernetesVersion = var.target_kubernetes_version
        } : {}
      )
    }
    
    resource "azurerm_resource_group" "example" {
      name     = local.resource_group_name
      location = var.location
      tags     = var.tags
    }
    
    resource "azurerm_kubernetes_fleet_manager" "example" {
      name                = local.fleet_name
      location            = azurerm_resource_group.example.location
      resource_group_name = azurerm_resource_group.example.name
      tags                = var.tags
    }
    
    # autoUpgradeProfiles is only available on the preview API version, which requires schema validation to be disabled.
    resource "azapi_resource" "auto_upgrade_profile" {
      type                      = "Microsoft.ContainerService/fleets/autoUpgradeProfiles@2025-04-01-preview"
      name                      = local.auto_upgrade_profile_name
      parent_id                 = azurerm_kubernetes_fleet_manager.example.id
      schema_validation_enabled = false
    
      body = {
        properties = local.auto_upgrade_properties
      }
    }
    ```
5. Create a file named `outputs.tf`, and insert the following code:

    ```terraform
    output "resource_group_name" {
      description = "Name of the created resource group."
      value       = azurerm_resource_group.example.name
    }
    
    output "fleet_manager_name" {
      description = "Name of the Azure Kubernetes Fleet Manager."
      value       = azurerm_kubernetes_fleet_manager.example.name
    }
    
    output "fleet_manager_id" {
      description = "Resource ID of the Azure Kubernetes Fleet Manager."
      value       = azurerm_kubernetes_fleet_manager.example.id
    }
    
    output "auto_upgrade_profile_name" {
      description = "Name of the Fleet auto-upgrade profile."
      value       = azapi_resource.auto_upgrade_profile.name
    }
    
    output "auto_upgrade_profile_id" {
      description = "Resource ID of the Fleet auto-upgrade profile."
      value       = azapi_resource.auto_upgrade_profile.id
    }
    ```
6. Copy the sample's `terraform.tfvars.example` file to `terraform.tfvars` in the same directory, and then edit the values to match the auto-upgrade channel, node image selection, and other options you want.

    ```console
    cp terraform.tfvars.example terraform.tfvars
    ```

### Initialize, validate, and apply the configuration

Run [terraform init](https://developer.hashicorp.com/terraform/cli/commands/init) to initialize the Terraform deployment. This command downloads the Azure providers required to manage your Azure resources.

```console
terraform init
```

Run [terraform fmt](https://developer.hashicorp.com/terraform/cli/commands/fmt) to format the configuration files consistently.

```console
terraform fmt
```

Run [terraform validate](https://developer.hashicorp.com/terraform/cli/commands/validate) to confirm that the configuration files are syntactically valid.

```console
terraform validate
```

Run [terraform plan](https://developer.hashicorp.com/terraform/cli/commands/plan) to create an execution plan.

```console
terraform plan -out main.tfplan
```

Run [terraform apply](https://developer.hashicorp.com/terraform/cli/commands/apply) to apply the execution plan to your cloud infrastructure.

```console
terraform apply main.tfplan
```

## View auto-upgrade profiles

Get the resource group, Fleet Manager, and auto-upgrade profile names from the Terraform outputs.

```console
resource_group_name=$(terraform output -raw resource_group_name)
fleet_manager_name=$(terraform output -raw fleet_manager_name)
auto_upgrade_profile_name=$(terraform output -raw auto_upgrade_profile_name)
```

Show the auto-upgrade profile's channel, status, and update sequence by using the [`az fleet autoupgradeprofile show`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-show) command.

```azurecli
az fleet autoupgradeprofile show \
  --resource-group $resource_group_name \
  --fleet-name $fleet_manager_name \
  --name $auto_upgrade_profile_name
```

The sample doesn't set an update strategy, so `updateStrategyId` in the output is empty and the profile updates the Fleet's member clusters sequentially using the **One by one** update sequence. List the current Fleet members with the following command.

```azurecli
az fleet member list \
  --resource-group $resource_group_name \
  --fleet-name $fleet_manager_name \
  --output table
```

## Delete an auto-upgrade profile

Run [terraform plan](https://developer.hashicorp.com/terraform/cli/commands/plan) with the `-destroy` flag to create a destroy execution plan.

```console
terraform plan -destroy -out main.destroy.tfplan
```

Run [terraform apply](https://developer.hashicorp.com/terraform/cli/commands/apply) to apply the destroy plan.

```console
terraform apply main.destroy.tfplan
```

Warning

This command deletes the auto-upgrade profile, the Azure Kubernetes Fleet Manager, and the resource group created by this sample, not just the profile. If you joined AKS clusters as members of the Fleet, remove them as Fleet members first. Confirm the resource group doesn't contain other resources you want to keep before you run this command.

::: zone-end

::: zone pivot="azure-portal"

## Create auto-upgrade profiles

# [Stable channel](#tab/stable)
Update to the latest supported Kubernetes patch release on minor version *N-1*, where *N* is the latest supported minor version.

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multicluster update** &gt; **Auto-upgrade profiles** &gt; **+ Create**.
3. On **Create an auto-upgrade profile**, configure the following options:

    - Under **Auto-upgrade details**:
        - **Auto-upgrade profile name**: Enter a name for the auto-upgrade profile.
        - **Status**: Select **Enabled** or **Disabled**. Disabled auto-upgrade profiles don't trigger when new versions are released.
        - **Update sequence**: Select **Stages** or **One by one**.
    - Under **Auto-upgrade triggers**:
        - **Channel**: Select **Stable**.
        - **Node image**: Select **Latest image** or **Consistent image**.
    - Under **Strategy details**:
        - If you selected an **Update sequence** using **Stages**, select an existing strategy or create a new one.
4. Select **Create** to create the auto-upgrade profile.

    [![Screenshot of the Azure Kubernetes Fleet Manager Azure portal pane for creating auto-upgrade profile using the Stable channel.](media/auto-upgrade/create-auto-upgrade-profile-stable.png)](media/auto-upgrade/create-auto-upgrade-profile-stable.png#lightbox)

# [Rapid channel](#tab/rapid)
Update to the latest supported Kubernetes patch release on the latest (*N*) minor version.

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multicluster update** &gt; **Auto-upgrade profiles** &gt; **+ Create**.
3. On **Create an auto-upgrade profile**, configure the following options:

    - Under **Auto-upgrade details**:
        - **Auto-upgrade profile name**: Enter a name for the auto-upgrade profile.
        - **Status**: Select **Enabled** or **Disabled**. Disabled auto-upgrade profiles don't trigger when new versions are released.
        - **Update sequence**: Select **Stages** or **One by one**.
    - Under **Auto-upgrade triggers**:
        - **Channel**: Select **Rapid**.
        - **Node image**: Select **Latest image** or **Consistent image**.
    - Under **Strategy details**:
        - If you selected an **Update sequence** using **Stages**, select an existing strategy or create a new one.
4. Select **Create** to create the auto-upgrade profile.

    [![Screenshot of the Azure Kubernetes Fleet Manager Azure portal pane for creating auto-upgrade profile using the Rapid channel.](media/auto-upgrade/create-auto-upgrade-profile-rapid.png)](media/auto-upgrade/create-auto-upgrade-profile-rapid.png#lightbox)

# [Node image channel](#tab/node-image)
Update nodes with a newly patched machine image that includes security fixes and bug fixes.

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multicluster update** &gt; **Auto-upgrade profiles** &gt; **+ Create**.
3. On **Create an auto-upgrade profile**, configure the following options:

    - Under **Auto-upgrade details**:
        - **Auto-upgrade profile name**: Enter a name for the auto-upgrade profile.
        - **Status**: Select **Enabled** or **Disabled**. Disabled auto-upgrade profiles don't trigger when new versions are released.
        - **Update sequence**: Select **Stages** or **One by one**.
    - Under **Auto-upgrade triggers**:
        - **Channel**: Select **Node image**.
4. Select **Create** to create the auto-upgrade profile.

    [![Screenshot of the Azure Kubernetes Fleet Manager Azure portal pane for creating auto-upgrade profile using the Node image channel.](media/auto-upgrade/create-auto-upgrade-profile-node-image.png)](media/auto-upgrade/create-auto-upgrade-profile-node-image.png#lightbox)

# [Target Kubernetes minor](#tab/target-kubernetes-minor-version)
Update to a defined target Kubernetes minor version. Fleet Manager Auto-upgrade automatically upgrades member clusters to the latest patch release of the specified target version when the patch is available. Clusters only upgrade patches in the selected minor. At end of a minor version's support, you must manually update to the next desired minor version.

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multicluster update** &gt; **Auto-upgrade profiles** &gt; **+ Create**.
3. On **Create an auto-upgrade profile**, configure the following options:

    - Under **Auto-upgrade details**:
        - **Auto-upgrade profile name**: Enter a name for the auto-upgrade profile.
        - **Status**: Select **Enabled** or **Disabled**. Disabled auto-upgrade profiles don't trigger when new versions are released.
        - **Update sequence**: Select **Stages** or **One by one**.
    - Under **Auto-upgrade triggers**:
        - **Channel**: Select **Target Kubernetes minor version**.
        - **Allow LTS minor versions**: Select whether to allow Kubernetes minor versions available only for AKS long term support (LTS) clusters.
        - **Target Kubernetes minor version**: Select the Kubernetes minor version trigger. Clusters at a lower minor are updated to it first, then only patch updates are applied.
        - **Node image**: Select **Latest image** or **Consistent image**.
    - Under **Strategy details**:
        - If you selected an **Update sequence** using **Stages**, select an existing strategy or create a new one.
4. Select **Create** to create the auto-upgrade profile.

    [![Screenshot of the Azure Kubernetes Fleet Manager Azure portal pane for creating auto-upgrade profile using the Target Kubernetes minor version channel.](media/auto-upgrade/create-auto-upgrade-profile-kubernetes-minor.png)](media/auto-upgrade/create-auto-upgrade-profile-kubernetes-minor.png#lightbox)

# [Security patch (preview)](#tab/node-security-patch)
Update Linux nodes with just security fixes, by using either live patching or a prepatched node image.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multicluster update** &gt; **Auto-upgrade profiles** &gt; **+ Create**.
3. On **Create an auto-upgrade profile**, configure the following options:

    - Under **Auto-upgrade details**:
        - **Auto-upgrade profile name**: Enter a name for the auto-upgrade profile.
        - **Status**: Select **Enabled** or **Disabled**. Disabled auto-upgrade profiles don't trigger when new versions are released.
        - **Update sequence**: Select **Stages** or **One by one**.
    - Under **Auto-upgrade triggers**:
        - **Channel**: Select **Security patch (preview)**.
4. Select **Create** to create the auto-upgrade profile.

    [![Screenshot of the Azure Kubernetes Fleet Manager Azure portal pane for creating auto-upgrade profile using the Node image channel.](media/auto-upgrade/create-auto-upgrade-profile-security-patch.png)](media/auto-upgrade/create-auto-upgrade-profile-security-patch.png#lightbox)

---

## View auto-upgrade profiles

Auto-upgrade profiles are Fleet-level resources. They aren't attached directly to individual AKS clusters. To determine which profiles can update your AKS clusters, confirm that the clusters are members of the Fleet, and then review the Fleet's profiles and their update sequences.

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, select **Fleet members**, and confirm that your AKS clusters appear in the member list.
3. Under **Settings**, select **Multicluster update** &gt; **Auto-upgrade profiles**.
4. Select an auto-upgrade profile to view its channel, status, and update sequence.
5. If the update sequence is **One by one**, the profile includes the Fleet's member clusters sequentially. If the update sequence uses **Stages**, review the associated strategy's stages, groups, and member selectors to determine which Fleet members the generated update runs include.

## Delete an auto-upgrade profile

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multicluster update** &gt; **Auto-upgrade profiles**.
3. Select the profile you want to delete, and then select **Delete** &gt; **Yes** to confirm.

Note

Deleting an auto-upgrade profile doesn't affect any in-progress update runs.

::: zone-end

## Validate auto-upgrades

Auto-upgrades happen only when new Kubernetes or node images are available. When auto-upgrade is triggered, a linked update run is created, so you can use [manage update run](update-orchestration#manage-an-update-run) to see the results of the auto-upgrade.

You can also check your existing versions as a baseline.

Get the current Kubernetes version for a member cluster by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command with the `--query` parameter to filter the output for the `currentKubernetesVersion` property.

```azurecli
az aks show \
  --resource-group $GROUP \
  --name $CLUSTER \
  --query currentKubernetesVersion
```

Get the current node image version for a member cluster by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command with the `--query` parameter to filter the output for the `nodeImageVersion` property.

```azurecli
az aks show \
  --resource-group $GROUP \
  --name $CLUSTER \
  --query "agentPoolProfiles[].{name:name,mode:mode, nodeImageVersion:nodeImageVersion, osSku:osSku, osType:osType}"
```

When update runs finish, you can rerun these commands and view the updated versions that are deployed.

## Generate an update run from an auto-upgrade profile

After you create an auto-upgrade profile, some time might pass before a new Kubernetes or node image version triggers auto-upgrade to create and execute an update run. Auto-upgrade allows you to generate a new update run at any time by using the [`az fleet autoupgradeprofile generate-update-run`](/en-us/cli/azure/fleet/autoupgradeprofile#az-fleet-autoupgradeprofile-generate-update-run) command. The resulting update run is based on the current AKS-published Kubernetes or node image version.

For more information about creating an on-demand update run from an auto-upgrade profile, see [Generate an update run from an auto-upgrade profile](update-orchestration#generate-an-update-run-from-an-auto-upgrade-profile).