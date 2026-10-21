---
layout: Conceptual
title: Pod is stuck in CrashLoopBackOff mode - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/pod-stuck-crashloopbackoff-mode
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
description: Troubleshoot a scenario in which a pod is stuck in CrashLoopBackOff mode on an Azure Kubernetes Service (AKS) cluster.
ms.date: 2026-06-15T00:00:00.0000000Z
editor: v-jsitser, addobres
ms.reviewer: chiragpa, nickoman, cssakscic, v-leedennis, addobres
ms.service: azure-kubernetes-service
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: c5725c51-1cbe-16fe-aa6c-2a64e008ce5d
document_version_independent_id: c5725c51-1cbe-16fe-aa6c-2a64e008ce5d
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/pod-stuck-crashloopbackoff-mode.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/pod-stuck-crashloopbackoff-mode
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/pod-stuck-crashloopbackoff-mode.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 5d96ca7c-52f4-e32c-3e26-d54fc83caad6
---

# Pod is stuck in CrashLoopBackOff mode - Azure | Microsoft Learn

## Summary

This article discusses how to troubleshoot a scenario in which a pod is stuck in `CrashLoopBackOff` mode on an Azure Kubernetes Service (AKS) cluster.

## Cause

If a pod has a `CrashLoopBackOff` status, then the pod probably failed or exited unexpectedly, and the log contains an exit code that isn't zero. Here are several possible reasons why your pod is stuck in `CrashLoopBackOff` mode:

1. **Application failure**: The application inside the container crashes shortly after starting, often due to misconfigurations, missing dependencies, or incorrect environment variables.
2. **Incorrect resource limits**: If the pod exceeds its CPU or memory resource limits, Kubernetes might kill the container. This issue can happen if resource requests or limits are set too low.
3. **Missing or misconfigured ConfigMaps/Secrets**: If the application relies on configuration files or environment variables stored in ConfigMaps or Secrets but they're missing or misconfigured, the application might crash.
4. **Image pull issues**: If there's an issue with the image (for example, it's corrupted or has an incorrect tag), the container might not start properly and fail repeatedly.
5. **Init containers failing**: If the pod has init containers and one or more fail to run properly, the pod will restart.
6. **Liveness/Readiness probe failures**: If liveness or readiness probes are misconfigured, Kubernetes might detect the container as unhealthy and restart it.
7. **Application dependencies not ready**: The application might depend on services that aren't yet ready, such as databases, message queues, or other APIs.
8. **Networking issues**: Network misconfigurations can prevent the application from communicating with necessary services, causing it to fail.
9. **Invalid commands or arguments**: The container might be started with an invalid `ENTRYPOINT`, command, or argument, leading to a crash.

For more information about the container status, see [Pod Lifecycle - Container states](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-states).

## Solution

Consider the following options and their associated [kubectl](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands) commands.

| Option | kubectl command |
| --- | --- |
| [Debug the pod](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application/#debugging-pods) itself | `kubectl describe pod <pod-name>` |
| [Debug the replication controllers](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/#debugging-replication-controllers) | `kubectl describe replicationcontroller <controller-name>` |
| [Read the termination message](https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/#writing-and-reading-a-termination-message) | `kubectl get pod <pod-name> --output=yaml` |
| [Examine the logs](https://kubernetes.io/docs/concepts/cluster-administration/logging/) | `kubectl logs <pod-name>` |

Note

A pod can also have a `CrashLoopBackOff` status if it has finished deployment, but it's configured to keep restarting even if the exit code is zero. For example, if you deploy a busybox image without specifying any arguments, the image starts, runs, finishes, and then restarts in a loop:

```console
$ kubectl run nginx --image nginx
pod/nginx created

$ kubectl run busybox --image busybox
pod/busybox created

$ kubectl get pods --watch
NAME     READY  STATUS             RESTARTS  AGE
busybox  0/1    ContainerCreating  0         3s
nginx    1/1    Running            0         11s
busybox  0/1    Completed          0         3s
busybox  0/1    Completed          1         4s
busybox  0/1    CrashLoopBackOff   1         5s

$ kubectl describe pod busybox
Name:         busybox
Namespace:    default
Priority:     0
Node:         aks-nodepool<number>-<resource-group-hash-number>-vmss<number>/<ip-address-1>
Start Time:   Wed, 16 Aug 2023 09:56:19 +0000
Labels:       run=busybox
Annotations:  <none>
Status:       Running
IP:           <ip-address-2>
IPs:
  IP:  <ip-address-2>
Containers:
  busybox:
    Container ID:   containerd://<64-digit-hexadecimal-value-1>
    Image:          busybox
    Image ID:       docker.io/library/busybox@sha256:<64-digit-hexadecimal-value-2>
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Wed, 16 Aug 2023 09:56:37 +0000
      Finished:     Wed, 16 Aug 2023 09:56:37 +0000
    Ready:          False
    Restart Count:  2
```

If you don't recognize the issue after you create more pods on the node, then run a pod on a single node to determine how many resources the pod actually uses.

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.