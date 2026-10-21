---
layout: Conceptual
title: Azure Kubernetes Service (AKS) for Extended Zones - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/extended-zones
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
description: Learn how to deploy an Azure Kubernetes Service (AKS) for Azure Extended Zones.
author: schaffererin
ms.author: schaffererin
ms.custom: aks-reliability
ms.topic: how-to
ms.date: 2026-06-11T00:00:00.0000000Z
locale: en-us
document_id: 0def392a-18cb-a630-cd65-e1fd5b99b712
document_version_independent_id: 968bd11c-853e-e0ba-5dbf-919880cc5e7e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/extended-zones.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/extended-zones
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/extended-zones.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: e41bb9a4-c685-a41f-d36d-2c1b6c33b464
---

# Azure Kubernetes Service (AKS) for Extended Zones - Azure Kubernetes Service | Microsoft Learn

Azure Kubernetes Service (AKS) for Extended Zones provides an extensive and sophisticated set of capabilities that make it simpler to deploy and operate a fully managed Kubernetes cluster in an Extended Zone scenario.

AKS is generally available in Azure Extended Zones for **public clusters** and **private clusters**. For the up-to-date list of supported services and features, see [Service offerings for Azure Extended Zones](/en-us/azure/extended-zones/overview#service-offerings-for-azure-extended-zones).

## What are Azure Extended Zones?

Azure Extended Zones are small-footprint extensions of Azure placed in metros, industry centers, or a specific jurisdiction to serve low latency and data residency workloads. Azure Extended Zones supports virtual machines (VMs), containers, storage, and a selected set of Azure services. They can run latency-sensitive and throughput-intensive applications close to end users and within approved data residency boundaries.

Azure Extended Zones are part of the Microsoft global network that provides secure, reliable, high-bandwidth connectivity between applications that run on an Azure Extended Zone close to the user. Extended Zones address low latency and data residency by bringing all the benefits of the Azure ecosystem (access, user experience, automation, security, and more) closer to you or your jurisdiction. Azure Extended Zone sites are associated with a parent Azure region that hosts all the control plane functions associated with the services running in the extended zone.

For more information, see the [Azure Extended Zones overview](/en-us/azure/extended-zones/overview).

## What is AKS for Extended Zones?

AKS for Extended Zones enables organizations to meet the unique needs of extended zones while leveraging the container orchestration and management capabilities of AKS, making the deployment and management of applications hosted in extended zones much simpler. Just like a typical AKS deployment, the Azure platform is responsible for maintaining the AKS control plane and providing the infrastructure, while your organization retains control over the worker nodes that run the applications.

![An architecture diagram of an AKS for Azure Extended Zones deployment, showing that the control plane is deployed in an Azure region while agent nodes are deployed in an Azure Extended Zone.](media/extended-zones/aez-aks-architecture.png)

Creating an AKS for Extended Zones cluster uses an optimized architecture that is specifically tailored to meet the unique needs and requirements of Extended Zones applications and workloads. The control plane of the clusters is created, deployed, and configured in the closest Azure region, while the agent nodes and node pools attached to the cluster are located in an Azure Extended Zone. The components in an AKS for Extended Zones cluster are identical to those in a typical cluster deployed in an Azure region, ensuring that the same level of functionality and performance is maintained. For more information, see [Kubernetes core concepts for AKS](/en-us/azure/aks/core-aks-concepts).

## Deploy a cluster in an Azure Extended Zone location

Deploying an AKS cluster in an Azure Extended Zone is similar to deploying an AKS cluster in any other region. All resource providers provide a field named [`extendedLocation`](/en-us/javascript/api/@azure/arm-compute/extendedlocation), which you can use to deploy resources in an Azure Extended Zone. This allows for precise and targeted deployment of your AKS cluster.

### Prerequisites

- Before you can deploy an AKS for Extended Zones cluster, your subscription needs to have access to the targeted Azure Extended Zone location. This access is provided through our onboarding process, done by following the steps outlined in the [Azure Extended Zones overview](/en-us/azure/extended-zones/overview).
- Your cluster must be running Kubernetes version 1.24 or later.
- The identity you're using to create your cluster must have the appropriate minimum permissions. For more information on access and identity for AKS, see [Access and identity options for Azure Kubernetes Service (AKS)](concepts-identity).

### Limitations and constraints

When deploying an AKS cluster in an Azure Extended Zone, the following limitations and constraints apply:

- AKS for Extended Zones allows for autoscaling only up to 100 nodes in a node pool.
- In all Azure Extended Zones, the maximum node count is 100.
- In Azure Extended Zones, only selected VM SKUs are offered.

# [ARM template](#tab/azure-resource-manager)
You use the `extendedLocation` parameter to specify the desired Azure Extended zone in an ARM template.

```json
"extendedLocation": {
    "name": "<extended-zone-id>",
    "type": "EdgeZone",
},
```

The following ARM template deploys a new cluster in an Azure Extended Zone.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.9.1.41621",
      "templateHash": "2637152180661081755"
    }
  },
  "parameters": {
    "clusterName": {
      "type": "string",
      "defaultValue": "myAKSCluster",
      "metadata": {
        "description": "The name of the Managed Cluster resource."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location of the Managed Cluster resource."
      }
    },
    "edgeZoneName": {
      "type": "String",
      "metadata": {
        "description": "The name of the Azure Extended Zone"
      }
    },
    "dnsPrefix": {
      "type": "string",
      "metadata": {
        "description": "Optional DNS prefix to use with hosted Kubernetes API server FQDN."
      }
    },
    "osDiskSizeGB": {
      "type": "int",
      "defaultValue": 0,
      "maxValue": 1023,
      "minValue": 0,
      "metadata": {
        "description": "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize."
      }
    },
    "agentCount": {
      "type": "int",
      "defaultValue": 3,
      "maxValue": 50,
      "minValue": 1,
      "metadata": {
        "description": "The number of nodes for the cluster."
      }
    },
    "agentVMSize": {
      "type": "string",
      "defaultValue": "standard_d2s_v3",
      "metadata": {
        "description": "The size of the Virtual Machine."
      }
    },
    "linuxAdminUsername": {
      "type": "string",
      "metadata": {
        "description": "User name for the Linux Virtual Machines."
      }
    },
    "sshRSAPublicKey": {
      "type": "string",
      "metadata": {
        "description": "Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example 'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm'"
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ContainerService/managedClusters",
      "apiVersion": "2024-09-01",
      "name": "[parameters('clusterName')]",
      "location": "[parameters('location')]",
      "extendedLocation": {
        "name": "[parameters('edgeZoneName')]",
        "type": "EdgeZone"
      },
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "dnsPrefix": "[parameters('dnsPrefix')]",
        "agentPoolProfiles": [
          {
            "name": "agentpool",
            "osDiskSizeGB": "[parameters('osDiskSizeGB')]",
            "count": "[parameters('agentCount')]",
            "vmSize": "[parameters('agentVMSize')]",
            "osType": "Linux",
            "mode": "System"
          }
        ],
        "linuxProfile": {
          "adminUsername": "[parameters('linuxAdminUsername')]",
          "ssh": {
            "publicKeys": [
              {
                "keyData": "[parameters('sshRSAPublicKey')]"
              }
            ]
          }
        }
      }
    }
  ],
  "outputs": {
    "controlPlaneFQDN": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.ContainerService/managedClusters', parameters('clusterName'))).fqdn]"
    }
  }
}
```

If you're unfamiliar with ARM templates, see the tutorial on [deploying a local ARM template](/en-us/azure/azure-resource-manager/templates/deployment-tutorial-local-template).

# [Azure CLI](#tab/azure-cli)
Prepare the following variables to deploy an AKS cluster in an Azure Extended Zone using the Azure CLI:

```azurecli
SUBSCRIPTION="<your-subscription>"
RG_NAME="<your-resource-group>"
CLUSTER_NAME="<your-cluster>"
EXTENDED_ZONE_NAME="<extended-zone-id>"
LOCATION="<parent-region>" # Ensure this location corresponds to the parent region for your targeted Azure Extended Zone
```

After making sure you're logged in and using the appropriate subscription, use [`az aks create`](/en-us/cli/azure/aks#az-aks-create) to deploy the cluster, specifying the targeted Azure Extended Zone with the `--edge-zone` property.

#### Create a public cluster

```azurecli
# Log in to Azure
az login

# Set the subscription you want to create the cluster on
az account set --subscription $SUBSCRIPTION 

# Create the resource group
az group create --name $RG_NAME --location $LOCATION

# Deploy the cluster in your designated Azure Extended Zone
az aks create \
    --resource-group $RG_NAME \
    --name $CLUSTER_NAME \
    --edge-zone $EXTENDED_ZONE_NAME \
    --location $LOCATION \
    --generate-ssh-keys
```

#### Create a private cluster

To deploy a [private AKS cluster](private-clusters) in an Azure Extended Zone, add the `--enable-private-cluster` flag.

```azurecli
az aks create \
    --resource-group $RG_NAME \
    --name $CLUSTER_NAME \
    --edge-zone $EXTENDED_ZONE_NAME \
    --location $LOCATION \
    --enable-private-cluster \
    --generate-ssh-keys
```

After deploying an AKS for Extended Zones cluster, you can check the status and monitor the cluster's metrics using the Azure portal or the Azure CLI.

# [Terraform](#tab/terraform)
The following code creates a resource group and a Kubernetes cluster in Azure, with auto-scaling enabled and specific network settings, using Terraform.

Note

The sample code for this article is located in the [Azure Terraform GitHub repo](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-extended-zones). You can view the log file containing the [test results from current and previous versions of Terraform](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-extended-zones/TestRecord.md).

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
    
    resource "random_pet" "azurerm_kubernetes_cluster_name" {
      prefix = "cluster"
    }
    
    resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
      prefix = "dns"
    }
    
    resource "azapi_resource" "aks" {
      type      = "Microsoft.ContainerService/ManagedClusters@2024-05-01"
      name      = random_pet.azurerm_kubernetes_cluster_name.id
      parent_id = azurerm_resource_group.rg.id
      location  = azurerm_resource_group.rg.location
      identity {
        type = "SystemAssigned"
      }
      body = {
        extendedLocation = {
          name = replace(lower(var.aks_extended_zone), " ", "")
          type = "EdgeZone"
        }
        sku = {
          name = "Base"
          tier = "Free"
        }
        properties = {
          dnsPrefix         = random_pet.azurerm_kubernetes_cluster_dns_prefix.id
          kubernetesVersion = "1.29"
          agentPoolProfiles = [
            {
              name                   = "agentpool"
              count                  = var.aks_node_count
              vmSize                 = var.aks_node_vm_size
              osDiskSizeGB           = 128
              kubeletDiskType        = "OS"
              maxPods                = 30
              type                   = "VirtualMachineScaleSets"
              enableAutoScaling      = false,
              scaleDownMode          = "Delete",
              orchestratorVersion    = "1.29"
              enableNodePublicIP     = false
              mode                   = "System"
              enableEncryptionAtHost = false
              enableUltraSSD         = false
              osType                 = "Linux"
              osSKU                  = "Ubuntu"
              upgradeSettings = {
                maxSurge = "10%"
              }
              enableFIPS = false
            }
          ]
          windowsProfile = {
            adminUsername  = var.admin_username
            adminPassword  = var.admin_password
            licenseType    = "None"
            enableCSIProxy = true
          }
          servicePrincipalProfile = {
            clientId = "msi"
          }
          enableRBAC  = true
          supportPlan = "KubernetesOfficial"
          networkProfile = {
            networkPlugin    = "azure"
            networkPolicy    = "none"
            networkDataplane = "azure"
            loadBalancerSku  = "standard"
            loadBalancerProfile = {
              managedOutboundIPs = {
                count = 1
              }
              backendPoolType = "nodeIPConfiguration"
            }
            serviceCidr  = "10.0.0.0/16"
            dnsServiceIP = "10.0.0.10"
            outboundType = "loadBalancer"
            serviceCidrs = [
              "10.0.0.0/16",
            ]
            ipFamilies = ["IPv4"]
          }
          autoUpgradeProfile = {
            upgradeChannel       = "none"
            nodeOSUpgradeChannel = "NodeImage"
          }
          disableLocalAccounts = false
          storageProfile = {
            diskCSIDriver = {
              enabled = true
            }
            fileCSIDriver = {
              enabled = true
            }
            snapshotController = {
              enabled = true
            }
          }
          oidcIssuerProfile = {
            enabled = false
          }
          azureMonitorProfile = {
            metrics = {
              enabled = false
            }
          }
        }
      }
      timeouts {
        create = "6h"
      }
    }
    ```
3. Create a file named `outputs.tf`, and insert the following code:

    ```Terraform
    output "resource_group_name" {
      value = azurerm_resource_group.rg.name
    }
    
    output "aks_cluster_name" {
      value = azapi_resource.aks.name
    }
    
    output "aks_extended_zone" {
      value = azapi_resource.aks.body.extendedLocation.name
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
        azapi = {
          source  = "Azure/azapi"
          version = "2.0.1"
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
    variable "resource_group_name_prefix" {
      type        = string
      default     = "rg"
      description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
    }
    
    variable "resource_group_location" {
      type        = string
      default     = "West US"
      description = "Location of the resource group."
    }
    
    variable "virtual_network_name" {
      type        = string
      description = "Virtual network names"
      default     = "example-vnet"
    }
    
    variable "aks_node_count" {
      type        = number
      description = "AKS node count"
      default     = 3
    }
    
    variable "aks_node_vm_size" {
      type        = string
      description = "AKS node VM size"
      default     = "Standard_D2_v2"
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
    
    variable "aks_extended_zone" {
      type        = string
      description = "AKS extended zone"
      default     = "Los Angeles"
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