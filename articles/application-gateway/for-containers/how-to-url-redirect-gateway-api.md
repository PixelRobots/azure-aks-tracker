---
layout: Conceptual
title: URL Redirect for Azure Application Gateway for Containers - Gateway API | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/how-to-url-redirect-gateway-api
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
description: Learn how to redirect URLs in Gateway API for Application Gateway for Containers.
services: application gateway
author: mbender-ms
ms.service: azure-application-gateway-containers
ms.topic: how-to
ms.date: 2024-11-05T00:00:00.0000000Z
ms.author: mbender
locale: en-us
document_id: edaddef6-393e-9cf3-ad97-c7976bd23dab
document_version_independent_id: 22dd72a9-14f1-f507-ceb4-18fce1a97ffd
original_content_git_url: https://github.com/MicrosoftDocs/azure-docs-pr/blob/live/articles/application-gateway/for-containers/how-to-url-redirect-gateway-api.md
site_name: Docs
depot_name: Azure.azure-documents
page_type: conceptual
toc_rel: toc.json
pdf_url_template: https://learn.microsoft.com/pdfstore/en-us/Azure.azure-documents/{branchName}{pdfName}
asset_id: application-gateway/for-containers/how-to-url-redirect-gateway-api
moniker_range_name: 
monikers: []
item_type: Content
source_path: articles/application-gateway/for-containers/how-to-url-redirect-gateway-api.md
cmProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/d4cf20b3-3e54-4ed9-8b09-370a52eee81b
- https://authoring-docs-microsoft.poolparty.biz/devrel/f98c9a19-e481-4f15-8047-76b641e6ed57
spProducts:
- https://authoring-docs-microsoft.poolparty.biz/devrel/9ecc2643-be13-4271-a1f4-87114737d63a
- https://authoring-docs-microsoft.poolparty.biz/devrel/f5685781-a4fd-40f1-8126-59abde4643bf
platformId: 327b73c5-6a59-cd57-2323-95a2e667f92f
---

# URL Redirect for Azure Application Gateway for Containers - Gateway API | Microsoft Learn

Application Gateway for Containers allows you to return a redirect response to the client based three aspects of a URL: protocol, hostname, and path. For each redirect, a defined HTTP status code may be returned to the client to define the nature of the redirect.

## Usage details

URL redirects take advantage of the [RequestRedirect rule filter](https://gateway-api.sigs.k8s.io/reference/api-spec/main/spec/#httprequestredirectfilter) as defined by Kubernetes Gateway API.

## Redirection

A redirect sets the response status code returned to clients to understand the purpose of the redirect. The following types of redirection are supported:

- 301 (Moved permanently): Indicates that the target resource is assigned a new permanent URI. Future references to this resource use one of the enclosed URIs. Use 301 status code for HTTP to HTTPS redirection.
- 302 (Found): Indicates that the target resource is temporarily under a different URI. Since the redirection can change on occasion, the client should continue to use the effective request URI for future requests.

## Redirection capabilities

- Protocol redirection is commonly used to tell the client to move from an unencrypted traffic scheme to traffic, such as HTTP to HTTPS redirection.
- Hostname redirection matches the fully qualified domain name (FQDN) of the request. This is commonly observed in redirecting an old domain name to a new domain name; such as `contoso.com` to `fabrikam.com`.
- Path redirection has two different variants: `prefix` and `full`.

    - `Prefix` redirection type will redirect all requests starting with a defined value. For example: a prefix of /shop would match /shop and any text after. For example, /shop, /shop/checkout, and /shop/item-a would all redirect to /shop as well.
    - `Full` redirection type matches an exact value. For example: /shop could redirect to /store, but /shop/checkout wouldn't redirect to /store.

The following figure illustrates an example of a request destined for *contoso.com/summer-promotion* being redirected to *contoso.com/shop/category/5*. In addition, a second request initiated to contoso.com via http protocol returns a redirect to initiate a new connection to its https variant.

[![A diagram showing the Application Gateway for Containers returning a redirect URL to a client.](media/how-to-url-redirect-gateway-api/url-redirect.png)](media/how-to-url-redirect-gateway-api/url-redirect.png#lightbox)

## Prerequisites

1. If following the BYO deployment strategy, ensure you set up your Application Gateway for Containers resources and ALB Controller ([Add-on](quickstart-deploy-application-gateway-for-containers-alb-controller-addon) or [Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm)).
2. If following the ALB managed deployment strategy, ensure you provision your ALB Controller ([Add-on](quickstart-deploy-application-gateway-for-containers-alb-controller-addon) or [Helm](quickstart-deploy-application-gateway-for-containers-alb-controller-helm)) and provision the Application Gateway for Containers resources via the [ApplicationLoadBalancer custom resource](quickstart-create-application-gateway-for-containers-managed-by-alb-controller).
3. Deploy sample HTTP application:

    Apply the following deployment.yaml file on your cluster to deploy a sample TLS certificate to demonstrate redirect capabilities.

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/MicrosoftDocs/azure-docs/refs/heads/main/articles/application-gateway/for-containers/examples/https-scenario/ssl-termination/deployment.yaml
    ```

    This command creates the following on your cluster:

    - a namespace called `test-infra`
    - one service called `echo` in the `test-infra` namespace
    - one deployment called `echo` in the `test-infra` namespace
    - one secret called `listener-tls-secret` in the `test-infra` namespace

## Deploy the required Gateway API resources

# [ALB managed deployment](#tab/alb-managed)
1. Create a Gateway

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
      - name: https-listener
        port: 443
        protocol: HTTPS
        allowedRoutes:
          namespaces:
            from: Same
        tls:
          mode: Terminate
          certificateRefs:
          - kind : Secret
            group: ""
            name: listener-tls-secret
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
2. Create a Gateway

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
      - name: https-listener
        port: 443
        protocol: HTTPS
        allowedRoutes:
          namespaces:
            from: Same
        tls:
          mode: Terminate
          certificateRefs:
          - kind : Secret
            group: ""
            name: listener-tls-secret
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
  - type: Hostname
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

Create an HTTPRoute resource for `contoso.com` that handles traffic received via https.

```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: https-contoso
  namespace: test-infra
spec:
  parentRefs:
  - name: gateway-01
    sectionName: https-listener
  hostnames:
  - "contoso.com"
  rules:
  - backendRefs:
    - name: echo
      port: 80
EOF
```

When the HTTPRoute resource is created, ensure the HTTPRoute resource shows *Accepted* and the Application Gateway for Containers resource is *Programmed*.

```bash
kubectl get httproute rewrite-example -n test-infra -o yaml
```

Verify the Application Gateway for Containers resource is successfully updated for each HTTPRoute.

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

Once the gateway is created, create an HTTPRoute resource for `contoso.com` with a RequestRedirect filter that redirects http traffic to https.

```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: http-to-https-contoso-redirect
  namespace: test-infra
spec:
  parentRefs:
  - name: gateway-01
    sectionName: http-listener
  hostnames:
  - "contoso.com"
  rules:
    - matches:
      filters:
        - type: RequestRedirect
          requestRedirect:
            scheme: https
            statusCode: 301
EOF
```

When the HTTPRoute resource is created, ensure the HTTPRoute resource shows *Accepted* and the Application Gateway for Containers resource is *Programmed*.

```bash
kubectl get httproute rewrite-example -n test-infra -o yaml
```

Verify the Application Gateway for Containers resource is successfully updated for each HTTPRoute.

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

Create an HTTPRoute resource for `contoso.com` that handles a redirect for the path /summer-promotion to a specific URL. By eliminating sectionName, demonstrated in the http to https HTTPRoute resources, this redirect rule applies to both HTTP and HTTPS requests.

```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: summer-promotion-redirect
  namespace: test-infra
spec:
  parentRefs:
  - name: gateway-01
    sectionName: https-listener
  hostnames:
  - "contoso.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /summer-promotion
    filters:
      - type: RequestRedirect
        requestRedirect:
          path:
            type: ReplaceFullPath
            replaceFullPath: /shop/category/5
          statusCode: 302
  - backendRefs:
    - name: echo
      port: 80
EOF
```

When the HTTPRoute resource is created, ensure the HTTPRoute resource shows *Accepted* and the Application Gateway for Containers resource is *Programmed*.

```bash
kubectl get httproute rewrite-example -n test-infra -o yaml
```

Verify the Application Gateway for Containers resource is successfully updated for each HTTPRoute.

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

Now we're ready to send some traffic to our sample application, via the FQDN assigned to the frontend. Use the following command to get the FQDN.

```bash
fqdn=$(kubectl get gateway gateway-01 -n test-infra -o jsonpath='{.status.addresses[0].value}')
```

When you specify the server name indicator using the curl command, `http://contoso.com` should return a response from the Application Gateway for Containers with a `location` header defining a 301 redirect to `https://contoso.com`.

```bash
fqdnIp=$(dig +short $fqdn)
curl -k --resolve contoso.com:80:$fqdnIp http://contoso.com/ -v
```

Via the response we should see:

```text
* Added contoso.com:80:xxx.xxx.xxx.xxx to DNS cache
* Hostname contoso.com was found in DNS cache
*   Trying xxx.xxx.xxx.xxx:80...
* Connected to contoso.com (xxx.xxx.xxx.xxx) port 80 (#0)
> GET / HTTP/1.1
> Host: contoso.com
> User-Agent: curl/7.81.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 301 Moved Permanently
< location: https://contoso.com/
< date: Mon, 26 Feb 2024 22:56:23 GMT
< server: Microsoft-Azure-Application-LB/AGC
< content-length: 0
<
* Connection #0 to host contoso.com left intact
```

When you specify the server name indicator using the curl command, `https://contoso.com/summer-promotion` Application Gateway for Containers should return a 302 redirect to `https://contoso.com/shop/category/5`.

```bash
fqdnIp=$(dig +short $fqdn)
curl -k --resolve contoso.com:443:$fqdnIp https://contoso.com/summer-promotion -v
```

Via the response we should see:

```text
> GET /summer-promotion HTTP/2
> Host: contoso.com
> user-agent: curl/7.81.0
> accept: */*
>
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
< HTTP/2 302
< location: https://contoso.com/shop/category/5
< date: Mon, 26 Feb 2024 22:58:43 GMT
< server: Microsoft-Azure-Application-LB/AGC
<
* Connection #0 to host contoso.com left intact
```

Congratulations, you have installed ALB Controller, deployed a backend application, and used Gateway API to configure both an HTTP to HTTPS redirect and path based redirection to specific client requests.