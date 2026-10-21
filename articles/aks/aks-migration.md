---
layout: Conceptual
title: Migrate to Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/aks-migration
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
description: This article shows you how to migrate to Azure Kubernetes Service (AKS).
ms.topic: concept-article
ms.date: 2024-06-12T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.custom: mvc, devx-track-azurecli, aks-migration
ms.collection:
- migration
locale: en-us
document_id: 366cbcc6-5981-1cbd-e972-4a26a2709bca
document_version_independent_id: ac540a05-6247-3e99-56c8-bbdd98cab238
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/aks-migration.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/aks-migration
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/aks-migration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 8d2bf6ac-56da-cc59-b619-7d7f8a1494e9
---

# Migrate to Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

To help you plan and execute a successful migration to Azure Kubernetes Service (AKS), this guide provides details for the current recommended AKS configuration. While this article doesn't cover every scenario, it contains links to more detailed information for planning a successful migration.

In this article, we summarize migration details for:

- Containerizing applications through Azure Migrate
- AKS with Azure Load Balancer (Standard) and Virtual Machine Scale Sets
- Existing attached Azure services
- Ensure valid quotas
- High availability and business continuity
- Considerations for stateless applications
- Considerations for stateful applications
- Deployment of your cluster configuration

Note

Depending on your scenario, the following open-source tools might help with your migration:

- [Velero](https://velero.io/) (Requires Kubernetes 1.7+)
- [Azure Kube CLI extension](https://github.com/yaron2/azure-kube-cli)

## Before you begin

- Ensure your target Kubernetes version is within the supported window for AKS. Older versions may not be within the supported range and require a version upgrade for AKS support. For more information, see [AKS supported Kubernetes versions](supported-kubernetes-versions).
- If you're migrating to a newer version of Kubernetes, review the [Kubernetes version and version skew support policy](https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions).

An important practice that you should include as part of your migration process is remembering to follow commonly used deployment and testing patterns. Testing your application before deployment is an important step to ensure its quality, functionality, and compatibility with the target environment. It can help you identify and fix any errors, bugs, or issues that might affect the performance, security, or usability of the application or underlying infrastructure.

## Use Azure Migrate to migrate your applications to AKS

Azure Migrate offers a unified platform to assess and migrate to Azure on-premises servers, infrastructure, applications, and data. For AKS, you can use Azure Migrate for the following tasks:

- [Containerizing ASP.NET applications and migrating to AKS](/en-us/azure/migrate/tutorial-app-containerization-aspnet-kubernetes).
- [Containerizing Java web applications and migrating to AKS](/en-us/azure/migrate/tutorial-app-containerization-java-kubernetes).

## AKS with Standard Load Balancer and Virtual Machine Scale Sets

AKS is a managed service offering unique capabilities with lower management overhead. Since AKS is a managed service, you must select from a set of AKS-supported [regions](quotas-skus-regions). You may need to modify your existing applications to keep them healthy on the AKS-managed control plane during the transition from your existing cluster to AKS.

We recommend using AKS clusters backed by [Virtual Machine Scale Sets](/en-us/azure/virtual-machine-scale-sets/) and [Load Balancer (Standard)](load-balancer-standard) to ensure you get the following features:

- [Multiple node pools](create-node-pools),
- [Availability zones](/en-us/azure/reliability/availability-zones-overview),
- [Authorized IP ranges](api-server-authorized-ip-ranges),
- [Cluster autoscaler](cluster-autoscaler),
- [Azure Policy for AKS](/en-us/azure/governance/policy/concepts/policy-for-kubernetes), and
- Other new features as they're released.

AKS clusters backed by [virtual machine (VM) availability sets](/en-us/azure/virtual-machines/availability#availability-sets) lack support for many of these features.

### Create an AKS cluster with Load Balancer (Standard) and Virtual Machine Scale Sets

# [Azure CLI](#tab/azure-cli)
The following example creates an AKS cluster with single node pool backed by a Virtual Machine Scale Set. It enables the cluster autoscaler on the node pool for the cluster and sets a minimum of *one* and a maximum of *three* nodes.

1. Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    First, export variables and add a random suffix to ensure resource names are unique. A reliable VM size is also specified for broad subscription compatibility.

    ```azurecli
    export RANDOM_SUFFIX=$(head -c 3 /dev/urandom | xxd -p)
    export RESOURCE_GROUP="myResourceGroup$RANDOM_SUFFIX"
    export REGION="eastus2"
    az group create --name $RESOURCE_GROUP --location $REGION
    ```

    Results:

    ```output
    {
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroupxxx",
      "location": "eastus2",
      "managedBy": null,
      "name": "myResourceGroupxxx",
      "properties": {
        "provisioningState": "Succeeded"
      },
      "tags": null,
      "type": "Microsoft.Resources/resourceGroups"
    }
    ```
2. Create an AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

    Set the cluster name and create an AKS cluster with autoscaler and standard load balancer. The VM size is set to Standard\_DS2\_v2 for reliability in most subscriptions.

    ```azurecli
    export CLUSTER_NAME="myAKSCluster$RANDOM_SUFFIX"
    az aks create \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --node-count 1 \
        --node-vm-size Standard_DS2_v2 \
        --vm-set-type VirtualMachineScaleSets \
        --load-balancer-sku standard \
        --enable-cluster-autoscaler \
        --min-count 1 \
        --max-count 3 \
        --generate-ssh-keys
    ```

    Results:

    ```output
    {
      "aadProfile": null,
      "addonProfiles": {},
      "agentPoolProfiles": [
        {
          "count": 1,
          "enableAutoScaling": true,
          "maxCount": 3,
          "minCount": 1,
          "name": "nodepool1",
          "orchestratorVersion": "x.xx.x",
          "osType": "Linux",
          "provisioningState": "Succeeded",
          "vmSize": "Standard_DS2_v2",
          "type": "VirtualMachineScaleSets"
        }
      ],
      "dnsPrefix": "myaksclusterxxx-dns-xxxxxxxx",
      "enableRBAC": true,
      "fqdn": "myaksclusterxxx-dns-xxxxxxxx.eastus2.cloudapp.azure.com",
      ...
      "provisioningState": "Succeeded",
      ...
    }
    ```

# [Terraform](#tab/terraform)
The following code creates a resource group and a Kubernetes cluster in Azure, with auto-scaling enabled and specific network settings, using Terraform.

Note

The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-standard-lb-and-vmss). You can view the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-standard-lb-and-vmss/TestRecord.md).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/terraform)

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
    
    resource "random_string" "aks_cluster_name" {
      length  = 12
      special = false
    }
    
    resource "azurerm_kubernetes_cluster" "aks_cluster" {
      name                = random_string.aks_cluster_name.result
      location            = azurerm_resource_group.rg.location
      resource_group_name = azurerm_resource_group.rg.name
      dns_prefix          = "myakscluster"
    
      default_node_pool {
        type                = "VirtualMachineScaleSets"
        name                = "default"
        node_count          = 1
        max_count           = 3
        min_count           = 1
        vm_size             = "Standard_DS2_v2"
        enable_auto_scaling = true
        upgrade_settings {
          drain_timeout_in_minutes      = 90
          max_surge                     = "10%"
          node_soak_duration_in_minutes = 0
        }
      }
    
      network_profile {
        network_plugin    = "azure"
        load_balancer_sku = "standard"
      }
    
      identity {
        type = "SystemAssigned"
      }
    
      tags = {
        Environment = "Production"
      }
    }
    ```
3. Create a file named `outputs.tf`, and insert the following code:

    ```Terraform
    output "resource_group_name" {
      value = azurerm_resource_group.rg.name
    }
    
    output "aks_cluster_name" {
      value = azurerm_kubernetes_cluster.aks_cluster.name
    }
    ```
4. Create a file named `providers.tf`, and insert the following code:

    ```Terraform
    terraform {
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
6. Initialize Terraform.

    Run [terraform init](https://www.terraform.io/docs/commands/init.html) to initialize the Terraform deployment. This command downloads the Azure provider required to manage your Azure resources.

    ```console
    terraform init -upgrade
    ```

    **Key points:**

    - The `-upgrade` parameter upgrades the necessary provider plugins to the newest version that complies with the configuration's version constraints.
7. Create a Terraform execution plan.

    Run [terraform plan](https://www.terraform.io/docs/commands/plan.html) to create an execution plan.

    ```console
    terraform plan -out main.tfplan
    ```

    **Key points:**

    - The `terraform plan` command creates an execution plan, but doesn't execute it. Instead, it determines what actions are necessary to create the configuration specified in your configuration files. This pattern allows you to verify whether the execution plan matches your expectations before making any changes to actual resources.
    - The optional `-out` parameter allows you to specify an output file for the plan. Using the `-out` parameter ensures that the plan you reviewed is exactly what is applied.
8. Apply a Terraform execution plan.

    Run [terraform apply](https://www.terraform.io/docs/commands/apply.html) to apply the execution plan to your cloud infrastructure.

    ```console
    terraform apply main.tfplan
    ```

    **Key points:**

    - The example `terraform apply` command assumes you previously ran `terraform plan -out main.tfplan`.
    - If you specified a different filename for the `-out` parameter, use that same filename in the call to `terraform apply`.
    - If you didn't use the `-out` parameter, call `terraform apply` without any parameters.

---

## Existing attached Azure Services

When migrating clusters, you may have attached external Azure services. While the following services don't require resource recreation, they require updating connections from previous to new clusters to maintain functionality:

- Azure Container Registry
- Azure Log Analytics
- Azure Application Insights
- Azure Traffic Manager
- Azure Storage account
- External databases

## Ensure valid quotas

Since other VMs are deployed into your subscription during migration, you should verify your quotas and limits are sufficient for these resources. If necessary, request an increase in [vCPU quota](/en-us/azure/azure-portal/supportability/per-vm-quota-requests).

You may need to request an increase for [network quotas](/en-us/azure/azure-portal/supportability/networking-quota-requests) to ensure you don't exhaust IPs. For more information, see [networking and IP ranges for AKS](configure-kubenet).

For more information, see [Azure subscription and service limits](/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits). To check your current quotas, in the Azure portal, go to the [subscriptions blade](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade), select your subscription, and then select **Usage + quotas**.

## High availability and business continuity

If your application can't handle downtime, you need to follow best practices for high availability migration scenarios. Read more about [Best practices for complex business continuity planning, disaster recovery, and maximizing uptime in Azure Kubernetes Service (AKS)](operator-best-practices-multi-region).

For complex applications, you typically migrate over time rather than all at once, meaning the old and new environments might need to communicate over the network. Applications previously using `ClusterIP` services to communicate might need to be exposed as type `LoadBalancer` and secured appropriately.

To complete the migration, you want to point clients to the new services that run on AKS. We recommend you redirect traffic by updating DNS to point to the load balancer sitting in front of your AKS cluster.

[Azure Traffic Manager](/en-us/azure/traffic-manager/) can direct customers to the desired Kubernetes cluster and application instance. Traffic Manager is a DNS-based traffic load balancer that can distribute network traffic across regions. For the best performance and redundancy, direct all application traffic through Traffic Manager before it goes to your AKS cluster.

In a multi-cluster deployment, customers should connect to a Traffic Manager DNS name that points to the services on each AKS cluster. Define these services by using Traffic Manager endpoints. Each endpoint is the *service load balancer IP*. Use this configuration to direct network traffic from the Traffic Manager endpoint in one region to the endpoint in a different region.

![AKS with Traffic Manager](media/operator-best-practices-bc-dr/aks-azure-traffic-manager.png)

[Azure Front Door](/en-us/azure/frontdoor/front-door-overview) is another option for routing traffic for AKS clusters. With Azure Front Door, you can define, manage, and monitor the global routing for your web traffic by optimizing for best performance and instant global failover for high availability.

### Considerations for stateless applications

Stateless application migration involves the following steps:

1. Apply your resource definitions (YAML or Helm) to the new cluster.
2. Ensure everything works as expected.
3. Redirect traffic to activate your new cluster.

### Considerations for stateful applications

Carefully plan your migration of stateful applications to avoid data loss or unexpected downtime.

- If you use Azure Files, you can mount the file share as a volume into the new cluster. See [Mount Static Azure Files as a Volume](azure-csi-files-storage-provision#mount-file-share-as-a-persistent-volume).
- If you use Azure Managed Disks, you can only mount the disk if unattached to any VM. See [Mount Static Azure Disk as a Volume](azure-csi-disk-storage-provision#mount-disk-as-a-volume).
- If neither of those approaches work, you can use a backup and restore options. See [Velero on Azure](https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/blob/master/README.md).

#### Azure Files

Unlike disks, Azure Files can be mounted to multiple hosts concurrently. In your AKS cluster, Azure and Kubernetes don't prevent you from creating a pod that your AKS cluster still uses. To prevent data loss and unexpected behavior, ensure the clusters don't simultaneously write to the same files.

If your application can host multiple replicas that point to the same file share, follow the stateless migration steps and deploy your YAML definitions to your new cluster.

If not, a possible migration approach involves the following steps:

1. Validate your application is working correctly.
2. Point your live traffic to your new AKS cluster.
3. Disconnect the old cluster.

If you want to start with an empty share and make a copy of the source data, you can use the [`az storage file copy`](/en-us/cli/azure/storage/file/copy) command to migrate your data.

#### Migrating persistent volumes

If you're migrating existing persistent volumes to AKS, you generally follow these steps:

1. Quiesce writes to the application.
    - This step is optional and requires downtime.
2. Take snapshots of the disks.
3. Create new managed disks from the snapshots.
4. Create persistent volumes in AKS.
5. Update pod specifications to [use existing volumes](azure-disk-csi) rather than PersistentVolumeClaims (static provisioning).
6. Deploy your application to AKS.
7. Validate your application is working correctly.
8. Point your live traffic to your new AKS cluster.

Important

If you choose not to quiesce writes, you need to replicate data to the new deployment. Otherwise, you miss the data that was written after you took the disk snapshots.

The following open-source tools can help you create managed disks and migrate volumes between Kubernetes clusters:

- [Azure CLI Disk Copy extension](https://github.com/noelbundick/azure-cli-disk-copy-extension) copies and converts disks across resource groups and Azure regions.
- [Azure Kube CLI extension](https://github.com/yaron2/azure-kube-cli) enumerates ACS Kubernetes volumes and migrates them to an AKS cluster.

### Deployment of your cluster configuration

We recommend you use your existing continuous integration and continuous delivery pipeline to deploy a known-good configuration to AKS. You can use Azure Pipelines to [build and deploy your applications to AKS](/en-us/azure/devops/pipelines/ecosystems/kubernetes/aks-template). Clone your existing deployment tasks and ensure `kubeconfig` points to the new AKS cluster.

If that's not possible, export resource definitions from your existing Kubernetes cluster, and then apply them to AKS. You can use `kubectl` to export objects. For example:

```console
kubectl get deployment -o yaml > deployments.yaml
```

Be sure to examine the output and remove any unnecessary live data fields.

### Moving existing resources to another region

You might want to move your AKS cluster to a [different region supported by AKS](https://azure.microsoft.com/global-infrastructure/services/?products=kubernetes-service). We recommend you create a new cluster in the other region and then deploy your resources and applications to your new cluster.

If you have any services running on your AKS cluster, you need to install and configure those services on your cluster in the new region.

In this article, we summarized migration details for:

- Containerizing applications through Azure Migrate
- AKS with Load Balancer (Standard) and Virtual Machine Scale Sets
- Existing attached Azure services
- Ensuring valid quotas
- High availability and business continuity
- Considerations for stateless applications
- Considerations for stateful applications
- Deploying your cluster configuration