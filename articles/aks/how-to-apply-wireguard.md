---
layout: Conceptual
title: Deploy WireGuard Encryption with Advanced Container Networking Services - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/how-to-apply-wireguard
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
description: Get started with WireGuard Encryption Feature for Advanced Container Networking Services on your AKS cluster.
author: JosephYostos
ms.author: josephyostos
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2024-05-02T00:00:00.0000000Z
ms.custom: template-how-to-pattern, devx-track-azurecli
locale: en-us
document_id: 0732658b-ad80-1866-50ad-4cfbac562f53
document_version_independent_id: 46c410d0-6159-47d8-cfbb-67792996a26e
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/how-to-apply-wireguard.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/how-to-apply-wireguard
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/how-to-apply-wireguard.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/089c8ba6-d135-43ff-bfaf-b8197fb72fb9
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/32516e21-6665-416f-be21-413febe47d91
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: edd3f459-acd8-c900-f74a-49769cf72c41
---

# Deploy WireGuard Encryption with Advanced Container Networking Services - Azure Kubernetes Service | Microsoft Learn

This article shows you how to deploy WireGuard encryption with Advanced Container Networking Services in Azure Kubernetes Service (AKS) clusters.

## Prerequisites

- An Azure account with an active subscription. If you don't have one, create a [free account](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn) before you begin.

- Use the Bash environment in [Azure Cloud Shell](/en-us/azure/cloud-shell/overview). For more information, see [Get started with Azure Cloud Shell](/en-us/azure/cloud-shell/quickstart).

    [![](../reusable-content/azure-cli/media/hdi-launch-cloud-shell.png)](https://shell.azure.com)
- If you prefer to run CLI reference commands locally, [install](/en-us/cli/azure/install-azure-cli) the Azure CLI. If you're running on Windows or macOS, consider running Azure CLI in a Docker container. For more information, see [How to run the Azure CLI in a Docker container](/en-us/cli/azure/run-azure-cli-docker).

    - If you're using a local installation, sign in to the Azure CLI by using the [az login](/en-us/cli/azure/reference-index#az-login) command. To finish the authentication process, follow the steps displayed in your terminal. For other sign-in options, see [Authenticate to Azure using Azure CLI](/en-us/cli/azure/authenticate-azure-cli).
    - When you're prompted, install the Azure CLI extension on first use. For more information about extensions, see [Use and manage extensions with the Azure CLI](/en-us/cli/azure/azure-cli-extensions-overview).
    - Run [az version](/en-us/cli/azure/reference-index?#az-version) to find the version and dependent libraries that are installed. To upgrade to the latest version, run [az upgrade](/en-us/cli/azure/reference-index?#az-upgrade).

- The minimum version of Azure CLI required for the steps in this article is 2.71.0. To find the version, run `az --version`. If you need to install or upgrade, see [Install Azure CLI](/en-us/cli/azure/install-azure-cli).
- WireGuard encryption is only supported with the Azure CNI powered by Cilium. If you're using any other network plugin, WireGuard encryption isn't supported. See [Configure Azure CNI Powered by Cilium](/en-us/azure/aks/azure-cni-powered-by-cilium).
- WireGuard establishes encrypted tunnels over UDP port 51871, which is exposed on each AKS node. Ensure UDP port 51871 is allowed between all node IPs, especially if your environment uses firewalls.

### Enable Advanced Container Networking Services and WireGuard

To proceed, you must have an AKS cluster with [Advanced Container Networking Services](advanced-container-networking-services-overview) enabled.

The `az aks create` command with the Advanced Container Networking Services flag, `--enable-acns`, creates a new AKS cluster with all Advanced Container Networking Services features. These features encompass:

- **Container Network Observability:** Provides insights into your network traffic. To learn more visit [Container Network Observability](advanced-container-networking-services-overview?tabs=cilium#container-network-observability).
- **Container Network Security:** Offers security features like Fully Qualified Domain Name (FQDN) filtering. To learn more visit [Container Network Security](advanced-container-networking-services-overview?tabs=cilium#container-network-security).

Note

Clusters with the Cilium data plane support Container Network Observability and Container Network security starting with Kubernetes version 1.29. WireGuard is disabled by default even after enabling Advanced Container Networking Services. To enable WireGuard set the encryption type by using the flag `--acns-transit-encryption-type wireguard`.

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
    --acns-transit-encryption-type wireguard \
    --generate-ssh-keys
```

## Enable Advanced Container Networking Services and WireGuard on an existing cluster

The [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the Advanced Container Networking Services flag, `--enable-acns`, updates an existing AKS cluster with all Advanced Container Networking Services features, which includes [Container Network Observability](advanced-container-networking-services-overview?tabs=cilium#container-network-observability) and the [Container Network Security](advanced-container-networking-services-overview?tabs=cilium#container-network-security) feature.

Important

Enabling WireGuard on an existing cluster will trigger a rollout restart of the Cilium agent across all nodes. For large clusters, this process can take some time and may temporarily impact workloads. It's recommended to plan the update during a maintenance window or low-traffic period to minimise disruption

Note

Only clusters with the Cilium data plane support Container Network Security features of Advanced Container Networking Services.

WireGuard is disabled by default even after enabling Advanced Container Networking Services. To enable WireGuard set the encryption type by using the flag `--acns-transit-encryption-type wireguard`.

```azurecli
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --enable-acns \
    --acns-transit-encryption-type wireguard
```

## Get cluster credentials

Get your cluster credentials using the [`az aks get-credentials`](/en-us/cli/azure/aks#az-aks-get-credentials) command.

```azurecli
az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
```

## Validate the setup

Validate that WireGuard is enabled successfully using cilium-dbg cli

Note

It might take a few minutes for WireGuard to be fully enabled and configured across all nodes after activation.

1. Run a bash shell in one of the Cilium pods

```bash
kubectl -n kube-system exec -ti ds/cilium -- bash
```

1. Check that WireGuard is enabled

```bash
cilium-dbg encrypt status
```

Expected output:

```
Encryption: Wireguard
Interface: cilium_wg0
        Public key: jikeOvVATORm/1GD0kZLxKhw1lofdsfdgiXWVyVIR3T0=
        Number of peers: 2
```

The number of peers should equal the number of nodes minus one.

## Troubleshooting

When WireGuard encryption is enabled in an AKS cluster using Cilium CNI, you can use the cilium-dbg CLI tool to inspect tunnel status, verify peer connectivity, and debug encryption-related issues.

### Inspect WireGuard peers

You can inspect peer status and configuration on each node using:

```bash
kubectl exec -n kube-system ds/cilium -- cilium-dbg debuginfo --output json | jq .encryption
```

Expected output:

```
{
  "wireguard": {
    "interfaces": [
      {
        "listen-port": 51871,
        "name": "cilium_wg0",
        "peer-count": 1,
        "peers": [
          {
            "allowed-ips": [
              "10.244.1.31/32",
              "10.244.1.206/32",
              "10.224.0.6/32"
            ],
            "endpoint": "10.224.0.6:51871",
            "last-handshake-time": "2025-04-24T11:13:49.102Z",
            "public-key": "3qwZEQLdK5IcFcdXxtr1m8RkDqznPVWEEirJ88+zDyk=",
            "transfer-rx": 2457024,
            "transfer-tx": 15746568
          }
        ],
        "public-key": "jikeOvVATORm/1GD0kZLxKhw1lofdsfdgiXWVyVIR3T0="
      }
    ],
    "node-encryption": "Disabled"
  }
}
```

This output shows the current state of WireGuard encryption on the node.

- listen-port: The UDP port (51871) where this node is listening for encrypted traffic from peers.
- peer-count: The number of remote WireGuard peers configured for this node.
- peers:
    - allowed-ips: list of pod IP addresses routed through the encrypted tunnel to this peer.
    - endpoint: The IP and port of the remote peer's WireGuard interface.
    - last-handshake-time: Timestamp of the most recent successful key exchange with this peer.
    - public-key: The public key of the remote peer.
    - transfer-rx / transfer-tx: The total number of bytes received/transmitted over the tunnel.
- public-key: The local WireGuard interface’s public key.
- node-encryption: Encrypts traffic originating from the node itself or from host-network pods. At present, only pod traffic is encrypted. Node encryption is not yet supported and remains disabled by default.

## Disabling WireGuard on an existing cluster

WireGuard can be disabled independently without affecting other Advanced Container Networking Services features. To disable it, set the flag `--acns-transit-encryption-type=none`.

```azurecli
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --enable-acns \
    --acns-transit-encryption-type none
```

## Known issues

- Packets might be dropped when configuring the WireGuard device leading to connectivity issues. This issue happens when endpoints are added or removed or when node updates occur. In some cases, this issue might lead to failed calls to [sendmsg](https://man7.org/linux/man-pages/man2/sendmsg.2.html) and [sendto](https://man7.org/linux/man-pages/man2/sendto.2.html). For more information, see [GitHub issue 33159](https://github.com/cilium/cilium/issues/33159).