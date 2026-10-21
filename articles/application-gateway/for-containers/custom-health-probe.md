---
layout: Conceptual
title: Custom health probe for Azure Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/custom-health-probe
breadcrumb_path: /azure/bread/toc.json
feedback_help_link_url: https://learn.microsoft.com/answers/tags/148/azure-application-gateway/
feedback_help_link_type: get-help-at-qna
feedback_product_url: https://feedback.azure.com/d365community/forum/8ae9bf04-8326-ec11-b6e6-000d3a4f0789?c=8d429912-8326-ec11-b6e6-000d3a4f0789
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
manager: kumud
ms.reviewer: mbender
description: Learn how to configure a custom health probe for Azure Application Gateway for Containers.
services: application gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2024-10-28T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: b0ddb048-fd8e-cee0-591b-3750f470472d
document_version_independent_id: 51911cfd-cb75-f238-3aa8-7461e7dbb56e
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/custom-health-probe.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/custom-health-probe
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/custom-health-probe.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
- https://authoring-docs-microsoft.poolparty.biz/devrel/07bb3e10-d135-43ff-bc8b-360497cb39fa
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
- https://authoring-docs-microsoft.poolparty.biz/devrel/12e559b9-eaf6-4aee-9af7-62334e15f863
platformId: 46c8762e-5128-9422-62f9-3800f1053fd8
---

# Custom health probe for Azure Application Gateway for Containers | Microsoft Learn

Application Gateway for Containers monitors the health of all backend targets by default. As backend targets become healthy or unhealthy, Application Gateway for Containers only distributes traffic to healthy endpoints.

In addition to using default health probe monitoring, you can also customize the health probe to suit your application's requirements. This article discusses both default and custom health probes.

The order and logic of health probing is as follows:

1. Use definition of HealthCheckPolicy Custom Resource (CR).
2. If there's no HealthCheckPolicy CR, then use [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes)
3. If there's no Readiness probe defined, use the default health probe

The following properties make up custom health probes:

| Property | Default Value |
| --- | --- |
| interval | How often in seconds health probes should be sent to the backend target. The minimum interval must be &gt; 0 seconds. |
| timeout | How long in seconds the request should wait until it's marked as a failure. The minimum interval must be &gt; 0 seconds. |
| healthyThreshold | Number of health probes before marking the target endpoint healthy. The minimum interval must be &gt; 0. |
| port | The port number used when probing the backend target. |
| unhealthyThreshold | Number of health probes to fail before the backend target should be labeled unhealthy. The minimum interval must be &gt; 0. |
| grpc | Specified if the backend service is expecting gRPC connections. The value must be `{}`. |
| (http) | Specified if the backend service is expecting http connections. |
| (http) host | The hostname specified in the request to the backend target. |
| (http) path | The specific path of the request. If a single file should be loaded, the path might be /index.html. |
| (http -&gt; match) statusCodes | Contains two properties, `start` and `end`, that define the range of valid HTTP status codes returned from the backend. |
| useTLS | Specifies if the health check should enforce TLS. If not specified, health check uses the same protocol as the service if the same port is used for health check. If the port is different, health check is cleartext. |

[![A diagram showing the Application Gateway for Containers using custom health probes to determine backend health.](media/custom-health-probe/custom-health-probe.png)](media/custom-health-probe/custom-health-probe.png#lightbox)

## Default health probe

Application Gateway for Containers automatically configures a default health probe when you don't define a custom probe configuration or configure a readiness probe. The monitoring behavior works by making an HTTP GET request to the IP addresses of configured backend targets. For default probes, if the backend target is configured for HTTPS, the probe uses HTTPS to test health of the backend targets.

For more implementation details, see [HealthCheckPolicyConfig](api-specification-kubernetes#alb.networking.azure.io/v1.HealthCheckPolicyConfig) in the API specification.

When the default health probe is used, the following values for each health probe property are used:

| Property | Default Value |
| --- | --- |
| interval | 5 seconds |
| timeout | 30 seconds |
| healthyThreshold | 1 probe |
| unhealthyThreshold | 3 probes |
| port | The port number used is defined by the backend port number in the Ingress resource or HttpRoute backend port in the HttpRoute resource. |
| (http) host | localhost |
| (http) path | / |
| useTLS | HTTP for HTTP and HTTPS when TLS is specified. |

^1^ HTTPS is used when a backendTLSPolicy references a target backend service (for Gateway API implementation) or IngressExtension with a backendSetting protocol of HTTPS (for Ingress API implementation) is specified.

Note

Health probes are initiated with the `User-Agent` value of `Microsoft-Azure-Application-LB/AGC`.

## Custom health probe

In both Gateway API and Ingress API, a custom health probe can be defined by defining a [*HealthCheckPolicyPolicy* resource](api-specification-kubernetes#alb.networking.azure.io/v1.HealthCheckPolicy) and referencing a service the health probes should check against. As the service is referenced by an HTTPRoute or Ingress resource with a class reference to Application Gateway for Containers, the custom health probe is used for each reference.

In this example, the health probe emitted by Application Gateway for Containers sends the hostname contoso.com to the pods that make up *test-service*. The requested protocol is `http` with a path of `/`. A probe is emitted every 5 seconds and waits 3 seconds before determining the connection has timed out. If a response is received, an HTTP response code between 200 and 299 (inclusive of 200 and 299) is considered healthy, all other responses are considered unhealthy.

```bash
kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: HealthCheckPolicy
metadata:
  name: gateway-health-check-policy
  namespace: test-infra
spec:
  targetRef:
    group: ""
    kind: Service
    name: test-service
    namespace: test-infra
  default:
    interval: 5s
    timeout: 3s
    healthyThreshold: 1
    unhealthyThreshold: 1
    port: 8123
    # grpc: {} # defined if probing a gRPC endpoint
    http:
      host: contoso.com
      path: /
      match:
        statusCodes: 
        - start: 200
          end: 299
    useTLS: true
EOF
```