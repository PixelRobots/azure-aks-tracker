---
layout: Conceptual
title: Use Kubernetes events for troubleshooting - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/events
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
description: Learn about Kubernetes events, which provide details on pods, nodes, and other Kubernetes objects.
ms.topic: how-to
ms.author: schaffererin
author: schaffererin
ms.subservice: aks-monitoring
ms.date: 2024-06-13T00:00:00.0000000Z
ms.custom: innovation-engine
locale: en-us
document_id: 0db1fbac-00c4-8b42-bcd0-5f6630d62fbf
document_version_independent_id: 8fbfb184-578c-f59e-4fb8-f9515146247d
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/events.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/events
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/events.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 736ebe6b-fde6-899c-3946-56c200fb5bfa
---

# Use Kubernetes events for troubleshooting - Azure Kubernetes Service | Microsoft Learn

This article shows you how to use Kubernetes events to monitor and troubleshoot issues in your Azure Kubernetes Service (AKS) clusters.

## What are Kubernetes events?

Events are one of the most prominent sources for monitoring and troubleshooting issues in Kubernetes. They capture and record information about the lifecycle of various Kubernetes objects, such as pods, nodes, services, and deployments. By monitoring events, you can gain visibility into your cluster's activities, identify issues, and troubleshoot problems effectively.

Kubernetes events don't persist throughout your cluster lifecycle, as there's no retention mechanism. Events are **only available for *one hour* after the event is generated**. To store events for a longer time period, enable [Container insights](/en-us/azure/azure-monitor/containers/container-insights-enable-aks).

## Kubernetes event objects

The following table lists some key Kubernetes event objects:

| Field name | Description |
| --- | --- |
| type | The type is based on the severity of the event:**Warning** events signal potentially problematic situations, such as a pod repeatedly failing or a node running out of resources. They require attention, but might not result in immediate failure.**Normal** events represent routine operations, such as a pod being scheduled or a deployment scaling up. They usually indicate healthy cluster behavior. |
| reason | The reason why the event was generated. For example, *FailedScheduling* or *CrashLoopBackoff*. |
| message | A human-readable message that describes the event. |
| namespace | The namespace of the Kubernetes object that the event is associated with. |
| firstSeen | Timestamp when the event was first observed. |
| lastSeen | Timestamp of when the event was last observed. |
| reportingController | The name of the controller that reported the event. For example, `kubernetes.io/kubelet`. |
| object | The name of the Kubernetes object that the event is associated with. |

For more information, see the official [Kubernetes documentation](https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/).

## View Kubernetes events

# [Azure CLI](#tab/azure-cli)
List all events in your cluster using the `kubectl get events` command.

Assuming your cluster is already created and available (per doc prerequisites), get credentials (note the `--overwrite-existing` flag is set to avoid kubeconfig errors):

```bash
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --overwrite-existing
```

Now list all events in your cluster:

```bash
kubectl get events
```

Results:

```output
LAST SEEN   TYPE      REASON              OBJECT                      MESSAGE
xxm         Normal    Scheduled           pod/my-pod-xxxxx            Successfully assigned default/my-pod-xxxxx to aks-nodepoolxx-xxxxxxx-vmss000000
xxm         Normal    Pulled              pod/my-pod-xxxxx            Container image "nginx" already present on machine
xxm         Normal    Created             pod/my-pod-xxxxx            Created container nginx
xxm         Normal    Started             pod/my-pod-xxxxx            Started container nginx
...
```

Look at a specific pod's events by first finding the name of the pod and then using the `kubectl describe pod` command.

List the pods in the current namespace:

```bash
kubectl get pods
```

Results:

```output
NAME                             READY   STATUS    RESTARTS   AGE
my-pod-xxxxx                     1/1     Running   0          xxm
nginx-deployment-xxxxx           1/1     Running   0          xxm
...
```

Replace `<pod-name>` below with your actual pod name. For automation, here's an example for the first pod in the list:

```shell
POD_NAME=$(kubectl get pods -o jsonpath="{.items[0].metadata.name}")
kubectl describe pod $POD_NAME
```

# [Azure portal](#tab/azure-portal)
1. Open the Azure portal and navigate to your AKS cluster resource.
2. From the service menu, under **Kubernetes resources**, select **Events**.
3. The **Events** page displays a list of events in your cluster. You can filter events by type, reason, source, object, or namespace. You can combine filters to narrow down the results.

---

## Best practices for troubleshooting with events

### Filtering events for relevance

You might have various namespaces and services running in your AKS cluster. Filtering events based on object type, namespace, or reason can help narrow down the results to the most relevant information.

For example, you can use the following command to filter events within the default namespace:

```bash
kubectl get events --namespace default
```

### Automating event notifications

To ensure timely response to critical events in your AKS cluster, set up automated notifications. Azure offers integration with monitoring and alerting services like [Azure Monitor](monitor-aks). You can configure alerts to trigger based on specific event patterns. This way, you're immediately informed about crucial issues that require attention.

### Regularly reviewing events

Make a habit of regularly reviewing events in your AKS cluster. This proactive approach can help you identify trends, catch potential problems early, and prevent escalations. By staying on top of events, you can maintain the stability and performance of your applications.