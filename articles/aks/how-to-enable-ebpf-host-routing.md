---
layout: Conceptual
title: Enable eBPF Host Routing with Advanced Container Networking Services - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/how-to-enable-ebpf-host-routing
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
description: Get started with eBPF Host Routing for Advanced Container Networking Services on your AKS cluster.
author: sf-msft
ms.author: samfoo
ms.subservice: aks-networking
ms.topic: how-to
ms.date: 2025-09-23T00:00:00.0000000Z
ms.custom: template-how-to-pattern, devx-track-azurecli
locale: en-us
document_id: 833934b0-c9c9-24de-dc40-80421e4553d5
document_version_independent_id: 5329e3a0-88bc-4864-d141-e17f7c77670b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/how-to-enable-ebpf-host-routing.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/how-to-enable-ebpf-host-routing
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/how-to-enable-ebpf-host-routing.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 6ee475d5-898f-1f93-df36-7fbe9a004138
---

# Enable eBPF Host Routing with Advanced Container Networking Services - Azure Kubernetes Service | Microsoft Learn

This article shows you how to enable eBPF Host Routing with Advanced Container Networking Services (ACNS) on Azure Kubernetes Service (AKS) clusters.

## Requirements and parameters

| Requirement or parameter | Supported versions or values | Description |
| --- | --- | --- |
| Azure CLI version | 2.71.0 or later | The Azure CLI version must be 2.71.0 or later to support eBPF Host Routing. |
| Kubernetes version | 1.33 or later | The Kubernetes version must be 1.33 or later to support eBPF Host Routing. |
| Node operating system | Azure Linux 3.0 or Ubuntu 24.04 | eBPF Host Routing is supported only on Azure CNI powered by Cilium clusters with Azure Linux 3.0 or Ubuntu 24.04. |
| Dataplane | Azure CNI powered by Cilium | eBPF Host Routing is supported only on AKS clusters that use Azure CNI powered by Cilium. |

Review the [Limitations](container-network-performance-ebpf-host-routing#limitations) section for node requirements and compatibility with existing iptable rules.

## Enable Advanced Container Networking Services and eBPF Host Routing

To proceed, you must have an AKS cluster with [Advanced Container Networking Services](advanced-container-networking-services-overview) enabled.

The `az aks create` command with the Advanced Container Networking Services flag, `--enable-acns`, creates a new AKS cluster with all Advanced Container Networking Services features. These features encompass:

- **Container Network Observability:** Provides insights into your network traffic. To learn more visit [Container Network Observability](advanced-container-networking-services-overview#container-network-observability).
- **Container Network Security:** Offers security features like FQDN filtering. To learn more visit [Container Network Security](advanced-container-networking-services-overview#container-network-security).
- **Container Network Performance:** Improves latency and throughput for pod network traffic. To learn more visit [Container Network Performance](advanced-container-networking-services-overview#container-network-performance)

Create an Azure resource group for the cluster using the [`az group create`](/en-us/cli/azure/group#az-group-create) command.

```azurecli
export LOCATION="<location>"

az group create --location $LOCATION --name <resourcegroup-name>
```

Create a new AKS cluster with eBPF Host Routing by enabling ACNS through `--enable-acns` and setting the acceleration mode with `--acns-datapath-acceleration-mode BpfVeth`.

```azurecli
# Set environment variables for the AKS cluster name and resource group. Make sure to replace the placeholders with your own values.
export CLUSTER_NAME="<aks-cluster-name>"
export RESOURCE_GROUP="<resourcegroup-name>"
export LOCATION="<location>"
export OS_SKU="<os-sku>" # Use AzureLinux or Ubuntu2404
 
# Create an AKS cluster
az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --network-plugin azure \
    --network-plugin-mode overlay \
    --network-dataplane cilium \
    --kubernetes-version 1.33 \
    --os-sku $OS_SKU \
    --enable-acns \
    --acns-datapath-acceleration-mode BpfVeth \
    --generate-ssh-keys
```

## Enable eBPF Host Routing with Advanced Container Networking Services on an existing cluster

The [`az aks update`](/en-us/cli/azure/aks#az-aks-update) command with the Advanced Container Networking Services flag, `--enable-acns`, updates an existing AKS cluster with `--acns-datapath-acceleration-mode BpfVeth` to enable Advanced Container Networking Services features that includes [Container Network Observability](advanced-container-networking-services-overview#container-network-observability), [Container Network Security](advanced-container-networking-services-overview#container-network-security), and [Container Network Performance](advanced-container-networking-services-overview#container-network-performance).

Note

Enabling eBPF Host Routing on an existing cluster may disrupt existing connections.

```azurecli
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --enable-acns \
    --acns-datapath-acceleration-mode BpfVeth
```

## Disable eBPF Host Routing on an existing cluster

eBPF Host Routing can be disabled independently without affecting other ACNS features. To disable it, set the flag `--acns-datapath-acceleration-mode=None`.

```azurecli
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --enable-acns \
    --acns-datapath-acceleration-mode None
```