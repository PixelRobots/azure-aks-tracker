---
layout: Conceptual
title: Troubleshoot High Memory Consumption in Disk-Intensive Applications - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/high-memory-consumption-disk-intensive-applications
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
description: Learn how to troubleshoot high memory consumption in disk-intensive Kubernetes pods caused by Linux kernel caching, and apply fixes to reduce memory pressure.
ms.date: 2025-04-30T00:00:00.0000000Z
ms.reviewer: claudiogodoy, v-weizhu
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance
locale: en-us
document_id: 7e7bf45d-b718-333d-a1d8-19c7bdd7337d
document_version_independent_id: 7e7bf45d-b718-333d-a1d8-19c7bdd7337d
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/high-memory-consumption-disk-intensive-applications.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/high-memory-consumption-disk-intensive-applications
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/high-memory-consumption-disk-intensive-applications.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: d7004d35-6d24-83a6-6163-ac1fc2b2b234
---

# Troubleshoot High Memory Consumption in Disk-Intensive Applications - Azure | Microsoft Learn

## Summary

Disk input and output operations are costly. Most operating systems implement caching strategies for reading and writing data to the filesystem. The [Linux kernel](https://www.kernel.org/doc) usually uses strategies like the [page cache](https://www.kernel.org/doc/gorman/html/understand/understand013.html) to improve overall performance. The primary goal of the page cache is to store data read from the filesystem in the cache, making it available in memory for future read operations.

This article helps you identify and avoid high memory consumption in disk-intensive applications due to Linux kernel behaviors on Kubernetes pods.

## Prerequisites

A tool to connect to the Kubernetes cluster, like the `kubectl` tool. To install `kubectl` by using the [Azure CLI](/en-us/cli/azure/install-azure-cli), run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.

## Symptoms

When a disk-intensive application running on a pod performs frequent filesystem operations, high memory consumption might occur.

The following table outlines common symptoms of high memory consumption:

| Symptom | Description |
| --- | --- |
| The [working set](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/#memory) metric is too high. | This issue occurs when there's a significant difference between the [working set](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/#memory) metric reported by the [Kubernetes Metrics API](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/#metrics-server) and the actual memory consumed by an application. |
| Out-of-memory (OOM) kill. | This issue indicates memory problems exist on your pod. |
| Increased memory usage after heavy disk activity. | After operations like backups, large file reads/writes, or data imports, memory consumption rises. |
| Memory usage grows indefinitely. | The pod's memory consumption increases over time without reducing, like a memory leak, even if the application itself isn't leaking memory. |

## Troubleshooting checklist

### Step 1: Inspect the pod working set

To inspect the working set of pods that the Kubernetes Metrics API reports, run the following [kubectl top pods](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/) command:

```console
$ kubectl top pods -A | grep -i "<DEPLOYMENT_NAME>"
NAME                            CPU(cores)   MEMORY(bytes)
my-deployment-fc94b7f98-m9z2l   1m           344Mi
```

For detailed steps about how to identify which pod is consuming excessive memory, see [Troubleshoot memory saturation in AKS clusters](identify-memory-saturation-aks)

### Step 2: Inspect pod memory statistics

To inspect the memory statistics of the [cgroups](https://kubernetes.io/docs/concepts/architecture/cgroups/) on the pod that's consuming excessive memory, follow these steps:

Note

[Cgroups](https://kubernetes.io/docs/concepts/architecture/cgroups/) help enforce resource management for pods and containers, including CPU and memory requests and limits for containerized workloads.

1. Connect to the pod:

    ```console
    $ kubectl exec <POD_NAME> -it -- bash
    ```
2. Go to the `cgroup` statistics directory and list the memory-related files:

    ```console
    $ ls /sys/fs/cgroup | grep -e memory.stat -e memory.current
    memory.current memory.stat
    ```

    - `memory.current`: Total memory currently used by the `cgroup` and its descendants.
    - `memory.stat`: This file breaks down the cgroup's memory footprint into different types of memory, type-specific details, and other information about the state and past events of the memory management system.

    All the values listed in those files are in bytes.
3. Get an overview of how memory consumption is distributed on the pod:

    ```console
    $ cat /sys/fs/cgroup/memory.current
    10645012480
    $ cat /sys/fs/cgroup/memory.stat
    anon 5197824
    inactive_anon 5152768
    active_anon 8192
    ...
    file 10256240640
    active_file 32768
    inactive_file 10256207872
    ...
    slab 354682456
    slab_reclaimable 354554400
    slab_unreclaimable 128056
    ...
    ```

    `cAdvisor` uses `memory.current` and `inactive_file` to compute the working set metric. You can replicate the calculation by using the following formula:

    `working_set = (memory.current - inactive_file) / 1048576 = (10645012480 - 10256207872) / 1048576 = 370 MB`

### Step 3: Determine kernel and application memory consumption

The following table describes some memory segments:

| Segment | Description |
| --- | --- |
| `anon` | The amount of memory used in anonymous mappings. Most languages use this segment to allocate memory. |
| `file` | The amount of memory used to cache filesystem data, including tmpfs and shared memory. |
| `slab` | The amount of memory used to store data structures in the Linux kernel. |

Combined with Step 2, `anon` represents 5,197,824 bytes, which isn't close to the total amount reported by the working set metric. The `slab` memory segment used by the Linux kernel represents 354,682,456 bytes, which is almost all the memory reported by the working set metric on the pod.

### Step 4: Drop the kernel cache on a debugger pod

Note

This step might cause availability and performance problems. Don't run it in a production environment.

1. Get the node running the pod:

    ```console
    $ kubectl get pod -A -o wide | grep "<POD_NAME>"
    NAME                            READY   STATUS    RESTARTS   AGE   IP            NODE                                NOMINATED NODE   READINESS GATES
    my-deployment-fc94b7f98-m9z2l   1/1     Running   0          37m   10.244.1.17   aks-agentpool-26052128-vmss000004   <none>           <none>
    ```
2. Create a debugger pod by using the [kubectl debug](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_debug/) command and start a `kubectl` session:

    ```console
    $ kubectl debug node/<NODE_NAME> -it --image=mcr.microsoft.com/cbl-mariner/busybox:2.0
    $ chroot /host
    ```
3. Drop the kernel cache:

    ```console
    echo 1 > /proc/sys/vm/drop_caches
    ```
4. Check if the command in the previous step causes any effect by repeating Step 1 and Step 2:

    ```console
    $ kubectl top pods -A | grep -i "<DEPLOYMENT_NAME>"
    NAME                            CPU(cores)   MEMORY(bytes)
    my-deployment-fc94b7f98-m9z2l   1m           4Mi
    
    $ kubectl exec <POD_NAME> -it -- cat /sys/fs/cgroup/memory.stat
    anon 4632576
    file 1781760
    ...
    slab_reclaimable 219312
    slab_unreclaimable 173456
    slab 392768
    ```

If you see a significant decrease in both the working set and the `slab` memory segment, you're experiencing a problem with the Linux kernel using a large amount of memory on the pod.

## Workaround: Configure appropriate memory limits and requests

The only effective workaround for high memory consumption on Kubernetes pods is to set realistic resource [limits and requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits). For example:

```yaml
resources:
    requests:
        memory: 30Mi
    limits:
        memory: 60Mi
```

By configuring appropriate memory limits and requests in Kubernetes or the specification, you can ensure that Kubernetes manages memory allocation more efficiently, reducing the impact of excessive kernel-level caching on pod memory usage.

Caution

Misconfigured pod memory limits can lead to problems like OOMKilled errors.

## References

- [Learn more about Azure Kubernetes Service (AKS) best practices](/en-us/azure/aks/best-practices)
- [Monitor your Kubernetes cluster performance with Container insights](/en-us/azure/azure-monitor/containers/container-insights-analyze)

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.