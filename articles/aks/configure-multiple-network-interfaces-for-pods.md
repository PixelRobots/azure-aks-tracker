---
layout: Conceptual
title: Configure Multi-NIC Pods using AKS Supported DRANET (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-multiple-network-interfaces-for-pods
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
description: Learn how to create an AKS cluster with a multi-NIC node pool for workloads that use AKS managed DRAnet.
author: JosephYostos
ms.author: josephyostos
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2026-07-22T00:00:00.0000000Z
ms.custom: devx-track-azurecli
ai-usage: ai-assisted
locale: en-us
document_id: 2822f9b1-2555-2839-ed82-f45f13554417
document_version_independent_id: 0945ed60-db59-a1dc-f13c-4cd128de3613
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-multiple-network-interfaces-for-pods.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/configure-multiple-network-interfaces-for-pods
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-multiple-network-interfaces-for-pods.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 05d2013b-63ce-e652-7efc-1de438739037
---

# Configure Multi-NIC Pods using AKS Supported DRANET (Preview) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to create an Azure Kubernetes Service (AKS) cluster with a node pool that has secondary network interfaces attached to every node.

For an overview of the feature, its architecture, and current limitations, see [Multi-NIC Pods in Azure Kubernetes Service (AKS) (Preview)](multiple-network-interfaces-for-pods-overview).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Prerequisites

- Kubernetes version **1.35 or later**.
- A VM size that supports the total number of NICs you need: one primary NIC plus one NIC for each entry in `secondaryNetworkInterfaces`.
- All interfaces must be attached to the same virtual network as the primary NIC. On a bring-your-own VNet cluster, different subnets within that VNet are supported, but different VNets aren't supported in this preview. On an AKS-managed VNet, secondary interfaces are currently limited to the same subnet as the primary NIC, since creating a new subnet on a managed VNet isn't supported yet.
- Plan for exclusive assignment. Each secondary NIC can be assigned to only one pod at a time.

### Install the `aks-preview` Azure CLI extension

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Install or update the Azure CLI preview extension by using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) or [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

```azurecli
# Install the aks-preview extension
az extension add --name aks-preview
# Update the extension to make sure you have the latest version installed
az extension update --name aks-preview
```

## Register the preview feature

Register the `NetworkingMultiNICPreview` feature.

```azurecli
az feature register \--namespace Microsoft.ContainerService \--name NetworkingMultiNICPreview
```

Verify that the feature registration state is `Registered`.

```azurecli
az feature show \--namespace Microsoft.ContainerService \--name NetworkingMultiNICPreview \--query properties.state \--output tsv
```

Refresh the `Microsoft.ContainerService` resource provider.

```azurecli
az provider register --namespace Microsoft.ContainerService
```

## Create virtual network and subnets

1. Set the environment variables that you use throughout this article. Ensure you replace the placeholders with your own values.

```azurecli
export LOCATION="<aks-region>"
export RESOURCE_GROUP="<resourcegroup-name>"
export CLUSTER_NAME="<aks-cluster-name>"
export VNET="<vnet-name>"
export PRIMARY_SUBNET="<primary-subnet-name>" //should contain only alphanumeric characters
export SECONDARY_SUBNET="<secondary-subnet-name>" //should contain only alphanumeric characters
export MULTINIC_NODEPOOL="<multinic-nodepool-name>"
export NODE_VM_SIZE="Standard_D8s_v5"
```

1. Create a virtual network and primary subnet.

```azurecli
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET \
  --location $LOCATION \
  --address-prefixes 192.168.0.0/16 \
  --subnet-name $PRIMARY_SUBNET \
  --subnet-prefixes 192.168.0.0/24 
```

1. Create a secondary subnet in the same virtual network.

```azurecli
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET \
  --name $SECONDARY_SUBNET \
  --address-prefixes 192.168.1.0/24
```

1. Save primary and secondary subnet IDs.

```azurecli
PRIMARY_SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VNET --name $PRIMARY_SUBNET --query id -o tsv)
SECONDARY_SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VNET --name $SECONDARY_SUBNET --query id -o tsv)
```

## Create the AKS cluster

1. Create the base AKS cluster first. This base cluster and node pool have only one network interface connected to the primary subnet.

```azurecli
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --location $LOCATION \
    --vnet-subnet-id $PRIMARY_SUBNET_ID \
    --network-plugin azure \
    --network-dataplane cilium \
    --node-count 1 \
    --generate-ssh-keys
```

## Add a multi-NIC node pool

Choose a VM size that supports at least two NICs. In this example, you use `Standard_D8s_v5` that comes with four NICs. Check the number of NICs by using the following command:

```azurecli
az vm list-skus \
    --location eastus \
    --resource-type virtualMachines \
    --all \
    --query "[?name=='Standard_D8s_v5'].{
        SKU:name,
        MaxNICs:capabilities[?name=='MaxNetworkInterfaces']|[0].value,
        AcceleratedNetworking:capabilities[?name=='AcceleratedNetworkingEnabled']|[0].value
    }" \
    -o table
```

1. Create a secondary NIC configuration file.

Create a JSON file that defines the secondary network interfaces to attach to each node. In this example, two secondary NICs are configured to use the same subnet.

```bash
[
  {
    "type": "Standard",
    "vnetSubnetId": "<SECONDARY_SUBNET_ID>"
  },
  {
    "type": "Standard",
    "vnetSubnetId": "<SECONDARY_SUBNET_ID>"
  },
]
```

Note

Each object in the array represents one secondary NIC. The preceding example configures two secondary NICs per node, both connected to the same subnet. Replace `<SECONDARY_SUBNET_ID>` with the full resource ID of the target subnet before creating the node pool.

1. Create a node pool using the configuration file Use the `az aks nodepool add` command and reference the JSON file by using the `@` syntax:

```azurecli
az aks nodepool add \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $MULTINIC_NODEPOOL \
  --node-vm-size $NODE_VM_SIZE\
  --secondary-network-interfaces @secondary-nics.json
```

Alternatively, pass the secondary network interface configuration directly to the `az` command as an inline JSON array:

```azurecli
az aks nodepool add \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $MULTINIC_NODEPOOL \
  --node-count 2 \
  --node-vm-size $NODE_VM_SIZE\
  --secondary-network-interfaces \
  "[{\"type\":\"Standard\",\"vnetSubnetId\":\"$SECONDARY_SUBNET_ID\"},
  {\"type\":\"Standard\",\"vnetSubnetId\":\"$SECONDARY_SUBNET_ID\"}]"
```

Note

The secondary NIC configuration is immutable after the node pool is created. To change the secondary NIC list later, create a new node pool and move your workloads to it.

## Validate the node pool configuration

1. Get the cluster credentials.

    ```azurecli
     az aks get-credentials \
     	--resource-group $RESOURCE_GROUP \
     	--name $CLUSTER_NAME
    ```
2. Verify that the multi-NIC node pool exists.

    ```azurecli
     az aks nodepool show \
     	--resource-group $RESOURCE_GROUP \
     	--cluster-name $CLUSTER_NAME \
     	--name $MULTINIC_NODEPOOL \
     	--query "{name:name,vmSize:vmSize,vnetSubnetID:vnetSubnetID,secondaryNetworkInterfaces:networkProfile.secondaryNetworkInterfaces}" \
     	--output json
    ```
3. Confirm that Kubernetes reports the nodes in the new node pool.

    ```azurecli
     kubectl get nodes -L agentpool
    ```

## Request secondary NIC resources through the DRAnet driver

When you configure secondary NICs on the node pool, AKS deploys the DRAnet driver. Then, you can request secondary NIC resources by using Dynamic Resource Allocation (DRA).

### 1. Validate that DeviceClass is deployed

A `DeviceClass` defines a category of devices that workloads can claim through DRA. The DRAnet driver (or your cluster admin) publishes one or more device classes for secondary NIC resources.

List the available device classes:

```azurecli
kubectl get deviceclasses
```

Inspect a device class to see selectors and configuration:

```azurecli
kubectl describe deviceclass standard-secondary-nic
```

### 2. Validate that the DRAnet driver is deployed as a DaemonSet

The DRAnet driver must run on every node that serves multi-NIC workloads. Validate that the DRAnet DaemonSet exists and that its pods are ready.

```azurecli
kubectl get daemonset -A
kubectl get pods -A -o wide
```

In the output, verify that the DRAnet DaemonSet and its pods are in a ready state.

### 3. Create a ResourceClaimTemplate

A `ResourceClaimTemplate` defines how each pod requests a device. Kubernetes creates a per-pod `ResourceClaim` from this template at scheduling time.

Create a file named `secondary-nic-claim-template.yaml`:

```yaml
apiVersion: resource.k8s.io/v1
kind: ResourceClaimTemplate
metadata:
  name: secondary-nic-claim-template
spec:
  spec:
    devices:
      requests:
      - name: secondary-nic
        exactly:
          count: 1
          allocationMode: ExactCount
          deviceClassName: standard-secondary-nic
```

Replace `<device-class-name>` with the value you checked in the previous step, and then apply the template.

```azurecli
kubectl apply -f secondary-nic-claim-template.yaml
kubectl get resourceclaimtemplate secondary-nic-claim-template
```

### 4. Deploy a test pod

Deploy a test pod that references the `ResourceClaimTemplate` and requests the claim in the container.

Create a file named `secondary-nic-test-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secondary-nic-test-pod
spec:
  resourceClaims:
  - name: secondary-nic-claim
    resourceClaimTemplateName: secondary-nic-claim-template
  containers:
  - name: multinic-container
    image: nicolaka/netshoot
    command: ["sh", "-c", "ip a; sleep 3600"]
    resources:
      claims:
      - name: secondary-nic-claim
```

Apply the pod and check scheduling.

```azurecli
kubectl apply -f secondary-nic-test-pod.yaml
kubectl get pod secondary-nic-test-pod
kubectl exec -it secondary-nic-test-pod -- ip add
kubectl get resourceclaims
```

When the pod is running, Kubernetes successfully allocated a secondary NIC resource through DRAnet for that workload.