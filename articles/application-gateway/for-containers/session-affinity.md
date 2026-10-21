---
layout: Conceptual
title: Session affinity overview for Azure Application Gateway for Containers | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/session-affinity
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
description: Learn how to configure session affinity for Azure Application Gateway for Containers.
services: application gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: concept-article
ms.date: 2025-07-02T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: 7a5579f7-51d6-3d61-f85b-a89971db8d75
document_version_independent_id: 31c67bc6-7dc7-c729-1896-cb449448c85e
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/session-affinity.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/session-affinity
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/session-affinity.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
platformId: 6cfca247-db70-36e5-80ad-b9c604175b38
---

# Session affinity overview for Azure Application Gateway for Containers | Microsoft Learn

Session affinity, also known as *session persistence* or *sticky sessions*, is a technique used in load balancing to ensure a client's requests are always sent to the same server. This is important for applications that store user data in session variables or in a local cache on a particular server (commonly referred to as a stateful application).

With session affinity, Application Gateway for Containers presents a cookie in the **Set-Cookie** header of the first response. If the client presents the cookie in future requests, Application Gateway for Containers recognizes the cookie and forwards traffic to the same backend target. See the following example scenario:

![A diagram depicting Application Gateway for Containers session affinity.](media/session-affinity/session-affinity.png)

The following steps are depicted in the previous diagram:

1. A client initiates a request to an Application Gateway for Containers' (Application Gateway for Containers) frontend.
2. Application Gateway for Containers selects one of the many available pods to load balance the request to. In this example, we assume Pod C is selected out of the four available pods.
3. Pod C returns a response to Application Gateway for Containers.
4. In addition to the backend response from Pod C, Application Gateway for Containers adds a Set-Cookie header containing a uniquely generated hash used for routing.
5. The client sends another request to Application Gateway for Containers along with the session affinity cookie set in the previous step.
6. Application Gateway for Containers detects the cookie and selects Pod C to serve the request.
7. Pod C responds to Application Gateway for Containers.
8. Application Gateway for Containers returns the response to the client

## Usage details

[Session affinity](api-specification-kubernetes#alb.networking.azure.io/v1.SessionAffinity) is defined by the following properties and characteristics:

| Name | Description |
| --- | --- |
| affinityType | Valid values are application-cookie or managed-cookie. |
| cookieName | Required if affinityType is application-cookie. This is the name of the cookie. |
| cookieDuration | Required if affinityType is application-cookie. This is the duration (lifetime) of the cookie in seconds. |

In managed cookie affinity type, Application Gateway uses predefined values when the cookie is offered to the client.

- The name of the cookie is: `AGCAffinity`.
- The duration (lifetime) of the cookie is 86,400 seconds (one day).
- The `cookieName` and `cookieDuration` properties and values are discarded.

In application affinity type, the cookie name and duration (lifetime) must be explicitly defined.

## How to configure session affinity

# [Gateway API](#tab/session-affinity-gateway-api)
Session affinity can be defined in a [RoutePolicy](api-specification-kubernetes#alb.networking.azure.io/v1.RoutePolicy) resource, which targets a defined HTTPRoute. You must specify `sessionAffinity` with an `affinityType` of either `application-cookie` or `managed-cookie`. In this example, we use `application-cookie` as the affinityType and explicitly define a cookie name and lifetime.

Example command to create a new RoutePolicy with a defined cookie called `nomnom` with a lifetime of 3,600 seconds (1 hour).

```bash
kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: RoutePolicy
metadata:
  name: session-affinity-route-policy
spec:
  targetRef:
    kind: HTTPRoute
    name: http-route
    namespace: test-infra
    group: ""
  default:
    sessionAffinity: 
      affinityType: "application-cookie"
      cookieName: "nomnom"
      cookieDuration: 3600s
EOF
```

# [Ingress API](#tab/session-affinity-ingress-api)
Session affinity can be defined in an [IngressExtension](api-specification-kubernetes#alb.networking.azure.io/v1.IngressExtensionSpec) resource. You must specify `sessionAffinity` with an `affinityType` of either `application-cookie` or `managed-cookie`. In this example, we use `application-cookie` as the affinityType and explicitly define a cookie name and lifetime.

Example command to create a new IngressExtension with a defined cookie called `nomnom` with a lifetime of 3,600 seconds (1 hour) targeting a backend service called `echo`.

```bash
kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: IngressExtension
metadata:
  name: session-affinity-ingress-extension
  namespace: test-infra
spec:
  backendSettings:
    - service: echo # replace with your service name
      sessionAffinity:
        affinityType: "application-cookie"
        cookieName: "nomnom"
        cookieDuration: 3600s
EOF
```

---