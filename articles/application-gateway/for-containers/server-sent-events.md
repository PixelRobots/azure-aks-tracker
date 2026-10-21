---
layout: Conceptual
title: Server-sent events and Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/server-sent-events
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
description: Learn how server-sent events interact with Azure Application Gateway for Containers.
services: application gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2025-05-08T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: 4dc1bfe5-760c-ebec-8f79-e5a4f924152a
document_version_independent_id: 29b578d1-bf03-5f95-578a-3feb14d04817
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/server-sent-events.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/server-sent-events
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/server-sent-events.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 78e06ac8-3139-f344-c27f-0493c66e5142
---

# Server-sent events and Application Gateway for Containers | Microsoft Learn

Server-sent events (SSEs) provide a useful mechanism to enable servers to push real-time updates to web clients over a single HTTP connection. Unlike WebSockets, which allow bidirectional communication, SSEs are unidirectional: the server sends data to the client without expecting any responses.

![A diagram depicting Application Gateway for Containers handling server-sent events.](media/server-sent-events/server-sent-events.png)

Applications using server-sent events can be found across several industries, such as medical (waiting area status boards), finance (displaying a stock ticker), aviation (flight status), and meteorology (current weather condition).

## Server-sent event connection and data flow

Server-sent events push data over the HTTP protocol. These events are supported by numerous browsers, defined by the EventSource interface, and standardized by W3C. The following process occurs for a server-sent event:

1. The client initiates a connection to the server.
2. The server sends a response containing the content-type of text/event-stream.
3. Both the client and server leave the connection open, enabling the server to send future events.

## Server-sent events and Application Gateway for Containers

## Server-sent events and scaling

When Application Gateway for Containers scales in, ongoing connections that aren't drained after 5 minutes are dropped. Server-sent events use automatic retry logic, which allows the application to establish a new connection and begin to receive new events.

### Server-sent events and HTTP/2

Server-sent events are supported both with HTTP/1.1 and HTTP/2. If the browser can support HTTP/2, server-sent events take advantage of multiplexing to improve performance by enabling multiple requests over the same connection.

### Configuration

Server-sent events are processed by Application Gateway for Containers. However, it's required to adjust the request timeout value for Application Gateway for Containers to prevent server-sent connections from timing out.

# [Gateway API](#tab/server-sent-events-gateway-api)
We recommend using Gateway API primitives. In Gateway API, define a `timeouts.request` value of `0s` on the `HTTPRouteRule`.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: query-param-matching
  namespace: test-sse
spec:
  parentRefs:
  - name: gateway-01
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    timeouts:
      request: "0s"
    backendRefs:
    - name: backend
      port: 80
```

# [RoutePolicy](#tab/server-sent-events-route-policy)
If you aren't using Gateway API HTTPRoute timeouts, define a `RoutePolicy` resource with a `routeTimeout` value of `0s`.

```yaml
apiVersion: alb.networking.azure.io/v1 
kind: RoutePolicy 
metadata: 
  name: route-policy-with-timeout 
  namespace: test-sse 
spec: 
  targetRef: 
    kind: HTTPRoute 
    name: query-param-matching 
    group: gateway.networking.k8s.io 
  default: 
    timeouts:  
      routeTimeout: 0s 
```

---

Note

If a Gateway API HTTPRoute timeout (`timeouts.request` or `timeouts.backendRequest`) is defined on the `HTTPRouteRule`, it's preferred over the `RoutePolicy` timeout. The `RoutePolicy``routeTimeout` is used when no Gateway API HTTPRoute timeout is defined, followed by the default timeout values.

Note

The idle timeout for Application Gateway for Containers is currently set to 5 minutes. If your application doesn't send or receive data within this period, consider sending a keep-alive request to prevent the connection from closing. You can implement this by prefixing a message with a colon `:` to act as a comment. For example, you may send the following message as a keep alive: `: keep-alive\n\n`