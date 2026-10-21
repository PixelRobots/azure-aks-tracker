---
layout: Conceptual
title: Troubleshoot pod workload restarts in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/availability-performance/troubleshoot-pod-workload-restart
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
description: Learn how to troubleshoot and resolve pod workload restarts in Azure Kubernetes Service (AKS) by reviewing and adjusting container health probe configurations.
ms.date: 2026-09-17T00:00:00.0000000Z
ms.reviewer: pinghe, shipu.yao, zhixinsun
ms.service: azure-kubernetes-service
ms.custom: sap:Node/node pool availability and performance
ai-usage: ai-assisted
locale: en-us
document_id: e6630a02-10b1-dfbd-ddc3-d1acfbcfa621
document_version_independent_id: e6630a02-10b1-dfbd-ddc3-d1acfbcfa621
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/availability-performance/troubleshoot-pod-workload-restart.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/availability-performance/troubleshoot-pod-workload-restart
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/availability-performance/troubleshoot-pod-workload-restart.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 64eb9ef3-2138-4eee-353f-771729a0eb77
---

# Troubleshoot pod workload restarts in AKS - Azure | Microsoft Learn

## Summary

This article provides guidance to troubleshoot and resolve pod workload restarts in Azure Kubernetes Service (AKS). It covers common symptoms, causes, and recommended resolutions that are related to container health probe configurations.

## Symptoms

Pod workloads in an AKS cluster restart repeatedly. You might observe one or more of the following symptoms:

- `kubectl get pods` shows pods in a `CrashLoopBackOff` or `Error` state.
- The pod `RESTARTS` count continues to increase over time.
- Events from `kubectl describe pod <pod-name>` show `liveness/startup` probe failures.
- Application log entries indicate abrupt termination or initialization failures.

The following example shows a pod in a `CrashLoopBackOff` state.

```bash
kubectl get pods 

NAME           READY      STATUS                RESTARTS      AGE 

Example-pod    0/1        CrashLoopBackOff      12            30m 
```

## Causes

Pod replacement can result from a deployment update, deletion, eviction, or node maintenance. Container restarts can result from a `OOMKilled` memory limit being exceeded, application exits, or failed liveness or startup probes.

Repetitive pod restarts in AKS commonly occur because of one or more of the following reasons:

- Liveness or startup probes are misconfigured so that the probe timeout, failure threshold, or initial delay doesn't account for normal application startup or response time.
- Startup probes are missing for slow‑initializing applications. This condition causes the liveness probe to run before the application is ready to accept requests.
- Probe endpoints depend on external resources, such as databases, storage mounts, and downstream services. These sources might be temporarily unavailable even though the application process is still healthy.
- CPU throttling or resource contention causes probe requests to time out. This behavior causes probe failures and subsequent container restarts.
- Health check logic is overly strict. Therefore, liveness probes perform full application or dependency validation instead of basic process health checks.

## Solution

Check whether the pod was replaced. If its containers are restarting, describe the pod and check the termination reason. Follow the out-of-memory (OOM) guidance for `OOMKilled`, or continue with logs and events for other reasons.

### Prerequisites

Ensure you have the necessary prerequisites before proceeding:

- Bash or Azure PowerShell v7.4 or later (not Windows PowerShell 5.1), with a compatible `kubectl` client configured for the intended cluster.
- Read access to pods, pod logs, and events. The rollout branch also requires read access to replicaSets and deployments.

Replace placeholders such as `<pod-name>` and `<namespace>` in each command. You don't need to set up a shell. Commands are read-only. Preserve evidence before changing the workload and retain any command errors.

Commands marked **Bash / PowerShell (shared)** work in either shell. Separate tabs are provided only where the command text differs.

### 1. Check whether the pod was replaced

Check the affected workload's pod `AGE` and compare it with observations before the incident.

**Bash / PowerShell (shared)**

Run the following command.

```bash
kubectl get pods -n "<namespace>"
```

See the following indicators to interpret the pod `AGE` and restart behavior:

- **AGE reset around the incident and the original pod is gone** - Investigate pod replacement. Review Kubernetes audit logs for the namespace and incident time to identify pod deletion, creation, eviction, or workload updates, including the operation, timestamp, and initiating user or controller.
- **The pod wasn't replaced and RESTARTS keeps increasing** - Continue to Step 2 to check the container's termination reason.

`AGE` measures time since pod creation, not the last container restart. A young pod can also be an additional replica, so compare it with the original pod rather than using a low `AGE` alone.

Use retained `kube-audit` or `kube-audit-admin` logs. Enabling collection at this point doesn't recover earlier operations. For more information, see [AKS resource logs](/en-us/azure/aks/monitor-aks-reference#resource-logs).

If a replacement pod's containers also restart, continue to Step 2 for that pod.

### 2. Describe the pod and check the termination reason

Describe the pod to identify the restarting container and check its termination details and events.

**Bash / PowerShell (shared)**

Run the following command.

```bash
kubectl describe pod "<pod-name>" -n "<namespace>"
```

Under **Containers** (or **Init Containers**), check **State**, **Last State**, **Reason**, **Exit Code**, and **Restart Count**.

See the following indicators to interpret the pod's termination reason and restart behavior:

- **The current or previous termination reason is `OOMKilled`** - Follow [Troubleshoot OOMKilled errors in AKS clusters](troubleshoot-oomkilled-aks-clusters) for diagnosis and remediation.
- **The reason is different or unclear** - Continue to Step 3. Exit code `137` alone doesn't prove OOM.

### 3. Investigate other container restarts

Exit code `137` with the reason `Error` can occur after a liveness-triggered termination, but it can also result from other `SIGKILL` events. Look for a matching `Liveness probe failed` event followed by a `Killing` event for the same container before attributing the restart to liveness.

#### Collect previous container logs and restart events

Retrieve logs from the container instance before its most recent restart. Replace `<container-name>` with the affected application or init container's name.

Run the following command.

**Bash / PowerShell (shared)**

```bash
kubectl logs "<pod-name>" -n "<namespace>" -c "<container-name>" -p --timestamps --tail=200
```

`-p` (`--previous`) returns only the previous instance's retained logs. If no previous instance or logs are available, preserve the error and use centralized logs. The 200-line limit can omit earlier messages. For more information, see [`kubectl logs`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_logs/).

To filter events for this pod instance, retrieve its user object ID (UID) first.

# [Bash](#tab/bash)
Run the following command.

```bash
kubectl get pod "<pod-name>" -n "<namespace>" -o jsonpath='{.metadata.uid}'
```

# [PowerShell](#tab/powershell)
Run the following command.

```powershell
kubectl get pod "<pod-name>" -n "<namespace>" -o 'jsonpath={.metadata.uid}'
```

---

Copy the returned value into `<pod-uid>` in the following steps. For a deleted pod, use its previously recorded UID. Check event messages, timestamps, counts, and the container `fieldPath` where available.

**Bash / PowerShell (shared)**

Run the following command.

```bash
kubectl get events -n "<namespace>" --field-selector "involvedObject.uid=<pod-uid>" -o yaml
```

Events can expire. No events doesn't rule out an earlier failure. Match `liveness/startup` failures to a killing event and the same container's termination time. A readiness warning alone doesn't explain a restart. For more information, see [Event field selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/#list-of-supported-fields).

The following is an example event message from the liveness test.

```text
Unhealthy  Liveness probe failed: HTTP probe failed with statuscode: 503
Killing    Container app failed liveness probe, will be restarted
```

Recheck the UID after collection. If it changed, keep evidence for the old and replacement pods separate.

See the following table to use the collected evidence and then choose the next action.

| Evidence for the restarting container | Next check |
| --- | --- |
| `liveness/startup` failure followed by a killing event and restart-count growth | Review probe configuration in Step 4. |
| Application error or nonzero exit without evidence of a probe-triggered termination | Check previous logs, entrypoint, configuration, and dependencies. |
| `Completed` or exit `0`, followed by another start | Check restart policy. For a short-lived process under `Always`, consider a job instead of a service. |
| Readiness failures but no restart-count growth | Readiness failure alone doesn't restart containers. If restarts occur, find the termination cause separately. |

### 4. Review and correct the health probe configuration

If events confirm a probe-triggered restart, review the probe settings in the pod description. To resolve this problem, review the container health probe configuration to ensure that it aligns with the application's startup and runtime characteristics. Verify the following points:

- Configure startup probes for applications that require extra initialization time. Verify that the `failureThreshold` and `periodSeconds` values provide enough time for the application to start successfully. For more information, see [Pod Lifecycle | Kubernetes](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#when-should-you-use-a-startup-probe).
- Adjust liveness probe thresholds, such as `timeoutSeconds` and `failureThreshold`, to prevent unnecessary container restarts during transient latency or periods of increased load. For more information, see [Configure Liveness, Readiness and Startup Probes | Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/).
- Keep liveness probes lightweight by validating only that the application process is running and responsive, instead of performing full dependency checks. For more information, see [Liveness, Readiness, and Startup Probes | Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/).
- Move dependency validation and traffic‑gating logic to the readiness probe instead of using liveness probes to determine overall application health. For more information, see [Configure Liveness, Readiness and Startup Probes | Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/).
- Check whether container CPU and memory limits are appropriately sized so the application can respond to health probes under normal operating conditions. For more information, see [Pod Lifecycle | Kubernetes](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#when-should-you-use-a-startup-probe).

## References

Use these focused references only when the evidence matches:

- [CPU pressure and throttling](troubleshoot-node-cpu-pressure-psi) for contention or throttling.
- [High CPU consumers](identify-high-cpu-consuming-containers-aks) to identify the workload using the CPU.
- [Memory saturation](identify-memory-saturation-aks) for node memory pressure. For an actual `OOMKilled` termination, use the OOM guidance in Step 2.
- [High disk I/O latency](identify-high-disk-io-latency-containers-aks) when file-operation delays or input/output (I/O) evidence coincide with probe timeouts.