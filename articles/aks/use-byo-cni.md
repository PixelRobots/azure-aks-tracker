---
layout: Conceptual
title: Bring Your Own Container Network Interface (CNI) Plugin with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-byo-cni
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
description: Learn how to bring your own Container Network Interface (CNI) plugin with Azure Kubernetes Service (AKS).
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2026-04-16T00:00:00.0000000Z
ai-usage: ai-assisted
locale: en-us
document_id: 9eeb80d7-ff5d-6032-fff9-93ba675dc19e
document_version_independent_id: 55a64224-e16b-4378-0b9b-1f0f8669baeb
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-byo-cni.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-byo-cni
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-byo-cni.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 7a9e84da-2a26-6baa-1fb0-ff2bf90243ea
---

# Bring Your Own Container Network Interface (CNI) Plugin with Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

Kubernetes doesn't provide a network interface system by default. Instead, [network plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/) provide this functionality. Azure Kubernetes Service (AKS) provides several supported Container Network Interface (CNI) plugins. For information on supported plugins, see [Networking concepts for applications in Azure Kubernetes Service](concepts-network).

The supported plugins meet most networking needs in Kubernetes. However, advanced AKS users might want the same CNI plugin that they used in on-premises Kubernetes environments. Or these users might want to use advanced functionalities available in other CNI plugins.

This article shows how to deploy an AKS cluster with no CNI plugin preinstalled. From there, you can install any CNI plugin that works in Azure.

## Support

Microsoft support can't assist with CNI-related issues in clusters that you deploy by bringing your own CNI plugin. For example, CNI-related issues would cover most east/west (pod to pod) traffic, along with `kubectl proxy` and similar commands. If you want CNI-related support, use a supported AKS network plugin or seek support from the CNI plugin vendor.

Microsoft still provides support for issues that aren't related to CNI.

## IP address planning considerations

When using a Bring Your Own CNI (BYO CNI) plugin with AKS, IP address planning responsibilities are split between AKS and the customer-managed CNI. Unlike AKS-managed CNI plugins, AKS doesn't allocate or manage pod IP addresses when a BYO CNI is used.

Note

The [IP address planning for your Azure Kubernetes Service (AKS) clusters](concepts-network-ip-address-planning) article focuses on AKS-managed networking plugins. In BYO CNI scenarios, only guidance related to node subnet sizing, upgrade and scaling behavior, and Kubernetes service address ranges is applicable. Pod IP address allocation, routing, and scaling behavior are determined by the selected CNI plugin.

### Virtual network and subnet sizing

AKS still requires a virtual network and subnet to host cluster nodes. Subnet sizing should account for:

- The maximum number of nodes per node pool
- Additional nodes required for upgrade and scale operations, such as surge upgrades
- Azure resources that allocate IP addresses from subnets in the virtual network, such as internal load balancers

AKS upgrades and scaling operations remain node-based. During these operations, AKS might temporarily provision additional nodes, so the subnet must be large enough to accommodate the maximum node count.

> 
> Pod IP addresses are not allocated from the AKS subnet when using BYO CNI unless explicitly implemented by the CNI plugin.

### Kubernetes service address range

All AKS clusters, including those using BYO CNI, require a Kubernetes service address range (`serviceCIDR`) and a DNS service IP address (`dnsServiceIP`). The following constraints apply:

- The service address range must not overlap with the virtual network or any connected network.
- The service CIDR must be smaller than /12.
- The DNS service IP must be within the service CIDR range and must not be the first IP address in the range.

These requirements are independent of the CNI plugin.

Note

Starting with Kubernetes 1.33, you can extend the service IP range after cluster creation using the `ServiceCIDR` Kubernetes resource. For more information, see [Extend Service IP Ranges](https://kubernetes.io/docs/tasks/network/extend-service-ip-ranges/) in the Kubernetes documentation.

### Pod networking and IP management

With BYO CNI, pod IP address management (IPAM), routing, and scaling behavior are determined by the CNI plugin.

AKS doesn't:

- Allocate pod IP addresses
- Preassign per-node pod CIDR ranges
- Enforce pod IP reuse or release behavior

Guidance related to overlay or flat networking models, per-node pod CIDR sizing, or subnet sizing formulas that include pod counts doesn't apply to BYO CNI scenarios.

### Maximum pods per node

AKS enforces a configurable maximum number of pods per node (`maxPods`) at the kubelet level. When using BYO CNI, this setting limits pod scheduling density but doesn't determine IP capacity. You're responsible for ensuring that the selected CNI plugin can support the configured pod density and cluster scale.

## Prerequisites

- For Azure Resource Manager or Bicep, use at least template version 2022-01-02-preview or 2022-06-01.
- For the Azure CLI, use at least version 2.39.0.
- The virtual network for the AKS cluster must allow outbound internet connectivity.
- AKS clusters can't use `169.254.0.0/16`, `172.30.0.0/16`, `172.31.0.0/16`, or `192.0.2.0/24` for the address range for the Kubernetes service, pods, or cluster virtual network.
- The cluster identity that the AKS cluster uses must have at least [Network Contributor](/en-us/azure/role-based-access-control/built-in-roles#network-contributor) permissions on the subnet within your virtual network. If you want to define a [custom role](/en-us/azure/role-based-access-control/custom-roles)instead of using the built-in Network Contributor role, the following permissions are required:
    - `Microsoft.Network/virtualNetworks/subnets/join/action`
    - `Microsoft.Network/virtualNetworks/subnets/read`
- The subnet assigned to the AKS node pool can't be a [delegated subnet](/en-us/azure/virtual-network/subnet-delegation-overview).
- AKS doesn't apply network security groups (NSGs) to its subnet or modify any of the NSGs associated with that subnet. If you provide your own subnet and add NSGs associated with that subnet, you must ensure that the security rules in the NSGs allow traffic within the node's Classless Inter-Domain Routing (CIDR) range. For more information, see [Network security groups](concepts-network#network-security-groups).
- AKS doesn't create a route table in the managed virtual network.
- You must specify a Pod CIDR (IP address range for pods). The AKS control plane uses this range for internal traffic routing to pods, even though pod IP assignment will be managed by your custom CNI. If no pod CIDR is provided, control plane to pod communication might fail or be misrouted. You must select a pod CIDR that doesn't conflict with any other network in your environment and avoids Azure reserved ranges, such as, `169.254.0.0/16`, `172.30.0.0/16`, `172.31.0.0/16`, or `192.0.2.0/24`. For example, you might use a range such as `10.XX.0.0/16` that's unique to your cluster. This ensures that the control plane can route directly to pod IPs on your nodes, and no IP overlap occurs if you integrate with other networks or clusters.

## Create an AKS cluster with no CNI plugin preinstalled

# [Azure CLI](#tab/azure-cli)
1. Create an Azure resource group for your AKS cluster by using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

    ```azurecli
    az group create --location eastus --name myResourceGroup
    ```
2. Create an AKS cluster by using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. Pass the `--network-plugin` parameter with the parameter value of `none`.

    ```azurecli
    az aks create \
        --location eastus \
        --resource-group myResourceGroup \
        --name myAKSCluster \
        --network-plugin none \
        --pod-cidr "10.10.0.0/16" \
        --generate-ssh-keys
    ```

# [Azure Resource Manager](#tab/azure-resource-manager)
For information on how to deploy the following template, see the [ARM template documentation](/en-us/azure/azure-resource-manager/templates/deploy-cli).

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "clusterName": {
      "type": "string",
      "defaultValue": "aksbyocni"
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]"
    },
    "kubernetesVersion": {
      "type": "string",
      "defaultValue": "1.22"
    },
    "nodeCount": {
      "type": "int",
      "defaultValue": 3
    },
    "nodeSize": {
      "type": "string",
      "defaultValue": "Standard_B2ms"
    }
  },
  "resources": [
    {
      "type": "Microsoft.ContainerService/managedClusters",
      "apiVersion": "2022-06-01",
      "name": "[parameters('clusterName')]",
      "location": "[parameters('location')]",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "agentPoolProfiles": [
          {
            "name": "nodepool1",
            "count": "[parameters('nodeCount')]",
            "mode": "System",
            "vmSize": "[parameters('nodeSize')]"
          }
        ],
        "dnsPrefix": "[parameters('clusterName')]",
        "kubernetesVersion": "[parameters('kubernetesVersion')]",
        "networkProfile": {
          "networkPlugin": "none",
          "podCidr": "[parameters('pod-cidr')]"
        }
      }
    }
  ]
}
```

# [Bicep](#tab/bicep)
For information on how to deploy the following template, see the [Bicep template documentation](/en-us/azure/azure-resource-manager/bicep/deploy-cli).

```bicep
param clusterName string = 'aksbyocni'
param location string = resourceGroup().location
param kubernetesVersion string = '1.22'
param nodeCount int = 3
param nodeSize string = 'Standard_B2ms'
param podCidr string = '10.2.0.0/16'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-06-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: nodeCount
        mode: 'System'
        vmSize: nodeSize
      }
    ]
    dnsPrefix: clusterName
    kubernetesVersion: kubernetesVersion
    networkProfile: {
      networkPlugin: 'none'
      podCidr: podCidr
    }
  }
}
```

---

## Deploy a CNI plugin

After AKS provisioning finishes, the cluster is online. But all the nodes are in a `NotReady` state, as shown in the following example:

```bash
  $ kubectl get nodes
  NAME                                STATUS     ROLES   AGE    VERSION
  aks-nodepool1-23902496-vmss000000   NotReady   agent   6m9s   v1.21.9

  $ kubectl get node -o custom-columns='NAME:.metadata.name,STATUS:.status.conditions[?(@.type=="Ready")].message'
  NAME                                STATUS
  aks-nodepool1-23902496-vmss000000   container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized
```

At this point, the cluster is ready for installation of a CNI plugin.