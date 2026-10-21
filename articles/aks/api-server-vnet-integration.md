---
layout: Conceptual
title: API Server VNet Integration in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/api-server-vnet-integration
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
description: Learn how to use API Server VNet Integration in Azure Kubernetes Service (AKS), including AKS Automatic where it's preconfigured and AKS Standard where you enable it explicitly.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2026-04-15T00:00:00.0000000Z
ms.custom: references_regions, devx-track-azurecli
locale: en-us
document_id: 5c8d52f7-77c7-03f6-39b6-64d2efe5fd0a
document_version_independent_id: b8795965-fb37-b865-2a88-b1ce5b5454a7
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/api-server-vnet-integration.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/api-server-vnet-integration
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/api-server-vnet-integration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a184a442-7b03-08e1-dc6f-311dc8790920
---

# API Server VNet Integration in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic ✔️ AKS Standard

An Azure Kubernetes Service (AKS) cluster configured with API Server VNet Integration projects the API server endpoint directly into a delegated subnet in the VNet where AKS is deployed. API Server VNet Integration enables network communication between the API server and the cluster nodes without requiring a private link or tunnel. The API server is available behind an internal load balancer VIP in the delegated subnet, which the nodes are configured to utilize. By using API Server VNet Integration, you can ensure network traffic between your API server and your node pools remains on the private network only.

For most production workloads, AKS Automatic is the recommended default AKS experience. AKS Automatic is production ready by default and includes API Server VNet Integration as a preconfigured cluster security capability. In AKS Standard, API Server VNet Integration is optional and you enable it during cluster creation or by updating an existing cluster.

To learn more about AKS Automatic, see [What is Azure Kubernetes Service (AKS) Automatic?](intro-aks-automatic)

## API Server VNet Integration in AKS Automatic and AKS Standard

API Server VNet Integration is available in both AKS cluster modes, but setup differs:

- **AKS Automatic**: API Server VNet Integration is preconfigured.
- **AKS Standard**: API Server VNet Integration is optional and must be enabled explicitly.

For most production scenarios, start with AKS Automatic to use production-ready defaults and reduce operational overhead.

## API server connectivity

The control plane or API server is in an AKS-managed Azure subscription. Your cluster or node pool is in your Azure subscription. The server and the virtual machines that make up the cluster nodes can communicate with each other through the API server VIP and pod IPs that are projected into the delegated subnet.

API Server VNet Integration is supported for public or private clusters. You can add or remove public access after cluster provisioning. Unlike non-VNet integrated clusters, the agent nodes always communicate directly with the private IP address of the API server internal load balancer (ILB) IP without using DNS. All node to API server traffic is kept on private networking, and no tunnel is required for API server to node connectivity. Out-of-cluster clients needing to communicate with the API server can do so normally if public network access is enabled. If public network access is disabled, you should follow the same private DNS setup methodology as standard [private clusters](private-clusters).

## Prerequisites

- You must have Azure CLI version 2.73.0 or later installed. You can check your version using the `az --version` command.
- If you bring your own virtual network, review the [virtual network prerequisites](concepts-network-cni-overview#aks-cni-networking-prerequisites).

## Limitations

The following limitations apply to API Server VNet Integration, whether it's preconfigured on AKS Automatic or explicitly enabled on AKS Standard:

- API Server VNet Integration doesn't support [Virtual Network Encryption](/en-us/azure/virtual-network/virtual-network-encryption-overview). Clusters deployed on **v3 or earlier AKS node SKUs** (which don't support VNet Encryption) are allowed, but traffic isn't encrypted. Clusters deployed on **v4 or later AKS node SKUs** (which support VNet Encryption) are blocked because encrypted VNets are incompatible with API Server VNet Integration. For more information, see [AKS supported VM SKUs](quotas-skus-regions#supported-vm-sizes-in-aks).
- To use dual-stack networking your cluster needs Kubernetes version 1.26.3 or later, network plugin `azure` and network plugin mode `overlay`. For more information, see [Azure CNI cluster with dual-stack networking](azure-cni-overlay).

## Availability

- API Server VNet Integration is available in all GA public cloud regions except qatarcentral.

## Create a cluster with API Server VNet Integration

### AKS Automatic (recommended default for production)

In AKS Automatic, API Server VNet Integration is preconfigured. No explicit `--enable-apiserver-vnet-integration` flag is required.

Create an AKS Automatic cluster by following the quickstart:

- [Create an Azure Kubernetes Service (AKS) Automatic cluster](automatic/quick-automatic-managed-network)

### AKS Standard: managed VNet

You can configure AKS Standard clusters with API Server VNet Integration in managed VNet mode as public or private clusters.

Note

API Server VNet Integration isn't available in qatarcentral.

#### Create a resource group

Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

```azurecli
az group create --location <location> --name <resource-group>
```

#### Deploy a public cluster

Deploy a public AKS Standard cluster with API Server VNet integration for managed VNet using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-apiserver-vnet-integration` flag.

```azurecli
az aks create --name <cluster-name> \
    --resource-group <resource-group> \
    --location <location> \
    --network-plugin azure \
    --enable-apiserver-vnet-integration \
    --generate-ssh-keys
```

#### Deploy a private cluster

Deploy a private AKS Standard cluster with API Server VNet integration for managed VNet using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-apiserver-vnet-integration` and `--enable-private-cluster` flags.

```azurecli
az aks create --name <cluster-name> \
    --resource-group <resource-group> \
    --location <location> \
    --network-plugin azure \
    --enable-private-cluster \
    --enable-apiserver-vnet-integration \
    --generate-ssh-keys
```

### AKS Standard: bring-your-own VNet

When you use bring-your-own VNet, you must create and delegate an API server subnet to `Microsoft.ContainerService/managedClusters`. This delegation grants the AKS service permissions to inject the API server pods and internal load balancer into that subnet. You can't use the subnet for any other workloads, but you can use it for multiple AKS clusters located in the same virtual network. The minimum supported API server subnet size is `/28`.

The cluster identity needs permissions to both the API server subnet and the node subnet. Lack of permissions at the API server subnet can cause a provisioning failure.

Warning

An AKS cluster reserves at least nine IPs in the subnet address space. Running out of IP addresses can prevent API server scaling and cause an API server outage.

Note

API Server VNet Integration isn't available in qatarcentral.

#### Create a resource group

Create a resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

```azurecli
az group create --location <location> --name <resource-group>
```

#### Create a virtual network

1. Create a virtual network using the [`az network vnet create`](/en-us/cli/azure/network/vnet#az-network-vnet-create) command.

    ```azurecli
    az network vnet create --name <vnet-name> \
    --resource-group <resource-group> \
    --location <location> \
    --address-prefixes 172.19.0.0/16
    ```
2. Create an API server subnet using the [`az network vnet subnet create`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-create) command.

    ```azurecli
    az network vnet subnet create --resource-group <resource-group> \
    --vnet-name <vnet-name> \
    --name <apiserver-subnet-name> \
    --delegations Microsoft.ContainerService/managedClusters \
    --address-prefixes 172.19.0.0/28
    ```
3. Create a cluster subnet using the [`az network vnet subnet create`](/en-us/cli/azure/network/vnet/subnet#az-network-vnet-subnet-create) command.

    ```azurecli
    az network vnet subnet create --resource-group <resource-group> \
    --vnet-name <vnet-name> \
    --name <cluster-subnet-name> \
    --address-prefixes 172.19.1.0/24
    ```

#### Create a managed identity and give it permissions on the virtual network

1. Create a managed identity using the [`az identity create`](/en-us/cli/azure/identity#az-identity-create) command.

    ```azurecli
    az identity create --resource-group <resource-group> --name <managed-identity-name> --location <location>
    ```
2. Assign the Network Contributor role to the API server subnet using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create --scope <apiserver-subnet-resource-id> \
    --role "Network Contributor" \
    --assignee <managed-identity-client-id>
    ```
3. Assign the Network Contributor role to the cluster subnet using the [`az role assignment create`](/en-us/cli/azure/role/assignment#az-role-assignment-create) command.

    ```azurecli
    az role assignment create --scope <cluster-subnet-resource-id> \
    --role "Network Contributor" \
    --assignee <managed-identity-client-id>
    ```

#### Deploy a public cluster

Deploy a public AKS cluster with API Server VNet integration using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-apiserver-vnet-integration` flag.

```azurecli
az aks create --name <cluster-name> \
    --resource-group <resource-group> \
    --location <location> \
    --network-plugin azure \
    --enable-apiserver-vnet-integration \
    --vnet-subnet-id <cluster-subnet-resource-id> \
    --apiserver-subnet-id <apiserver-subnet-resource-id> \
    --assign-identity <managed-identity-resource-id> \
    --generate-ssh-keys
```

#### Deploy a private cluster

Deploy a private AKS cluster with API Server VNet integration using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-apiserver-vnet-integration` and `--enable-private-cluster` flags.

```azurecli
az aks create --name <cluster-name> \
    --resource-group <resource-group> \
    --location <location> \
    --network-plugin azure \
    --enable-private-cluster \
    --enable-apiserver-vnet-integration \
    --vnet-subnet-id <cluster-subnet-resource-id> \
    --apiserver-subnet-id <apiserver-subnet-resource-id> \
    --assign-identity <managed-identity-resource-id> \
    --generate-ssh-keys
```

## Convert an existing AKS Standard cluster to API Server VNet Integration

Warning

**API Server VNet Integration is a one-way, capacity-sensitive feature**. When you enable API Server VNet Integration on an existing AKS Standard cluster, the following limitations apply:

- **Manual restart required**: After enabling API Server VNet Integration using `az aks update --enable-apiserver-vnet-integration`, due to control plane resource transition, you must immediately restart the cluster for the change to take effect. This restart isn't automated. Delaying the restart increases the risk of capacity becoming unavailable, which can prevent the API server from starting. The cluster restart also ensures that all nodes reliably reconnect to the new API server endpoint.
- **Capacity is validated, but not reserved**: AKS validates regional capacity when you enable the feature on an existing cluster, but this validation doesn't reserve capacity. If you delay the restart and capacity becomes unavailable in the meantime, the cluster might fail to start after a stop or restart. Clusters that enabled this feature before general availability (GA), or that haven't yet restarted since enablement, don't undergo capacity validation.
- **Feature can't be disabled**: Once enabled, the feature is permanent. You can't disable API Server VNet Integration.

This upgrade performs a node-image version upgrade on all node pools and restarts all workloads while they undergo a rolling image upgrade.

Warning

Converting a cluster to API Server VNet Integration results in a change of the API Server IP address, though the hostname remains the same. If you configure the IP address of the API server in any firewalls or network security group rules, you might need to update those rules.

1. Update your cluster to API Server VNet Integration using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-apiserver-vnet-integration` flag.

    ```azurecli
    az aks update --name <cluster-name> \
        --resource-group <resource-group> \
        --enable-apiserver-vnet-integration \
        --apiserver-subnet-id <apiserver-subnet-resource-id>
    ```
2. Restart your cluster using the [`az aks stop`](/en-us/cli/azure/aks#az-aks-stop) and [`az aks start`](/en-us/cli/azure/aks#az-aks-update) commands.

    ```azurecli
    az aks stop --name <cluster-name> --resource-group <resource-group>
    az aks start --name <cluster-name> --resource-group <resource-group>
    ```

## Enable or disable private cluster mode on an existing cluster with API Server VNet Integration

AKS clusters configured with API Server VNet Integration can have public network access/private cluster mode enabled or disabled without redeploying the cluster. The API server hostname doesn't change, but public DNS entries are modified or removed if necessary.

Note

`--disable-private-cluster` is currently in preview. For more information, see [Reference and support levels](/en-us/cli/azure/reference-types-and-status).

### Enable private cluster mode

Enable private cluster mode using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-private-cluster` flag.

```azurecli
az aks update --name <cluster-name> \
    --resource-group <resource-group> \
    --enable-private-cluster \
    --enable-apiserver-vnet-integration \
    --apiserver-subnet-id <apiserver-subnet-resource-id>
```

### Disable private cluster mode

Disable private cluster mode using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-private-cluster` flag.

```azurecli
az aks update --name <cluster-name> \
    --resource-group <resource-group> \
    --disable-private-cluster
```

## Connect to cluster using kubectl

Configure `kubectl` to connect to your cluster using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

```azurecli
az aks get-credentials --resource-group <resource-group> --name <cluster-name>
```

## Expose the API server through Private Link

You can expose the API server endpoint of a private cluster with API Server VNet Integration using Azure Private Link. The following steps show how to create a Private Link Service (PLS) in the cluster VNet and connect to it from another VNet or subscription using a Private Endpoint.

Note

API Server VNet Integration isn't available in qatarcentral.

### Create an API Server VNet Integration Private cluster

Create a private AKS cluster with API Server VNet Integration using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-apiserver-vnet-integration` and `--enable-private-cluster` flags.

```azurecli
az aks create --name <cluster-name> \
    --resource-group <resource-group> \
    --location <location> \
    --enable-private-cluster \
    --enable-apiserver-vnet-integration
```

For more guidance on how to set up Private Link with API Server VNet Integration, see [Private Link with API Server VNet Integration](private-apiserver-vnet-integration-cluster).

## Network security group (NSG) security rules

All traffic within the VNet is allowed by default. But if you have added NSG rules to restrict traffic between different subnets, ensure that the NSG security rules permit the following types of communication:

| Destination | Source | Protocol | Port | Use |
| --- | --- | --- | --- | --- |
| APIServer Subnet CIDR | Cluster Subnet | TCP | 443 and 4443 | Required to enable communication between Nodes and the API server. |
| APIServer Subnet CIDR | Azure Load Balancer | TCP | 9988 | Required to enable communication between Azure Load Balancer and the API server. You can also enable all communications between the Azure Load Balancer and the API Server Subnet CIDR. |