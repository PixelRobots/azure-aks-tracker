---
layout: Conceptual
title: Troubleshoot AKS outbound connections - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/basic-troubleshooting-outbound-connections
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
description: Learn how to troubleshoot outbound connections from an AKS cluster, isolate network blockers, and restore egress connectivity quickly. Start now.
ms.date: 2026-07-21T00:00:00.0000000Z
ms.reviewer: chiragpa, rissing, jopalhei, jaewonpark, v-leedennis, v-weizhu, juliayin, v-liuamson, andraciobanu
editor: v-jsitser
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity
locale: en-us
document_id: a6893da3-957c-409e-1e3b-338e90f8142a
document_version_independent_id: a6893da3-957c-409e-1e3b-338e90f8142a
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/basic-troubleshooting-outbound-connections.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/basic-troubleshooting-outbound-connections
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/basic-troubleshooting-outbound-connections.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/1ae5c491-970a-4062-8301-6336e69f9026
- https://authoring-docs-microsoft.poolparty.biz/devrel/20ed8455-bc18-4537-87a4-83784e7b2a39
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/f2c3e52e-3667-4e8a-bf11-20b9eaccdc8c
- https://authoring-docs-microsoft.poolparty.biz/devrel/9a7f703b-30bb-4d62-9eb4-97213f571849
platformId: 39c2d5ea-9c28-3ff8-b68f-1b3291b6d7d7
---

# Troubleshoot AKS outbound connections - Azure | Microsoft Learn

## Summary

This article explains basic troubleshooting of outbound connections from an Azure Kubernetes Service (AKS) cluster. By following these steps, you can identify faulty components and restore connectivity faster.

## Prerequisites

- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool, or a similar tool to connect to the cluster. To install kubectl by using [Azure CLI](/en-us/cli/azure/install-azure-cli), run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.
- The [apt-get](https://linux.die.net/man/8/apt-get) command-line tool for handling packages.
- The Client URL ([cURL](https://www.tecmint.com/install-curl-in-linux/)) tool, or a similar command-line tool.
- The `nslookup` command-line ([dnsutils](https://www.tecmint.com/install-dig-and-nslookup-in-linux/)) tool for checking DNS resolution.

## Scenarios for outbound traffic in Azure Kubernetes Service

Traffic that originates from within the AKS cluster, whether it's from a pod or a worker node, is considered outbound traffic from the cluster. If there's an issue in the outbound flow for an AKS cluster, before you troubleshoot, first look at the scenarios for outbound traffic flow.

You can classify the outbound traffic from an AKS cluster into the following categories:

1. Traffic to a pod or service in the same cluster (internal traffic).
2. Traffic to a network resource or endpoint in the same virtual network or a different virtual network that uses virtual network peering.
3. Traffic to an on-premises environment through a VPN connection or an Azure ExpressRoute connection.
4. Traffic outside the AKS network through Azure Load Balancer (public outbound traffic).
5. Traffic outside the AKS network through Azure Firewall or a proxy server (public outbound traffic).

#### Internal traffic

A basic request flow for internal traffic from an AKS cluster resembles the flow shown in the following diagram.

[![Screenshot of the internal outbound traffic flow between pods and services in an AKS cluster.](media/basic-troubleshooting-outbound-connections/internal-traffic-aks-cluster.svg)](media/basic-troubleshooting-outbound-connections/internal-traffic-aks-cluster.svg#lightbox)

#### Public outbound traffic through Azure Load Balancer

If the traffic is for a destination on the internet, the default method is to send the traffic through the Azure Load Balancer.

[![Screenshot of outbound internet traffic from an AKS cluster through Azure Load Balancer.](media/basic-troubleshooting-outbound-connections/external-traffic-load-balancer.svg)](media/basic-troubleshooting-outbound-connections/external-traffic-load-balancer.svg#lightbox)

The preceding discussion about Load Balancer applies specifically to `outboundType=loadBalancer`. You also need to check the managed NAT gateway outbound architectures [from here](/en-us/azure/aks/nat-gateway).

#### Public outbound traffic through Azure Firewall or a proxy server

In some cases, you need to filter the egress traffic, and it might require Azure Firewall.

[![Screenshot of outbound internet traffic from an AKS cluster through Azure Firewall.](media/basic-troubleshooting-outbound-connections/external-traffic-firewall.svg)](media/basic-troubleshooting-outbound-connections/external-traffic-firewall.svg#lightbox)

You might want to add a proxy server instead of a firewall, or set up a NAT gateway for egress traffic. The basic flow remains the same as shown in the diagram.

It's important to understand the nature of egress flow for your cluster so that you can continue troubleshooting.

## Considerations when troubleshooting

#### Check your network resources within traffic flow

When you troubleshoot outbound traffic in AKS, it's important to know what network resources are present (that is, the hops through which the traffic passes). Here, the network resource could be one of the following components:

- Azure Load Balancer
- Azure Firewall or a custom firewall
- A network address translation (NAT) gateway
- A proxy server
- Network security group (NSG)
- Network policy

The flow could also differ based on the destination. For example, internal traffic (that is, within the cluster) doesn't go through the external network resources and only uses the cluster networking. For public outbound traffic, determine which network resources are implemented for your cluster.

#### Check the outbound connectivity path and blockers with Azure Virtual Network Verifier (Preview)

To check where traffic is blocked within your network resources to specific endpoints (for example, `mcr.microsoft.com`), use the [Azure Virtual Network Verifier (Preview)](/en-us/azure/virtual-network-manager/concept-virtual-network-verifier) tool. By running a connectivity analysis, you can visualize the hops within the traffic flow and any misconfigurations within Azure networking resources that are blocking traffic. Use the Virtual Network Verifier tool as a first step in troubleshooting outbound connectivity issues to isolate the issue and detect problematic network configuration. For more instructions, check if Azure network resources are blocking traffic to the endpoint using Azure Virtual Network Verifier (Preview).

#### Manual troubleshooting steps for outbound connections

For manual troubleshooting, check the following items:

- The source and the destination for the request.
- The hops between the source and the destination.
- The request-response flow.
- The hops enhanced by extra security layers, such as the following layers:

    - Firewall
    - Network security group (NSG)
    - Network policy

To identify a problematic hop, [check the HTTP response codes before and after it](get-and-analyze-http-response-codes). These codes are useful to identify the nature of the issue. The codes are especially helpful in scenarios in which the application responds to HTTP requests. To check whether the packets arrive properly in a specific hop, you can proceed with packet captures.

#### Take packet captures from the client and server

If other troubleshooting steps don't provide any conclusive outcome, take packet captures from the client and server. Packet captures are also useful when non-HTTP traffic is involved between the client and server. For more information about how to collect packet captures for AKS environment, see the following articles in the data collection guide:

- [Capture a TCP dump from a Linux node in an AKS cluster](../logs/capture-tcp-dump-linux-node-aks)
- [Capture a TCP dump from a Windows node in an AKS cluster](../logs/capture-tcp-dump-windows-node-aks)
- [Capture TCP packets from a pod on an AKS cluster](../logs/packet-capture-pod-level)

Before starting the troubleshooting flow, determine the cluster outbound type (loadBalancer, managedNATGateway, userAssignedNATGateway, userDefinedRouting) and follow scenario-specific validation.

- [Customize Cluster Egress with Outbound Types in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn](/en-us/azure/aks/egress-outboundtype)
- [Customize cluster egress with a user-defined routing table in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn](/en-us/azure/aks/egress-udr)
- [Troubleshoot connections to endpoints outside the virtual network](troubleshoot-connections-endpoints-outside-virtual-network)

## Troubleshooting checklists

For basic troubleshooting for egress traffic from an AKS cluster, follow these steps:

1. Check if Azure network resources are blocking traffic to the endpoint using Azure Virtual Network Verifier (Preview).
2. Make sure that the Domain Name System (DNS) resolution for the endpoint works correctly.
3. Make sure that you can reach the endpoint through an IP address.
4. [Make sure that you can reach the endpoint from another source](troubleshoot-connection-pods-services-same-cluster).
5. [Make sure that the endpoint is working](troubleshoot-connections-endpoints-same-virtual-network).
6. [Check whether the cluster can reach any other external endpoint](troubleshoot-connections-endpoints-outside-virtual-network).
7. [Check whether a network policy is blocking the traffic](dns/troubleshoot-dns-failure-from-pod-but-not-from-worker-node).
8. [Check whether an NSG is blocking the traffic](traffic-between-node-pools-is-blocked).
9. Check whether a firewall or proxy is blocking the traffic.
10. Check whether the AKS service principal or managed identity has the required [AKS service permissions](/en-us/azure/aks/concepts-identity#aks-service-permissions) to make the network changes to Azure resources.

Note

This checklist assumes no service mesh when you do basic troubleshooting. If you use a service mesh such as Istio, it produces unusual outcomes for TCP based traffic.

#### Check if Azure network resources are blocking traffic to the endpoint

To determine if Azure network resources block traffic to the endpoint, run a connectivity analysis from your AKS cluster nodes to the endpoint by using the [Azure Virtual Network Verifier (Preview)](/en-us/azure/virtual-network-manager/concept-virtual-network-verifier#supported-features-of-the-reachability-analysis) tool. The connectivity analysis covers the following resources:

- Azure Load Balancer
- Azure Firewall
- A network address translation (NAT) gateway
- Network security group (NSG)
- Network policy
- User defined routes (route tables)
- Virtual network peering

Note

Azure Virtual Network Verifier (Preview) can't access any external or third-party networking resources, such as a custom firewall. If the connectivity analysis doesn't detect any blocked traffic, perform a manual check of any external networking to cover all hops in the traffic flow.

1. Go to your cluster in the Azure portal. In the sidebar, go to the **Settings** &gt; **Node pools** blade.
2. Identify the node pool you want to run a connectivity analysis from. Select the node pool as the scope.
3. Select **Connectivity analysis (Preview)** from the toolbar at the top of the page. If you don't see it, select the three dots **...** in the toolbar at the top of the page to open the expanded menu.
4. Select a Virtual Machine Scale Set (VMSS) instance as the source. The source IP addresses are populated automatically.
5. Select a public domain name or endpoint as the destination for the analysis, such as `mcr.microsoft.com`. The destination IP addresses are also populated automatically.
6. Run the analysis and wait up to two minutes for the results. In the resulting diagram, identify the associated Azure network resources and where traffic is blocked. To view the detailed analysis output, select the **JSON output** tab or select the arrows in the diagram.

#### Check that the Domain Name Service (DNS) resolution for the endpoint works correctly

You can run a DNS lookup to the endpoint by running a debugging pod on one of your AKS nodes. If the issue is isolated to a specific problematic pod or namespace, run the DNS lookup from within the same namespace where you notice the problem.

If you can't run the [kubectl exec](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec) command to connect to an existing pod, you can [start a test pod in the same namespace as the problematic pod](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/#create-a-simple-pod-to-use-as-a-test-environment) to run the tests.

Note

If DNS resolution or egress traffic doesn't let you install the necessary network packages, use the `rishasi/ubuntu-netutil:1.0` Docker image. In this image, the required packages are already installed.

##### Example procedure for checking DNS resolution

1. Start a test pod in the problematic namespace:

    ```bash
    kubectl run -it --rm aks-ssh --namespace <namespace> --image=debian:stable --overrides='{"spec": { "nodeSelector": {"kubernetes.io/os": "linux"}}}'
    ```

    After the test pod is running, you gain access to the pod.
2. Run the following `apt-get` commands to install other tool packages:

    ```bash
    # Update and install tool packages
    apt-get update && apt-get install -y dnsutils curl
    ```
3. After the packages are installed, run the [nslookup](/en-us/windows-server/administration/windows-commands/nslookup) command to test the DNS resolution to the endpoint:

    ```console
    $ nslookup microsoft.com # Microsoft.com is used as an example
    Server:         <server>
    Address:        <server IP address>#53
    ...
    ...
    Name:   microsoft.com
    Address: 20.53.203.50
    ```
4. Try the DNS resolution from the upstream DNS server directly. This example uses Azure DNS:

    ```console
    $ nslookup microsoft.com 168.63.129.16
    Server:         168.63.129.16
    Address:        168.63.129.16#53
    ...
    ...
    Address: 20.81.111.85
    ```

Sometimes, there's a problem with the endpoint itself rather than a cluster DNS. In such cases, consider the following checks:

1. Check whether the desired port is open on the remote host:

    ```bash
    curl -Ivm5 telnet://microsoft.com:443
    ```
2. Check the HTTP response code:

    ```bash
    curl -Ivm5 https://microsoft.com
    ```
3. Check whether you can connect to any other endpoint:

    ```bash
    curl -Ivm5 https://kubernetes.io
    ```

To verify that the endpoint is reachable and DNS is functioning from the node hosting the problematic pod, follow these steps:

1. Enter the node hosting the problematic pod by using the debug pod. For more information, see [Connect to Azure Kubernetes Service (AKS) cluster nodes for maintenance or troubleshooting](/en-us/azure/aks/node-access).
2. Test the DNS resolution to the endpoint:

    ```console
    $ nslookup  microsoft.com
    Server:         168.63.129.16
    Address:        168.63.129.16#53
    
    Non-authoritative answer:
    Name:   microsoft.com
    Address: 20.112.52.29
    Name:   microsoft.com
    Address: 20.81.111.85
    Name:   microsoft.com
    Address: 20.84.181.62
    Name:   microsoft.com
    Address: 20.103.85.33
    Name:   microsoft.com
    Address: 20.53.203.50
    ```
3. Check the **resolv.conf** file to determine whether the expected name servers are added:

    ```bash
    cat /etc/resolv.conf
    cat /run/systemd/resolve/resolv.conf
    ```

##### Example procedure for checking DNS resolution of a Windows pod

1. Run a test pod in the Windows node pool:

    ```bash
    # For a Windows environment, use the Resolve-DnsName cmdlet.
    kubectl run dnsutil-win --image='mcr.microsoft.com/windows/servercore:ltsc2022' --overrides='{"spec": { "nodeSelector": {"kubernetes.io/os": "windows"}}}' -- powershell "Start-Sleep -s 3600"
    ```
2. Run the [kubectl exec](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec) command to connect to the pod by using PowerShell:

    ```bash
    kubectl exec -it dnsutil-win -- powershell
    ```
3. Run the [Resolve-DnsName](/en-us/powershell/module/dnsclient/resolve-dnsname) cmdlet in PowerShell to check whether the DNS resolution is working for the endpoint:

    ```console
    PS C:\> Resolve-DnsName www.microsoft.com 
    
    Name                           Type   TTL   Section    NameHost
    ----                           ----   ---   -------    --------
    www.microsoft.com              CNAME  20    Answer     www.microsoft.com-c-3.edgekey.net
    www.microsoft.com-c-3.edgekey. CNAME  20    Answer     www.microsoft.com-c-3.edgekey.net.globalredir.akadns.net
    net
    www.microsoft.com-c-3.edgekey. CNAME  20    Answer     e13678.dscb.akamaiedge.net
    net.globalredir.akadns.net
    
    Name       : e13678.dscb.akamaiedge.net 
    QueryType  : AAAA
    TTL        : 20
    Section    : Answer
    IP6Address : 2600:1408:c400:484::356e   

    Name       : e13678.dscb.akamaiedge.net 
    QueryType  : AAAA
    TTL        : 20
    Section    : Answer
    IP6Address : 2600:1408:c400:496::356e 

    Name       : e13678.dscb.akamaiedge.net
    QueryType  : A
    TTL        : 12
    Section    : Answer
    IP4Address : 23.200.197.152
    ```

In one unusual scenario that involves DNS resolution, the DNS queries get a correct response from the node but fail from the pod. For this scenario, you might consider [checking DNS resolution failures from inside the pod but not from the worker node](dns/troubleshoot-dns-failure-from-pod-but-not-from-worker-node). If you want to inspect DNS resolution for an endpoint across the cluster, you can consider [checking DNS resolution status across the cluster](dns/troubleshoot-dns-failures-across-an-aks-cluster-in-real-time#step-3-verify-the-health-of-the-upstream-dns-servers).

If the DNS resolution is successful, continue to the network tests. Otherwise, verify the DNS configuration for the cluster.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.

If the basic troubleshooting steps don't identify the root cause, continue with advanced diagnostics. Use Azure Virtual Network Verifier to validate the network path through Azure resources and identify blocked hops. For deeper cluster-network analysis, use Advanced Container Networking Services (ACNS) observability capabilities to investigate DNS failures, packet drops, network policy enforcement, connection tracking behavior, and Layer 7 traffic issues. If you suspect packet loss or intermittent connectivity, collect packet captures from the affected pod and node at the same time to determine where traffic is dropped. Also verify that all required AKS outbound endpoints and FQDN dependencies are permitted through firewalls, proxies, and egress filtering devices before focusing on application-level troubleshooting.

[Source](/en-us/azure/aks/container-network-observability-guide)