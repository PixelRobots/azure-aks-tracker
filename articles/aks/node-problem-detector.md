---
layout: Conceptual
title: Node Problem Detector (NPD) in Azure Kubernetes Service (AKS) nodes - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/node-problem-detector
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
description: Learn about how AKS uses Node Problem Detector to expose issues with the node.
ms.topic: concept-article
ms.subservice: aks-monitoring
ms.date: 2023-05-31T00:00:00.0000000Z
author: schaffererin
ms.author: schaffererin
ai-usage: ai-assisted
locale: en-us
document_id: 3ff0165f-b216-2dcb-fdf2-3e3813e500a5
document_version_independent_id: 7bc4b5d7-0db4-9dbe-7350-29420cb89d2d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/node-problem-detector.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
interactive_type: azurecli
toc_rel: toc.json
asset_id: aks/node-problem-detector
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/node-problem-detector.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 746f3049-354b-2ab3-5f94-6c813293e1e7
---

# Node Problem Detector (NPD) in Azure Kubernetes Service (AKS) nodes - Azure Kubernetes Service | Microsoft Learn

[Node Problem Detector (NPD)](https://github.com/kubernetes/node-problem-detector) is an open source Kubernetes component that detects node-related problems and reports on them. It runs as a systemd serviced on each node in the cluster and collects various metrics and system information, such as CPU usage, disk usage, and network connectivity. When it detects a problem, it generates *events and/or node conditions*. Azure Kubernetes Service (AKS) uses NPD to monitor and manage nodes in a Kubernetes cluster running on the Azure cloud platform. The AKS Linux extension enables NPD by default.

Note

Upgrades to NPD are independent of the node image and Kubernetes version upgrade processes. If a node pool is unhealthy (that is, in a failed state), new NPD versions aren't installed.

## Node conditions

Node conditions indicate a permanent problem that makes the node unavailable. AKS uses the following node conditions from NPD to expose permanent problems on the node. NPD also emits corresponding Kubernetes events.

| Problem Daemon type | NodeCondition | Reason | Compute type |
| --- | --- | --- | --- |
| CustomPluginMonitor | FilesystemCorruptionProblem | FilesystemCorruptionDetected | General purpose |
| CustomPluginMonitor | KubeletProblem | KubeletIsDown | General purpose |
| CustomPluginMonitor | ContainerRuntimeProblem | ContainerRuntimeIsDown | General purpose |
| CustomPluginMonitor | VMEventScheduled | VMEventScheduled | General purpose |
| CustomPluginMonitor | FrequentUnregisterNetDevice | UnregisterNetDevice | General purpose |
| CustomPluginMonitor | FrequentKubeletRestart | FrequentKubeletRestart | General purpose |
| CustomPluginMonitor | FrequentContainerdRestart | FrequentContainerdRestart | General purpose |
| CustomPluginMonitor | FrequentDockerRestart | FrequentDockerRestart | General purpose |
| CustomPluginMonitor | GPUMissing | Observed GPU count does not match expected GPU count | GPU only |
| CustomPluginMonitor | NVLinkStatusInactive | NVLinkStatusInactive | GPU only |
| CustomPluginMonitor | XIDErrors | XID errors present in kernel log | GPU only |
| CustomPluginMonitor | IBLinkFlapping | Intermittent InfiniBand device connectivity | GPU only |
| CustomPluginMonitor | GPUClockThrottling | Problematic GPU clock throttling detected | GPU only |
| CustomPluginMonitor | UnhealthyNvidiaDevicePlugin | NVIDIA device plugin service is not active | GPU only (managed GPU) |
| SystemLogMonitor | KernelDeadlock | DockerHung | General purpose |
| SystemLogMonitor | ReadonlyFilesystem | FilesystemIsReadOnly | General purpose |

Note

The `GPU only` node conditions apply to all GPU node pools that use AKS-managed GPU drivers (node pools not created with `--gpu-driver none`). The `GPU only (managed GPU)` conditions apply only to node pools with the [fully managed GPU experience](aks-managed-gpu-nodes) enabled. GPU health monitoring is supported on standard GPU and [MIG-enabled GPU node pools](gpu-multi-instance).

## Events

NPD emits events with relevant information to help you diagnose underlying issues.

| Problem Daemon type | Reason | Frequency | Description | Action |
| --- | --- | --- | --- | --- |
| CustomPluginMonitor | EgressBlocked | 30 min | This event checks for connectivity to external endpoints | Check if a firewall or NSG blocking the connectivity to the endpoint getting flagged |
| CustomPluginMonitor | FilesystemCorruptionDetected | 5min | This checks for filesystem corruption surfaced by docker |  |
| CustomPluginMonitor | KubeletIsDown | 30s | This checks if kubelet service is running and healthy |  |
| CustomPluginMonitor | ContainerRuntimeIsDown | 30s | This event checks if the container runtime eg: containerd is running and healthy |  |
| CustomPluginMonitor | FreezeScheduled | 1min | This event checks if a Freeze Event is scheduled on the node. Check https://aka.ms/aks/scheduledevents for more information |  |
| CustomPluginMonitor | RebootScheduled | 1min | This event checks if a Reboot Event is scheduled on the node Check https://aka.ms/aks/scheduledevents for more information |  |
| CustomPluginMonitor | RedeployScheduled | 1min | This event checks if a Redeploy Event is scheduled on the node. Check https://aka.ms/aks/scheduledevents for more information |  |
| CustomPluginMonitor | TerminateScheduled | 1min | This event checks if a Terminate Event is scheduled on the node. Check https://aka.ms/aks/scheduledevents for more information |  |
| CustomPluginMonitor | PreemptScheduled | 2s | This event checks if a Preempt Event is scheduled on the node. Check https://aka.ms/aks/scheduledevents for more information |  |
| CustomPluginMonitor | DNSProblem |  |  |  |
| SystemLogMonitor | OOMKilling |  |  |  |
| SystemLogMonitor | TaskHung |  |  |  |
| SystemLogMonitor | UnregisterNetDevice |  |  |  |
| SystemLogMonitor | KernelOops |  |  |  |
| SystemLogMonitor | DockerSocketCannotConnect |  |  |  |
| SystemLogMonitor | KubeletRPCDeadlineExceeded |  |  |  |
| SystemLogMonitor | KubeletRPCNoSuchContainer |  |  |  |
| SystemLogMonitor | CNICannotStatFS |  |  |  |
| SystemLogMonitor | PLEGUnhealthy |  |  |  |
| SystemLogMonitor | KubeletStart |  |  |  |
| SystemLogMonitor | DockerStart |  |  |  |
| SystemLogMonitor | ContainerdStart |  |  |  |

In certain instances, AKS automatically cordons and drains the node to minimize disruption to workloads. For more information about the events and actions, see [Node autodrain](/en-us/azure/aks/node-auto-repair#node-auto-drain).

### EgressBlocked

The list of endpoints checked by the EgressBlocked are listed below

Note

The actual endpoints will depend on the type of the cluster and the location where it's hosted (Public cloud vs Airgapped clouds). Review the documentation for outbound access [here](/en-us/azure/aks/outbound-rules-control-egress). The documentation is for public clouds

| Type | Example | Note |
| --- | --- | --- |
| MCR | https://mcr.microsoft.com |  |
| Microsoft Entra ID | `https://login.microsoftonline.com` |  |
| Resource Manager | https://management.azure.com |  |
| Packages | https://packages.microsoft.com |  |
| Kube Binary | https://acs-mirror.azureedge.net/acs-mirror/healthz https://packages.aks.azure.com/acs-mirror/healthz |  |

## Check the node conditions and events

- Check the node conditions and events using the `kubectl describe node` command.

    ```azurecli
    kubectl describe node my-aks-node
    ```

    Your output should look similar to the following example condensed output:

    ```output
    ...
    ...
    
    Conditions:
      Type                          Status  LastHeartbeatTime                 LastTransitionTime                Reason                          Message
      ----                          ------  -----------------                 ------------------                ------                          -------
      VMEventScheduled              False   Thu, 01 Jun 2023 19:14:25 +0000   Thu, 01 Jun 2023 03:57:41 +0000   NoVMEventScheduled              VM has no scheduled event
      FrequentContainerdRestart     False   Thu, 01 Jun 2023 19:14:25 +0000   Thu, 01 Jun 2023 03:57:41 +0000   NoFrequentContainerdRestart     containerd is functioning properly
      FrequentDockerRestart         False   Thu, 01 Jun 2023 19:14:25 +0000   Thu, 01 Jun 2023 03:57:41 +0000   NoFrequentDockerRestart         docker is functioning properly
      FilesystemCorruptionProblem   False   Thu, 01 Jun 2023 19:14:25 +0000   Thu, 01 Jun 2023 03:57:41 +0000   FilesystemIsOK                  Filesystem is healthy
      FrequentUnregisterNetDevice   False   Thu, 01 Jun 2023 19:14:25 +0000   Thu, 01 Jun 2023 03:57:41 +0000   NoFrequentUnregisterNetDevice   node is functioning properly
      ContainerRuntimeProblem       False   Thu, 01 Jun 2023 19:14:25 +0000   Thu, 01 Jun 2023 03:57:40 +0000   ContainerRuntimeIsUp            container runtime service is up
      KernelDeadlock                False   Thu, 01 Jun 2023 19:14:25 +0000   Thu, 01 Jun 2023 03:57:41 +0000   KernelHasNoDeadlock             kernel has no deadlock
      FrequentKubeletRestart        False   Thu, 01 Jun 2023 19:14:25 +0000   Thu, 01 Jun 2023 03:57:41 +0000   NoFrequentKubeletRestart        kubelet is functioning properly
      KubeletProblem                False   Thu, 01 Jun 2023 19:14:25 +0000   Thu, 01 Jun 2023 03:57:41 +0000   KubeletIsUp                     kubelet service is up
      ReadonlyFilesystem            False   Thu, 01 Jun 2023 19:14:25 +0000   Thu, 01 Jun 2023 03:57:41 +0000   FilesystemIsNotReadOnly         Filesystem is not read-only
      NetworkUnavailable            False   Thu, 01 Jun 2023 03:58:39 +0000   Thu, 01 Jun 2023 03:58:39 +0000   RouteCreated                    RouteController created a route
      MemoryPressure                True    Thu, 01 Jun 2023 19:16:50 +0000   Thu, 01 Jun 2023 19:16:50 +0000   KubeletHasInsufficientMemory    kubelet has insufficient memory available
      DiskPressure                  False   Thu, 01 Jun 2023 19:16:50 +0000   Thu, 01 Jun 2023 03:57:22 +0000   KubeletHasNoDiskPressure        kubelet has no disk pressure
      PIDPressure                   False   Thu, 01 Jun 2023 19:16:50 +0000   Thu, 01 Jun 2023 03:57:22 +0000   KubeletHasSufficientPID         kubelet has sufficient PID available
      Ready                         True    Thu, 01 Jun 2023 19:16:50 +0000   Thu, 01 Jun 2023 03:57:23 +0000   KubeletReady                    kubelet is posting ready status. AppArmor enabled
    ...
    ...
    ...
    Events:
      Type    Reason                   Age                  From     Message
      ----    ------                   ----                 ----     -------
      Normal  NodeHasSufficientMemory  94s (x176 over 15h)  kubelet  Node aks-agentpool-40622340-vmss000009 status is now: NodeHasSufficientMemory
    ```

These events are also available in [Container Insights](/en-us/azure/azure-monitor/containers/container-insights-overview) through [KubeEvents](/en-us/azure/azure-monitor/reference/tables/kubeevents).

## Metrics

NPD also exposes Prometheus metrics based on the node problems, which you can use for monitoring and alerting. These metrics are exposed on port 20257 of the Node IP and Prometheus can scrape them.

The following example YAML shows a scrape config you can use with the [Azure Managed Prometheus add-on as a DaemonSet](/en-us/azure/azure-monitor/essentials/prometheus-metrics-scrape-configuration#advanced-setup-configure-custom-prometheus-scrape-jobs-for-the-daemonset):

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: ama-metrics-prometheus-config-node
  namespace: kube-system
data:
  prometheus-config: |-
    global:
      scrape_interval: 1m
    scrape_configs:
    - job_name: node-problem-detector
      scrape_interval: 1m
      scheme: http
      metrics_path: /metrics
      relabel_configs:
      - source_labels: [__metrics_path__]
        regex: (.*)
        target_label: metrics_path
      - source_labels: [__address__]
        replacement: '$NODE_NAME'
        target_label: instance
      static_configs:
      - targets: ['$NODE_IP:20257']
```

The following example shows the scraped metrics:

```output
problem_gauge{reason="UnregisterNetDevice",type="FrequentUnregisterNetDevice"} 0
problem_gauge{reason="VMEventScheduled",type="VMEventScheduled"} 0
```