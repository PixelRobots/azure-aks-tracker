---
layout: Conceptual
title: Diagnose and solve UDP packet drops in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/troubleshoot-udp-packet-drops
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
description: Learn how to diagnose and solve UDP packet drops in Azure Kubernetes Service (AKS).
ms.topic: troubleshooting
ms.date: 2024-07-25T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ms.subservice: aks-networking
locale: en-us
document_id: b72db63f-204e-ab31-b6eb-32dc07f2b0f4
document_version_independent_id: 94560669-1736-c04d-0cc1-7b4e74c8bfd0
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/troubleshoot-udp-packet-drops.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/troubleshoot-udp-packet-drops
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/troubleshoot-udp-packet-drops.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 6ffbdd05-af96-fc67-4a38-b0067999903d
---

# Diagnose and solve UDP packet drops in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

User Datagram Protocol (UDP) is a connectionless protocol used within managed AKS clusters. UDP packets are sent without any guarantee of delivery, reliability, or order, as they don’t establish a connection before data transfer. This means that UDP packets can be lost, duplicated, or arrive out of order at the destination because of multiple reasons.

This article describes how to diagnose and solve UDP packet drop issues caused by a small read buffer which could overflow in cases where you have high network traffic.

## Prerequisites

- An AKS cluster with at least one node pool and one pod running a UDP-based application.
- Azure CLI installed and configured. For more information, see [Install the Azure CLI](/en-us/cli/azure/install-azure-cli).
- Kubectl installed and configured to connect to your AKS cluster. For more information, see [Install kubectl](/en-us/cli/azure/install-azure-cli).
- A client machine that can send and receive UDP packets to and from your AKS cluster.

## Issue: UDP connections have a high packet drop rate

One possible cause of UDP packet loss is that the UDP buffer size is too small to handle the incoming traffic. The UDP buffer size determines how much data can be stored in the kernel before it's processed by the application. If the buffer size is insufficient, the kernel might drop packets that exceed the buffer capacity. This setting is managed at the virtual machine (VM) level for your nodes, and the default value is set to *1048576 bytes* or *1 MB*.

Note

Ubuntu versions prior to 24.10, excluding 20.04, 22.04, and 24.04, have the default UDP buffer capacity set to *212992 bytes* or *0.2 MB*.

There are two different variables at the VM level that apply to buffer sizes:

- `net.core.rmem_max = 1048576 bytes`: The largest buffer value a socket owner can explicitly set.
- `net.core.rmem_default = 1048576 bytes`: The maximum the system can grow the buffer to if a `rmem_max` value isn't explicitly set.

To allow the buffer to grow to serve high bursts of traffic, we need to update the buffer size values.

Note

This article focuses on Ubuntu Linux kernel buffer sizes. If you want to see other configurations for Linux and Windows, see [Customize node configuration for AKS node pools](custom-node-configuration).

## Diagnose

### Check current UDP buffer settings

1. Get a list of your nodes using the `kubectl get nodes` command and pick a node you want to check the buffer settings for.

    ```bash
    kubectl get nodes
    ```
2. Set up a debug pod on the node you selected using the `kubectl debug` command. Replace `<node-name>` with the name of the node you want to debug.

    ```bash
    kubectl debug -it node/<node-name> --image=ubuntu --share-processes -- bash
    ```
3. Get the value of the `net.core.rmem_max` and `net.core.rmem_default` variables using the following `sysctl` command:

    ```bash
    sysctl net.core.rmem_max net.core.rmem_default
    ```

### Measure incoming UDP traffic

To check if your buffer is too small for your application and is dropping packets, start by simulating realistic network traffic on your pods and setting up a debug pod to monitor the incoming traffic. Then, you can use the following commands to measure the incoming UDP traffic.

1. Check the UDP file while the test is running using the following `cat` command:

    ```bash
    cat /proc/net/udp
    ```

    This file shows you the statistics of the current open connections under the `rx_queue` column. It doesn't show historical data.
2. Check the snmp file and compare the `RcvbufErrors` value before and after the test using the following `cat` command:

    ```bash
    cat /proc/net/snmp
    ```

    This file shows you the life to date of the UDP packets, including how many packets were dropped under the `RcvbufErrors` column.

If you notice an increase beyond your buffer size in the `rx_queue` or an uptick in the `RcvbufErrors` value, you need to increase your buffer size.

Note

Increasing the system buffer size might not be effective if your application can't keep up with the incoming packet rate. Increasing the system buffer size in this case would merely delay packet drop. You should consider examining and improving your application for how it processes the UDP packets in such situations. A larger buffer size is only useful if you have occasional spikes of traffic that sometimes fill up the buffer, as it provides the kernel with more time/resources to deal with the surge in requests.

## Mitigate

Note

The kernel dynamically allocates the read buffers for each socket when packets arrive, rather than allocating them in advance. The `rmem_default` and `rmem_max` settings specify the kernel buffer boundaries for each socket before packet loss occurs.

You can change buffer size values on a node pool level during the node pool creation process. The steps in this section show you how to configure your Linux OS and apply the changes to all nodes in the node pool. You can't add this setting to an existing node pool.

1. Create a `linuxosconfig.json` file on your local machine with the following contents. You can modify the values per your application requirements and node SKU. The minimum value is *212992 bytes*, and the maximum is *134217728 bytes*.

    ```json
    {
        "sysctls": {
            "netCoreRmemMax": 1572864,
            "netCoreRmemDefault": 1572864
        }
    }
    ```
2. Make sure you're in the same directory as the `linuxosconfig.json` file and create a new node pool with the buffer size configuration using the [`az aks nodepool add`](/en-us/cli/azure/aks/nodepool#az-aks-nodepool-) command.

    ```azurecli
    az aks nodepool add --resource-group $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --name $NODE_POOL_NAME --linux-os-config ./linuxosconfig.json
    ```

    This command sets the maximum UDP buffer size to *8MB* for each socket on the node. You can adjust these values in the `linuxosconfig.json` file based on your application requirements.

## Validate

Once you apply the new values, you can access your VM to ensure the new values are set as default.

1. Get a list of your nodes using the `kubectl get nodes` command and pick a node you want to check the buffer settings for.

    ```bash
    kubectl get nodes
    ```
2. Set up a debug pod on the node you selected using the `kubectl debug` command. Replace `<node-name>` with the name of the node you want to debug.

    ```bash
    kubectl debug -it node/<node-name> --image=ubuntu --share-processes -- bash
    ```
3. Get the value of the `net.core.rmem_max` variable using the following `sysctl` command:

    ```bash
    sysctl net.core.rmem_max net.core.rmem_default
    ```

    Your values should now be set to the values outlined in `linuxosconfig.json`.

## Revert to original values

If you want to restore the buffer size to its default value of *1 MB*, you can update the `linuxosconfig.json` file with the following values:

```json
{
    "sysctls": {
        "netCoreRmemMax": 1048576,
        "netCoreRmemDefault": 1048576
    }
}
```