---
layout: Conceptual
title: Capture a TCP dump from a Linux node in an AKS cluster - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/logs/capture-tcp-dump-linux-node-aks
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: kaushika
ms.topic: how-to
description: Learn how to capture a TCP dump from a Linux node in an AKS cluster to troubleshoot network issues quickly. Follow the steps and start diagnosing now.
ms.date: 2026-06-11T00:00:00.0000000Z
ms.reviewer: erbookbi, amaljuna, kuzhao, v-rekhanain, v-leedennis, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Monitoring and Logging, linux-related-content
locale: en-us
document_id: 44ea4d31-2301-3b93-f04a-a60b3ebf1661
document_version_independent_id: 44ea4d31-2301-3b93-f04a-a60b3ebf1661
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/logs/capture-tcp-dump-linux-node-aks.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/logs/capture-tcp-dump-linux-node-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/logs/capture-tcp-dump-linux-node-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 3a019afb-0051-0959-e89e-a274c46933da
---

# Capture a TCP dump from a Linux node in an AKS cluster - Azure | Microsoft Learn

## Summary

Networking problems can occur when you use a Microsoft Azure Kubernetes Service (AKS) cluster. To help you investigate these problems, this article explains how to capture a TCP dump from a Linux node in an AKS cluster, and then download the capture to your local machine.

## Prerequisites

- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool. To install kubectl by using [Azure CLI](/en-us/cli/azure/install-azure-cli-linux), run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.
- An AKS cluster. If you don't have an AKS cluster, [create one using Azure CLI](/en-us/azure/aks/kubernetes-walkthrough) or [through the Azure portal](/en-us/azure/aks/kubernetes-walkthrough-portal).
- The [tcpdump](https://www.tcpdump.org/) command-line tool installed on the Linux node.

Note

You can automate TCP capture through a [Helm chart](https://helm.sh/docs/topics/charts/), which can run in the background as a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). For more information, see this [custom GitHub tool for capturing TCP dumps](https://github.com/amjadaljunaidi/tcpdump), or use the steps in the following sections.

## Step 1: Find the nodes to troubleshoot

How do you determine which node to pull the TCP dump from? First, get the list of nodes in the AKS cluster by using the Kubernetes command-line client, [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/). Follow the instructions to connect to the cluster and run the `kubectl get nodes --output wide` command [using the Azure portal](/en-us/azure/aks/kubernetes-walkthrough-portal#connect-to-the-cluster) or [Azure CLI](/en-us/azure/aks/kubernetes-walkthrough#connect-to-the-cluster). A node list that's similar to the following output appears:

```console
$ kubectl get nodes --output wide
NAME                                STATUS   ROLES   AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION     CONTAINER-RUNTIME
aks-agentpool-34796016-vmss000000   Ready    agent   45h   v1.20.9   10.240.1.81    <none>        Ubuntu 18.04.6 LTS               5.4.0-1062-azure   containerd://1.4.9+azure
aks-agentpool-34796016-vmss000002   Ready    agent   45h   v1.20.9   10.240.2.47    <none>        Ubuntu 18.04.6 LTS               5.4.0-1062-azure   containerd://1.4.9+azure
```

## Step 2: Connect to a Linux node

The next step is to establish a connection to the AKS cluster node that you want to capture the network trace from. For more information, see [Create an interactive shell connection to a Linux node](/en-us/azure/aks/node-access#create-an-interactive-shell-connection-to-a-linux-node).

## Step 3: Make sure tcpdump is installed

After you connect to the AKS Linux node, verify that the tcpdump tool is installed on the node by running `tcpdump --version`. If tcpdump isn't installed, you see the following error text:

```console
# tcpdump --version
bash: tcpdump: command not found
```

Then install tcpdump on your pod by running the Advanced Package Tool's package handling utility, [apt-get](https://manpages.debian.org/bullseye/apt/apt-get.8.en.html):

```bash
apt-get update && apt-get install tcpdump
```

If tcpdump is installed, you see output similar to the following text:

```console
# tcpdump --version
tcpdump version 4.9.3
libpcap version 1.8.1
OpenSSL 1.1.1  11 Sep 2018
```

## Step 4: Create a packet capture

To capture the dump, run the [tcpdump command](https://www.tcpdump.org/manpages/tcpdump.1.html) as follows:

```console
# tcpdump --snapshot-length=0 -vvv -w /capture.cap
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
Got 6
```

Note

Running tcpdump without filtering parameters can significantly increase the size of the Packet Capture (PCAP) file, especially for long runs. Therefore, add filters like source, destination, and port. For example:

- `tcpdump dst 192.168.1.100`
- `tcpdump dst host.mydomain.com`
- `tcpdump port http or port ftp or port smtp or port imap or port pop3 or port telnet`

While the trace is running, replicate your issue many times. This action ensures that the issue is captured within the TCP dump. Note the time stamp while you replicate the issue. To stop the packet capture when you're done, press Ctrl+C:

```console
# tcpdump -s 0 -vvv -w /capture.cap
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
^C526 packets captured
526 packets received by filter
0 packets dropped by kernel
```

## Step 5: Capture traffic for a specific pod from the node

In some scenarios, you might need to capture traffic for a specific pod from the node hosting the pod instead of performing a packet capture within the pod itself. This method is useful when packet capture tools aren't available in the container image, security restrictions prevent running packet capture utilities inside the pod, or the pod is restarting frequently.

Note

Ensure that you create the debug pod on the same node that hosts the affected pod. Otherwise, the packet capture might not contain the pod's traffic.

1. Identify the pod IP address and the node hosting the pod by running the following command.

```console
kubectl get pod <pod-name> -n <namespace> -o wide
Example output:
NAME        READY   STATUS    IP            NODE
sample-pod  1/1     Running   10.244.1.15   aks-nodepool1-12345678-vmss000001
```

Record the pod IP address and node name.

1. Create a debug pod on the node hosting the affected pod.

```console
kubectl debug node/<node-name> -it --image=mcr.microsoft.com/cbl-mariner/busybox:2.0
```

1. Access the host filesystem.

```console
chroot /host
```

1. Start the packet capture. Capture all traffic to and from the pod by filtering on the pod IP address.

```console
tcpdump -i any host <pod-ip-address> -vvv -w /tmp/pod-capture.pcap
```

The following example shows the command with the pod IP address.

```console
tcpdump -i any host 10.244.1.15 -vvv -w /tmp/pod-capture.pcap
```

1. Reproduce the issue while the packet capture is running. After the issue is reproduced, stop the packet capture by pressing Ctrl+C.
2. Copy the packet capture file from the debug pod to your local machine.

```console
kubectl cp <namespace>/<debug-pod-name>:/host/tmp/pod-capture.pcap ./pod-capture.pcap
```

1. Delete the debug pod after the packet capture is collected.

```console
kubectl delete pod <debug-pod-name>
```

## Step 6: Transfer the capture locally

After you complete the packet capture, identify the helper pod so you can copy the dump locally. Open a second console, and then get a list of pods by running `kubectl get pods`, as shown in the following example.

```console
$ kubectl get pods
NAME                                                    READY   STATUS    RESTARTS   AGE
azure-vote-back-6c4dd64bdf-m4nk7                        1/1     Running   0          3m29s
azure-vote-front-85b4df594d-jhpzw                       1/1     Running   0          3m29s
node-debugger-aks-nodepool1-38878740-vmss000000-jfsq2   1/1     Running   0          60s
```

The helper pod has a prefix of `node-debugger-aks`, as shown in the third row. Replace the pod name, and then run the following kubectl command. These commands retrieve the packet capture for your Linux node.

```bash
kubectl cp node-debugger-aks-nodepool1-38878740-vmss000000-jfsq2:/capture.cap capture.cap
```

Note

If you use the `chroot /host` command when entering the debug pod, add `/host` before `/capture.cap` for the source file.

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.