---
layout: Conceptual
title: Create a Private Azure Kubernetes Service (AKS) Cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/private-clusters
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
description: Learn how to create a private Azure Kubernetes Service (AKS) cluster with enhanced security and network control using Azure CLI or Terraform.
ms.topic: how-to
ms.author: schaffererin
author: schaffererin
ms.date: 2026-08-05T00:00:00.0000000Z
ms.custom: references_regions, devx-track-azurecli
ms.subservice: aks-security
zone_pivot_groups: azure-cli-or-terraform
locale: en-us
document_id: bb005ef0-13c1-05bd-1a19-aae65149ffbb
document_version_independent_id: 028051c9-b3cc-5b7d-c379-c14f2bf78e71
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/private-clusters.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/private-clusters
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/private-clusters.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 8503d509-6b97-b2f1-2378-c18f2befdc0d
---

# Create a Private Azure Kubernetes Service (AKS) Cluster - Azure Kubernetes Service | Microsoft Learn

This article helps you deploy a private link-based AKS cluster using Azure CLI or Terraform. If you're interested in creating an AKS cluster without required private link or tunnel, see [Create an Azure Kubernetes Service (AKS) cluster with API Server VNet integration](api-server-vnet-integration).

## Overview of private clusters in AKS

In a private cluster, the control plane or API server has internal IP addresses that are defined in the [RFC1918 - Address Allocation for Private Internet](https://tools.ietf.org/html/rfc1918) document. By using a private cluster, you can ensure network traffic between your API server and your node pools remains only on the private network.

The control plane or API server is in an AKS-managed Azure resource group, and your cluster or node pool is in your resource group. The API server and the cluster or node pool can communicate with each other through the [Azure Private Link service](/en-us/azure/private-link/private-link-service-overview#limitations) in the API server virtual network and a private endpoint exposed on the subnet of your AKS cluster.

When you create a private AKS cluster, AKS creates both private and public fully qualified domain names (FQDNs) with corresponding DNS zones by default. For detailed DNS configuration options, see Configure a private DNS zone, private DNS subzone, or custom subdomain.

Note

AKS places the API server private endpoint in the subnet used by the first node pool in the cluster configuration. If the first node pool changes, AKS might recreate the private endpoint in a different subnet during a [cluster stop/start operation](start-stop-cluster#about-the-cluster-stopstart-feature).

## Region availability

Private clusters are available in public regions, Azure Government, and Microsoft Azure operated by 21Vianet regions where [AKS is supported](https://azure.microsoft.com/global-infrastructure/services/?products=kubernetes-service).

Important

All Microsoft Defender for Cloud features will be officially retired in the Azure in China region on August 18, 2026. Due to this upcoming retirement, Azure in China customers are no longer able to onboard new subscriptions to the service. A new subscription is any subscription that was not already onboarded to the Microsoft Defender for Cloud service prior to August 18, 2025, the date of the retirement announcement. For more information on the retirement, see [Microsoft Defender for Cloud Deprecation in Microsoft Azure Operated by 21Vianet Announcement](https://aka.ms/mdcretirementinchina).

Customers should work with their account representatives for Microsoft Azure operated by 21Vianet to assess the impact of this retirement on their own operations.

## Prerequisites for private AKS clusters

- An active Azure subscription. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Set your subscription context using the [`az account set`](/en-us/cli/azure/account#az_account_set) command. For example:

    ```azurecli
    az account set --subscription "00000000-0000-0000-0000-000000000000"
    ```
- Azure CLI version 2.28.0 or higher. Find your version using the `az --version` command. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- If using Azure Resource Manager (ARM) or the Azure REST API, the AKS API version must be *2021-05-01 or higher*.
- If you use a custom DNS server, it must be able to resolve the cluster's private DNS zone, and AKS nodes must reach it over both UDP and TCP port 53:

    - Configure a conditional forwarder for the cluster's private DNS zone that forwards to the Azure DNS virtual server at `168.63.129.16`. Alternatively, use Azure DNS Private Resolver in a virtual network linked to the private DNS zone. For more information about the Azure IP address, see [What is IP address 168.63.129.16?](/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16). For zone-name information, see [Azure services DNS zone configuration](/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration).
    - Ensure that AKS nodes can reach the custom DNS server over both UDP and TCP port 53.
    - Ensure that the custom DNS server listens and responds on both UDP and TCP port 53.
    - Ensure that NSGs, firewalls, NVAs, and routes don't block either protocol.
- Existing AKS clusters enabled with API Server VNet integration can have private cluster mode enabled. For more information, see [Enable or disable private cluster mode on an existing cluster with API Server VNet integration](api-server-vnet-integration#enable-or-disable-private-cluster-mode-on-an-existing-cluster-with-api-server-vnet-integration).
- If you need to enable Azure Container Registry on a private AKS cluster, [set up a private link for the container registry in the cluster virtual network (VNet)](/en-us/azure/container-registry/container-registry-private-link) or set up peering between the container registry's VNet and the private cluster's VNet.
- [kubectl](https://kubernetes.io/releases/download/) installed. You can install it locally using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.

::: zone pivot="terraform"

- Terraform installed locally. For installation instructions, see [Install Terraform](https://developer.hashicorp.com/terraform/install).

::: zone-end

Important

Starting with Kubernetes 1.37, LocalDNS can become active when an eligible AKS Standard node pool without an explicit LocalDNS profile is created or upgraded. By using `PreferUDP`, LocalDNS retries over TCP when a UDP response is truncated. Validate both protocols before upgrading:

```bash
dig +udp @<custom-dns-ip> <private-or-public-fqdn>
dig +tcp @<custom-dns-ip> <private-or-public-fqdn>
```

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Limitations

- IP authorized ranges only apply to the public API server. You can't apply these ranges to the private API server endpoint.
- [Azure Private Link service limitations](/en-us/azure/private-link/private-link-service-overview#limitations) apply to private clusters.
- There's no support for Azure DevOps Microsoft-hosted Agents with private clusters. Consider using [self-hosted agents](/en-us/azure/devops/pipelines/agents/agents).
- Deleting or modifying the private endpoint in the customer subnet causes the cluster to stop functioning.
- Azure Private Link service supports only Standard Load Balancer. Basic Load Balancer isn't supported.

## Hub and spoke with custom DNS for private AKS clusters

[Hub and spoke architectures](/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) are commonly used to deploy networks in Azure. In many of these deployments, DNS settings in the spoke VNets are configured to reference a central DNS forwarder to allow for on-premises and Azure-based DNS resolution.

The following diagram illustrates a hub and spoke architecture for a private AKS cluster with custom DNS:

![Private cluster hub and spoke](media/private-clusters/aks-private-hub-spoke.png)

- When a private cluster is created, a private endpoint (1) and a private DNS zone (2) are created in the cluster-managed resource group by default. The cluster uses an `A` record in the private zone to resolve the IP of the private endpoint for communication to the API server.
- The private DNS zone is linked only to the VNet that the cluster nodes are attached to (3), which means that the private endpoint can only be resolved by hosts in that linked VNet. In scenarios where no custom DNS is configured on the VNet (default), it works without issue as hosts point at *168.63.129.16* for DNS that can resolve records in the private DNS zone because of the link.
- If you keep the default private DNS zone behavior, AKS tries to link the zone directly to the spoke VNet that hosts the cluster even when the zone is already linked to a hub VNet.
    - In spoke VNets that use custom DNS servers, this action can fail if the cluster's managed identity lacks **Network Contributor** on the spoke VNet. To prevent the failure, choose **one**of the following supported configurations:
        - **Custom private DNS zone**: Provide an existing private zone and set `privateDNSZone` / `--private-dns-zone` to its resource ID. AKS still creates a virtual network link for the spoke VNet that hosts the cluster, even when the zone is already linked to a hub VNet. Ensure the cluster managed identity has **Network Contributor** on the spoke VNet, then set `publicDNS` to `false` / use `--disable-public-fqdn`.
        - **Public DNS only**: Disable private zone creation by setting `privateDNSZone` / `--private-dns-zone` to `none`**and** leave `publicDNS` at its default value (`true`) / don't use `--disable-public-fqdn`.
- If you're using [bring your own (BYO) route table with kubenet](configure-kubenet#bring-your-own-subnet-and-route-table-with-kubenet) and BYO DNS with private clusters, cluster creation fails. You need to associate the [`RouteTable`](configure-kubenet#bring-your-own-subnet-and-route-table-with-kubenet) in the node resource group to the subnet after the cluster creation failed to make the creation successful.

### Limitations for private AKS clusters with custom DNS

- Setting `privateDNSZone` / `--private-dns-zone` to `none`**and**`publicDNS: false` / `--disable-public-fqdn` at the same time **isn't supported**.
- Conditional forwarding doesn't support subdomains.

::: zone pivot="azure-cli"

## Create a resource group

Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command. You can also use an existing resource group for your AKS cluster.

```azurecli
az group create \
    --name <private-cluster-resource-group> \
    --location <location>
```

::: zone-end

## Create a private AKS cluster with default basic networking

::: zone pivot="azure-cli"

Create a private cluster with default basic networking using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-private-cluster` flag.

**Key parameters in this command**:

- `--enable-private-cluster`: Enables private cluster mode.

```azurecli
az aks create \
    --name <private-cluster-name> \
    --resource-group <private-cluster-resource-group> \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --generate-ssh-keys
```

::: zone-end

::: zone pivot="terraform"

1. Create a file named `main.tf` and add the following code to define the Terraform version and specify the Azure provider:

    ```Terraform
    terraform {
      required_version = ">= 1.3.0"
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
      }
    }
    
    provider "azurerm" {
      features {}
      subscription_id = var.subscription_id
    }
    ```
2. Add the following code to `main.tf` to create input variables for your Azure subscription ID, resource group name, location, and AKS cluster name. You can modify the default values as needed.

    ```Terraform
    variable "subscription_id" {
      description = "The Azure subscription ID."
      type = string
    }
    
    variable "resource_group_name" {
      description = "The name of the resource group for the AKS cluster."
      type        = string
      default     = "rg-private-aks-basic"
    }
    
    variable "location" {
      description = "The Azure region where the resources will be created."
      type        = string
      default     = "eastus"
    }
    
    variable "aks_cluster_name" {
      description = "The name of the AKS cluster."
      type        = string
      default     = "aks-private-basic"
    }
    ```
3. Add the following code to `main.tf` to create an Azure resource group:

    ```Terraform
    resource "azurerm_resource_group" "this" {
      name     = var.resource_group_name
      location = var.location
    }
    ```
4. Add the following code to `main.tf` to create a private AKS cluster with basic networking:

    ```Terraform
    resource "azurerm_kubernetes_cluster" "this" {
      name                = var.aks_cluster_name
      location            = azurerm_resource_group.this.location
      resource_group_name = azurerm_resource_group.this.name
      dns_prefix          = "privatebasicaks"
    
      private_cluster_enabled = true
    
      default_node_pool {
        name       = "system"
        node_count = 1
        vm_size    = "Standard_DS2_v2"
      }
    
      identity {
        type = "SystemAssigned"
      }
    
      network_profile {
        load_balancer_sku   = "standard"
        network_plugin      = "azure"
        network_plugin_mode = "overlay"
      }
    }
    ```
5. Follow the steps in Initialize Terraform, Format and validate the Terraform configuration, Create a Terraform execution plan, Apply the Terraform configuration, and Configure kubectl to connect to a private AKS cluster.

::: zone-end

## Create a private AKS cluster with advanced networking

::: zone pivot="azure-cli"

Create a private cluster with advanced networking using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

**Key parameters in this command**:

- `--enable-private-cluster`: Enables private cluster mode.
- `--network-plugin azure`: Specifies the Azure CNI networking plugin.
- `--vnet-subnet-id <subnet-id>`: The resource ID of an existing subnet in a VNet.
- `--dns-service-ip <dns-service-ip>`: An available IP address within the Kubernetes service address range to use for the cluster DNS service. For example, `10.2.0.10`.
- `--service-cidr <service-cidr>`: A CIDR notation IP range from which to assign service cluster IPs. For example, `10.2.0.0/24`.

```azurecli
az aks create \
    --resource-group <private-cluster-resource-group> \
    --name <private-cluster-name> \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --network-plugin azure \
    --vnet-subnet-id <subnet-id> \
    --dns-service-ip <dns-service-ip> \
    --service-cidr <service-cidr> \
    --generate-ssh-keys
```

::: zone-end

::: zone pivot="terraform"

1. Create a file named `main.tf` and add the following code to define the Terraform version and specify the Azure provider:

    ```Terraform
    terraform {
      required_version = ">= 1.3.0"
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
      }
    }
    
    provider "azurerm" {
      features {}
      subscription_id = var.subscription_id
    }
    ```
2. Add the following code to `main.tf` to create input variables for your Azure subscription ID, resource group name, location, AKS cluster name, virtual network (VNet) name, and subnet name. You can modify the default values as needed.

    ```Terraform
    variable "subscription_id" {
      description = "The Azure subscription ID."
      type = string
    }
    
    variable "resource_group_name" {
      description = "The name of the resource group for the AKS cluster."
      type = string
      default = "rg-private-aks-advanced"
    }
    
    variable "location" {
      description = "The Azure region where the resources will be created."
      type = string
      default = "eastus"
    }
    
    variable "aks_cluster_name" {
      description = "The name of the AKS cluster."
      type = string
      default = "aks-private-advanced"
    }
    
    variable "vnet_name" {
      description = "The name of the virtual network."
      type = string
      default = "vnet-private-aks"
    }
    
    variable "subnet_name" {
      description = "The name of the subnet used by AKS."
      type = string
      default = "snet-aks"
    }
    ```
3. Add the following code to `main.tf` to create an Azure resource group, VNet, and subnet:

    ```Terraform
    resource "azurerm_resource_group" "this" {
      name = var.resource_group_name
      location = var.location
    }
    
    resource "azurerm_virtual_network" "this" {
      name = var.vnet_name
      location = azurerm_resource_group.this.location
      resource_group_name = azurerm_resource_group.this.name
      address_space = ["10.0.0.0/8"]
    }
    
    resource "azurerm_subnet" "aks" {
      name = var.subnet_name
      resource_group_name  = azurerm_resource_group.this.name
      virtual_network_name = azurerm_virtual_network.this.name
      address_prefixes = ["10.240.0.0/16"]
    }
    ```
4. Add the following code to `main.tf` to create the AKS cluster with advanced networking:

    ```Terraform
    resource "azurerm_kubernetes_cluster" "this" {
      name = var.aks_cluster_name
      location = azurerm_resource_group.this.location
      resource_group_name = azurerm_resource_group.this.name
      dns_prefix = "privateadvancedaks"
    
      private_cluster_enabled = true
    
      default_node_pool {
        name = "system"
        node_count = 1
        vm_size = "Standard_DS2_v2"
        vnet_subnet_id = azurerm_subnet.aks.id
      }
    
      identity {
        type = "SystemAssigned"
      }
    
      network_profile {
        load_balancer_sku = "standard"
        network_plugin = "azure"
        dns_service_ip = "10.2.0.10"
        service_cidr = "10.2.0.0/24"
      }
    }
    ```
5. Follow the steps in Initialize Terraform, Format and validate the Terraform configuration, Create a Terraform execution plan, Apply the Terraform configuration, and Configure kubectl to connect to a private AKS cluster.

::: zone-end

## Use custom domains with private AKS clusters

If you want to configure custom domains that can only be resolved internally, see [Use custom domains](coredns-custom#use-custom-domains).

## Disable a public FQDN on a private AKS cluster

When you create a private AKS cluster by using `--enable-private-cluster`, AKS deploys the Kubernetes API server through a private endpoint inside the virtual network. By default, AKS might still create a public DNS name (public FQDN) for the API server unless you specify `--disable-public-fqdn`. The public FQDN is only a publicly resolvable DNS name, while API communication for private clusters still occurs through the private endpoint. Using `--disable-public-fqdn` removes the public DNS name and restricts cluster management access to private connectivity methods such as VPN, ExpressRoute, VNet peering, or Bastion hosts.

Use the following guidance:

- **Keep public FQDN enabled**: If clients on the cluster VNet or a connected network require a publicly resolvable DNS name for the API server. A public FQDN doesn't create a public API endpoint or remove the requirement for network connectivity to the private endpoint. For DevOps pipelines, use self-hosted agents on a connected network.
- **Disable public FQDN**: If you have strong security or compliance requirements, enterprise private networking is already implemented, hub and spoke secure networking architectures are used, or cluster operations must occur exclusively through private connectivity paths.

### Disable a public FQDN when creating a private AKS cluster

::: zone pivot="azure-cli"

Disable a public FQDN when creating a private AKS cluster using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--disable-public-fqdn` flag.

**Key parameters in this command**:

- `--disable-public-fqdn`: Disables the public fully qualified domain name (FQDN) for the API server.
- `--assign-identity <resource-id>`: Specifies the managed identity to use for the cluster.
- `--private-dns-zone system`: Specifies that AKS creates a private DNS zone in the node resource group. You can't use `none` when you disable the public FQDN because the cluster requires a private or public DNS zone for API server name resolution.

```azurecli
az aks create \
    --name <private-cluster-name> \
    --resource-group <private-cluster-resource-group> \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --assign-identity <resource-id> \
    --private-dns-zone system \
    --disable-public-fqdn \
    --generate-ssh-keys
```

::: zone-end

::: zone pivot="terraform"

1. Follow steps 1-3 in Create a private AKS cluster with advanced networking or Create a private AKS cluster with default basic networking to set up the Terraform configuration and create the necessary resources depending on your scenario. This example uses advanced networking.
2. Add the following code to `main.tf` to create a private AKS cluster with a user-assigned identity and the public FQDN disabled:

    ```Terraform
    resource "azurerm_user_assigned_identity" "aks" {
      name = "id-private-aks-public-fqdn-off"
      location = azurerm_resource_group.this.location
      resource_group_name = azurerm_resource_group.this.name
    }
    resource "azurerm_kubernetes_cluster" "this" {
      name = var.aks_cluster_name
      location = azurerm_resource_group.this.location
      resource_group_name = azurerm_resource_group.this.name
      dns_prefix = "privateaks"
      private_cluster_enabled = true
      private_cluster_public_fqdn_enabled = false
    
      private_dns_zone_id = "System"
    
      default_node_pool {
        name = "system"
        node_count = 1
        vm_size = "Standard_DS2_v2"
        vnet_subnet_id = azurerm_subnet.aks.id
      }
      identity {
        type = "UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.aks.id]
      }
      network_profile {
        load_balancer_sku = "standard"
        network_plugin = "azure"
        dns_service_ip = "10.2.0.10"
        service_cidr = "10.2.0.0/24"
      }
    }
    ```
3. Follow the steps in Initialize Terraform, Format and validate the Terraform configuration, Create a Terraform execution plan, Apply the Terraform configuration, and Configure kubectl to connect to a private AKS cluster.

::: zone-end

### Disable a public FQDN on an existing private AKS cluster

::: zone pivot="azure-cli"

Disable a public FQDN on an existing AKS cluster using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-public-fqdn` flag.

**Key parameters in this command**:

- `--disable-public-fqdn`: Disables the public fully qualified domain name (FQDN) for the API server.

```azurecli
az aks update \
    --name <private-cluster-name> \
    --resource-group <private-cluster-resource-group> \
    --disable-public-fqdn
```

::: zone-end

::: zone pivot="terraform"

1. Add the following code to the existing `main.tf` to disable the public FQDN on an existing AKS cluster. This example uses advanced networking. You can modify it to use default basic networking by changing the relevant Terraform resources and parameters.

    ```Terraform
    resource "azurerm_kubernetes_cluster" "this" {
      name = var.aks_cluster_name
      location = azurerm_resource_group.this.location
      resource_group_name = azurerm_resource_group.this.name
      dns_prefix = "privateaks"
    
      private_cluster_enabled = true
      private_cluster_public_fqdn_enabled = false
      private_dns_zone_id = "System"
    
      default_node_pool {
        name = "system"
        node_count = 1
        vm_size = "Standard_DS2_v2"
        vnet_subnet_id = azurerm_subnet.aks.id
      }
    
      identity {
        type = "UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.aks.id]
      }
    
      network_profile {
        load_balancer_sku = "standard"
        network_plugin = "azure"
        dns_service_ip = "10.2.0.10"
        service_cidr = "10.2.0.0/24"
      }
    }
    ```
2. Apply the updated Terraform configuration using the `terraform plan` and `terraform apply` commands.

    ```console
    terraform plan
    terraform apply
    ```

::: zone-end

::: zone pivot="azure-cli"

## Configuration options for private DNS

You can configure private DNS settings for a private AKS cluster by using Azure CLI (with the `--private-dns-zone` parameter) or an Azure Resource Manager template (with the `privateDNSZone` property). The following table describes the supported values for the Azure CLI `--private-dns-zone` parameter and the Azure Resource Manager `privateDNSZone` property:

| `--private-dns-zone`/`privateDNSZone`value | Description |
| --- | --- |
| `system` | The default value when configuring a private DNS zone. If you omit `--private-dns-zone` / `privateDNSZone`, AKS creates a private DNS zone in the node resource group. |
| `none` | If you set `--private-dns-zone` / `privateDNSZone` to `none`, AKS doesn't create a private DNS zone. |
| `<custom-private-dns-zone-resource-id>` | To use this parameter, create a private DNS zone in the following format for Azure global cloud: `privatelink.<region>.azmk8s.io` or `<subzone>.privatelink.<region>.azmk8s.io`. You need the resource ID of the private DNS zone for future use. You also need a user-assigned identity or service principal with the [Private DNS Zone Contributor](/en-us/azure/role-based-access-control/built-in-roles#dns-zone-contributor) and [Network Contributor](/en-us/azure/role-based-access-control/built-in-roles#network-contributor) roles. For clusters using API Server VNet integration, a private DNS zone supports the naming format of `private.<region>.azmk8s.io` or `<subzone>.private.<region>.azmk8s.io`. You **can't change or delete these resources after creating the cluster**, as it can cause performance problems and cluster upgrade failures. You can use `--fqdn-subdomain <subdomain>` with `<custom-private-dns-zone-resource-id>` only to provide subdomain capabilities to `privatelink.<region>.azmk8s.io`. If you're specifying a subzone, there's a 32 character limit for the `<subzone>` name. |

### Considerations for private DNS

Keep the following considerations in mind when configuring private DNS for a private AKS cluster:

- If the private DNS zone is in a different subscription than the AKS cluster, you need to register the `Microsoft.ContainerService` Azure provider in both subscriptions.
- If you configure your AKS cluster with an Active Directory service principal, AKS doesn't support using a system-assigned managed identity with custom private DNS zone. The cluster must use [user-assigned managed identity authentication](user-assigned-managed-identity).

::: zone-end

## Private DNS zone: create a private AKS cluster

::: zone pivot="azure-cli"

Create a private AKS cluster with a private DNS zone using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

**Key parameters in this command**:

- `--enable-private-cluster`: Enables private cluster mode.
- `--private-dns-zone [system|none]`: Configures the private DNS zone for the cluster. `system` is the default value when configuring a private DNS zone. If you omit `--private-dns-zone`, AKS creates a private DNS zone in the node resource group. `none` disables the creation of a private DNS zone.
- `--assign-identity <resource-id>`: The resource ID of a user-assigned managed identity with the [Private DNS Zone Contributor](/en-us/azure/role-based-access-control/built-in-roles#dns-zone-contributor) and [Network Contributor](/en-us/azure/role-based-access-control/built-in-roles#network-contributor) roles.

```azurecli
az aks create \
    --name <private-cluster-name> \
    --resource-group <private-cluster-resource-group> \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --assign-identity <resource-id> \
    --private-dns-zone [system|none] \
    --generate-ssh-keys
```

::: zone-end

::: zone pivot="terraform"

1. Follow steps 1-3 in Create a private AKS cluster with advanced networking or Create a private AKS cluster with default basic networking to set up the Terraform configuration and create the necessary resources depending on your scenario. This example uses advanced networking.
2. Add the following code to `main.tf` to create a private AKS cluster with an AKS-managed private DNS zone:

    ```Terraform
    resource "azurerm_kubernetes_cluster" "this" {
     name                = var.aks_cluster_name
     location            = azurerm_resource_group.this.location
     resource_group_name = azurerm_resource_group.this.name
     dns_prefix          = "aks-system-dns"
     private_cluster_enabled = true
     private_dns_zone_id     = "System"
     default_node_pool {
       name           = "system"
       node_count     = 1
       vm_size        = "Standard_DS2_v2"
       vnet_subnet_id = azurerm_subnet.aks.id
     }
     identity {
       type = "SystemAssigned"
     }
     network_profile {
       network_plugin    = "azure"
       load_balancer_sku = "standard"
       dns_service_ip    = "10.2.0.10"
       service_cidr      = "10.2.0.0/24"
     }
    }
    ```
3. Follow the steps in Initialize Terraform, Format and validate the Terraform configuration, Create a Terraform execution plan, Apply the Terraform configuration, and Configure kubectl to connect to a private AKS cluster.

## No private DNS zone: create a private AKS cluster

1. Follow steps 1-3 in Create a private AKS cluster with advanced networking or Create a private AKS cluster with default basic networking to set up the Terraform configuration and create the necessary resources depending on your scenario. This example uses advanced networking.
2. Add the following code to `main.tf` to create the AKS cluster without a private DNS zone:

    ```Terraform
    resource "azurerm_kubernetes_cluster" "this" {
     name                = var.aks_cluster_name
     location            = azurerm_resource_group.this.location
     resource_group_name = azurerm_resource_group.this.name
     dns_prefix          = "aks-no-dns"
     private_cluster_enabled = true
     private_dns_zone_id     = "None"
     default_node_pool {
       name           = "system"
       node_count     = 1
       vm_size        = "Standard_DS2_v2"
       vnet_subnet_id = azurerm_subnet.aks.id
     }
     identity {
       type = "SystemAssigned"
     }
     network_profile {
       network_plugin    = "azure"
       load_balancer_sku = "standard"
       dns_service_ip    = "10.2.0.10"
       service_cidr      = "10.2.0.0/24"
     }
    }
    ```
3. Follow the steps in Initialize Terraform, Format and validate the Terraform configuration, Create a Terraform execution plan, Apply the Terraform configuration, and Configure kubectl to connect to a private AKS cluster.

::: zone-end

## Custom private DNS zone or subzone: create a private AKS cluster

::: zone pivot="azure-cli"

Create a private AKS cluster with a custom private DNS zone or subzone using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

**Key parameters in this command**:

- `--enable-private-cluster`: Enables private cluster mode.
- `--private-dns-zone [<custom-private-dns-zone-resource-id>|<custom-private-dns-subzone-resource-id>]`: The resource ID of an existing private DNS zone or subzone in the following format for Azure global cloud: `privatelink.<region>.azmk8s.io` or `<subzone>.privatelink.<region>.azmk8s.io`.
- `--assign-identity <resource-id>`: The resource ID of a user-assigned managed identity with the [Private DNS Zone Contributor](/en-us/azure/role-based-access-control/built-in-roles#dns-zone-contributor) and [Network Contributor](/en-us/azure/role-based-access-control/built-in-roles#network-contributor) roles.

```azurecli
az aks create \
    --name <private-cluster-name> \
    --resource-group <private-cluster-resource-group> \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --assign-identity <resource-id> \
    --private-dns-zone [<custom-private-dns-zone-resource-id>|<custom-private-dns-subzone-resource-id>] \
    --generate-ssh-keys
```

::: zone-end

::: zone pivot="terraform"

When using a custom private DNS zone, you're responsible for creating and managing the DNS infrastructure instead of relying on Azure-managed DNS. This includes creating the DNS zone, linking it to your VNet, and assigning the necessary permissions for AKS to manage records.

For custom DNS configurations, you must use a user-assigned managed identity with the [Private DNS Zone Contributor](/en-us/azure/role-based-access-control/built-in-roles#dns-zone-contributor) and [Network Contributor](/en-us/azure/role-based-access-control/built-in-roles#network-contributor) roles.

1. Follow steps 1-3 in Create a private AKS cluster with advanced networking or Create a private AKS cluster with default basic networking to set up the Terraform configuration and create the necessary resources depending on your scenario. This example uses advanced networking.
2. Add the code to `main.tf` to create a private AKS cluster with a custom private DNS zone or subzone:

    ```Terraform
    resource "azurerm_user_assigned_identity" "aks" {
     name                = "aks-custom-dns-id"
     location            = azurerm_resource_group.this.location
     resource_group_name = azurerm_resource_group.this.name
    }
    resource "azurerm_private_dns_zone" "aks" {
     name                = "privatelink.eastus.azmk8s.io"
     resource_group_name = azurerm_resource_group.this.name
    }
    resource "azurerm_private_dns_zone_virtual_network_link" "link" {
     name                  = "aks-dns-link"
     resource_group_name   = azurerm_resource_group.this.name
     private_dns_zone_name = azurerm_private_dns_zone.aks.name
     virtual_network_id    = azurerm_virtual_network.this.id
    }
    resource "azurerm_role_assignment" "dns" {
     scope                = azurerm_private_dns_zone.aks.id
     role_definition_name = "Private DNS Zone Contributor"
     principal_id         = azurerm_user_assigned_identity.aks.principal_id
    }
    resource "azurerm_role_assignment" "network" {
     scope                = azurerm_virtual_network.this.id
     role_definition_name = "Network Contributor"
     principal_id         = azurerm_user_assigned_identity.aks.principal_id
    }
    resource "azurerm_kubernetes_cluster" "this" {
     name                = var.aks_cluster_name
     location            = azurerm_resource_group.this.location
     resource_group_name = azurerm_resource_group.this.name
     dns_prefix          = "aks-custom-dns"
     private_cluster_enabled = true
     private_dns_zone_id     = azurerm_private_dns_zone.aks.id
     default_node_pool {
       name           = "system"
       node_count     = 1
       vm_size        = "Standard_DS2_v2"
       vnet_subnet_id = azurerm_subnet.aks.id
     }
     identity {
       type         = "UserAssigned"
       identity_ids = [azurerm_user_assigned_identity.aks.id]
     }
     network_profile {
       network_plugin    = "azure"
       load_balancer_sku = "standard"
       dns_service_ip    = "10.2.0.10"
       service_cidr      = "10.2.0.0/24"
     }
     depends_on = [
       azurerm_role_assignment.dns,
       azurerm_role_assignment.network
     ]
    }
    ```
3. Follow the steps in Initialize Terraform, Format and validate the Terraform configuration, Create a Terraform execution plan, Apply the Terraform configuration, and Configure kubectl to connect to a private AKS cluster.

::: zone-end

## Custom private DNS zone with subdomain: create a private AKS cluster

::: zone pivot="azure-cli"

Create a private AKS cluster with a custom private DNS zone and subdomain using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command.

**Key parameters in this command**:

- `--enable-private-cluster`: Enables private cluster mode.
- `--private-dns-zone <custom-private-dns-zone-resource-id>`: The resource ID of an existing private DNS zone in the following format for Azure global cloud: `privatelink.<region>.azmk8s.io`.
- `--fqdn-subdomain <subdomain>`: The subdomain to use for the cluster FQDN within the custom private DNS zone.
- `--assign-identity <resource-id>`: The resource ID of a user-assigned managed identity with the [Private DNS Zone Contributor](/en-us/azure/role-based-access-control/built-in-roles#dns-zone-contributor) and [Network Contributor](/en-us/azure/role-based-access-control/built-in-roles#network-contributor) roles.

```azurecli
az aks create \
    --name <private-cluster-name> \
    --resource-group <private-cluster-resource-group> \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --assign-identity <resource-id> \
    --private-dns-zone <custom-private-dns-zone-resource-id> \
    --fqdn-subdomain <subdomain> \
    --generate-ssh-keys
```

::: zone-end

::: zone pivot="terraform"

1. Follow steps 1-3 in Create a private AKS cluster with advanced networking or Create a private AKS cluster with default basic networking to set up the Terraform configuration and create the necessary resources depending on your scenario. This example uses advanced networking.
2. Add the following code to `main.tf` to create a private AKS cluster with a custom private DNS zone and subdomain:

    ```Terraform
    resource "azurerm_kubernetes_cluster" "this" {
     name                = var.aks_cluster_name
     location            = azurerm_resource_group.this.location
     resource_group_name = azurerm_resource_group.this.name
     dns_prefix          = "aks-subdomain"
     private_cluster_enabled = true
     private_dns_zone_id     = azurerm_private_dns_zone.aks.id
     fqdn_subdomain          = "team1"
     default_node_pool {
       name           = "system"
       node_count     = 1
       vm_size        = "Standard_DS2_v2"
       vnet_subnet_id = azurerm_subnet.aks.id
     }
     identity {
       type         = "UserAssigned"
       identity_ids = [azurerm_user_assigned_identity.aks.id]
     }
     network_profile {
       network_plugin    = "azure"
       load_balancer_sku = "standard"
       dns_service_ip    = "10.2.0.10"
       service_cidr      = "10.2.0.0/24"
     }
    }
    ```
3. Follow the steps in Initialize Terraform, Format and validate the Terraform configuration, Create a Terraform execution plan, Apply the Terraform configuration, and Configure kubectl to connect to a private AKS cluster.

::: zone-end

## Update an existing private AKS cluster from a private DNS zone to public

::: zone pivot="azure-cli"

You can only update from `byo` (bring your own) or `system` to `none`. No other combination of update values is supported.

Warning

When you update a private cluster from `byo` or `system` to `none`, the agent nodes change to use a public FQDN. In an AKS cluster that uses Azure Virtual Machine Scale Sets, a [node image upgrade](node-image-upgrade) is performed to update your nodes with the public FQDN.

Update a private cluster from `byo` or `system` to `none` using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--private-dns-zone` parameter set to `none`.

```azurecli
az aks update \
    --name <private-cluster-name> \
    --resource-group <private-cluster-resource-group> \
    --private-dns-zone none
```

::: zone-end

::: zone pivot="terraform"

1. Add the following code to the existing `main.tf` to update the private AKS cluster from a private DNS zone to public. This example uses advanced networking. You can modify it to use default basic networking by changing the relevant Terraform resources and parameters.

    ```Terraform
    resource "azurerm_kubernetes_cluster" "this" {
     name                = var.aks_cluster_name
     location            = azurerm_resource_group.this.location
     resource_group_name = azurerm_resource_group.this.name
     dns_prefix          = "aks-update"
     private_cluster_enabled = true
     private_dns_zone_id     = "None"
     default_node_pool {
       name           = "system"
       node_count     = 1
       vm_size        = "Standard_DS2_v2"
       vnet_subnet_id = azurerm_subnet.aks.id
     }
     identity {
       type         = "UserAssigned"
       identity_ids = [azurerm_user_assigned_identity.aks.id]
     }
     network_profile {
       network_plugin    = "azure"
       load_balancer_sku = "standard"
       dns_service_ip    = "10.2.0.10"
       service_cidr      = "10.2.0.0/24"
     }
    }
    ```
2. Apply the updated Terraform configuration using the `terraform plan` and `terraform apply` commands.

    ```console
    terraform plan
    terraform apply
    ```

## Initialize Terraform

Initialize Terraform in the directory containing your `main.tf` file using the `terraform init` command. This command downloads the Azure provider required to manage Azure resources with Terraform.

```console
terraform init
```

## Format and validate the Terraform configuration

Format and validate the Terraform configuration using the `terraform fmt` and `terraform validate` commands.

```console
terraform fmt
terraform validate
```

## Create a Terraform execution plan

Create a Terraform execution plan using the `terraform plan` command. This command shows you the resources that Terraform will create or modify in your Azure subscription.

```console
terraform plan -var="subscription_id=<your-subscription-id>"
```

## Apply the Terraform configuration

After reviewing and confirming the execution plan, apply the Terraform configuration using the `terraform apply` command. This command creates or modifies the resources defined in your main.tf file in your Azure subscription.

```console
terraform apply -var="subscription_id=<your-subscription-id>"
```

::: zone-end

## Configure kubectl to connect to a private AKS cluster

To manage a Kubernetes cluster, use the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/). `kubectl` is already installed if you use Azure Cloud Shell. To install `kubectl` locally, use the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.

Before you connect, make sure the client has network and DNS access to the cluster's private API endpoint. You can connect from the cluster VNet or a connected network by using options such as VNet-injected Azure Cloud Shell, Azure Bastion, VNet peering, a private endpoint, ExpressRoute, or VPN. For more information, see [Establish network connectivity to a private AKS cluster](private-cluster-connect). If you don't have direct network connectivity, use the [`az aks command invoke`](access-private-cluster) command to run commands through the Azure API.

1. Configure `kubectl` to connect to your Kubernetes cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command downloads credentials and configures the Kubernetes CLI to use them.

    ```azurecli
    az aks get-credentials --resource-group <private-cluster-resource-group> --name <private-cluster-name>
    ```
2. Verify the connection to your cluster using the [`kubectl get`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command. This command returns a list of the cluster nodes.

    ```bash
    kubectl get nodes
    ```

    The command returns output similar to the following example output:

    ```output
    NAME                                STATUS   ROLES   AGE    VERSION
    aks-nodepool1-12345678-vmss000000   Ready    agent   3h6m   v1.36.2
    aks-nodepool1-12345678-vmss000001   Ready    agent   3h6m   v1.36.2
    aks-nodepool1-12345678-vmss000002   Ready    agent   3h6m   v1.36.2
    ```