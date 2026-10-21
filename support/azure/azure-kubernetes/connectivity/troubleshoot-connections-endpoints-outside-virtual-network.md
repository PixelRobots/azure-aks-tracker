---
layout: Conceptual
title: Troubleshoot connections to endpoints outside the virtual network - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-connections-endpoints-outside-virtual-network
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: troubleshooting
description: Learn how to troubleshoot connections to endpoints outside the virtual network from an AKS cluster over the public internet, and fix issues fast.
ms.date: 2024-10-18T00:00:00.0000000Z
ms.reviewer: chiragpa, rissing, jaewonpark, v-leedennis, v-weizhu
editor: v-jsitser
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity
locale: en-us
document_id: c7cc2be8-a6e2-88d4-5c44-730a75bac4ff
document_version_independent_id: c7cc2be8-a6e2-88d4-5c44-730a75bac4ff
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/troubleshoot-connections-endpoints-outside-virtual-network.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/troubleshoot-connections-endpoints-outside-virtual-network
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/troubleshoot-connections-endpoints-outside-virtual-network.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
platformId: a231a5b7-5113-170a-91f3-1a75c67ea082
---

# Troubleshoot connections to endpoints outside the virtual network - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot connections to endpoints outside the virtual network (that is, through the public internet) from an AKS cluster. Use these steps to identify root causes and restore connectivity quickly.

## Prerequisites

- [Azure CLI](/en-us/cli/azure/install-azure-cli).
- The client URL ([curl](https://techcommunity.microsoft.com/t5/containers/tar-and-curl-come-to-windows/ba-p/382409)) tool.
- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool, or a similar tool to connect to the cluster. To install kubectl by using Azure CLI, run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.

## Troubleshooting checklist

### Is the issue persistent?

#### Step 1: Do basic troubleshooting

Make sure that you can connect to public endpoints on the internet. For instructions, see [Basic troubleshooting of outbound AKS cluster connections](basic-troubleshooting-outbound-connections).

#### Step 2: Determine the outbound type for the AKS cluster

To identify the outbound type of the AKS cluster, run the [az aks show](/en-us/cli/azure/aks#az-aks-show) command:

```azurecli
az aks show --resource-group <resource_group> --name <cluster_name> --query "networkProfile.outboundType"
```

If the outbound type is `loadBalancer`, there's no route table unless you use *kubenet* network. If you use *kubenet*, make sure that the default route table has no additional configuration that blocks outbound internet connection. If you use another network, such as Azure CNI, Dynamic Allocation, or Azure CNI Overlay, no route table is created by default. In this case, make sure the NSG (network security group) has no custom configuration that blocks outbound internet connection.

If the outbound type is `userDefinedRouting`, make sure that the following conditions are met:

- The egress device (firewall or proxy) is reachable.
- The egress device allows the [required outbound traffic](/en-us/azure/aks/limit-egress-traffic#required-outbound-network-rules-and-fqdns-for-aks-clusters) from the cluster.

    To get the list of FQDNs that are allowed for your AKS cluster, run the [az aks egress-endpoints list](/en-us/cli/azure/aks/egress-endpoints#az-aks-egress-endpoints-list) command:

    ```azurecli
    az aks egress-endpoints list --resource-group <resource_group> --name <cluster_name>
    ```

If the outbound type is `managedNATGateway`, check whether the AKS subnet is associated with the NAT gateway by running the [az network nat gateway show](/en-us/cli/azure/network/nat/gateway#az-network-nat-gateway-show) command:

```azurecli
az network nat gateway show --resource-group <resource_group> --name <nat_gateway_name> --query "subnets[].id"
```

For more information about how to use a NAT gateway together with AKS, see [Managed NAT gateway](/en-us/azure/aks/nat-gateway).

#### Step 3: Examine the curl output when you connect to the application pod

The curl response codes can help you identify the issue type. After the response code becomes available, try to better understand how the issue behaves. For more information about the HTTP status codes and the underlying behavior of the issue, refer to the following table.

| Information source | Link |
| --- | --- |
| Internet Assigned Numbers Authority (IANA) | [Hypertext Transfer Protocol (HTTP) status code registry](https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml) |
| Mozilla | [HTTP response status codes](https://developer.mozilla.org/docs/Web/HTTP/Status) |
| Wikipedia | [List of HTTP status codes](https://wikipedia.org/wiki/List_of_HTTP_status_codes) |

The following HTTP status codes might indicate the listed issues.

| HTTP status code | Issue | Example |
| --- | --- | --- |
| `4xx` | 1. An issue affects the client request.<br>2. A network blocker exists between the client and the server. | 1. The requested page doesn't exist, or the client doesn't have permission to access the page.<br>2. Traffic is being blocked by a network security group or a firewall. |
| `5xx` | An issue affects the server. | The application is down, or a gateway isn't working. |

You can try to connect to the application endpoint using curl. Here's an example command and output:

```bash
# 404 error code example
$ curl -vv <host IP address>/test.index

*   Trying <host IP address>:80...
* TCP_NODELAY set
* Connected to <host IP address> (<host IP address>) port 80 (#0)
> GET /test.index HTTP/1.1
> Host: <host IP address>
> User-Agent: curl/7.68.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 404 Not Found
...
* Connection #0 to host <host IP address> left intact
```

#### Step 4: Check what happens if outbound traffic bypasses the virtual appliance temporarily

For quick testing to determine whether the egress device (virtual appliance) causes the issue, you can temporarily allow all traffic to go through the internet. To configure this setup, you can change the default IP address and port route of `0.0.0.0`/`0` through the virtual appliance to go through the internet instead.

If the egress device works well when bypassing the virtual appliance, check the logs of the virtual appliance to see which packets are denied and add allow rules in the virtual appliance accordingly.

### Is the issue intermittent?

You may experience intermittent outbound issues for many reasons. For troubleshooting intermittent outbound connection issues, try the following steps:

#### Step 1: Check if the pod or node resources are exhausted

Run the following commands to check how much the resources are used:

```bash
kubectl top pods
kubectl top nodes
```

#### Step 2: Check if the operating system disk is used heavily

To check whether the operating system disk is used heavily, follow these steps:

1. In the [Azure portal](https://portal.azure.com), search for and select **Virtual machine scale sets**.
2. In the list of scale sets, select the scale set that's used for your AKS cluster.
3. In the scale set navigation pane, go to the **Monitoring** section, and then select **Metrics**.
4. View the disk metrics for the scale set from the **Metrics** section by looking for the following fields.

    | Field | Value |
    | --- | --- |
    | Scope | **VMSS Name** |
    | Metrics Namespace | **Virtual Machine Host** |
    | Metrics | **OS and Data Disk Metric** |

For more information about metrics, see [OS Disk and Data Disk metrics](/en-us/azure/virtual-machines/disks-metrics).

To view AKS recommendations about disk utilization, follow these steps:

1. In the [Azure portal](https://portal.azure.com), search for and select **Kubernetes services**.
2. In the list of Kubernetes services, select the name of your AKS cluster.
3. In the AKS cluster navigation pane, go to the **Monitoring** section, and then select **Advisor recommendations**.
4. Review the listed recommendations about disk usage.

If the OS disk is used heavily, consider using the following remedies:

- Increase the OS disk size.
- Switch to [Ephemeral OS disks](/en-us/azure/aks/cluster-configuration#ephemeral-os).

If these remedies don't resolve the issue, analyze the process that does heavy read/write operations on the disk. Then, check whether you can move the actions to a data disk instead of the OS disk.

#### Step 3: Check if the source network address translation port is exhausted

If applications are making many outbound connections, they may exhaust the number of available ports on the outbound device's IP address. Follow [Standard load balancer diagnostics with metrics, alerts, and resource health](/en-us/azure/load-balancer/load-balancer-standard-diagnostics) to monitor the usage and allocation of your existing load balancer's [source network address translation (SNAT) port](/en-us/azure/load-balancer/load-balancer-outbound-connections#what-are-snat-ports). Monitor to verify or determine the risk of [SNAT port exhaustion](/en-us/azure/load-balancer/load-balancer-outbound-connections#port-exhaustion).

Are you reaching or exceeding the maximum number of allocated SNAT ports? In that case, you can check your application to determine whether it's reusing existing connections. For more information, see [Design your applications to use connections efficiently](/en-us/azure/load-balancer/troubleshoot-outbound-connection#design-your-applications-to-use-connections-efficiently).

If you feel that the application is configured correctly, and you do need more SNAT ports than the default number of allocated ports, follow these steps:

1. Increase the number of public IPs on the egress device. If the egress device is the load balancer, you can [Increase the number of public IP addresses on the load balancer](/en-us/azure/aks/load-balancer-standard#scale-the-number-of-managed-outbound-public-ips).
2. [Increase the ports per node for your AKS worker nodes](/en-us/azure/aks/load-balancer-standard#configure-the-allocated-outbound-ports).

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.