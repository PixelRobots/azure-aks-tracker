---
layout: Conceptual
title: Establish network connectivity to a private Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/private-cluster-connect
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
description: Learn about the options for connecting to a private AKS cluster, including using Azure Cloud Shell, Azure Bastion, virtual network peering, and private endpoints.
ms.topic: how-to
ms.author: schaffererin
author: schaffererin
ms.date: 2026-08-13T00:00:00.0000000Z
ms.subservice: aks-security
ms.custom: aeo-round-2
zone_pivot_groups: private-cluster-connect
locale: en-us
document_id: c0b3dbc6-bf1a-3667-7aed-93aa6cdb8c8d
document_version_independent_id: 36d1fedd-ef42-889b-3799-24db834e72ea
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/private-cluster-connect.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/private-cluster-connect
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/private-cluster-connect.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
- https://authoring-docs-microsoft.poolparty.biz/devrel/cdc80360-921e-4b45-947f-2719acf06f23
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
- https://authoring-docs-microsoft.poolparty.biz/devrel/539badf0-028a-4e3e-bda6-770b2552b4d8
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: bf361304-5536-c1e6-6c8b-b43e13c0c112
---

# Establish network connectivity to a private Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

In private AKS clusters, the API server endpoint has no public IP address. To manage the API server, you need to use a virtual machine (VM) or container that has access to the virtual network (VNet) of the AKS cluster. There are several options for establishing network connectivity to the private cluster:

- Use an [Azure Cloud Shell](/en-us/azure/cloud-shell/vnet/overview) instance deployed into a subnet that's connected to the API server for the cluster.
- Use [Azure Bastion](/en-us/azure/bastion/bastion-connect-to-aks-private-cluster)'s native client tunneling feature (preview).
- Use a VM in a separate network and set up [virtual network peering](/en-us/azure/virtual-network/virtual-network-peering-overview).
- Use a [private endpoint](/en-us/azure/private-link/private-endpoint-overview) connection.
- Create a VM in the same VNet as the AKS cluster using the [`az vm create`](/en-us/cli/azure/vm#az-vm-create) command with the `--vnet-name` flag.
- Use an [Express Route or VPN](/en-us/azure/expressroute/expressroute-about-virtual-network-gateways) connection.
- Use the [AKS `command invoke` feature](access-private-cluster).

## Choose a connectivity option

Azure Cloud Shell and Azure Bastion (preview) are the easiest options. Express Route and VPNs add costs and require extra networking complexity. Virtual network peering requires you to plan your network CIDR ranges to ensure there are no overlapping ranges.

The following table outlines the key differences and limitations of using Azure Cloud Shell and Azure Bastion:

| Option | Azure Cloud Shell | Azure Bastion (preview) |
| --- | --- | --- |
| Key differences | • Ephemeral, browser-based access.  • Cost-effective.  • Comes with preinstalled tools like `az cli` and `kubectl`. | • Persistent, long-running access.  • Suited for managing multiple clusters.  • Use your own native client tooling. |
| Limitations | • Not supported with AKS Automatic clusters or clusters with network resource group (NRG) lockdown.  • You can't have multiple Cloud Shell sessions in different VNets at the same time. | • Not supported with AKS Automatic clusters or clusters with NRG lockdown. |

::: zone pivot="azure-cloud-shell"

## Connect using Azure Cloud Shell

Connecting to a private AKS cluster through Azure Cloud Shell requires completing the following steps:

- **Deploy required resources:** You need to deploy Cloud Shell in a VNet that can reach your private cluster. This step provisions the necessary infrastructure. While Cloud Shell is a free service, using Cloud Shell in a VNet requires some resources that incur cost. For more information, see [Deploy Cloud Shell in a virtual network](/en-us/azure/cloud-shell/vnet/deployment).
- **Configure the connection:** After you deploy the resources, any user in the subscription that has appropriate permissions on the cluster can configure Cloud Shell to deploy in the VNet to allow a secure connection to the private cluster.

## Deploy required resources

To deploy and configure the required resources, you must have the **Owner** role assignment on the subscription. To view and assign roles, see [List Owners of a Subscription](/en-us/azure/role-based-access-control/role-assignments-list-portal#list-owners-of-a-subscription).

You can deploy the required resources using the Azure portal or the provided ARM template if you manage infrastructure as code or have organizational policies that require specific resource naming conventions.

You can optionally leave the deployed resources in place for future connections or delete and recreate them as needed.

### Use the Azure portal (preview)

This option creates a separate VNet with the necessary resources for Cloud Shell and configures VNet peering for you.

1. In the [Azure portal](https://portal.azure.com), navigate to your private cluster resource.
2. On the Overview page, select **Connect**.
3. On the **Cloud Shell** tab, under **Prerequisites for private cluster connection**, select **Configure**to deploy the necessary resources.
    - The deployment creates a new resource group named `RG-CloudShell-PrivateClusterConnection-{RANDOM_ID}`.
4. Once the deployment succeeds, under **Set cluster context**, select **Open Cloud Shell**.

![Screenshot of the Azure portal at a private cluster's resource page showing the Connect button with the Cloud Shell tab selected.](media/access-private-cluster/azure-portal-cloud-shell-connect.png)

Note

If you already configured Cloud Shell in a VNet for a particular cluster, repeating these steps ensures your Cloud Shell user settings are correctly aligned with that VNet.

### Use an ARM template

To have more control over the deployment configuration, use the [provided ARM template](/en-us/azure/cloud-shell/vnet/deployment).

You can deploy Cloud Shell in the same VNet as your AKS private cluster with a dedicated subnet, or you can deploy in a new VNet and connect via [VNet peering](/en-us/azure/virtual-network/virtual-network-peering-overview).

## Configure connection to the private cluster

After you deploy the required resources, any user in the subscription can configure their Cloud Shell to deploy in the given VNet using the steps in [Configure Cloud Shell to use a virtual network](/en-us/azure/cloud-shell/vnet/deployment#5-configure-cloud-shell-to-use-a-virtual-network).

Ensure the user has appropriate Kubernetes-level access to successfully connect to the private cluster. For more information, see [Access and identity options for Azure Kubernetes Service (AKS)](concepts-identity).

::: zone-end

::: zone pivot="azure-bastion"

## Connect using Azure Bastion (preview)

Azure Bastion is a fully managed PaaS service that you provision to securely connect to private resources via private IP addresses. To use Bastion's native client tunneling feature, see [Connect to AKS private cluster using Azure Bastion](/en-us/azure/bastion/bastion-connect-to-aks-private-cluster).

::: zone-end

::: zone pivot="vnet-peering"

## Connect using virtual network (VNet) peering

To use VNet peering, you need to set up a link between the VNet and the private DNS zone. You can set up VNet peering using either the Azure portal or the Azure CLI.

### Use the Azure portal

1. In the [Azure portal](https://portal.azure.com), navigate to your node resource group and select your **private DNS zone resource**.
2. In the service menu, under **DNS Management**, select **Virtual Network Links** &gt; **Add**.
3. On the **Add Virtual Network Link** page, configure the following settings:

    - **Link name**: Enter a name for the virtual network link.
    - **Virtual Network**: Select the virtual network that contains the VM.
4. Select **Create** to create the virtual network link.
5. Navigate to the resource group that contains the virtual network of your AKS cluster and select your **virtual network resource**.
6. In the service menu, under **Settings**, select **Peerings** &gt; **Add**.
7. On the **Add peering** page, configure the following settings:

    - **Peering link name**: Enter a name for the peering link.
    - **Virtual network**: Select the virtual network of the VM.
8. Select **Add** to create the peering link.

For more information, see [Virtual network peering](/en-us/azure/virtual-network/virtual-network-peering-overview).

### Use the Azure CLI

1. Create a new link to add the virtual network of the VM to the private DNS zone using the [`az network private-dns link vnet create`](/en-us/cli/azure/network/private-dns/link/vnet#az-network-private-dns-link-vnet-create) command.

    ```azurecli
    az network private-dns link vnet create \
        --name <new-link-name> \
        --resource-group <node-resource-group-name> \
        --zone-name <private-dns-zone-name> \
        --virtual-network <vm-virtual-network-resource-id> \
        --registration-enabled false
    ```
2. Create a peering between the virtual network of the VM and the virtual network of the node resource group using the [`az network vnet peering create`](/en-us/cli/azure/network/vnet/peering#az-network-vnet-peering-create) command.

    ```azurecli
    az network vnet peering create \
        --name <new-peering-name-1> \
        --resource-group <vm-virtual-network-resource-group-name> \
        --vnet-name <vm-virtual-network-name> \
        --remote-vnet <node-resource-group-virtual-network-resource-id> \
        --allow-vnet-access
    ```
3. Create a second peering between the virtual network of the node resource group and the virtual network of the VM using the [`az network vnet peering create`](/en-us/cli/azure/network/vnet/peering#az-network-vnet-peering-create) command.

    ```azurecli
    az network vnet peering create \
        --name <new-peering-name-2> \
        --resource-group <node-resource-group-name> \
        --vnet-name <node-resource-group-virtual-network-name> \
        --remote-vnet <vm-virtual-network-resource-id> \
        --allow-vnet-access
    ```
4. List the virtual network peerings you created using the [`az network vnet peering list`](/en-us/cli/azure/network/vnet/peering#az-network-vnet-peering-list) command.

    ```azurecli
    az network vnet peering list \
        --resource-group <node-resource-group-name> \
        --vnet-name <private-dns-zone-name>
    ```

::: zone-end

::: zone pivot="private-endpoint"

## Use a private endpoint connection

You can set up a private endpoint so that a VNet doesn't need to be peered to communicate with the private cluster. To set up a private endpoint connection, you first create a new private endpoint in the virtual network containing the consuming resources, and then create a link between your virtual network and a new private DNS zone in the same network.

Important

If the virtual network is configured with custom DNS servers, you need to set up private DNS appropriately for the environment. For more information, see the [Virtual network name resolution documentation](/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances#name-resolution-that-uses-your-own-dns-server).

### Create a private endpoint resource

1. From the [Azure portal home page](https://portal.azure.com), select **Create a resource**.
2. Search for **Private Endpoint** and select **Create** &gt; **Private Endpoint**.
3. Select **Create**.
4. On the **Basics** tab, configure the following settings:

    - **Project details**

        - **Subscription**: Select the subscription where your private cluster is located.
        - **Resource group**: Select the resource group that contains your virtual network.
    - **Instance details**

        - **Name**: Enter a name for your private endpoint, such as *myPrivateEndpoint*.
        - **Region**: Select the same region as your virtual network.
5. Select **Next: Resource** and configure the following settings:

    - **Connection method**: Select **Connect to an Azure resource in my directory**.
    - **Subscription**: Select the subscription where your private cluster is located.
    - **Resource type**: Select **Microsoft.ContainerService/managedClusters**.
    - **Resource**: Select your private cluster.
    - **Target sub-resource**: Select **management**.
6. Select **Next: Virtual Network** and configure the following settings:

    - **Networking**
        - **Virtual network**: Select your virtual network.
        - **Subnet**: Select your subnet.
7. Select **Next: DNS** &gt; **Next: Tags** and (optionally) set up key-values as needed.
8. Select **Next: Review + create** &gt; **Create**.

Once the resource is created, record the private IP address of the private endpoint for future use.

### Create a private DNS zone

Once you create the private endpoint, create a new private DNS zone with the same name as the private DNS zone created by the private cluster. Remember to create this DNS zone in the VNet containing the consuming resources.

1. In the Azure portal, navigate to your node resource group and select your **private DNS zone resource**.
2. In the service menu, under **DNS Management**, select **Recordsets** and note the following:

    - The name of the private DNS zone, which follows the pattern `*.privatelink.<region>.azmk8s.io`.
    - The name of the `A` record (excluding the private DNS name).
    - The time-to-live (TTL).
3. From the [Azure portal home page](https://portal.azure.com), select **Create a resource**.
4. Search for **Private DNS zone** and select **Create** &gt; **Private DNS zone**.
5. On the **Basics** tab, configure the following settings:

    - **Project details**

        - Select your **Subscription**.
        - Select the **Resource group** where you created the private endpoint.
    - **Instance details**

        - **Name**: Enter the name of the DNS zone retrieved from previous steps.
        - **Region**: Defaults to the location of your resource group.
6. Select **Review + create** &gt; **Create**.

### Create an `A` record

Once the private DNS zone is created, create an `A` record, which associates the private endpoint to the private cluster.

1. Navigate to your private DNS zone resource.
2. In the service menu, under **DNS Management**, select **Recordsets** &gt; **Add**.
3. On the **Add record set** page, configure the following settings:

    - **Name**: Enter the name retrieved from the `A` record in the private cluster's DNS zone.
    - **Type**: Select **A - Address record**.
    - **TTL**: Enter the number from the `A` record in the private cluster's DNS zone.
    - **TTL unit**: Change the dropdown value to match the one in the `A` record from the private cluster's DNS zone.
    - **IP address**: Enter the **IP address of the private endpoint you created**.
4. Select **Add** to create the `A` record.

Important

When creating the `A` record, only use the name and not the fully qualified domain name (FQDN).

### Link the private DNS zone to the virtual network

Once the `A` record is created, link the private DNS zone to the virtual network that will access the private cluster.

1. Navigate to your private DNS zone resource.
2. In the service menu, under **DNS Management**, select **Virtual Network Links** &gt; **Add**.
3. On the **Add Virtual Network Link** page, configure the following settings:

    - **Link name**: Enter a name for your virtual network link.
    - **Subscription**: Select the subscription where your private cluster is located.
    - **Virtual Network**: Select the virtual network of your private cluster.
4. Select **Create** to create the link.

    It might take a few minutes for the operation to complete. Once the virtual network link is created, you can access it from the **Virtual Network Links** tab you used in step 2.

Warning

- If the private cluster is stopped and restarted, the private cluster's original private link service is removed and recreated, which breaks the connection between your private endpoint and the private cluster. To resolve this issue, delete and recreate any user-created private endpoints linked to the private cluster. If the recreated private endpoints have new IP addresses, you also need to update DNS records.
- If you update the DNS records in the private DNS zone, ensure the host that you're trying to connect from is using the updated DNS records. You can verify this using the `nslookup` command. If you notice the updates aren't reflected in the output, you might need to flush the DNS cache on your machine and try again.

::: zone-end

::: zone pivot="vm-same-vnet"

## Create a VM in the same virtual network

The following steps create an Ubuntu VM in an existing subnet in the same VNet as your private AKS cluster. Before you begin, make sure that you have permission to create VMs in the VNet and access the AKS cluster.

1. Set the variables for your AKS cluster and the VM that you want to create.

    ```azurecli
    AKS_RESOURCE_GROUP=<aks-resource-group-name>
    AKS_CLUSTER_NAME=<aks-cluster-name>
    VM_NAME=<vm-name>
    VM_ADMIN_USERNAME=<vm-admin-username>
    ```
2. Get the resource ID of the subnet used by the first AKS node pool, and then identify its parent VNet.

    ```azurecli
    AKS_SUBNET_ID=$(az aks show \
        --resource-group $AKS_RESOURCE_GROUP \
        --name $AKS_CLUSTER_NAME \
        --query "agentPoolProfiles[0].vnetSubnetId" \
        --output tsv)
    
    VNET_ID=${AKS_SUBNET_ID%/subnets/*}
    VNET_NAME=$(az network vnet show --ids $VNET_ID --query name --output tsv)
    VNET_RESOURCE_GROUP=$(az network vnet show --ids $VNET_ID --query resourceGroup --output tsv)
    ```
3. List the subnets in the AKS VNet, and choose an existing subnet for the VM. Use a subnet that has enough available IP addresses and permits connectivity to the private API server. Don't deploy the VM into the AKS node subnet.

    ```azurecli
    az network vnet subnet list \
        --resource-group $VNET_RESOURCE_GROUP \
        --vnet-name $VNET_NAME \
        --query "[].{Name:name, AddressPrefix:addressPrefix}" \
        --output table
    
    VM_SUBNET_NAME=<vm-subnet-name>
    ```
4. Create the VM in the VNet's resource group using the [`az vm create`](/en-us/cli/azure/vm#az-vm-create) command. This command uses SSH keys for authentication and doesn't create a public IP address.

    ```azurecli
    az vm create \
        --resource-group $VNET_RESOURCE_GROUP \
        --name $VM_NAME \
        --image Ubuntu2204 \
        --size Standard_B2s \
        --vnet-name $VNET_NAME \
        --subnet $VM_SUBNET_NAME \
        --admin-username $VM_ADMIN_USERNAME \
        --authentication-type ssh \
        --generate-ssh-keys \
        --public-ip-address ""
    ```
5. Connect to the VM through Azure Bastion or from a network that can reach the VM's private IP address. On the VM, install the Azure CLI, `kubectl`, and the `nslookup` utility.

    ```bash
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    sudo az aks install-cli
    sudo apt-get update && sudo apt-get install --yes dnsutils
    ```
6. On the VM, set the AKS cluster variables, sign in to Azure, select the subscription that contains the cluster, and retrieve the cluster credentials.

    ```azurecli
    AKS_RESOURCE_GROUP=<aks-resource-group-name>
    AKS_CLUSTER_NAME=<aks-cluster-name>
    
    az login --use-device-code
    az account set --subscription <subscription-id>
    az aks get-credentials \
        --resource-group $AKS_RESOURCE_GROUP \
        --name $AKS_CLUSTER_NAME
    ```
7. Verify that the private API server fully qualified domain name (FQDN) resolves to a private IP address from the VM.

    ```azurecli
    AKS_PRIVATE_FQDN=$(az aks show \
        --resource-group $AKS_RESOURCE_GROUP \
        --name $AKS_CLUSTER_NAME \
        --query privateFqdn \
        --output tsv)
    
    nslookup $AKS_PRIVATE_FQDN
    ```
8. Verify connectivity and authorization to the private API server.

    ```bash
    kubectl get nodes
    ```

::: zone-end

::: zone pivot="express-route-or-vpn"

## Use an Express Route or VPN connection

To use an Express Route or VPN connection, see [About ExpressRoute virtual network gateways](/en-us/azure/expressroute/expressroute-about-virtual-network-gateways).

::: zone-end

::: zone pivot="aks-command-invoke"

## Use the AKS `command invoke` feature

To use the AKS `command invoke` feature to connect to a private cluster, see [Access a private cluster using `command invoke`](access-private-cluster).

::: zone-end