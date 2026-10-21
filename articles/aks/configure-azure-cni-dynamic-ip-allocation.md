---
layout: Conceptual
title: Configure Azure CNI Pod Subnet - Dynamic IP Allocation and enhanced subnet support in AKS - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni-dynamic-ip-allocation
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
description: Learn how to configure Azure CNI for dynamic IP allocation and enhanced subnet support in AKS, improving IP address management and cluster scalability.
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2026-09-10T00:00:00.0000000Z
ms.custom: references_regions, devx-track-azurecli
ai-usage: ai-assisted
locale: en-us
document_id: 431be8db-aaf4-02d8-d8eb-346f1e03a396
document_version_independent_id: f30f2e39-6ceb-7555-197e-8cd48763117d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-azure-cni-dynamic-ip-allocation.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/configure-azure-cni-dynamic-ip-allocation
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-azure-cni-dynamic-ip-allocation.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68cb9039-df60-49b0-8ef8-89ad96497f63
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/725b6df3-93e8-472d-834e-e7e0d2953d35
platformId: 5f7851f7-bbe7-11fa-92e0-2bee0872f5ea
---

# Configure Azure CNI Pod Subnet - Dynamic IP Allocation and enhanced subnet support in AKS - Azure Kubernetes Service | Microsoft Learn

A drawback with the traditional CNI is the exhaustion of pod IP addresses as the AKS cluster grows, which results in the need to rebuild your entire cluster in a bigger subnet. The new dynamic IP allocation capability in Azure CNI solves this problem by allocating pod IPs from a subnet separate from the subnet hosting the AKS cluster.

It offers the following benefits:

- **Better IP utilization**: IPs are dynamically allocated to cluster pods from the pod subnet. This method leads to better utilization of IPs in the cluster compared to the traditional CNI solution, which does static allocation of IPs for every node.
- **Scalable and flexible**: You can scale node and pod subnets independently. A single pod subnet can be shared across multiple node pools of a cluster or across multiple AKS clusters deployed in the same VNet. You can also configure a separate pod subnet for a node pool.
- **High performance**: Since pods are assigned virtual network IPs, they have direct connectivity to other cluster pods and resources in the VNet. The solution supports large clusters within the configured VNet IP address limits without any degradation in performance.
- **Separate VNet policies for pods**: Since pods have a separate subnet, you can configure separate VNet policies for them that are different from node policies. This configuration enables many useful scenarios such as allowing internet connectivity only for pods and not for nodes, fixing the source IP for a pod in a node pool by using an Azure NAT Gateway, and using network security groups (NSGs) to filter traffic between node pools.
- **Kubernetes network policies**: For Linux node pools, use Azure CNI Powered by Cilium. For Windows node pools, use Calico. Azure Network Policy Manager (NPM) support ends on September 30, 2026, for Windows nodes and September 30, 2028, for Linux nodes. New subscriptions can no longer enable Azure NPM. For more information, see [Network policy options in AKS](use-network-policies#network-policy-options-in-aks).

This article shows you how to use Azure CNI Pod Subnet - Dynamic IP Allocation and enhanced subnet support in AKS.

## Prerequisites

- Review the [prerequisites](concepts-network-cni-overview#aks-cni-networking-prerequisites) for configuring basic Azure CNI networking in AKS, as the same prerequisites apply to this article.
- AKS Engine and DIY clusters aren't supported.
- Azure CLI version `2.37.0` or later.
- Unless you use a network isolated cluster, the virtual network must allow outbound connectivity to the required AKS endpoints.
- If you use a virtual network that you manage, the cluster identity must have Network Contributor permissions on the node and pod subnets. The node subnet can't be delegated.
- If you have an existing cluster, you need to enable Container Insights for monitoring IP subnet usage. You can enable Container Insights by using the [`az aks enable-addons`](/en-us/cli/azure/aks#az-aks-enable-addons) command, as shown in the following example:

    ```azurecli
    RESOURCE_GROUP_NAME="<resource-group-name>"
    CLUSTER_NAME="<cluster-name>"
    
    az aks enable-addons --addons monitoring --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME
    ```

## Limitations

- Dynamic IP allocation supports pod subnets up to `/16`. Large clusters can also be limited to approximately 65,000 pods due to the Azure address-mapping limit. To scale beyond these limits, use [Azure CNI pod subnet - Static block allocation](configure-azure-cni-static-block-allocation).
- [Node auto-provisioning (NAP) doesn't support Azure CNI pod subnet with dynamic IP allocation](node-auto-provisioning-networking#supported-networking-configurations-for-nap).

## Plan IP addressing

Planning your IP addressing is much simpler with this feature. Since the nodes and pods scale independently, their address spaces can also be planned separately. Since pod subnets can be configured to the granularity of a node pool, you can always add a new subnet when you add a node pool. The system pods in a cluster/node pool also receive IPs from the pod subnet, so this behavior needs to be accounted for.

IPs are allocated to nodes in batches of 16. Nodes request 16 IPs on startup and request another batch of 16 when fewer than eight IPs remain unallocated in their allotment. When you size the pod subnet, account for the maximum pods per node, the maximum number of nodes, upgrade surge nodes, and expected scaling. Also include extra capacity for the delay between deleting a pod and releasing its IP address. For more information, see [Upgrading and scaling considerations](concepts-network-ip-address-planning#upgrading-and-scaling-considerations).

If your workloads repeatedly create and delete many short-lived pods, such as CronJobs that run every minute or every few minutes, some pods might wait for an IP address before they start. For more information, see [Pod startup for workloads with high pod churn](concepts-network-azure-cni-pod-subnet#pod-startup-for-workloads-with-high-pod-churn).

The planning of IPs for Kubernetes services and Docker bridge remain unchanged.

To view and verify the NodeNetworkConfiguration (NNC) resources responsible for these IP allocations, you can run the following command:

```bash
kubectl get nodenetworkconfigs -n kube-system -o wide
```

## Maximum pods per node in a cluster with Pod Subnet - Dynamic IP Allocation and enhanced subnet support

The pods per node value when using Azure CNI Pod Subnet - Dynamic IP Allocation is slightly different from the traditional CNI behavior:

| CNI | Default | Configurable at deployment |
| --- | --- | --- |
| Traditional Azure CNI | 30 | Yes (up to 250) |
| Azure CNI Pod Subnet - Dynamic IP Allocation | 110 | Yes (up to 250) |

You can configure `--max-pods` when you create a cluster or add a node pool, up to the AKS maximum of 250. For minimum values and other requirements, see [Maximum pods per node](concepts-network-ip-address-planning#maximum-pods-per-node).

## Deployment parameters

Use `--network-plugin azure` to enable Azure CNI. The `--node-count` parameter sets the initial number of nodes, and `--max-pods` sets the maximum pods on each node. The following subnet parameters differ from basic Azure CNI networking:

- The **subnet** parameter refers to the node subnet, which hosts the AKS cluster nodes.
- Use an additional parameter **pod subnet** to specify the subnet whose IP addresses are dynamically allocated to pods.

## Configure dynamic IP allocation using Azure CLI

The following steps create a virtual network with separate node and pod subnets, then deploy an AKS cluster using Azure CNI Pod Subnet with Dynamic IP Allocation. Before you run the commands, verify that Azure CLI is using the subscription where you want to create the resources.

Create the virtual network with two subnets.

```azurecli
RESOURCE_GROUP_NAME="myResourceGroup"
VNET_NAME="myVirtualNetwork"
LOCATION="westcentralus"
SUBNET_NAME_1="nodesubnet"
SUBNET_NAME_2="podsubnet"

# Create the resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create our two subnet network 
az network vnet create --resource-group $RESOURCE_GROUP_NAME --location $LOCATION --name $VNET_NAME --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create --resource-group $RESOURCE_GROUP_NAME --vnet-name $VNET_NAME --name $SUBNET_NAME_1 --address-prefixes 10.240.0.0/16 -o none 
az network vnet subnet create --resource-group $RESOURCE_GROUP_NAME --vnet-name $VNET_NAME --name $SUBNET_NAME_2 --address-prefixes 10.241.0.0/16 -o none 
```

Create the cluster, referencing the node subnet using `--vnet-subnet-id` and the pod subnet using `--pod-subnet-id` and enabling the monitoring add-on.

```azurecli
CLUSTER_NAME="myAKSCluster"
SUBSCRIPTION=$(az account show --query id --output tsv)

az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --location $LOCATION \
    --max-pods 250 \
    --node-count 2 \
    --network-plugin azure \
    --vnet-subnet-id /subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$SUBNET_NAME_1 \
    --pod-subnet-id /subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$SUBNET_NAME_2 \
    --enable-addons monitoring \
    --generate-ssh-keys
```

### Adding node pool

When adding node pool, reference the node subnet using `--vnet-subnet-id` and the pod subnet using `--pod-subnet-id`. The following example creates two new subnets that are then referenced in the creation of a new node pool:

```azurecli
SUBNET_NAME_3="node2subnet"
SUBNET_NAME_4="pod2subnet"
NODE_POOL_NAME="mynodepool"

az network vnet subnet create --resource-group $RESOURCE_GROUP_NAME --vnet-name $VNET_NAME --name $SUBNET_NAME_3 --address-prefixes 10.242.0.0/16 -o none 
az network vnet subnet create --resource-group $RESOURCE_GROUP_NAME --vnet-name $VNET_NAME --name $SUBNET_NAME_4 --address-prefixes 10.243.0.0/16 -o none 

az aks nodepool add --cluster-name $CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME --name $NODE_POOL_NAME \
    --max-pods 250 \
    --node-count 2 \
    --vnet-subnet-id /subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$SUBNET_NAME_3 \
    --pod-subnet-id /subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$SUBNET_NAME_4 \
    --no-wait
```

## Monitor IP subnet usage

Azure CNI provides the capability to monitor IP subnet usage. Use the following procedure to enable monitoring and view the collected metrics:

1. Download the **container-azm-ms-agentconfig.yaml** file from [GitHub](https://raw.githubusercontent.com/microsoft/Docker-Provider/ci_prod/kubernetes/container-azm-ms-agentconfig.yaml).
2. In the `integrations` section, find `azure_subnet_ip_usage` and set `enabled` to `true`. Setting `enabled = true` under `azure_subnet_ip_usage` activates IP subnet usage monitoring.
3. Save the file.
4. Run the following commands to set your active subscription and download the cluster credentials to your local kubeconfig file:

    ```azurecli
    az account set --subscription $SUBSCRIPTION
    az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP_NAME
    ```
5. Open a terminal in the folder where you saved **container-azm-ms-agentconfig.yaml**.
6. Apply the config by using the [`kubectl apply`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_apply/)`-f container-azm-ms-agentconfig.yaml` command. This command restarts the pod, and after 5-10 minutes, you can see the metrics.
7. View the metrics on the cluster by navigating to Workbooks on the cluster page in the Azure portal, and find the workbook named *Subnet IP Usage*.

## Dynamic IP allocation FAQs

### Can I assign multiple pod subnets to a cluster or node pool?

You can assign multiple pod subnets to a cluster, but you can assign only one pod subnet to each node pool. Multiple clusters or node pools can share a pod subnet.

### Can I assign pod subnets from a different virtual network?

No, you must use pod subnets from the same virtual network as the cluster.

### Can some node pools in a cluster use the traditional CNI while others use the new CNI?

The entire cluster should use only one type of CNI.