---
layout: Conceptual
title: Header rewrite for Azure Application Gateway for Containers - Gateway API | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/how-to-header-rewrite-gateway-api
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
description: Learn how to rewrite headers in Gateway API for Application Gateway for Containers.
services: application gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: how-to
ms.date: 2025-10-27T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: 2b063f3c-3e56-7edb-3da2-b7d082b2569e
document_version_independent_id: 6aca5b1e-ce0a-4107-6855-2a384fb6e9e8
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/how-to-header-rewrite-gateway-api.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/how-to-header-rewrite-gateway-api
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/how-to-header-rewrite-gateway-api.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: c266417c-bcf1-2cc9-2c05-c1591be34745
---

# Header rewrite for Azure Application Gateway for Containers - Gateway API | Microsoft Learn

Application Gateway for Containers allows you to rewrite HTTP headers of client requests and responses from backend targets.

## Usage details

Header rewrites take advantage of [filters](https://gateway-api.sigs.k8s.io/references/spec/#gateway.networking.k8s.io/v1.HTTPURLRewriteFilter) as defined by Kubernetes Gateway API.

## Background

Header rewrites enable you to modify the request and response headers to and from your backend targets.

The following figure illustrates a request with a specific user agent being rewritten to a simplified value called SearchEngine-BingBot when the request is initiated to the backend target by Application Gateway for Containers:

[![A diagram showing the Application Gateway for Containers rewriting a request header to the backend.](media/how-to-header-rewrite-gateway-api/header-rewrite.png)](media/how-to-header-rewrite-gateway-api/header-rewrite.png#lightbox)

## Prerequisites

1. If following the BYO deployment strategy, ensure that you set up your Application Gateway for Containers resources and ALB Controller ([Add-on](quickstart-deploy-application-gateway-for-containers-alb-controller-addon) or [Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm))
2. If you're following the ALB managed deployment strategy, ensure provisioning of the ALB Controller ([Add-on](quickstart-deploy-application-gateway-for-containers-alb-controller-addon) or [Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm)) the Application Gateway for Containers resources via the [ApplicationLoadBalancer custom resource](quickstart-create-application-gateway-for-containers-managed-by-alb-controller).
3. Deploy sample HTTP application Apply the following deployment.yaml file on your cluster to create a sample web application to demonstrate the header rewrite.

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/MicrosoftDocs/azure-docs/refs/heads/main/articles/application-gateway/for-containers/examples/traffic-split-scenario/deployment.yaml
    ```

    This command creates the following on your cluster:

    - a namespace called `test-infra`
    - two services called `backend-v1` and `backend-v2` in the `test-infra` namespace
    - two deployments called `backend-v1` and `backend-v2` in the `test-infra` namespace

## Deploy the required Gateway API resources

# [ALB managed deployment](#tab/alb-managed)
Create a gateway:

```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway-01
  namespace: test-infra
  annotations:
    alb.networking.azure.io/alb-namespace: alb-test-infra
    alb.networking.azure.io/alb-name: alb-test
spec:
  gatewayClassName: azure-alb-external
  listeners:
  - name: http-listener
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
EOF
```

Note

When the ALB Controller creates the Application Gateway for Containers resources in Azure Resource Manager, it uses the following naming convention for a frontend resource: `fe-<eight randomly generated characters>`.

If you want to change the name of the frontend resource created in Azure, consider following the [bring-your-own deployment strategy](overview#deployment-strategies).

# [Bring your own (BYO) deployment](#tab/byo)
1. Set the following environment variables

```bash
RESOURCE_GROUP='<resource group name of the Application Gateway For Containers resource>'
RESOURCE_NAME='alb-test'

RESOURCE_ID=$(az network alb show --resource-group $RESOURCE_GROUP --name $RESOURCE_NAME --query id -o tsv)
FRONTEND_NAME='frontend'
```

1. Create a Gateway

```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway-01
  namespace: test-infra
  annotations:
    alb.networking.azure.io/alb-id: $RESOURCE_ID
spec:
  gatewayClassName: azure-alb-external
  listeners:
  - name: http-listener
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
  addresses:
  - type: alb.networking.azure.io/alb-frontend
    value: $FRONTEND_NAME
EOF
```

---

Once the gateway resource is created, ensure the status is valid, the listener is *Programmed*, and an address is assigned to the gateway.

```bash
kubectl get gateway gateway-01 -n test-infra -o yaml
```

Example output of successful gateway creation.

```yaml
status:
  addresses:
  - type: IPAddress
    value: xxxx.yyyy.alb.azure.com
  conditions:
  - lastTransitionTime: "2023-06-19T21:04:55Z"
    message: Valid Gateway
    observedGeneration: 1
    reason: Accepted
    status: "True"
    type: Accepted
  - lastTransitionTime: "2023-06-19T21:04:55Z"
    message: Application Gateway For Containers resource has been successfully updated.
    observedGeneration: 1
    reason: Programmed
    status: "True"
    type: Programmed
  listeners:
  - attachedRoutes: 0
    conditions:
    - lastTransitionTime: "2023-06-19T21:04:55Z"
      message: ""
      observedGeneration: 1
      reason: ResolvedRefs
      status: "True"
      type: ResolvedRefs
    - lastTransitionTime: "2023-06-19T21:04:55Z"
      message: Listener is accepted
      observedGeneration: 1
      reason: Accepted
      status: "True"
      type: Accepted
    - lastTransitionTime: "2023-06-19T21:04:55Z"
      message: Application Gateway For Containers resource has been successfully updated.
      observedGeneration: 1
      reason: Programmed
      status: "True"
      type: Programmed
    name: https-listener
    supportedKinds:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
```

Once the gateway is created, create an HTTPRoute that listens for hostname contoso.com and overrides the user-agent value to SearchEngine-BingBot.

In this example, we look for the user agent used by the Bing search engine and simplify the header to SearchEngine-BingBot for easier backend parsing.

This example also demonstrates addition of a new header called `AGC-Header-Add` with a value of `AGC-value` and removes a request header called `client-custom-header`.

Tip

For this example, while we can use the HTTPHeaderMatch of "Exact" for a string match, a demonstration is used in regular expression for illustration of further capabilities.

```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: header-rewrite-route
  namespace: test-infra
spec:
  parentRefs:
    - name: gateway-01
      namespace: test-infra
  hostnames:
    - "contoso.com"
  rules:
    - matches:
        - headers:
          - name: user-agent
            value: Mozilla/5\.0 AppleWebKit/537\.36 \(KHTML, like Gecko; compatible; bingbot/2\.0; \+http://www\.bing\.com/bingbot\.htm\) Chrome/
            type: RegularExpression
      filters:
        - type: RequestHeaderModifier
          requestHeaderModifier:
            set:
              - name: user-agent
                value: SearchEngine-BingBot
            add:
              - name: AGC-Header-Add
                value: AGC-value
            remove: ["client-custom-header"]
      backendRefs:
        - name: backend-v2
          port: 8080
    - backendRefs:
        - name: backend-v1
          port: 8080
EOF
```

Note

Modifying the `Host` header is not supported with a `requestHeaderModifier` rule. To override the `Host` value specified to the backend target, use a [URLRewrite](how-to-url-rewrite-gateway-api#deploy-the-required-gateway-api-resources) filter.

Once the HTTPRoute resource is created, ensure the route is *Accepted* and the Application Gateway for Containers resource is *Programmed*.

```bash
kubectl get httproute header-rewrite-route -n test-infra -o yaml
```

Verify the status of the Application Gateway for Containers resource has been successfully updated.

```yaml
status:
  parents:
  - conditions:
    - lastTransitionTime: "2023-06-19T22:18:23Z"
      message: ""
      observedGeneration: 1
      reason: ResolvedRefs
      status: "True"
      type: ResolvedRefs
    - lastTransitionTime: "2023-06-19T22:18:23Z"
      message: Route is Accepted
      observedGeneration: 1
      reason: Accepted
      status: "True"
      type: Accepted
    - lastTransitionTime: "2023-06-19T22:18:23Z"
      message: Application Gateway For Containers resource has been successfully updated.
      observedGeneration: 1
      reason: Programmed
      status: "True"
      type: Programmed
    controllerName: alb.networking.azure.io/alb-controller
    parentRef:
      group: gateway.networking.k8s.io
      kind: Gateway
      name: gateway-01
      namespace: test-infra
```

## Test access to the application

Now we're ready to send some traffic to our sample application, via the FQDN assigned to the frontend. Use the following command to get the FQDN:

```bash
fqdn=$(kubectl get gateway gateway-01 -n test-infra -o jsonpath='{.status.addresses[0].value}')
```

If you specify the server name indicator using the curl command, `contoso.com` for the frontend FQDN, the output should return a response from the backend-v1 service.

```bash
fqdnIp=$(dig +short $fqdn)
curl -k --resolve contoso.com:80:$fqdnIp http://contoso.com
```

Via the response we should see:

```json
{
 "path": "/",
 "host": "contoso.com",
 "method": "GET",
 "proto": "HTTP/1.1",
 "headers": {
  "Accept": [
   "*/*"
  ],
  "User-Agent": [
   "curl/7.81.0"
  ],
  "X-Forwarded-For": [
   "xxx.xxx.xxx.xxx"
  ],
  "X-Forwarded-Proto": [
   "http"
  ],
  "X-Request-Id": [
   "dcd4bcad-ea43-4fb6-948e-a906380dcd6d"
  ]
 },
 "namespace": "test-infra",
 "ingress": "",
 "service": "",
 "pod": "backend-v1-5b8fd96959-f59mm"
}
```

Specifying a user-agent header with the value `` should return a response from the backend service of SearchEngine-BingBot:

```bash
fqdnIp=$(dig +short $fqdn)
curl -k --resolve contoso.com:80:$fqdnIp http://contoso.com -H "user-agent: Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/"
```

Via the response we should see:

```json
{
 "path": "/",
 "host": "fabrikam.com",
 "method": "GET",
 "proto": "HTTP/1.1",
 "headers": {
  "Accept": [
   "*/*"
  ],
  "User-Agent": [
   "curl/7.81.0"
  ],
  "X-Forwarded-For": [
   "xxx.xxx.xxx.xxx"
  ],
  "X-Forwarded-Proto": [
   "http"
  ],
  "X-Request-Id": [
   "adae8cc1-8030-4d95-9e05-237dd4e3941b"
  ]
 },
 "namespace": "test-infra",
 "ingress": "",
 "service": "",
 "pod": "backend-v2-5b8fd96959-f59mm"
}
```

Specifying a `client-custom-header` header with the value `moo` should be stripped from the request when Application Gateway for Containers initiates the connection to the backend service:

```bash
fqdnIp=$(dig +short $fqdn)
curl -k --resolve contoso.com:80:$fqdnIp http://contoso.com -H "client-custom-header: moo"
```

Via the response we should see:

```json
{
 "path": "/",
 "host": "fabrikam.com",
 "method": "GET",
 "proto": "HTTP/1.1",
 "headers": {
  "Accept": [
   "*/*"
  ],
  "User-Agent": [
   "curl/7.81.0"
  ],
  "X-Forwarded-For": [
   "xxx.xxx.xxx.xxx"
  ],
  "X-Forwarded-Proto": [
   "http"
  ],
  "X-Request-Id": [
   "kd83nc84-4325-5d22-3d23-237dd4e3941b"
  ]
 },
 "namespace": "test-infra",
 "ingress": "",
 "service": "",
 "pod": "backend-v2-5b8fd96959-f59mm"
}
```

Congratulations, you have installed ALB Controller, deployed a backend application and modified header values via Gateway API on Application Gateway for Containers.