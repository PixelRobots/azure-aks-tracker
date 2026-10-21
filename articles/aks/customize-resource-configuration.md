---
layout: Conceptual
title: Customize the resource configuration for managed add-ons - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/customize-resource-configuration
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
description: Learn how to customize the resource configuration for managed add-ons.
ms.author: schaffererin
author: schaffererin
ms.topic: how-to
ms.date: 2025-05-20T00:00:00.0000000Z
locale: en-us
document_id: 2e9dd87d-1ab0-ed5b-f652-6b40919f8898
document_version_independent_id: 24b8da32-34da-7fe6-9026-5655fc2f2581
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/customize-resource-configuration.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/customize-resource-configuration
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/customize-resource-configuration.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: 15ef5932-c52d-0ddd-dd3e-b410506d3943
---

# Customize the resource configuration for managed add-ons - Azure Kubernetes Service | Microsoft Learn

This article provides an overview of how to customize the resource configuration for Azure Kubernetes Service (AKS) managed add-ons with [cost optimized add-on scaling (Preview)](optimized-addon-scaling).

## Overview

Enabling the cost optimized add-on scaling feature in your AKS cluster installs the Vertical Pod Autoscaler (VPA) add-on and VPA custom resources for AKS managed add-ons that support this capability. This feature also allows you to manually customize the resource CPU and memory requests and limits in Deployments and DaemonSets. You can also customize the maximum and minimum allowed CPU and memory and the VPA update mode within VPA custom resources.

## Prerequisites

- Review the [supported AKS managed add-ons](optimized-addon-scaling#supported-aks-add-ons) and [limitations](optimized-addon-scaling) for this feature.
- You need an AKS cluster enabled with the cost optimized add-on scaling feature. If you don't have one, see [Enable cost optimized add-on scaling on your AKS cluster (Preview)](optimized-addon-scaling).

## Customize resource annotations

| Annotation | Description | Values |
| --- | --- | --- |
| `kubernetes.azure.com/override-requests-limits` | Supports the capability to customize the container resource CPU/memory requests/limits in a Deployment or DaemonSet if the value is "enabled". Set the value to "disabled" to reset to AKS defaults. | "enabled" or "disabled" |
| `kubernetes.azure.com/override-min-max` | Supports the capability to customize the container policy maximum/minimum allowed CPU/memory value in VPA custom resource if the value is "enabled". Set the value to "disabled" to reset to AKS defaults. | "enabled" or "disabled" |
| `kubernetes.azure.com/override-update-mode` | Supports the capability to customize the update policy `updateMode` value in a VPA custom resource if the value is "enabled". Set the value to "disabled" to reset to AKS defaults. | "enabled" or "disabled" |

## Customize resource CPU/memory requests/limits

After setting the `kubernetes.azure.com/override-requests-limits` annotation to "enabled" in a Deployment or DaemonSet, you can customize the resource CPU/memory requests and limits. The following example shows how to customize the resource CPU/memory requests and limits in a Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
  annotations:
    # update value from "disabled" to "enabled"
    kubernetes.azure.com/override-requests-limits: "enabled"
spec:
  ...
  containers:
  - name: coredns
    resources:
      limits:
        # update cpu limits value won't be reconciled back
        cpu: "3"
        # update memory limits value won't be reconciled back
        memory: "500Mi"
      requests:
        # update cpu requests value won't be reconciled back
        cpu: "100m"
        # update memory requests value won't be reconciled back
        memory: "70Mi"
```

## Customize resource maximum/minimum allowed CPU/memory

After setting the `kubernetes.azure.com/override-min-max` annotation to "enabled" in a VPA custom resource, you can customize the maximum and minimum allowed CPU and memory values in a VPA custom resource. The following example shows how to customize the maximum and minimum allowed CPU and memory values in a VPA custom resource:

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: coredns
  namespace: kube-system
  annotations:
    # update value from "disabled" to "enabled"
    kubernetes.azure.com/override-min-max: "enabled"
spec:
  resourcePolicy:
    containerPolicies:
    - containerName: coredns
      maxAllowed:
        # update maxAllowed cpu value won't be reconciled back
        cpu: 3
        # update maxAllowed memory value won't be reconciled back
        memory: 500Mi
      minAllowed:
        # update minAllowed cpu value won't be reconciled back
        cpu: 10m
        # update minAllowed memory value won't be reconciled back
        memory: 10Mi
  ...
```

## Customize resource update mode

After setting the `kubernetes.azure.com/override-update-mode` annotation to "enabled" in a VPA custom resource, you can customize the update policy `updateMode` value in a VPA custom resource to "Off" or "Initial" (default). The following example shows how to customize the update policy `updateMode` value to "Initial" in a VPA custom resource:

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: coredns
  namespace: kube-system
  annotations:
    # update value from "disabled" to "enabled"
    kubernetes.azure.com/override-update-mode: "enabled"
spec:
  ...
  updatePolicy:
    # update updateMode won't be reconciled back
    updateMode: "Initial"
```

## Disable VPA on a specific AKS managed add-on

To disable VPA on a specific AKS managed add-on, you need to update the VPA custom resource YAML file to set the `kubernetes.azure.com/override-update-mode` annotation to `"enabled"` and the `updateMode` to `"Off"`. With *Off* mode, the VPA only provides CPU and memory recommendations and doesn't apply the changes to the pod.

The following example shows how to disable VPA on the CoreDNS add-on:

```yml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: coredns
  namespace: kube-system
  annotations:
    # Set value to "enabled"
    kubernetes.azure.com/override-update-mode: "enabled"
spec:
  ...
  updatePolicy:
    # Set value to "Off"
    updateMode: "Off"
```

## Troubleshooting

1. Make sure the AKS managed add-on supports the cost optimized add-on scaling feature. For more information, see [Supported AKS managed add-ons](optimized-addon-scaling#supported-aks-add-ons).
2. Verify that the `kubernetes.azure.com/override-requests-limits` annotation in the Deployment or DaemonSet is set to "enabled".
3. Verify that the `kubernetes.azure.com/override-min-max` annotation in the VPA custom resource is set to "enabled".
4. Verify that the `kubernetes.azure.com/override-update-mode` annotation in the VPA custom resource is set to "enabled".