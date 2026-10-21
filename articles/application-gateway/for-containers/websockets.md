---
layout: Conceptual
title: WebSocket protocol and Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/websockets
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
description: Learn how the WebSocket protocol is used with Application Gateway for Containers.
services: application gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2025-01-13T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: cc868d3a-fd1d-8295-2106-8295f238e84e
document_version_independent_id: 6b7be058-6c41-6666-c53c-8a55fd42136e
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/websockets.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/websockets
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/websockets.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: b2ad46b1-70ca-6e6b-fdc2-838c09e91104
---

# WebSocket protocol and Application Gateway for Containers | Microsoft Learn

WebSockets, established in [RFC6455](https://datatracker.ietf.org/doc/html/rfc6455), enable two-way communication between a client and server. Unlike a traditional HTTP or HTTPS request that, WebSockets allow for the browser to establish a connection and receive continuous data from a server, without having to constantly pull the remote server or need to establish multiple connections in both directions (client to server and server to client).

## WebSocket benefits

The WebSocket protocol has several benefits over traditional HTTP requests, including:

- Browser compatibility: Nearly all modern web browsers support WebSockets.
- Real-time data: WebSockets enable real-time data transfer between client and server.
- Efficiency: WebSockets eliminate the need to continuously poll servers to check for updates.
- Security: WebSockets can be encrypted using TLS and use standard HTTP ports, such as 80 and 443.
- Flexibility: WebSockets can be used for a variety of applications, including chat, gaming, and financial trading platforms.

## How the WebSocket protocol works

To establish a WebSocket connection, a specific HTTP-based handshake is exchanged between the client and the server. If successful, the application-layer protocol is "upgraded" from HTTP to WebSockets, using the previously established TCP connection. Once this occurs, the protocol is changed to WebSockets and traffic no longer flows over HTTP. Data is sent or received using the WebSocket protocol by both endpoints until the WebSocket connection is closed.

![Diagram depicts a client interacting with a web server, connecting with HTTP, upgrading the connection to the WebSocket protocol, and continuing communication over the WebSocket protocol.](media/websockets/websockets.svg)

Note

After a connection is upgraded to WebSocket, as an intermediary/terminating proxy, Application Gateway for Containers will send the data received from the frontend to the backend and vice-versa, without any inspection or manipulation capability. Therefore, any manipulations like Header Rewrites, URL Rewrites, or Overriding Hostname will not apply after establishing a WebSocket connection.

WebSocket connections may be either in plain-text or encrypted over TLS. When a connection is established over plain-text, the connection is established in the format of ws://&lt;fqdn&gt;/path. When a connection is established over TLS, the connection is established in the format of wss://&lt;fqdn&gt;/path.

### Health probes

No configuration is required to leverage a WebSocket request in Application Gateway for Containers, however you must ensure you properly configure health probes to ensure the backend is reflected as healthy.

By default, Application Gateway for Containers attempts to initiate an HTTP handshake to the backend port running the WebSocket service. In many cases, this erroneously labels the backend as unhealthy, so a HealthCheckPolicy should be defined to ensure the health probe considers use of a TCP probe.

Here's an example of a HealthCheckPolicy for a WebSocket backend.

```bash
kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: HealthCheckPolicy
metadata:
  name: websockets-health-check-policy
  namespace: test-infra
spec:
  targetRef:
    group: ""
    kind: Service
    name: websockets-backend
    namespace: test-infra
  default:
    interval: 5s
    timeout: 3s
    healthyThreshold: 1
    unhealthyThreshold: 1
    http:
      path: /health 
EOF
```

Note

WebSockets are only supported when using Gateway API for Application Gateway for Containers.

### Metrics & Monitoring

Diagnostic Logs:

WebSocket connections operate using a distinct protocol. Upon initiating the connection, the browser receives an HTTP 101 status code, indicating the switch from HTTP to WebSocket and will be reflected in the access log.

The details of the WebSocket connection are recorded only when the connection closes. This allows the duration of each connection to be accurately measured.