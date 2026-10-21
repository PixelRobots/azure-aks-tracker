---
layout: Conceptual
title: Identify high CPU usage in AKS clusters - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/identify-high-cpu-consuming-containers-aks
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
description: Learn how to identify nodes and pods causing high CPU usage in AKS clusters and apply best practices to improve performance and reliability.
ms.date: 2026-07-22T00:00:00.0000000Z
ms.reviewer: chiragpa, v-weizhu, angrif
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance
locale: en-us
document_id: f9a1c02e-775f-d7ce-1dd4-5db4fff746d0
document_version_independent_id: d488bf33-eeeb-8f7a-e8c7-689aa04e3847
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/identify-high-cpu-consuming-containers-aks.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/identify-high-cpu-consuming-containers-aks
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/identify-high-cpu-consuming-containers-aks.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 3ba937b2-aab6-e276-ec5d-ae5fda925d32
---

# Identify high CPU usage in AKS clusters - Azure | Microsoft Learn

Note

This article discusses high CPU utilization. In many situations, CPU Pressure Stall Information (PSI) metrics provide a more accurate indication of CPU pressure than utilization alone. For more information, see [Troubleshoot CPU pressure in AKS clusters using PSI metrics](troubleshoot-node-cpu-pressure-psi).

## Summary

High CPU usage is a symptom of one or more applications or processes that require so much CPU time that the performance or usability of the machine is impacted. High CPU usage can occur in many ways, but user configuration mostly causes it.

When a node in an [Azure Kubernetes Service (AKS)](/en-us/azure/aks/intro-kubernetes) cluster experiences high CPU usage, the applications running on it can experience degradation in performance and reliability. Applications or processes also become unstable, which might lead to problems beyond slow responses.

This article helps you identify the nodes and containers that consume high CPU and provides best practices to resolve high CPU usage.

## Symptoms

The following table outlines the common symptoms of high CPU usage:

| Symptom | Description |
| --- | --- |
| CPU starvation | CPU-intensive applications slow down other applications on the same node. |
| Slow state changes | Pods may take longer to get ready. |
| NotReady node state | Severe CPU contention can starve the kubelet of CPU time and prevent it from sending timely status updates to the API server. As a result, the node might be marked **NotReady**. |

## Troubleshoot high CPU usage in AKS

To resolve high CPU usage, use effective monitoring tools and apply best practices.

### Step 1: Identify nodes and containers with high CPU usage

Use either of the following methods to identify nodes and containers with high CPU usage:

- In a web browser, use the Container Insights feature of AKS in the Azure portal.
- In a console, use the Kubernetes command-line tool (kubectl).

# [Browser](#tab/browser)
[Container Insights](/en-us/azure/azure-monitor/containers/container-insights-overview) is a feature within AKS. It's designed to monitor the performance of container workloads. Use Container Insights to identify nodes, containers, or pods that drive high CPU usage.

To identify nodes, containers, or pods that drive high CPU usage, follow these steps:

1. Go to the cluster from the [Azure portal](https://portal.azure.com).
2. Under **Monitoring**, select **Insights**.

    [![Screenshot of the Monitoring under Insights.](media/identify-high-cpu-consuming-containers-aks/insights.png)](media/identify-high-cpu-consuming-containers-aks/insights.png#lightbox)
3. Set the appropriate **Time range**.

    [![Screenshot of a time range of six hours.](media/identify-high-cpu-consuming-containers-aks/six-hour-time-range.png)](media/identify-high-cpu-consuming-containers-aks/six-hour-time-range.png#lightbox)
4. Find the nodes with high CPU usage and check if the node CPU usage is stable.

    Select **Nodes**. Set **Metric** to **CPU Usage (millicores)** and then set the sample to **Max**. Use the sort feature on the **Max** to order the nodes by **Max%**. The nodes with the highest CPU usage appear at the top.

    In the following screenshot, the node uses only 12% of the max CPU and has been running for 16 days.

    [![Screenshot of the Nodes under the Monitoring selection.](media/identify-high-cpu-consuming-containers-aks/node-container-insights.png)](media/identify-high-cpu-consuming-containers-aks/node-container-insights.png#lightbox)
5. After you find the nodes with high CPU usage, select the nodes to find pods on them and their CPU usage.

    [![Screenshot of the insights option for pods under the Monitoring selection.](media/identify-high-cpu-consuming-containers-aks/containers-node-insights.png)](media/identify-high-cpu-consuming-containers-aks/containers-node-insights.png#lightbox)

    Note

    The percentage of CPU or memory usage for pods is based on the CPU request specified for the container. It doesn't represent the percentage of the CPU or memory usage for the node. So, look at the actual CPU or memory usage rather than the percentage of CPU or memory usage for pods.

    After you get the list of pods with high CPU usage, you can map it to the applications that cause the spike in CPU usage.

# [Command line](#tab/command-line)
Note

This method only diagnoses high CPU usage at the current time. The process-level instructions in this section apply to Linux node pools.

1. Use the `kubectl top node` command to get the CPU usage of all nodes.

    [![Screenshot of running the kubectl top node command.](media/identify-high-cpu-consuming-containers-aks/identify-top-node-cpu.png)](media/identify-high-cpu-consuming-containers-aks/identify-top-node-cpu.png#lightbox)
2. Use the following command to list pods across all namespaces and sort them by CPU usage.

    ```bash
    kubectl top pod --all-namespaces --sort-by=cpu
    ```

    [![Screenshot of pods across all namespaces sorted by CPU usage.](media/identify-high-cpu-consuming-containers-aks/pods-on-node-kubectl.png)](media/identify-high-cpu-consuming-containers-aks/pods-on-node-kubectl.png#lightbox)

    After you identify a pod with high CPU usage, confirm that it runs on the affected node.

    ```bash
    kubectl get pod <pod_name> --namespace <namespace> -o wide
    ```

    Check the **NODE** column in the output. If the pod runs on a different node, continue checking the high-CPU pods in the list.
3. Check the requests and limits for each pod on the node with the `kubectl describe node <node_name>` command.

    [![Screenshot of kubectl describe node output with CPU requests and limits.](media/identify-high-cpu-consuming-containers-aks/describe-node-kubectl.png)](media/identify-high-cpu-consuming-containers-aks/describe-node-kubectl.png#lightbox)

    Note

    The percentage of CPU or memory usage for the node is based on the allocatable resources on the node rather than the actual node capacity.

    After you identify a pod that uses excessive CPU on the affected node, you can identify the application running on the pod.
4. If the pod contains multiple containers, identify the container with the highest CPU usage.

    ```bash
    kubectl top pod <pod_name> --namespace <namespace> --containers
    ```
5. To investigate CPU usage at the process level, connect to the affected node. For supported node-access methods and instructions, see [Connect to AKS cluster nodes for maintenance or troubleshooting](/en-us/azure/aks/node-access).

    After you access the node, use `mpstat` to review CPU utilization across the node and determine whether the load affects all CPUs or specific CPUs. The following command takes five samples at one-second intervals:

    ```bash
    mpstat -P ALL 1 5
    ```

    Use Linux process-monitoring tools such as `top` or `ps` to identify the process or thread consuming CPU.

    ```bash
    top -H
    ```

    ```bash
    ps -eo pid,ppid,comm,args,%cpu --sort=-%cpu | head
    ```

    Determine whether the process belongs to an application container, a Kubernetes component, or another process running on the node. If necessary, inspect the process cgroup information or use container-runtime tools to identify the associated container and pod.

---

### Step 2: Review best practices to avoid high CPU usage

Review the following table to learn how to implement best practices for avoiding high CPU usage:

| Best practice | Description |
| --- | --- |
| [Set appropriate requests and limits for containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | CPU requests help Kubernetes schedule workloads and determine CPU allocation during contention. CPU limits restrict the maximum CPU a container can consume and can result in throttling. Configure requests and limits according to the workload's observed requirements and choose the appropriate Kubernetes [Quality of Service (QoS)](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/) class for each pod. |
| [Enable Horizontal Pod Autoscaler (HPA)](/en-us/azure/aks/concepts-scale) | Set appropriate CPU requests and use HPA for workloads that can scale horizontally. Verify that the workload hasn't reached its configured maximum replica count and that the cluster has sufficient capacity for additional replicas. |
| [Increase or adjust node-pool capacity](https://azure.microsoft.com/pricing/details/virtual-machines/series/) | If the workload requires more CPU capacity, consider adding nodes, selecting a VM size with more or more appropriate CPU resources, or moving the workload to a dedicated node pool. |
| [Isolate system and user workloads](/en-us/azure/aks/use-system-pools) | Run application workloads on user node pools and reserve system node pools for critical system workloads. This separation reduces the risk that application CPU usage affects Kubernetes system components. |

## References

- [Container insights overview](/en-us/azure/azure-monitor/containers/container-insights-overview)
- [Monitor your Kubernetes cluster performance with Container insights](/en-us/azure/azure-monitor/containers/container-insights-analyze)
- [How to manage the Container insights agent](/en-us/azure/azure-monitor/containers/container-insights-manage-agent)
- [Resource Limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/)
- [Quality of Service](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/)