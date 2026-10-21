---
layout: Conceptual
title: Use labels in an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/use-labels
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
description: Learn how to use labels in an Azure Kubernetes Service (AKS) cluster.
author: rayoef
ms.author: rayoflores
ms.topic: how-to
ms.date: 2024-06-10T00:00:00.0000000Z
ms.custom: innovation-engine, devx-track-azurecli, linux-related-content, kubernetes, aks
locale: en-us
document_id: 7f90cda7-730c-16e8-91c6-2e8a5a63a61b
document_version_independent_id: 00348be9-7f2b-55ab-ae32-c0b48a6f4fdc
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/use-labels.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/use-labels
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/use-labels.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: ece6f7a5-582a-47bd-3de4-4894fd68c0a3
---

# Use labels in an Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

If you have multiple node pools, you may want to add a label during node pool creation. [Kubernetes labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) handle the scheduling rules for nodes. You can add labels to a node pool anytime and apply them to all nodes in the node pool.

In this how-to guide, you learn how to use labels in an Azure Kubernetes Service (AKS) cluster.

## Prerequisites

You need the Azure CLI version 2.2.0 or later installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

## Create an AKS cluster with a label

You can create an AKS cluster with node labels to set key/value metadata for workload scheduling.

```bash
export RANDOM_SUFFIX=$(openssl rand -hex 3)
export RESOURCE_GROUP="myResourceGroup$RANDOM_SUFFIX"
export AKS_CLUSTER_NAME="myAKSCluster$RANDOM_SUFFIX"
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

Create the AKS cluster specifying node labels (e.g., dept=IT, costcenter=9000):

```azurecli
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --node-count 2 \
    --nodepool-labels dept=IT costcenter=9000 \
    --generate-ssh-keys --location $REGION
```

Results:

```output
{
  "aadProfile": null,
  "addonProfiles": {},
  "agentPoolProfiles": [
    {
      "count": 2,
      "enableAutoScaling": null,
      "mode": "System",
      "name": "nodepool1",
      "nodeLabels": {
        "costcenter": "9000",
        "dept": "IT"
      }
    }
  ],
  "dnsPrefix": "myaksclusterxxx-dns",
  "fqdn": "myaksclusterxxx-xxxxxxxx.hcp.eastus2.azmk8s.io",
  "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroupxxx/providers/Microsoft.ContainerService/managedClusters/myAKSClusterxxx",
  "location": "eastus2",
  "name": "myAKSClusterxxx",
  "resourceGroup": "myResourceGroupxxx"
}
```

Verify the labels were set:

```bash
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --overwrite-existing
kubectl get nodes --show-labels | grep -e "costcenter=9000" -e "dept=IT"
```

## Create a node pool with a label

You can create an additional node pool with labels for specific scheduling needs.

```bash
export NODEPOOL_NAME="labelnp"
az aks nodepool add \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $AKS_CLUSTER_NAME \
    --name $NODEPOOL_NAME \
    --node-count 1 \
    --labels dept=HR costcenter=5000
```

The following is example output from the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command showing the *labelnp* node pool is *Creating* nodes with the specified *nodeLabels*:

```bash
az aks nodepool list --resource-group $RESOURCE_GROUP --cluster-name $AKS_CLUSTER_NAME
```

Results:

```output
[
  {
    "count": 2,
    "name": "nodepool1",
    "nodeLabels": {
      "costcenter": "9000",
      "dept": "IT"
    }
  },
  {
    "count": 1,
    "name": "labelnp",
    "nodeLabels": {
      "costcenter": "5000",
      "dept": "HR"
    },
    "provisioningState": "Creating"
  }
]
```

Verify the labels were set:

```bash
kubectl get nodes --show-labels | grep -e "costcenter=5000" -e "dept=HR"
```

## Updating labels on existing node pools

You can update the labels on an existing node pool. Note that updating labels will overwrite the old labels.

```bash
az aks nodepool update \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $AKS_CLUSTER_NAME \
    --name $NODEPOOL_NAME \
    --labels dept=ACCT costcenter=6000
```

Verify the new labels are set:

```bash
kubectl get nodes --show-labels | grep -e "costcenter=6000" -e "dept=ACCT"
```

## Unavailable labels

### Reserved system labels

Since the [2021-08-19 AKS release](https://github.com/Azure/AKS/releases/tag/2021-08-19), AKS stopped the ability to make changes to AKS reserved labels. Attempting to change these labels results in an error message.

The following labels are AKS reserved labels. *Virtual node usage* specifies if these labels could be a supported system feature on virtual nodes. Some properties that these system features change aren't available on the virtual nodes because they require modifying the host.

| Label | Value | Example/Options | Virtual node usage |
| --- | --- | --- | --- |
| `kubernetes.azure.com/agentpool` | &lt;agent pool name&gt; | `nodepool1` | Same |
| `kubernetes.io/arch` | &lt;runtime.GOARCH&gt; | `amd64       ` | N/A |
| `kubernetes.io/os` | &lt;OS Type&gt; | `Linux/Windows` | Same |
| `node.kubernetes.io/instance-type` | &lt;VM size&gt; | `Standard_NC6s_v3` | Virtual |
| `topology.kubernetes.io/region` | &lt;Azure region&gt; | `westus2` | Same |
| `topology.kubernetes.io/zone` | &lt;Azure zone&gt; | `0` | Same |
| `kubernetes.azure.com/cluster` | &lt;MC\_RgName&gt; | `MC_aks_myAKSCluster_westus2` | Same |
| `kubernetes.azure.com/managedby` | `aks` | `aks` | N/A |
| `kubernetes.azure.com/mode` | &lt;mode&gt; | `User` or `system` | User |
| `kubernetes.azure.com/role` | agent | `Agent` | Same |
| `kubernetes.azure.com/scalesetpriority` (deprecated) | &lt;VMSS priority&gt; | `spot` (`regular` is not written on regular nodes). Prefer `kubernetes.azure.com/priority` instead. | N/A |
| `kubernetes.azure.com/priority` | &lt;VM priority&gt; | `spot` or `regular` | N/A |
| `kubernetes.io/hostname` | &lt;hostname&gt; | `aks-nodepool-00000000-vmss000000` | Same |
| `kubernetes.azure.com/storageprofile` | &lt;OS disk storage profile&gt; | `Managed` | N/A |
| `kubernetes.azure.com/storagetier` | &lt;OS disk storage tier&gt; | `Premium_LRS` | N/A |
| `kubernetes.azure.com/node-image-version` | &lt;VHD version&gt; | `AKSUbuntu-1804-2020.03.05` | Virtual node version |
| `kubernetes.azure.com/network-name` | &lt;nodepool vnet name&gt; | `vnetName` | Virtual node virtual network |
| `kubernetes.azure.com/network-subnet` | &lt;nodepool subnet name&gt; | `subnetName` | Virtual node subnet name |
| `kubernetes.azure.com/ppg` | &lt;nodepool ppg name&gt; | `ppgName` | N/A |
| `kubernetes.azure.com/encrypted-set` | &lt;nodepool encrypted-set name&gt; | `encrypted-set-name` | N/A |
| `kubernetes.azure.com/accelerator` | &lt;accelerator&gt; | `nvidia` | N/A |
| `kubernetes.azure.com/fips_enabled` | &lt;is FIPS enabled?&gt; | `true` | N/A |
| `kubernetes.azure.com/os-sku` | &lt;os/sku&gt; | [Create or update OS SKU](/en-us/rest/api/aks/agent-pools/create-or-update#ossku) | Linux |
| `kubernetes.azure.com/os-sku-effective` | &lt;actual OS SKU chosen&gt; | `Ubuntu2204` or similar (never Ubuntu, always has the version specified) | N/A |
| `kubernetes.azure.com/os-sku-requested` | &lt;user requested OS SKU&gt; | `Ubuntu`, `Ubuntu2204`, or similar (exactly matches requested sku from API) | N/A |
| `kubernetes.azure.com/sku-cpu` | &lt;num cpus&gt; | `4` | Same |
| `kubernetes.azure.com/sku-memory` | &lt;memory in GB&gt; | `16` | Same |
| `kubernetes.azure.com/nodepool-type` | &lt;node pool type&gt; | `VirtualMachineScaleSets` | N/A |

- *Same* is included in places where the expected values for the labels don't differ between a standard node pool and a virtual node pool. As virtual node pods don't expose any underlying virtual machine (VM), the VM SKU values are replaced with the SKU *Virtual*.
- *Virtual node version* refers to the current version of the [virtual Kubelet-ACI connector release](https://github.com/virtual-kubelet/azure-aci/releases).
- *Virtual node subnet name* is the name of the subnet where virtual node pods are deployed into Azure Container Instance (ACI).
- *Virtual node virtual network* is the name of the virtual network, which contains the subnet where virtual node pods are deployed on ACI.
- *Node Auto Provisioning (Karpenter)* nodes have additional labels corresponding to the supported [selectors](/en-us/azure/aks/node-auto-provisioning-node-pools#well-known-labels-and-sku-selectors).
- `kubernetes.azure.com/network-name` and `kubernetes.azure.com/network-subnet` will be truncated if the underlying resource names are greater than 64 characters long.

### Reserved prefixes

The following prefixes are AKS reserved prefixes and can't be used for any node:

- kubernetes.azure.com/
- kubernetes.io/

For more information on reserved prefixes, see [Kubernetes well-known labels, annotations, and taints](https://kubernetes.io/docs/reference/labels-annotations-taints/).

### Deprecated labels

The following labels are planned for deprecation with the release of [Kubernetes v1.24](supported-kubernetes-versions#aks-kubernetes-release-calendar-and-upcoming-versions). You should change any label references to the recommended substitute.

| Label | Recommended substitute | Maintainer |
| --- | --- | --- |
| failure-domain.beta.kubernetes.io/region | topology.kubernetes.io/region | [Kubernetes](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| failure-domain.beta.kubernetes.io/zone | topology.kubernetes.io/zone | [Kubernetes](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| beta.kubernetes.io/arch | kubernetes.io/arch | [Kubernetes](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| beta.kubernetes.io/instance-type | node.kubernetes.io/instance-type | [Kubernetes](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| beta.kubernetes.io/os | kubernetes.io/os | [Kubernetes](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) |
| node-role.kubernetes.io/agent\* | kubernetes.azure.com/role=agent | Azure Kubernetes Service |
| kubernetes.io/role\* | kubernetes.azure.com/role=agent | Azure Kubernetes Service |
| Agentpool\* | kubernetes.azure.com/agentpool | Azure Kubernetes Service |
| Storageprofile\* | kubernetes.azure.com/storageprofile | Azure Kubernetes Service |
| Storagetier\* | kubernetes.azure.com/storagetier | Azure Kubernetes Service |
| Accelerator\* | kubernetes.azure.com/accelerator | Azure Kubernetes Service |

\*Newly deprecated. For more information, see the [Release Notes](https://github.com/Azure/AKS/releases).