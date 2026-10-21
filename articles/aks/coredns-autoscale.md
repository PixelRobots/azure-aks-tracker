---
layout: Conceptual
title: Configure Autoscaling for CoreDNS in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/coredns-autoscale
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
description: Learn how to configure and customize CoreDNS autoscaling in Azure Kubernetes Service (AKS) clusters.
ms.subservice: aks-networking
author: schaffererin
ms.topic: how-to
ms.date: 2025-09-08T00:00:00.0000000Z
ms.author: schaffererin
locale: en-us
document_id: fa4dc845-e550-8a3d-befb-2bad5985d0e7
document_version_independent_id: bc2ca2df-51ed-c42f-4282-11a4c2814544
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/coredns-autoscale.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/coredns-autoscale
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/coredns-autoscale.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: a5b2cb32-a991-9651-7aa5-711ed304b281
---

# Configure Autoscaling for CoreDNS in Azure Kubernetes Service (AKS) - Azure Kubernetes Service | Microsoft Learn

This article explains how to configure and customize CoreDNS autoscaling in Azure Kubernetes Service (AKS) clusters.

## Configure CoreDNS horizontal pod scaling

Due to the elastic nature of AKS, it's common to experience sudden spikes in DNS traffic within your clusters. These spikes can lead to an increase in memory consumption by CoreDNS pods. In some cases, this increased memory consumption can cause `Out of memory` issues.

To preempt this issue, AKS clusters autoscale CoreDNS pods to reduce memory usage per pod. The default settings for this autoscaling logic are stored in the `coredns-autoscaler` ConfigMap. However, you might observe that the default autoscaling of CoreDNS pods isn't always aggressive enough to prevent `Out of memory` issues for your CoreDNS pods. In this case, you can directly modify the `coredns-autoscaler` ConfigMap. Keep in mind that simply increasing the number of CoreDNS pods without addressing the root cause of the `Out of memory` issue might only provide a temporary fix. If there's not enough memory available across the nodes where the CoreDNS pods are running, increasing the number of CoreDNS pods won't help. You might need to investigate further and implement appropriate solutions such as optimizing resource usage, adjusting resource requests and limits, or adding more memory to the nodes.

CoreDNS uses the [horizontal cluster proportional autoscaler](https://github.com/kubernetes-sigs/cluster-proportional-autoscaler) for pod autoscaling. You can edit the `coredns-autoscaler` to configure the scaling logic for the number of CoreDNS pods. The `coredns-autoscaler` ConfigMap currently supports two different ConfigMap key values: `linear` and `ladder`, which correspond to two supported control modes.

- The `linear` controller yields a number of replicas in [min,max] range equivalent to `max( ceil( cores * 1/coresPerReplica ) , ceil( nodes * 1/nodesPerReplica ) )`.
- The `ladder` controller calculates the number of replicas by consulting two different step functions, one for core scaling and another for node scaling, yielding the max of the two replica values.

For more information on the control modes and ConfigMap format, see the [upstream documentation](https://github.com/kubernetes-sigs/cluster-proportional-autoscaler#control-patterns-and-configmap-formats).

Important

We recommend a minimum of *two* CoreDNS pod replicas per cluster.

### View the current `coredns-autoscaler` ConfigMap

- Get the current `coredns-autoscaler` ConfigMap using the [`kubectl get configmaps`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get) command.

    ```bash
    kubectl get configmap coredns-autoscaler --namespace kube-system --output yaml
    ```

    Your output should resemble the following example output:

    ```output
    apiVersion: v1
    data:
      ladder: '{"coresToReplicas":[[1,2],[512,3],[1024,4],[2048,5]],"nodesToReplicas":[[1,2],[8,3],[16,4],[32,5]]}'
    kind: ConfigMap
    metadata:
      name: coredns-autoscaler
      namespace: kube-system
      resourceVersion: "..."
      creationTimestamp: "..."
    ```

Note

The configuration provided serves as a potential starting point, but you should customize the values based on your specific cluster requirements and DNS traffic patterns. One way to determine the appropriate number of replicas for your environment is to use the linear scaling formula: `replicas = max( ceil( cores * 1/coresPerReplica ) , ceil( nodes * 1/nodesPerReplica ) )` to determine replica counts based on core / node count in the cluster.

## CoreDNS vertical pod autoscaling behavior

CoreDNS uses the original provided resource requests/limits when enabling the [add-on autoscaling feature](optimized-addon-scaling) to prevent service unavailability during the CoreDNS pod restart process.

The following table outlines the default requests/limits and request-to-limit ratios for the AKS CoreDNS add-on:

| Resource | Requests/limits | Request-to-limit ratio |
| --- | --- | --- |
| CPU | `100 m / 3 cores` | Approximately *1:30* |
| Memory | `70 Mi / 500 Mi` | Approximately *1:7* |

If the recommended CPU requests are *500 m*, VPA adjusts the CPU limits to *15* to maintain this ratio. Similarly, if the recommended memory requests are *700 Mi*, VPA adjusts the memory limit to *5000 Mi*.

VPA sets CoreDNS CPU and memory limits to large values based on the VPA recommended CPU/Memory request and AKS defined request-to-limit ratio. These adjustments are beneficial for handling multiple requests during peak service times. The drawback is that CoreDNS might consume all the CPU and memory available resource on the node when the peak service time.

It's difficult to set a single ideal CPU and memory requests/limits value to meet the requirements of both large cluster and small cluster at the same time. By enabling optimized add-on scaling, you have the flexibility to customize the CoreDNS CPU and memory requests/limits or use VPA to autoscale CoreDNS to meet specific cluster requirements. Keep the following scenarios in mind when deciding whether to customize the resource configuration or use VPA:

- You're considering whether VPA is suitable for your CoreDNS service and want to only view the VPA recommendations. You can disable VPA for CoreDNS by enabling the override VPA update mode to *Off* if you don't want VPA to automatically update the pods. [Customize the resource configuration in Deployment](customize-resource-configuration) to set the CPU/Memory requests/limits to the value you prefer.
- You're considering using VPA but want to restrict the ratio of request-to-limit so VPA won't bump the CPU and Memory limit to large values at one time. You can customize resources in the Deployment and update the CPU and Memory requests/limits value to keep the ratio of request-to-limit to *1:2* or *1:3*.
- If a VPA container policy sets maxAllowed CPU and Memory, the recommended resource requests won't exceed those limits. Customizing the resource configuration allows you to increase or decrease the maxAllowed values and control the recommendations of VPA.

For more information, see [Enable add-on autoscaling on your AKS cluster (Preview)](optimized-addon-scaling).