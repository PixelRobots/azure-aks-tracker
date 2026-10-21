---
layout: Conceptual
title: Deploy Cilium mTLS encryption with Advanced Container Networking Services - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/container-network-security-cilium-mutual-tls-how-to
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
description: Get started with Cilium mTLS encryption for Advanced Container Networking Services on your AKS cluster.
author: JosephYostos
ms.author: josephyostos
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2026-03-16T00:00:00.0000000Z
ms.custom: template-how-to-pattern, devx-track-azurecli
locale: en-us
document_id: 912c0ec7-b0ae-6e20-1fac-7126fcdf38b4
document_version_independent_id: 495a57bb-e460-93db-1dcc-a508446a268d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/container-network-security-cilium-mutual-tls-how-to.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/container-network-security-cilium-mutual-tls-how-to
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/container-network-security-cilium-mutual-tls-how-to.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: fcd62dba-03de-63b7-8568-9cc9bb9d09f0
---

# Deploy Cilium mTLS encryption with Advanced Container Networking Services - Azure Kubernetes Service | Microsoft Learn

Important

Cilium mTLS encryption with Advanced Cluster Networking Services is currently in PREVIEW. See the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/) for legal terms that apply to Azure features that are in beta, preview, or otherwise not yet released into general availability.

This article shows you how to deploy Cilium mTLS encryption with Advanced Container Networking Services in Azure Kubernetes Service (AKS) clusters.

## Prerequisites

- An Azure account with an active subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- The minimum version of Azure CLI required for the steps in this article is 2.71.0. To find the version, run `az --version`. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- Cilium mTLS encryption is only supported with the Azure CNI powered by Cilium. If you're using any other network plugin, Cilium mTLS encryption isn't supported. See [Configure Azure CNI Powered by Cilium](/en-us/azure/aks/azure-cni-powered-by-cilium).
- Ensure your AKS cluster is running Kubernetes version 1.34.0 or later.
- Ensure your cluster is using Cilium version 1.18 or later.

### Install the `aks-preview` Azure CLI extension

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

Install or update the Azure CLI preview extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) or [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

The minimum version of the aks-preview Azure CLI extension is `14.0.0b6`.

```azurecli
# Install the aks-preview extension
az extension add --name aks-preview
# Update the extension to make sure you have the latest version installed
az extension update --name aks-preview
```

### Register the `AdvancedNetworkingmTLSPreview` feature flag

Register the `AdvancedNetworkingmTLSPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

```azurecli
az feature register --namespace "Microsoft.ContainerService" --name "AdvancedNetworkingmTLSPreview"
```

Verify successful registration using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command. It takes a few minutes for the registration to complete.

```azurecli
az feature show --namespace "Microsoft.ContainerService" --name "AdvancedNetworkingmTLSPreview"
```

Once the feature shows `Registered`, refresh the registration of the `Microsoft.ContainerService` resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

## Enable Advanced Container Networking Services and mTLS encryption

To proceed, you must have an AKS cluster with [Advanced Container Networking Services](advanced-container-networking-services-overview) enabled.

The `az aks create` command with the Advanced Container Networking Services flag, `--enable-acns`, creates a new AKS cluster with all Advanced Container Networking Services features. These features encompass:

- **Container Network Observability:** Provides insights into your network traffic. To learn more, visit [Container Network Observability](advanced-container-networking-services-overview?tabs=cilium#container-network-observability).
- **Container Network Security:** Offers security features like Fully Qualified Domain Name (FQDN) filtering, L7 Policy, and in-transit encryption. To learn more, visit [Container Network Security](advanced-container-networking-services-overview?tabs=cilium#container-network-security).

Note

Clusters with the Cilium data plane support Container Network Observability and Container Network Security starting with Kubernetes version 1.29.

Note

Cilium mTLS encryption is disabled by default even after enabling ACNS. To enable mTLS, set the encryption type by using the flag `--acns-transit-encryption-type mTLS`.

```azurecli
# Set environment variables for the AKS cluster name and resource group. Make sure to replace the placeholders with your own values.
export CLUSTER_NAME="<aks-cluster-name>"
export RESOURCE_GROUP="<resourcegroup-name>"

# Create an AKS cluster
az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --location eastus \
    --network-plugin azure \
    --network-plugin-mode overlay \
    --network-dataplane cilium \
    --enable-acns \
    --acns-transit-encryption-type mTLS \
    --generate-ssh-keys
```

## Enable Advanced Container Networking Services and mTLS encryption on an existing cluster

The [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the Advanced Container Networking Services flag, `--enable-acns`, updates an existing AKS cluster with all Advanced Container Networking Services features, which includes [Container Network Observability](advanced-container-networking-services-overview?tabs=cilium#container-network-observability) and the [Container Network Security](advanced-container-networking-services-overview?tabs=cilium#container-network-security) feature.

Important

Enabling mTLS encryption on an existing cluster triggers a rollout restart of the Cilium agent across all nodes. For large clusters, this process can take some time and might temporarily impact workloads. Plan the update during a maintenance window or low-traffic period to minimize disruption.

```azurecli
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --enable-acns \
    --acns-transit-encryption-type mTLS
```

## Get cluster credentials

Get your cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

```azurecli
az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
```

## Enroll a namespace

To enroll an application in mTLS, apply the mTLS label to the namespace that contains the application pods.

```bash
kubectl label namespace <namespace-name> io.cilium/mtls-enabled=true
```

Traffic between enrolled and non‑enrolled workloads continues in plaintext without causing connectivity issues or hard failures.

## Verify mTLS is enabled

After enrolling a namespace for Cilium mTLS, you can verify that authentication and encryption are active using the following methods.

1. Check that ztunnel has been enabled:

    ```bash
    kubectl -n kube-system describe cm cilium-config | grep enable-ztunnel -A2
    ```

    You should see output indicating that ztunnel encryption is enabled.
2. Check which namespaces are enrolled:

    ```bash
    kubectl get namespaces -l io.cilium/mtls-enabled=true
    ```

    This shows all namespaces labeled for ztunnel enrollment.

    To verify that these namespaces are actually enrolled in the StateDB table:

    ```bash
    kubectl exec -n kube-system ds/cilium -- cilium-dbg statedb dump | jq '.["mtls-enrolled-namespaces"]'
    ```

    The results of this query should show which namespaces have been successfully processed by the enrollment reconciler.
3. Verify pods are enrolled in SPIRE

    Exec into the SPIRE Server container and list entries:

    ```bash
    kubectl exec -n kube-system spire-server-0 -c spire-server -- \
    /opt/spire/bin/spire-server entry show
    ```

    This command queries the SPIRE Server datastore and prints all registered workload identities.

    Look for entries matching the SPIFFE format:

    ```
    spiffe://<trust-domain>/ns/<namespace>/sa/<serviceaccount>
    ```
4. Verify pod enrollment in ztunnel

    Ztunnel exposes a local admin endpoint that allows inspecting its active configuration, including enrolled workloads.

    Select a ztunnel pod.

    ```bash
    kubectl get pods -n kube-system \
    -l app.kubernetes.io/name=ztunnel-cilium \
    -o wide
    ```

    Port-forward the ztunnel admin endpoint. ztunnel exposes an admin API on port 15000 (localhost-only by default).

    ```bash
    kubectl port-forward -n kube-system <ZTUNNEL_POD> 15000:15000
    ```

    Inspect the ztunnel configuration dump.

    ```bash
    curl -s http://localhost:15000/config_dump | jq
    ```

    Verify your pod is registered. Search the config dump for your workload's SPIFFE identity or namespace/service account. You should see entries like the following output:

```json
"workloads": [
    {
    "capacity": 1,
    "clusterId": "Kubernetes",
    "name": "test-server-5dc49df4cf-grr2f",
    "namespace": "ztunnel-test-enrolled",
    "networkMode": "Standard",
    "node": "10.224.0.5",
    "protocol": "HBONE",
    "serviceAccount": "default",
    "status": "Healthy",
    "trustDomain": "cluster.local",
    "uid": "30f37433-a83f-4e30-9946-f62cf5d10924",
    "workloadIps": [
        "192.168.0.50"
    ],
    "workloadType": "deployment"
    }
]
```

## Disable mTLS on an existing cluster

It's recommended to disenroll namespaces from mTLS before disabling it.

```bash
kubectl label namespace <namespace-name> io.cilium/mtls-enabled-
```

mTLS encryption can be disabled independently without affecting other ACNS features. To disable it, set the flag `--acns-transit-encryption-type` to `none`.

```azurecli
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --enable-acns \
    --acns-transit-encryption-type none
```