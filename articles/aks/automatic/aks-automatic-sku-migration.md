---
layout: Conceptual
title: Migrate AKS Automatic clusters and managed system node pools - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/automatic/aks-automatic-sku-migration
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
manager: kumud
learn_banner_products:
- azure
ms.service: azure-kubernetes-service
description: Learn how to migrate AKS Automatic clusters between managed system node pool and AKS Standard configurations.
ms.topic: how-to
ms.date: 2026-10-23T00:00:00.0000000Z
author: wangyira
ms.author: wangamanda
locale: en-us
document_id: 1440884c-161d-36b4-d063-a3b4fd0b9c89
document_version_independent_id: 27acf025-6727-3e58-a4bc-1aaf302760e0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/automatic/aks-automatic-sku-migration.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: ../toc.json
asset_id: aks/automatic/aks-automatic-sku-migration
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/automatic/aks-automatic-sku-migration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: b43d6e57-29fa-55ef-ef76-cd00df8703d6
---

# Migrate AKS Automatic clusters and managed system node pools - Azure Kubernetes Service | Microsoft Learn

**Applies to**: ✔️ AKS Automatic ✔️ AKS Standard

This article shows you how to migrate AKS Automatic clusters between supported [managed system node pool](aks-automatic-managed-system-node-pools-about) and AKS Standard configurations.

## Supported migration paths

| Migration path | Support |
| --- | --- |
| AKS Automatic with managed system node pools to AKS Standard (`base` SKU) | Supported |
| AKS Automatic without managed system node pools to AKS Automatic with managed system node pools | Supported in preview in regions where managed system node pools are generally available |
| AKS Standard (`base` SKU) to AKS Automatic with managed system node pools | Supported in preview in regions where managed system node pools are generally available |
| AKS Automatic with managed system node pools to AKS Automatic without managed system node pools | Not supported |

By using managed system node pools, AKS provisions, scales, and upgrades the system node pools and system components for you, and isolates them from your workloads. AKS Automatic clusters are also backed by a [pod readiness SLA and an uptime SLA](../intro-aks-automatic#service-level-agreement). For more information, see [Overview of AKS Automatic clusters with managed system node pools](aks-automatic-managed-system-node-pools-about).

## Migrate from an AKS Automatic cluster with managed system node pools to an AKS Standard cluster

### How the migration works

An AKS Automatic cluster with managed system node pools runs its system components on system node pools that AKS provisions, scales, and upgrades for you.

Important

An AKS Standard (`base` SKU) cluster doesn't enable managed system node pools, so you're responsible for running, managing, and upgrading the system node pool and the system components.

To migrate from AKS Automatic to AKS Standard, complete the following high-level steps:

1. Add a self-managed system node pool to your AKS Automatic cluster.
2. Update the cluster SKU from `automatic` to `base`.

After you update the SKU, the cluster runs as an AKS Standard cluster, and your system components run on the system node pool that you added and manage.

### Migrate to an AKS Standard cluster

1. Add a self-managed system node pool to your existing AKS Automatic cluster by using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command. Set the node pool mode to `System` so it can run system components after migration.

    ```azurecli
    az aks nodepool add \
        --resource-group "${RESOURCE_GROUP}" \
        --cluster-name "${RESOURCE_NAME}" \
        --name systempool \
        --mode System \
        --node-count 3
    ```
2. Update the cluster SKU from `automatic` to `base` by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command.

    ```azurecli
    az aks update \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --sku base
    ```

### Verify the migration

1. Confirm that the cluster now uses the `base` SKU by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

    ```azurecli
    az aks show \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --query "sku" \
        --output table
    ```
2. List the node pools on the cluster to confirm your self-managed system node pool is present and in the `System` mode by using the [`az aks nodepool list`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-list) command.

    ```azurecli
    az aks nodepool list \
        --resource-group "${RESOURCE_GROUP}" \
        --cluster-name "${RESOURCE_NAME}" \
        --query "[].{Name:name, Mode:mode, Count:count}" \
        --output table
    ```

## Migrate from an AKS Automatic cluster without managed system node pools to AKS Automatic with managed system node pools (preview)

AKS Automatic supports preview migration from non-managed system node pools to managed system node pools in regions where managed system node pools are generally available. This migration keeps the cluster on the `automatic` SKU and moves AKS system components to a system node pool managed by AKS.

### Prerequisites

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

- An existing AKS Automatic cluster without managed system node pools.
- Azure CLI version 2.86.0 or later. To find the version, run `az --version`. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The latest version of the `aks-preview` Azure CLI extension.
- The `Microsoft.ContainerService/NonHoboToHoboConversionPreview` feature flag registered in your subscription.

Register the `NonHoboToHoboConversionPreview` feature flag by using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command:

```azurecli
az feature register \
    --namespace Microsoft.ContainerService \
    --name NonHoboToHoboConversionPreview
```

Check the registration status by using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command:

```azurecli
az feature show \
    --namespace Microsoft.ContainerService \
    --name NonHoboToHoboConversionPreview \
    --query properties.state \
    --output tsv
```

Wait until the command returns `Registered` before you continue. Then, refresh the `Microsoft.ContainerService` resource provider registration.

```azurecli
az provider register --namespace Microsoft.ContainerService
```

Install or update the `aks-preview` extension:

```azurecli
az extension add --name aks-preview
az extension update --name aks-preview
```

### Migrate an AKS-managed virtual network cluster

For an AKS Automatic cluster that uses AKS-managed networking, migrate to managed system node pools by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-hosted-system` parameter:

```azurecli
az aks update \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${RESOURCE_NAME}" \
    --enable-hosted-system
```

### Migrate a custom virtual network cluster

For an AKS Automatic cluster that uses a custom virtual network, provide a subnet for the managed system node pool by using the `--system-node-subnet-id` parameter. The system node subnet must:

- Be in the same virtual network and region as the cluster.
- Be at least `/26`.
- Not be delegated to another service.
- Be different from the node subnet.

The `--node-subnet-id` parameter is optional. If you don't provide it, AKS uses the existing system node pool subnet.

```azurecli
az aks update \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${RESOURCE_NAME}" \
    --enable-hosted-system \
    --system-node-subnet-id "${SYSTEM_NODE_SUBNET_ID}" \
    --node-subnet-id "${NODE_SUBNET_ID}"
```

### Verify the migration

Confirm the cluster uses managed system node pools by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command:

```azurecli
az aks show \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${RESOURCE_NAME}" \
    --query hostedSystemProfile \
    --output json
```

The following example output shows the `hostedSystemProfile.enabled` property set to `true`:

```output
{
  "enabled": true,
  "nodeSubnetId": "<node-subnet-resource-id>",
  "systemNodeSubnetId": "<system-node-subnet-resource-id>"
}
```

## Migrate from an AKS Standard cluster to an AKS Automatic cluster with managed system node pools (preview)

AKS supports preview migration from AKS Standard (`base` SKU) clusters to AKS Automatic clusters with managed system node pools in regions where managed system node pools are generally available.

To migrate, you first configure your AKS Standard cluster to match the AKS Automatic configuration, and then update the cluster SKU. Most of the work is in preparing the cluster. Complete the following sections in order, because several settings depend on others being configured first.

### Before you begin

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

- An existing AKS Standard (`base` SKU) cluster. For general AKS Automatic requirements and limitations, see [Quickstart: Create an Azure Kubernetes Service (AKS) Automatic cluster](quick-automatic-managed-network) and [Overview of AKS Automatic clusters with managed system node pools](aks-automatic-managed-system-node-pools-about).
- Azure CLI version 2.86.0 or later and the latest version of the `aks-preview` extension.
- The `Microsoft.ContainerService/NonHoboToHoboConversionPreview` feature flag registered in your subscription. To register the feature flag and install the extension, follow the steps in Prerequisites.

Set environment variables for your cluster:

```azurecli
export RESOURCE_GROUP="<resource-group>"
export RESOURCE_NAME="<cluster-name>"
export NODE_RESOURCE_GROUP=$(az aks show --resource-group "${RESOURCE_GROUP}" --name "${RESOURCE_NAME}" --query nodeResourceGroup --output tsv)
```

### Migration requirements

Before you can update the SKU, your cluster must meet the following requirements. Some requirements differ depending on whether your cluster uses an AKS-managed virtual network or a custom virtual network. You can configure these settings by using the Azure portal, Azure CLI, an ARM template, or other tools. The rest of this article shows the Azure CLI steps in the order that you should apply them.

| Requirement | Required setting | Learn more |
| --- | --- | --- |
| Cluster tier | Standard | [AKS pricing tiers](../free-standard-pricing-tiers) |
| Load balancer SKU | Standard | [Customize cluster egress with outbound types](../egress-outboundtype) |
| Outbound type | AKS-managed virtual network: managed NAT gateway (`StandardV2`). The `loadBalancer` outbound type isn't supported.Custom virtual network: any outbound type. | [Update outboundType after cluster creation](../egress-outboundtype#update-outboundtype-after-cluster-creation) |
| Cluster identity | AKS-managed virtual network: system-assigned managed identity.Custom virtual network: user-assigned managed identity with the *Network Contributor* role on the virtual network. | [Use a user-assigned managed identity](../user-assigned-managed-identity) |
| API Server VNet Integration | Enabled, with a dedicated API server subnet in the same virtual network as your nodes | [Convert an existing AKS Standard cluster to API Server VNet Integration](../api-server-vnet-integration#convert-an-existing-aks-standard-cluster-to-api-server-vnet-integration) |
| Network plugin | Azure CNI Overlay (`azure` plugin in `overlay` mode) | [Update the IPAM mode to Azure CNI Overlay](../update-azure-cni#update-the-ipam-mode-to-azure-cni-overlay) |
| Network dataplane and network policy | Cilium | [Azure CNI Powered by Cilium](../azure-cni-powered-by-cilium) |
| Node provisioning mode | Auto | [Node auto-provisioning](../node-auto-provisioning) |
| System node pool OS SKU | Azure Linux | [Use the Azure Linux Container Host](../use-azure-linux) |
| System node pool SSH access | Disabled | [Manage SSH access on AKS cluster nodes](../manage-ssh-node-access) |
| System node pool OS disk | Ephemeral | [Ephemeral OS disks in AKS](../concepts-storage#ephemeral-os-disks-in-aks) |
| Azure Policy add-on | Enabled | [Use Azure Policy](../use-azure-policy) |
| Azure Key Vault Secrets Provider add-on | Enabled, with secret rotation turned on | [Use the Secrets Store CSI Driver](../csi-secrets-store-driver) |
| Auto-upgrade channels | Cluster: `stable`Node OS: `NodeImage` | [Automatically upgrade an AKS cluster](../auto-upgrade-cluster) |
| Workload identity and OIDC issuer | Enabled | [Use Microsoft Entra Workload ID](../workload-identity-overview) |
| Microsoft Entra integration and Azure RBAC | Enabled | [Microsoft Entra integration](../access-control-managed-azure-ad) |
| Local accounts | Disabled | [Manage local accounts with Microsoft Entra integration](../local-accounts) |
| Image Cleaner | Enabled | [Image Cleaner](../image-cleaner) |
| Vertical Pod Autoscaler | Enabled | [Vertical Pod Autoscaling](../vertical-pod-autoscaler) |
| KEDA | Enabled | [KEDA](../keda-about) |
| Node resource group lockdown | `ReadOnly` | [Node resource group lockdown](../node-resource-group-lockdown) |

### Plan your migration

1. Determine whether your cluster uses an AKS-managed virtual network or a custom virtual network. If the following command returns a virtual network name, your cluster uses an AKS-managed virtual network. If it returns nothing, your cluster uses a custom virtual network.

    ```azurecli
    az network vnet list --resource-group "${NODE_RESOURCE_GROUP}" --query "[].name" --output tsv
    ```

    Several steps in this article differ depending on your virtual network type.
2. Check your cluster's current network plugin, outbound type, load balancer SKU, and node resource group restriction level:

    ```azurecli
    az aks show \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --query "{networkPlugin:networkProfile.networkPlugin, networkPluginMode:networkProfile.networkPluginMode, outboundType:networkProfile.outboundType, loadBalancerSku:networkProfile.loadBalancerSku, nrgRestrictionLevel:nodeResourceGroupProfile.restrictionLevel}" \
        --output table
    ```

    - **Network plugin**: Must be `azure` with plugin mode `overlay`. If your cluster uses kubenet or Azure CNI without Overlay, update it to Azure CNI Overlay before you continue. For more information, see [Update the IPAM mode to Azure CNI Overlay](../update-azure-cni#update-the-ipam-mode-to-azure-cni-overlay).
    - **Load balancer SKU**: Must be `standard`. If your cluster still uses `basic`, update it with `az aks update --load-balancer-sku standard`.
    - **Node resource group restriction level**: For an AKS-managed virtual network, you need to create a subnet in the node resource group. If the restriction level is `ReadOnly`, set it to `Unrestricted` before you continue. You lock it down again in a later step.
3. Review the changes that disrupt running workloads or access, and plan a maintenance window:

    - Changing the outbound type changes your cluster's egress IP addresses. Update any firewall rules that allow traffic from the cluster.
    - Enabling API Server VNet Integration changes the API server IP address and requires a cluster restart. This change is permanent.
    - Changing the network dataplane, OS SKU, and SSH access settings reimages your nodes.
    - Disabling local accounts removes static kubeconfig credentials. Ensure you have access through Microsoft Entra ID and an Azure RBAC role, such as *Azure Kubernetes Service RBAC Cluster Admin*, before you disable them.
    - The migration enables Deployment Safeguards in `Enforce` mode with baseline Pod Security Standards. Deployments that don't comply are rejected. You can exclude namespaces, but you can't switch the cluster-wide level to `Warn`. Review your workloads before you migrate. For more information, see [Use Deployment Safeguards](../deployment-safeguards#excluding-namespaces).

### Prepare cluster networking

1. **Outbound type**: For an AKS-managed virtual network, the outbound type must be a managed NAT gateway. The `loadBalancer` outbound type isn't supported. If needed, update the outbound type:

    ```azurecli
    az aks update \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --outbound-type managedNATGateway \
        --outbound-type-sku StandardV2
    ```

    For a custom virtual network, any outbound type is supported and no change is required. For more information, see [Update outboundType after cluster creation](../egress-outboundtype#update-outboundtype-after-cluster-creation).
2. **Cluster identity**: For an AKS-managed virtual network, keep the cluster's system-assigned managed identity. For a custom virtual network, the cluster must use a user-assigned managed identity that has the *Network Contributor* role on the virtual network. If needed, assign the identity:

    ```azurecli
    az aks update \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --enable-managed-identity \
        --assign-identity "${IDENTITY_RESOURCE_ID}" \
        --yes
    ```

    Replace `IDENTITY_RESOURCE_ID` with the resource ID of your user-assigned managed identity. For more information, see [Use a user-assigned managed identity](../user-assigned-managed-identity).
3. **API server subnet**: Create a dedicated subnet for the API server in the same virtual network as your nodes. The subnet must be separate from your node subnet, be at least `/28`, and be delegated to `Microsoft.ContainerService/managedClusters`.

    For an AKS-managed virtual network, create the subnet in the virtual network in the node resource group:

    ```azurecli
    export VNET_NAME=$(az network vnet list --resource-group "${NODE_RESOURCE_GROUP}" --query "[0].name" --output tsv)
    
    export APISERVER_SUBNET_ID=$(az network vnet subnet create \
        --resource-group "${NODE_RESOURCE_GROUP}" \
        --vnet-name "${VNET_NAME}" \
        --name apiserver-subnet \
        --address-prefixes "<unused-address-range>" \
        --delegations Microsoft.ContainerService/managedClusters \
        --query id --output tsv)
    ```

    For a custom virtual network, create the subnet in your own virtual network instead, and set `APISERVER_SUBNET_ID` to its resource ID.
4. **API Server VNet Integration**: Enable API Server VNet Integration with the subnet you created, and then restart the cluster:

    ```azurecli
    az aks update \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --enable-apiserver-vnet-integration \
        --apiserver-subnet-id "${APISERVER_SUBNET_ID}"
    
    az aks stop --resource-group "${RESOURCE_GROUP}" --name "${RESOURCE_NAME}"
    az aks start --resource-group "${RESOURCE_GROUP}" --name "${RESOURCE_NAME}"
    ```

    For more information, see [Convert an existing AKS Standard cluster to API Server VNet Integration](../api-server-vnet-integration#convert-an-existing-aks-standard-cluster-to-api-server-vnet-integration).
5. **Network dataplane**: Update the network dataplane to Cilium. This command also sets the network policy to Cilium.

    ```azurecli
    az aks update \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --network-dataplane cilium
    ```

    For more information, see [Azure CNI Powered by Cilium](../azure-cni-powered-by-cilium).

Important

Update the network dataplane before you enable Auto node provisioning mode in the next section. After Auto mode is enabled, you can't change the network dataplane.

### Prepare the system node pool and node provisioning

1. **Ephemeral OS disk**: The system node pool must use an ephemeral OS disk. Check the current OS disk type:

    ```azurecli
    az aks nodepool list \
        --resource-group "${RESOURCE_GROUP}" \
        --cluster-name "${RESOURCE_NAME}" \
        --query "[?mode=='System'].{name:name, osDiskType:osDiskType}" \
        --output table
    ```

    You can't change the OS disk type of an existing node pool. If your system node pool uses a `Managed` OS disk, [add a new system node pool](../create-node-pools) with `--mode System --node-osdisk-type Ephemeral --os-sku AzureLinux --ssh-access disabled`, move your system workloads to it, and then [delete the old node pool](../delete-node-pool). You can then skip the next step.
2. **OS SKU and SSH access**: Update the system node pool to use Azure Linux and disable SSH access:

    ```azurecli
    az aks nodepool update \
        --resource-group "${RESOURCE_GROUP}" \
        --cluster-name "${RESOURCE_NAME}" \
        --name "<system-node-pool-name>" \
        --os-sku AzureLinux \
        --ssh-access disabled \
        --yes
    ```

    This command reimages the node pool. Wait for it to finish before you make other changes to the node pool. For more information, see [Use the Azure Linux Container Host](../use-azure-linux) and [Manage SSH access on AKS cluster nodes](../manage-ssh-node-access).
3. **Node provisioning mode**: Enable Auto node provisioning mode:

    ```azurecli
    az aks update \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --node-provisioning-mode Auto
    ```

    After you enable Auto mode, you can't revert to Manual mode without first removing all autoprovisioned nodes. For more information, see [Node auto-provisioning](../node-auto-provisioning).

### Enable required features and add-ons

1. Update the cluster tier to Standard, and enable the Azure Policy and Azure Key Vault Secrets Provider add-ons with secret rotation:

    ```azurecli
    az aks update --resource-group "${RESOURCE_GROUP}" --name "${RESOURCE_NAME}" --tier standard
    
    az aks enable-addons \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --addons azure-policy,azure-keyvault-secrets-provider \
        --enable-secret-rotation
    ```
2. Enable the remaining required features:

    ```azurecli
    az aks update \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --auto-upgrade-channel stable \
        --node-os-upgrade-channel NodeImage \
        --enable-workload-identity \
        --enable-oidc-issuer \
        --enable-aad \
        --enable-azure-rbac \
        --disable-local-accounts \
        --enable-image-cleaner \
        --enable-vpa \
        --enable-keda \
        --yes
    ```

### Lock down the node resource group

Set the node resource group restriction level to `ReadOnly`. Do this step last, because lockdown blocks changes to resources in the node resource group, including the API server subnet you created earlier.

```azurecli
az aks update \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${RESOURCE_NAME}" \
    --nrg-lockdown-restriction-level ReadOnly
```

For more information, see [Node resource group lockdown](../node-resource-group-lockdown).

### Migrate the cluster to AKS Automatic

If any requirement is still unmet, the migration command fails and lists the unmet requirements it detected. Some checks run only after earlier ones pass, so resolve the listed items and run the command again until it succeeds.

#### AKS-managed virtual network

```azurecli
az aks update \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${RESOURCE_NAME}" \
    --sku automatic \
    --enable-hosted-system
```

#### Custom virtual network

Provide a subnet for the managed system node pool by using the `--system-node-subnet-id` parameter. For subnet requirements, see [Migrate an existing AKS Automatic cluster to managed system node pools](aks-automatic-managed-system-node-pools-about#migrate-an-existing-aks-automatic-cluster-to-managed-system-node-pools-preview). The `--node-subnet-id` parameter is optional. If you don't provide it, AKS uses the existing system node pool subnet.

```azurecli
az aks update \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${RESOURCE_NAME}" \
    --sku automatic \
    --enable-hosted-system \
    --system-node-subnet-id "${SYSTEM_NODE_SUBNET_ID}" \
    --node-subnet-id "${NODE_SUBNET_ID}"
```

### Verify the migration

1. Confirm that the cluster uses the `automatic` SKU and `Standard` tier, and that the update finished successfully:

    ```azurecli
    az aks show \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --query "{sku:sku, provisioningState:provisioningState}" \
        --output json
    ```

    Confirm `sku.name` is `Automatic`, `sku.tier` is `Standard`, and `provisioningState` is `Succeeded`.
2. Confirm the cluster uses managed system node pools:

    ```azurecli
    az aks show \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${RESOURCE_NAME}" \
        --query hostedSystemProfile \
        --output json
    ```

    Confirm `hostedSystemProfile.enabled` is `true`. For a custom virtual network, `systemNodeSubnetId` and `nodeSubnetId` show your subnet resource IDs. For an AKS-managed virtual network, these values are `null`.
3. Get credentials for the cluster and confirm all nodes are in the `Ready` state:

    ```azurecli
    az aks get-credentials --resource-group "${RESOURCE_GROUP}" --name "${RESOURCE_NAME}"
    kubectl get nodes -o wide
    ```

### Failure behavior

If migration can't provision managed system pool infrastructure (for example, because of regional capacity constraints), AKS preserves existing system and user node pools in their pre-migration state.