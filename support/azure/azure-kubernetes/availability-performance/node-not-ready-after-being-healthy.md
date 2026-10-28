---
layout: Conceptual
title: Node Not Ready status after node is in a healthy state - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/node-not-ready-after-being-healthy
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
description: Learn how to troubleshoot an AKS node that changes to Not Ready after a healthy state. Follow these steps to find the cause and restore your cluster.
ms.date: 2026-10-26T00:00:00.0000000Z
ms.reviewer: rissing, chiragpa, momajed, v-leedennis, ookour, kaushika
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance, innovation-engine
ai-usage: ai-assisted
locale: en-us
document_id: 64c658c0-dfba-771f-b99c-dbb8827551ba
document_version_independent_id: 64c658c0-dfba-771f-b99c-dbb8827551ba
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/node-not-ready-after-being-healthy.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/node-not-ready-after-being-healthy
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/node-not-ready-after-being-healthy.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 29a9f740-aee3-a7ef-813d-b7dbbfd43001
---

# Node Not Ready status after node is in a healthy state - Azure | Microsoft Learn

## Summary

This article explains how to troubleshoot an Azure Kubernetes Service (AKS) node that changes to **Not Ready** after staying healthy for some time. It describes the cause and shows how to restore the node to a healthy state.

## Prerequisites

To troubleshoot an AKS node that changes to **Not Ready** status, you need the following prerequisites:

- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool. To install kubectl by using Azure CLI, run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.
- The Kubernetes [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/) tool.
- The Kubernetes [containerd](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd) tool.
- The following Linux tools:
    - [awk](https://man7.org/linux/man-pages/man1/awk.1p.html)
    - [head](https://man7.org/linux/man-pages/man1/head.1.html)
    - [journalctl](https://man7.org/linux/man-pages/man1/journalctl.1.html)
    - [ps](https://man7.org/linux/man-pages/man1/ps.1.html)
    - [sort](https://man7.org/linux/man-pages/man1/sort.1.html)
    - [watch](https://man7.org/linux/man-pages/man1/watch.1.html)

## Connect to the AKS cluster

Before you can troubleshoot the issue, you must connect to the AKS cluster. To do so, run the following commands.

```bash
export RANDOM_SUFFIX=$(head -c 3 /dev/urandom | xxd -p)
export RESOURCE_GROUP="my-resource-group$RANDOM_SUFFIX"
export AKS_CLUSTER="my-aks-cluster$RANDOM_SUFFIX"
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --overwrite-existing
```

## Symptoms

The status of a cluster node that has a healthy state (all services running) unexpectedly changes to **Not Ready**. To view the status of a node, run the following [kubectl describe](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe) command.

```bash
kubectl describe nodes
```

## Cause

The [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/) stops posting its **Ready** status.

Check the output of the `kubectl describe nodes` command to find the [Conditions](https://kubernetes.io/docs/reference/node/node-status/#condition) field and the [Capacity and Allocatable](https://kubernetes.io/docs/reference/node/node-status/#capacity) blocks. Do the contents of these fields appear as expected? For example, in the **Conditions** field, does the `message` property contain the "kubelet is posting ready status" string? If you have direct Secure Shell (SSH) access to the node, check the recent events to understand the error. Look within the */var/log/syslog* file instead of */var/log/messages* (not available on all distributions).

Note

If the affected node is still available, you can open a support ticket for assistance. However, if the node is deleted—manually or by the cluster autoscaler—you can't retrieve its logs unless a monitoring tool collected them. To learn more, see [Analyze Syslog data from Kubernetes cluster in Azure Monitor](/en-us/azure/azure-monitor/containers/container-insights-syslog).

## Solution

### Step 1: Check for changes at the network level

If all cluster nodes regressed to a **Not Ready** status, check whether any changes occurred at the network level. Examples of network-level changes include:

- Domain name system (DNS) changes.
- Firewall rule changes, like port, fully qualified domain names (FQDNs), and so on.
- Added network security groups (NSGs).
- Applied or changed route table configurations for AKS traffic.

If there were changes at the network level, make any necessary corrections. If you have direct Secure Shell (SSH) access to the node, use the `curl` or `telnet` command to check the connectivity to [AKS outbound requirements](/en-us/azure/aks/outbound-rules-control-egress). After you fix the issues, stop and restart the nodes. If the nodes stay in a healthy state after these fixes, you can safely skip the remaining steps.

### Step 2: Stop and restart the nodes

If only a few nodes show a **Not Ready** status, try restarting them as a temporary mitigation. This action might return the nodes to a healthy state. Then, check [Azure Kubernetes Service diagnostics overview](/en-us/azure/aks/concepts-diagnostics) to see if there are any problems, like the following issues:

- Node faults.
- Source network address translation (SNAT) failures.
- Node input/output operations per second (IOPS) performance problems.
- Other problems.

If the diagnostics don't find any underlying problems and the nodes return to Ready status, you can safely skip the remaining steps.

### Step 3: Fix SNAT issues for public AKS API clusters

Did AKS diagnostics find any SNAT problems? If so, take some of the following actions, as appropriate:

- Check whether your connections stay idle for a long time and rely on the default idle timeout to release their port. If the connections show this behavior, you might need to reduce the default timeout of 30 minutes.
- Find out how your application creates outbound connectivity. For example, does it use code review or packet capture?
- Find out whether this activity represents the expected behavior or, instead, it shows that the application is misbehaving. Use metrics and logs in Azure Monitor to back up your findings. For example, you can use the **Failed** category as a SNAT Connections metric.
- Check whether appropriate patterns are followed.
- Check whether you should fix SNAT port exhaustion by using extra outbound IP addresses and more allocated outbound ports. For more information, see [Scale the number of managed outbound public IPs](/en-us/azure/aks/load-balancer-standard#scale-the-number-of-managed-outbound-public-ips) and [Configure the allocated outbound ports](/en-us/azure/aks/load-balancer-standard#configure-the-allocated-outbound-ports).

For more information about how to troubleshoot SNAT port exhaustion, see [Troubleshoot SNAT port exhaustion on AKS nodes](../connectivity/snat-port-exhaustion?tabs=for-a-linux-pod).

### Step 4: Fix IOPS, CPU, and memory performance problems

If AKS diagnostics identifies conditions that degrade **IOPS performance** or cause **high CPU and memory utilization**, consider taking the following remedial actions:

- To increase IOPS on virtual machine (VM) scale sets, choose a larger disk size that offers better IOPS performance by deploying a new node pool. Direct resizing of VMSS isn't supported. For more information about resizing node pools, see [Resize node pools in Azure Kubernetes Service (AKS)](/en-us/azure/aks/resize-node-pool?tabs=azure-cli).
- Increase the node SKU size for more memory and CPU processing capability.
- Consider using [Ephemeral OS](/en-us/azure/aks/cluster-configuration#ephemeral-os).
- Limit the CPU and memory usage for pods. These limits help prevent node CPU consumption and out-of-memory situations.
- Use scheduling topology methods to add more nodes and distribute the load among the nodes. For more information, see [Pod topology spread constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/).

### Step 5: Fix threading problems

Kubernetes components like kubelets and [containerd runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd) rely heavily on threading, and they regularly create new threads. If the system can't allocate new threads, this failure can affect service readiness, as follows:

- The node status changes to **Not Ready**, but a remediator restarts the node and recovers it.
- The */var/log/messages* and */var/log/syslog* log files show repeated occurrences of the following error entries:

> 
> pthread\_create failed: Resource temporarily unavailable by various processes

    The processes that are cited include containerd and possibly kubelet.
- The node status changes to **Not Ready** soon after the `pthread_create` failure entries are written to the log files.

Process IDs (PIDs) represent threads. The default number of PIDs that a pod can use might depend on the operating system. However, the default number is at least 32,768. This number provides more than enough PIDs for most situations. Are there any known application requirements for higher PID resources? If there aren't, even an eight-fold increase to 262,144 PIDs might not be enough to accommodate a high-resource application.

Instead, identify the problematic application, and then take the appropriate action. Consider other options, like increasing the VM size or upgrading AKS. These actions can mitigate the issue temporarily, but they aren't a guarantee that the issue won't reappear.

To monitor the thread count for each control group (cgroup) and print the top eight cgroups, run the following shell command.

```bash
# Show current thread count for each cgroup (top 8)
ps -e -w -o "thcount,cgname" --no-headers | awk '{a[$2] += $1} END{for (i in a) print a[i], i}' | sort --numeric-sort --reverse | head --lines=8
```

For more information, see [Process ID limits and reservations](https://kubernetes.io/docs/concepts/policy/pid-limiting/).

Kubernetes offers two methods to manage PID exhaustion at the node level:

1. Configure the maximum number of PIDs that a pod can use within a kubelet by using the `--pod-max-pids` parameter. This configuration sets the `pids.max` setting within the cgroup of each pod. You can also use the `--system-reserved` and `--kube-reserved` parameters to configure the system and kubelet limits, respectively.
2. Configure PID-based eviction.

Note

By default, neither of these methods is set up. Additionally, you can't currently configure either method by using [Node configuration for AKS node pools](/en-us/azure/aks/custom-node-configuration).

### Step 6: Use a higher service tier

To ensure the AKS API server is highly available, use a higher service tier. For more information, see the [Azure Kubernetes Service (AKS) Uptime SLA](/en-us/azure/aks/uptime-sla).

## References

- To view the health and performance of the AKS API server and kubelets, see [Managed AKS components](/en-us/azure/aks/monitor-aks#level-2---managed-aks-components).
- For general troubleshooting steps, see [Basic troubleshooting of node not ready failures](node-not-ready-basic-troubleshooting).