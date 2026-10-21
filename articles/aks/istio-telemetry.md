---
layout: Conceptual
title: Istio-based service mesh add-on telemetry - Azure Kubernetes Service | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/aks/istio-telemetry
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
description: Configure telemetry for Istio-based service mesh add-on for Azure Kubernetes Service.
ms.topic: how-to
ms.date: 2024-08-14T00:00:00.0000000Z
ms.author: nshankar
author: niranjanshankar
locale: en-us
document_id: cb9dd560-fc30-5368-0f1d-03c879929f2e
document_version_independent_id: f0c889b7-1504-1e6a-316c-52675d2a4e5b
original_content_git_url: https://github.com/MicrosoftDocs/azure-aks-docs-pr/blob/live/articles/aks/istio-telemetry.md
site_name: Docs
depot_name: Learn.azure-aks
page_type: conceptual
toc_rel: toc.json
asset_id: aks/istio-telemetry
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/aks/istio-telemetry.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d44a5346-5de4-439c-b804-7b2a536cbb55
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/da41a22b-b7a0-42d3-9c35-50da1c2b7b87
platformId: c165f1c9-c223-28b5-fdbf-a8aec6a8e23c
---

# Istio-based service mesh add-on telemetry - Azure Kubernetes Service | Microsoft Learn

Istio can [generate metrics, distributed traces, and access logs](https://istio.io/latest/docs/concepts/observability/) for all workloads in the mesh. The Istio-based service mesh add-on for Azure Kubernetes Service (AKS) provides telemetry customization options through the [shared MeshConfig](istio-meshconfig) and the Istio Telemetry API `v1` for Istio add-on minor revisions `asm-1-22` and higher.

Note

While the [Istio MeshConfig](istio-meshconfig) also provides options for configuring telemetry globally across the mesh, the Telemetry API offers more granular control over telemetry settings on a per-service or per-workload basis. As the Istio community continues to invest in the Telemetry API, it is now the preferred method for telemetry configuration. We encourage migrating to the Telemetry API for configuring telemetry to be collected in the mesh.

## Prerequisites

- You must be on revision `asm-1-22` or higher. For information on how to perform minor version upgrades, see the [Istio add-on upgrade documentation](istio-upgrade).

## Configure Telemetry resources

The following example demonstrates how Envoy access logging can be enabled across the mesh for the Istio add-on via the Telemetry API using `asm-1-22` (adjust the revision as needed). For guidance on other Telemetry API customizations for the add-on, see the Telemetry API support scope section and the [Istio documentation](https://istio.io/latest/docs/reference/config/telemetry/).

### Deploy sample applications

Label the namespace for sidecar injection:

```azurecli
kubectl label ns default istio.io/rev=asm-1-22
```

Deploy the `sleep` application and set the `SOURCE_POD` environment variable:

```azurecli
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/sleep/sleep.yaml
export SOURCE_POD=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})
```

Then, deploy the `httpbin` application:

```azurecli
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/httpbin/httpbin.yaml
```

### Enable Envoy access logging with the Istio Telemetry API

Deploy the following Istio `v1` Telemetry API resource to enable Envoy access logging for the entire mesh:

```azurecli
cat <<EOF | kubectl apply -n aks-istio-system -f -
apiVersion: telemetry.istio.io/v1
kind: Telemetry
metadata:
  name: mesh-logging-default
spec:
  accessLogging:
  - providers:
    - name: envoy
EOF
```

### Test access logs

Send a request from `sleep` to `httpbin`:

```azurecli
kubectl exec "$SOURCE_POD" -c sleep -- curl -sS -v httpbin:8000/status/418
```

Verify that access logs are visible for the `sleep` pod:

```azurecli
kubectl logs -l app=sleep -c istio-proxy
```

You should see the following output:

```bash
[2024-08-13T00:31:47.690Z] "GET /status/418 HTTP/1.1" 418 - via_upstream - "-" 0 135 12 11 "-" "curl/8.9.1" "cdecaca5-5964-48f3-b42d-f474dfa623d5" "httpbin:8000" "10.244.0.13:8080" outbound|8000||httpbin.default.svc.cluster.local 10.244.0.12:53336 10.0.112.220:8000 10.244.0.12:42360 - default
```

Now, verify that access logs are visible for the `httpbin` pod:

```azurecli
kubectl logs -l app=httpbin -c istio-proxy
```

You should see the following output:

```bash
[2024-08-13T00:31:47.696Z] "GET /status/418 HTTP/1.1" 418 - via_upstream - "-" 0 135 2 1 "-" "curl/8.9.1" "cdecaca5-5964-48f3-b42d-f474dfa623d5" "httpbin:8000" "10.244.0.13:8080" inbound|8080|| 127.0.0.6:55401 10.244.0.13:8080 10.244.0.12:53336 outbound_.8000_._.httpbin.default.svc.cluster.local default
```

## Telemetry API support scope

For the Istio service mesh add-on for AKS, Telemetry API fields are classified as `allowed`, `supported`, and `blocked` values. For more information about the Istio add-on's support policy for features and mesh configurations, see the Istio add-on [support policy document](istio-support-policy#allowed-supported-and-blocked-customizations).

The following Telemetry API configurations are either `allowed` or `supported` for the Istio add-on. Any field not included in this table is `blocked`.

| **Telemetry API Field** | **Supported/Allowed** | **Notes** |
| --- | --- | --- |
| `accessLogging.match` | Supported | - |
| `accessLogging.disabled` | Supported | - |
| `accessLogging.providers` | Allowed | The default `envoy` access log provider is supported. For a managed experience for log collection and querying, see [Azure Monitor Container Insights Log Analytics](/en-us/azure/azure-monitor/containers/container-insights-overview). Third-party or open-source log collection and analytics solutions are `allowed` but unsupported. |
| `metrics.overrides` | Supported | - |
| `metrics.providers` | Allowed | Metrics collection with [Azure Monitor Managed Prometheus](/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable) is supported. Third-party or open-source metrics scraping solutions are `allowed` but unsupported. |
| `tracing.*` | Allowed | All tracing configurations are `allowed` but unsupported. |