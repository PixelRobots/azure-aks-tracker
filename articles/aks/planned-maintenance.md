---
layout: Conceptual
title: Use Planned Maintenance to Schedule and Control Upgrades for Azure Kubernetes Service (AKS) Clusters - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/planned-maintenance
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
description: Learn how to use planned maintenance to schedule and control cluster and node image upgrades in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.custom: devx-track-azurecli
ms.date: 2026-08-10T00:00:00.0000000Z
ms.author: schaffererin
ms.subservice: aks-upgrade
author: schaffererin
ai-usage: ai-assisted
zone_pivot_groups: cli-portal-terraform-json
locale: en-us
document_id: 72441f2f-47e9-ece7-e60f-cecb436a74e5
document_version_independent_id: 880da085-1b0a-6475-8c88-19131e5eee2a
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/planned-maintenance.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/planned-maintenance
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/planned-maintenance.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/bcbcbad5-4208-4783-8035-8481272c98b8
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/43b2e5aa-8a6d-4de2-a252-692232e5edc8
platformId: 4c8669f2-c6c1-5dd4-2de4-86895dd8b633
---

# Use Planned Maintenance to Schedule and Control Upgrades for Azure Kubernetes Service (AKS) Clusters - Azure Kubernetes Service | Microsoft Learn

Important

**AKS platform-initiated upgrades.** Starting on **June 1, 2027**, AKS automatically upgrades any cluster that stays on an unsupported Kubernetes version after its 60-day [platform support grace period](platform-initiated-upgrades#platform-support-grace-period) ends. A platform-initiated upgrade **doesn't follow your maintenance window**, **doesn't stop for deprecated API usage**, and **can override a Pod Disruption Budget** that blocks a node drain, so workloads might be disrupted. Before the upgrade month, replace APIs removed from the target Kubernetes version and update incompatible self-managed add-ons. Keep your clusters on a supported Kubernetes version to avoid a platform-initiated upgrade. For more information, see [Prepare for platform-initiated upgrades in AKS](platform-initiated-upgrades#prepare-before-aks-starts-the-upgrade).

This article shows you how to use planned maintenance to schedule and control cluster and node image upgrades in Azure Kubernetes Service (AKS).

Regular maintenance is performed on your AKS cluster automatically. There are two types of maintenance operations:

- **AKS-initiated maintenance** involves the weekly releases that AKS performs to keep your cluster up to date with the latest features and fixes.
- **User-initiated maintenance** includes [cluster auto-upgrades](upgrade-cluster) and [node operating system (OS) automatic security updates](auto-upgrade-node-image).

When you use the feature of planned maintenance in AKS, you can run both types of maintenance in a cadence of your choice to minimize workload impact.

Note

You can use planned maintenance to schedule the timing of automatic upgrades, but enabling or disabling planned maintenance doesn't enable or disable automatic upgrades.

## Before you begin

::: zone pivot="azure-cli,azure-portal,json-file"

- This article assumes that you have an existing AKS cluster. If you don't have an AKS cluster, see [Create an AKS cluster](learn/quick-kubernetes-deploy-cli).

::: zone-end

- If you're using the Azure CLI, upgrade to the latest version using the [`az upgrade`](/en-us/cli/azure/update-azure-cli#manual-update) command.

::: zone pivot="terraform"

- An active Azure subscription. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Set your subscription context using the [`az account set`](/en-us/cli/azure/account#az_account_set) command. For example:

    ```azurecli
    az account set --subscription "00000000-0000-0000-0000-000000000000"
    ```
- Terraform installed locally. For installation instructions, see [Install Terraform](https://developer.hashicorp.com/terraform/install).

::: zone-end

## Considerations

When you use planned maintenance, the following considerations apply:

- AKS reserves the right to break planned maintenance windows for unplanned, reactive maintenance operations that are urgent or critical. These maintenance operations might even run during the `notAllowedTime` or `notAllowedDates` periods defined in your configuration.
- Maintenance operations are considered *best effort only* and aren't guaranteed to occur within a specified window.
- [Platform-initiated upgrades](platform-initiated-upgrades) can occur outside maintenance windows. If a cluster stays on an unsupported Kubernetes version after the 60-day [platform support grace period](platform-initiated-upgrades#platform-support-grace-period) ends, AKS can upgrade it during or after the planned platform-initiated upgrade month. Keep your cluster on a supported version to avoid a platform-initiated upgrade outside your maintenance window.

## Schedule configuration types for planned maintenance

Three schedule configuration types are available for planned maintenance:

- `default` is a basic configuration for controlling AKS releases, which covers control plane components and system add-ons upgrade. The releases can take up to two weeks to roll out to all regions from the initial time of shipping, because of Azure safe deployment practices.

    Choose `default` to schedule these updates in a manner that's least disruptive for you. You can monitor the status of an ongoing AKS release by region with the [weekly release tracker](release-tracker).
- `aksManagedAutoUpgradeSchedule` controls when to perform cluster upgrades scheduled by your designated auto-upgrade channel. You can configure more finely controlled cadence and recurrence settings with this configuration compared to the `default` configuration. For more information on cluster auto-upgrade, see [Automatically upgrade an Azure Kubernetes Service cluster](upgrade-cluster).
- `aksManagedNodeOSUpgradeSchedule` controls when to perform the node OS security patching scheduled by your node OS auto-upgrade channel. You can configure more finely controlled cadence and recurrence settings with this configuration compared to the `default` configuration. For more information on node OS auto-upgrade channels, see [Automatically patch and update AKS cluster node images](auto-upgrade-node-image).

We recommend using `aksManagedAutoUpgradeSchedule` for all cluster Kubernetes version upgrade scenarios and `aksManagedNodeOSUpgradeSchedule` for all node OS security patching scenarios.

The `default` option is meant exclusively for AKS weekly releases. Use `default` if you want to control the upgrade schedule for AKS control plane components (such as API Server, ETCD, etc.) and add-ons (such as CoreDNS, Metrics Server, etc.).

All three types of configurations can coexist.

## Create a maintenance window

Note

When you're using auto-upgrade, to ensure proper functionality, use a maintenance window with a duration of four hours or more.

Note

From the 2023-05-01 API version onwards, use the properties in the following table for `default` configuration.

An `aksManagedAutoUpgradeSchedule` or `aksManagedNodeOSUpgradeSchedule` maintenance window and `default` configuration from 2023-05-01 API version onwards has the following properties:

| Name | Description | Default value |
| --- | --- | --- |
| `utcOffset` | The time zone for cluster maintenance. | `+00:00` |
| `startDate` | The date on which the maintenance window begins to take effect. | The current date at creation time |
| `startTime` | The time for maintenance to begin, based on the time zone determined by `utcOffset`. | Not applicable |
| `schedule` | The upgrade frequency. Three types are available: `Weekly`, `AbsoluteMonthly`, and `RelativeMonthly`. | Not applicable |
| `intervalDays` | The interval in days for maintenance runs. It's applicable only to `aksManagedNodeOSUpgradeSchedule`. | Not applicable |
| `intervalWeeks` | The interval in weeks for maintenance runs. | Not applicable |
| `intervalMonths` | The interval in months for maintenance runs. | Not applicable |
| `dayOfWeek` | The specified day of the week for maintenance to begin. | Not applicable |
| `durationHours` | The duration of the window for maintenance to run. | Not applicable |
| `notAllowedDates` | A range of dates that maintenance can't run, determined by `start` and `end` child properties. It's applicable only when you're creating the maintenance window by using a configuration file. | Not applicable |

### Deprecated properties

Note

If you create a `default` configuration with the following deprecated properties, it migrates automatically to the new properties shown in the previous table.

**[Deprecated]** A `default` maintenance window has the following legacy properties:

| Name | Description | Default value |
| --- | --- | --- |
| `timeInWeek` | In a `default` configuration, this property contains the `day` and `hourSlots` values that define a maintenance window. | Not applicable |
| `timeInWeek.day` | The day of the week to perform maintenance in a `default` configuration. | Not applicable |
| `timeInWeek.hourSlots` | A list of hour-long time slots to perform maintenance on a particular day in a `default` configuration. | Not applicable |
| `notAllowedTime` | A range of dates that maintenance can't run, determined by `start` and `end` child properties. This property is applicable only when you're creating the maintenance window by using a configuration file. | Not applicable |

### Schedule types

Four schedule types are supported: `Daily`, `Weekly`, `AbsoluteMonthly`, and `RelativeMonthly`.

The following table shows which types are available for each maintenance-configuration option:

| Schedule type | `default` | `aksManagedClusterAutoUpgradeSchedule` | `aksManagedNodeOSUpgradeSchedule` |
| --- | --- | --- | --- |
| Daily | Unsupported ❌ | Supported ✅ (after Jun 2025) | Supported ✅ |
| Weekly | Supported ✅ | Supported ✅ | Supported ✅ |
| AbsoluteMonthly | Unsupported ❌ | Supported ✅ | Supported ✅ |
| RelativeMonthly | Unsupported ❌ | Supported ✅ | Supported ✅ |

All of the fields shown for each schedule type are required.

A `Daily` schedule might look like "every three days":

```json
"schedule": {
    "daily": {
        "intervalDays": 3
    }
}
```

A `Weekly` schedule might look like "every two weeks on Friday":

```json
"schedule": {
    "weekly": {
        "intervalWeeks": 2,
        "dayOfWeek": "Friday"
    }
}
```

An `AbsoluteMonthly` schedule might look like "every three months on the first day of the month":

```json
"schedule": {
    "absoluteMonthly": {
        "intervalMonths": 3,
        "dayOfMonth": 1
    }
}
```

A `RelativeMonthly` schedule might look like "every two months on the last Monday":

```json
"schedule": {
    "relativeMonthly": {
        "intervalMonths": 2,
        "dayOfWeek": "Monday",
        "weekIndex": "Last"
    }
}
```

Valid values for `weekIndex` include `First`, `Second`, `Third`, `Fourth`, and `Last`.

::: zone pivot="terraform"

## Create the Terraform configuration file

Terraform configuration files define the infrastructure that Terraform creates and manages.

Create a file named `main.tf` and add the following code to define the Terraform version and specify the Azure provider:

```Terraform
terraform {
 required_providers {
   azurerm = {
     source  = "hashicorp/azurerm"
     version = "~>4.0"
   }
   azapi = {
     source  = "azure/azapi"
     version = "~>2.0"
   }
 }
}
provider "azurerm" {
 features {}
}
provider "azapi" {}
```

## Create a resource group

Add the following code to `main.tf` to create an Azure resource group. Update the `location` and `name` values to match your environment.

```Terraform
resource "azurerm_resource_group" "rg" {
 name     = "aks-maintenance-rg"
 location = "East US"
}
```

## Create an AKS cluster

Add the following code to `main.tf` to create an AKS cluster. Update any values as needed to match your environment.

```Terraform
resource "azurerm_kubernetes_cluster" "aks" {
 name                = "aks-maintenance-cluster"
 location            = azurerm_resource_group.rg.location
 resource_group_name = azurerm_resource_group.rg.name
 dns_prefix          = "aksmaintenance"
 default_node_pool {
   name       = "nodepool1"
   node_count = 1
   vm_size    = "Standard_DS2_v2"
 }
 identity {
   type = "SystemAssigned"
 }
}
```

::: zone-end

## Add a maintenance window configuration

::: zone pivot="azure-cli"

Add a maintenance window configuration to an AKS cluster using the [`az aks maintenanceconfiguration add`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-add) command.

The first example adds a new `default` configuration that schedules maintenance to run from 1:00 AM to 5:00 AM every Monday in the `UTC` time zone. The second example adds a new `aksManagedAutoUpgradeSchedule` configuration that schedules maintenance to run every third Friday between 12:00 AM and 8:00 AM in the `UTC+5:30` time zone.

```azurecli
# Add a new default configuration
az aks maintenanceconfiguration add --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name default --schedule-type Weekly --day-of-week Monday --interval-weeks 1 --duration 4 --utc-offset +00:00 --start-time 01:00

# Add a new aksManagedAutoUpgradeSchedule configuration
az aks maintenanceconfiguration add --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name aksManagedAutoUpgradeSchedule --schedule-type Weekly --day-of-week Friday --interval-weeks 3 --duration 8 --utc-offset +05:30 --start-time 00:00
```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, go to your AKS cluster resource.
2. From the service menu, under **Settings**, select **Upgrades**.
3. Under **Upgrade** &gt; **Automatic upgrade scheduler**, select **Add schedule**.

    ![Screenshot that shows the option to add a schedule in the Azure portal.](media/planned-maintenance/add-schedule-portal.png)
4. On the **Add maintenance schedule** pane, configure the following maintenance window settings:

    - **Repeats**: Select the frequency for the maintenance window. We recommend selecting **Weekly**.
    - **Frequency**: Select the day of the week for the maintenance window. We recommend selecting **Sunday**.
    - **Maintenance start date**: Select the start date for the maintenance window.
    - **Maintenance start time**: Select the start time for the maintenance window.
    - **UTC offset**: Select the UTC offset for the maintenance window. The default is **+00:00**.

    ![Screenshot that shows the pane for adding a maintenance schedule in the Azure portal.](media/planned-maintenance/add-maintenance-schedule-portal.png)
5. Select **Save**.

::: zone-end

::: zone pivot="json-file"

You can use a JSON file to create a maintenance configuration instead of using parameters. When you use this method, you can prevent maintenance during a range of dates by specifying `notAllowedDates` for `default`, `aksManagedAutoUpgradeSchedule`, and `aksManagedNodeOSUpgradeSchedule` configurations.

1. Create a JSON file with the maintenance window settings.

    The following example creates a `default.json` file that schedules maintenance to run from 1:00 AM to 5:00 AM every Tuesday in the `UTC` time zone. There's also an exception from `2021-05-26` to `2021-05-30` where maintenance isn't allowed, even if it overlaps with a maintenance window.

    ```json
    {
      "properties": {
        "maintenanceWindow": {
            "schedule": {
                "weekly": {
                    "intervalWeeks": 1,
                    "dayOfWeek": "Tuesday"
                }
            },
            "durationHours": 4,
            "utcOffset": "+00:00",
            "startTime": "01:00",
            "notAllowedDates": [
                {
                    "start": "2021-05-26",
                    "end": "2021-05-30"
                }
            ]
        }
      }
    }
    ```

    The following example creates an `autoUpgradeWindow.json` file that schedules maintenance to run every three months on the first of the month between 9:00 AM and 1:00 PM in the `UTC-08` time zone. There's also an exception from `2023-12-23` to `2024-01-05` where maintenance isn't allowed, even if it overlaps with a maintenance window.

    ```json
    {
      "properties": {
        "maintenanceWindow": {
            "schedule": {
                "absoluteMonthly": {
                    "intervalMonths": 3,
                    "dayOfMonth": 1
                }
            },
            "durationHours": 4,
            "utcOffset": "-08:00",
            "startTime": "09:00",
            "notAllowedDates": [
                {
                    "start": "2023-12-23",
                    "end": "2024-01-05"
                }
            ]
        }
      }
    }
    ```
2. Add the maintenance window configuration using the [`az aks maintenanceconfiguration add`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-add) command with the `--config-file` parameter.

    The first example adds a new `default` configuration by using the `default.json` file. The second example adds a new `aksManagedAutoUpgradeSchedule` configuration by using the `autoUpgradeWindow.json` file.

    ```azurecli
    # Add a new default configuration
    az aks maintenanceconfiguration add --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name default --config-file ./default.json
    
    # Add a new aksManagedAutoUpgradeSchedule configuration
    az aks maintenanceconfiguration add --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name aksManagedAutoUpgradeSchedule --config-file ./autoUpgradeWindow.json
    ```

::: zone-end

::: zone pivot="terraform"

Add the maintenance window configuration to `main.tf` using the `azapi_resource` resource.

### Default maintenance configuration

The following example creates a `default` maintenance configuration that schedules maintenance to run from 2:00 AM to 6:00 AM every Saturday in the `UTC-04:00` time zone:

```Terraform
resource "azapi_resource" "default_maintenance" {
 type      = "Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2025-10-01"
 name      = "default"
 parent_id = azurerm_kubernetes_cluster.aks.id
 schema_validation_enabled = false
 body = {
   properties = {
     maintenanceWindow = {
       schedule = {
         weekly = {
           dayOfWeek     = "Saturday"
           intervalWeeks = 1
         }
       }
       durationHours = 4
       startTime     = "02:00"
       utcOffset     = "-04:00"
     }
   }
 }
}
```

### Autoupgrade maintenance configuration

The following example creates an `aksManagedAutoUpgradeSchedule` maintenance configuration that schedules maintenance to run every Sunday from 1:00 AM to 5:00 AM in the `UTC-04:00` time zone, starting on April 20, 2026:

```Terraform
resource "azapi_resource" "auto_upgrade" {
 type      = "Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2025-10-01"
 name      = "aksManagedAutoUpgradeSchedule"
 parent_id = azurerm_kubernetes_cluster.aks.id
 schema_validation_enabled = false
 body = {
   properties = {
     maintenanceWindow = {
       startDate     = "2026-04-20"
       startTime     = "01:00"
       durationHours = 4
       utcOffset     = "-04:00"
       schedule = {
         weekly = {
           dayOfWeek     = "Sunday"
           intervalWeeks = 1
         }
       }
     }
   }
 }
}
```

### Node OS upgrade maintenance configuration

The following example creates an `aksManagedNodeOSUpgradeSchedule` maintenance configuration that schedules maintenance to run every Monday from 3:00 AM to 7:00 AM in the `UTC-04:00` time zone, starting on April 21, 2026:

```Terraform
resource "azapi_resource" "node_os_upgrade" {
 type      = "Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2025-10-01"
 name      = "aksManagedNodeOSUpgradeSchedule"
 parent_id = azurerm_kubernetes_cluster.aks.id
 schema_validation_enabled = false
 body = {
   properties = {
     maintenanceWindow = {
       startDate     = "2026-04-21"
       startTime     = "03:00"
       durationHours = 4
       utcOffset     = "-04:00"
       schedule = {
         weekly = {
           dayOfWeek     = "Monday"
           intervalWeeks = 1
         }
       }
     }
   }
 }
}
```

::: zone-end

## Update an existing maintenance window

::: zone pivot="azure-cli"

Update an existing maintenance configuration using the [`az aks maintenanceconfiguration update`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-update) command.

The following example updates the `default` configuration to schedule maintenance to run from 2:00 AM to 6:00 AM every Friday:

```azurecli
az aks maintenanceconfiguration update --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name default --schedule-type Weekly --day-of-week Friday --interval-weeks 1 --duration 4 --utc-offset +00:00 --start-time 02:00
```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your AKS cluster resource.
2. From the service menu, under **Settings**, select **Upgrades**.
3. Under **Upgrade** &gt; **Automatic upgrade scheduler**, select **Edit schedule**.

    ![Screenshot that shows the option for editing a schedule in the Azure portal.](media/planned-maintenance/edit-schedule-portal.png)
4. On the **Edit maintenance schedule** pane, update the maintenance window settings as needed.
5. Select **Save**.

::: zone-end

::: zone pivot="json-file"

1. Update the configuration JSON file with the new maintenance window settings.

    The following example updates the `default.json` file from the previous section to schedule maintenance to run from 2:00 AM to 6:00 AM every Monday:

    ```json
    {
      "properties": {
        "maintenanceWindow": {
            "schedule": {
                "weekly": {
                    "intervalWeeks": 1,
                    "dayOfWeek": "Monday"
                }
            },
            "durationHours": 4,
            "utcOffset": "+00:00",
            "startTime": "02:00",
            "notAllowedDates": [
                {
                    "start": "2021-05-26",
                    "end": "2021-05-30"
                }
            ]
        }
      }
    }
    ```
2. Update the maintenance window configuration using the [`az aks maintenanceconfiguration update`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-update) command with the `--config-file` parameter:

    ```azurecli
    az aks maintenanceconfiguration update --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name default --config-file ./default.json
    ```

::: zone-end

::: zone pivot="terraform"

If you already have an existing AKS cluster managed by Terraform, you can update the maintenance window configuration by modifying the Terraform configuration file and applying the changes using the `terraform apply` command.

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

::: zone-end

## List all maintenance windows in an existing cluster

List the current maintenance configuration windows in your AKS cluster using the [`az aks maintenanceconfiguration list`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-list) command:

```azurecli
az aks maintenanceconfiguration list --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME
```

## Show a specific maintenance configuration window in an existing cluster

View a specific maintenance configuration window in your AKS cluster using the [`az aks maintenanceconfiguration show`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-show) command with the `--name` parameter:

```azurecli
az aks maintenanceconfiguration show --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name aksManagedAutoUpgradeSchedule
```

The following example output shows the maintenance window for `aksManagedAutoUpgradeSchedule`:

```output
{
  "id": "/subscriptions/<subscription>/resourceGroups/myResourceGroup/providers/Microsoft.ContainerService/managedClusters/myAKSCluster/maintenanceConfigurations/aksManagedAutoUpgradeSchedule",
  "maintenanceWindow": {
    "durationHours": 4,
    "notAllowedDates": [
      {
        "end": "2024-01-05",
        "start": "2023-12-23"
      }
    ],
    "schedule": {
      "absoluteMonthly": {
        "dayOfMonth": 1,
        "intervalMonths": 3
      },
      "daily": null,
      "relativeMonthly": null,
      "weekly": null
    },
    "startDate": "2023-01-20",
    "startTime": "09:00",
    "utcOffset": "-08:00"
  },
  "name": "aksManagedAutoUpgradeSchedule",
  "notAllowedTime": null,
  "resourceGroup": "myResourceGroup",
  "systemData": null,
  "timeInWeek": null,
  "type": null
}
```

## Delete a maintenance configuration window in an existing cluster

::: zone pivot="azure-cli"

Delete a maintenance configuration window in your AKS cluster using the [`az aks maintenanceconfiguration delete`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-delete) command.

The following example deletes the `autoUpgradeSchedule` maintenance configuration:

```azurecli
az aks maintenanceconfiguration delete --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name autoUpgradeSchedule
```

::: zone-end

::: zone pivot="azure-portal"

1. In the Azure portal, navigate to your AKS cluster resource.
2. From the service menu, under **Settings**, select **Cluster configuration**.
3. Under **Upgrade** &gt; **Automatic upgrade scheduler**, select **Edit schedule**.

    ![Screenshot that shows the option for editing a schedule in the Azure portal.](media/planned-maintenance/edit-schedule-portal.png)
4. On the **Edit maintenance schedule** pane, select **Remove schedule**.

    ![Screenshot that shows the pane for editing a maintenance window with the button for removing a schedule in the Azure portal.](media/planned-maintenance/remove-schedule-portal.png)

::: zone-end

::: zone pivot="json-file"

Delete a maintenance configuration window in your AKS cluster using the [`az aks maintenanceconfiguration delete`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-delete) command.

The following example deletes the `autoUpgradeSchedule` maintenance configuration:

```azurecli
az aks maintenanceconfiguration delete --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name autoUpgradeSchedule
```

::: zone-end

::: zone pivot="terraform"

To delete a maintenance configuration, remove the corresponding block from your Terraform configuration and apply the changes using the `terraform apply` command.

::: zone-end

## Use a shared maintenance window (preview)

By using shared maintenance windows, you can apply the same maintenance window schedule across multiple AKS maintenance configurations and managed clusters in the same region. This approach ensures that related upgrade operations follow a consistent maintenance policy.

Use shared maintenance windows when you want cluster auto-upgrades and node OS auto-upgrades to use the same approved maintenance schedule instead of managing each schedule independently.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Shared maintenance windows are available in the `2026-05-02-preview` AKS API version or later. To use these preview commands, install Azure CLI version 2.85.0 or later and version 21.0.0b13 or later of the `aks-preview` extension. You create a shared maintenance window as a standalone resource, then link it to one or more clusters by setting the `maintenanceWindowId` field in the `aksManagedAutoUpgradeSchedule` or `aksManagedNodeOSUpgradeSchedule` maintenance configuration.

::: zone pivot="azure-cli,json-file"

Before you use a shared maintenance window, complete the following prerequisite steps:

- Install or update the `aks-preview` Azure CLI extension.

```azurecli
az extension add --upgrade --name aks-preview
```

- Register the `AKSSharedMaintenanceWindowPreview` feature flag on your subscription by using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command. Feature registration is subscription-scoped, so you only need to complete it once per subscription.

```azurecli
az feature register \
  --namespace Microsoft.ContainerService \
  --name AKSSharedMaintenanceWindowPreview
```

- Check the registration status by using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command:

```azurecli
az feature show \
  --namespace Microsoft.ContainerService \
  --name AKSSharedMaintenanceWindowPreview \
  --query properties.state \
  --output tsv
```

- Wait until the command returns `Registered` before you continue. Then refresh the registration of the `Microsoft.ContainerService` resource provider by using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command:

```azurecli
az provider register --namespace Microsoft.ContainerService
```

### Create a shared maintenance window

Create the shared maintenance window resource by using the [`az aks maintenancewindow create`](/en-us/cli/azure/aks/maintenancewindow#az-aks-maintenancewindow-create) command. For the full list of supported fields and schedule types, see Schedule configuration types for planned maintenance.

The following example creates a shared maintenance window with a weekly schedule that runs every Friday from 1:00 AM to 5:00 AM UTC:

```azurecli
az aks maintenancewindow create \
  --resource-group $RESOURCE_GROUP \
  --name mySharedWindow \
  --schedule-type Weekly \
  --day-of-week Friday \
  --interval-weeks 1 \
  --duration 4 \
  --utc-offset=+00:00 \
  --start-time 01:00
```

The following example creates a shared maintenance window with a relative monthly schedule that runs on the last Sunday of every month from 1:00 AM to 5:00 AM UTC:

```azurecli
az aks maintenancewindow create \
  --resource-group $RESOURCE_GROUP \
  --name mySharedWindow \
  --schedule-type RelativeMonthly \
  --day-of-week Sunday \
  --week-index Last \
  --interval-months 1 \
  --duration 4 \
  --utc-offset=+00:00 \
  --start-time 01:00
```

### Link a maintenance configuration to a shared maintenance window

Set the shared maintenance window resource ID:

```azurecli
MAINTENANCE_WINDOW_ID="/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroup/providers/Microsoft.ContainerService/maintenanceWindows/mySharedWindow"
```

Link a maintenance configuration to the shared maintenance window by using the [`az aks maintenanceconfiguration add`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-add) command:

```azurecli
az aks maintenanceconfiguration add \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name aksManagedAutoUpgradeSchedule \
  --maintenance-window-id $MAINTENANCE_WINDOW_ID
```

You can also link an existing maintenance configuration to a shared maintenance window by using the [`az aks maintenanceconfiguration update`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-update) command:

```azurecli
az aks maintenanceconfiguration update \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name aksManagedNodeOSUpgradeSchedule \
  --maintenance-window-id $MAINTENANCE_WINDOW_ID
```

When you use `--maintenance-window-id`, the schedule is defined by the referenced shared maintenance window. Don't combine `--maintenance-window-id` with inline schedule arguments such as `--schedule-type`, `--day-of-week`, `--interval-weeks`, `--duration`, `--utc-offset`, or `--start-time`.

You also can't combine `--maintenance-window-id` with `--config-file`. To link a shared maintenance window by using a JSON configuration file, set the `maintenanceWindowId` property in the file instead:

```json
{
  "properties": {
    "maintenanceConfigurationType": "aksManagedAutoUpgradeSchedule",
    "maintenanceWindowId": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroup/providers/Microsoft.ContainerService/maintenanceWindows/mySharedWindow"
  }
}
```

Apply the configuration file:

```azurecli
az aks maintenanceconfiguration add \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name aksManagedAutoUpgradeSchedule \
  --config-file ./linked-config.json
```

### Unlink a shared maintenance window

To unlink a shared maintenance window from a maintenance configuration, update the configuration with an inline schedule and omit `--maintenance-window-id`. This action converts the configuration to a standard inline maintenance configuration.

Update the configuration by using the [`az aks maintenanceconfiguration update`](/en-us/cli/azure/aks/maintenanceconfiguration#az-aks-maintenanceconfiguration-update) command:

```azurecli
az aks maintenanceconfiguration update \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name aksManagedAutoUpgradeSchedule \
  --schedule-type Weekly \
  --day-of-week Friday \
  --interval-weeks 1 \
  --duration 4 \
  --utc-offset +00:00 \
  --start-time 01:00
```

Note

Removing the link doesn't delete the shared maintenance window resource. Other maintenance configurations that reference the same window continue to use it.

To delete the shared maintenance window resource itself, use the [`az aks maintenancewindow delete`](/en-us/cli/azure/aks/maintenancewindow#az-aks-maintenancewindow-delete) command:

```azurecli
az aks maintenancewindow delete \
  --resource-group $RESOURCE_GROUP \
  --name mySharedWindow
```

Warning

You can't delete a shared maintenance window while any maintenance configuration references it. Unlink all referencing maintenance configurations before you delete the window.

::: zone-end

::: zone pivot="azure-portal,terraform"

Important

Shared maintenance windows aren't supported in the Azure portal or Terraform during preview. Use the Azure CLI or REST API to create and manage shared maintenance windows.

::: zone-end

## Frequently asked questions (FAQ)

### How can I check the existing maintenance configurations in my cluster?

Use the `az aks maintenanceconfiguration show` command.

### Can reactive, unplanned maintenance happen during the `notAllowedDates` periods too?

Yes. AKS reserves the right to break these windows for unplanned, reactive maintenance operations that are urgent or critical.

### How can I tell if a maintenance event occurred?

For releases, check your cluster's region and look up information in [weekly releases](release-tracker) to see if it matches your maintenance schedule. To view the status of your automatic upgrades, look up [activity logs](monitor-aks-reference) on your cluster. You can also look up specific upgrade-related events, as mentioned in [Upgrade an AKS cluster](upgrade-cluster).

AKS also emits upgrade-related Azure Event Grid events. To learn more, see [AKS as an Event Grid source](quickstart-event-grid).

### Can I use more than one maintenance configuration at the same time?

Yes, you can run all three configurations simultaneously: `default`, `aksManagedAutoUpgradeSchedule`, and `aksManagedNodeOSUpgradeSchedule`. If the windows overlap, AKS decides the running order.

### I configured a maintenance window, but the upgrade didn't happen. Why?

AKS auto-upgrade needs a certain amount of time, usually not more than 15 minutes, to take the maintenance window into consideration. We recommend at least 15 minutes between the creation or update of a maintenance configuration and the scheduled start time.

Also, ensure that your cluster is started when the planned maintenance window starts. If the cluster is stopped, its control plane is deallocated and no operations can be performed.

### Why was one of my agent pools upgraded outside the maintenance window?

AKS starts upgrade-related operations only during the configured maintenance window. If an operation begins before the window closes, it can continue running until completion, even if this extends beyond the window end time.

When the window closes, AKS does not start any new upgrade operations. Any remaining upgrade work is deferred until a future eligible window.

Example: If the maintenance window is 08:00-12:00 and a cluster or node pool upgrade that started before 12:00 is still in progress at 12:15, AKS lets that in-flight work finish. However, AKS does not initiate new upgrade work after 12:00.

### Are there any best practices for the maintenance configurations?

We recommend setting the [node OS security updates](auto-upgrade-node-image) schedule to a weekly cadence if you're using the `NodeImage` channel, because a new node image is shipped every week. You can also opt in for the `SecurityPatch` channel to receive daily security updates.

You can set the [auto-upgrade](auto-upgrade-cluster) schedule to a monthly cadence to stay current with the Kubernetes N-2 [support policy](support-policies).

For a detailed discussion of upgrade best practices and other considerations, see [AKS patch and upgrade guidance](/en-us/azure/architecture/operator-guides/aks/aks-upgrade-practices).

### Can I configure all my clusters in a single subscription to use the same maintenance configuration?

We don't recommend using the same maintenance configuration for multiple clusters in a single subscription, as doing so can lead to ARM throttling errors causing cluster upgrades to fail. Instead, we recommend staggering the maintenance windows for each cluster to avoid these errors.

### Why did my node pools get upgraded twice during the same maintenance window?

If a newer version of the node image becomes available during the maintenance window, AKS performs a second upgrade to ensure that your node pools are running the latest version. This behavior is normal and doesn't indicate an issue.

### Can Azure use the AKS planned maintenance window for platform maintenance on the underlying VMSS?

No. The AKS planned maintenance window is specifically intended to schedule and control AKS cluster and node image upgrades in Azure Kubernetes Service. It does not apply to Azure platform‑level maintenance on the underlying VMSS hosting the AKS node pools. They operate independently with no direct dependency between them.

Azure periodically performs platform updates to enhance the reliability, performance, and security of the underlying host infrastructure for virtual machines. These updates might include patching software components, upgrading networking infrastructure, or decommissioning hardware. Platform maintenance can be either rebootless or require a reboot. For maintenance events that require a reboot, customers are notified in advance through Maintenance Notifications, which include a `self‑service phase` that typically lasts up to four weeks.