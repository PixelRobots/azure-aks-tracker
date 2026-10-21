---
layout: Conceptual
title: Troubleshoot API server and etcd problems in AKS - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-apiserver-etcd
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
description: Diagnose and resolve AKS API server and etcd problems faster with practical steps for latency, timeouts, and throttling. Start troubleshooting now.
ms.date: 2026-07-24T00:00:00.0000000Z
ms.service: azure-kubernetes-service
ms.reviewer: kthakar1990, v-weizhu, axelg, josebl, aritraghosh, v-leedennis, v-liuamson, segule, shuyingqin
ms.custom: sap:Create, Upgrade, Scale and Delete operations (cluster or nodepool)
locale: en-us
document_id: cd75116e-9d37-46ba-349a-b01f93f6b693
document_version_independent_id: cd75116e-9d37-46ba-349a-b01f93f6b693
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-apiserver-etcd.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/create-upgrade-delete/troubleshoot-apiserver-etcd
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/create-upgrade-delete/troubleshoot-apiserver-etcd.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 5fbd3e80-9581-fc41-9453-ac4714dec47d
---

# Troubleshoot API server and etcd problems in AKS - Azure | Microsoft Learn

## Summary

This article helps you troubleshoot API server and etcd problems in large Azure Kubernetes Service (AKS) deployments.

Microsoft tests the reliability and performance of the API server at a scale of 5,000 nodes and 200,000 pods. The cluster that contains the API server can automatically scale out and deliver [Kubernetes Service Level Objectives (SLOs)](https://github.com/kubernetes/community/blob/main/sig-scalability/slos/slos.md). If you experience high latencies or timeouts, the cause is likely a resource leak in etcd (the distributed key-value store that backs the API server), or an offending client that makes excessive API calls.

## Prerequisites

- The [Azure CLI](/en-us/cli/azure/install-azure-cli).
- The Kubernetes [kubectl](https://kubernetes.io/docs/reference/kubectl/) tool. To install kubectl by using Azure CLI, run the [az aks install-cli](/en-us/cli/azure/aks#az-aks-install-cli) command.
- AKS diagnostics logs (specifically, kube-audit events) that are enabled and sent to a [Log Analytics workspace](/en-us/azure/aks/monitor-aks#aks-control-plane-resource-logs). To determine whether logs are collected by using [resource-specific](/en-us/azure/azure-monitor/platform/resource-logs#resource-specific) or [Azure diagnostics](/en-us/azure/azure-monitor/platform/resource-logs#azure-diagnostics-mode) mode, check the **Diagnostic Settings** blade in the Azure portal.
- The Standard tier for AKS clusters. If you're using the Free tier, the API server and etcd contain limited resources. AKS clusters in the Free tier don't provide high availability. This condition is often the root cause of API server and etcd problems.
- The [kubectl-aks](https://go.microsoft.com/fwlink/p/?linkid=2259767#install) plugin for running commands directly on AKS nodes without using the Kubernetes control plane.

## Basic health checks

- Check resource health events

    AKS provides resource health events for critical component downtime. Before you proceed, make sure that [Resource Health](/en-us/azure/service-health/resource-health-overview) doesn't report any critical events.

    [![Screenshot of an AKS resource health event indicating control plane status.](media/troubleshoot-apiserver-etcd/resource-health-event.png)](media/troubleshoot-apiserver-etcd/resource-health-event.png#lightbox)
- Diagnose and solve problems

    AKS provides a dedicated troubleshooting category for **Cluster and Control Plane Availability and Performance**.

    [![Screenshot of the Cluster and Control Plane Availability and Performance diagnostics category in AKS.](media/troubleshoot-apiserver-etcd/cluster-control-plane-availability-performance.png)](media/troubleshoot-apiserver-etcd/cluster-control-plane-availability-performance.png#lightbox)

## Symptoms

The following table outlines the common symptoms of API server failures.

| Symptom | Description |
| --- | --- |
| API server pod in `CrashLoopBackOff` status or facing webhook call failures | Verify that you don't have any custom admission webhook (such as the [Kyverno](https://kyverno.io/docs/introduction/) policy engine) that's blocking the calls to the API server. |
| Timeouts from the API server | Frequent timeouts that are beyond the guarantees in [the AKS API server SLA](/en-us/azure/aks/free-standard-pricing-tiers#uptime-sla-terms-and-conditions). For example, `kubectl` commands timeout. |
| High latencies | High latencies that make the Kubernetes SLOs fail. For example, the `kubectl` command takes more than 30 seconds to list pods. |
| \* Elevated HTTP 429 responses from the API server  \* Following message for **kubectl get** commands:  "The server is currently unable to handle the request" | API server is overloaded and is throttling calls. Refer to Cause 4 and Cause 5. |

## Cause and resolution

### Cause 1: A network rule blocks the traffic from agent nodes to the API server

A network rule can block traffic between the agent nodes and the API server.

To check whether a misconfigured network policy is blocking communication between the API server and agent nodes, run the following [kubectl-aks](https://go.microsoft.com/fwlink/p/?linkid=2259767) commands:

```bash
kubectl aks config import \
    --subscription <mySubscriptionID> \
    --resource-group <myResourceGroup> \
    --cluster-name <myAKSCluster>

kubectl aks check-apiserver-connectivity --node <myNode>
```

The [config import](https://go.microsoft.com/fwlink/p/?linkid=2259867#importing-configuration) command retrieves the Virtual Machine Scale Set information for all the nodes in the cluster. Then, the [check-apiserver-connectivity](https://go.microsoft.com/fwlink/p/?linkid=2259674) command uses this information to verify the network connectivity between the API server and a specified node, specifically for its underlying scale set instance.

Note

If the output of the `check-apiserver-connectivity` command contains the `Connectivity check: succeeded` message, the network connectivity is unimpeded.

### Solution 1: Fix the network policy to remove the traffic blockage

If the command output indicates that a connection failure occurred, reconfigure the network policy so it doesn't block traffic between the agent nodes and the API server.

### Cause 2: A custom webhook causes a deadlock in API server pods

A custom webhook, such as Kyverno, might cause a deadlock within API server pods.

Check the events that are related to your API server. You might see event messages that resemble the following text:

> 
> Internal error occurred: failed calling webhook "mutate.kyverno.svc-fail": failed to call webhook: Post "https://kyverno-system-kyverno-system-svc.kyverno-system.svc:443/mutate/fail?timeout=10s": write unix @-&gt;/tunnel-uds/proxysocket: write: broken pipe

#### Retrieve API server logs

# [Resource-specific](#tab/resource-specific)
```kusto
AKSControlPlane
| where TimeGenerated between(now(-1h)..now())
| where Category=="kube-apiserver"
| where Message contains "Failed calling webhook, failing closed"
| limit 100
| project TimeGenerated, Level, Message
```

# [Azure diagnostics](#tab/azure-diagnostics)
```kusto
AzureDiagnostics
| where TimeGenerated between(now(-1h)..now())  // When you experienced the problem
| where Category == "kube-apiserver" 
| where log_s  contains "Failed calling webhook, failing closed"
| extend event = parse_json(log_s) 
| limit 100
| project TimeGenerated, event, Category
```

---

In this example, the validating webhook blocks the creation of some API server objects. Because this scenario might occur during bootstrap time, the API server and Konnectivity pods can't be created. Therefore, the webhook can't connect to those pods. This sequence of events causes the deadlock and the error message.

A custom webhook can also fail outside of bootstrap. If a webhook uses `failurePolicy: Fail` and its backend becomes unavailable, the API server rejects every request that matches the webhook rules while the rest of the cluster keeps running. On AKS, the API server reaches the webhook through the Konnectivity tunnel, so an unreachable backend often surfaces as a gateway timeout wrapped in an HTTP 500 error:

> 
> Internal error occurred: failed calling webhook "&lt;name&gt;": failed to call webhook: Post "https://&lt;host&gt;/validate?timeout=&lt;n&gt;s": proxy error from localhost:9443 while dialing &lt;host&gt;, code 504: 504 Gateway Timeout

Because controllers can't create objects, the impact spreads. For example, a Deployment's ReplicaSet reports `ReplicaFailure` with `FailedCreate` events that carry the same webhook error. To confirm, make sure kube-audit diagnostics logs are enabled and sent to a Log Analytics workspace (see Prerequisites), and then query the `AKSAudit` table for the failing operations:

# [Resource-specific](#tab/resource-specific)
```kusto
AKSAudit
| where TimeGenerated between(now(-1h)..now()) // When you experienced the problem
| where ResponseStatus.code == 500
| where ResponseStatus.message has "failed calling webhook"
| extend Resource = tostring(ObjectRef.resource), User = tostring(User.username)
| project TimeGenerated, Verb, Resource, User, Message = tostring(ResponseStatus.message)
```

# [Azure diagnostics](#tab/azure-diagnostics)
```kusto
AzureDiagnostics
| where TimeGenerated between(now(-1h)..now())  // When you experienced the problem
| where Category == "kube-audit"
| extend event = parse_json(log_s)
| where event.responseStatus.code == 500
| where event.responseStatus.message has "failed calling webhook"
| extend Resource = tostring(event.objectRef.resource), User = tostring(event.user.username)
| project TimeGenerated, Verb = tostring(event.verb), Resource, User, Message = tostring(event.responseStatus.message)
```

---

### Solution 2: Delete webhook configurations

To fix this problem, delete the validating and mutating webhook configurations. To delete these webhook configurations in Kyverno, review the [Kyverno troubleshooting article](https://kyverno.io/docs/guides/troubleshooting/).

### Cause 3: An offending client leaks etcd objects and causes a slowdown of etcd

A common situation is that objects are continuously created even though existing unused objects in the etcd database aren't removed. This situation can cause performance problems if etcd handles too many objects (more than 10,000) of any type. A rapid increase of changes on such objects could also cause the etcd database to exceed its size limit (8 GB by default).

To check the etcd database usage, go to **Diagnose and Solve problems** &gt; **Cluster and Control Plane Availability and Performance** in the Azure portal. Run the **Etcd Capacity Issues** and **Etcd Performance Issues** diagnosis tool. The diagnosis tool shows the usage breakdown and the total database size.

[![Screenshot of the Etcd Capacity Issues diagnosis tool in the AKS Azure portal experience.](media/troubleshoot-apiserver-etcd/etcd-detector.png)](media/troubleshoot-apiserver-etcd/etcd-detector.png#lightbox)

To get a quick view of the current size of your etcd database in bytes, run the following command:

```bash
kubectl get --raw /metrics | grep -E "etcd_db_total_size_in_bytes|apiserver_storage_size_bytes|apiserver_storage_db_total_size_in_bytes"
```

Note

If your control plane is unavailable, the kubectl commands don't work. Use **Diagnose and Solve problems** in Azure portal as shown in the section above.

The metric name in the previous command is different for different Kubernetes versions. For Kubernetes 1.25 and earlier versions, use `etcd_db_total_size_in_bytes`. For Kubernetes 1.26 and 1.27, use `apiserver_storage_db_total_size_in_bytes`. For Kubernetes 1.28 and later, use `apiserver_storage_size_bytes`. The `grep` command above matches all three names, so it returns a value regardless of your cluster version. An etcd database with size greater than two (2) gigabytes is considered a large etcd db.

### Solution 3: Define quotas for object creation, delete objects, or limit object lifetime in etcd

To prevent etcd from reaching capacity and causing cluster downtime, limit the maximum number of resources that you create. You can also slow the number of revisions that are generated for resource instances. To limit the number of objects that you can create, [define object quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/#quota-on-object-count).

If you identify objects that are no longer in use but consume resources, consider deleting them. For example, delete completed jobs to free up space:

```bash
kubectl delete jobs --field-selector status.successful=1
```

For objects that support [automatic cleanup](https://kubernetes.io/docs/concepts/architecture/garbage-collection/), set Time to Live (TTL) values to limit the lifetime of these objects. You can also label your objects so that you can bulk delete all the objects of a specific type by using label selectors. If you establish [owner references](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/) among objects, any dependent objects are automatically deleted after the parent object is deleted.

Also refer to Solution 6 for object size reduction techniques.

### Cause 4: AKS managed API server guard was applied

If you see a high rate of HTTP 429 errors, one possible cause is that AKS applies a managed API server guard. AKS applies this guard by using a FlowSchema and PriorityLevelConfiguration named **"aks-managed-apiserver-guard"**. This safeguard triggers when the API server encounters frequent out-of-memory (OOM) events after scaling efforts on the API server fail to stabilize it. This guard acts as a last-resort measure to protect the API server by throttling non-system client requests to the API server and preventing it from becoming completely unresponsive. For more information, see [Control plane safeguards](/en-us/azure/aks/concepts-scale#control-plane-safeguards).

- Check the cluster for the presence of **"aks-managed-apiserver-guard"** FlowSchema and PriorityLevelConfiguration.

Note

Kubectl commands might take longer than expected or time out when the API server is overloaded. Retry if it fails.

```bash
kubectl get flowschemas
kubectl get prioritylevelconfigurations
```

![Screenshot of the aks-managed-apiserver-guard FlowSchema configuration in an AKS cluster.](media/troubleshoot-apiserver-etcd/flow-schema.png)

![Screenshot of the aks-managed-apiserver-guard PriorityLevelConfiguration in an AKS cluster.](media/troubleshoot-apiserver-etcd/priority-level-configuration.png)

- Check Kubernetes events.

```bash
kubectl get events -n kube-system aks-managed-apiserver-throttling-enabled
```

When you observe HTTP 429 (“Too Many Requests”) errors, the API server is being throttled. This is often caused by one or more clients generating excessive API calls. Use kube-audit logs in Log Analytics to identify the top contributors.

```kusto
AzureDiagnostics
| where Category == "kube-audit"
| summarize RequestCount = count() by Caller = tostring(identity_username)
| order by RequestCount desc
| take 20
```

This shows users, service accounts, controllers sending requests to API server and helps quickly spot “noisy” clients.

If you wish to know which clients are actually being throttled and to focus directly on root cause of API server overload, you can use the query below:

```kusto
Azure Diagnostics
| where Category == "kube-audit"
| where responseCode == 429
| summarize ThrottledRequests = count() by Caller = tostring(identity_username)
| order by ThrottledRequests desc
```

### Solution 4: Identify unoptimized clients and mitigate

#### Step 1: Identify unoptimized clients

- See Cause 5 to identify problematic clients and refine their LIST call patterns - especially those clients generating high-frequency or high-latency requests as they are the primary contributors to API server degradation. Refer to [best practices](/en-us/azure/aks/best-practices-performance-scale-large#kubernetes-client-best-practices) for further guidance on client optimization.

#### Step 2: Mitigation

- Scale down the cluster to reduce the load on the API server.
- If Step 1 identifies a recently added controller, CRD, or DaemonSet as the primary driver of API server overload, remove the associated object from the cluster.
- Use [Control Plane Metrics](/en-us/azure/aks/control-plane-metrics-monitor) to monitor the load on the API server. Refer to the [blog](https://techcommunity.microsoft.com/blog/appsonazureblog/azure-platform-metrics-for-aks-control-plane-monitoring/4385770) for more details.
- When you complete the preceding steps, delete aks-managed-apiserver-guard.

```bash
kubectl delete flowschema aks-managed-apiserver-guard
kubectl delete prioritylevelconfiguration aks-managed-apiserver-guard
```

Warning

Avoid scaling the cluster back to the originally intended scale point until client call patterns are optimized. Refer to **[best practices](/en-us/azure/aks/best-practices-performance-scale-large#kubernetes-client-best-practices)**. Premature scaling might cause the API server to crash again.

- You can also [modify the aks-managed-apiserver-guard FlowSchema and PriorityLevelConfiguration](https://kubernetes.io/docs/concepts/cluster-administration/flow-control/#good-practice-apf-settings) by applying the label **aks-managed-skip-update-operation: true**. This label preserves the modified configurations and prevents AKS from reconciling them back to default values. This setting is relevant if you're applying a custom FlowSchema and PriorityLevelConfiguration tailored to your cluster's requirements as specified in solution 5b and don't want AKS to automatically manage client throttling.

```bash
kubectl label prioritylevelconfiguration aks-managed-apiserver-guard aks-managed-skip-update-operation=true
kubectl label flowschema aks-managed-apiserver-guard aks-managed-skip-update-operation=true
```

### Cause 5: An offending client makes excessive LIST or PUT calls

If etcd isn't overloaded with too many objects as defined in Cause 3, an offending client might be making too many `LIST` or `PUT` calls to the API server. If you experience high latency or frequent timeouts, follow these steps to pinpoint the offending client and the types of API calls that fail.

#### Step 1: Identify top user agents by the number of requests

To identify which clients generate the most requests (and potentially the most API server load), run a query that resembles the following code. This query lists the top 10 user agents by the number of API server requests sent.

# [Resource-specific](#tab/resource-specific)
```kusto
AKSAudit
| where TimeGenerated between(now(-1h)..now()) // When you experienced the problem
| summarize count() by UserAgent
| top 10 by count_
| project UserAgent, count_
```

# [Azure diagnostics](#tab/azure-diagnostics)
```kusto
AzureDiagnostics
| where TimeGenerated between(now(-1h)..now())  // When you experienced the problem
| where Category == "kube-audit" 
| extend event = parse_json(log_s) 
| extend User = tostring(event.user.username) 
| summarize count() by User 
| top 10 by count_ 
| project User, count_ 
```

---

Note

If your query returns no results, you might have selected the wrong table to query diagnostics logs. In resource-specific mode, data is written to individual tables, depending on the category of the resource. Diagnostics logs are written to the `AKSAudit` table. In Azure diagnostics mode, all data is written to the `AzureDiagnostics` table. For more information, see [Azure resource logs](/en-us/azure/azure-monitor/platform/resource-logs).

Although it's helpful to know which clients generate the highest request volume, high request volume alone might not be a cause for concern. The response latency that clients experience is a better indicator of the actual load that each one generates on the API server.

Note

Watch/informer clients are underrepresented here - a long-lived watch is one audit entry even though it streams many objects - so use the **API server resource intensive listing detector** (next section) to catch them. Top rows are often health-check agents (for example, `Envoy/HC`, `kube-probe`), which are normal.

#### Step 2: Identify and analyse latency for a user agent

**Using Diagnose and Solve on Azure portal**

AKS now provides a built-in analyzer, the API Server Resource Intensive Listing Detector, to help you identify agents that make resource-intensive LIST calls. These calls are a leading cause of API server and etcd performance issues.

To access the detector, follow these steps:

1. Open your AKS cluster in the Azure portal.
2. Go to **Diagnose and solve problems**.
3. Select **Cluster and Control Plane Availability and Performance**.
4. Select **API server resource intensive listing detector**.

The detector analyzes recent API server activity and highlights agents or workloads that generate large or frequent LIST calls. It provides a summary of potential effects, such as request timeouts, increased numbers of "408" and "503" errors, node instability, health probe failures, and OOM-Kills in API server or etcd.

[![Screenshot of the API server resource-intensive listing detector summary in AKS diagnostics.](media/troubleshoot-apiserver-etcd/resource-intensive-listing-analyzer-1.png)](media/troubleshoot-apiserver-etcd/resource-intensive-listing-analyzer-1.png#lightbox)

[![Screenshot of the detailed view for API server resource-intensive listing analysis in AKS.](media/troubleshoot-apiserver-etcd/resource-intensive-listing-analyzer-2.png)](media/troubleshoot-apiserver-etcd/resource-intensive-listing-analyzer-2.png#lightbox)

**How to interpret the detector output**

- **Summary:** Indicates if resource-intensive LIST calls were detected and describes possible impacts on your cluster.
- **Analysis window:** Shows the 30-minute window analyzed, with peak memory and CPU usage.
- **Read types:** Explains whether LIST calls were served from the API server cache (preferred) or required fetching from etcd (most impactful).
- **Charts and tables:** Identify which agents, namespaces, or workloads are generating the most resource-intensive LIST calls.

Note

- The API server resource intensive listing detector is available to all users who have access to the AKS resource in the Azure portal. No special permissions or prerequisites are required.
- Only successful LIST calls are counted. Failed or throttled calls are excluded.
- After you identify the offending agents and apply the recommendations, you can use [the API Priority and Fairness feature](https://kubernetes.io/docs/concepts/cluster-administration/flow-control/) to throttle or isolate problematic clients. Alternatively, refer to Cause 3.

**Using Logs**

To identify the average latency of API server requests per user agent, as plotted on a time chart, run the following query.

# [Resource-specific](#tab/resource-specific)
```kusto
AKSAudit
| where TimeGenerated between(now(-1h)..now()) // When you experienced the problem
| extend start_time = RequestReceivedTime
| extend end_time = StageReceivedTime
| extend latency = datetime_diff('millisecond', end_time, start_time)
| summarize avg(latency) by UserAgent, bin(start_time, 5m)
| render timechart
```

# [Azure diagnostics](#tab/azure-diagnostics)
```kusto
AzureDiagnostics
| where TimeGenerated between(now(-1h)..now())  // When you experienced the problem
| where Category == "kube-audit" 
| extend event = parse_json(log_s) 
| extend User = tostring(event.user.username)
| extend start_time = todatetime(event.requestReceivedTimestamp)
| extend end_time = todatetime(event.stageTimestamp)
| extend latency = datetime_diff('millisecond', end_time, start_time)
| summarize avg(latency) by User, bin(start_time, 5m) 
| render timechart 
```

---

This query follows the query in the "Identify top user agents by the number of requests" section. It might give you more insights into the actual load that each user agent generates over time.

Tip

By analyzing this data, you can identify patterns and anomalies that indicate problems on your AKS cluster or applications. For example, you might notice that a particular user experiences high latency. This scenario can indicate the type of API calls that cause excessive load on the API server or etcd.

#### Step 3: Identify unoptimized API calls for a given user agent

Run the following query to tabulate the 99th percentile (P99) latency of API calls across different resource types for a given client.

# [Resource-specific](#tab/resource-specific)
```kusto
AKSAudit
| where TimeGenerated between(now(-1h)..now()) // When you experienced the problem
| extend HttpMethod = Verb
| extend Resource = tostring(ObjectRef.resource)
| where UserAgent == "DUMMYUSERAGENT" // Filter by name of the useragent you are interested in
| where Resource != ""
| extend start_time = RequestReceivedTime
| extend end_time = StageReceivedTime
| extend latency = datetime_diff('millisecond', end_time, start_time)
| summarize p99latency=percentile(latency, 99) by HttpMethod, Resource
| render table
```

# [Azure diagnostics](#tab/azure-diagnostics)
```kusto
AzureDiagnostics
| where TimeGenerated between(now(-1h)..now())  // When you experienced the problem
| where Category == "kube-audit" 
| extend event = parse_json(log_s) 
| extend HttpMethod = tostring(event.verb) 
| extend Resource = tostring(event.objectRef.resource) 
| extend User = tostring(event.user.username) 
| where User == "DUMMYUSERAGENT"  // Filter by name of the useragent you are interested in
| where Resource != ""
| extend start_time = todatetime(event.requestReceivedTimestamp)
| extend end_time = todatetime(event.stageTimestamp)
| extend latency = datetime_diff('millisecond', end_time, start_time)
| summarize p99latency=percentile(latency, 99) by HttpMethod, Resource 
| render table  
```

---

The results from this query can help you identify the kinds of API calls that fail the upstream Kubernetes SLOs. In most cases, an offending client makes too many `LIST` calls on a large set of objects or objects that are too large. API server or etcd scalability limits are multidimensional and explained in [Kubernetes Scalability thresholds](https://github.com/kubernetes/community/blob/main/sig-scalability/configs-and-limits/thresholds.md).

### Solution 5a: Tune your API call pattern

To reduce the pressure on the control plane, consider tuning your client's API server call pattern. Refer to [best practices](/en-us/azure/aks/best-practices-performance-scale-large#kubernetes-client-best-practices).

### Solution 5b: Throttle a client that's overwhelming the control plane

If you can't tune the client, use the [Priority and Fairness](https://kubernetes.io/docs/concepts/cluster-administration/flow-control/) feature in Kubernetes to throttle the client. This feature can help preserve the health of the control plane and prevent other applications from failing.

The following procedure shows you how to throttle an offending client's LIST Pods API set to five concurrent calls:

1. Create a [FlowSchema](https://kubernetes.io/docs/concepts/cluster-administration/flow-control/#flowschema) that matches the API call pattern of the offending client:

    ```yaml
    apiVersion: flowcontrol.apiserver.k8s.io/v1
    kind: FlowSchema
    metadata:
      name: restrict-bad-client
    spec:
      priorityLevelConfiguration:
        name: very-low-priority
      distinguisherMethod:
        type: ByUser
      rules:
      - resourceRules:
        - apiGroups: [""]
          namespaces: ["default"]
          resources: ["pods"]
          verbs: ["list"]
        subjects:
        - kind: ServiceAccount
          serviceAccount:
            name: bad-client-account
            namespace: default 
    ```
2. Create a lower priority configuration to throttle bad API calls of the client:

    ```yaml
    apiVersion: flowcontrol.apiserver.k8s.io/v1
    kind: PriorityLevelConfiguration
    metadata:
      name: very-low-priority
    spec:
      limited:
        nominalConcurrencyShares: 5
        limitResponse:
          type: Reject
      type: Limited
    ```
3. Observe the throttled call in the API server metrics:

    ```bash
    kubectl get --raw /metrics | grep "restrict-bad-client"
    ```

### Cause 6: High etcd memory usage (per an alert)

You might receive an alert that states that etcd memory usage exceeds 20 GiB. This alert indicates that your cluster is experiencing an intensive API server load. The load can cascade and overwhelm etcd memory capacity. If the excessive load isn't resolved promptly, it can cause performance degradation or outages.

To check the current etcd memory usage and understand the specific factors that contribute to the high memory consumption, go to **Diagnose and Solve Problems** in the Azure portal. Run the **Etcd Performance Analyzer** by searching for "*etcd performance*" in the Search box. The analyzer shows you the memory usage breakdown and helps identify whether the cause of the problem is high request rates, large object counts, or large object sizes.

[![Screenshot of the Etcd Performance Analyzer showing memory usage breakdown and top contributors in AKS.](media/troubleshoot-apiserver-etcd/etcd-performance-analyzer.png)](media/troubleshoot-apiserver-etcd/etcd-performance-analyzer.png#lightbox)

The root cause of high etcd memory usage is typically intensive API server load. This problem overlaps the other causes that this article discusses. To identify the specific problem that's affecting your cluster, use the following solution.

### Solution 6: Use existing diagnostic tools to identify and resolve the underlying cause

**Determine the primary contributing factor**

The etcd memory alert can trigger due to any combination of factors. Identify which factor is most problematic in your situation.

- **If excessive LIST or PUT calls are identified**: Follow the Cause 5 solution to tune API call patterns or throttle problematic clients.
- **If too many objects are stored in etcd**: Follow the Cause 3 solution to clean up objects and implement retention policies.
- **If large objects consume excessive memory**: Focus on the following object size reduction techniques.

    - To reduce pod specification sizes, move environment variables from pod specifications to ConfigMaps.
    - Split large secrets or ConfigMaps into smaller, more manageable pieces.
    - Review and optimize resource specifications in your applications.
    - Reduce revision counts.

    ```bash
    # Example: Clean up completed jobs that may have large specifications
    kubectl delete jobs --field-selector status.successful=1
    
    # Example: Clean up failed pods that may be consuming memory
    kubectl delete pods --field-selector status.phase=Failed
    ```

Tip

The etcd memory alert often indicates a combination of factors. Start at the **API Server Resource Intensive Listing Analyzer** to identify immediate request rate issues. Then, use the **Etcd Performance Analyzer** and **Etcd Capacity Analyzer** to understand object-related contributions to memory usage.

Important

Severe etcd memory pressure can cause the API server to become unresponsive. This condition might prevent you from performing the diagnostic steps that are provided in this article. In this situation, contact Azure support immediately to request assistance to clean up problematic objects or throttle excessive requests.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.