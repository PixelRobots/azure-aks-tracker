---
layout: Conceptual
title: Define reuseable update strategies for multi-clusters updates using Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/update-create-update-strategy
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
description: See how you can define staged update strategies that can be reused across multiple update runs and auto-upgrade profiles in Azure Kubernetes Fleet Manager.
ms.topic: how-to
ms.date: 2026-06-15T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.custom: devx-track-terraform
zone_pivot_groups: azure-portal-azure-cli-terraform
locale: en-us
document_id: b5a1f6d2-833d-0a16-4e19-4bcb90cc07eb
document_version_independent_id: f3eb6043-c8de-8795-ffbf-51048b873169
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/update-create-update-strategy.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: kubernetes-fleet/update-create-update-strategy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/update-create-update-strategy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 02751246-66e0-72a1-f82a-9a6d8836c3bc
---

# Define reuseable update strategies for multi-clusters updates using Azure Kubernetes Fleet Manager | Microsoft Learn

**Applies to:** ✔️ Fleet Manager ✔️ Fleet Manager with hub cluster

Administrators can control the sequence of updates to Fleet-managed clusters by defining a series of stages and groups. They can configure when approvals and pauses should occur within those stages and groups. The entire configuration can be saved as an update strategy which can be managed independently of update runs or auto-upgrades, allowing strategies to be reused as required.

This article covers how to define update strategies using groups and stages.

[![A diagram showing an example update strategy containing two update stages. Each update stage contains two update groups. Each update group contains two member clusters.](media/conceptual-update-orchestration-inline.png)](media/conceptual-update-orchestration-inline.png#lightbox)

## Prerequisites

- Read the [conceptual overview of Fleet updates](concepts-update-orchestration), which provides an explanation of update runs, stages, groups, and strategies referenced in this guide.
- You must have a Fleet resource with one or more member clusters. If not, follow the [quickstart](quickstart-create-fleet-and-members) to create a Fleet resource and join Azure Kubernetes Service (AKS) clusters as members.
- Set the following environment variables:

    ```bash
    export GROUP=<resource-group>
    export FLEET=<fleet-name>
    export CLUSTERID=<aks-cluster-resource-id>
    export STRATEGY=<strategy-name>
    ```
- If you're following the Azure CLI instructions in this article, install the latest version of the Azure CLI. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- You also need the `fleet` Azure CLI extension. To install it, run the following command:

    ```azurecli
    az extension add --name fleet
    ```

    Run the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command to update to the latest version of the extension released:

    ```azurecli
    az extension update --name fleet
    ```

::: zone pivot="terraform"

- [Install and configure Terraform](/en-us/azure/developer/terraform/quickstart-configure).
- Install the latest version of the Azure CLI. To install or upgrade, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli). You use the Azure CLI to verify the update strategy that Terraform creates.
- You also need the `fleet` Azure CLI extension. To install it, run the following command:

    ```azurecli
    az extension add --name fleet
    ```

    Run the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command to update to the latest version of the extension.

    ```azurecli
    az extension update --name fleet
    ```
- The Terraform sample used in this article creates its own resource group and an Azure Kubernetes Fleet Manager without a hub cluster. It doesn't join any AKS clusters as Fleet members. The sample's update strategy references the update group names `group-1`, `group-2`, and `group-3`. To have the strategy apply to real update runs, assign existing Fleet member clusters to those update group names, or edit the sample's `group` blocks to match your own update group names.

::: zone-end

## Select clusters for your strategy

There are two ways to select which clusters are included in each stage and group of your update strategy to control update sequence:

- **Member labels (recommended)**: Assign labels to each fleet member and use `memberSelector` to select members by those labels. Each member can have multiple labels.
- **Update groups**: Assign an update group to each fleet member, then define groups in your strategy that match those group names. Each member can only belong to one group.

## Create an update strategy using member selectors (preview)

Use member labels to select clusters in your update strategies. They provide more flexibility. For conceptual details, see [Group clusters using member labels](concepts-update-orchestration#group-clusters-using-member-labels-preview).

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

### Apply labels on member clusters

#### Apply labels when adding member cluster to the fleet

Use the [`az fleet member create`](/en-us/cli/azure/fleet/member#az-fleet-member-create) command to apply labels to your fleet members. The following example applies two labels to the member cluster: `env=staging` and `tier=frontend`:

```azurecli
az fleet member create \
    --resource-group $GROUP \
    --fleet-name $FLEET \
    --name member1 \
    --member-cluster-id $CLUSTERID \
    --labels "env=staging tier=frontend"
```

#### Apply labels to an existing fleet member

Use the [`az fleet member update`](/en-us/cli/azure/fleet/member#az-fleet-member-update) command to apply labels to your fleet members.

```azurecli
az fleet member update \
 --resource-group $GROUP \
 --fleet-name $FLEET \
 --name member1 \
 --labels "env=staging tier=frontend"
```

### Create an update strategy

An update strategy consists of one or more stages, where a stage can contain one or more update groups.

Note

An Azure portal experience will be available prior to general availability of this capability.

1. Create a JSON file to define the stages and groups for the update run. Stages run sequentially in the order they appear in the JSON file. Groups run in parallel within each stage. The following example file (*example-labels-strategy.json*) defines a strategy with two stages using `memberSelector` to select clusters by their labels and includes optional `maxConcurrency` settings:

    - The `staging` stage uses a stage-level `memberSelector` to select all clusters with the label `env=staging` and create one implicit group.
    - The `production` stage uses a stage-level `memberSelector` to prefilter all clusters with the label `env=production`, then defines two groups, each with its own `memberSelector` to select clusters by the `tier` label.

    When `memberSelector` is set on a group, the group's `name` field is used only as a display identifier for status reporting and logging and no longer used for update group based selection of fleet members.

    ```json
    {
        "stages": [
            {
                "name": "staging",
                "memberSelector": { "byLabel": "env=staging" },
                "maxConcurrency": "1",
                "afterStageWaitInSeconds": 600
            },
            {
                "name": "production",
                "memberSelector": { "byLabel": "env=production" },
                "maxConcurrency": "4",
                "groups": [
                    {
                        "name": "frontend",
                        "memberSelector": { "byLabel": "tier=frontend" },
                        "maxConcurrency": "3"
                    },
                    {
                        "name": "backend",
                        "memberSelector": { "byLabel": "tier=backend" },
                        "maxConcurrency": "3"
                    }
                ]
            }
        ]
    }
    ```

Note

The `maxConcurrency` field is optional and controls how many clusters can upgrade concurrently at the stage or group level. Use a larger value to upgrade clusters faster across your fleet, or a smaller value for a more controlled rollout that limits the blast radius if issues arise.

When a stage uses `memberSelector` without groups (like `staging`), all matching members form a single implicit group and the stage's `maxConcurrency` controls concurrency directly. When groups are defined (like `production`), the stage-level `maxConcurrency` acts as an overall ceiling across all groups.

In this example, the `staging` stage sets `maxConcurrency` to `"1"`, so staging clusters upgrade one at a time. The `production` stage allows up to `"4"` clusters concurrently, with the `frontend` and `backend` groups each limited to `"3"`.

Values can be a fixed integer (for example, `"3"`) or a percentage (for example, `"50%"`). If omitted, the system applies default values. For details on how these values are resolved and their upper limits, see [Maximum concurrency (preview)](concepts-update-orchestration#maximum-concurrency-preview).

1. Create a new update strategy using the [`az fleet updatestrategy create`](/en-us/cli/azure/fleet/updatestrategy#az-fleet-updatestrategy-create) command with the `--stages` flag set to the name of your JSON file.

    ```azurecli
    az fleet updatestrategy create \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name $STRATEGY \
     --stages example-labels-strategy.json
    ```

## Create an update strategy using update groups

You can select clusters in update strategies by assigning them to a single update group. Define an update strategy that assigns these update groups to stages. Within an update stage, updates are applied to each update group in parallel. Within an update group, member clusters update sequentially.

Note

A fleet member can only be a part of one update group, but an update group can have multiple fleet members assigned to it. An update group itself isn't a separate resource type. Update groups are only strings representing references from the fleet members. So, if all fleet members with references to a common update group are deleted, that specific update group ceases to exist as well.

### Assign clusters to update groups

#### Assign to group when adding member cluster to the fleet

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Member clusters** &gt; **Add**.

    [![Screenshot of the Azure portal page for Azure Kubernetes Fleet Manager for adding member clusters.](media/create-update-strategy/add-members-inline.png)](media/create-update-strategy/add-members.png#lightbox)
3. Select the cluster that you want to add, and then select **Next: Review + add**.
4. Enter the name of the update group that you want to assign the cluster to, and then select **Add**.

    [![Screenshot of the Azure portal page for Azure Kubernetes Fleet Manager review and add step for member clusters.](media/create-update-strategy/add-members-assign-group-inline.png)](media/create-update-strategy/add-members-assign-group.png#lightbox)

::: zone-end

::: zone pivot="azure-cli,terraform"

Assign a member cluster to an update group when adding the member cluster to the fleet using the [`az fleet member create`](/en-us/cli/azure/fleet/member#az-fleet-member-create) command with the `--update-group` parameter set to the name of the update group.

```azurecli
az fleet member create \
    --resource-group $GROUP \
    --fleet-name $FLEET \
    --name member1 \
    --member-cluster-id $CLUSTERID \
    --update-group group-1a
```

::: zone-end

#### Assign an existing fleet member to an update group

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Member clusters**.
3. Select the clusters that you want to assign to an update group, and then select **Assign update group**

    [![Screenshot of the Azure portal page for assigning existing member clusters to a group.](media/create-update-strategy/existing-members-assign-group-inline.png)](media/create-update-strategy/existing-members-assign-group.png#lightbox)
4. Enter the name of the update group that you want to assign the cluster to, and then select **Assign**.

    [![Screenshot of the Azure portal page for member clusters that shows the form for updating a member cluster's group.](media/create-update-strategy/group-name-inline.png)](media/create-update-strategy/group-name.png#lightbox)

::: zone-end

::: zone pivot="azure-cli,terraform"

Assign an existing fleet member to an update group using the [`az fleet member update`](/en-us/cli/azure/fleet/member#az-fleet-member-update) command with the `--update-group` flag set to the name of the update group.

```azurecli
az fleet member update \
 --resource-group $GROUP \
 --fleet-name $FLEET \
 --name member1 \
 --update-group group-1
```

::: zone-end

### Create an update strategy

An update strategy consists of one or more stages, where a stage can contain one or more update groups.

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your Azure Kubernetes Fleet Manager resource.
2. From the service menu, under **Settings**, select **Multi-cluster update** &gt; **Strategies**, then **Create**.
3. Enter a name for the strategy.
4. The first time you view the page, an update strategy explanation diagram is displayed which can help visualize how strategies function.

    [![A screenshot of the Azure portal showing creation of update strategy.](media/create-update-strategy/create-strategy-inline.png)](media/create-update-strategy/create-strategy-lightbox.png#lightbox)
5. Select **Create Stage** and enter:

    - **Stage name** - name the stage - it must be unique across all stage names in the strategy.
    - **(Optional) Stage approvals** - select this option if you would like to wait for an approval before this stage starts or after it completes. For more information, see [Add approvals to update groups and stages](update-strategies-gates-approvals).
    - **(Optional) Pause after stage** - select this option if you would like to define a pause before moving to the next stage.
    - **(Optional) Pause duration** - select a predefined duration, or enter a custom value in seconds.

    [![A screenshot of the Azure portal showing creation of Azure Kubernetes Fleet Manager update strategy stage.](media/create-update-strategy/create-stage-basics-inline.png)](media/create-update-strategy/create-stage-basics.png#lightbox)
6. Assign one or more **Update Groups** to the stage, and then select **Create**.

    Note

    The maximum number of Update Groups in each Update Stage is **50**.

    [![A screenshot of the Azure portal showing creation of Azure Kubernetes Fleet Manager update strategy stage, selecting update groups to include.](media/create-update-strategy/create-stage-choose-groups-inline.png)](media/create-update-strategy/create-stage-choose-groups.png#lightbox)

::: zone-end

::: zone pivot="azure-cli"

For this scenario, we create stages and groups to match the details used for the Azure portal process.

1. Create a JSON file to define the stages and groups for the update run. Stages run sequentially in the order they appear in the JSON file. Groups run in parallel within each stage, so ordering isn't important. The following example file (*example-stages.json*) defines a strategy with two stages and includes optional `maxConcurrency` and `maxAllowedFailures` settings:

    ```json
    {
        "stages": [
            {
                "name": "stage-1",
                "maxConcurrency": "7",
                "maxAllowedFailures": "2",
                "groups": [
                    {
                        "name": "group-1",
                        "maxConcurrency": "3",
                        "maxAllowedFailures": "1"
                    },
                    {
                        "name": "group-2",
                        "maxConcurrency": "50%",
                        "maxAllowedFailures": "25%"
                    }
                ],
                "afterStageWaitInSeconds": 300
            },
            {
                "name": "stage-2",
                "maxConcurrency": "100%",
                "maxAllowedFailures": "0",
                "groups": [
                    {
                        "name": "group-3",
                        "maxConcurrency": "2",
                        "maxAllowedFailures": "0"
                    }
                ]
            }
        ]
    }
    ```

    **`maxConcurrency`**

    The `maxConcurrency` field is optional and controls how many clusters can upgrade concurrently at the stage or group level. Use a larger value to upgrade clusters faster across your fleet, or a smaller value for a more controlled rollout that limits the blast radius if problems arise.

    In this example, `stage-1` sets `maxConcurrency` to `"7"`, which allows up to `"7"` clusters in this stage to upgrade concurrently. Within `stage-1`, `group-1` limits concurrency to `"3"` clusters, which means up to `"3"` in this group can upgrade concurrently. `group-2` allows up to `"50%"` of its clusters to upgrade concurrently (for example, if the group contains 4 clusters, up to 2 can upgrade at the same time).

    Values can be a fixed integer (for example, `"3"`) or a percentage (for example, `"100%"`). If omitted, the system applies default values. For details on how these values are resolved and their upper limits, see [Maximum concurrency (preview)](concepts-update-orchestration#maximum-concurrency-preview).

    **`maxAllowedFailures`**

    The `maxAllowedFailures` field is optional and controls how many member cluster upgrade failures are tolerated before the group or stage is marked as failed. By default (when unset or `"0"`), a single failure stops the entire update run.

    This setting evaluates failure count only. It doesn't enforce a minimum success rate. A group or stage can therefore end in `Completed` even if some or all members failed, as long as the failure threshold wasn't exceeded when Fleet made its scheduling decisions.

    In this example, `stage-1` sets `maxAllowedFailures` to `"2"`, tolerating up to two member failures across the stage. Within `stage-1`, `group-1` tolerates `"1"` failure and `group-2` tolerates `"25%"` of its members failing (for example, if the group contains 4 clusters, up to 1 failure is tolerated). `stage-2` sets `maxAllowedFailures` to `"0"`, which means any failure immediately stops the run and is often useful for production stages.

    For most rollouts, prefer percentage-based values because they scale better across different group sizes. Avoid setting the value equal to the total member count unless you intentionally want effectively "never fail" behavior for that segment.

    Values can be a fixed integer (for example, `"3"`) or a percentage (for example, `"25%"`). For details on how these values are resolved, see [Maximum allowed failures (preview)](concepts-update-orchestration#maximum-allowed-failures-preview).
2. Create a new update strategy using the [`az fleet updatestrategy create`](/en-us/cli/azure/fleet/updatestrategy#az-fleet-updatestrategy-create) command with the `--stages` flag set to the name of your JSON file.

    ```azurecli
    az fleet updatestrategy create \
     --resource-group $GROUP \
     --fleet-name $FLEET \
     --name $STRATEGY \
     --stages example-stages.json
    ```

::: zone-end

::: zone pivot="terraform"

The Terraform sample in this section creates the same two-stage strategy shape shown in the preceding Azure CLI example: `stage-1` contains `group-1` and `group-2`, which update in parallel and are followed by a 300-second wait, and then `stage-2` updates `group-3`. Unlike the CLI JSON example, the sample doesn't set `maxConcurrency` or `maxAllowedFailures` on any stage or group, so Fleet applies its default values. To add these settings, extend the `stage` and `group` blocks in `main.tf` with the corresponding `azurerm_kubernetes_fleet_update_strategy` arguments.

#### Review the Terraform code

Note

The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/201-aks-fleet-update-strategy). View the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/201-aks-fleet-update-strategy/TestRecord.md).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/terraform).

1. Create a directory to test the sample Terraform code, and make it the current directory.
2. Create a file named `providers.tf`, and insert the following code:

    ```terraform
    terraform {
      required_version = ">= 1.9.0"
    
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.77"
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
    
    variable "update_strategy_name" {
      type        = string
      description = "Name of the Fleet update strategy."
      default     = "example-update-strategy"
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
      length  = 6
      lower   = true
      numeric = true
      special = false
      upper   = false
    }
    
    locals {
      resource_group_name = coalesce(var.resource_group_name, "rg-fleet-update-strategy-${random_string.suffix.result}")
      fleet_name          = coalesce(var.fleet_name, "fleet-update-strategy-${random_string.suffix.result}")
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
    
    resource "azurerm_kubernetes_fleet_update_strategy" "example" {
      name                        = var.update_strategy_name
      kubernetes_fleet_manager_id = azurerm_kubernetes_fleet_manager.example.id
    
      stage {
        name = "stage-1"
    
        group {
          name = "group-1"
        }
    
        group {
          name = "group-2"
        }
    
        after_stage_wait_in_seconds = 300
      }
    
      stage {
        name = "stage-2"
    
        group {
          name = "group-3"
        }
      }
    }
    ```
5. Create a file named `outputs.tf`, and insert the following code:

    ```terraform
    output "resource_group_name" {
      description = "Name of the created resource group."
      value       = azurerm_resource_group.example.name
    }
    
    output "fleet_manager_id" {
      description = "Resource ID of the Azure Kubernetes Fleet Manager."
      value       = azurerm_kubernetes_fleet_manager.example.id
    }
    
    output "fleet_manager_name" {
      description = "Name of the Azure Kubernetes Fleet Manager."
      value       = azurerm_kubernetes_fleet_manager.example.name
    }
    
    output "update_strategy_id" {
      description = "Resource ID of the Fleet update strategy."
      value       = azurerm_kubernetes_fleet_update_strategy.example.id
    }
    ```
6. Copy the sample's `terraform.tfvars.example` file to `terraform.tfvars` in the same directory, and then edit the values for the Azure region, resource group name, Fleet name, update strategy name, and tags you want to use.

    ```console
    cp terraform.tfvars.example terraform.tfvars
    ```

#### Initialize, validate, and apply the configuration

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

#### Verify the update strategy

Get the resource group and Fleet Manager names from the Terraform outputs, and extract the strategy name from the `update_strategy_id` output.

```console
resource_group_name=$(terraform output -raw resource_group_name)
fleet_manager_name=$(terraform output -raw fleet_manager_name)
update_strategy_name=$(terraform output -raw update_strategy_id | awk -F'/' '{print $NF}')
```

Show the strategy's stages and groups by using the [`az fleet updatestrategy show`](/en-us/cli/azure/fleet/updatestrategy#az-fleet-updatestrategy-show) command.

```azurecli
az fleet updatestrategy show \
  --resource-group $resource_group_name \
  --fleet-name $fleet_manager_name \
  --name $update_strategy_name
```

The command output's `stages` array shows `stage-1` with `group-1` and `group-2` and an `afterStageWaitInSeconds` value of `300`, followed by `stage-2` with `group-3`, matching the strategy defined in `main.tf`.

#### Clean up resources

Run [terraform plan](https://developer.hashicorp.com/terraform/cli/commands/plan) with the `-destroy` flag to create a destroy execution plan.

```console
terraform plan -destroy -out main.destroy.tfplan
```

Run [terraform apply](https://developer.hashicorp.com/terraform/cli/commands/apply) to apply the destroy plan.

```console
terraform apply main.destroy.tfplan
```

Warning

This command deletes the update strategy, the Azure Kubernetes Fleet Manager, and the resource group created by this sample, not just the strategy. Confirm the resource group doesn't contain other resources you want to keep before you run this command.

::: zone-end