---
layout: Conceptual
title: Enable Federal Information Processing Standard (FIPS) for Azure Kubernetes Service (AKS) clusters (preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/enable-fips-cluster
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
description: Learn how to enable Federal Information Processing Standard (FIPS) at the cluster level for Azure Kubernetes Service (AKS) clusters.
author: everjing
ms.author: gaojing
ms.topic: how-to
ms.subservice: aks-security
ms.date: 2026-10-22T00:00:00.0000000Z
ms.custom: template-how-to, devx-track-azurecli, linux-related-content
ai-usage: ai-assisted
locale: en-us
document_id: 72d60e4f-d50d-7531-6b16-f4db15f74892
document_version_independent_id: 7b0f5216-0927-bfcc-9998-e0bd06553f66
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/enable-fips-cluster.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/enable-fips-cluster
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/enable-fips-cluster.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: dcc17ae0-e017-9d29-4291-78c2bfbc090e
---

# Enable Federal Information Processing Standard (FIPS) for Azure Kubernetes Service (AKS) clusters (preview) - Azure Kubernetes Service | Microsoft Learn

The Federal Information Processing Standard (FIPS) is a US government standard that defines minimum security requirements for cryptographic modules in information technology products and systems. This article describes how to enable FIPS mode at the **cluster level** for Azure Kubernetes Service (AKS). Cluster-level FIPS enforces that every node pool in the cluster uses a FIPS-enabled OS image, and it blocks AKS-managed [components](aks-component-versioning#aks-components-overview) that aren't FIPS-compliant. This capability is intended for customers with compliance requirements such as FedRAMP who need a single, declarative way to ensure FIPS usage across their AKS cluster. For more information on FIPS, see [Federal Information Processing Standard (FIPS) 140](/en-us/azure/compliance/offerings/offering-fips-140-2).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## What is FIPS mode in AKS?

FIPS 140-2/140-3 defines U.S. government standards for cryptographic modules. When you enable FIPS mode on an AKS cluster:

- All **node pools** in the cluster, including Windows node pools, must use FIPS-enabled OS images.
- AKS blocks creation of **non-FIPS node pools**.
- AKS blocks **AKS-managed add-ons, features, and extensions** that aren't validated for FIPS compliance.

Cluster-level FIPS (`properties.enableFIPS`) is separate from FIPS on individual node pools (`enableFIPS` on each agent pool). Cluster-level FIPS requires every node pool to be FIPS-enabled, but disabling cluster-level FIPS doesn't disable FIPS on your node pools. For more information about FIPS-enabled node pools, see [Enable FIPS for AKS node pools](enable-fips-nodes).

Important

FIPS mode applies to **AKS-managed infrastructure and components**. Customers remain responsible for ensuring their **own application containers** use FIPS-compliant cryptography.

## Prerequisites

- An active Azure subscription. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.
- Azure CLI version 2.86.0 or later installed and configured. To find the version, run `az --version`. For more information about installing or upgrading the Azure CLI, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- The latest version of the `aks-preview` Azure CLI extension. The `--enable-fips` and `--disable-fips` parameters are available only in the `aks-preview` extension. For instructions, see Install the `aks-preview` Azure CLI extension.
- The `k8s-extension` Azure CLI extension, used to list and remove cluster extensions. Install it by running `az extension add --upgrade --name k8s-extension`.
- [kubectl](https://kubernetes.io/releases/download/) installed. You can install it locally by using the [`az aks install-cli`](/en-us/cli/azure/aks#az-aks-install-cli) command.
- The `EnableFIPSPreview` feature flag registered on your subscription. For instructions, see Register the `EnableFIPSPreview` feature flag.
- Kubernetes version 1.35.0 or later. To see the versions available in your region, use the [`az aks get-versions`](/en-us/cli/azure/aks#az-aks-get-versions) command. A FIPS-enabled cluster on an earlier version isn't grandfathered: AKS rejects every update to the cluster until you upgrade it to 1.35.0 or later or disable FIPS.
- If you use Azure Resource Manager (ARM) templates or the REST API, use API version `2026-03-02-preview` or later for `Microsoft.ContainerService/managedClusters` and `Microsoft.ContainerService/managedClusters/agentPools`.

### Install the `aks-preview` Azure CLI extension

1. Install the `aks-preview` extension by using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension by using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    az extension update --name aks-preview
    ```

### Set environment variables

Set the following environment variables for the resources that you use in this article. Replace the placeholder values with your own. Then set your subscription context by using the [`az account set`](/en-us/cli/azure/account#az-account-set) command.

```azurecli
export SUBSCRIPTION_ID="<subscription-id>"
export RESOURCE_GROUP="myResourceGroup"
export CLUSTER_NAME="myAKSCluster"
export NODE_POOL_NAME="fipsnp"

az account set --subscription $SUBSCRIPTION_ID
```

### Register the `EnableFIPSPreview` feature flag

1. Register the `EnableFIPSPreview` feature flag by using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "EnableFIPSPreview"
    ```

    It takes a few minutes for the status to show *Registered*.
2. Verify the registration status by using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show --namespace "Microsoft.ContainerService" --name "EnableFIPSPreview"
    ```
3. When the status shows *Registered*, refresh the registration of the `Microsoft.ContainerService` resource provider by using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

## Limitations

The following limitations apply when using FIPS-enabled AKS clusters.

- Some AKS-managed components aren't FIPS-compliant and are blocked on FIPS-enabled clusters. For the list, see Blocked components.
- Node pools that use a Kata workload runtime (`KataVmIsolation`, `KataMshvVmIsolation`, or `KataCcIsolation`) aren't supported.
- Node pools that use the preview node pool–level custom CA trust setting (`enableCustomCATrust`) aren't supported. Use [cluster-level custom certificate authority trust](custom-certificate-authority) instead.
- All limitations documented for FIPS-enabled node pools also apply to FIPS-enabled clusters, including OS, image, and upgrade constraints. For details, see [Enable Federal Information Processing Standard (FIPS) for Azure Kubernetes Service (AKS) node pools](enable-fips-nodes).

### Blocked components

Some AKS-managed components aren't yet built with FIPS-compliant cryptographic libraries. You can't enable these components on a FIPS-enabled cluster, and you can't enable FIPS on a cluster that uses them. The following table lists the blocked components and the Azure CLI command to disable each one. Add `--resource-group $RESOURCE_GROUP --name $CLUSTER_NAME` to each `az aks` command.

Important

This list applies only to AKS-managed components. Customer application containers aren't validated by AKS.

| Blocked component | Disable command |
| --- | --- |
| [`cost-analysis`](cost-analysis) | `az aks update --disable-cost-analysis` |
| [`approuting`](app-routing) | `az aks approuting disable` |
| [`defender`](/en-us/azure/defender-for-cloud/defender-for-containers-azure-enable-programmatically) (Microsoft Defender for Containers security monitoring) | `az aks update --disable-defender` |
| [`azure-monitor`](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable) (managed Prometheus metrics, Container insights, and application monitoring) | `az aks update --disable-azure-monitor-metrics``az aks disable-addons --addons monitoring``az aks update --disable-azure-monitor-app-monitoring` |
| [`blob-csi`](csi-storage-drivers) | `az aks update --disable-blob-driver` |
| [`ACCSGXDevicePlugin`](/en-us/azure/confidential-computing/confidential-nodes-aks-addon) | `az aks disable-addons --addons confcom` |
| [`IngressApplicationGateway`](/en-us/azure/application-gateway/ingress-controller-overview) | `az aks disable-addons --addons ingress-appgw` |
| [`calico`](use-network-policies#create-an-aks-cluster-with-calico), [`azure-npm`](use-network-policies#create-an-aks-cluster-with-azure-network-policy-manager-linux) | `az aks update --network-policy none` |
| [`cilium`](azure-cni-powered-by-cilium) | You can't remove Cilium from an existing cluster. Create a new cluster. |
| [`acns-observability`](container-network-observability-how-to) | `az aks update --disable-acns` or `az aks update --disable-acns-observability` |
| [`OpenServiceMesh`](open-service-mesh-about) | `az aks disable-addons --addons open-service-mesh` |
| [`kaito`](ai-toolchain-operator) | `az aks update --disable-ai-toolchain-operator` |
| [Istio-based service mesh add-on](istio-about) revisions earlier than `asm-1-26` | Upgrade to revision `asm-1-26` or later. For instructions, see [Upgrade the Istio-based service mesh add-on](istio-upgrade). |
| [Windows GPU driver installation](use-windows-gpu#skip-gpu-driver-installation) | To add a Windows GPU node pool, skip driver installation by using `--gpu-driver none`. |
| Cluster extensions that aren't FIPS-compliant, such as Flux (GitOps). See the **FIPS** column in the [extension capability matrix](cluster-extensions#extension-capability-matrix). | `az k8s-extension delete --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --cluster-type managedClusters --name <extension-name>` |

If an automation, such as an Azure Policy assignment, tries to install an extension that isn't FIPS-compliant on a FIPS-enabled cluster, AKS rejects the installation and the extension shows a `Failed` provisioning state. The cluster isn't affected.

## Create a FIPS-enabled AKS cluster

You can enable FIPS when you create the cluster by using the `--enable-fips` flag. The cluster can't use any of the blocked components.

1. Create a FIPS-enabled AKS cluster by using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) command with the `--enable-fips` parameter.

    ```azurecli
    az aks create \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --kubernetes-version 1.35 \
        --enable-fips \
        --generate-ssh-keys
    ```
2. Verify your cluster is FIPS-enabled by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command and query for the *enableFips* value.

    ```azurecli
    az aks show \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --query "enableFips"
    ```

    The following example output shows your cluster is FIPS-enabled:

    ```output
    true
    ```

    If the command doesn't return `true`, you didn't install the `aks-preview` extension when you created the cluster. Without the extension, the Azure CLI treats `--enable-fips` as `--enable-fips-image` and enables FIPS only on the default node pool. Install the `aks-preview` extension, and then enable FIPS on the existing cluster.
3. Creating a FIPS-enabled cluster automatically creates a FIPS-enabled node pool. You can verify this by inspecting the node pool configuration by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command and query for the *enableFips* value in *agentPoolProfiles*.

    ```azurecli
    az aks show \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --query "agentPoolProfiles[].{Name:name, enableFips:enableFips}" \
        --output table
    ```

    The following example output shows the default node pool is FIPS-enabled:

    ```output
    Name       EnableFips
    ---------  ----------
    nodepool1  True
    ```

## Update an existing AKS cluster to enable or disable FIPS

To enable FIPS on an existing cluster, prepare the cluster first, and then update it.

### Prepare your cluster for FIPS

Complete the following steps before you enable FIPS at the cluster level.

1. Make sure the cluster runs **Kubernetes version 1.35.0 or later**. If your cluster is running an earlier version, upgrade the cluster first. For instructions, see [Upgrade an AKS cluster](upgrade-aks-control-plane).
2. Make sure every node pool is FIPS-enabled. Update each **non-FIPS node pool** to use FIPS-enabled images. For instructions, see [Update an existing node pool to enable or disable FIPS](enable-fips-nodes#update-an-existing-node-pool-to-enable-or-disable-fips).

    Windows Server 2022 node pools already run with FIPS enabled in the OS, but their `enableFips` property is `False` unless you set it. Run `az aks nodepool update --enable-fips-image` on these node pools too. For these node pools, the update sets the property and doesn't change the node image.
3. Disable or remove every component that's listed in Blocked components, including cluster extensions that aren't FIPS-compliant. To list the extensions on your cluster, use the [`az k8s-extension list`](/en-us/cli/azure/k8s-extension#az-k8s-extension-list) command. To remove an extension, use the [`az k8s-extension delete`](/en-us/cli/azure/k8s-extension#az-k8s-extension-delete) command. For more information, see [Manage AKS extensions](cluster-extensions).

    ```azurecli
    az k8s-extension list \
        --resource-group $RESOURCE_GROUP \
        --cluster-name $CLUSTER_NAME \
        --cluster-type managedClusters \
        --query "[].{name:name, extensionType:extensionType, state:provisioningState}" \
        --output table
    ```

    Note

    An extension can be installed automatically after cluster creation, for example by an Azure Policy assignment. List the extensions again right before you enable FIPS. If an assignment keeps installing an extension that isn't FIPS-compliant, exempt the cluster from that assignment.

### Update an existing cluster to enable FIPS

After you prepare your cluster, enable FIPS. If the cluster doesn't meet a requirement, AKS rejects the update, and the error message describes the cause. For help, see Troubleshoot cluster-level FIPS errors.

1. Update an AKS cluster by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--enable-fips` parameter.

    ```azurecli
    az aks update \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --enable-fips
    ```
2. Verify your cluster is FIPS-enabled by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command and query for the *enableFips* value.

    ```azurecli
    az aks show \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --query "enableFips"
    ```

    The following example output shows your cluster is FIPS-enabled:

    ```output
    true
    ```

### Update an existing cluster to disable FIPS

You can update an existing cluster to disable FIPS. When you disable FIPS mode:

- Cluster-level FIPS enforcement is removed.
- Existing node pools aren't modified.
- You can run both FIPS and non-FIPS node pools in the same cluster.
- You can deploy AKS extensions and add-ons that were previously blocked while FIPS was enabled.
- New node pools are no longer required to be FIPS-enabled.

Note

Disabling FIPS doesn't automatically convert FIPS-enabled node pools to non-FIPS. If needed, you can update node pools individually. For instructions, see [Disable FIPS on an existing node pool](enable-fips-nodes#disable-fips-on-an-existing-node-pool). Windows Server 2025 node pools can't disable FIPS.

1. Update an AKS cluster by using the [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the `--disable-fips` parameter.

    ```azurecli
    az aks update \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --disable-fips
    ```
2. Verify your cluster isn't FIPS-enabled by using the [`az aks show`](/en-us/cli/azure/aks#az-aks-show) command and query for the *enableFips* value.

    ```azurecli
    az aks show \
        --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --query "enableFips"
    ```

    The following example output shows your cluster isn't FIPS-enabled:

    ```output
    false
    ```

## Add a node pool to a FIPS-enabled AKS cluster

Every new node pool in a FIPS-enabled cluster must be FIPS-enabled. Add a node pool by using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-add) command with the `--enable-fips-image` parameter. If you omit `--enable-fips-image`, AKS rejects the request.

```azurecli
az aks nodepool add \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --name $NODE_POOL_NAME \
    --enable-fips-image
```

## Troubleshoot cluster-level FIPS errors

When a request conflicts with cluster-level FIPS, AKS rejects it, usually with a `BadRequest` error that describes the cause. For common error messages and how to resolve them, see [Troubleshoot cluster-level FIPS errors in AKS](/en-us/troubleshoot/azure/azure-kubernetes/security/troubleshoot-cluster-level-fips).

## Clean up resources

When you no longer need the resources you created in this article, delete the resource group and all related resources by using the [`az group delete`](/en-us/cli/azure/group#az-group-delete) command.

```azurecli
az group delete --name $RESOURCE_GROUP --yes --no-wait
```