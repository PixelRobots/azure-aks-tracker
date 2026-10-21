---
layout: Conceptual
title: Create a network isolated Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/network-isolated
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
description: Learn how to configure an Azure Kubernetes Service (AKS) cluster with outbound and inbound network restrictions.
ms.subservice: aks-networking
ms.custom: devx-track-azurecli, devx-track-terraform
author: schaffererin
ms.author: schaffererin
ms.topic: how-to
ms.date: 2026-09-09T00:00:00.0000000Z
zone_pivot_groups: network-isolated-acr-type
ai-usage: ai-assisted
locale: en-us
document_id: 7e2b7390-5bd4-2b69-da0d-602ae9e67e7c
document_version_independent_id: 7d8b31f7-3de1-9d60-c74b-d63cf0864858
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/network-isolated.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/network-isolated
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/network-isolated.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/cb49e66a-8528-497d-adaa-eade2d009d1b
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/472c9d15-157b-443c-afa2-e209c8fecf58
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
platformId: 29f4b0b3-25a8-f3b1-af61-8579ad49bccf
---

# Create a network isolated Azure Kubernetes Service (AKS) cluster - Azure Kubernetes Service | Microsoft Learn

Organizations typically have strict security and compliance requirements to regulate egress (outbound) network traffic from a cluster to eliminate risks of data exfiltration. By default, standard SKU Azure Kubernetes Service (AKS) clusters have unrestricted outbound internet access. This level of network access allows nodes and services you run to access external resources as needed. If you wish to restrict egress traffic, a limited number of ports and addresses must be accessible to maintain healthy cluster maintenance tasks. The conceptual document on [outbound network and FQDN rules for AKS clusters](outbound-rules-control-egress) provides a list of required endpoints for the AKS cluster and its optional add-ons and features.

One common solution to restricting outbound traffic from the cluster is to use a [firewall device](limit-egress-traffic) to restrict traffic based on firewall rules. Firewall is applicable when your application requires outbound access, but when outbound requests have to be inspected and secured. Configuring a firewall manually with required egress rules and *FQDNs* is a cumbersome process especially if your only requirement is to create an isolated AKS cluster with no outbound dependencies for the cluster bootstrapping.

To reduce risk of data exfiltration, network isolated cluster allows for bootstrapping the AKS cluster without any outbound network dependencies, even for fetching cluster components/images from Microsoft Artifact Registry (MAR). The cluster operator could incrementally set up allowed outbound traffic for each scenario they want to enable. This article walks you through the steps of creating a network isolated cluster.

## Before you begin

- Read the [conceptual overview of this feature](concepts-network-isolated), which provides an explanation of how network isolated clusters work. The overview article also:
    - Explains two options for private Azure Container Registry (ACR) resource used for cluster bootstrapping - AKS-managed ACR or bring-your-own ACR.
    - Explains two private cluster modes for creating private access to API server - [private link-based](private-clusters) or [API Server VNet Integration](api-server-vnet-integration).
    - Explains the two outbound types for cluster egress control - `none` or `block` (preview).
    - Describes the [current limitations of network isolated clusters](concepts-network-isolated#limitations).

Note

Outbound type `none` is generally available. Outbound type `block` is in preview.

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

::: zone pivot="aks-managed-acr,byo-acr"

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- This article requires version 2.73.0 or later of the Azure CLI. If you're using Azure Cloud Shell, the latest version is already installed there.
- You should install the `aks-preview` Azure CLI extension version *9.0.0b2* or later if you are using outbound type `block`(preview).
    - If you don't already have the `aks-preview` extension, install it using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command. 

        ```azurecli
        az extension add --name aks-preview
        ```
    - If you already have the `aks-preview` extension, update it to make sure you have the latest version using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command. 

        ```azurecli
        az extension update --name aks-preview
        ```

::: zone-end

- Network isolated clusters are supported on AKS clusters using Kubernetes version 1.30 or higher.
- If you're choosing to use the Bring your own (BYO) Azure Container Registry (ACR) option, you need to ensure the ACR is [Premium SKU service tier](/en-us/azure/container-registry/container-registry-skus).
- If you're using a network isolated cluster configured with API Server VNet Integration, follow the prerequisites and guidance in [Use API Server VNet Integration with Azure Kubernetes Service](api-server-vnet-integration).

::: zone pivot="aks-managed-acr,byo-acr"

### Set environment variables

Set the environment variables used throughout this article. The ACR name must be globally unique and contain only lowercase alphanumeric characters.

```azurecli
RESOURCE_GROUP="myResourceGroup"
LOCATION="eastus"
AKS_NAME="myAKSCluster"
VNET_NAME="myVNet"
AKS_SUBNET_NAME="aksSubnet"
ACR_SUBNET_NAME="acrSubnet"
APISERVER_SUBNET_NAME="apiServerSubnet"
REGISTRY_NAME="myregistry${RANDOM}"
CLUSTER_IDENTITY_NAME="clusterIdentity"
KUBELET_IDENTITY_NAME="kubeletIdentity"

az group create --name ${RESOURCE_GROUP} --location ${LOCATION}
```

::: zone-end

::: zone pivot="terraform"

- An Azure account with an active subscription. If you don't have one, create a [free account](https://azure.microsoft.com/free/) before you begin.
- [Install and configure Terraform](/en-us/azure/developer/terraform/quickstart-configure).
- Azure CLI installed and signed in by using `az login`, used to verify the deployment and connect to the cluster. [Install Azure CLI](/en-us/cli/azure/install-azure-cli) if you don't already have it.
- `kubectl` installed to connect to the cluster. If you use Azure Cloud Shell, `kubectl` is already installed. To install it locally, use the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.
- [`jq`](https://jqlang.org/download/) installed, used to parse Terraform state when verifying the deployment. Azure Cloud Shell already has `jq` installed.

::: zone-end

::: zone pivot="aks-managed-acr"

## Deploy a network isolated cluster with AKS-managed ACR

AKS creates, manages, and reconciles an ACR resource in this option. You don't need to assign any permissions or manage the ACR. AKS manages the cache rules, private link, and private endpoint used in the network isolated cluster.

### Create a network isolated cluster

When creating a network isolated AKS cluster, choose one of the following private cluster modes: private link-based or API Server VNet Integration.

Set the artifact source and outbound type based on your network isolation requirements.

| Parameter | Accepted values / effect |
| --- | --- |
| `--bootstrap-artifact-source` | `Direct` pulls images directly from Microsoft Artifact Registry (MAR) and isn't network isolated. `Cache` pulls images from a private ACR and is network isolated. |
| `--outbound-type` | `none` doesn't configure outbound connections for the cluster, so you can configure them. `block` (preview) blocks all outbound connections. |

#### Private link-based

Create a private link-based network isolated cluster by running the [az aks create](/en-us/cli/azure/aks#az-aks-create) command with `--bootstrap-artifact-source`, `--enable-private-cluster`, and `--outbound-type` parameters.

```azurecli
az aks create --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --bootstrap-artifact-source Cache --outbound-type none --network-plugin azure --enable-private-cluster
```

#### API Server VNet Integration

Create a network isolated cluster configured with API Server VNet Integration by running the [az aks create](/en-us/cli/azure/aks#az-aks-create) command with `--bootstrap-artifact-source`, `--enable-private-cluster`, `--enable-apiserver-vnet-integration` and `--outbound-type` parameters.

```azurecli
az aks create --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --bootstrap-artifact-source Cache --outbound-type none --network-plugin azure --enable-private-cluster --enable-apiserver-vnet-integration
```

### Update an existing AKS cluster to network isolated type

If you'd rather enable network isolation on an existing AKS cluster instead of creating a new cluster, use the [az aks update](/en-us/cli/azure/aks#az-aks-update) command.

To enable the network isolated feature on an existing AKS cluster, first run the following command to update `bootstrap-artifact-source`:

```azurecli
az aks update --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --bootstrap-artifact-source Cache
```

Then you need to manually reimage all the existing node pools:

```azurecli
az aks upgrade --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --node-image-only
```

Note

You need to ensure the outbound exists until the first reimage completes. To check if the reimage completes, run:

```azurecli
NODEPOOLS=$(az aks nodepool list \
--resource-group "${RESOURCE_GROUP}" \
--cluster-name "${AKS_NAME}" \
--query "[].name" -o tsv)
for NODEPOOL in $NODEPOOLS; do
echo "Waiting for node pool $NODEPOOL to finish upgrading..."
az aks nodepool wait \
--resource-group "${RESOURCE_GROUP}" \
--cluster-name "${AKS_NAME}" \
--name "$NODEPOOL" \
--updated
echo "Node pool $NODEPOOL upgrade succeeded."
done
```

Wait and ensure the reimage completes, then run the following command to update `outbound-type`:

```azurecli
az aks update --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --outbound-type none
```

Important

Remember to reimage the cluster's node pools instantly after you update the artifact source to Cache. Otherwise, the feature won't take effect for the cluster.

::: zone-end

::: zone pivot="byo-acr"

## Deploy a network isolated cluster with bring your own ACR

AKS supports bringing your own (BYO) ACR. To support the BYO ACR scenario, you have to configure an ACR private endpoint and a private DNS zone before you create the AKS cluster.

The following steps show how to prepare these resources:

- Custom virtual network and subnets for AKS and ACR.
- ACR, ACR cache rule, private endpoint, and private DNS zone.
- Custom control plane identity and kubelet identity.

### Step 1: Create the virtual network and subnets

```azurecli
az network vnet create  --resource-group ${RESOURCE_GROUP} --name ${VNET_NAME} --address-prefixes 192.168.0.0/16

az network vnet subnet create --name ${AKS_SUBNET_NAME} --vnet-name ${VNET_NAME} --resource-group ${RESOURCE_GROUP} --address-prefixes 192.168.1.0/24

SUBNET_ID=$(az network vnet subnet show --name ${AKS_SUBNET_NAME} --vnet-name ${VNET_NAME} --resource-group ${RESOURCE_GROUP} --query 'id' --output tsv)

az network vnet subnet create --name ${ACR_SUBNET_NAME} --vnet-name ${VNET_NAME} --resource-group ${RESOURCE_GROUP} --address-prefixes 192.168.2.0/24 --private-endpoint-network-policies Disabled
```

### Step 2: Disable virtual network outbound connectivity (Optional)

For example, make the AKS subnet private by setting its default outbound access to `false`.

```azurecli
az network vnet subnet update --resource-group ${RESOURCE_GROUP} --vnet-name ${VNET_NAME} --name ${AKS_SUBNET_NAME} --default-outbound false
```

For other supported methods and transition considerations, see [Disable virtual network outbound connectivity](/en-us/azure/virtual-network/ip-services/default-outbound-access#how-can-i-transition-to-an-explicit-method-of-public-connectivity-and-disable-default-outbound-access).

### Step 3: Create the ACR and enable artifact cache

1. Create the ACR with public network access disabled.

    ```azurecli
    az acr create --resource-group ${RESOURCE_GROUP} --name ${REGISTRY_NAME} --sku Premium --public-network-enabled false
    
    REGISTRY_ID=$(az acr show --name ${REGISTRY_NAME} -g ${RESOURCE_GROUP}  --query 'id' --output tsv)
    ```
2. Create an ACR cache rule by using the following command to allow users to cache MAR container images and binaries in the new ACR. The cache rule name and repo names must follow the guidance in the next section.

    ```azurecli
    az acr cache create -n aks-managed-mcr -r ${REGISTRY_NAME} -g ${RESOURCE_GROUP} --source-repo "mcr.microsoft.com/*" --target-repo "aks-managed-repository/*"
    ```

Note

With BYO ACR, it is your responsibility to ensure the ACR cache rule is created and maintained correctly as above. This step is critical to cluster creation, functioning and upgrading. This cache rule should NOT be modified.

### Step 4: Create a private endpoint for the ACR

```azurecli
az network private-endpoint create --name myPrivateEndpoint --resource-group ${RESOURCE_GROUP} --vnet-name ${VNET_NAME} --subnet ${ACR_SUBNET_NAME} --private-connection-resource-id ${REGISTRY_ID} --group-id registry --connection-name myConnection

NETWORK_INTERFACE_ID=$(az network private-endpoint show --name myPrivateEndpoint --resource-group ${RESOURCE_GROUP} --query 'networkInterfaces[0].id' --output tsv)

REGISTRY_PRIVATE_IP=$(az network nic show --ids ${NETWORK_INTERFACE_ID} --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry'].privateIPAddress" --output tsv)

DATA_ENDPOINT_PRIVATE_IP=$(az network nic show --ids ${NETWORK_INTERFACE_ID} --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='registry_data_$LOCATION'].privateIPAddress" --output tsv)
```

### Step 5: Create a private DNS zone and add records

Create a private DNS zone named `privatelink.azurecr.io`. Add the records for the registry REST endpoint `{REGISTRY_NAME}.azurecr.io`, and the registry data endpoint `{REGISTRY_NAME}.{LOCATION}.data.azurecr.io`.

```azurecli
az network private-dns zone create --resource-group ${RESOURCE_GROUP} --name "privatelink.azurecr.io"

az network private-dns link vnet create --resource-group ${RESOURCE_GROUP} --zone-name "privatelink.azurecr.io" --name MyDNSLink --virtual-network ${VNET_NAME} --registration-enabled false

az network private-dns record-set a create --name ${REGISTRY_NAME} --zone-name "privatelink.azurecr.io" --resource-group ${RESOURCE_GROUP}

az network private-dns record-set a add-record --record-set-name ${REGISTRY_NAME} --zone-name "privatelink.azurecr.io" --resource-group ${RESOURCE_GROUP} --ipv4-address ${REGISTRY_PRIVATE_IP}

az network private-dns record-set a create --name ${REGISTRY_NAME}.${LOCATION}.data --zone-name "privatelink.azurecr.io" --resource-group ${RESOURCE_GROUP}

az network private-dns record-set a add-record --record-set-name ${REGISTRY_NAME}.${LOCATION}.data --zone-name "privatelink.azurecr.io" --resource-group ${RESOURCE_GROUP} --ipv4-address ${DATA_ENDPOINT_PRIVATE_IP}
```

### Step 6: Create control plane and kubelet identities

#### Control plane identity

```azurecli
az identity create --name ${CLUSTER_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP}

CLUSTER_IDENTITY_RESOURCE_ID=$(az identity show --name ${CLUSTER_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP} --query 'id' -o tsv)

CLUSTER_IDENTITY_PRINCIPAL_ID=$(az identity show --name ${CLUSTER_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP} --query 'principalId' -o tsv)
```

#### Kubelet identity

```azurecli
az identity create --name ${KUBELET_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP}

KUBELET_IDENTITY_RESOURCE_ID=$(az identity show --name ${KUBELET_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP} --query 'id' -o tsv)

KUBELET_IDENTITY_PRINCIPAL_ID=$(az identity show --name ${KUBELET_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP} --query 'principalId' -o tsv)
```

If you're updating an existing AKS cluster, skip the preceding identity creation commands and retrieve the existing kubelet identity object ID:

```azurecli
KUBELET_IDENTITY_PRINCIPAL_ID=$(az aks show --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --query identityProfile.kubeletidentity.objectId -o tsv)
```

#### Grant ACR pull permissions to the kubelet identity

Check the registry's role assignment permissions mode and select the corresponding pull role. ABAC-enabled registries use the `Container Registry Repository Reader` role. Non-ABAC-enabled registries use the `AcrPull` role.

```azurecli
ROLE_ASSIGNMENT_MODE=$(az acr show --name ${REGISTRY_NAME} --resource-group ${RESOURCE_GROUP} --query roleAssignmentMode -o tsv)

if [[ "${ROLE_ASSIGNMENT_MODE}" == "rbac-abac" ]]; then
  ACR_PULL_ROLE="Container Registry Repository Reader"
else
  ACR_PULL_ROLE="AcrPull"
fi

az role assignment create --role "${ACR_PULL_ROLE}" --scope ${REGISTRY_ID} --assignee-object-id ${KUBELET_IDENTITY_PRINCIPAL_ID} --assignee-principal-type ServicePrincipal
```

After you configure these resources, you can proceed to create the network isolated AKS cluster with BYO ACR.

### Step 7: Create network isolated cluster using BYO ACR

When you create a network isolated cluster, choose one of the following private cluster modes: private link-based or API Server VNet Integration.

Set the artifact source and outbound type based on your network isolation requirements.

| Parameter | Accepted values / effect |
| --- | --- |
| `--bootstrap-artifact-source` | `Direct` pulls images directly from Microsoft Artifact Registry (MAR) and isn't network isolated. `Cache` pulls images from a private ACR and is network isolated. |
| `--outbound-type` | `none` doesn't configure outbound connections for the cluster, so you can configure them. `block` (preview) blocks all outbound connections. |

#### Private link-based

Create a private link-based network isolated cluster that accesses your ACR by running the [az aks create](/en-us/cli/azure/aks#az-aks-create) command with the required parameters.

```azurecli
az aks create --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --vnet-subnet-id ${SUBNET_ID} --assign-identity ${CLUSTER_IDENTITY_RESOURCE_ID} --assign-kubelet-identity ${KUBELET_IDENTITY_RESOURCE_ID} --bootstrap-artifact-source Cache --bootstrap-container-registry-resource-id ${REGISTRY_ID} --outbound-type none --network-plugin azure --enable-private-cluster
```

#### API Server VNet Integration

For a network isolated cluster configured with API Server VNet Integration, first create a subnet and assign the correct role with the following commands:

```azurecli
az network vnet subnet create --name ${APISERVER_SUBNET_NAME} --vnet-name ${VNET_NAME} --resource-group ${RESOURCE_GROUP} --address-prefixes 192.168.3.0/24 --delegations Microsoft.ContainerService/managedClusters

export APISERVER_SUBNET_ID=$(az network vnet subnet show --resource-group ${RESOURCE_GROUP} --vnet-name ${VNET_NAME} --name ${APISERVER_SUBNET_NAME} --query id -o tsv)
```

```azurecli
az role assignment create --scope ${APISERVER_SUBNET_ID} --role "Network Contributor" --assignee-object-id ${CLUSTER_IDENTITY_PRINCIPAL_ID} --assignee-principal-type ServicePrincipal

az role assignment create --scope ${SUBNET_ID} --role "Network Contributor" --assignee-object-id ${CLUSTER_IDENTITY_PRINCIPAL_ID} --assignee-principal-type ServicePrincipal
```

Create a private network isolated cluster configured with API Server VNet Integration and access your ACR by running the [az aks create](/en-us/cli/azure/aks#az-aks-create) command with the required parameters.

```azurecli
az aks create --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --vnet-subnet-id ${SUBNET_ID} --assign-identity ${CLUSTER_IDENTITY_RESOURCE_ID} --assign-kubelet-identity ${KUBELET_IDENTITY_RESOURCE_ID} --bootstrap-artifact-source Cache --bootstrap-container-registry-resource-id ${REGISTRY_ID} --outbound-type none --network-plugin azure --enable-private-cluster --enable-apiserver-vnet-integration --apiserver-subnet-id ${APISERVER_SUBNET_ID}
```

### Update an existing AKS cluster

If you'd rather enable network isolation on an existing AKS cluster instead of creating a new cluster, use the [az aks update](/en-us/cli/azure/aks#az-aks-update) command.

When creating the private endpoint and private DNS zone for the BYO ACR, use the existing virtual network and subnets of the existing AKS cluster. When you assign the appropriate ACR pull role to the kubelet identity, use the existing kubelet identity of the existing AKS cluster.

To enable the network isolated feature on an existing AKS cluster, first run the following command to update `bootstrap-artifact-source`:

```azurecli
az aks update --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --bootstrap-artifact-source Cache --bootstrap-container-registry-resource-id ${REGISTRY_ID}
```

Then you need to manually reimage all the existing node pools:

```azurecli
az aks upgrade --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --node-image-only
```

Note

You need to ensure the outbound exists until the first reimage completes. To check if the reimage completes, run:

```azurecli
NODEPOOLS=$(az aks nodepool list \
--resource-group "${RESOURCE_GROUP}" \
--cluster-name "${AKS_NAME}" \
--query "[].name" -o tsv)
for NODEPOOL in $NODEPOOLS; do
echo "Waiting for node pool $NODEPOOL to finish upgrading..."
az aks nodepool wait \
--resource-group "${RESOURCE_GROUP}" \
--cluster-name "${AKS_NAME}" \
--name "$NODEPOOL" \
--updated
echo "Node pool $NODEPOOL upgrade succeeded."
done
```

Wait and ensure the reimage completes, then run the following command to update `outbound-type`:

```azurecli
az aks update --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --outbound-type none
```

Important

Remember to reimage the cluster's node pools instantly after you update the artifact source to Cache. Otherwise, the feature won't take effect for the cluster.

### Update your ACR ID

You can update the private ACR used with a network isolated cluster. To identify the ACR resource ID, use the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

```azurecli
az aks show --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME}
```

Updating the ACR ID is performed by running the `az aks update` command with the `--bootstrap-artifact-source` and `--bootstrap-container-registry-resource-id` parameters.

```azurecli
az aks update --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --bootstrap-artifact-source Cache --bootstrap-container-registry-resource-id <new-byo-acr-resource-id>
```

When you update the ACR ID on an existing cluster, you need to manually reimage all existing nodes.

```azurecli
az aks upgrade --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --node-image-only
```

Important

Remember to reimage the cluster's node pools after you enable the network isolated cluster feature. Otherwise, the feature won't take effect for the cluster.

::: zone-end

::: zone pivot="terraform"

## Deploy a network-isolated cluster with Terraform

Note

The sample code for this article is in the [Azure Terraform GitHub repository](https://github.com/Azure/terraform/tree/master/quickstart/101-aks-network-isolated). You can view the [test results log for current and previous versions of Terraform](https://github.com/Azure/terraform/blob/master/quickstart/101-aks-network-isolated/TestRecord.md).

See more [articles and sample code showing how to use Terraform to manage Azure resources](/en-us/azure/terraform).

This Terraform sample deploys a network-isolated cluster by using the **AKS-managed ACR** option described earlier in this article. The AzureRM provider doesn't yet expose all of the network-isolated bootstrap settings that this sample uses, so the sample uses the AzAPI provider to deploy the managed cluster resource against the required API version. A Terraform sample for the bring your own (BYO) ACR option isn't currently available. To use BYO ACR, follow the Azure CLI guidance earlier in this article.

The sample deploys the following resources:

- A **resource group** (`Microsoft.Resources/resourceGroups`).
- A **network-isolated AKS cluster** (`Microsoft.ContainerService/managedClusters`) that uses:
    - A system-assigned managed identity.
    - A single system node pool with one `Standard_D2s_v3` node and autoscaling disabled.
    - The `azure` network plugin, with `outboundType` set to `none` so the cluster has no outbound network dependencies for bootstrapping.
    - `apiServerAccessProfile.enablePrivateCluster` set to `true`, which creates a private link-based private cluster.
    - `bootstrapProfile.artifactSource` set to `Cache`, so AKS creates, manages, and reconciles its own ACR cache to bootstrap the cluster instead of pulling directly from Microsoft Artifact Registry (MAR). As described earlier in this article, you don't need to create or manage this ACR yourself, and AKS handles the cache rules, private link, and private endpoint that the network-isolated cluster uses.

The cluster is created with the default Kubernetes version supported in the deployment region. To pin a specific version, add `kubernetesVersion` to the cluster's `properties` block in `main.tf`, and confirm the version is available in the region by using the [`az aks get-versions`](/en-us/cli/azure/aks#az-aks-get-versions) command.

1. Create a directory to test the sample Terraform code, and make it the current directory.
2. Create a file named `main.tf` and copy the following tested sample configuration into it.

    ```terraform
    terraform {
      required_version = ">= 1.6.0"
    
      required_providers {
        azapi = {
          source  = "Azure/azapi"
          version = "~> 2.0"
        }
        random = {
          source  = "hashicorp/random"
          version = "~> 3.6"
        }
      }
    }
    
    provider "azapi" {}
    
    resource "random_string" "suffix" {
      length  = 6
      upper   = false
      special = false
    }
    
    locals {
      location            = "westus2"
      resource_group_name = "rg-aks-network-isolated-${random_string.suffix.result}"
      aks_name            = "aks-netisolated-${random_string.suffix.result}"
      dns_prefix          = "aksnetiso${random_string.suffix.result}"
    }
    
    resource "azapi_resource" "resource_group" {
      type     = "Microsoft.Resources/resourceGroups@2024-03-01"
      name     = local.resource_group_name
      location = local.location
    }
    
    resource "azapi_resource" "aks_cluster" {
      type      = "Microsoft.ContainerService/managedClusters@2025-08-01"
      name      = local.aks_name
      parent_id = azapi_resource.resource_group.id
      location  = local.location
    
      identity {
        type = "SystemAssigned"
      }
    
      body = {
        properties = {
          dnsPrefix = local.dns_prefix
          agentPoolProfiles = [
            {
              name              = "systempool"
              count             = 1
              vmSize            = "Standard_D2s_v3"
              mode              = "System"
              osType            = "Linux"
              type              = "VirtualMachineScaleSets"
              enableAutoScaling = false
            }
          ]
          networkProfile = {
            networkPlugin = "azure"
            outboundType  = "none"
          }
          apiServerAccessProfile = {
            enablePrivateCluster = true
          }
          bootstrapProfile = {
            artifactSource = "Cache"
          }
        }
      }
    }
    ```

## Initialize Terraform

Run [`terraform init`](https://developer.hashicorp.com/terraform/cli/commands/init) to initialize the Terraform deployment. This command downloads the `azapi` and `random` providers required to manage the resources in this sample.

```console
terraform init -upgrade
```

## Format and validate the configuration

Run [`terraform fmt`](https://developer.hashicorp.com/terraform/cli/commands/fmt) to format the configuration file, and [`terraform validate`](https://developer.hashicorp.com/terraform/cli/commands/validate) to confirm the configuration is syntactically valid.

```console
terraform fmt
terraform validate
```

## Create a Terraform execution plan

Run [`terraform plan`](https://developer.hashicorp.com/terraform/cli/commands/plan) to create an execution plan.

```console
terraform plan -out main.tfplan
```

## Apply a Terraform execution plan

Run [`terraform apply`](https://developer.hashicorp.com/terraform/cli/commands/apply) to apply the execution plan to your Azure subscription.

```console
terraform apply main.tfplan
```

Creating the resource group and the private, network-isolated AKS cluster takes several minutes to complete.

## Verify the deployment

This sample doesn't define Terraform outputs, so use [`terraform show -json`](https://developer.hashicorp.com/terraform/cli/commands/show#json-output) with [`jq`](https://jqlang.org/) to retrieve the generated resource group and cluster names from the resource state after `terraform apply` completes. You manage both resources with the `azapi` provider, and their `name` attribute holds the resolved resource name.

```console
RESOURCE_GROUP=$(terraform show -json | jq -r '.values.root_module.resources[] | select(.address=="azapi_resource.resource_group") | .values.name')
AKS_NAME=$(terraform show -json | jq -r '.values.root_module.resources[] | select(.address=="azapi_resource.aks_cluster") | .values.name')
```

Confirm the cluster was created with the expected network isolated settings by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

```azurecli
az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --query "{outboundType:networkProfile.outboundType, artifactSource:bootstrapProfile.artifactSource, privateCluster:apiServerAccessProfile.enablePrivateCluster}"
```

The output shows `outboundType` set to `none`, `artifactSource` set to `Cache`, and `privateCluster` set to `true`, confirming the cluster is network isolated and bootstraps from the AKS-managed ACR cache.

## Connect to the cluster

Because this is a private cluster, connect from a client that has network line-of-sight to the cluster's private endpoint, such as a VM in the same or peered virtual network, or Azure Cloud Shell if it's connected to the cluster's virtual network. Get the cluster credentials by using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command, and then verify the connection by using the [`kubectl get nodes`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

```azurecli
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
kubectl get nodes
```

## Clean up resources

If you no longer need the resources created in this article, remove them to avoid incurring further charges.

Warning

Running `terraform destroy` removes every resource tracked in the Terraform state file for this configuration, including the resource group and the AKS cluster. Review the plan carefully before you destroy, and avoid running it against shared or production infrastructure.

Run [`terraform plan`](https://developer.hashicorp.com/terraform/cli/commands/plan) with the `-destroy` flag to review what Terraform removes.

```console
terraform plan -destroy -out main.destroy.tfplan
```

Run [`terraform apply`](https://developer.hashicorp.com/terraform/cli/commands/apply) to apply the destroy plan and remove all resources created by this sample.

```console
terraform apply main.destroy.tfplan
```

::: zone-end

## Validate that network isolated cluster is enabled on AKS

To validate the network isolated cluster feature is enabled, use the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command.

```azurecli
az aks show --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME}
```

The following output shows a network isolated cluster configured with the `none` outbound type. Confirm that `outboundType` is set to `none` or `block`, and that `artifactSource` is set to `Cache`. The `containerRegistryId` field identifies the ACR used for bootstrapping.

```json
{
  "kubernetesVersion": "<major>.<minor>.<patch>",
  "name": "myAKSCluster",
  "type": "Microsoft.ContainerService/ManagedClusters",
  "properties": {
    "networkProfile": {
      "outboundType": "none"
    },
    "bootstrapProfile": {
      "artifactSource": "Cache",
      "containerRegistryId": "/subscriptions/my-subscription-id/resourceGroups/my-node-resource-group-name/providers/Microsoft.ContainerRegistry/registries/my-registry-name"
    }
  }
}
```

## Disable network isolated cluster on AKS

Disable the network isolated cluster feature by running the `az aks update` command with the `--bootstrap-artifact-source` and `--outbound-type` parameters.

```azurecli
az aks update --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --bootstrap-artifact-source Direct --outbound-type LoadBalancer
```

When you disable the feature on an existing cluster, you need to manually reimage all existing nodes.

```azurecli
az aks upgrade --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --node-image-only
```

Important

Remember to reimage the cluster's node pools after you disable the network isolated cluster feature. Otherwise, the feature won't take effect for the cluster.

## Troubleshooting

If you're experiencing issues, such as image pull fails, see [Troubleshoot network isolated Azure Kubernetes Service (AKS) clusters issues](/en-us/troubleshoot/azure/azure-kubernetes/extensions/troubleshoot-network-isolated-cluster).