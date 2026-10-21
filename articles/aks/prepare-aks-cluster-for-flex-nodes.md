---
layout: Conceptual
title: Prepare an AKS cluster for flex nodes (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/prepare-aks-cluster-for-flex-nodes
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
description: Learn how to prepare a public or private AKS cluster, save its resource ID, and verify API server access for flex nodes.
ms.topic: how-to
ms.date: 2026-09-22T00:00:00.0000000Z
author: leslielin-5
ms.author: leslielin
ms.subservice: aks-nodes
ai-usage: ai-assisted
locale: en-us
document_id: d577bc81-b684-07b3-3730-cb1b681dc6c1
document_version_independent_id: 5c8b1c10-4799-5d2c-cf44-ef9bee2588f8
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/prepare-aks-cluster-for-flex-nodes.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/prepare-aks-cluster-for-flex-nodes
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/prepare-aks-cluster-for-flex-nodes.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 8e1c506b-5c74-5c4b-9259-b071ab481550
---

# Prepare an AKS cluster for flex nodes (preview) - Azure Kubernetes Service | Microsoft Learn

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Before you add flex nodes, prepare a compatible Azure Kubernetes Service (AKS) cluster and verify access to its Kubernetes API server. The AKS cluster can use public or private API access.

Run the commands in this article in a Linux-compatible Bash environment that has the required tools and network access. This article calls that environment your **Bash environment**. The separate machine that joins the cluster is the **flex node host**.

In this article, you:

- Load the deployment values from the environment file.
- Install the required preview Azure CLI extension and register the preview features.
- Create a public or private AKS cluster.
- Record the AKS resource ID and verify authenticated API access.

## Before you begin

- Complete [Plan flex nodes for AKS](plan-flex-nodes-deployment), including the address plan and environment file.
- Use an Azure subscription that's approved for the flex nodes preview.
- Use an account with permission to register subscription features and resource providers and to create the AKS cluster.
- Install the Azure CLI, `kubectl`, and `getent` in your Bash environment.
- Ensure your account can retrieve AKS cluster administrator credentials.
- Prepare the resource group, virtual network, and AKS subnet recorded in the environment file.
- For private AKS API access, ensure that your Bash environment runs on a machine in the AKS virtual network or a connected network that can resolve and reach the private API endpoint.

## Load the deployment environment

1. Start a new Bash session and identify the environment file that you created in the preceding article. Replace `<deployment-name>` with your deployment label.

    ```bash
    export FLEXNODE_DEPLOYMENT="<deployment-name>"
    export FLEXNODE_ENV_FILE="${HOME}/.config/aks-flexnode/${FLEXNODE_DEPLOYMENT}.env"
    ```
2. Load the environment file and prepare the protected working directory.

    ```bash
    test -s "${FLEXNODE_ENV_FILE}"
    source "${FLEXNODE_ENV_FILE}"
    install -d -m 0700 "${WORK_DIR:?Load the deployment environment first.}"
    ```

    The environment file supplies the shared deployment values that this article reads, including `WORK_DIR`, the directory in your Bash environment where this article stores downloads and generated files. By default, `WORK_DIR` is `~/.local/share/aksflexnode/<deployment-name>`. The article derives any other variables that it needs. If you didn't create the environment file yet, complete [Plan your flex nodes deployment](plan-flex-nodes-deployment) first.

    Stop if the file isn't found or the shell reports an error while loading it.
3. Set and verify the active Azure subscription.

    ```azurecli
    az account set --subscription "${SUBSCRIPTION_ID}"
    az account show \
        --query "{Name:name,SubscriptionId:id}" \
        --output table
    ```

    Confirm that **SubscriptionId** matches `SUBSCRIPTION_ID`.

## Install the preview Azure CLI extension

The environment file contains the `aks-preview` extension version published for this flex nodes release.

1. Install the minimum `aks-preview` extension version `22.0.0b8`.

    ```azurecli
    az extension add \
        --name aks-preview \
        --allow-preview true \
        --version "${AKS_PREVIEW_VERSION}" \
        --upgrade
    ```
2. Verify the installed version.

    ```azurecli
    az extension show \
        --name aks-preview \
        --query version \
        --output tsv
    ```

    Confirm that the returned version matches `AKS_PREVIEW_VERSION`, which should be `22.0.0b8` or later.

## Register the preview features

Register the preview features once for each subscription.

1. Register the `AKSFlexNodePreview` and `PutMachinePreview` features.

    ```azurecli
    az feature register \
        --namespace Microsoft.ContainerService \
        --name AKSFlexNodePreview
    
    az feature register \
        --namespace Microsoft.ContainerService \
        --name PutMachinePreview
    ```
2. Registration can take several minutes. Check the registration state:

    ```azurecli
    az feature show \
        --namespace Microsoft.ContainerService \
        --name AKSFlexNodePreview \
        --query properties.state \
        --output tsv
    
    az feature show \
        --namespace Microsoft.ContainerService \
        --name PutMachinePreview \
        --query properties.state \
        --output tsv
    ```

    Rerun the commands until both return `Registered`.
3. Refresh the `Microsoft.ContainerService` resource provider registration.

    ```azurecli
    az provider register \
        --namespace Microsoft.ContainerService \
        --wait
    ```
4. Verify the resource provider registration.

    ```azurecli
    az provider show \
        --namespace Microsoft.ContainerService \
        --query registrationState \
        --output tsv
    ```

    Continue when the command returns `Registered`.

## Create or select an AKS cluster

The following examples create one Azure-managed system node and use the address values recorded in the environment file. The cluster is created with `networkPlugin=none`; the next article installs Unbounded-Net on the AKS-managed nodes and flex nodes.

You can attach flex nodes to a new or existing public or private AKS cluster, including an existing cluster that uses Azure CNI or Azure CNI powered by Cilium. The AKS-managed network plugin and its capabilities don't extend to flex nodes. This walkthrough creates a new cluster without a built-in network plugin and uses Unbounded-Net on both node types. For an existing cluster, confirm that its Kubernetes version is compatible with `AKS_FLEX_NODE_VERSION` and use a compatible customer-managed CNI for the flex nodes.

### Check the system node VM size and quota

`AKS_NODE_VM_SIZE` sets the Azure-managed system node size, not the flex node host. Check that the SKU is available in the selected region:

```azurecli
az vm list-skus \
    --location "${LOCATION}" \
    --resource-type virtualMachines \
    --all \
    --query "[?name=='${AKS_NODE_VM_SIZE}'] | [0].{Name:name,Family:family,Restrictions:restrictions[].reasonCode}" \
    --output json

az vm list-usage \
    --location "${LOCATION}" \
    --output table
```

Continue only when Azure returns the selected SKU without a location or subscription restriction and the regional and VM-family quotas have enough remaining vCPUs for the system node pool. In the usage table, check the **Total Regional vCPUs** row and the row for the returned VM family. If you need more quota, see [View quotas](/en-us/azure/quotas/view-quotas).

Check `AKS_API_ACCESS` in the environment file and run the matching tab. Use **Public cluster** when the value is `public` and **Private cluster** when the value is `private`.

# [Public cluster](#tab/public-cluster)
Create a public AKS cluster without a built-in network plugin or SSH access to the AKS-managed nodes:

```azurecli
az aks create \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --location "${LOCATION}" \
    --kubernetes-version "${AKS_VERSION}" \
    --nodepool-name systempool \
    --node-count 1 \
    --node-vm-size "${AKS_NODE_VM_SIZE}" \
    --network-plugin none \
    --pod-cidr "${AKS_POD_CIDR}" \
    --vnet-subnet-id "${AKS_SUBNET_ID}" \
    --service-cidr "${SERVICE_CIDR}" \
    --dns-service-ip "${DNS_SERVICE_IP}" \
    --enable-managed-identity \
    --ssh-access disabled \
    --no-ssh-key \
    --output none
```

# [Private cluster](#tab/private-cluster)
Create the same cluster with a private API endpoint:

```azurecli
az aks create \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --location "${LOCATION}" \
    --kubernetes-version "${AKS_VERSION}" \
    --nodepool-name systempool \
    --node-count 1 \
    --node-vm-size "${AKS_NODE_VM_SIZE}" \
    --network-plugin none \
    --enable-private-cluster \
    --disable-public-fqdn \
    --private-dns-zone system \
    --pod-cidr "${AKS_POD_CIDR}" \
    --vnet-subnet-id "${AKS_SUBNET_ID}" \
    --service-cidr "${SERVICE_CIDR}" \
    --dns-service-ip "${DNS_SERVICE_IP}" \
    --enable-managed-identity \
    --ssh-access disabled \
    --no-ssh-key \
    --output none
```

This command uses the AKS-managed private DNS zone. AKS links the zone to the virtual network that contains the AKS nodes. If your Bash environment or flex node hosts use another network, provide both a private route to the cluster virtual network and DNS resolution for the private API FQDN. The route can use virtual network peering, VPN, or ExpressRoute. DNS can use a virtual network link, DNS forwarding, or Azure DNS Private Resolver. Ensure that network controls on the path permit HTTPS to the private endpoint. For more information, see [Create a private AKS cluster](private-clusters) and [Connect to a private AKS cluster](private-cluster-connect).

---

Verify the new cluster configuration:

```azurecli
az aks show \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --query '{Name:name,PrivateCluster:(apiServerAccessProfile.enablePrivateCluster || `false`),KubernetesVersion:(currentKubernetesVersion || kubernetesVersion),NetworkPlugin:networkProfile.networkPlugin,PodCIDR:networkProfile.podCidr,ServiceCIDR:networkProfile.serviceCidr,DnsServiceIP:networkProfile.dnsServiceIp}' \
    --output table
```

Confirm the following values:

| Output | Required value |
| --- | --- |
| **PrivateCluster** | `false` when `AKS_API_ACCESS` is `public`, or `true` when `AKS_API_ACCESS` is `private` |
| **KubernetesVersion** | The value of `AKS_VERSION` |
| **NetworkPlugin** | `none` |
| **PodCIDR** | The value of `AKS_POD_CIDR` |
| **ServiceCIDR** | The value of `SERVICE_CIDR` |
| **DnsServiceIP** | The value of `DNS_SERVICE_IP` |

The AKS system node can remain `NotReady` until the next article installs Unbounded-Net.

## Get cluster credentials

Use a dedicated kubeconfig for this deployment so that you don't overwrite the default kubeconfig in your Bash environment.

1. Set the kubeconfig path and create a protected file.

    ```bash
    export FLEXNODE_KUBECONFIG="${WORK_DIR}/kubeconfig-${CLUSTER_NAME}"
    install -m 0600 /dev/null "${FLEXNODE_KUBECONFIG}"
    ```
2. Retrieve the AKS cluster administrator credentials.

    ```azurecli
    az aks get-credentials \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${CLUSTER_NAME}" \
        --admin \
        --file "${FLEXNODE_KUBECONFIG}" \
        --overwrite-existing
    ```
3. Verify the kubeconfig permissions.

    ```bash
    chmod 600 "${FLEXNODE_KUBECONFIG}"
    stat -c '%a %n' "${FLEXNODE_KUBECONFIG}"
    ```

    Confirm that the permission value is `600`.
4. Record the kubeconfig path in the environment file.

    ```bash
    set_flexnode_env FLEXNODE_KUBECONFIG "${FLEXNODE_KUBECONFIG}"
    ```

## Record the AKS cluster

Retrieve the AKS resource ID and Kubernetes version:

```azurecli
AKS_RESOURCE_ID="$(az aks show \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --query id \
    --output tsv)"
export AKS_RESOURCE_ID

az aks show \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --query "{ResourceId:id,KubernetesVersion:(currentKubernetesVersion || kubernetesVersion)}" \
    --output json
```

Confirm that **ResourceId** contains the full AKS resource ID and **KubernetesVersion** matches `AKS_VERSION`. Record the resource ID in the environment file:

```bash
set_flexnode_env AKS_RESOURCE_ID "${AKS_RESOURCE_ID}"
```

## Verify API endpoint resolution

Run the tab that matches the API access model selected in the environment file.

# [Public API access](#tab/public-api-access)
Retrieve the public API server FQDN:

```azurecli
AKS_API_FQDN="$(az aks show \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --query fqdn \
    --output tsv)"
export AKS_API_FQDN

getent hosts "${AKS_API_FQDN}"
```

Confirm that the FQDN resolves to an IP address. If the command returns no result, check DNS configuration in your Bash environment.

# [Private API access](#tab/private-api-access)
Retrieve and resolve the private API server FQDN:

```azurecli
AKS_API_FQDN="$(az aks show \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --query privateFqdn \
    --output tsv)"
export AKS_API_FQDN

getent hosts "${AKS_API_FQDN}"
```

Confirm that the FQDN resolves to a private IP address. If the command returns no result, check private DNS configuration for the network used by your Bash environment.

---

## Verify authenticated API access

List the AKS nodes:

```bash
kubectl \
    --kubeconfig "${FLEXNODE_KUBECONFIG}" \
    get nodes
```

The output lists the Azure-managed system node. The node can remain `NotReady` until you install Unbounded-Net. A successful response confirms authenticated API access; it doesn't confirm node or pod networking.

If the command returns `Unauthorized` or `Forbidden`, verify the retrieved credentials and your Kubernetes RBAC permission to list nodes. If the request times out, verify API FQDN resolution and HTTPS connectivity. For a private cluster, also check the route and network controls between your Bash environment and the cluster virtual network.