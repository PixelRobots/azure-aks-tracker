---
layout: Conceptual
title: Configure kube-proxy (iptables/IPVS/nftables) (Preview) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/configure-kube-proxy
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
description: Learn how to configure kube-proxy to utilize different load balancing configurations with Azure Kubernetes Service (AKS).
ms.subservice: aks-networking
ms.custom: devx-track-azurecli
ms.topic: how-to
ms.date: 2026-01-28T00:00:00.0000000Z
ms.author: schaffererin
author: schaffererin
locale: en-us
document_id: 50af023d-d649-47e5-28d9-cd446c6b0f4a
document_version_independent_id: 357152e5-d627-568c-78f6-b77138c71ff3
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/configure-kube-proxy.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/configure-kube-proxy
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/configure-kube-proxy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 46590a81-7299-d995-812f-e0d35102cd48
---

# Configure kube-proxy (iptables/IPVS/nftables) (Preview) - Azure Kubernetes Service | Microsoft Learn

`kube-proxy` is a component of Kubernetes that handles routing traffic for services within the cluster. There are three backends available for Layer 3/4 load balancing in upstream `kube-proxy`: `iptables`, `IPVS`, and `nftables`.

- `iptables` is the default backend used in many Kubernetes clusters. It's simple and well-supported, but not as efficient or intelligent as `IPVS`.
- `IPVS` uses the Linux Virtual Server, a Layer 3/4 load balancer built into the Linux kernel. `IPVS` provides many advantages over the default `iptables` configuration, including state awareness, connection tracking, and more intelligent load balancing. `IPVS`*doesn't support Azure Network Policy*.
- `nftables` is the successor to the `iptables` API and is designed to provide better performance and scalability than `iptables`. The `nftables` proxy mode is essentially a replacement for both the `iptables` and `IPVS` modes, with better performance than either of them, and is recommended as a replacement for `IPVS`.

For more information, see the [Kubernetes documentation on kube-proxy](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/).

Note

You can disable the AKS-managed `kube-proxy``DaemonSet` to support [bring-your-own CNI](use-byo-cni).

Important

AKS preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. AKS previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use. For more information, see the following support articles:

- [AKS support policies](/en-us/azure/aks/support-policies)
- [Azure support FAQ](/en-us/azure/aks/faq)

## Before you begin

- If you're using the Azure CLI, you need the `aks-preview` extension. See Install the `aks-preview` Azure CLI extension.
- If you're using Azure Resource Manager or the REST API, the AKS API version must be *2022-08-02-preview* or later. Specifically for `nftables` mode, the version must be *2025-09-02-preview* or later.
- You need to register the `KubeProxyConfigurationPreview` feature flag. See Register the `KubeProxyConfigurationPreview` feature flag.

### Install the `aks-preview` Azure CLI extension

1. Install the `aks-preview` extension using the [`az extension add`](/en-us/cli/azure/extension#az-extension-add) command.

    ```azurecli
    az extension add --name aks-preview
    ```
2. Update to the latest version of the extension using the [`az extension update`](/en-us/cli/azure/extension#az-extension-update) command.

    ```azurecli
    az extension update --name aks-preview
    ```

### Register the `KubeProxyConfigurationPreview` feature flag

1. Register the `KubeProxyConfigurationPreview` feature flag using the [`az feature register`](/en-us/cli/azure/feature#az-feature-register) command.

    ```azurecli
    az feature register --namespace "Microsoft.ContainerService" --name "KubeProxyConfigurationPreview"
    ```

    It takes a few minutes for the status to show *Registered*.
2. Verify the registration status using the [`az feature show`](/en-us/cli/azure/feature#az-feature-show) command.

    ```azurecli
    az feature show --namespace "Microsoft.ContainerService" --name "KubeProxyConfigurationPreview"
    ```
3. When the status shows *Registered*, refresh the registration of the `Microsoft.ContainerService` resource provider using the [`az provider register`](/en-us/cli/azure/provider#az-provider-register) command.

    ```azurecli
    az provider register --namespace Microsoft.ContainerService
    ```

## `kube-proxy` configuration options

You can view the full `kube-proxy` configuration structure in the [AKS Cluster Schema](/en-us/azure/templates/microsoft.containerservice/managedclusters?pivots=deployment-language-bicep#containerservicenetworkprofilekubeproxyconfig).

- `enabled`: Determines deployment of the `kube-proxy` DaemonSet. Defaults to `true`.
- `mode`: You can set to either `IPTABLES`, `IPVS` or `NFTABLES`. Defaults to `IPTABLES`.
- `ipvsConfig`: If `mode` is `IPVS`, this object contains IPVS-specific configuration properties.
    - `scheduler`: Determines which connection scheduler to use. Supported values include:
        - `LeastConnection`: Sends connections to the backend pod with the fewest connections.
        - `RoundRobin`: Evenly distributes connections between backend pods.
    - `tcpFinTimeoutSeconds`: Sets the timeout length value after a TCP session receives a FIN.
    - `tcpTimeoutSeconds`: Sets the timeout length value for idle TCP sessions.
    - `udpTimeoutSeconds`: Sets the timeout length value for idle UDP sessions.

`IPVS` load balancing operates in each node independently and is only aware of connections that flow through the local node. This means that while `LeastConnection` results in a more even load under a higher number of connections, when a low number of connections occur (`# connects < 2 * node count`), traffic might be unbalanced.

## Use `kube-proxy` in a new or existing AKS cluster

The `kube-proxy` configuration is a cluster-wide setting. You don't need to update your services.

A change to the `kube-proxy` configuration might cause a slight interruption in cluster service traffic flow.

1. Create a configuration file with the desired `kube-proxy` configuration.

    - `IPVS`: For example, the following configuration enables `IPVS` with the `LeastConnection` scheduler and sets the TCP timeout to 900 seconds.

        ```json
        {
          "enabled": true,
          "mode": "IPVS",
          "ipvsConfig": {
            "scheduler": "LeastConnection",
            "tcpTimeoutSeconds": 900,
            "tcpFinTimeoutSeconds": 120,
            "udpTimeoutSeconds": 300
          }
        }
        ```
    - `nftables`: For example, the following configuration enables `nftables` mode.

        ```json
        {
          "enabled": true,
          "mode": "NFTABLES"
        }
        ```
2. Create a new cluster or update an existing cluster with the configuration file using the [`az aks create`](/en-us/cli/azure/aks#az-aks-create) or [`az aks update`](/en-us/cli/azure/aks#az-aks-update) commands. Use the `--kube-proxy-config` parameter to specify the configuration file.

    ```azurecli
    # Create a new cluster
    az aks create \
      --resource-group <resourceGroup> \
      --name <clusterName> \
      --kube-proxy-config kube-proxy.json \
      --generate-ssh-keys
    
    # Update an existing cluster
    az aks update \
      --resource-group <resourceGroup> \
      --name <clusterName> \
      --kube-proxy-config kube-proxy.json
    ```