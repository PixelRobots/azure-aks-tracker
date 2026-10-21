---
layout: Conceptual
title: Set Up Private Endpoint with Private Link for ACR - Azure Container Registry | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-private-endpoints
breadcrumb_path: ../breadcrumb/azure-management/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/62/azure-container-registry/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/180a533d-0d25-ec11-b6e6-000d3a4f0858
feedback_system: Standard
permissioned-type: public
recommendations: true
recommendation_types:
- Training
- Certification
uhfHeaderId: azure
ms.suite: office
author: KumudD
learn_banner_products:
- azure
manager: kumud
ms.reviewer: kumud
ms.author: kumud
ms.service: azure-container-registry
description: Set up a private endpoint on a container registry and enable access over a private link in a local virtual network.
ms.topic: how-to
ms.date: 2026-02-11T00:00:00.0000000Z
ms.custom:
- devx-track-azurecli
- sfi-image-nochange
locale: en-us
document_id: 8e01945a-5892-a416-716f-c499f110586c
document_version_independent_id: e2aef346-266f-3e69-842d-58004084609b
original_content_git_url: https://github.com/MicrosoftDocs/azure-management-docs-pr/blob/live/articles/container-registry/container-registry-private-endpoints.md
site_name: Docs
depot_name: Learn.azure-management
page_type: conceptual
toc_rel: toc.json
asset_id: container-registry/container-registry-private-endpoints
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/container-registry/container-registry-private-endpoints.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
- https://authoring-docs-microsoft.poolparty.biz/devrel/16cd61cd-9ecf-429b-b494-91576c41f8e4
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
- https://authoring-docs-microsoft.poolparty.biz/devrel/c4bdb33a-5524-4b66-b162-03f5621d7902
platformId: c603eaa7-819d-cab7-b20b-8999be59548d
---

# Set Up Private Endpoint with Private Link for ACR - Azure Container Registry | Microsoft Learn

Limit access to a registry by assigning virtual network private IP addresses to the registry endpoints and using [Azure Private Link](/en-us/azure/private-link/private-link-overview). Network traffic between the clients on the virtual network and the registry's private endpoints traverses the virtual network and a private link on the Microsoft backbone network, eliminating exposure from the public internet. Private Link also enables private registry access from on-premises through [Azure ExpressRoute](/en-us/azure/expressroute/expressroute-introduction), private peering, or a [VPN gateway](/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways).

You can [configure DNS settings](/en-us/azure/private-link/private-endpoint-overview#dns-configuration) for the registry's private endpoints so that the settings resolve to the registry's allocated private IP address. With DNS configuration, clients and services in the network can continue to access the registry at the registry's fully qualified domain name, such as *myregistry.azurecr.io*.

This article shows how to configure a private endpoint for your registry by using the Azure portal (recommended) or the Azure CLI. This feature is available in the **Premium**[container registry service tier (SKU)](container-registry-skus), with a maximum of 200 private endpoints.

Important

If your container registry restricts access to private endpoints, selected subnets, or IP addresses, some functionality might be unavailable or require more configuration.

- When you disable public network access to a registry, certain [trusted services](allow-access-trusted-services), including Microsoft Defender for Cloud, can access the registry only if you enable a network setting to bypass the network rules.
- Once you disable the public network access, instances of certain Azure services, including Azure DevOps Services, can't access the container registry.
- Private endpoints aren't currently supported with agents managed by Azure DevOps. You need to use a self-hosted agent with network line of sight to the private endpoint.
- If the registry has an approved private endpoint and you disable public network access, you can't list repositories and tags outside the virtual network by using the Azure portal, Azure CLI, or other tools.

## Prerequisites

- A virtual network and subnet in which to set up the private endpoint. If needed, [create a new virtual network and subnet](/en-us/azure/virtual-network/quick-create-portal).
- For testing, set up a VM in the virtual network. For steps to create a test virtual machine to access your registry, see [Create a Docker-enabled virtual machine](container-registry-vnet#create-a-docker-enabled-virtual-machine).
- To use the Azure CLI steps in this article, Azure CLI version 2.6.0 or later is recommended. To install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- If you don't already have a Premium container registry, create one and [import](container-registry-import-images) a sample public image such as `mcr.microsoft.com/hello-world` from Microsoft Container Registry. For example, use the [Azure portal](container-registry-get-started-portal) or the [Azure CLI](container-registry-get-started-azure-cli) to create a registry.

### Register container registry resource provider

To configure registry access by using a private link in a different Azure subscription or tenant, you need to [register the resource provider](/en-us/azure/azure-resource-manager/management/resource-providers-and-types) for Azure Container Registry in that subscription. Use the Azure portal, Azure CLI, or other tools.

Example:

```azurecli
az account set --subscription <Name or ID of subscription of private link>

az provider register --namespace Microsoft.ContainerRegistry
```

## Set up a private endpoint in the Azure portal

Set up a private endpoint when you create a registry, or add a private endpoint to an existing registry.

### Create a private endpoint in a new registry

1. When you create a registry in the portal, on the **Basics** tab, select **Premium** for **Pricing plan**.
2. In the **Networking** tab, for **Connectivity configuration**, select **Private access (recommended)**.
3. Select **Create a private endpoint connection.**
4. Enter or select the following information:

    | Setting | Value |
    | --- | --- |
    | Subscription | Select your subscription. |
    | Resource group | Enter the name of an existing group or create a new one. |
    | Name | Enter a unique name. |
    | Registry subresource | Ensure **registry** is selected. |
    | Virtual network | Select the virtual network for the private endpoint. Example: *myDockerVMVNET*. |
    | Subnet | Select the subnet for the private endpoint. Example: *myDockerVMSubnet*. |
    | Integrate with private DNS zone | Select **Yes**. |
    | Private DNS Zone | Select *(New) privatelink.azurecr.io* |

    ![Screenshot showing the options to create a private endpoint for a new Azure container registry.](media/private-endpoints/private-link-create-portal.png)
5. Select **OK**.
6. Configure the remaining registry settings, and then select **Review + create**. Your registry is created with the private endpoint.

### Create a private endpoint for an existing registry

1. Go to your container registry in the Azure portal.
2. In the service menu, under **Settings**, select **Networking**.
3. On the **Private access** tab, select **Create a private endpoint connection**.
4. In the **Basics** tab, select a subscription, resource group, and region, and enter a name for the private endpoint. The network interface name is created using your endpoint name.
5. Select **Next: Resource**. The private endpoint is for the registry resource, so the resource type and subresource are preselected. Then select **Next: Virtual Network**.
6. Select the virtual network and subnet for the private endpoint. Don't change the other options, and then select **Next: DNS**.
7. Ensure that **Integrate with private DNS zone** is set to **Yes**, and that the private DNS zone is set to *(New) privatelink.azurecr.io*. Select **Next: Tags** and add any desired tags, then select **Next: Review + create**.
8. When you see the **Validation passed** message, select **Create**.

### Confirm endpoint configuration

After you create the private endpoint, the **Private endpoints** settings in the portal show the DNS settings. To confirm:

1. In your container registry's service menu, under **Settings**, select **Networking**.
2. On the **Private access** tab, select the name of the private endpoint you created.
3. In the service menu, under **Settings**, select **DNS configuration**.
4. Review the details for your private link's DNS configuration.

## Set up private endpoint by using the Azure CLI

The Azure CLI examples in this article are formatted for the Bash shell and use the following environment variables. Replace the example values with the names of an existing container registry, virtual network, and subnet to set up a private endpoint.

```bash
REGISTRY_NAME=<container-registry-name>
REGISTRY_LOCATION=<container-registry-location> # Azure region such as westeurope where registry created
RESOURCE_GROUP=<resource-group-name> # Resource group for your existing virtual network and subnet
NETWORK_NAME=<virtual-network-name>
SUBNET_NAME=<subnet-name>
```

### Disable network policies in subnet

[Disable network policies](/en-us/azure/private-link/disable-private-endpoint-network-policy) such as network security groups in the subnet for the private endpoint. Update your subnet configuration by using [az network vnet subnet update](/en-us/cli/azure/network/vnet/subnet/#az-network-vnet-subnet-update):

```azurecli
az network vnet subnet update \
 --name $SUBNET_NAME \
 --vnet-name $NETWORK_NAME \
 --resource-group $RESOURCE_GROUP \
 --disable-private-endpoint-network-policies
```

### Configure the private DNS zone

Create a [private Azure DNS zone](/en-us/azure/dns/private-dns-privatednszone) for the private Azure container registry domain. In later steps, you create DNS records for your registry domain in this DNS zone. For more information, see DNS configuration options, later in this article.

To use a private zone to override the default DNS resolution for your Azure container registry, name the zone **privatelink.azurecr.io**. Run the following [az network private-dns zone create](/en-us/cli/azure/network/private-dns/zone#az-network-private-dns-zone-create) command to create the private zone:

```azurecli
az network private-dns zone create \
  --resource-group $RESOURCE_GROUP \
  --name "privatelink.azurecr.io"
```

### Create an association link

Run [az network private-dns link vnet create](/en-us/cli/azure/network/private-dns/link/vnet#az-network-private-dns-link-vnet-create) to associate your private zone with the virtual network. This example creates a link named *myDNSLink*.

```azurecli
az network private-dns link vnet create \
  --resource-group $RESOURCE_GROUP \
  --zone-name "privatelink.azurecr.io" \
  --name MyDNSLink \
  --virtual-network $NETWORK_NAME \
  --registration-enabled false
```

### Create a private registry endpoint

In this section, create the registry's private endpoint in the virtual network. First, get the resource ID of your registry:

```azurecli
REGISTRY_ID=$(az acr show --name $REGISTRY_NAME \
  --query 'id' --output tsv)
```

Run the [az network private-endpoint create](/en-us/cli/azure/network/private-endpoint#az-network-private-endpoint-create) command to create the registry's private endpoint.

The following example creates the endpoint *myPrivateEndpoint* and service connection *myConnection*. To specify a container registry resource for the endpoint, pass `--group-ids registry`:

```azurecli
az network private-endpoint create \
    --name myPrivateEndpoint \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $NETWORK_NAME \
    --subnet $SUBNET_NAME \
    --private-connection-resource-id $REGISTRY_ID \
    --group-ids registry \
    --connection-name myConnection
```

### Get endpoint IP configuration

To configure DNS records, get the IP configuration of the private endpoint. The private endpoint's network interface connects to one or more private IP addresses for the container registry, depending on registry features:

- **Global endpoint** — 1 private IP address for the registry itself (`myregistry.azurecr.io`).
- **Dedicated data endpoints** — 1 private IP address per geo-replica for the data endpoint (for example, `myregistry.westus2.data.azurecr.io`). Dedicated data endpoints are automatically enabled when you configure a private endpoint.
- **Regional endpoints** (if enabled) — 1 additional private IP address per geo-replica for the regional endpoint (for example, `myregistry.westus2.geo.azurecr.io`). Regional endpoints are only available in the **Premium** SKU when you enable them with `az acr update --regional-endpoints Enabled`.

For example, a registry with three geo-replicas and regional endpoints enabled requires **7 private IP addresses**: 1 global + 3 data + 3 regional. Without regional endpoints, the same registry requires **4 private IP addresses**: 1 global + 3 data.

For a complete list of registry endpoint types and their FQDN patterns, see the [endpoint reference](container-registry-endpoint-reference).

## Plan subnet IP capacity for private endpoints

Each ACR private endpoint network interface consumes private IP addresses from its subnet. The number of IPs grows with geo-replication and regional endpoints. Registries with private endpoints automatically get [dedicated data endpoints](container-registry-firewall-rules#enable-dedicated-data-endpoints), so each geo-replica has its own regional dedicated data endpoint that consumes a private IP. Plan your subnet size before enabling these features to avoid provisioning failures.

### IP address consumption per feature

| Configuration | IPs consumed per VNet |
| --- | --- |
| Initial private endpoint (registry endpoint + home region regional dedicated data endpoint) | 2 |
| Each geo-replication region added | +1 (regional dedicated data endpoint) |
| [Regional endpoints](container-registry-geo-replication#regional-endpoints-of-a-geo-replicated-registry-preview) enabled | +1 per geo-replica |

**Example:** A registry with 3 geo-replicas (1 home + 2 added regions) and regional endpoints enabled consumes **7 private IPs** per VNet that has a private endpoint to the registry: 2 initial + 2 regional dedicated data endpoints + 3 regional endpoints. Without regional endpoints, the same registry requires **4 private IPs**: 2 initial + 2 regional dedicated data endpoints.

### Geo-replication and subnet capacity

When you add a geo-replication region to a registry that has private endpoints configured, ACR automatically provisions an additional private IP in each associated VNet for the new region's regional dedicated data endpoint. If **any** PE subnet across any connected VNet does not have enough free IPs, the replication provisioning fails and the entire operation rolls back. The replica appears briefly in a `Creating` state and then is removed.

The resulting error does not identify which subnet or VNet is exhausted. If a geo-replication fails unexpectedly, verify that every PE subnet connected to the registry has free IP capacity using the command in Recommendations.

### Recommendations

Ensure the subnet hosting your private endpoints has sufficient free IP capacity before adding replicas. Microsoft recommends using at minimum a `/27` (32 addresses) subnet for PE subnets on geo-replicated registries, and `/24` where possible.

Tip

To check how many private IPs are already consumed on a subnet before adding a replica, run:

```azurecli
az network vnet subnet show \
  --name <subnet-name> \
  --vnet-name <vnet-name> \
  --resource-group <resource-group> \
  --query "{addressPrefix:addressPrefix, usedIPs:length(ipConfigurations || \`[]\`)}" \
  --output table
```

### Regional endpoints and IP consumption

If you enable [regional endpoints](container-registry-geo-replication#regional-endpoints-of-a-geo-replicated-registry-preview), each geo-replica gets a dedicated login server URL (`myregistry.<region>.geo.azurecr.io`). For registries with private endpoints, this allocates one additional private IP per geo-replica in every associated VNet. Evaluate your subnet capacity before enabling this feature on registries with multiple replicas and many associated VNets.

First, run [az network private-endpoint show](/en-us/cli/azure/network/private-endpoint#az-network-private-endpoint-show) to query the private endpoint for the network interface ID:

```azurecli
NETWORK_INTERFACE_ID=$(az network private-endpoint show \
  --name myPrivateEndpoint \
  --resource-group $RESOURCE_GROUP \
  --query 'networkInterfaces[0].id' \
  --output tsv)
```

The following [az network nic show](/en-us/cli/azure/network/nic#az-network-nic-show) commands get the private IP addresses and FQDNs for the container registry and the registry's data endpoint:

```azurecli
REGISTRY_PRIVATE_IP=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry'].privateIPAddress" \
  --output tsv)

DATA_ENDPOINT_PRIVATE_IP=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry_data_$REGISTRY_LOCATION'].privateIPAddress" \
  --output tsv)

# An FQDN is associated with each IP address in the IP configurations

REGISTRY_FQDN=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry'].privateLinkConnectionProperties.fqdns" \
  --output tsv)

DATA_ENDPOINT_FQDN=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry_data_$REGISTRY_LOCATION'].privateLinkConnectionProperties.fqdns" \
  --output tsv)
```

#### Additional endpoints for geo-replicas

If your registry is [geo-replicated](container-registry-geo-replication), query for the additional data endpoint for each registry replica. If you also enabled [regional endpoints](container-registry-geo-replication#regional-endpoints-of-a-geo-replicated-registry-preview), query for the regional endpoint private IP as well.

For example, querying the data endpoint in the *eastus* region:

```azurecli
REPLICA_LOCATION=eastus
GEO_REPLICA_DATA_ENDPOINT_PRIVATE_IP=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry_data_$REPLICA_LOCATION'].privateIPAddress" \
  --output tsv) 

GEO_REPLICA_DATA_ENDPOINT_FQDN=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry_data_$REPLICA_LOCATION'].privateLinkConnectionProperties.fqdns" \
  --output tsv)
```

If [regional endpoints](container-registry-geo-replication#regional-endpoints-of-a-geo-replicated-registry-preview) are enabled, also query the regional endpoint for each replica:

```azurecli
GEO_REPLICA_REGIONAL_ENDPOINT_PRIVATE_IP=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry_$REPLICA_LOCATION'].privateIPAddress" \
  --output tsv)

GEO_REPLICA_REGIONAL_ENDPOINT_FQDN=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry_$REPLICA_LOCATION'].privateLinkConnectionProperties.fqdns" \
  --output tsv)
```

Tip

Run `az acr show-endpoints --name <registry-name>` to see all endpoint FQDNs for your registry, including regional endpoints. For details, see the [endpoint reference](container-registry-endpoint-reference).

When you add a new geo-replication, a private endpoint connection is pending. To approve a private endpoint connection that you configured manually, run [az acr private-endpoint-connection approve](/en-us/cli/azure/acr/private-endpoint-connection#az-acr-private-endpoint-connection-approve).

### Create DNS records in the private zone

The following commands create DNS records in the private zone for the registry endpoint and its data endpoint. For example, if you have a registry named *myregistry* in the *westeurope* region, the endpoint names are `myregistry.azurecr.io` and `myregistry.westeurope.data.azurecr.io`.

First, run [az network private-dns record-set a create](/en-us/cli/azure/network/private-dns/record-set/a#az-network-private-dns-record-set-a-create) to create empty A-record sets for the registry endpoint and data endpoint:

```azurecli
az network private-dns record-set a create \
  --name $REGISTRY_NAME \
  --zone-name privatelink.azurecr.io \
  --resource-group $RESOURCE_GROUP

# Specify registry region in data endpoint name
az network private-dns record-set a create \
  --name ${REGISTRY_NAME}.${REGISTRY_LOCATION}.data \
  --zone-name privatelink.azurecr.io \
  --resource-group $RESOURCE_GROUP
```

Run the [az network private-dns record-set a add-record](/en-us/cli/azure/network/private-dns/record-set/a#az-network-private-dns-record-set-a-add-record) command to create the A-records for the registry endpoint and data endpoint:

```azurecli
az network private-dns record-set a add-record \
  --record-set-name $REGISTRY_NAME \
  --zone-name privatelink.azurecr.io \
  --resource-group $RESOURCE_GROUP \
  --ipv4-address $REGISTRY_PRIVATE_IP

# Specify registry region in data endpoint name
az network private-dns record-set a add-record \
  --record-set-name ${REGISTRY_NAME}.${REGISTRY_LOCATION}.data \
  --zone-name privatelink.azurecr.io \
  --resource-group $RESOURCE_GROUP \
  --ipv4-address $DATA_ENDPOINT_PRIVATE_IP
```

#### Additional records for geo-replicas

If your registry is geo-replicated, create additional DNS settings for each replica. Continuing the example in the *eastus* region:

```azurecli
az network private-dns record-set a create \
  --name ${REGISTRY_NAME}.${REPLICA_LOCATION}.data \
  --zone-name privatelink.azurecr.io \
  --resource-group $RESOURCE_GROUP

az network private-dns record-set a add-record \
  --record-set-name ${REGISTRY_NAME}.${REPLICA_LOCATION}.data \
  --zone-name privatelink.azurecr.io \
  --resource-group $RESOURCE_GROUP \
  --ipv4-address $GEO_REPLICA_DATA_ENDPOINT_PRIVATE_IP
```

The private link is now configured and ready for use.

## Disable public access to a registry

For many scenarios, disable registry access from public networks. This configuration prevents all clients outside the virtual network from reaching the registry endpoints.

To disable public access to a container registry in the Azure portal, follow these steps:

1. In your container registry's service menu, under **Settings**, select **Networking**.
2. On the **Public access** tab, in **Public network access**, select **Disabled**. Then select **Save**.

You can also use the Azure CLI to disable public access by running [az acr update](/en-us/cli/azure/acr#az-acr-update) and set `--public-network-enabled` to `false`.

Note

If you disable public access to a registry, `az acr build` commands no longer work.

```azurecli
az acr update --name $REGISTRY_NAME --public-network-enabled false
```

## Use `az acr build` with private endpoint and private registry

Note

If you disable public network access, `az acr build` commands will fail. Unless you use dedicated agent pools, public IPs are typically required. Tasks reserve a set of public IPs in each region for outbound requests. If needed, you can add these IPs to your firewall's allowed list for seamless communication. `az acr build` command uses the same set of IPs as tasks.

Consider the following options to execute the `az acr build` successfully.

- Assign a [dedicated agent pool](tasks-agent-pools).
- If agent pool isn't available in your region, add the regional [Azure Container Registry Service Tag IPv4](/en-us/azure/virtual-network/service-tags-overview#use-the-service-tag-discovery-api) to the [firewall access rules](container-registry-firewall-rules#allow-access-by-ip-address-range). Tasks reserve a set of public IPs in each region (`AzureContainerRegistry` service tag) for outbound requests. You can add these IPs to the firewall allowed list.

## Disable access to a container registry by using a service endpoint

Important

You can't use both private link and service endpoint features configured from a virtual network in your container registry.

After you disable public access and configure private link for your registry, disable service endpoint access from a virtual network by [removing virtual network rules](container-registry-vnet#remove-network-rules).

- Run [`az acr network-rule list`](/en-us/cli/azure/acr/network-rule#az-acr-network-rule-list) command to list the existing network rules.
- Run [`az acr network-rule remove`](/en-us/cli/azure/acr/network-rule#az-acr-network-rule-remove) command to remove the network rule.

## Validate private link connection

Validate that the resources within the subnet of the private endpoint connect to your registry over a private IP address and have the correct private DNS zone integration.

To validate the private link connection, connect to the virtual machine you set up in the virtual network. Then, run a utility such as `nslookup` or `dig` to look up the IP address of your registry over the private link. For example:

```bash
dig $REGISTRY_NAME.azurecr.io
```

Example output shows the registry's IP address in the address space of the subnet:

```console
[...]
; <<>> DiG 9.11.3-1ubuntu1.13-Ubuntu <<>> myregistry.azurecr.io
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 52155
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;myregistry.azurecr.io.         IN      A

;; ANSWER SECTION:
myregistry.azurecr.io.  1783    IN      CNAME   myregistry.privatelink.azurecr.io.
myregistry.privatelink.azurecr.io. 10 IN A      10.0.0.7

[...]
```

Compare this result with the public IP address in `dig` output for the same registry over a public endpoint:

```console
[...]
;; ANSWER SECTION:
myregistry.azurecr.io.	2881	IN	CNAME	myregistry.privatelink.azurecr.io.
myregistry.privatelink.azurecr.io. 2881	IN CNAME xxxx.xx.azcr.io.
xxxx.xx.azcr.io.	300	IN	CNAME	xxxx-xxx-reg.trafficmanager.net.
xxxx-xxx-reg.trafficmanager.net. 300 IN	CNAME	xxxx.westeurope.cloudapp.azure.com.
xxxx.westeurope.cloudapp.azure.com. 10	IN A 20.45.122.144

[...]
```

### Confirm registry operations over private link

Also verify that you can perform registry operations from the virtual machine in the network. Make an SSH connection to your virtual machine, and run [az acr login](/en-us/cli/azure/acr#az-acr-login) to authenticate to your registry. Depending on your VM configuration, you might need to prefix the following commands with `sudo`.

```azurecli
az acr login --name $REGISTRY_NAME
```

Perform registry operations such as `docker pull` to pull a sample image from the registry. Replace `hello-world:v1` with an image and tag appropriate for your registry, prefixed with the registry login server name (all lowercase):

```bash
docker pull myregistry.azurecr.io/hello-world:v1
```

Confirm that Docker successfully pulls the image to the VM.

## Manage private endpoint connections

Manage a registry's private endpoint connections by using the Azure portal or commands in the [az acr private-endpoint-connection](/en-us/cli/azure/acr/private-endpoint-connection) command group. You can approve, delete, list, reject, or show details of a registry's private endpoint connections.

To list the private endpoint connections of a registry, run the [az acr private-endpoint-connection list](/en-us/cli/azure/acr/private-endpoint-connection#az-acr-private-endpoint-connection-list) command:

```azurecli
az acr private-endpoint-connection list \
  --registry-name $REGISTRY_NAME 
```

When you set up a private endpoint connection by using the steps in this article, the registry automatically accepts connections from clients and services that have Azure RBAC permissions on the registry. You can set up the endpoint to require manual approval of connections. For information about how to approve and reject private endpoint connections, see [Manage a Private Endpoint Connection](/en-us/azure/private-link/manage-private-endpoint).

Important

Currently, if you delete a private endpoint from a registry, you might also need to delete the virtual network's link to the private zone. If you don't delete the link, you might see an `unresolvable host` error.

## DNS configuration options

The private endpoint in this example integrates with a private DNS zone associated with a basic virtual network. This setup uses the Azure-provided DNS service directly to resolve the registry's public FQDN to its private IP addresses in the virtual network.

Private link supports additional DNS configuration scenarios that use the private zone, including custom DNS solutions. For example, you might have a custom DNS solution deployed in the virtual network, or on-premises in a network you connect to the virtual network using a VPN gateway or Azure ExpressRoute.

To resolve the registry's public FQDN to the private IP address in these scenarios, you need to configure a server-level forwarder to the Azure DNS service (168.63.129.16). Exact configuration options and steps depend on your existing networks and DNS. For examples, see [Azure Private Endpoint private DNS zone values](/en-us/azure/private-link/private-endpoint-dns).

Important

If you create private endpoints in several regions to enable high availability, use a separate resource group in each region and place the virtual network and the associated private DNS zone in it. This configuration also prevents unpredictable DNS resolution caused by sharing the same private DNS zone.

### Manually configure DNS records

For some scenarios, you might need to manually configure DNS records in a private zone instead of using the Azure-provided private zone. Be sure to create records for the registry endpoint, the registry's data endpoint, and the data endpoint for any additional regional replica. If [regional endpoints](container-registry-geo-replication#regional-endpoints-of-a-geo-replicated-registry-preview) are enabled, also create records for each regional endpoint (`<registry-name>.<region>.geo.azurecr.io`). If you don't configure all records, the registry might be unreachable.

Important

If you later add a new replica, you need to manually add a new DNS record for the data endpoint in that region. For example, if you create a replica of *myregistry* in the northeurope location, add a record for `myregistry.northeurope.data.azurecr.io`. If regional endpoints are enabled, also add a record for `myregistry.northeurope.geo.azurecr.io`.

The FQDNs and private IP addresses that you need to create DNS records are associated with the private endpoint's network interface. You can get this information by using the Azure portal or Azure CLI.

- In the portal, go to your private endpoint, and select **DNS configuration**.
- By using the Azure CLI, run [az network nic show](/en-us/cli/azure/network/nic#az-network-nic-show). For example commands, see Get endpoint IP configuration.

After creating DNS records, make sure that the registry FQDNs resolve properly to their respective private IP addresses.

## Pull from a registry with private link enabled

To pull content from a registry with private link enabled, clients must allow access to the registry REST endpoint and all data endpoints. The client proxy or firewall must allow access to:

- **Global endpoint**: `{REGISTRY_NAME}.azurecr.io`
- **Data endpoints**: `{REGISTRY_NAME}.{REGISTRY_LOCATION}.data.azurecr.io`
- **Regional endpoints** (if enabled): `{REGISTRY_NAME}.{REGISTRY_LOCATION}.geo.azurecr.io`

For a geo-replicated registry, you must configure access to the data endpoint (and the regional endpoint, if enabled) for each geo-replica. For the full list of endpoint types, see the [endpoint reference](container-registry-endpoint-reference).

Update the routing configuration for the client proxy and client firewall with the data endpoints to handle the pull requests successfully. A client proxy provides central traffic control to [outbound requests](/en-us/azure/firewall/rule-processing#outbound-connectivity). To handle local traffic, a client proxy isn't required. You can add endpoints into the `noProxy` section to bypass the proxy. For more information, see [HTTP proxy support in AKS](/en-us/azure/aks/http-proxy).

Requests to the token server over a private endpoint connection don't require data endpoint configuration.

## Clean up resources

If you created all the Azure resources in the same resource group and you no longer need them, you can delete the resource group in the Azure portal or by using a single [az group delete](/en-us/cli/azure/group) command:

```azurecli
az group delete --name $RESOURCE_GROUP
```