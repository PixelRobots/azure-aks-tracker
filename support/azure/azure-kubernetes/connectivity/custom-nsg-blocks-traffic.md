---
layout: Conceptual
title: Fix AKS time-out errors from custom NSG blocks - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/custom-nsg-blocks-traffic
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
description: Fix AKS time-out errors caused by a custom NSG blocking app traffic. Use this guide to identify the cause and restore access quickly.
ms.date: 2024-09-16T00:00:00.0000000Z
ms.reviewer: chiragpa, v-leedennis
editor: v-jsitser
ms.service: azure-kubernetes-service
ms.custom: sap:Connectivity, linux-related-content
locale: en-us
document_id: 9c169eb9-c2b0-197c-7a8a-80e3602e4371
document_version_independent_id: 9c169eb9-c2b0-197c-7a8a-80e3602e4371
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/connectivity/custom-nsg-blocks-traffic.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/connectivity/custom-nsg-blocks-traffic
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/connectivity/custom-nsg-blocks-traffic.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: cc5cc942-8ce6-b5ec-87bc-e4a2696b1db4
---

# Fix AKS time-out errors from custom NSG blocks - Azure | Microsoft Learn

## Summary

When you access an application that's hosted on an Azure Kubernetes Service (AKS) cluster, you receive a "Timed out" error message. This error can occur even if the application is running and the rest of the configuration appears to be correct.

## Prerequisites

- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool, or a similar tool, to connect to the cluster. To install kubectl by using [Azure CLI](/en-us/cli/azure/install-azure-cli), run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.
- The Client URL ([cURL](https://www.tecmint.com/install-curl-in-linux/)) tool, or a similar command-line tool.
- The [apt-get](https://linux.die.net/man/8/apt-get) command-line tool for handling packages.

## Symptoms

If you run the following [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) and cURL commands, you experience "Timed out" errors that resemble the following console output:

```console
$ kubectl get pods
NAME                             READY   STATUS    RESTARTS   AGE
my-deployment-66648877fc-v78jm   1/1     Running   0          5m53s

$ kubectl get service
NAME                      TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
my-loadbalancer-service   LoadBalancer   10.0.107.79   10.81.x.x   80:31048/TCP   4m14s

$ curl -Iv http://10.81.124.39  # Use an IP address that fits the "EXTERNAL-IP" pattern.
*   Trying 10.81.x.x:80...
* connect to 10.81.x.x port 80 failed: Timed out
* Failed to connect to 10.81.x.x port 80 after 21033 ms: Timed out
* Closing connection 0
curl: (28) Failed to connect to 10.81.x.x port 80 after 21033 ms: Timed out
```

## Cause

If you experience the same "Timed out" error every time, that usually suggests that a network component is blocking the traffic.

To troubleshoot this issue, you can start by checking access to the pod, and then move on to the client in an *inside-out* approach.

To check the pod, run the following `kubectl get` and [kubectl describe](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) commands:

```console
$ kubectl get pods -o wide
NAME                             READY   STATUS    RESTARTS   AGE   IP            NODE                               
my-deployment-66648877fc-v78jm   1/1     Running   0          53s   172.25.0.93   aks-agentpool-42617579-vmss000000

$ kubectl describe pod my-deployment-66648877fc-v78jm  # Specify the pod name from the previous command.
...
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  117s  default-scheduler  Successfully assigned default/my-deployment-66648877fc-v78jm to aks-agentpool-42617579-vmss000000
  Normal  Pulling    116s  kubelet            Pulling image "httpd"
  Normal  Pulled     116s  kubelet            Successfully pulled image "httpd" in 183.532816ms
  Normal  Created    116s  kubelet            Created container webserver
  Normal  Started    116s  kubelet            Started container webserver
```

Based on this output, the pod seems to be running correctly, without any restarts.

Open a test pod to check access to the application pod. Run the following `kubectl get`, [kubectl run](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run), `apt-get`, and cURL commands:

```console
$ kubectl get pods -o wide  # Get the pod IP address.
NAME                             READY   STATUS    RESTARTS   AGE     IP            NODE                                
my-deployment-66648877fc-v78jm   1/1     Running   0          7m45s   172.25.0.93   aks-agentpool-42617579-vmss000000  

$ kubectl run -it --rm aks-ssh --image=debian:stable  # Launch the test pod.
If you don't see a command prompt, try pressing enter.
$ root@aks-ssh:

$ # Install packages inside the test pod.
$ root@aks-ssh: apt-get update -y && apt-get install dnsutils -y && apt-get install curl -y
Get:1 http://deb.debian.org/debian bullseye InRelease [116 kB]
Get:2 http://deb.debian.org/debian bullseye-updates InRelease [39.4 kB]
...
...
Running hooks in /etc/ca-certificates/update.d...
done.

$ # Try to check access to the pod using the pod IP address from the "kubectl get" output.
$ curl -Iv http://172.25.0.93
*   Trying 172.25.0.93:80...
* Connected to 172.25.0.93 (172.25.0.93) port 80 (#0)
...
...
< HTTP/1.1 200 OK
HTTP/1.1 200 OK
...
...
* Connection #0 to host 172.25.0.93 left intact
```

The pod is accessible directly. Therefore, the application is running.

The defined service is a `LoadBalancer` type. This means that the request flow from the end client to the pod will be as follows:

> 
> Client &gt;&gt; Load balancer &gt;&gt; AKS node &gt;&gt; Application pod

In this request flow, we can block the traffic through the following components:

- Network policies in the cluster
- The network security group (NSG) for the AKS subnet and AKS node

To check network policy, run the following `kubectl get` command:

```console
$ kubectl get networkpolicy --all-namespaces
NAMESPACE     NAME                 POD-SELECTOR             AGE
kube-system   konnectivity-agent   app=konnectivity-agent   3h8m
```

Only the AKS default policy exists. Therefore, network policy doesn't seem to be blocking the traffic.

To check the NSGs and their associated rules by using AKS, follow these steps:

1. In the [Azure portal](https://portal.azure.com), search for and select **Virtual machine scale sets**.
2. In the list of scale set instances, select the one that you're using.
3. In the menu pane of your scale set instance, select `Networking`.

The **Networking** page for the scale set instance appears. In the **Inbound port rules** tab, two sets of rules are displayed that are based on the two NSGs that act on the scale set instance:

- The first set is composed of NSG rules at the subnet level. These rules are displayed under the following note heading:

> 
> Network security group *&lt;my-aks-nsg&gt;* (attached to subnet: *&lt;my-aks-subnet&gt;*)

    This arrangement is common if a custom virtual network and custom subnet for the AKS cluster are used. The set of rules at the subnet level might resemble the following table.

    | Priority | Name | Port | Protocol | Source | Destination | Action |
    | --- | --- | --- | --- | --- | --- | --- |
    | 65000 | AllowVnetInBound | Any | Any | VirtualNetwork | VirtualNetwork | Allow |
    | 65001 | AllowAzureLoadBalancerInBound | Any | Any | AzureLoadBalancer | Any | Allow |
    | 65500 | DenyAllInBound | Any | Any | Any | Any | Deny |
- The second set is composed of NSG rules at the network adapter level. These rules are displayed under the following note heading:

> 
> Network security group *aks-agentpool-&lt;agentpool-number&gt;-nsg* (attached to network interface: *aks-agentpool-&lt;vm-scale-set-number&gt;-vmss*)

    This NSG is applied by the AKS cluster, and it's managed by AKS. The corresponding set of rules might resemble the following table.

    | Priority | Name | Port | Protocol | Source | Destination | Action |
    | --- | --- | --- | --- | --- | --- | --- |
    | **500** | **&lt;guid&gt;-TCP-80-Internet** | **80** | **TCP** | **Internet** | **10.81.*x*.*x*** | **Allow** |
    | 65000 | AllowVnetInBound | Any | Any | VirtualNetwork | VirtualNetwork | Allow |
    | 65001 | AllowAzureLoadBalancerInBound | Any | Any | AzureLoadBalancer | Any | Allow |
    | 65500 | DenyAllInBound | Any | Any | Any | Any | Deny |

At the network adapter level, there's an NSG inbound rule for TCP at IP address 10.81.*x*.*x* on port 80 (highlighted in the table). However, an equivalent rule is missing from the rules for the NSG at the subnet level.

Why didn't AKS apply the rule to the custom NSG? Because AKS doesn't apply NSGs to its subnet, and it won't modify any of the NSGs that are associated with that subnet. AKS will modify the NSGs only at the network adapter level. For more information, see [Can I configure NSGs with AKS?](/en-us/azure/aks/faq#can-i-configure-nsgs-with-aks).

## Solution

If the application is enabled for access on a certain port, you must make sure that the custom NSG allows that port as an `Inbound` rule. After the appropriate rule is added in the custom NSG at the subnet level, the application is accessible.

```console
$ curl -Iv http://10.81.x.x
*   Trying 10.81.x.x:80...
* Connected to 10.81.x.x (10.81.x.x) port 80 (#0)
...
...
< HTTP/1.1 200 OK
HTTP/1.1 200 OK
...
...
* Connection #0 to host 10.81.x.x left intact
```