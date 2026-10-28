---
layout: Conceptual
title: Troubleshoot CPU pressure in AKS clusters using PSI metrics - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/troubleshoot-node-cpu-pressure-psi
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
description: Learn how to troubleshoot CPU pressure in AKS clusters by using PSI metrics to find real resource contention faster. Follow these steps to improve performance.
ms.date: 2026-10-27T00:00:00.0000000Z
ms.reviewer: aritraghosh, dafell, alvinli, v-weizhu, addobres, kaushika
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance
ai-usage: ai-assisted
locale: en-us
document_id: 6f9eeff2-f741-8bcc-3a5b-6d5904dd0aab
document_version_independent_id: 6f9eeff2-f741-8bcc-3a5b-6d5904dd0aab
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/troubleshoot-node-cpu-pressure-psi.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/troubleshoot-node-cpu-pressure-psi
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/troubleshoot-node-cpu-pressure-psi.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 03fe95de-4a54-561b-9182-f66ed2b774d6
---

# Troubleshoot CPU pressure in AKS clusters using PSI metrics - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot CPU pressure in Azure Kubernetes Service (AKS) clusters by using Pressure Stall Information (PSI) metrics. It also provides best practices to resolve resource contention problems and improve application performance.

CPU pressure is a more accurate indicator of resource contention than traditional CPU utilization metrics. While high CPU usage shows resource consumption, it doesn't necessarily indicate performance problems. In an Azure Kubernetes Service (AKS) cluster, understanding CPU pressure through PSI metrics helps identify true resource contention problems.

When a node in an AKS cluster experiences CPU pressure, applications might suffer from poor performance even when CPU utilization appears moderate. PSI metrics provide insight into actual resource contention by measuring task delays rather than just resource consumption.

## Symptoms

The following table outlines the common symptoms of CPU pressure.

| Symptom | Description |
| --- | --- |
| Increased application latency | Services respond slower even when CPU utilization appears moderate. |
| Throttled containers | Containers experience delays in processing despite having CPU resources available on the node. |
| Degraded performance | Applications experience unpredictable performance variations that don't correlate with CPU usage percentages. |

## Troubleshooting

To identify and resolve CPU pressure problems, follow these steps:

### Step 1: Enable and monitor PSI metrics

Use one of the following methods to access PSI metrics:

- In a web browser, use Azure Monitoring Managed Prometheus or other monitoring solution to query PSI metrics.
- In a console, use the Kubernetes command-line tool (`kubectl`).

# [Browser](#tab/browser)
Azure Monitoring Managed Prometheus provides a way to monitor PSI metrics. Follow these steps:

1. Enable Azure Monitoring Managed Prometheus for your AKS cluster by following the instructions in [Enable Prometheus and Grafana](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable#enable-prometheus-and-grafana).

    To enable customized scrape metrics for Prometheus, see [Scrape configs](/en-us/azure/azure-monitor/containers/prometheus-metrics-scrape-configuration#scrape-configs). Set `minumum ingestion profile` to `false` and `node-exporter` to `true`.
2. Go to the Azure Monitor workspace associated with the AKS cluster from the [Azure portal](https://portal.azure.com).

    [![Screenshot of the Azure Monitor workspace page for an AKS cluster in the Azure portal.](media/troubleshoot-node-cpu-pressure-psi/configure-azure-monitor-for-containers.png)](media/troubleshoot-node-cpu-pressure-psi/configure-azure-monitor-for-containers.png#lightbox)
3. Under **Monitoring**, select **Metrics**.
4. Select **Prometheus metrics** as the data source.

    Note

    To use the metrics, you need to enable them in Azure Monitoring Managed Prometheus. Node Exporter or cAdvisor exposes these metrics.
5. Query the following specific PSI metrics in Prometheus explorer:

    - For node-level CPU pressure, use the `node_pressure_cpu_waiting_seconds_total` Prometheus Query Language (PromQL).

        [![Screenshot of a Prometheus query for node-level CPU pressure in an AKS cluster.](media/troubleshoot-node-cpu-pressure-psi/node-level-cpu-pressure.png)](media/troubleshoot-node-cpu-pressure-psi/node-level-cpu-pressure.png#lightbox)
    - For pod-level CPU pressure, use the `container_cpu_cfs_throttled_seconds_total` PromQL.
6. Calculate the PSI-some percentage (percentage of time at least one task is stalled on CPU).

    `rate(node_pressure_cpu_waiting_seconds_total[5m]) * 100`

Note

Some of the container level metrics, like `container_pressure_cpu_waiting_seconds_total` and `container_pressure_cpu_stalled_seconds_total`, aren't available in AKS as they're part of the Kubelet PSI feature gate that is in alpha state. AKS begins supporting the use of the feature when it reaches beta stage.

# [Command Line](#tab/command-line)
Access PSI metrics safely by using kubectl without requiring Secure Shell (SSH) access:

1. Use Kubernetes proxy and node metrics. Run the following commands.

    ```bash
    # Start the kubernetes proxy in a separate terminal
    kubectl proxy
    
    # Access node metrics API
    kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes
    ```
2. For more detailed PSI metrics, use the `kubectl debug` feature to create a temporary debug pod.

    ```bash
    # Create a debug pod that mounts the host filesystem
    kubectl debug node/<node_name> -it --image=busybox
    
    # Once inside the debug pod, check PSI metrics
    cat /host/proc/pressure/cpu
    ```

    The following example shows command output.

    ```output
    some avg10=0.00 avg60=0.00 avg300=0.00 total=0
    full avg10=0.00 avg60=0.00 avg300=0.00 total=0
    ```

    - The `some` line indicates the percentage of time at least one task is stalled on CPU.
    - The `full` line indicates the percentage of time all tasks are stalled on CPU.

---

### Step 2: Review best practices to prevent CPU pressure

Review the following table to learn how to implement best practices for avoiding CPU pressure.

| Best practice | Description |
| --- | --- |
| Focus on PSI metrics instead of utilization | Use PSI metrics as your primary indicator of resource contention rather than CPU utilization percentages. For more information, see [PSI - Pressure Stall Information](https://docs.kernel.org/accounting/psi.html). |
| Identify pods using the most CPU | Isolate the pods that use the most CPU and identify solutions to reduce pressure. For more information, see [Troubleshoot high CPU usage in AKS clusters](identify-high-cpu-consuming-containers-aks). |
| Minimize CPU limits | Consider removing CPU limits and rely on [Linux's Completely Fair Scheduler](https://docs.kernel.org/scheduler/sched-design-CFS.html) with CPU shares based on requests. For more information, see [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/). |
| Use appropriate Quality of Service (QoS) classes | Set the right QoS class for each pod based on its importance and contention sensitivity. For more information, see [Configure Quality of Service for Pods](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/). |
| Optimize pod placement | Use pod anti-affinity rules to avoid placing CPU-intensive workloads on the same nodes. For more information, see [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). |
| Monitor for brief pressure spikes | Short pressure spikes can indicate issues even when average utilization appears acceptable. For more information, see [Resource metrics pipeline](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/). |

## Key PSI metrics for monitoring CPU pressure

The following key PSI metrics help you monitor CPU pressure.

Note

If a node's CPU usage is moderate but the containers on the node experience CFS throttling, increase the resource limits, or remove them and follow [Linux's Completely Fair Scheduler (CFS)](https://docs.kernel.org/scheduler/sched-design-CFS.html) algorithm.

### Node-level PSI metrics

The following node-level PSI metrics are important for monitoring CPU pressure:

- `node_pressure_cpu_waiting_seconds_total`: Cumulative time tasks wait for CPU.
- `node_cpu_seconds_total`: Traditional CPU utilization for comparison.

### Container-level PSI indicators

The following container-level PSI metrics are important for monitoring CPU pressure:

- `container_cpu_cfs_throttled_periods_total`: The number of periods a container is throttled.
- `container_cpu_cfs_throttled_seconds_total`: Total time a container is throttled.
- Throttling percentage: `rate(container_cpu_cfs_throttled_periods_total[5m]) / rate(container_cpu_cfs_periods_total[5m]) * 100`

## Why use PSI metrics?

AKS uses PSI metrics as an indicator for CPU pressure instead of load average for several reasons:

- In oversized and multicore nodes, load average often underreports CPU saturation.
- On chattier and containerized nodes, load average can over-signal, leading to alert fatigue.
- Since load average doesn't have per-cgroup visibility, noisy pods can hide behind a low system average.

## References

- [Linux PSI documentation](https://docs.kernel.org/accounting/psi.html)
- [Kubernetes resource management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [AKS performance best practices](/en-us/azure/aks/concepts-clusters-workloads)
- [Enable Prometheus and Grafana](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable#enable-prometheus-and-grafana)
- [Quality of Service in Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/)
- [Linux Completely Fair Scheduler](https://docs.kernel.org/scheduler/sched-design-CFS.html)