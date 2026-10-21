---
layout: Conceptual
title: Identify containers causing high disk I/O latency in AKS clusters - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/identify-high-disk-io-latency-containers-aks
breadcrumb_path: /support/breadcrumb/toc.json
feedback_system: Standard
recommendations: true
uhfHeaderId: Azure
feedback_product_url: https://feedback.azure.com/d365community/forum/aabe212a-f724-ec11-b6e6-000d3a4f0da0
manager: dcscontentpm
audience: itpro
author: kaushika-msft
ms.author: burakok
ms.topic: troubleshooting
description: Identify containers and pods causing high disk I/O latency in AKS, and troubleshoot faster with Inspektor Gadget. Start diagnosing bottlenecks now.
ms.date: 2025-07-16T00:00:00.0000000Z
ms.reviewer: burakok, mayasingh, blanquicet
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance
locale: en-us
document_id: 8d11e631-993f-58ce-b8a2-ad0e3ab02914
document_version_independent_id: 8d11e631-993f-58ce-b8a2-ad0e3ab02914
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/identify-high-disk-io-latency-containers-aks.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/identify-high-disk-io-latency-containers-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/identify-high-disk-io-latency-containers-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 608bcdf3-6ffe-bca9-5d5a-1470c6ed2876
---

# Identify containers causing high disk I/O latency in AKS clusters - Azure | Microsoft Learn

## Summary

Disk I/O latency can severely affect the performance and reliability of workloads running in Azure Kubernetes Service (AKS) clusters. This article shows how to use the open source project [Inspektor Gadget](https://aka.ms/ig-website) to identify which containers and pods cause high disk I/O latency in AKS.

Inspektor Gadget provides eBPF-based gadgets that help you observe and troubleshoot disk I/O problems in Kubernetes environments.

## Symptoms

You might suspect disk I/O latency problems when you observe the following behaviors in your AKS cluster:

- Applications become unresponsive during file operations.
- [Azure Portal metrics](/en-us/azure/aks/monitor-aks-reference#supported-metrics-for-microsoftcomputevirtualmachines)(`Data Disk Bandwidth Consumed Percentage` and `Data Disk IOPS Consumed Percentage`) or other system monitoring shows high disk utilization with low throughput.
- Database operations take significantly longer than expected.
- Pod logs show file system operation errors or timeouts.

## Prerequisites

- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) command-line tool. To install kubectl by using [Azure CLI](/en-us/cli/azure/install-azure-cli), run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.
- Access to your AKS cluster with sufficient permissions to run privileged pods.
- The open source project [Inspektor Gadget](../logs/capture-system-insights-from-aks#what-is-inspektor-gadget) for eBPF-based observability. For more information, see [How to install Inspektor Gadget in an AKS cluster](../logs/capture-system-insights-from-aks#how-to-install-inspektor-gadget-in-an-aks-cluster).

Note

The `top_blockio` gadget requires kernel version 6.5 or later. You can verify your AKS node kernel version by running `kubectl get nodes -o wide` to see the kernel version in the KERNEL-VERSION column.

## Troubleshooting checklist

### Step 1: Profile disk I/O latency by using `profile_blockio`

The [`profile_blockio`](https://aka.ms/ig-profile-blockio) gadget collects information about block device I/O usage and periodically generates a histogram distribution of I/O latency. This data helps you visualize disk I/O performance and identify latency patterns. Use this information to gather evidence that supports or refutes the hypothesis that the symptoms you're seeing are due to disk I/O problems.

```console
kubectl gadget run profile_blockio --node <node-name>
```

Note

You must specify a node by using the `--node` parameter when you use the `profile_blockio` gadget. Run `kubectl get nodes` to get node names.

**Baseline example** (empty cluster with minimal activity):

```
latency
        µs               : count    distribution
         0 -> 1          : 0        |                                        |
         1 -> 2          : 0        |                                        |
         2 -> 4          : 0        |                                        |
         4 -> 8          : 0        |                                        |
         8 -> 16         : 0        |                                        |
        16 -> 32         : 0        |                                        |
        32 -> 64         : 70       |                                        |
        64 -> 128        : 22       |                                        |
       128 -> 256        : 6        |                                        |
       256 -> 512        : 16       |                                        |
       512 -> 1024       : 1017     |*********                               |
      1024 -> 2048       : 2205     |********************                    |
      2048 -> 4096       : 2740     |**************************              |
      4096 -> 8192       : 1128     |**********                              |
      8192 -> 16384      : 708      |******                                  |
     16384 -> 32768      : 4211     |****************************************|
     32768 -> 65536      : 129      |*                                       |
     65536 -> 131072     : 185      |*                                       |
    131072 -> 262144     : 402      |***                                     |
    262144 -> 524288     : 112      |*                                       |
    524288 -> 1048576    : 0        |                                        |
   1048576 -> 2097152    : 0        |                                        |
   2097152 -> 4194304    : 0        |                                        |
   4194304 -> 8388608    : 0        |                                        |
   8388608 -> 16777216   : 0        |                                        |
  16777216 -> 33554432   : 0        |                                        |
  33554432 -> 67108864   : 0        |                                        |
```

**High disk I/O stress example** (with `stress-ng --hdd 10 --io 10` running to simulate I/O load):

```
latency
        µs               : count    distribution
         0 -> 1          : 0        |                                        |
         1 -> 2          : 0        |                                        |
         2 -> 4          : 0        |                                        |
         4 -> 8          : 0        |                                        |
         8 -> 16         : 42       |                                        |
        16 -> 32         : 236      |                                        |
        32 -> 64         : 558      |*                                       |
        64 -> 128        : 201      |                                        |
       128 -> 256        : 147      |                                        |
       256 -> 512        : 62       |                                        |
       512 -> 1024       : 2660     |******                                  |
      1024 -> 2048       : 6376     |***************                         |
      2048 -> 4096       : 8374     |********************                    |
      4096 -> 8192       : 3912     |*********                               |
      8192 -> 16384      : 2099     |*****                                   |
     16384 -> 32768      : 16703    |****************************************|
     32768 -> 65536      : 1718     |****                                    |
     65536 -> 131072     : 5758     |*************                           |
    131072 -> 262144     : 9552     |**********************                  |
    262144 -> 524288     : 6778     |****************                        |
    524288 -> 1048576    : 347      |                                        |
   1048576 -> 2097152    : 16       |                                        |
   2097152 -> 4194304    : 0        |                                        |
   4194304 -> 8388608    : 0        |                                        |
   8388608 -> 16777216   : 0        |                                        |
  16777216 -> 33554432   : 0        |                                        |
  33554432 -> 67108864   : 0        |                                        |
```

**Interpreting the results**: To identify which node has I/O pressure, compare the baseline and stress scenarios:

- **Baseline**: Most operations (4,211 count) are in the 16-32 ms range, which is typical for normal system activity.
- **Under stress**: Significantly more operations are in higher latency ranges (9,552 operations in 131-262 ms, 6,778 in 262-524 ms).
- **Performance degradation**: The stress test shows operations extending into the 500 ms-2 s range, which indicates disk saturation.
- **Concerning signs**: Look for high counts above 100 ms (100,000 µs) that might indicate disk performance problems.

### Step 2: Find top disk I/O consumers with `top_blockio`

The [`top_blockio`](https://aka.ms/ig-top-blockio) gadget provides a periodic list of containers with the highest disk I/O operations. You can optionally limit the tracing to the node you identified in Step 1. This gadget requires kernel version 6.5 or higher (available on [Azure Linux Container Host clusters](/en-us/azure/aks/use-azure-linux)).

```console
kubectl gadget run top_blockio --namespace <namespace> --sort -bytes [--node <node-name>]
```

Sample output:

```
K8S.NODE                      K8S.NAMESPACE   K8S.PODNAME   K8S.CONTAINERNAME   COMM     PID  TID MAJOR MINOR BYTES      US         IO    RW
aks-nodepool1-…99-vmss000000                                                               0    0 8     0     173707264  153873788  11954 write
aks-nodepool1-…99-vmss000000                                                               0    0 8     0     352256     85222      36    read 
aks-nodepool1-…99-vmss000000  default         stress-hdd    stress-hdd          stress  324… 324… 8     0     131072     4450       1     write
aks-nodepool1-…99-vmss000000  default         stress-hdd    stress-hdd          stress  324… 324… 8     0     131072     3651       1     write
aks-nodepool1-…99-vmss000000  default         stress-hdd    stress-hdd          stress  324… 324… 8     0     4096       4096       1     write
```

From the output, you can identify containers with an unusually high number of bytes read or written to the disk (`BYTES` column), time spent on reading or writing operations (`US` column), or number of I/O operations (`IO` column), which might indicate high disk activity. In this example, you see significant write activity (173 MB) with considerable time spent (~154 seconds total).

Note

Empty K8S.NAMESPACE, K8S.PODNAME, and K8S.CONTAINERNAME fields can occur during kernel space initiated operations or high-volume I/O. You can still use the `top_file` gadget for detailed process information when these fields are empty.

### Step 3: Identify files causing high disk activity with `top_file`

The [`top_file`](https://aka.ms/ig-top-file) gadget reports periodically the read/write activity by file, helping you identify specific processes in which containers are causing high disk activity.

```console
kubectl gadget run top_file --namespace <namespace> --max-entries 20 --sort -wbytes_raw,-rbytes_raw
```

Sample output:

```
K8S.NODE                      K8S.NAMESPACE   K8S.PODNAME   K8S.CONTAINERNAME   COMM     PID    TID   READS WRITES FILE              T RBYTES WBYTES
aks-nodepool1-…99-vmss000000  default         stress-hdd    stress-hdd          stress   49258  49258 0     17     /stress.ADneNJ    R 0 B    18 MB
aks-nodepool1-…99-vmss000000  default         stress-hdd    stress-hdd          stress   49254  49254 0     20     /stress.LEbDOb    R 0 B    21 MB
aks-nodepool1-…99-vmss000000  default         stress-hdd    stress-hdd          stress   49252  49252 0     18     /stress.eMOjmP    R 0 B    19 MB
aks-nodepool1-…99-vmss000000  default         stress-hdd    stress-hdd          stress   49264  49264 0     22     /stress.fLHpBC    R 0 B    23 MB
...
```

This output shows which files are being accessed most frequently, helping you pinpoint what specific file a given process is reading or writing the most. In this example, the stress-hdd pod is creating multiple temporary files with significant write activity (18-23 MB each).

### Root cause analysis workflow

By combining all three gadgets, you can trace disk latency problems from symptoms to root cause:

1. **`profile_blockio`** identifies that disk latency exists in a given node (high counts in 100 ms+ ranges).
2. **`top_blockio`** shows which processes generate the most disk I/O (173 MB writes with 154 seconds total time spent).
3. **`top_file`** reveals the specific files and commands causing the problem (stress command creating `/stress.*` files).

This complete visibility allows you to:

- **Identify the problematic pod**: `stress-hdd` pod in the `default` namespace.
- **Find the specific process**: `stress` command with PIDs 49258, 49254, and others.
- **Locate the problematic files**: Multiple `/stress.*` temporary files with 18-23 MB each.
- **Understand the I/O pattern**: Heavy write operations creating temporary files.

Use this information to take targeted action instead of making broad system changes.