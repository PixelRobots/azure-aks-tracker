---
layout: Conceptual
title: Multi-cluster DNS-based load balancing with Azure Kubernetes Fleet Manager | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/kubernetes-fleet/concepts-dns-load-balancing
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
learn_banner_products:
- azure
description: Understand how Fleet Manager supports DNS-based load balancing for placed workloads.
ms.date: 2026-05-14T00:00:00.0000000Z
author: sjwaight
ms.author: simonwaight
ms.service: azure-kubernetes-fleet-manager
ms.topic: concept-article
locale: en-us
document_id: 2a8da6d5-47c9-7fe2-6629-138f05b65236
document_version_independent_id: f3daf3ed-5374-e9d7-dc05-9df482a29d69
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/kubernetes-fleet/concepts-dns-load-balancing.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: kubernetes-fleet/concepts-dns-load-balancing
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/kubernetes-fleet/concepts-dns-load-balancing.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/a21829dd-8109-415c-84d3-07c42e4d33fd
- https://authoring-docs-microsoft.poolparty.biz/devrel/68ec7f3a-2bc6-459f-b959-19beb729907d
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/70f417fa-3512-48b5-a80a-bb8985120ba9
- https://authoring-docs-microsoft.poolparty.biz/devrel/90370425-aca4-4a39-9533-d52e5e002a5d
platformId: 696c976d-210e-ed75-ebdd-e7cdb4a0088b
---

# Multi-cluster DNS-based load balancing with Azure Kubernetes Fleet Manager | Microsoft Learn

**Applies to**: ✔️ Fleet Manager with hub cluster

Azure Kubernetes Fleet Manager can be used to create and manage DNS-based multi-cluster load balancing for public-facing workloads deployed across member clusters.

Important

Azure Kubernetes Fleet Manager preview features are available on a self-service, opt-in basis. Previews are provided "as is" and "as available," and they're excluded from the service-level agreements and limited warranty. Azure Kubernetes Fleet Manager previews are partially covered by customer support on a best-effort basis. As such, these features aren't meant for production use.

Our data plane networking previews are released via our `networking.fleet.azure.com/v1beta1` API. If you don't see preview objects, check that you're requesting the `networking.fleet.azure.com/v1beta1` API when you interact with the Fleet Manager hub cluster.

[![A diagram showing a conceptual overview of how Fleet Manager supports DNS load balancing across three member clusters using Azure Traffic Manager and Kubernetes ServiceExport resources.](media/concepts-dns-load-balancing/fleet-dns-load-balance-conceptual.png)](media/concepts-dns-load-balancing/fleet-dns-load-balance-conceptual.png#lightbox)

To deliver multi-cluster public load balancing with DNS, Fleet Manager utilizes [Azure Traffic Manager](/en-us/azure/traffic-manager/traffic-manager-overview) with a [weighted routing profile](/en-us/azure/traffic-manager/traffic-manager-routing-methods#weighted-traffic-routing-method) to act as a frontend for `Services` exported from member clusters. It is possible to use this capability for both layer 4 and 7 load balancing.

Fleet administrators use `kubectl` to create and configure `TrafficManagerProfile` and `TrafficManagerBackend` resources on the Fleet Manager hub cluster. The `TrafficManagerProfile` defines an Azure Traffic Manager Profile that includes [endpoint health monitoring](/en-us/azure/traffic-manager/traffic-manager-monitoring#configure-endpoint-monitoring) configuration, with the associated `TrafficManagerBackend` defining the `Service` to be load balanced.

Services on member clusters can be added to the load balancing by creating a `ServiceExport` on the cluster and configuring a unique DNS hostname for the `Service`. Optional weights can be defined that configure traffic routing behavior between clusters. If the workload is deployed using Fleet Manager's [cluster resource placement](concepts-resource-placement), the DNS hostname can be configured on placement using a `ResourceOverride`.

The creation and configuration of the associated Traffic Manager is managed by Fleet Manager, with fleet administrators able to drive the end to end experience using the Kubernetes API.

## TrafficManagerProfile properties

The `TrafficManagerProfile` resource provides a Kubernetes object representation of a standard Azure Traffic Manager Profile.

```yml
apiVersion: networking.fleet.azure.com/v1beta1
kind: TrafficManagerProfile
metadata:
  name: myatm
  namespace: work
spec:
  monitorConfig:
    protocol: HTTP
    path: /api
    port: 8080
    intervalInSeconds: 30
    timeoutInSeconds: 10
    toleratedNumberOfFailures: 3
```

The important properties to understand include:

- `name`: used as the DNS prefix for the `trafficmanager.net` DNS name. It must be unique. If the name is already in use, deployment fails.
- `namespace`: must be the same as the corresponding `TrafficManagerBackend` and `Service` resources.
- `monitorConfig`: maps to the standard Azure Traffic Manager monitoring configuration. Unsupported Azure Traffic Manager endpoint monitoring options are: Custom header settings; expected status codes.

## TrafficManagerBackend properties

The `TrafficManagerBackend` resource provides a Kubernetes object that is used to store backend endpoints which can be considered by Traffic Manager to receive traffic. Before traffic is routed to an endpoint a `ServiceExport` must be created.

```yml
apiVersion: networking.fleet.azure.com/v1beta1
kind: TrafficManagerBackend
metadata:
  name: app
  namespace: work
spec:
  profile:
    name: myatm
  backend:
    name: app
  weight: 100
```

The important properties to understand include:

- `spec/profile/name`: must match the corresponding `TrafficManagerProfile`.
- `spec/backend/name`: must match the exported service name to load balance.
- `spec/weight`: optional weight (priority) to apply to this backend. Integer value between 0 and 1,000. If omitted, Traffic Manager uses a default weight of '1'. Set to '0' to disable traffic routing without deleting the associated Traffic Manger Profile resource. For further information, see [Azure Traffic Manager weighted routing method](/en-us/azure/traffic-manager/traffic-manager-routing-methods#weighted-traffic-routing-method).

## ServiceExport properties

To add an endpoint for a `Service` to Traffic Manager, create a `ServiceExport` resource on the member cluster containing the service. The `ServiceExport` resource must be created in the same namespace as the `Service` to be exported.

```yml
apiVersion: networking.fleet.azure.com/v1alpha1
kind: ServiceExport
metadata:
  name: kuard-export
  namespace: kuard-demo
  annotations:
    networking.fleet.azure.com/weight: "50"
```

The important properties to understand include:

- `metadata/namespace`: must match the namespace of the `Service` to be exported.
- `metadata/annotations/networking.fleet.azure.com/weight`: optional weight (priority) to apply to this service export. Integer value between 0 and 1,000. If omitted, Traffic Manager uses a default weight of '1'. Set to '0' to disable traffic routing without deleting the associated Service endpoint. For further information, see [Azure Traffic Manager weighted routing method](/en-us/azure/traffic-manager/traffic-manager-routing-methods#weighted-traffic-routing-method).

## Unique DNS hostname via Service annotation

In order to add a `Service` to the Traffic Manager, it must have a unique DNS hostname. The DNS hostname can be set by following the AKS recommended method of using the `service.beta.kubernetes.io/azure-dns-label-name` annotation as shown.

```yml
apiVersion: v1
kind: Service
metadata:
  name: kuard-svc
  namespace: kuard-demo
  labels:
    app: kuard
  annotations:
    service.beta.kubernetes.io/azure-dns-label-name: kuard-demo-cluster-01
spec:
  selector:
    app: kuard
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```

The DNS label annotation can be overridden using the `ResourceOverride` feature of Fleet Manager making it possible to deploy unique host names across multiple clusters. For further information, see the [DNS load balancing how-to guide](howto-dns-load-balancing).

## Controlling traffic routing

In this section we look at common scenarios for controlling traffic routing between clusters.

### Distribute traffic across clusters

To allow Traffic Manager to consider any cluster to receive traffic use the definitions shown.

1. Create a `TrafficManagerBackend` resource and omit the `weight` property.

    ```yml
    apiVersion: networking.fleet.azure.com/v1beta1
    kind: TrafficManagerBackend
    metadata:
      name: app
      namespace: work
    spec:
      profile:
        name: myatm
      backend:
        name: app
    ```
2. On each cluster, create a `ServiceExport` and omit the `weight` property.

    ```yml
    apiVersion: networking.fleet.azure.com/v1alpha1
    kind: ServiceExport
    metadata:
      name: kuard-export
      namespace: kuard-demo
    ```

Once deployed, Traffic Manager will pick a cluster at random, considering all clusters of equal weight.

### Distribute traffic across clusters with different weights

To provide Traffic Manager with preference hints when selecting clusters, set the `weight` property on the `TrafficManagerBackend` and `ServiceExport` objects.

1. Create a `TrafficManagerBackend` resource and set the `weight` property to `100`.

    ```yml
    apiVersion: networking.fleet.azure.com/v1beta1
    kind: TrafficManagerBackend
    metadata:
      name: app
      namespace: work
    spec:
      profile:
        name: myatm
      backend:
        name: app
      weight: 100
    ```
2. Create a `ServiceExport` and set the `weight` property to a value representing the priority Traffic Manager should use when considering a cluster to receive traffic.

    ```yml
    apiVersion: networking.fleet.azure.com/v1alpha1
    kind: ServiceExport
    metadata:
      name: kuard-export
      namespace: kuard-demo
      annotations:
        networking.fleet.azure.com/weight: "40"
    ```

Once deployed, Traffic Manager will preference clusters with a higher weight. It is not required that you set the weight value on every cluster. If you set the weight value the same on more than one cluster, Traffic Manager will consider those clusters equally.

### Exclude a cluster from traffic routing

To exclude a cluster from traffic routing, set the `weight` property to `0` on the `ServiceExport` resource. This weight removes the endpoint from the Traffic Manager configuration.

```yml
apiVersion: networking.fleet.azure.com/v1alpha1
kind: ServiceExport
metadata:
  name: kuard-export
  namespace: kuard-demo
  annotations:
    networking.fleet.azure.com/weight: "0"
```

## TrafficManagerProfile deletion behavior

When a `TrafficManagerProfile` Kubernetes resource is deleted, the associated Azure Traffic Manager and its endpoints are also deleted and requests are no longer routed to clusters.

If you wish to stop traffic routing but retain the Azure Traffic Manager and its endpoints, set the `weight` property to `0` on the `TrafficManagerBackend` resource.