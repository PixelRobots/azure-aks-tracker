---
layout: Conceptual
title: Access a Private API Server VNet Integration Cluster from Another Virtual Network - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/private-apiserver-vnet-integration-cluster
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
description: Step‑by‑step guidance for exposing the API server of an AKS cluster that has API Server VNet Integration enabled, by using Azure Private Link and consuming it from a separate virtual network.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2026-03-03T00:00:00.0000000Z
ms.custom: devx-track-azurecli
locale: en-us
document_id: 6754aac3-f509-54c8-c03c-b95ce2880f37
document_version_independent_id: 0abe4ce9-70da-dd65-7580-9d4bacacf46b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/private-apiserver-vnet-integration-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/private-apiserver-vnet-integration-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/private-apiserver-vnet-integration-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/16cd61cd-9ecf-429b-b494-91576c41f8e4
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/c4bdb33a-5524-4b66-b162-03f5621d7902
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
platformId: 76eb244c-2e9c-8bf4-6b3c-2fe12bd4e9ab
---

# Access a Private API Server VNet Integration Cluster from Another Virtual Network - Azure Kubernetes Service | Microsoft Learn

With API Server VNet Integration, the AKS control plane is reachable through a private IP inside your cluster's virtual network (VNet). This configuration works well for workloads running in the same VNet, but it doesn't automatically cover external networks, such as a hub network, a dedicated operations VNet, or a jump-host environment that need to reach the API server without exposing it to the public internet. This article shows you how to bridge that gap by fronting the API server with a Private Link Service, then connecting to it from a separate virtual network through a Private Endpoint.

This article applies only to **private AKS clusters that are created with [API Server VNet Integration](api-server-vnet-integration) and use a bring-your-own VNet (BYO VNet) configuration**. You learn how to:

- Deploy a **private** AKS cluster with API Server VNet Integration using your own VNet.
- Expose the API server through a **Private Link Service (PLS)** inside the cluster virtual network.
- Create a **Private Endpoint (PE)** in a different virtual network.
- Configure **private DNS** so Kubernetes tools resolve the cluster's private FQDN inside the remote network.

For private clusters that **don't** use API Server VNet Integration, see [Create a private AKS cluster](private-clusters).

## Region availability

API Server VNet Integration is currently available in a subset of Azure regions and is subject to regional capacity limits. Before you begin, confirm that your target region is supported. For more information, see [API Server VNet Integration](api-server-vnet-integration).

## Prerequisites

- Minimum Azure CLI version 2.73.0. Check your version using the `az --version` command. To install or update the Azure CLI, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- You need Contributor and Network Contributor permissions on both the subscription where the AKS cluster is deployed and the subscription where you create the Private Endpoint (if different). This is required to create and manage the necessary network resources such as subnets, Private Link Service, and Private Endpoint. For more information, see [Azure role-based access control (RBAC) built-in roles](/en-us/azure/role-based-access-control/built-in-roles).
- If you're using custom DNS servers, you need to add Azure's virtual IP, *168.63.129.16*, as an upstream forwarder.

## Set environment variables

- Set the following environment variables for use throughout this article. Feel free to replace the placeholder values with your own.

    ```bash
    LOCATION="westus3"
    
    # Resource groups
    AKS_RG="aks-demo-rg"
    REMOTE_RG="client-demo-rg"
    
    # AKS cluster VNet and subnets (all user-owned, in AKS_RG)
    AKS_VNET="aks-vnet"
    AKS_VNET_PREFIX="172.19.0.0/16"
    APISERVER_SUBNET="apiserver-subnet"
    APISERVER_SUBNET_PREFIX="172.19.0.0/28"
    NODE_SUBNET="node-subnet"
    NODE_SUBNET_PREFIX="172.19.1.0/24"
    
    # Private Link Service subnet (also in the cluster VNet, user-owned)
    PLS_SUBNET="pls-subnet"
    PLS_SUBNET_PREFIX="172.19.2.0/24"
    
    # AKS cluster
    AKS_CLUSTER="aks-private"
    AKS_IDENTITY="aks-identity"
    
    # Private Link Service
    PLS_NAME="apiserver-pls"
    
    # Remote VNet
    REMOTE_VNET="client-vnet"
    REMOTE_SUBNET="client-subnet"
    REMOTE_VNET_PREFIX="192.168.0.0/16"
    REMOTE_SUBNET_PREFIX="192.168.1.0/24"
    PE_NAME="aks-pe"
    PE_CONN_NAME="aks-pe-conn"
    
    # DNS
    DNS_ZONE="private.${LOCATION}.azmk8s.io"
    DNS_LINK="dns-link"
    ```

## Create resource groups

1. Create a resource group for the AKS cluster using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --name $AKS_RG --location $LOCATION
    ```
2. Create a resource group for the remote VNet and Private Endpoint using the [`az group create`](/en-us/cli/azure/group#az-group-create) command. This can be in the same subscription or a different one, but it must be in the same region

    ```azurecli
    az group create --name $REMOTE_RG --location $LOCATION
    ```

## Create the cluster VNet and subnets

With BYO VNet, you create and own the VNet before the cluster is deployed. This lets you add resources such as the PLS subnet to the VNet without touching AKS-managed infrastructure.

Three subnets are required:

| Subnet | Purpose | Notes |
| --- | --- | --- |
| `apiserver-subnet` | API server internal load balancer injection | Must be delegated to `Microsoft.ContainerService/managedClusters`; minimum `/28` |
| `node-subnet` | AKS worker nodes | Standard cluster subnet |
| `pls-subnet` | Private Link Service | Must have private link service network policies disabled |

1. Create the cluster VNet using the [`az network vnet create`](/en-us/cli/azure/network/vnet#az-network-vnet-create) command.

    ```azurecli
    az network vnet create \
      --name $AKS_VNET \
      --resource-group $AKS_RG \
      --location $LOCATION \
      --address-prefixes $AKS_VNET_PREFIX
    ```
2. Create the API server subnet delegated to AKS using the [`az network vnet subnet create`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-create) command. AKS injects the control plane internal load balancer into this subnet, so delegation to `Microsoft.ContainerService/managedClusters` is required.

    ```azurecli
    az network vnet subnet create \
      --name $APISERVER_SUBNET \
      --vnet-name $AKS_VNET \
      --resource-group $AKS_RG \
      --address-prefixes $APISERVER_SUBNET_PREFIX \
      --delegations Microsoft.ContainerService/managedClusters
    ```
3. Create the node subnet using the [`az network vnet subnet create`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-create) command.

    ```azurecli
    # Create the node subnet
    az network vnet subnet create \
      --name $NODE_SUBNET \
      --vnet-name $AKS_VNET \
      --resource-group $AKS_RG \
      --address-prefixes $NODE_SUBNET_PREFIX
    ```
4. Create the Private Link Service subnet with network policies disabled using the [`az network vnet subnet create`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-create) command. Network policies must be disabled on the PLS subnet to allow traffic from the Private Endpoint to reach the API server internal load balancer.

    ```azurecli
    az network vnet subnet create \
      --name $PLS_SUBNET \
      --vnet-name $AKS_VNET \
      --resource-group $AKS_RG \
      --address-prefixes $PLS_SUBNET_PREFIX \
      --disable-private-link-service-network-policies
    ```

## Create a managed identity and assign permissions

AKS requires a managed identity with Network Contributor rights on both the API server subnet and the node subnet to manage network resources during cluster operations.

1. Create a user-assignment managed identity for the cluster using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    ```azurecli
    az identity create \
      --name $AKS_IDENTITY \
      --resource-group $AKS_RG \
      --location $LOCATION
    ```
2. Get the resource ID of the managed identity using the [`az identity show`](/en-us/cli/azure/identity#az-identity-show) command and set it to an environment variable. You need this value to assign the identity to the cluster.

    ```azurecli
    IDENTITY_ID=$(az identity show \
      --name $AKS_IDENTITY \
      --resource-group $AKS_RG \
      --query id -o tsv)
    ```
3. Get the client ID of the managed identity using the [`az identity show`](/en-us/cli/azure/identity#az-identity-show) command and set it to an environment variable. You need this value to assign roles on the subnets.

    ```azurecli
    IDENTITY_CLIENT_ID=$(az identity show \
      --name $AKS_IDENTITY \
      --resource-group $AKS_RG \
      --query clientId -o tsv)
    ```
4. Get the API server subnet ID using the [`az network vnet subnet show`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-show) command and set it to an environment variable.

    ```azurecli
    APISERVER_SUBNET_ID=$(az network vnet subnet show \
      --name $APISERVER_SUBNET \
      --vnet-name $AKS_VNET \
      --resource-group $AKS_RG \
      --query id -o tsv)
    ```
5. Get the node subnet ID using the [`az network vnet subnet show`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-show) command and set it to an environment variable.

    ```azurecli
    NODE_SUBNET_ID=$(az network vnet subnet show \
      --name $NODE_SUBNET \
      --vnet-name $AKS_VNET \
      --resource-group $AKS_RG \
      --query id -o tsv)
    ```
6. Assign the Network Contributor role to the API server subnet using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create \
      --scope $APISERVER_SUBNET_ID \
      --role "Network Contributor" \
      --assignee $IDENTITY_CLIENT_ID
    ```
7. Assign the Network Contributor role to the node subnet using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create \
      --scope $NODE_SUBNET_ID \
      --role "Network Contributor" \
      --assignee $IDENTITY_CLIENT_ID
    ```

## Deploy a private cluster with API Server VNet Integration

1. Create the private AKS cluster with API Server VNet Integration using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. You must specify the `--enable-apiserver-vnet-integration` flag to enable the feature, and provide the IDs of the API server subnet, node subnet, and managed identity you created in the previous steps. AKS injects the API server internal load balancer into the API server subnet and deploys worker nodes into the node subnet.

    ```azurecli
    az aks create \
      --name $AKS_CLUSTER \
      --resource-group $AKS_RG \
      --location $LOCATION \
      --network-plugin azure \
      --enable-private-cluster \
      --enable-apiserver-vnet-integration \
      --vnet-subnet-id $NODE_SUBNET_ID \
      --apiserver-subnet-id $APISERVER_SUBNET_ID \
      --assign-identity $IDENTITY_ID \
      --generate-ssh-keys
    ```
2. After the cluster finishes provisioning, get the node resource group where AKS deploys the kube-apiserver internal load balancer using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command and set it to an environment variable.

    ```azurecli
    AKS_NODE_RG=$(az aks show \
      --name $AKS_CLUSTER \
      --resource-group $AKS_RG \
      --query nodeResourceGroup -o tsv)
    ```
3. Get the private FQDN label to construct the DNS record name later using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command and set it to an environment variable. The private FQDN is in the format `<label>.<region>.azmk8s.io`, so you can extract the label by splitting on the dots.

    ```azurecli
    DNS_RECORD=$(az aks show \
      --name $AKS_CLUSTER \
      --resource-group $AKS_RG \
      --query privateFqdn -o tsv | cut -d'.' -f1,2)
    ```
4. Get the API server internal load balancer frontend IP configuration ID using the [`az network lb show`](/en-us/cli/azure/network/lb#az-network-lb-show) command and set it to an environment variable. You need this value to front the API server with the Private Link Service.

    ```azurecli
    FRONTEND_IP_CONFIG_ID=$(az network lb show \
      --name kube-apiserver \
      --resource-group $AKS_NODE_RG \
      --query "frontendIPConfigurations[0].id" \
      -o tsv)
    ```

## Create a Private Link Service (PLS) in the cluster VNet

Because you own the cluster VNet, you can create the PLS and its subnet directly in `AKS_RG` without interacting with AKS-managed resources. Point the PLS at the `kube-apiserver` internal load balancer frontend that AKS created in the node resource group.

- Create the Private Link Service in the cluster VNet using the [`az network private-link-service create`](/en-us/cli/azure/network/private-link-service#az-network-private-link-service-create) command. Specify the frontend IP configuration of the kube-apiserver internal load balancer to front the API server with this PLS.

    ```azurecli
    az network private-link-service create \
      --name $PLS_NAME \
      --resource-group $AKS_RG \
      --vnet-name $AKS_VNET \
      --subnet $PLS_SUBNET \
      --lb-frontend-ip-configs $FRONTEND_IP_CONFIG_ID \
      --location $LOCATION
    ```

## Create a remote VNet and subnet for the Private Endpoint

1. Create the remote VNet using the [`az network vnet create`](/en-us/cli/azure/network/vnet#az-network-vnet-create) command.

    ```azurecli
    az network vnet create \
      --name $REMOTE_VNET \
      --resource-group $REMOTE_RG \
      --location $LOCATION \
      --address-prefixes $REMOTE_VNET_PREFIX
    ```
2. Create the remote subnet using the [`az network vnet subnet create`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-create) command.

    ```azurecli
    az network vnet subnet create \
      --name $REMOTE_SUBNET \
      --vnet-name $REMOTE_VNET \
      --resource-group $REMOTE_RG \
      --address-prefixes $REMOTE_SUBNET_PREFIX
    ```

## Create a Private Endpoint in the remote VNet

1. Get the Private Link Service ID for the Private Endpoint connection using the [`az network private-link-service show`](/en-us/cli/azure/network/private-link-service#az-network-private-link-service-show) command and set it to an environment variable.

    ```azurecli
    PLS_ID=$(az network private-link-service show \
      --name $PLS_NAME \
      --resource-group $AKS_RG \
      --query id -o tsv)
    ```
2. Create the Private Endpoint in the remote VNet and connect it to the PLS in the cluster VNet using the [`az network private-endpoint create`](/en-us/cli/azure/network/private-endpoint#az-network-private-endpoint-create) command. This establishes the private connection between the remote VNet and the API server internal load balancer through the PLS.

    ```azurecli
    az network private-endpoint create \
      --name $PE_NAME \
      --resource-group $REMOTE_RG \
      --vnet-name $REMOTE_VNET \
      --subnet $REMOTE_SUBNET \
      --private-connection-resource-id $PLS_ID \
      --connection-name $PE_CONN_NAME \
      --location $LOCATION
    ```
3. When the Private Endpoint finishes provisioning, get the network interface (NIC) ID using the [`az network private-endpoint show`](/en-us/cli/azure/network/private-endpoint#az-network-private-endpoint-show) command and set it to an environment variable. You need this value to get the private IP address assigned to the Private Endpoint, which is used for DNS configuration in the next step.

    ```azurecli
    PE_NIC_ID=$(az network private-endpoint show \
      --name $PE_NAME \
      --resource-group $REMOTE_RG \
      --query 'networkInterfaces[0].id' \
      --output tsv)
    ```
4. Get the Private Endpoint private IP address from the NIC using the [`az network nic show`](/en-us/cli/azure/network/nic#az-network-nic-show) command and set it to an environment variable.

    ```azurecli
    PE_IP=$(az network nic show \
      --ids $PE_NIC_ID \
      --query 'ipConfigurations[0].privateIPAddress' \
      --output tsv)
    ```

## Configure private DNS

1. Create or reuse a private DNS zone in the remote resource group using the [`az network private-dns zone create`](/en-us/cli/azure/network/private-dns/zone#az-network-private-dns-zone-create) command. The DNS zone name should match the suffix of the API server's private FQDN, which is in the format `<label>.<region>.azmk8s.io`. In this example, we use `private.<region>.azmk8s.io` as the DNS zone name.

    ```azurecli
    az network private-dns zone create \
      --name $DNS_ZONE \
      --resource-group $REMOTE_RG
    ```
2. Create an A record in the DNS zone for the API server private FQDN and point it to the Private Endpoint IP address using the [`az network private-dns record-set a create`](/en-us/cli/azure/network/private-dns/record-set#a-record-set-create) command.

    ```azurecli
    az network private-dns record-set a create \
      --name $DNS_RECORD \
      --zone-name $DNS_ZONE \
      --resource-group $REMOTE_RG
    ```
3. Add the A record pointing to the Private Endpoint IP address using the [`az network private-dns record-set a add-record`](/en-us/cli/azure/network/private-dns/record-set#a-record-set-add-record) command.

    ```azurecli
    az network private-dns record-set a add-record \
      --record-set-name $DNS_RECORD \
      --zone-name $DNS_ZONE \
      --resource-group $REMOTE_RG \
      --ipv4-address $PE_IP
    ```
4. Link the DNS zone to the remote VNet using the [`az network private-dns link vnet create`](/en-us/cli/azure/network/private-dns/link#az-network-private-dns-link-vnet-create) command. This allows resources in the remote VNet to resolve the API server's private FQDN to the Private Endpoint IP address.

    ```azurecli
    REMOTE_VNET_ID=$(az network vnet show \
      --name $REMOTE_VNET \
      --resource-group $REMOTE_RG \
      --query id -o tsv)
    ```
5. Link the DNS zone to the remote VNet so the private FQDN resolves inside that network using the [`az network private-dns link vnet create`](/en-us/cli/azure/network/private-dns/link#az-network-private-dns-link-vnet-create) command.

    ```azurecli
    az network private-dns link vnet create \
      --name $DNS_LINK \
      --zone-name $DNS_ZONE \
      --resource-group $REMOTE_RG \
      --virtual-network $REMOTE_VNET_ID \
      --registration-enabled false
    ```

## Test the connection

Note

If you try to test the connection locally, you might get an error because the DNS zone isn't linked to your local network.

1. Get the AKS credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This command configures your local `kubectl` context to connect to the cluster. If you're running this command from a machine that isn't in the remote VNet, you might get an error because the private FQDN doesn't resolve. This is expected and confirms that the cluster isn't accessible from outside the remote VNet.

    ```azurecli
    az aks get-credentials --resource-group $AKS_RG --name $AKS_CLUSTER
    ```
2. Check the connection by running a `kubectl` command, such as `kubectl get nodes`. This command should succeed if you're running it from a machine that has network access to the remote VNet and the DNS resolution is working correctly. If you run this command from a machine that doesn't have access to the remote VNet, it should fail, confirming that the cluster is only accessible through the Private Endpoint.

    ```bash
    kubectl get nodes
    ```

### Deploy a test virtual machine (VM) in the remote VNet

To confirm the Private Endpoint path, deploy a test VM in the remote VNet and use it to connect to the AKS cluster.

1. Create a Network Security Group (NSG) that allows inbound SSH traffic on TCP port 22 using the [`az network nsg create`](/en-us/cli/azure/network/nsg#az-network-nsg-create) command.

    ```azurecli
    az network nsg create \
      --name "${REMOTE_VNET}-nsg" \
      --resource-group $REMOTE_RG \
      --location $LOCATION
    ```
2. Add an NSG rule to allow inbound SSH traffic on TCP port 22 using the [`az network nsg rule create`](/en-us/cli/azure/network/nsg/rule#az-network-nsg-rule-create) command.

    ```azurecli
    az network nsg rule create \
      --nsg-name "${REMOTE_VNET}-nsg" \
      --resource-group $REMOTE_RG \
      --name allow-ssh \
      --priority 100 \
      --access Allow \
      --protocol Tcp \
      --direction Inbound \
      --source-address-prefixes '*' \
      --destination-port-ranges 22
    ```
3. Associate the NSG with the remote subnet using the [`az network vnet subnet update`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-update) command.

    ```azurecli
    az network vnet subnet update \
      --name $REMOTE_SUBNET \
      --vnet-name $REMOTE_VNET \
      --resource-group $REMOTE_RG \
      --network-security-group "${REMOTE_VNET}-nsg"
    ```
4. Create a small Ubuntu VM in that subnet with a public IP for quick SSH access using the [`az vm create`](/en-us/cli/azure/vm#az-vm-create) command.

    ```azurecli
    az vm create \
      --resource-group $REMOTE_RG \
      --name test-vm \
      --image Ubuntu2204 \
      --size Standard_B2s \
      --admin-username azureuser \
      --generate-ssh-keys \
      --vnet-name $REMOTE_VNET \
      --subnet $REMOTE_SUBNET \
      --public-ip-sku Standard
    ```
5. Get the public IP address of the VM using the [`az vm show`](/en-us/cli/azure/vm#az-vm-show) command and set it to an environment variable. You need this IP address to SSH into the VM for testing.

    ```azurecli
    VM_PUBLIC_IP=$(az vm show -d --resource-group $REMOTE_RG --name test-vm --query publicIps -o tsv)
    ```

### Connect to the VM and test the connection

1. SSH into the VM using the public IP address and the private key you generated when creating the VM. The default username is `azureuser` unless you specified a different one during VM creation.

    ```bash
    ssh -i ~/.ssh/id_rsa azureuser@$VM_PUBLIC_IP
    ```
2. Once connected to the VM, install the Azure CLI and kubectl to test connectivity to the AKS cluster through the Private Endpoint.

    ```bash
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    ```
3. Install kubectl using the Azure CLI command.

    ```bash
    sudo az aks install-cli
    ```
4. Re-export the AKS variables in the VM environment so you can use them to get credentials and test the connection.

    ```bash
    export AKS_RG="aks-demo-rg"
    export AKS_CLUSTER="aks-private"
    ```
5. Log in to Azure using the [`az login`](/en-us/cli/azure/authenticate-azure-cli-interactively#interactive-login) command. This command prompts you to authenticate, and you can follow the instructions to complete the login process.

    ```azurecli
    az login
    ```
6. Get the AKS credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command. This configures `kubectl` to connect to the cluster through the Private Endpoint.

    ```azurecli
    az aks get-credentials --resource-group $AKS_RG --name $AKS_CLUSTER
    ```
7. Test the connection to the AKS cluster by running a `kubectl` command, such as `kubectl get nodes`. If everything is set up correctly, this command should succeed and return the list of nodes in the cluster, confirming that you can access the private API server through the Private Endpoint from the remote VNet.

    ```bash
    kubectl get nodes
    ```
8. After testing, you can exit the SSH session on the VM.

    ```bash
    exit
    ```

## Clean up resources

- To avoid ongoing Azure charges, delete the resource groups using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command. This deletes all resources contained in those groups, including the AKS cluster, virtual networks, Private Link Service, Private Endpoint, and DNS zone.

    ```azurecli
    az group delete --name $AKS_RG --yes --no-wait
    az group delete --name $REMOTE_RG --yes --no-wait
    ```