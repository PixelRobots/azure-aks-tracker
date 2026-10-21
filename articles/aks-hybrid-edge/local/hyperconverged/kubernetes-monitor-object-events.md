---
layout: Conceptual
title: Monitor Kubernetes object events in AKS Hybrid and Edge | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-object-events
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
learn_banner_products:
- azure
ms.service: azure-kubernetes-service-hybrid
description: Learn how to monitor real-time Kubernetes object events.
author: davidsmatlak
ms.topic: how-to
ms.date: 2026-09-01T00:00:00.0000000Z
ms.author: davidsmatlak
ms.lastreviewed: 2024-01-16T00:00:00.0000000Z
ms.reviewer: guanghu
ms.custom: hyperconverged
locale: en-us
document_id: e2400aa0-acff-54a1-ff06-29733379142b
document_version_independent_id: 26c3357d-0f78-1450-5213-db32864ec836
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-object-events.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: ../../../aks/toc.json
asset_id: aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-object-events
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks-hybrid-edge/local/hyperconverged/kubernetes-monitor-object-events.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
- https://authoring-docs-microsoft.poolparty.biz/devrel/5287f575-02f0-405f-92b7-800456526b0c
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
- https://authoring-docs-microsoft.poolparty.biz/devrel/06e86142-34c2-4b94-ab9c-9477c21f7152
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 12cfd9eb-a081-aa61-efc7-12de755f5edf
---

# Monitor Kubernetes object events in AKS Hybrid and Edge | Microsoft Learn

> 
> Applies to: AKS on Azure Local

Kubernetes events are real-time notifications that provide insights into actions and changes occurring within a Kubernetes cluster, helping you monitor and troubleshoot the health and behavior of their applications. These events capture and record information about the lifecycle of various Kubernetes objects, such as pods, nodes, services, and deployments. Kubernetes events don't persist throughout your cluster lifecycle, as there's no mechanism for retention. They are short-lived, only available for one hour after the event is generated. To store events for a longer time period, enable [Container Insights](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable).

## Kubernetes event objects

For a comprehensive list of all fields in a Kubernetes event, see [the official Kubernetes documentation](https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/event-v1/).

### Access events

You can find events for your cluster and its components by using `kubectl`:

```powershell
kubectl get events
```

To see a specific pod's events, first find the name of the pod, and then use `kubectl describe` to list events:

```powershell
kubectl get pods
kubectl describe pods <pod-name>
```

## Best practices

This section describes some best practices to follow when you monitor Kubernetes events.

### Filter events for relevance

In your Kubernetes cluster, you might have various namespaces and running services. To help you narrow down your focus to what's most relevant to your applications, you can filter events based on object type, namespace, or reason. For example, you can use the following command to filter events within a specific namespace:

```powershell
kubectl get events -n <namespace>
```

### Automate event notifications

To ensure a timely response to critical events in your cluster, you can set up automated notifications. Azure offers integration with monitoring and alerting services such as [Container Insights](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable). You can configure alerts to trigger based on specific event patterns. This way, you're immediately informed about crucial issues that require attention.

### Review events regularly

It's a good practice to regularly review events in your Kubernetes cluster. This proactive approach can help you identify trends, catch potential problems early, and prevent escalations. By staying on top of events, you can maintain the stability and performance of your applications.