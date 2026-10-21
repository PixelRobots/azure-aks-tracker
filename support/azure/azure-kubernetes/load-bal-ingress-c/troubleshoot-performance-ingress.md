---
layout: Conceptual
title: Troubleshoot AKS managed NGINX ingress performance - Azure | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/load-bal-ingress-c/troubleshoot-performance-ingress
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
description: Learn how to troubleshoot Managed NGINX ingress controller performance issues in AKS and optimize scaling and latency. Follow the steps now.
ms.reviewer: claudiogodoy
ms.service: azure-kubernetes-service
ms.date: 2025-05-24T00:00:00.0000000Z
ms.custom: sap:Load balancer and Ingress controller
locale: en-us
document_id: 593f4621-deb6-4808-be14-e8834fafe34c
document_version_independent_id: 593f4621-deb6-4808-be14-e8834fafe34c
original_content_git_url: https://github.com/MicrosoftDocs/SupportArticles-docs-pr/blob/live/support/azure/azure-kubernetes/load-bal-ingress-c/troubleshoot-performance-ingress.md
site_name: Docs
depot_name: MSDN.support1-docset
page_type: conceptual
toc_rel: ../toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/MSDN.support1-docset/{branchName}{pdfName}
feedback_help_link_type: ''
feedback_help_link_url: ''
asset_id: azure/azure-kubernetes/load-bal-ingress-c/troubleshoot-performance-ingress
moniker_range_name: 
monikers: []
item_type: Content
source_path: support/azure/azure-kubernetes/load-bal-ingress-c/troubleshoot-performance-ingress.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: e4480bdd-4a54-c18a-b40a-2ef2a2e453ac
---

# Troubleshoot AKS managed NGINX ingress performance - Azure | Microsoft Learn

## Summary

The [Managed NGINX ingress controller](/en-us/azure/aks/app-routing) is a routing add-on that routes HTTP and HTTPS traffic to applications that run on an [Azure Kubernetes Service (AKS)](/en-us/azure/aks/) cluster.

The routing system might cause performance-related problems. This article provides step-by-step guidance to troubleshoot NGINX ingress controller performance problems. It also discusses common symptoms, root cause analysis, and configuration adjustments.

## Prerequisites

Before you start, make sure that you have the following tool installed:

- Kubernetes CLI (`kubectl`)

Use Azure CLI and run the `az aks install-cli` command.

## Symptoms

You receive an HTTP gateway error code like `502` or `504` or a response time error message when you run the NGINX ingress controller. This condition can indicate an NGINX exhaustion problem.

You encounter a significant difference between your service response time and the end-to-end response time. This condition can indicate latency that NGINX adds and an NGINX exhaustion problem.

## Cause

The most common cause of performance problems on NGINX is CPU exhaustion. During a load spike in the system, monitor [HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/) behavior. By default, the routing add-on creates a [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) named `app-routing-system`.

## Resolution

To troubleshoot the problem, follow these steps.

### Step 1: Verify horizontal pod autoscaler (HPA) behavior

1. Get the HPA name:

    ```console
    kubectl get hpa -n app-routing-system
    ```
2. Monitor the `HPA` behavior:

    ```console
    kubectl get hpa <HPA_NAME> -n app-routing-system -w
    ```
3. Evaluate the results:

    ```console
    $ kubectl get hpa <HPA_NAME> -n app-routing-system -w
    NAME    REFERENCE          TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
    nginx   Deployment/nginx   cpu: 83%/70%   1         2         1          77m
    nginx   Deployment/nginx   cpu: 83%/70%   1         2         2          77m
    nginx   Deployment/nginx   cpu: 106%/70%        1         2         2          79m
    nginx   Deployment/nginx   cpu: 133%/70%        1         2         2          80m
    ```

The **TARGETS** column shows the CPU threshold at which the `HPA` triggers to scale up the pods. This behavior has several possible causes:

- The `HPA` reached the maximum number of pods.
- No nodes are available to schedule the pods.

### Step 2: Look for pods in a pending state

If your evaluation reveals that the `NGINX HPA` didn't reach the maximum number of pods, the [kube-scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/#kube-scheduler) might not be able to find available nodes to schedule the `NGINX pods`. To find pending pods, run the following command:

```console
kubectl get pod --field-selector=status.phase=Pending -n app-routing-system
```

Note

If there are pending pods, the cluster might experience a resource exhaustion problem. For more information, see [Troubleshoot pod scheduler errors in Azure Kubernetes Service](../availability-performance/troubleshoot-pod-scheduler-errors).

### Step 3: Check whether limits are applied to the NGINX deployment

Any misconfiguration on the `NGINX`[resource limits or requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) can cause the `HPA` to scale up more pods than it needs. To check the limits, follow these steps:

1. Describe the NGINX deployment:

    ```console
    kubectl describe deploy nginx -n app-routing-system
    ```
2. Verify the requests and limits:

    ```console
    $ kubectl describe deploy nginx -n app-routing-system
    Name:                   nginx
    ....
    Selector:               app=nginx
    ....
    Pod Template:
    ....
    Containers:
    controller:
        ...
        Limits:
        ...
        Requests:
        ...
    ```

## More information

By default, the current version of the NGINX ingress controller doesn't set limits for NGINX pods. The controller requests `500m` CPU to use by the `HPA`. Don't change these settings directly in the deployment definition.

If the `HPA` reaches the maximum number of pods, and the deployment requests and limits remain unchanged, configure the [custom resource definition (CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) named [NginxIngressController](https://github.com/Azure/aks-app-routing-operator/blob/main/config/crd/bases/approuting.kubernetes.azure.com_nginxingresscontrollers.yaml).

### Configuration options

The following configuration options directly affect the `HPA` behavior.

| Property | Type | Description | Required | Default |
| --- | --- | --- | --- | --- |
| `scaling` | object | Configuration for scaling the controller. Contains nested properties. | No | Not applicable |
| `maxReplicas` | integer | Upper limit for replicas. | No | 100 |
| `minReplicas` | integer | Lower limit for replicas. | No | 2 |
| `threshold` | string | Scaling threshold that defines how aggressively to scale. Options include: `rapid`, `steady`, `balanced`. | No | balanced |

### Apply the configuration

1. Edit the NginxIngressController CRD:

    ```console
    kubectl edit nginxingresscontroller -n app-routing-system
    ```
2. Add or modify the scaling configuration:

    ```yaml
    spec:
      scaling:
        maxReplicas: 10
        minReplicas: 2
        threshold: "balanced"
    ```
3. Save the changes and exit the editor.
4. Verify the changes:

    ```console
    kubectl get hpa -n app-routing-system
    ```

The HPA automatically updates based on your new configuration. The NGINX ingress controller scales according to the specified parameters.

## References

- [Learn more about Azure Kubernetes Service (AKS) best practices](/en-us/azure/aks/best-practices)
- [Monitor your Kubernetes cluster performance with Container insights](/en-us/azure/azure-monitor/containers/container-insights-analyze)
- [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx)

**Third-party information disclaimer**

The third-party products that this article discusses are manufactured by companies that are independent of Microsoft. Microsoft makes no warranty, implied or otherwise, about the performance or reliability of these products.

**Third-party contact disclaimer**

Microsoft provides third-party contact information to help you find additional information about this topic. This contact information may change without notice. Microsoft does not guarantee the accuracy of third-party contact information.