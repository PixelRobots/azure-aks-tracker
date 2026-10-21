---
layout: Conceptual
title: Create Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/create-node-pools
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
description: Learn how to create multiple node pools for a cluster in Azure Kubernetes Service (AKS).
ms.topic: how-to
ms.custom: devx-track-azurecli, build-2023, linux-related-content, annual
ms.date: 2026-07-13T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-nodes
zone_pivot_groups: azure-cli-or-arm
locale: en-us
document_id: c449dee9-ae35-2eb5-45a9-f68f9c70b873
document_version_independent_id: 97a712f3-153f-b107-74cf-dbfa882acf26
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/create-node-pools.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/create-node-pools
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/create-node-pools.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 06b115c0-8712-fd0d-43ec-5cf3fd5a2ad9
---

# Create Node Pools in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article shows you how to create one or more node pools in an AKS cluster.

Note

This feature enables more control over creating and managing multiple node pools and requires separate commands for *create/update/delete* (CRUD) operations. Previously, cluster operations through [`az aks create`](/en-us/cli/azure/aks#az-aks-create) or [`az aks update`](/en-us/cli/azure/aks#az-aks-update) used the managedCluster API and were the only options to change your control plane and a single node pool. This feature exposes a separate operation set for agent pools through the agentPool API and requires use of the [`az aks nodepool`](/en-us/cli/azure/aks/nodepool) command set to execute operations on an individual node pool.

Important

Starting on **December 10, 2026**, Azure Kubernetes Service (AKS) no longer supports Azure Linux with OS Guard for AKS (preview). At that point, AKS no longer produces new Azure Linux with OS Guard node images or provides security patches, and you can no longer create new node pools with Azure Linux with OS Guard. On **March 10, 2027**, AKS removes all existing Azure Linux with OS Guard node images, which causes scaling and remediation (reimage and redeploy) operations to fail. To avoid disruption, migrate to [Azure Container Linux (ACL)](azure-container-linux-overview). For more information about this retirement, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/5950) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates/?id=571257). To stay informed about announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

Important

Starting on **November 30, 2025**, Azure Kubernetes Service (AKS) no longer supports or provides security updates for Azure Linux 2.0. The Azure Linux 2.0 node image is frozen at the `202512.06.0` release. Beginning on **October 31, 2026**, node images will be removed, and you'll be unable to scale your node pools. Migrate to a supported Azure Linux version by [upgrading your node pools](/en-us/azure/aks/upgrade-aks-cluster) to a supported Kubernetes version or migrating to [osSku AzureLinux3](/en-us/azure/aks/upgrade-os-version). For more information, see the [Retirement GitHub issue](https://github.com/Azure/AKS/issues/4988) and the [Azure Updates retirement announcement](https://azure.microsoft.com/updates?id=500645). To stay informed on announcements and updates, follow the [AKS release notes](https://github.com/Azure/AKS/releases).

## Prerequisites

::: zone pivot="azure-cli"

- You need Azure CLI version 2.87.0 or later installed and configured. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).

::: zone-end

::: zone pivot="arm"

- To deploy an ARM template, you need write access on the resources you're deploying and access to all operations on the `Microsoft.Resources/deployments` resource type. For example, to deploy a virtual machine (VM), you need `Microsoft.Compute/virtualMachines/write` and `Microsoft.Resources/deployments/*` permissions. For a list of roles and permissions, see [Azure built-in roles](/en-us/azure/role-based-access-control/built-in-roles).
- Review the following requirements for each parameter:
    - `osType`: The operating system type. The default is Linux.
    - `osSKU`: Specifies the OS SKU used by the agent pool.
    - `count`: Number of agents (VMs) to host docker containers. Allowed values must be in the range of 0 to 1000 (inclusive) for user pools and in the range of 1 to 1000 (inclusive) for system pools. The default value is 1.
- After you deploy the cluster using an ARM template, you can use Azure CLI or Azure PowerShell to connect to the cluster and deploy the sample application.

::: zone-end

## Limitations

The following limitations apply when you create AKS clusters that support multiple node pools:

- You can delete the system node pool if you have another system node pool to take its place in the AKS cluster. Otherwise, you can't delete the system node pool.
- System pools must contain at least two nodes, and user node pools may contain zero or more nodes.
- **If you create a cluster with a single node pool, the OS type must be `Linux`**. The OS SKU can be any Linux variation such as `Ubuntu`, `AzureContainerLinux`, or `AzureLinux`. You can't create a cluster with a single Windows node pool. If you want to run Windows containers, you must add a Windows node pool to the cluster after creating it with a Linux system node pool.
- **You can't enable Windows support on a cluster that was created without it.** Adding a Windows node pool to a cluster requires the `windowsProfile` to be configured during the initial cluster creation (for example, by specifying `--windows-admin-username` and `--windows-admin-password` with the Azure CLI). If a cluster was created without these parameters, attempts to add a Windows node pool fail because the cluster doesn't have a Windows profile definition. To run Windows containers on an existing Linux-only cluster, you need to recreate the cluster with Windows support enabled. For more information, see the related [feature request](https://github.com/Azure/AKS/issues/4489) on GitHub.
- The AKS cluster must use the Standard SKU load balancer to use multiple node pools. This feature isn't supported with Basic SKU load balancers.
- The AKS cluster must use Virtual Machine Scale Sets for the nodes.
- The name of a node pool can only contain lowercase alphanumeric characters and must begin with a lowercase letter.

    - For Linux node pools, the length must be between 1-12 characters.
    - For Windows node pools, the length must be between 1-6 characters.
- All node pools must reside in the same virtual network.
- You can't change the virtual machine (VM) size of a node pool after you create it.
- You can't change the max pods setting of a node pool after you create it. To use a different max pods value, create a new node pool with the desired max pods setting, migrate workloads, and then delete the old node pool.
- When you create multiple node pools at cluster creation time, the Kubernetes versions for the node pools must match the version set for the control plane. You can make updates after provisioning the cluster using per node pool operations.

Important

If you're using **Azure Container Linux (ACL)** on AKS, make sure you review the following considerations and limitations:

- ACL is generally available starting AKS v1.34.
- ACL requires [Trusted Launch](/en-us/azure/aks/use-trusted-launch) with Secure Boot and vTPM. Non-Trusted Launch variants aren't available.
- ACL on Arm64 requires Cobalt-based (v6) SKUs to enable Trusted Launch compatibility.
- `NodeImage` and `None` are the only supported [operating system (OS) upgrade channels](/en-us/azure/aks/auto-upgrade-node-os-image). `Unmanaged` and `SecurityPatch` are incompatible with ACL due to the immutable `/usr` directory.
- [Artifact Streaming](/en-us/azure/aks/artifact-streaming) isn't supported.
- [Pod Sandboxing](/en-us/azure/aks/use-pod-sandboxing) isn't supported.
- [Confidential Virtual Machines (CVMs)](/en-us/azure/aks/confidential-containers-overview) aren't supported.
- [Generation 1 VMs](/en-us/azure/aks/aks-virtual-machine-sizes#vm-support-on-aks) aren't supported.

## Create specialized node pools

To learn how to create specialized node pools, see the following articles:

- [Add an Azure Spot node pool to an AKS cluster](spot-node-pool)
- [Add a Virtual Machines node pool to an AKS cluster](virtual-machines-node-pools)
- [Add a dedicated system node pool to an AKS cluster](use-system-pools#add-a-dedicated-system-node-pool-to-an-existing-aks-cluster)
- [Enabled Federal Information Processing Standards (FIPS) on an AKS node pool](enable-fips-nodes)
- [Add a node pool with a Confidential Virtual Machine (CVM) on an AKS cluster](use-cvm)
- [Create node pools with unique subnets in AKS](node-pool-unique-subnet)
- [Add a generation 2 VM node pool to an AKS cluster](generation-2-vms)
- [Add a node pool with Artifact Streaming to an AKS cluster](artifact-streaming)
- [Add Windows Server node pools with `containerd` to an AKS cluster](windows-containerd)

::: zone pivot="azure-cli"

## Set environment variables

Set the following environment variables in your shell to simplify the commands in this article. You can change the values to your preferred names.

```bash
export RESOURCE_GROUP_NAME="my-aks-rg"
export LOCATION="eastus"
export CLUSTER_NAME="my-aks-cluster"
export NODE_POOL_NAME="mynodepool"
```

## Create a resource group

Create an Azure resource group using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

```azurecli
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
```

## Create an AKS cluster with a single node pool using the Azure CLI

If you want only one node pool in your AKS cluster, you can schedule application pods on system node pools. If you run a single system node pool for your AKS cluster in a production environment, we recommend you use at least three nodes for the node pool. If one node goes down, the redundancy is compromised. You can mitigate this risk by having more system node pool nodes.

# [Single Ubuntu node pool](#tab/ubuntu)
1. Create a cluster with a single Ubuntu node pool using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. This step specifies two nodes in the single node pool.

    ```azurecli
    az aks create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $CLUSTER_NAME \
        --vm-set-type VirtualMachineScaleSets \
        --node-count 2 \
        --os-sku Ubuntu \
        --location $LOCATION \
        --load-balancer-sku standard \
        --generate-ssh-keys
    ```

    It takes a few minutes to create the cluster.
2. When the cluster is ready, get the cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME
    ```

# [Single Azure Linux node pool](#tab/azure-linux)
1. Create a cluster with a single Azure Linux node pool using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. This step specifies two nodes in the single node pool.

    For more information about Azure Linux, see [Azure Linux on AKS](use-azure-linux).

    ```azurecli
    az aks create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $CLUSTER_NAME \
        --vm-set-type VirtualMachineScaleSets \
        --node-count 2 \
        --os-sku AzureLinux \
        --location $LOCATION \
        --load-balancer-sku standard \
        --generate-ssh-keys
    ```

    It takes a few minutes to create the cluster.
2. When the cluster is ready, get the cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME
    ```

# [Single Azure Container Linux (ACL) for AKS node pool](#tab/acl)
1. Create a cluster with a single ACL node pool using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. The `--os-sku AzureContainerLinux` parameter configures the node pool to use ACL as the node OS. This step specifies two nodes in the single node pool.

    ```azurecli
    az aks create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $CLUSTER_NAME \
        --node-count 3 \
        --os-sku AzureContainerLinux \
        --location $LOCATION \
        --load-balancer-sku standard \
        --generate-ssh-keys
    ```

    It takes a few minutes to create the cluster.
2. When the cluster is ready, get the cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME
    ```

# [Single Azure Linux with OS Guard for AKS (preview) node pool](#tab/os-guard)
#### Install the `aks-preview` extension

1. Install the `aks-preview` Azure CLI extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    Important

    AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

    - [AKS support policies](/en-us/azure/aks/support-policies)
    - [Azure support FAQ](/en-us/azure/aks/faq)

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    az extension update --name aks-preview
    ```

#### Register the `AzureLinuxOSGuardPreview` feature flag

1. Register the `AzureLinuxOSGuardPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AzureLinuxOSGuardPreview"
    ```
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*.

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name AzureLinuxOSGuardPreview
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

#### Create the Azure Linux with OS Guard for AKS cluster

1. Create a cluster with a single Azure Linux with OS Guard for AKS (preview) node pool using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. This step specifies two nodes in the single node pool.

    ```azurecli
    az aks create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $CLUSTER_NAME \
        --vm-set-type VirtualMachineScaleSets \
        --node-count 2 \
        --os-sku AzureLinuxOSGuard \
        --node-osdisk-type Managed \
        --enable-fips-image \
        --enable-secure-boot \
        --enable-vtpm
        --location $LOCATION \
        --load-balancer-sku standard \
        --generate-ssh-keys
    ```

    It takes a few minutes to create the cluster.
2. When the cluster is ready, get the cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME
    ```

# [Single Flatcar Container Linux for AKS (preview) node pool](#tab/flatcar)
#### Install the `aks-preview` extension

1. Install the `aks-preview` Azure CLI extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    Important

    AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

    - [AKS support policies](/en-us/azure/aks/support-policies)
    - [Azure support FAQ](/en-us/azure/aks/faq)

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command. **Flatcar Container Linux requires a minimum of 18.0.0b42**.

    ```azurecli
    az extension update --name aks-preview
    ```

#### Register the `AKSFlatcarPreview` feature flag

1. Register the `AKSFlatcarPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AKSFlatcarPreview"
    ```
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*.

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name AKSFlatcarPreview
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

#### Create the Flatcar Container Linux for AKS cluster

1. Create a cluster with a single Flatcar Container Linux for AKS (preview) node pool using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command. This step specifies two nodes in the single node pool.

    ```azurecli
    az aks create \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $CLUSTER_NAME \
        --vm-set-type VirtualMachineScaleSets \
        --node-count 2 \
        --os-sku flatcar \
        --location $LOCATION \
        --load-balancer-sku standard \
        --generate-ssh-keys
    ```

    It takes a few minutes to create the cluster.
2. When the cluster is ready, get the cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

    ```azurecli
    az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $CLUSTER_NAME
    ```

---

## Add a second node pool using the Azure CLI

The cluster created in the previous section has a single node pool. In this section, we add a second node pool to the cluster. This second node pool can have an OS type of `Linux` with an OS SKU of `Ubuntu` or `AzureLinux`, or an OS type of `Windows`.

Note

If you want to add a node pool that uses **Ephemeral OS disks** to your AKS cluster, you can set the `--node-osdisk-type` flag to `Ephemeral` when running the `az aks nodepool add` command.

With Ephemeral OS, you can deploy VMs and instance images up to the size of the VM cache. The default node OS disk configuration in AKS uses 128 GB, which means that you need a VM size that has a cache larger than 128 GB. The default `Standard_DS2_v2` has a cache size of 86 GB, which isn't large enough. The `Standard_DS3_v2` VM SKU has a cache size of 172 GB, which is large enough. You can also reduce the default size of the OS disk using `--node-osdisk-size`, but keep in mind the minimum size for AKS images is 30 GB.

If you want to create node pools with **network-attached OS disks**, you can set the `--node-osdisk-type` flag to `Managed` when running the `az aks nodepool add` command.

### Add a Linux node pool

# [Add an Ubuntu node pool](#tab/ubuntu)
Create a new node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. The following example creates a `Linux` node pool with the `Ubuntu` OS SKU that runs *three* nodes. If you don't specify an OS SKU, AKS defaults to `Ubuntu`.

```azurecli
az aks nodepool add \
    --resource-group $RESOURCE_GROUP_NAME \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --node-vm-size Standard_DS2_v2 \
    --os-type Linux \
    --os-sku Ubuntu \
    --node-count 3
```

It takes a few minutes to create the node pool.

# [Add an Azure Linux node pool](#tab/azure-linux)
Create a new node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. The following example creates a `Linux` node pool with the `Azure Linux` OS SKU that runs *three* nodes. If you don't specify an OS SKU, AKS defaults to `Ubuntu`.

For more information about Azure Linux, see [Azure Linux on AKS](use-azure-linux).

```azurecli
az aks nodepool add \
    --resource-group $RESOURCE_GROUP_NAME \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --node-vm-size Standard_DS2_v2 \
    --os-type Linux \
    --os-sku AzureLinux \
    --node-count 3
```

It takes a few minutes to create the node pool.

# [Add an Azure Container Linux (ACL) for AKS node pool](#tab/acl)
Add a new node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. The `--os-sku AzureContainerLinux` parameter configures the node pool to use ACL as the node OS. The following example creates a `Linux` node pool that runs *three* nodes.

```azurecli
az aks nodepool add \
    --resource-group $RESOURCE_GROUP_NAME \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --node-vm-size Standard_DS2_v2 \
    --os-type Linux \
    --os-sku AzureContainerLinux \
    --node-count 3
```

It takes a few minutes to create the node pool.

For more information, see [Azure Container Linux (ACL) for AKS](azure-container-linux-overview).

# [Add an Azure Linux with OS Guard for AKS (preview) node pool](#tab/os-guard)
##### Install the `aks-preview` extension

1. Install the `aks-preview` Azure CLI extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    Important

    AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

    - [AKS support policies](/en-us/azure/aks/support-policies)
    - [Azure support FAQ](/en-us/azure/aks/faq)

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    az extension update --name aks-preview
    ```

##### Register the `AzureLinuxOSGuardPreview` feature flag

1. Register the `AzureLinuxOSGuardPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AzureLinuxOSGuardPreview"
    ```
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*.

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name AzureLinuxOSGuardPreview
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

##### Create the Azure Linux with OS Guard for AKS node pool

Create a new node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. The following example creates a `Linux` node pool with the `Azure Linux with OS Guard` OS SKU that runs *three* nodes. If you don't specify an OS SKU, AKS defaults to `Ubuntu`.

```azurecli
az aks nodepool add \
    --resource-group $RESOURCE_GROUP_NAME \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --node-vm-size Standard_DS2_v2 \
    --os-type Linux \
    --os-sku AzureLinuxOSGuard \
    --node-osdisk-type Managed \
    --enable-fips-image \
    --enable-secure-boot \
    --enable-vtpm \
    --node-count 3
```

It takes a few minutes to create the node pool.

For more information, see [Azure Linux with OS Guard for AKS](use-azure-linux-os-guard).

# [Add a Flatcar Container Linux for AKS (preview) node pool](#tab/flatcar)
##### Install the `aks-preview` extension

1. Install the `aks-preview` Azure CLI extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    Important

    AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

    - [AKS support policies](/en-us/azure/aks/support-policies)
    - [Azure support FAQ](/en-us/azure/aks/faq)

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command. **Flatcar Container Linux requires a minimum of 18.0.0b42**.

    ```azurecli
    az extension update --name aks-preview
    ```

##### Register the `AKSFlatcarPreview` feature flag

1. Register the `AKSFlatcarPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AKSFlatcarPreview"
    ```
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*.

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name AKSFlatcarPreview
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

##### Create the Flatcar Container Linux for AKS node pool

Create a new node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. The following example creates a `Linux` node pool with the `flatcar` OS SKU that runs *three* nodes. If you don't specify an OS SKU, AKS defaults to `Ubuntu`.

```azurecli
az aks nodepool add \
    --resource-group $RESOURCE_GROUP_NAME \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --node-vm-size Standard_DS2_v2 \
    --os-type Linux \
    --os-sku flatcar \
    --node-count 3
```

It takes a few minutes to create the node pool.

For more information, see [Flatcar Container Linux for AKS](flatcar-container-linux-for-aks).

---

### Add a Windows Server node pool

# [Add a Windows Server 2025 node pool](#tab/ws2025)
##### Create the Windows Server 2025 node pool

Create a new node pool by using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. The following example creates a `Windows` node pool with the `Windows2025` OS SKU that runs *three* nodes. Windows Server 2025 node pools require a FIPS-enabled image, so the command includes `--enable-fips-image`.

For more information about Windows OS, see [Windows best practices](windows-best-practices).

```azurecli
az aks nodepool add \
    --resource-group $RESOURCE_GROUP_NAME \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --node-vm-size Standard_DS2_v2 \
    --os-type Windows \
    --os-sku Windows2025 \
    --enable-fips-image \
    --node-count 3
```

# [Add a Windows Server 2022 node pool](#tab/ws2022)
Create a new node pool using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. The following example creates a `Windows` node pool with the `Windows2022` OS SKU that runs *three* nodes.

For more information about Windows OS, see [Windows best practices](windows-best-practices).

```azurecli
az aks nodepool add \
    --resource-group $RESOURCE_GROUP_NAME \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --node-vm-size Standard_DS2_v2 \
    --os-type Windows \
    --os-sku Windows2022 \
    --node-count 3
```

---

## Check the status of your node pools

Check the status of your node pools using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command and specify your resource group and cluster name.

```azurecli
az aks nodepool list --resource-group $RESOURCE_GROUP_NAME --cluster-name $CLUSTER_NAME
```

::: zone-end

::: zone pivot="arm"

## Create an AKS cluster with a single node pool using an ARM template

If you want only one node pool in your AKS cluster, you can schedule application pods on system node pools. If you run a single system node pool for your AKS cluster in a production environment, we recommend you use at least three nodes for the node pool. If one node goes down, the redundancy is compromised. You can mitigate this risk by having more system node pool nodes.

### Create a `Microsoft.ContainerService/managedClusters` resource

Create a `Microsoft.ContainerService/managedClusters` resource by adding [this JSON](/en-us/azure/templates/microsoft.containerservice/managedclusters?pivots=deployment-language-arm-template) to your template.

# [Create a single Ubuntu node pool](#tab/ubuntu-arm)
- Create a single Ubuntu node pool in your AKS cluster by making the following modifications to your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
        {
            "count": "1",
            "osSKU": "ubuntu",
            "osType": "linux"
         } 
         ],
    }
    ```

# [Create a single Azure Linux node pool](#tab/azure-linux-arm)
- Create a single Azure Linux node pool in your AKS cluster by making the following modifications to your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
        {
            "count": "1",
            "osSKU": "AzureLinux",
            "osType": "linux"
         } 
         ],
    }
    ```

    For more information about Azure Linux, see [Azure Linux on AKS](use-azure-linux).

# [Create a single Azure Container Linux (ACL) for AKS node pool](#tab/acl-arm)
- Create a single ACL node pool in your AKS cluster by setting `osSKU` to `AzureContainerLinux` in your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
        {
            "count": "1",
            "osSKU": "AzureContainerLinux",
            "osType": "linux"
        } 
         ],
    }
    ```

For more information, see [Azure Container Linux (ACL) for AKS](azure-container-linux-overview).

# [Create a single Azure Linux with OS Guard for AKS (preview) node pool](#tab/os-guard-arm)
#### Install the `aks-preview` extension

1. Install the `aks-preview` Azure CLI extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    Important

    AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

    - [AKS support policies](/en-us/azure/aks/support-policies)
    - [Azure support FAQ](/en-us/azure/aks/faq)

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    az extension update --name aks-preview
    ```

#### Register the `AzureLinuxOSGuardPreview` feature flag

1. Register the `AzureLinuxOSGuardPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AzureLinuxOSGuardPreview"
    ```
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*.

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name AzureLinuxOSGuardPreview
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

#### Create the Azure Linux with OS Guard for AKS node pool

- Create a single Azure Linux with OS Guard for AKS node pool in your AKS cluster by making the following modifications to your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
        {
            "count": "1",
            "osSKU": "AzureLinuxOSGuard",
            "osType": "linux",
            "osDiskType": "Managed",
                        "enableFIPS": true,
                        "securityProfile": {
                            "enableSecureBoot": true,
                            "enableVTPM": true
                        },
         } 
         ],
    }
    ```

    For more information, see [Azure Linux with OS Guard for AKS](use-azure-linux-os-guard).

# [Create a single Flatcar Container Linux for AKS (preview) node pool](#tab/flatcar-arm)
#### Install the `aks-preview` extension

1. Install the `aks-preview` Azure CLI extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    Important

    AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

    - [AKS support policies](/en-us/azure/aks/support-policies)
    - [Azure support FAQ](/en-us/azure/aks/faq)

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command. **Flatcar Container Linux requires a minimum of 18.0.0b42**.

    ```azurecli
    az extension update --name aks-preview
    ```

#### Register the `AKSFlatcarPreview` feature flag

1. Register the `AKSFlatcarPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AKSFlatcarPreview"
    ```
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*.

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name AKSFlatcarPreview
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

#### Create the Flatcar Container Linux for AKS node pool

- Create a single Flatcar Container Linux for AKS node pool in your AKS cluster by making the following modifications to your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
        {
            "count": "1",
            "osSKU": "flatcar",
            "osType": "linux"
         } 
         ],
    }
    ```

    For more information, see [Flatcar Container Linux for AKS](flatcar-container-linux-for-aks).

---

## Add a second node pool using an ARM template

The cluster created in the previous section has a single node pool. In this section, we add a second node pool to the cluster. This second node pool can have an OS type of `Linux` with an OS SKU of `Ubuntu` or `AzureLinux`, or an OS type of `Windows`.

### Add Linux node pools

# [Create multiple Ubuntu node pools](#tab/ubuntu-arm)
- Create multiple Ubuntu node pools in your AKS cluster by making the following modifications to your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
        {
            "count": "3",
            "osSKU": "ubuntu",
            "osType": "linux"
         } 
         ],
    }
    ```

# [Create multiple Azure Linux node pools](#tab/azure-linux-arm)
- Create multiple Azure Linux node pools in your AKS cluster by making the following modifications to your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
        {
            "count": "3",
            "osSKU": "AzureLinux",
            "osType": "linux"
         } 
         ],
    }
    ```

    For more information about Azure Linux, see [Azure Linux on AKS](use-azure-linux).

# [Create multiple Azure Container Linux (ACL) for AKS node pools](#tab/acl-arm)
- Create multiple ACL node pools in your AKS cluster by making the following modifications to your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
          {
            "count": "3",
            "osSKU": "AzureContainerLinux",
            "osType": "linux",
            "name": "pool1"
          },
          {
            "count": "2",
            "osSKU": "AzureContainerLinux",
            "osType": "linux",
            "name": "pool2"
          }
        ]
      }
    ```

For more information, see [Azure Container Linux (ACL) for AKS](azure-container-linux-overview).

# [Create multiple Azure Linux with OS Guard for AKS (preview) node pools](#tab/os-guard-arm)
##### Install the `aks-preview` extension

1. Install the `aks-preview` Azure CLI extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    Important

    AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

    - [AKS support policies](/en-us/azure/aks/support-policies)
    - [Azure support FAQ](/en-us/azure/aks/faq)

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    az extension update --name aks-preview
    ```

##### Register the `AzureLinuxOSGuardPreview` feature flag

1. Register the `AzureLinuxOSGuardPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AzureLinuxOSGuardPreview"
    ```
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*.

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name AzureLinuxOSGuardPreview
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

##### Create the Azure Linux with OS Guard for AKS node pools

- Create multiple Azure Linux with OS Guard for AKS (preview) node pools in your AKS cluster by making the following modifications to your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
        {
            "count": "3",
            "osSKU": "AzureLinuxOSGuard",
            "osType": "linux",
            "osDiskType": "Managed",
            "enableFIPS": true,
            "securityProfile": {
                   "enableSecureBoot": true,
                   "enableVTPM": true
             },
         } 
         ],
    }
    ```

For more information, see [Azure Linux with OS Guard for AKS](use-azure-linux-os-guard).

# [Create multiple Flatcar Container Linux for AKS (preview) node pools](#tab/flatcar-arm)
##### Install the `aks-preview` extension

1. Install the `aks-preview` Azure CLI extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    Important

    AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

    - [AKS support policies](/en-us/azure/aks/support-policies)
    - [Azure support FAQ](/en-us/azure/aks/faq)

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command. **Flatcar Container Linux requires a minimum of 18.0.0b42**.

    ```azurecli
    az extension update --name aks-preview
    ```

##### Register the `AKSFlatcarPreview` feature flag

1. Register the `AKSFlatcarPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "AKSFlatcarPreview"
    ```
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the status to show *Registered*.

    ```azurecli
    az feature show --namespace Microsoft.ContainerService --name AKSFlatcarPreview
    ```
3. When the status reflects *Registered*, refresh the registration of the *Microsoft.ContainerService* resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

##### Create the Flatcar Container Linux for AKS node pools

- Create multiple Flatcar Container Linux for AKS (preview) node pools in your AKS cluster by making the following modifications to your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
        {
            "count": "3",
            "osSKU": "flatcar",
            "osType": "linux"
         } 
         ],
    }
    ```

For more information, see [Flatcar Container Linux for AKS](flatcar-container-linux-for-aks).

---

### Add Windows Server node pools

# [Modify JSON to create multiple Windows Server 2025 node pools](#tab/ws2025-arm)
##### Create the Windows Server 2025 node pools

- Create multiple Windows node pools in your AKS cluster by making the following modifications to your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
        {
            "count": "3",
            "osSKU": "windows2025",
            "osType": "windows"
         } 
         ],
    }
    ```

# [Modify JSON to create multiple Windows Server 2022 node pools](#tab/ws2022-arm)
- Create multiple Windows node pools in your AKS cluster by making the following modifications to your ARM template:

    ```json
      "properties": {
        "agentPoolProfiles": [
        {
            "count": "3",
            "osSKU": "windows2022",
            "osType": "windows"
         } 
         ],
    }
    ```

---

## Deploy your ARM template

- Deploy your ARM template by following the guidance in [Deploy an Azure Kubernetes Service (AKS) cluster using an ARM template](learn/quick-kubernetes-deploy-rm-template).

::: zone-end

## Set taints, labels, or tags for a node pool

When creating a node pool, you can add taints, labels, or tags to it. When you add a taint, label, or tag, all nodes within that node pool also get that taint, label, or tag. We recommend applying these properties to an entire node pool instead of individual nodes. This way, you can easily manage the properties of all nodes in the node pool by updating the node pool properties instead of updating each node individually.

For specific instructions on how to set taints, labels, or tags for a node pool, use the following resources:

- [Use node taints in an Azure Kubernetes Service (AKS) cluster](use-node-taints)
- [Use labels in an Azure Kubernetes Service (AKS) cluster](use-labels)
- [Use Azure tags in Azure Kubernetes Service (AKS)](use-tags)
- [Provide dedicated nodes using taints and tolerations in Azure Kubernetes Service (AKS)](operator-best-practices-advanced-scheduler#what-are-taints-and-tolerations)